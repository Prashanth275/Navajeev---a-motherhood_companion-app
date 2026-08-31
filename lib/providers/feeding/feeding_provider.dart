import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/feeding/feeding_model.dart';
import '../../repositories/feeding/feeding_repository.dart';
import '../../services/auth_service.dart';

class FeedingProvider extends ChangeNotifier {
  final FeedingRepository _repository;
  AuthService _authService;
  String? _currentBabyId;

  FeedingProvider({
    required FeedingRepository repository,
    required AuthService authService,
  })  : _repository = repository,
        _authService = authService;

  void updateAuth(AuthService authService) {
    _authService = authService;
    if (_authService.isLoading) return;
    final newBabyId = _authService.currentUser?.activeBabyId;
    if (newBabyId != _currentBabyId) {
      initialize();
    }
  }

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  void setSelectedDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
  }

  StreamSubscription<List<Feeding>>? _subscription;
  Timer? _loadTimeoutTimer;
  bool _gotFirstEvent = false;
  List<Feeding> _feedings = [];
  bool _isLoading = true;
  String? _error;
  bool _isDisposed = false;

  List<Feeding> get feedings => _feedings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    if (_isDisposed) return;
    if (_authService.isLoading) {
      void listener() {
        if (_isDisposed) return;
        if (!_authService.isLoading) {
          _authService.removeListener(listener);
          initialize();
        }
      }
      _authService.addListener(listener);
      return;
    }

    try {
      final babyId = _authService.currentUser?.activeBabyId;

      if (babyId == _currentBabyId && _subscription != null && _error == null) {
        return;
      }
      if (babyId != _currentBabyId) {
        _subscription?.cancel();
        _subscription = null;
        _loadTimeoutTimer?.cancel();
      }

      _currentBabyId = babyId;

      if (babyId == null) {
        _error = "No active baby selected";
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (_isDisposed) return;
      _isLoading = true;
      _error = null;
      notifyListeners();

      _subscribeToFeedings(babyId);
    } catch (e) {
      if (_isDisposed) return;
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void _subscribeToFeedings(String babyId, {int retries = 0}) {
    if (_isDisposed) return;
    _subscription?.cancel();
    _loadTimeoutTimer?.cancel();
    _gotFirstEvent = false;

    _loadTimeoutTimer = Timer(const Duration(seconds: 8), () {
      if (_isDisposed) return;
      if (_gotFirstEvent) return;
      _subscription?.cancel();
      _subscription = null;

      if (retries < 4) {
        _subscribeToFeedings(babyId, retries: retries + 1);
      } else {
        _error = "Could not load feedings. Please check your connection and try again.";
        _isLoading = false;
        notifyListeners();
      }
    });

    _subscription = _repository.streamFeedings(babyId).listen(
          (data) {
        if (_isDisposed) return;
        _gotFirstEvent = true;
        _loadTimeoutTimer?.cancel();
        _feedings = data..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        if (_isDisposed) return;
        _gotFirstEvent = true;
        _loadTimeoutTimer?.cancel();
        final errStr = e.toString().toLowerCase();
        if ((errStr.contains('permission') || errStr.contains('denied')) && retries < 4) {
          final delayMs = (500 * (retries + 1)).clamp(0, 3000);
          Future.delayed(Duration(milliseconds: delayMs), () {
            if (_isDisposed) return;
            _subscribeToFeedings(babyId, retries: retries + 1);
          });
          return;
        }
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  List<Feeding> get filteredFeedings {
    return _feedings.where((f) {
      return f.timestamp.year == _selectedDate.year &&
          f.timestamp.month == _selectedDate.month &&
          f.timestamp.day == _selectedDate.day;
    }).toList();
  }

  int get breastCount =>
      filteredFeedings.where((f) => f.type.name == 'breast').length;

  int get bottleCount =>
      filteredFeedings.where((f) => f.type.name == 'bottle').length;

  int get solidCount =>
      filteredFeedings.where((f) => f.type.name == 'solid').length;

  double get totalBottleMl {
    return filteredFeedings
        .where((f) => f.type.name == 'bottle')
        .fold(0.0, (sum, f) => sum + (f.quantity ?? 0));
  }

  String? get lastFedText {
    if (filteredFeedings.isEmpty) return null;
    final latest = filteredFeedings.first;
    final diff = DateTime.now().difference(latest.timestamp);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    if (hours > 0) return "${hours}h ${minutes}m ago";
    return "${minutes}m ago";
  }

  Future<void> addFeeding(Feeding feeding) async {
    final babyId = await _authService.getActiveBabyId();
    if (babyId == null) return;

    if (babyId == _currentBabyId) {
      if (!_feedings.any((f) => f.id == feeding.id)) {
        _feedings.add(feeding);
        _feedings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        notifyListeners();
      }
    }

    await _repository.addFeeding(babyId: babyId, feeding: feeding);
  }

  Future<void> deleteFeeding(String feedingId) async {
    final babyId = await _authService.getActiveBabyId();
    if (babyId == null) return;

    if (babyId == _currentBabyId) {
      _feedings.removeWhere((f) => f.id == feedingId);
      notifyListeners();
    }

    await _repository.deleteFeeding(babyId: babyId, feedingId: feedingId);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _subscription?.cancel();
    _loadTimeoutTimer?.cancel();
    super.dispose();
  }
}