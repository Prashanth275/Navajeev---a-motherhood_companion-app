import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../models/wellbeing/wellbeing_model.dart';
import '../../repositories/wellbeing/wellbeing_repository.dart';

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
}