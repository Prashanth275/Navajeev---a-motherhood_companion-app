
import 'dart:convert';

class AiInsightResult {
  final String module;
  final bool success;

  // Common across most modules
  final String? insight;
  final String? action;
  final String? severity; // "normal" | "watch" | "consult_doctor" | "seek_support"

  // Sleep
  final String? trend;
  final String? whoComparison;

  // Feeding
  final String? frequencyStatus;
  final String? tip;

  // Growth
  final String? weightStatus;
  final String? heightStatus;
  final String? milestonePrediction;

  // Trimester
  final String? weekSummary;
  final List<SymptomCheck>? symptomAssessment;
  final List<String>? actionItems;

  // Wellbeing
  final String? copingSuggestion;
  final bool showHelpline;

  // Appointments
  final List<String>? questions;
  final List<String>? bring;
  final List<String>? urgentItems;

  // Notifications
  final List<SmartAlert>? alerts;

  // Recommendation
  final List<String>? nutritionTips;
  final String? devActivity;
  final String? weeklyFocus;

  const AiInsightResult({
    required this.module,
    required this.success,
    this.insight,
    this.action,
    this.severity,
    this.trend,
    this.whoComparison,
    this.frequencyStatus,
    this.tip,
    this.weightStatus,
    this.heightStatus,
    this.milestonePrediction,
    this.weekSummary,
    this.symptomAssessment,
    this.actionItems,
    this.copingSuggestion,
    this.showHelpline = false,
    this.questions,
    this.bring,
    this.urgentItems,
    this.alerts,
    this.nutritionTips,
    this.devActivity,
    this.weeklyFocus,
  });

  factory AiInsightResult.fromJson(
    Map<String, dynamic> json,
    String module,
  ) {
    // 1. Unpack top-level or 'result' field
    Map<String, dynamic> rootMap = json;
    final rawResult = json['result'];
    final extractedResult = _tryExtractMap(rawResult);
    if (extractedResult != null) {
      rootMap = extractedResult;
    }

    // 2. Unpack 'insight' field if it contains nested or stringified JSON
    Map<String, dynamic>? innerMap;
    final candidateInsight = rootMap['insight'] ?? json['insight'];
    if (candidateInsight is String && _looksLikeJson(candidateInsight)) {
      innerMap = _tryExtractMap(candidateInsight);
    }

    // Priority for fields: innerMap (from decoded insight JSON) -> rootMap -> json
    T? getField<T>(String key) {
      if (innerMap != null && innerMap[key] != null && innerMap[key] is T) {
        return innerMap[key] as T;
      }
      if (rootMap[key] != null && rootMap[key] is T) {
        return rootMap[key] as T;
      }
      if (json[key] != null && json[key] is T) {
        return json[key] as T;
      }
      return null;
    }

    // Clean insight text so raw JSON syntax is NEVER displayed on UI
    String? finalInsight;
    if (innerMap != null && innerMap['insight'] is String) {
      finalInsight = innerMap['insight'] as String;
    } else if (candidateInsight is String) {
      finalInsight = candidateInsight;
    }

    if (finalInsight != null) {
      finalInsight = _sanitizeHumanText(finalInsight);
    }

    return AiInsightResult(
      module: module,
      success: json['success'] as bool? ?? rootMap['success'] as bool? ?? true,
      insight: finalInsight,
      action: getField<String>('action'),
      severity: getField<String>('severity'),
      trend: getField<String>('trend'),
      whoComparison: getField<String>('who_comparison'),
      frequencyStatus: getField<String>('frequency_status'),
      tip: getField<String>('tip'),
      weightStatus: getField<String>('weight_status'),
      heightStatus: getField<String>('height_status'),
      milestonePrediction: getField<String>('milestone_prediction'),
      weekSummary: getField<String>('week_summary'),
      symptomAssessment: (getField<List>('symptom_assessment'))
          ?.whereType<Map<String, dynamic>>()
          .map((e) => SymptomCheck.fromJson(e))
          .toList(),
      actionItems: (getField<List>('action_items'))
          ?.map((e) => e.toString())
          .toList(),
      copingSuggestion: getField<String>('coping_suggestion'),
      showHelpline: getField<bool>('show_helpline') ?? false,
      questions:
          (getField<List>('questions'))?.map((e) => e.toString()).toList(),
      bring: (getField<List>('bring'))?.map((e) => e.toString()).toList(),
      urgentItems:
          (getField<List>('urgent_items'))?.map((e) => e.toString()).toList(),
      alerts: (getField<List>('alerts'))
          ?.whereType<Map<String, dynamic>>()
          .map((e) => SmartAlert.fromJson(e))
          .toList(),
      nutritionTips:
          (getField<List>('nutrition_tips'))?.map((e) => e.toString()).toList(),
      devActivity: getField<String>('dev_activity'),
      weeklyFocus: getField<String>('weekly_focus'),
    );
  }

  factory AiInsightResult.error(String module, String message) {
    return AiInsightResult(
      module: module,
      success: false,
      insight: 'Could not load insight: $message',
    );
  }

  // Converts severity string to an enum for easy UI logic
  SeverityLevel get severityLevel {
    switch (severity) {
      case 'watch':
      case 'moderate':
        return SeverityLevel.watch;
      case 'consult_doctor':
      case 'seek_support':
      case 'critical':
        return SeverityLevel.urgent;
      default:
        return SeverityLevel.normal;
    }
  }
}

