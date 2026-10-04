import 'dart:convert';

class RecommendationResult {
  final bool success;
  final String? weeklyFocus;
  final List<String> dailyRoutine;
  final List<String> nutritionTips;
  final List<String> selfCare;
  final String? devActivity;
  final String? errorMessage;

  const RecommendationResult({
    required this.success,
    this.weeklyFocus,
    this.dailyRoutine = const [],
    this.nutritionTips = const [],
    this.selfCare = const [],
    this.devActivity,
    this.errorMessage,
  });

  factory RecommendationResult.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> rootMap = json;
    final rawResult = json['result'];
    final extractedResult = _tryExtractMap(rawResult);
    if (extractedResult != null) {
      rootMap = extractedResult;
    }

    final bool isSuccess = json['success'] as bool? ?? rootMap['success'] as bool? ?? true;

    // Helper for string fields
    String? getString(String key) {
      final val = rootMap[key] ?? json[key];
      if (val is String && val.trim().isNotEmpty) {
        return _sanitizeHumanText(val);
      }
      return null;
    }

    List<String> getList(String key) {
      final val = rootMap[key] ?? json[key];
      if (val is List) {
        return val
            .map((e) => _sanitizeHumanText(e.toString()))
            .where((s) => s.isNotEmpty)
            .toList();
      }
      if (val is String && val.trim().isNotEmpty) {
        final sanitized = _sanitizeHumanText(val);
        return [sanitized];
      }
      return const [];
    }

    return RecommendationResult(
      success: isSuccess,
      weeklyFocus: getString('weekly_focus') ?? getString('weeklyFocus'),
      dailyRoutine: getList('daily_routine').isNotEmpty
          ? getList('daily_routine')
          : getList('dailyRoutine'),
      nutritionTips: getList('nutrition_tips').isNotEmpty
          ? getList('nutrition_tips')
          : getList('nutritionTips'),
      selfCare: getList('self_care').isNotEmpty
          ? getList('self_care')
          : getList('selfCare'),
      devActivity: getString('dev_activity') ?? getString('devActivity'),
      errorMessage: null,
    );
  }

  factory RecommendationResult.error(String message) {
    return RecommendationResult(
      success: false,
      errorMessage: message,
    );
  }

  bool get hasContent =>
      (weeklyFocus != null && weeklyFocus!.isNotEmpty) ||
      dailyRoutine.isNotEmpty ||
      nutritionTips.isNotEmpty ||
      selfCare.isNotEmpty ||
      (devActivity != null && devActivity!.isNotEmpty);
}

Map<String, dynamic>? _tryExtractMap(dynamic input) {
  if (input == null) return null;
  if (input is Map<String, dynamic>) return input;
  if (input is Map) return Map<String, dynamic>.from(input);
  if (input is! String) return null;

  String text = input.trim();
  if (text.isEmpty) return null;

  final fenceMatch = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```').firstMatch(text);
  if (fenceMatch != null && fenceMatch.group(1) != null) {
    text = fenceMatch.group(1)!.trim();
  }

  try {
    final decoded = jsonDecode(text);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
  } catch (_) {}

  final startBrace = text.indexOf('{');
  final lastBrace = text.lastIndexOf('}');
  if (startBrace != -1 && lastBrace > startBrace) {
    final candidate = text.substring(startBrace, lastBrace + 1).trim();
    try {
      final decoded = jsonDecode(candidate);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
  }

  return null;
}

String _sanitizeHumanText(String text) {
  String cleaned = text.trim();
  final fenceMatch = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```').firstMatch(cleaned);
  if (fenceMatch != null && fenceMatch.group(1) != null) {
    cleaned = fenceMatch.group(1)!.trim();
  }
  if (cleaned.startsWith('"') && cleaned.endsWith('"') && cleaned.length >= 2) {
    cleaned = cleaned.substring(1, cleaned.length - 1).trim();
  }
  return cleaned;
}
