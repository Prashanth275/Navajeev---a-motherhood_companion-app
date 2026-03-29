import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/sleep/sleep_session.dart';
import '../../repositories/sleep/sleep_repository.dart';
import '../../services/auth_service.dart';
import '../../services/sleep/sleep_analyzer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SleepProvider extends ChangeNotifier {
  final AuthService auth;
  final FirebaseFirestore firestore;


  late SleepRepository _repository;

  List<SleepSession> _sessions = [];
  bool _isLoading = true;
  bool _isMotherSelected = true;
  bool _isPregnancyMode = false;

  bool get isPregnancyMode => _isPregnancyMode;

  StreamSubscription<List<SleepSession>>? _subscription;

  SleepProvider({
    required this.auth,
    required this.firestore,
  }) {
    _init();
  }

  //GETTERS

  bool get isLoading => _isLoading;
  bool get isMotherSelected => _isMotherSelected;

  Duration get todayTotal =>
      SleepAnalyzer.getTodayTotal(_sessions);

  Duration get todayNight =>
      SleepAnalyzer.getTodayNightTotal(_sessions);

  int get todayNaps =>
      SleepAnalyzer.getTodayNapCount(_sessions);

  List<double> get weeklyHours =>
      SleepAnalyzer.getWeeklyHours(_sessions);

  int _babyAgeMonths = 0;

  int get babyAgeMonths => _babyAgeMonths;

  String get statusOrQuality {
    if (_isMotherSelected) {
      return SleepAnalyzer.getMotherQuality(todayTotal);
    } else {
      return SleepAnalyzer.getBabyStatus(
        total: todayTotal,
        ageMonths: _babyAgeMonths,
      );
    }
  }

  //INIT

  Future<void> _init() async {
    _subscription?.cancel();

    _isLoading = true;
    notifyListeners();

    final uid = auth.currentUser!.id;

    final userDoc =
    await firestore.collection('users').doc(uid).get();

    final stage = userDoc.data()?['stage']?.toString().toLowerCase();

    _isPregnancyMode = stage == 'pregnancy';

    _repository = SleepRepository(
      firestore: firestore,
      auth: auth,
      isMother: _isMotherSelected,
    );

    if (!_isMotherSelected) {
      final babyId = await auth.getActiveBabyId();

      if (babyId != null) {
        final babyDoc = await firestore
            .collection('babies')
            .doc(babyId)
            .get();

        final dobField = babyDoc.data()?['dob'];

        DateTime dob;

        if (dobField is Timestamp) {
          dob = dobField.toDate();
        } else if (dobField is String) {
          dob = DateTime.parse(dobField);
        } else {
          throw Exception("Invalid DOB format");
        }

        final now = DateTime.now();

        _babyAgeMonths =
            (now.year - dob.year) * 12 +
                (now.month - dob.month);
      }
    }


    _subscription = _repository.streamSessions().listen((data) {
      _sessions = data;
      _isLoading = false;
      notifyListeners();
    },
      onError: (error) {
        print("Sleep stream error: $error");
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // TOGGLE

  void toggleMode(bool isMother) {
    if (_isMotherSelected == isMother) return;

    _isMotherSelected = isMother;
    _init();
  }

  //ADD SESSION

  Future<void> addSession({
    required DateTime start,
    required DateTime end,
    required bool isNight,
  }) async {
    final session = SleepSession(
      id: '',
      startTime: start,
      endTime: end,
      isNight: isNight,
    );
    await _repository.addSession(session);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}