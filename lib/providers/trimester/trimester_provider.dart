import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/trimester/trimester_week_model.dart';
import '../../repositories/trimester/trimester_repository.dart';
import '../../services/auth_service.dart';

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

      final uid = _authService.currentUser?.id;
      if (uid == null) {
        _error = "User not logged in";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!doc.exists) {
        _error = "User data not found";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final data = doc.data();
      final pregnancy = data?['pregnancy'];

      if (pregnancy == null || pregnancy['edd'] == null) {
        _error = "Due date not set";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final eddString = pregnancy['edd'];
      final dueDate = DateTime.parse(eddString);

      final week = _repository.calculateCurrentWeek(dueDate);
      _currentWeekData = await _repository.getWeekData(week);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}