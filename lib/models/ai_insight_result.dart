
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
    final r = (json['result'] as Map<String, dynamic>?) ?? json;

    return AiInsightResult(
      module: module,
      success: json['success'] as bool? ?? false,
      insight: r['insight'] as String?,
      action: r['action'] as String?,
      severity: r['severity'] as String?,
      trend: r['trend'] as String?,
      whoComparison: r['who_comparison'] as String?,
      frequencyStatus: r['frequency_status'] as String?,
      tip: r['tip'] as String?,
      weightStatus: r['weight_status'] as String?,
      heightStatus: r['height_status'] as String?,
      milestonePrediction: r['milestone_prediction'] as String?,
      weekSummary: r['week_summary'] as String?,
      symptomAssessment: (r['symptom_assessment'] as List?)
          ?.map((e) => SymptomCheck.fromJson(e as Map<String, dynamic>))
          .toList(),
      actionItems: (r['action_items'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      copingSuggestion: r['coping_suggestion'] as String?,
      showHelpline: r['show_helpline'] as bool? ?? false,
      questions:
      (r['questions'] as List?)?.map((e) => e.toString()).toList(),
      bring: (r['bring'] as List?)?.map((e) => e.toString()).toList(),
      urgentItems:
      (r['urgent_items'] as List?)?.map((e) => e.toString()).toList(),
      alerts: (r['alerts'] as List?)
          ?.map((e) => SmartAlert.fromJson(e as Map<String, dynamic>))
          .toList(),
      nutritionTips:
      (r['nutrition_tips'] as List?)?.map((e) => e.toString()).toList(),
      devActivity: r['dev_activity'] as String?,
      weeklyFocus: r['weekly_focus'] as String?,
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
