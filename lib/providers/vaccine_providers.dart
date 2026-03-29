import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/vaccine_model.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';

class VaccineProvider extends ChangeNotifier {
  final AuthService _authService;

  VaccineProvider({required AuthService authService})
      : _authService = authService;

  StreamSubscription? _sub;
  List<Vaccine> _vaccines = [];
  bool _isLoading = true;

  DateTime? _babyDob;
  String? _babyId;

  List<Vaccine> get vaccines => _vaccines;
  bool get isLoading => _isLoading;

  int get completedCount =>
      _vaccines.where((v) => v.actualDate != null).length;

  int get totalCount => _vaccines.length;

  Vaccine? get nextUpcomingVaccine {
    if (_babyDob == null) return null;

    final pending = _vaccines
        .where((v) => v.actualDate == null)
        .toList();

    if (pending.isEmpty) return null;

    pending.sort((a, b) {
      final aDue = a.getDueDate(_babyDob!);
      final bDue = b.getDueDate(_babyDob!);
      return aDue.compareTo(bDue);
    });

    return pending.first;
  }

  void initialize({
    required String babyId,
    required DateTime babyDob,
  }) {
    _babyId = babyId;
    _babyDob = babyDob;

    _sub?.cancel();
    _isLoading = true;
    notifyListeners();

    _sub = _authService
        .getVaccinationsForBaby(babyId)
        .listen((list) {
      _vaccines = list;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> markAsDone(String vaccineId, DateTime date) async {
    if (_babyId == null) return;

    await _authService.markVaccinationGiven(
      babyId: _babyId!,
      vaccineId: vaccineId,
      actualDate: date,
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
