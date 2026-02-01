import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/vaccine_model.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';

class VaccineProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  final AuthService _authService = authService;

  StreamSubscription? _subscription;

  List<Vaccine> _vaccines = [];
  bool _isLoading = true;
  DateTime? _dob;

  // ───────── Getters ─────────
  List<Vaccine> get vaccines => _vaccines;
  bool get isLoading => _isLoading;
  DateTime? get dob => _dob;

  // ───────── Progress ─────────
  int get completedCount =>
      _vaccines.where((v) => v.actualDate != null).length;

  int get totalCount => _vaccines.length;

  double get progressPercentage =>
      totalCount == 0 ? 0 : completedCount / totalCount;

  // ───────── Next upcoming vaccine ─────────
  Vaccine? get nextUpcomingVaccine {
    if (_dob == null) return null;

    final pending = _vaccines
        .where((v) => v.getStatus(_dob!) != VaccineStatus.done)
        .toList();

    if (pending.isEmpty) return null;

    pending.sort((a, b) =>
        a.getDueDate(_dob!).compareTo(b.getDueDate(_dob!)));

    return pending.first;
  }

  // ───────── Init with DOB ─────────
  void initializeWithDob(DateTime dob) {
    _dob = dob;
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _authService.getVaccinations().listen((list) {
      _vaccines = list;
      _isLoading = false;
      notifyListeners();
    });
  }

  // ───────── Mark vaccine done ─────────
  Future<void> markAsDone(String id, DateTime actualDate) async {
    final index = _vaccines.indexWhere((v) => v.id == id);
    if (index == -1) return;

    final updated = _vaccines[index].copyWith(
      actualDate: actualDate,
    );

    _vaccines[index] = updated;
    notifyListeners();

    await _notificationService.cancelReminders(updated);
    await _authService.updateVaccine(updated);

  }

  // ───────── Cleanup ─────────
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
