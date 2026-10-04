import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/ai_insight_result.dart';
import '../models/recommendation_result.dart';
import '../services/ai_service.dart';

class AiInsightProvider extends ChangeNotifier {

  final Map<String, String> _dataHashes = {};
  final Map<String, AiInsightResult> _results = {};
  final Map<String, bool> _loading = {};
  final Map<String, String?> _errors = {};

  // Typed recommendation state
  final Map<String, RecommendationResult> _recommendations = {};
  final Map<String, String> _recommendationHashes = {};
  final Map<String, bool> _recommendationLoading = {};
  final Map<String, String?> _recommendationErrors = {};

  // NEW KEY (userId + module + subject)
  String _key(String userId, String module, String subject) {
    return "$userId-$module-$subject";
  }

  AiInsightResult? getResult(String userId, String module, String subject) {
    return _results[_key(userId, module, subject)];
  }

  bool isLoading(String userId, String module, String subject) {
    return _loading[_key(userId, module, subject)] ?? false;
  }

  String? getError(String userId, String module, String subject) {
    return _errors[_key(userId, module, subject)];
  }

  // Typed getters for Recommendation
  RecommendationResult? getRecommendation(String userId) {
    return _recommendations[userId];
  }

  bool isRecommendationLoading(String userId) {
    return _recommendationLoading[userId] ?? false;
  }

  String? getRecommendationError(String userId) {
    return _recommendationErrors[userId];
  }

  Future<void> fetchInsight({
    required String userId,
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

  Future<void> fetchRecommendation({
    required String userId,
    int? babyAgeWeeks,
    String? sleepPattern,
    String? feedingPattern,
    String? moodTrend,
    int? pregnancyWeek,
    String? topConcern,
    bool forceRefresh = false,
  }) async {

    final payloadMap = {
      if (babyAgeWeeks != null) 'baby_age_weeks': babyAgeWeeks,
      if (sleepPattern != null) 'sleep_pattern': sleepPattern,
      if (feedingPattern != null) 'feeding_pattern': feedingPattern,
      if (moodTrend != null) 'mood_trend': moodTrend,
      if (pregnancyWeek != null) 'pregnancy_week': pregnancyWeek,
      if (topConcern != null) 'top_concern': topConcern,
    };

    final newHash = jsonEncode(payloadMap);

    if (!forceRefresh &&
        _recommendations.containsKey(userId) &&
        _recommendationHashes[userId] == newHash) {
      return;
    }

    final legacyKey = "$userId-recommendation";

    _loading[legacyKey] = true;
    _recommendationLoading[userId] = true;
    _errors[legacyKey] = null;
    _recommendationErrors[userId] = null;
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

      final typedResult = RecommendationResult.fromJson(response);
      _recommendations[userId] = typedResult;
      _recommendationHashes[userId] = newHash;

      _results[legacyKey] = AiInsightResult.fromJson(
        {'success': true, 'result': response['result'] ?? response},
        'recommendation',
      );

    } catch (e) {
      final err = e.toString();
      _errors[legacyKey] = err;
      _recommendationErrors[userId] = err;
      _recommendations[userId] = RecommendationResult.error(err);
      _results[legacyKey] = AiInsightResult.error('recommendation', err);
    } finally {
      _loading[legacyKey] = false;
      _recommendationLoading[userId] = false;
      notifyListeners();
    }
  }

  void clearModule(String userId, String module) {
    _results.removeWhere((key, _) => key.startsWith("$userId-$module"));
    _loading.removeWhere((key, _) => key.startsWith("$userId-$module"));
    _errors.removeWhere((key, _) => key.startsWith("$userId-$module"));
    notifyListeners();
  }

  void clearUser(String userId) {
    _results.removeWhere((key, _) => key.startsWith(userId));
    _loading.removeWhere((key, _) => key.startsWith(userId));
    _errors.removeWhere((key, _) => key.startsWith(userId));
    _recommendations.remove(userId);
    _recommendationHashes.remove(userId);
    _recommendationLoading.remove(userId);
    _recommendationErrors.remove(userId);
    notifyListeners();
  }

  void clearAll() {
    _results.clear();
    _loading.clear();
    _errors.clear();
    _recommendations.clear();
    _recommendationHashes.clear();
    _recommendationLoading.clear();
    _recommendationErrors.clear();
    notifyListeners();
  }
}
