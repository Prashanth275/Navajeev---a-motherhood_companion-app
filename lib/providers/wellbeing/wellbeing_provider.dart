import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../models/wellbeing/wellbeing_model.dart';
import '../../models/sleep/sleep_session.dart';
import '../../repositories/wellbeing/wellbeing_repository.dart';
import '../../services/sleep/sleep_analyzer.dart';

class WellbeingProvider extends ChangeNotifier {
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;
  final WellbeingRepository repo;
  final AuthService auth;

  WellbeingProvider({
    required this.repo,
    required this.auth,
  });

  String get _uid => auth.currentUser!.id;

  Stream<List<WellbeingEntry>> get entriesStream =>
      repo.streamEntries(_uid);

  Future<WellbeingEntry?> getTodayEntry() async {
    final todayId = _formatDate(DateTime.now());
    return await repo.getEntry(_uid, todayId);
  }

  Future<String> _getUserStage() async {
    final doc = await firestore
        .collection('users')
        .doc(_uid)
        .get();

    if (!doc.exists) return "pregnancy";

    return doc.data()?['stage'] ?? "pregnancy";
  }

  List<WellbeingEntry> _entries = [];
  StreamSubscription? _subscription;

  List<WellbeingEntry> get entries => _entries;

  Future<void> initialize() async {
    _subscription?.cancel();

    _subscription =
        repo.streamEntries(_uid).listen((data) {
          _entries = data;
          notifyListeners();
        });
  }
  WellbeingEntry? get todayEntry {
    final todayId = _formatDate(DateTime.now());

    try {
      return _entries.firstWhere((e) => e.id == todayId);
    } catch (_) {
      return null;
    }
  }
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> saveEntry({
    required DateTime date,
    required int mood,
    required int energy,
    required int stress,
    required int sleepQuality,
    required String notes,
  }) async {

    final stage = await _getUserStage();
    final id = _formatDate(date);

    final entry = WellbeingEntry(
      id: id,
      date: date,
      mood: mood,
      energy: energy,
      stress: stress,
      sleepQuality: sleepQuality,
      notes: notes,
      stage: stage,
    );

    await repo.upsertEntry(_uid, entry);
  }

  String _formatDate(DateTime date) {
    return "${date.year}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  List<WellbeingEntry> _getLast7Days(
      List<WellbeingEntry> entries,
      ) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return entries
        .where((e) => e.date.isAfter(weekAgo))
        .toList();
  }

  double _average(
      List<WellbeingEntry> entries,
      int Function(WellbeingEntry) selector,
      ) {
    if (entries.isEmpty) return 0;

    final total =
    entries.fold(0, (sum, e) => sum + selector(e));

    return total / entries.length;
  }

  double calculateWeeklyMoodAverage(
      List<WellbeingEntry> entries,
      ) {
    final weekly = _getLast7Days(entries);
    return _average(weekly, (e) => e.mood);
  }

  double calculateWeeklyStressAverage(
      List<WellbeingEntry> entries,
      ) {
    final weekly = _getLast7Days(entries);
    return _average(weekly, (e) => e.stress);
  }

  double calculateWeeklyEnergyAverage(
      List<WellbeingEntry> entries,
      ) {
    final weekly = _getLast7Days(entries);
    return _average(weekly, (e) => e.energy);
  }

  double calculateWeeklySleepAverage(
      List<WellbeingEntry> entries,
      ) {
    final weekly = _getLast7Days(entries);
    return _average(weekly, (e) => e.sleepQuality);
  }

  Future<List<SleepSession>> fetchRecentMotherSleepSessions({int days = 14}) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final snapshot = await firestore
        .collection('users')
        .doc(_uid)
        .collection('mother_sleep')
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(cutoff))
        .orderBy('startTime', descending: true)
        .get();

    return snapshot.docs.map((doc) => SleepSession.fromDoc(doc)).toList();
  }

  Future<Map<String, dynamic>> buildCorrelatedAiPayload({int days = 14}) async {
    final motherSleepSessions = await fetchRecentMotherSleepSessions(days: days);

    final Map<String, double> dailySleep = {};
    for (final session in motherSleepSessions) {
      final split = SleepAnalyzer.splitByDay(session);
      split.forEach((date, duration) {
        final dateKey = _formatDate(date);
        final hours = duration.inMinutes / 60.0;
        dailySleep[dateKey] = (dailySleep[dateKey] ?? 0.0) + hours;
      });
    }

    final cutoff = DateTime.now().subtract(Duration(days: days));
    final recentWellbeing = _entries
        .where((e) => e.date.isAfter(cutoff) || e.date.isAtSameMomentAs(cutoff))
        .toList();

    recentWellbeing.sort((a, b) => b.date.compareTo(a.date));

    final moodLogs = recentWellbeing.map((entry) {
      final dateKey = _formatDate(entry.date);
      final sleepHours = dailySleep[dateKey] ?? 0.0;
      return {
        'date': dateKey,
        'mood_score': entry.mood,
        'sleep_hours': double.parse(sleepHours.toStringAsFixed(1)),
        'note': entry.notes.isNotEmpty ? entry.notes : 'none',
      };
    }).toList();

    final userModel = auth.currentUser;
    int? babyAgeWeeks;
    String daysPostpartum = 'unknown';

    if (userModel != null && userModel.isPostpartum && userModel.babyDob != null) {
      final dob = userModel.babyDob!;
      final diffDays = DateTime.now().difference(dob).inDays;
      daysPostpartum = diffDays.toString();
      babyAgeWeeks = diffDays ~/ 7;
    }

    return {
      'baby_age_weeks': babyAgeWeeks,
      'data': {
        'days_postpartum': daysPostpartum,
        'mood_logs': moodLogs,
      },
    };
  }
}