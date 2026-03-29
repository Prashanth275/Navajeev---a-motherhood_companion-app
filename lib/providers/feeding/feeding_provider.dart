import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../models/feeding/feeding_model.dart';
import '../../repositories/feeding/feeding_repository.dart';
import '../../services/auth_service.dart';

class FeedingProvider extends ChangeNotifier {
  final FeedingRepository _repository;
  final AuthService _authService;

  FeedingProvider({
    required FeedingRepository repository,
    required AuthService authService,
  })  : _repository = repository,
        _authService = authService;

  // DATE STATE

  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  void setSelectedDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
  }

  StreamSubscription<List<Feeding>>? _subscription;

  List<Feeding> _feedings = [];
  bool _isLoading = true;
  String? _error;

  List<Feeding> get feedings => _feedings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // INITIALIZE

  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      final babyId = await _authService.getActiveBabyId();

      if (babyId == null) {
        _error = "No active baby selected";
        _isLoading = false;
        notifyListeners();
        return;
      }

      _subscription?.cancel();

      _subscription =
          _repository.streamFeedings(babyId).listen((data) {
            _feedings = data
              ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

            _isLoading = false;
            notifyListeners();
          });
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // FILTERED BY SELECTED DATE

  List<Feeding> get filteredFeedings {
    return _feedings.where((f) {
      return f.timestamp.year == _selectedDate.year &&
          f.timestamp.month == _selectedDate.month &&
          f.timestamp.day == _selectedDate.day;
    }).toList();
  }

  // SUMMARY CALCULATIONS

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

    if (hours > 0) {
      return "${hours}h ${minutes}m ago";
    }
    return "${minutes}m ago";
  }

  // ADD

  Future<void> addFeeding(Feeding feeding) async {
    final babyId = await _authService.getActiveBabyId();
    if (babyId == null) return;

    await _repository.addFeeding(
      babyId: babyId,
      feeding: feeding,
    );
  }
  // DELETE

  Future<void> deleteFeeding(String feedingId) async {
    final babyId = await _authService.getActiveBabyId();
    if (babyId == null) return;

    await _repository.deleteFeeding(
      babyId: babyId,
      feedingId: feedingId,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}