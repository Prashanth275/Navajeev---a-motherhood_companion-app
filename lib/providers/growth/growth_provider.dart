import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/growth_record_model.dart';
import '../../services/growth/growth_fetch_service.dart';
import '../../services/auth_service.dart';

class GrowthProvider extends ChangeNotifier {
  final AuthService auth;

  GrowthProvider({required this.auth});

  List<GrowthRecord> _records = [];
  bool _isLoading = true;

  StreamSubscription<List<GrowthRecord>>? _subscription;

  List<GrowthRecord> get records => _records;
  bool get isLoading => _isLoading;

  GrowthRecord? get latestRecord =>
      _records.isNotEmpty ? _records.last : null;

  Future<void> initialize() async {
    _subscription?.cancel();

    final babyId = auth.currentUser?.activeBabyId;
    if (babyId == null) return;

    _subscription =
        GrowthFetchService().streamGrowthRecords(babyId)
            .listen((data) {
          _records = data;
          _isLoading = false;
          notifyListeners();
        });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}