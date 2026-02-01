import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:navajeev_m/models/user_model.dart';
import 'package:navajeev_m/models/vaccine_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? _firebaseUser;
  UserModel? _currentUser;
  bool _isLoading = true;

  // ─────────────────────────────────────────
  // Getters
  // ─────────────────────────────────────────
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _firebaseUser != null;
  bool get isProfileComplete => _currentUser != null;
  UserModel? get currentUser => _currentUser;

  // ─────────────────────────────────────────
  // Constructor
  // ─────────────────────────────────────────
  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // ─────────────────────────────────────────
  // 🔁 Auth state listener
  // ─────────────────────────────────────────
  Future<void> _onAuthStateChanged(User? user) async {
    _firebaseUser = user;
    _currentUser = null;

    if (user != null) {
      final doc =
      await _db.collection('users').doc(user.uid).get();

      if (doc.exists) {
        _currentUser = _fromFirestore(doc);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─────────────────────────────────────────
  // 🔐 Register
  // ─────────────────────────────────────────
  Future<void> signUp(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ─────────────────────────────────────────
  // 🔐 Login
  // ─────────────────────────────────────────
  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ─────────────────────────────────────────
  // 🚪 Logout
  // ─────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ─────────────────────────────────────────
  // 💾 Save profile (after setup)
  Future<void> saveProfile(UserModel user) async {
    if (_firebaseUser == null) return;

    await _db.collection('users').doc(_firebaseUser!.uid).set({
      'name': user.name,
      'role': user.role.name,
      'stage': user.stage.name,
      'pregnancy': user.pregnancyDetails == null
          ? null
          : {
        'edd':
        user.pregnancyDetails!.expectedDueDate.toIso8601String(),
      },
      'baby': user.babyDetails == null
          ? null
          : {
        'name': user.babyDetails!.name,
        'dob':
        user.babyDetails!.dateOfBirth.toIso8601String(),
        'gender': user.babyDetails!.gender.name,
      },
    });

    _currentUser = user;

    // 🔥 Seed vaccines ONLY after profile completion
    await seedVaccinationsIfNeeded();

    notifyListeners();
  }

  // ─────────────────────────────────────────
  // 💉 Seed vaccination schedule (ONLY ONCE)
  // ─────────────────────────────────────────
  Future<void> seedVaccinationsIfNeeded() async {
    if (_firebaseUser == null || _currentUser?.babyDetails == null) return;

    final uid = _firebaseUser!.uid;
    final vaccinesRef =
    _db.collection('users').doc(uid).collection('vaccinations');

    // Prevent duplicate seeding
    final existing = await vaccinesRef.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    // Load WHO vaccine schedule
    final jsonString =
    await rootBundle.loadString('assets/vaccines/who_vaccines.json');

    final List<dynamic> jsonList = json.decode(jsonString);

    final batch = _db.batch();

    for (final item in jsonList) {
      final String id = item['id'];

      batch.set(
        vaccinesRef.doc(id),
        {
          'name': item['name'],
          'milestone': item['milestone'],
          'targetDaysFromBirth': item['targetDaysFromBirth'],
          'description': item['description'],
          'protection': item['protection'],
          'route': item['route'],
          'sideEffects': item['sideEffects'],
          'care': item['care'],
          'actualDate': null,
          'notes': null,
        },
      );
    }

    await batch.commit();
  }

  // ─────────────────────────────────────────
  // 🔄 Get vaccines (REAL-TIME STREAM)
  // ─────────────────────────────────────────
  Stream<List<Vaccine>> getVaccinations() {
    if (_firebaseUser == null) return const Stream.empty();

    return _db
        .collection('users')
        .doc(_firebaseUser!.uid)
        .collection('vaccinations')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
            (doc) =>
            Vaccine.fromFirestore(doc.id, doc.data()),
      )
          .toList();
    });
  }

  // ─────────────────────────────────────────
  // 💾 Update vaccine (actual date / notes)
  // ─────────────────────────────────────────
  Future<void> updateVaccine(Vaccine v) async {
    if (_firebaseUser == null) return;

    await _db
        .collection('users')
        .doc(_firebaseUser!.uid)
        .collection('vaccinations')
        .doc(v.id)
        .update({
      'actualDate': v.actualDate?.toIso8601String(),
      'notes': v.notes,
    });
  }

  // ─────────────────────────────────────────
  // 🔄 Firestore → UserModel
  // ─────────────────────────────────────────
  UserModel _fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    PregnancyDetails? pregnancy;
    BabyDetails? baby;

    if (data['pregnancy'] != null) {
      pregnancy = PregnancyDetails(
        expectedDueDate:
        DateTime.parse(data['pregnancy']['edd']),
      );
    }

    if (data['baby'] != null) {
      baby = BabyDetails(
        name: data['baby']['name'],
        dateOfBirth:
        DateTime.parse(data['baby']['dob']),
        gender: BabyGender.values.byName(
          data['baby']['gender'],
        ),
        birthHeight: data['baby']['birthHeight'],
        birthWeight: data['baby']['birthWeight'],
        deliveryType: data['baby']['deliveryType'],
        feedingType: data['baby']['feedingType'],
      );
    }

    return UserModel(
      id: doc.id,
      name: data['name'],
      role: ParentRole.values.byName(data['role']),
      stage: UserStage.values.byName(data['stage']),
      pregnancyDetails: pregnancy,
      babyDetails: baby,
    );
  }
}

// 🌍 Global instance
final authService = AuthService();
