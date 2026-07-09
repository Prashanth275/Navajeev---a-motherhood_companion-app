import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/ai_insight_result.dart';
import '../services/ai_service.dart';

class AiInsightProvider extends ChangeNotifier {

  final Map<String, String> _dataHashes = {};
  final Map<String, AiInsightResult> _results = {};
  final Map<String, bool> _loading = {};
  final Map<String, String?> _errors = {};

  // 🔑 NEW KEY (userId + module + subject)
  String _key(String userId, String module, String subject) {
    return "$userId-$module-$subject";
  }

  // -------------------------------------------------------
  // GETTERS
  // -------------------------------------------------------

  AiInsightResult? getResult(String userId, String module, String subject) {
    return _results[_key(userId, module, subject)];
  }

  bool isLoading(String userId, String module, String subject) {
    return _loading[_key(userId, module, subject)] ?? false;
  }

  String? getError(String userId, String module, String subject) {
    return _errors[_key(userId, module, subject)];
  }

  // -------------------------------------------------------
  // FETCH INSIGHT
  // -------------------------------------------------------

  Future<void> fetchInsight({
    required String userId,              // 🔥 NEW
    required String module,
    required String subject,
    int? babyAgeWeeks,
    required Map<String, dynamic> data,
    bool forceRefresh = false,
  }) async {

    final key = _key(userId, module, subject);

    final newHash = jsonEncode(data);

    if (!forceRefresh &&
        _results.containsKey(key) &&
        _dataHashes[key] == newHash) {
      return;
    }

    _loading[key] = true;
    _errors[key] = null;
    notifyListeners();

    try {
      final response = await aiService.getInsight(
        module: module,
        babyAgeWeeks: babyAgeWeeks,
        data: {
          ...data,
          "subject": subject,
        },
      );

      _results[key] = AiInsightResult.fromJson(response, module);
      _dataHashes[key] = newHash;
    } catch (e) {
      _errors[key] = e.toString();
      _results[key] = AiInsightResult.error(module, e.toString());
    } finally {
      _loading[key] = false;
      notifyListeners();
    }
  }

  // -------------------------------------------------------
  // FETCH RECOMMENDATION (USER-SAFE)
  // -------------------------------------------------------

  Future<void> fetchRecommendation({
    required String userId,              // 🔥 NEW
    int? babyAgeWeeks,
    String? sleepPattern,
    String? feedingPattern,
    String? moodTrend,
    int? pregnancyWeek,
    String? topConcern,
  }) async {

    final key = "$userId-recommendation";

    _loading[key] = true;
    _errors[key] = null;
    notifyListeners();

    try {
      final response = await aiService.getRecommendation(
        babyAgeWeeks: babyAgeWeeks,
        sleepPattern: sleepPattern,
        feedingPattern: feedingPattern,
        moodTrend: moodTrend,
        pregnancyWeek: pregnancyWeek,
        topConcern: topConcern,
      );

      _results[key] = AiInsightResult.fromJson(
        {'success': true, 'result': response['result'] ?? response},
        'recommendation',
      );

    } catch (e) {
      _errors[key] = e.toString();
      _results[key] = AiInsightResult.error('recommendation', e.toString());
    } finally {
      _loading[key] = false;
      notifyListeners();
    }
  }

  // -------------------------------------------------------
  // CLEAR METHODS
  // -------------------------------------------------------

  // 🔥 Clear only one module for a user
  void clearModule(String userId, String module) {
    _results.removeWhere((key, _) => key.startsWith("$userId-$module"));
    _loading.removeWhere((key, _) => key.startsWith("$userId-$module"));
    _errors.removeWhere((key, _) => key.startsWith("$userId-$module"));
    notifyListeners();
  }

  // 🔥 Clear only one user's data (BEST PRACTICE)
  void clearUser(String userId) {
    _results.removeWhere((key, _) => key.startsWith(userId));
    _loading.removeWhere((key, _) => key.startsWith(userId));
    _errors.removeWhere((key, _) => key.startsWith(userId));
    notifyListeners();
  }

  // 🔥 Clear everything (fallback)
  void clearAll() {
    _results.clear();
    _loading.clear();
    _errors.clear();
    notifyListeners();
  }
}