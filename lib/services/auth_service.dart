import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:navajeev_m/models/user_model.dart';
import '../models/appointment_model.dart';
import '../models/vaccine_model.dart';
import 'package:navajeev_m/services/growth/growth_service.dart';

import 'package:google_sign_in/google_sign_in.dart';


class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? _firebaseUser;
  UserModel? _currentUser;
  bool _isLoading = true;
  bool _fetchingUser = false;
  bool _isDeletingAccount = false;


  bool get isLoading => _isLoading;
  bool get isAuthenticated => _firebaseUser != null;
  UserModel? get currentUser => _currentUser;
  User? get firebaseUser => _firebaseUser;
  String? get userEmail => _firebaseUser?.email;
  bool get emailVerified => _firebaseUser?.emailVerified ?? false;

  bool get isProfileComplete {
    if (_currentUser == null) return false;
    if (_currentUser!.stage == UserStage.onboarding) return false;
    if (_currentUser!.stage == UserStage.pregnancy) return true;
    if (_currentUser!.stage == UserStage.postpartum) {
      return _currentUser!.activeBabyId != null;
    }
    return false;
  }

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (_isDeletingAccount) {
      if (user == null) {
        _isDeletingAccount = false;
        _firebaseUser = null;
        _currentUser = null;
        _fetchingUser = false;
        _isLoading = false;
        notifyListeners();
      }
      return;
    }

    if (user != null && !user.emailVerified) {
      try {
        await user.reload();
        user = _auth.currentUser;
      } catch (e) {
        debugPrint('Error reloading user on auth change: $e');
      }
    }

    // Case 1: Logged out
    if (user == null) {
      _firebaseUser = null;
      _currentUser = null;
      _fetchingUser = false;
      _isLoading = false;
      notifyListeners();
      return;
    }
    if (_firebaseUser?.uid == user.uid && (_fetchingUser || _currentUser != null)) {
      return;
    }

    _firebaseUser = user;
    _fetchingUser = true;
    _isLoading = true;
    notifyListeners();

    try {
      DocumentSnapshot<Map<String, dynamic>>? doc;
      int retries = 0;
      while (true) {
        try {
          doc = await _db.collection('users').doc(user.uid).get();
          break;
        } catch (e) {
          final errStr = e.toString().toLowerCase();
          if ((errStr.contains('permission') || errStr.contains('denied')) && retries < 4) {
            retries++;
            await Future.delayed(Duration(milliseconds: 500 * retries));
            continue;
          }
          debugPrint('❌ _onAuthStateChanged user fetch error: $e');
          break;
        }
      }

      if (doc == null || !doc.exists) {
        await _db.collection('users').doc(user.uid).set({
          'stage': UserStage.onboarding.name,
          'created_at': FieldValue.serverTimestamp(),
        });
        doc = await _db.collection('users').doc(user.uid).get();
      }

      if (doc != null && doc.exists) {
        var userModel = _fromFirestore(doc);

        if (userModel.stage == UserStage.postpartum &&
            userModel.activeBabyId != null) {
          final baby = await _fetchBaby(userModel.activeBabyId!);
          userModel = UserModel(
            id: userModel.id,
            name: userModel.name,
            role: userModel.role,
            stage: userModel.stage,
            activeBabyId: userModel.activeBabyId,
            pregnancyDetails: userModel.pregnancyDetails,
            babyDetails: baby,
            partnerDetails: userModel.partnerDetails,
          );
        }

        _currentUser = userModel;
      }
    } finally {
      _fetchingUser = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<BabyDetails?> _fetchBaby(String babyId) async {
    final doc = await _db.collection('babies').doc(babyId).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    return BabyDetails(
      name: data['name'],
      dateOfBirth: DateTime.parse(data['dob']),
      gender: BabyGender.values.byName(data['gender']),
      birthHeight: (data['birthHeight'] as num?)?.toDouble(),
      birthWeight: (data['birthWeight'] as num?)?.toDouble(),
      deliveryType: data['deliveryType'],
      feedingType: data['feedingType'],
    );
  }

  Future<void> signUp(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user!.uid;

    await cred.user!.sendEmailVerification();

    await _db.collection('users').doc(uid).set({
      'stage': UserStage.onboarding.name,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final GoogleAuthProvider provider = GoogleAuthProvider();
      provider.setCustomParameters({'prompt': 'select_account'});
      return await _auth.signInWithPopup(provider);
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      await GoogleSignIn.instance.initialize(
        serverClientId: '56811257855-2sgg4gk7b20f56r5mqke3sc5bu6dca47.apps.googleusercontent.com',
      );
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'popup-closed-by-user',
          message: 'Google sign-in was cancelled by the user.',
        );
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    }
    throw UnsupportedError(
      'Google Sign-In is currently configured for Web and Android only.',
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found.');
    }
    await user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    _firebaseUser = _auth.currentUser;
    notifyListeners();
    return _firebaseUser?.emailVerified ?? false;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (e) {
        debugPrint('Google Sign-In signOut error: $e');
      }
    }
    _currentUser = null;
    _firebaseUser = null;
    _fetchingUser = false;
    notifyListeners();
  }

  Future<void> _deleteCollection(CollectionReference collection) async {
    final snapshots = await collection.get();
    for (final doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      final uid = user.uid;

      _isDeletingAccount = true;
      notifyListeners();

      try {
        final babiesSnapshot = await _db
            .collection('babies')
            .where('parent_uids', arrayContains: uid)
            .get();

        final userRef = _db.collection('users').doc(uid);
        await _deleteCollection(userRef.collection('mother_sleep'));
        await _deleteCollection(userRef.collection('wellbeing_entries'));
        await _deleteCollection(userRef.collection('appointments'));

        await userRef.delete();

        for (final babyDoc in babiesSnapshot.docs) {
          final babyRef = babyDoc.reference;
          await _deleteCollection(babyRef.collection('feedings'));
          await _deleteCollection(babyRef.collection('baby_sleep'));
          await _deleteCollection(babyRef.collection('vaccinations'));
          await _deleteCollection(babyRef.collection('appointments'));
          await babyRef.delete();
        }

        await user.delete();

        _firebaseUser = null;
        _currentUser = null;
        _fetchingUser = false;
        _isDeletingAccount = false;
        notifyListeners();
      } catch (e) {
        _isDeletingAccount = false;
        notifyListeners();
        rethrow;
      }
    }
  }

  Future<void> savePregnancyProfile({
    required String parentName,
    required ParentRole role,
    required PregnancyDetails pregnancy,
  }) async {
    if (_firebaseUser == null) return;
    final uid = _firebaseUser!.uid;

    await _db.collection('users').doc(uid).set({
      'name': parentName,
      'role': role.name,
      'stage': UserStage.pregnancy.name,
      'pregnancy': {
        'edd': pregnancy.expectedDueDate.toIso8601String(),
        'enable_notifications': pregnancy.enableNotifications,
      },
      'created_at': FieldValue.serverTimestamp(),
    });

    _currentUser = UserModel(
      id: uid,
      name: parentName,
      role: role,
      stage: UserStage.pregnancy,
      pregnancyDetails: pregnancy,
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<void> savePostpartumProfile({
    required String parentName,
    required ParentRole role,
    required BabyDetails baby,
  }) async {
    if (_firebaseUser == null) return;
    final uid = _firebaseUser!.uid;
    final babyRef = _db.collection('babies').doc();

    await babyRef.set({
      'name': baby.name,
      'dob': baby.dateOfBirth.toIso8601String(),
      'gender': baby.gender.name,
      'parent_uids': [uid],
      'created_at': FieldValue.serverTimestamp(),
      'active': true,
      'birthWeight': baby.birthWeight,
      'birthHeight': baby.birthHeight,
      'deliveryType': baby.deliveryType,
      'feedingType': baby.feedingType,
    });

    await _db.collection('users').doc(uid).set({
      'name': parentName,
      'role': role.name,
      'stage': UserStage.postpartum.name,
      'active_baby_id': babyRef.id,
      'created_at': FieldValue.serverTimestamp(),
    });

    await seedVaccinationsForBaby(babyRef.id);

    if (baby.birthWeight != null || baby.birthHeight != null) {
      try {
        await GrowthService().addGrowthRecord(
          babyId: babyRef.id,
          baby: baby,
          checkInDate: baby.dateOfBirth,
          weightKg: baby.birthWeight,
          lengthCm: baby.birthHeight,
        );
      } catch (e) {
        debugPrint('Error seeding birth growth record: $e');
      }
    }

    _currentUser = UserModel(
      id: uid,
      name: parentName,
      role: role,
      stage: UserStage.postpartum,
      activeBabyId: babyRef.id,
      babyDetails: baby,
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> getActiveBabyId() async {

    if (_currentUser?.activeBabyId != null) {
      return _currentUser!.activeBabyId;
    }
    if (_firebaseUser == null) return null;

    final doc = await _db.collection('users').doc(_firebaseUser!.uid).get();
    if (!doc.exists) return null;

    final data = doc.data();
    return data?['active_baby_id'] ?? data?['activeBabyId'];
  }

  Future<void> seedVaccinationsForBaby(String babyId) async {
    final vaccinesRef =
    _db.collection('babies').doc(babyId).collection('vaccinations');

    final existing = await vaccinesRef.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final jsonString =
    await rootBundle.loadString('assets/vaccines/who_vaccines.json');
    final List list = json.decode(jsonString);

    for (final v in list) {
      await vaccinesRef.doc(v['id']).set({
        'name': v['name'],
        'milestone': v['milestone'],
        'targetDaysFromBirth': v['targetDaysFromBirth'],
        'description': v['description'],
        'protection': v['protection'],
        'sideEffects': v['sideEffects'],
        'care': v['care'],
        'actualDate': null,
        'notes': null,
      });
    }
  }

  Stream<List<Vaccine>> getVaccinationsForBaby(String babyId) {
    return _db
        .collection('babies')
        .doc(babyId)
        .collection('vaccinations')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Vaccine.fromFirestore(doc.id, doc.data()))
        .toList());
  }

  Future<void> markVaccinationGiven({
    required String babyId,
    required String vaccineId,
    required DateTime actualDate,
  }) async {
    await _db
        .collection('babies')
        .doc(babyId)
        .collection('vaccinations')
        .doc(vaccineId)
        .update({'actualDate': actualDate.toIso8601String()});
  }

  Stream<List<Appointment>> getAppointments(String? babyId) {
    if (_firebaseUser == null) return Stream.value([]);

    final collectionPath = babyId != null
        ? _db.collection('babies').doc(babyId).collection('appointments')
        : _db
        .collection('users')
        .doc(_firebaseUser!.uid)
        .collection('appointments');

    return collectionPath
        .orderBy('scheduledAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Appointment.fromFirestore(doc.id, doc.data()))
        .toList());
  }

  Future<void> addAppointment(Appointment appointment, String? babyId) async {
    if (_firebaseUser == null) return;

    final collectionPath = babyId != null
        ? _db.collection('babies').doc(babyId).collection('appointments')
        : _db
        .collection('users')
        .doc(_firebaseUser!.uid)
        .collection('appointments');

    await collectionPath.add(appointment.toFirestore());
  }

  Future<void> toggleAppointmentStatus(
      String appointmentId, bool currentStatus, String? babyId) async {
    if (_firebaseUser == null) return;

    final docPath = babyId != null
        ? _db
        .collection('babies')
        .doc(babyId)
        .collection('appointments')
        .doc(appointmentId)
        : _db
        .collection('users')
        .doc(_firebaseUser!.uid)
        .collection('appointments')
        .doc(appointmentId);

    await docPath.update({'isCompleted': !currentStatus});
  }

  Future<void> deleteAppointment(String appointmentId, String? babyId) async {
    final docPath = babyId != null
        ? _db
        .collection('babies')
        .doc(babyId)
        .collection('appointments')
        .doc(appointmentId)
        : _db
        .collection('users')
        .doc(_firebaseUser!.uid)
        .collection('appointments')
        .doc(appointmentId);

    await docPath.delete();
  }

  UserModel _fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    PregnancyDetails? pregnancy;
    if (data['pregnancy'] != null) {
      final p = data['pregnancy'];
      pregnancy = PregnancyDetails(
        expectedDueDate: DateTime.parse(p['edd']),
        enableNotifications: p['enable_notifications'] ?? true,
      );
    }

    PartnerDetails? partner;
    if (data['partner'] != null) {
      partner = PartnerDetails.fromJson(Map<String, dynamic>.from(data['partner']));
    }

    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      role: ParentRole.values.byName(data['role'] ?? 'mother'),
      stage: UserStage.values.byName(data['stage']),
      activeBabyId: data['active_baby_id'] ?? data['activeBabyId'],
      pregnancyDetails: pregnancy,
      partnerDetails: partner,
    );
  }

  Future<void> reloadUser() async {
    if (_firebaseUser == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final doc =
      await _db.collection('users').doc(_firebaseUser!.uid).get();
      if (!doc.exists) return;

      var userModel = _fromFirestore(doc);

      if (userModel.stage == UserStage.postpartum &&
          userModel.activeBabyId != null) {
        final baby = await _fetchBaby(userModel.activeBabyId!);
        userModel = UserModel(
          id: userModel.id,
          name: userModel.name,
          role: userModel.role,
          stage: userModel.stage,
          activeBabyId: userModel.activeBabyId,
          pregnancyDetails: userModel.pregnancyDetails,
          babyDetails: baby,
          partnerDetails: userModel.partnerDetails,
        );
      }

      _currentUser = userModel;
    } catch (e) {
      debugPrint('❌ reloadUser error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateExpectedDueDate(DateTime newDate) async {
    if (_firebaseUser == null) return;
    final uid = _firebaseUser!.uid;

    await _db.collection('users').doc(uid).update({
      'pregnancy.edd': newDate.toIso8601String(),
    });

    if (_currentUser != null) {
      final pDetails = _currentUser!.pregnancyDetails;
      final updatedPregnancy = PregnancyDetails(
        expectedDueDate: newDate,
        enableNotifications: pDetails?.enableNotifications ?? true,
      );

      _currentUser = UserModel(
        id: _currentUser!.id,
        name: _currentUser!.name,
        role: _currentUser!.role,
        stage: _currentUser!.stage,
        activeBabyId: _currentUser!.activeBabyId,
        pregnancyDetails: updatedPregnancy,
        babyDetails: _currentUser!.babyDetails,
        partnerDetails: _currentUser!.partnerDetails,
      );
      notifyListeners();
    }
  }

  Future<void> savePartnerDetails({
    required String name,
    required String email,
    required ParentRole role,
  }) async {
    if (_firebaseUser == null) return;
    final uid = _firebaseUser!.uid;

    await _db.collection('users').doc(uid).update({
      'partner': {
        'name': name,
        'email': email.trim().toLowerCase(),
        'role': role.name,
      },
    });

    await reloadUser();
  }

  Future<void> removePartnerDetails() async {
    if (_firebaseUser == null) return;
    final uid = _firebaseUser!.uid;

    await _db.collection('users').doc(uid).update({
      'partner': FieldValue.delete(),
    });

    await reloadUser();
  }
}