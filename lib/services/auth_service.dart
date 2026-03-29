import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:navajeev_m/models/user_model.dart';
import '../models/appointment_model.dart';
import '../models/vaccine_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? _firebaseUser;
  UserModel? _currentUser;
  bool _isLoading = true;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _firebaseUser != null;
  UserModel? get currentUser => _currentUser;
  bool get isProfileComplete {
    if (_currentUser == null) return false;

    if (_currentUser!.stage == UserStage.onboarding) {
      return false;
    }

    // Pregnancy user -> profile complete
    if (_currentUser!.stage == UserStage.pregnancy) {
      return true;
    }

    // Postpartum user-> must have active baby
    if (_currentUser!.stage == UserStage.postpartum) {
      return _currentUser!.activeBabyId != null;
    }

    return false;
  }

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    // Case 1: Logged out
    if (user == null) {
      _firebaseUser = null;
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Case 2: Logged in (first time only)
    if (_firebaseUser?.uid != user.uid || _currentUser == null) {
      _firebaseUser = user;
      _isLoading = true;
      notifyListeners();

      final doc = await _db.collection('users').doc(user.uid).get();

      if (doc.exists) {
        var userModel = _fromFirestore(doc);

        // load baby once if postpartum
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
          );
        }

        _currentUser = userModel;
      }

      _isLoading = false;
      notifyListeners();
    }

    // ELSE: ignore rebuilds
  }

  Future<BabyDetails?> _fetchBaby(String babyId) async {
    final doc = await _db.collection('babies').doc(babyId).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    return BabyDetails(
      name: data['name'],
      dateOfBirth: DateTime.parse(data['dob']),
      gender: BabyGender.values.byName(data['gender']),
      birthHeight: data['birthHeight'],
      birthWeight: data['birthWeight'],
      deliveryType: data['deliveryType'],
      feedingType: data['feedingType'],
    );
  }
  // Auth
  Future<void> signUp(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = cred.user!.uid;

    //Explicit onboarding stage
    await _db.collection('users').doc(uid).set({
      'stage': UserStage.onboarding.name,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }
// PREGNANCY: Save USER only
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

    //UPDATE LOCAL STATE IMMEDIATELY
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

// POSTPARTUM: Save USER + BABY
  Future<void> savePostpartumProfile({
    required String parentName,
    required ParentRole role,
    required BabyDetails baby,
  }) async {
    if (_firebaseUser == null) return;

    final uid = _firebaseUser!.uid;
    final babyRef = _db.collection('babies').doc();

    // 1.Save baby
    await babyRef.set({
      'name': baby.name,
      'dob': baby.dateOfBirth.toIso8601String(),
      'gender': baby.gender.name,
      'parent_uids': [uid],
      'created_at': FieldValue.serverTimestamp(),
      'active': true,
    });

    // 2.Save user
    await _db.collection('users').doc(uid).set({
      'name': parentName,
      'role': role.name,
      'stage': UserStage.postpartum.name,
      'active_baby_id': babyRef.id,
      'created_at': FieldValue.serverTimestamp(),
    });

    // 3.Seed vaccinations
    await seedVaccinationsForBaby(babyRef.id);

// UPDATE LOCAL STATE
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
  // Get active baby id
  Future<String?> getActiveBabyId() async {
    if (_firebaseUser == null) return null;

    final doc =
    await _db.collection('users').doc(_firebaseUser!.uid).get();

    if (!doc.exists) return null;

    return doc.data()?['active_baby_id'];
  }

  // Seed vaccinations
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
        .map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => Vaccine.fromFirestore(doc.id, doc.data()),
      )
          .toList();
    });
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
        .update({
      'actualDate': actualDate.toIso8601String(),
    });
  }

  // APPOINTMENTS (NEW)
  Stream<List<Appointment>> getAppointments(String? babyId) {
    if (_firebaseUser == null) return Stream.value([]);

    final collectionPath = babyId != null
        ? _db.collection('babies').doc(babyId).collection('appointments')
        : _db.collection('users').doc(_firebaseUser!.uid).collection('appointments');

    return collectionPath
        .orderBy('scheduledAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Appointment.fromFirestore(doc.id, doc.data()))
        .toList());
  }

  //Save a new appointment
  Future<void> addAppointment(Appointment appointment, String? babyId) async {
    if (_firebaseUser == null) return;

    final collectionPath = babyId != null
        ? _db.collection('babies').doc(babyId).collection('appointments')
        : _db.collection('users').doc(_firebaseUser!.uid).collection('appointments');

    await collectionPath.add(appointment.toFirestore());
  }

  Future<void> toggleAppointmentStatus(String appointmentId, bool currentStatus, String? babyId) async {
    if (_firebaseUser == null) return;

    final docPath = babyId != null
        ? _db.collection('babies').doc(babyId).collection('appointments').doc(appointmentId)
        : _db.collection('users').doc(_firebaseUser!.uid).collection('appointments').doc(appointmentId);

    await docPath.update({'isCompleted': !currentStatus});
  }

  // Delete an appointment
  Future<void> deleteAppointment(String appointmentId, String? babyId) async {
    final docPath = babyId != null
        ? _db.collection('babies').doc(babyId).collection('appointments').doc(appointmentId)
        : _db.collection('users').doc(_firebaseUser!.uid).collection('appointments').doc(appointmentId);

    await docPath.delete();
  }

  // Firestore → UserModel
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

    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      role: ParentRole.values.byName(data['role'] ?? 'mother'),
      stage: UserStage.values.byName(data['stage']),
      activeBabyId: data['active_baby_id'],
      pregnancyDetails: pregnancy,
    );
  }


}

