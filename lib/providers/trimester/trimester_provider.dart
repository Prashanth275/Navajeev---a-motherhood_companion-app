import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/trimester/trimester_week_model.dart';
import '../../repositories/trimester/trimester_repository.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

class TrimesterProvider extends ChangeNotifier {
  final TrimesterRepository _repository;
  final AuthService _authService;

  TrimesterProvider({
    required TrimesterRepository repository,
    required AuthService authService,
  })  : _repository = repository,
        _authService = authService;

  TrimesterWeekModel? _currentWeekData;
  bool _isLoading = true;
  String? _error;

  TrimesterWeekModel? get currentWeekData => _currentWeekData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = _authService.currentUser;
      if (user == null) {
        _error = "User not logged in";
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (user.stage != UserStage.pregnancy || user.pregnancyDetails == null) {
        _error = "Due date not set";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final dueDate = user.pregnancyDetails!.expectedDueDate;
      final week = _repository.calculateCurrentWeek(dueDate);
      _currentWeekData = await _repository.getWeekData(week);

      _error = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}