// ---------------------------------------------------------------------------
// Robust helper methods to guarantee no raw JSON leaks to UI
// ---------------------------------------------------------------------------

bool _looksLikeJson(String text) {
  final trimmed = text.trim();
  return trimmed.contains('{') ||
      trimmed.contains('```json') ||
      trimmed.contains('"insight":') ||
      trimmed.contains('"trend":') ||
      trimmed.contains('"coping_suggestion":') ||
      trimmed.contains('"action":');
}

Map<String, dynamic>? _tryExtractMap(dynamic input) {
  if (input == null) return null;
  if (input is Map<String, dynamic>) return input;
  if (input is Map) return Map<String, dynamic>.from(input);
  if (input is! String) return null;

  String text = input.trim();
  if (text.isEmpty) return null;

  // 1. Strip markdown code fences if present: ```json ... ``` or ``` ... ```
  final fenceMatch = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```').firstMatch(text);
  if (fenceMatch != null && fenceMatch.group(1) != null) {
    text = fenceMatch.group(1)!.trim();
  }

  // 2. Direct JSON decode
  try {
    final decoded = jsonDecode(text);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
  } catch (_) {}

  // 3. Try finding and extracting outermost { ... }
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

  // 4. Try repairing unclosed JSON (e.g. truncated response missing closing brace/quote)
  if (startBrace != -1) {
    final candidate = text.substring(startBrace).trim();
    final repairs = [
      '$candidate}',
      '$candidate"}',
      '$candidate"\n}',
    ];
    for (final r in repairs) {
      try {
        final decoded = jsonDecode(r);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
  }

  // 5. Robust Regex Extraction fallback
  final Map<String, dynamic> fallbackMap = {};

  // Extract string fields: "key": "value"
  final stringRegex = RegExp(r'"([a-zA-Z0-9_]+)"\s*:\s*"(.*?)(?<!\\)"', dotAll: true);
  for (final match in stringRegex.allMatches(text)) {
    final key = match.group(1);
    final val = match.group(2);
    if (key != null && val != null) {
      fallbackMap[key] = val
          .replaceAll(r'\"', '"')
          .replaceAll(r'\n', '\n')
          .replaceAll(r'\r', '')
          .replaceAll(r'\\', r'\');
    }
  }

  // Extract boolean fields: "key": true/false
  final boolRegex = RegExp(r'"([a-zA-Z0-9_]+)"\s*:\s*(true|false)', caseSensitive: false);
  for (final match in boolRegex.allMatches(text)) {
    final key = match.group(1);
    final val = match.group(2);
    if (key != null && val != null) {
      fallbackMap[key] = val.toLowerCase() == 'true';
    }
  }

  // Extract list of strings: "key": ["a", "b"]
  final listRegex = RegExp(r'"([a-zA-Z0-9_]+)"\s*:\s*\[([\s\S]*?)\]');
  for (final match in listRegex.allMatches(text)) {
    final key = match.group(1);
    final innerList = match.group(2);
    if (key != null && innerList != null) {
      final items = <String>[];
      final itemMatches = RegExp(r'"(.*?)(?<!\\)"', dotAll: true).allMatches(innerList);
      for (final im in itemMatches) {
        if (im.group(1) != null) {
          items.add(im.group(1)!
              .replaceAll(r'\"', '"')
              .replaceAll(r'\n', '\n')
              .replaceAll(r'\\', r'\'));
        }
      }
      if (items.isNotEmpty) {
        fallbackMap[key] = items;
      }
    }
  }

  if (fallbackMap.isNotEmpty) {
    return fallbackMap;
  }

  return null;
}

String _sanitizeHumanText(String text) {
  String cleaned = text.trim();
  // Strip markdown code fences if remaining
  final fenceMatch = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```').firstMatch(cleaned);
  if (fenceMatch != null && fenceMatch.group(1) != null) {
    cleaned = fenceMatch.group(1)!.trim();
  }
  // If it still contains "insight": "...", extract just the value
  final insightMatch = RegExp(r'"insight"\s*:\s*"(.*?)(?<!\\)"', dotAll: true).firstMatch(cleaned);
  if (insightMatch != null && insightMatch.group(1) != null) {
    return insightMatch.group(1)!
        .replaceAll(r'\"', '"')
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\\', r'\')
        .trim();
  }
  // Strip leading { and trailing } if any remain
  if (cleaned.startsWith('{') && cleaned.endsWith('}')) {
    cleaned = cleaned.substring(1, cleaned.length - 1).trim();
  }
  return cleaned;
}

enum SeverityLevel { normal, watch, urgent }

class SymptomCheck {
  final String symptom;
  final String status; // normal | watch | urgent
  final String note;

  const SymptomCheck({
    required this.symptom,
    required this.status,
    required this.note,
  });

  factory SymptomCheck.fromJson(Map<String, dynamic> json) {
    return SymptomCheck(
      symptom: json['symptom'] as String? ?? '',
      status: json['status'] as String? ?? 'normal',
      note: json['note'] as String? ?? '',
    );
  }
}

class SmartAlert {
  final String title;
  final String message;
  final String severity; // critical | moderate | info
  final String module;

  const SmartAlert({
    required this.title,
    required this.message,
    required this.severity,
    required this.module,
  });

  factory SmartAlert.fromJson(Map<String, dynamic> json) {
    return SmartAlert(
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      severity: json['severity'] as String? ?? 'info',
      module: json['module'] as String? ?? '',
    );
  }
}
