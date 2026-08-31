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

  bool get isLoading => _isLoading;

  bool get isMotherSelected => _isMotherSelected;

  StreamSubscription<List<SleepSession>>? _subscription;
  DateTime? _babyDob;

  int get babyAgeMonths {
    if (_babyDob == null) return 0;

    final now = DateTime.now();

    int months =
        (now.year - _babyDob!.year) * 12 +
            (now.month - _babyDob!.month);

    if (now.day < _babyDob!.day) {
      months--;
    }

    return months;
  }

  int get babyAgeWeeks {
    if (_babyDob == null) return 0;
    return DateTime
        .now()
        .difference(_babyDob!)
        .inDays ~/ 7;
  }

  Duration get todayTotal =>
      SleepAnalyzer.getTodayTotal(_sessions);

  Duration get todayNight =>
      SleepAnalyzer.getTodayNightTotal(_sessions);

  int get todayNaps =>
      SleepAnalyzer.getTodayNapCount(_sessions);

  List<double> get weeklyHours =>
      SleepAnalyzer.getWeeklyHours(_sessions);

  List<SleepSession> get sessions => _sessions;

  String get statusOrQuality {
    if (_isMotherSelected) {
      return SleepAnalyzer.getMotherQuality(todayTotal);
    } else {
      return SleepAnalyzer.getBabyStatus(
        total: todayTotal,
        ageMonths: babyAgeMonths,
      );
    }
  }

  SleepProvider({
    required this.auth,
    required this.firestore,
  }) {
    _init();
  }

  Future<void> _init() async {
    await _subscription?.cancel();

    _isLoading = true;
    _sessions = [];
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

        if (dobField is Timestamp) {
          _babyDob = dobField.toDate();
        } else if (dobField is String) {
          _babyDob = DateTime.parse(dobField);
        } else {
          throw Exception("Invalid DOB format");
        }
      }
    } else {
      _babyDob = null;
    }

    _subscription = _repository.streamSessions().listen(
          (data) {
        _sessions = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint("Sleep stream error: $error");
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void toggleMode(bool isMother) {
    if (_isMotherSelected == isMother) return;

    _isMotherSelected = isMother;

    _subscription?.cancel();
    _sessions = [];
    _babyDob = null;

    _init();
  }

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