import 'package:flutter/material.dart';
import '../models/ai_insight_result.dart';

// -------------------------------------------------------
// Drop this widget into any tracker screen.
//
// Usage:
//   AiInsightCard(
//     module: 'sleep',
//     isLoading: aiProvider.isLoading,
//     result: aiProvider.result,
//     onRefresh: () => aiProvider.fetchInsight(...),
//   )
// -------------------------------------------------------

class AiInsightCard extends StatelessWidget {
  final String module;
  final bool isLoading;
  final AiInsightResult? result;
  final VoidCallback? onRefresh;

  const AiInsightCard({
    super.key,
    required this.module,
    this.isLoading = false,
    this.result,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradient(module),
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _accent(module).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(module: module, result: result, onRefresh: onRefresh, isLoading: isLoading),
          if (isLoading) const _LoadingBody(),
          if (!isLoading && result == null) const _EmptyBody(),
          if (!isLoading && result != null) _Body(result: result!),
        ],
      ),
    );
  }

  // ---- Theming ----

  static List<Color> _gradient(String module) {
    switch (module) {
      case 'sleep':        return [const Color(0xFF7B6DA8), const Color(0xFF5A4F8A)];
      case 'feeding':      return [const Color(0xFFE8926B), const Color(0xFFC97050)];
      case 'growth':       return [const Color(0xFF7A9E87), const Color(0xFF4A7E57)];
      case 'trimester':    return [const Color(0xFFE8748A), const Color(0xFFC85070)];
      case 'wellbeing':    return [const Color(0xFF7BB8C9), const Color(0xFF4A90A4)];
      case 'appointments': return [const Color(0xFF8B6EC4), const Color(0xFF6050A0)];
      case 'notifications':return [const Color(0xFF5A9E7A), const Color(0xFF3A7E5A)];
      default:             return [const Color(0xFFC9956B), const Color(0xFFA07040)];
    }
  }

  static Color _accent(String module) => _gradient(module).first;

  static String _emoji(String module) {
    const map = {
      'sleep': '🌙', 'feeding': '🍼', 'growth': '📈',
      'trimester': '🤰', 'wellbeing': '💆', 'appointments': '🗓️',
      'notifications': '🔔', 'dashboard': '🏠', 'recommendation': '✨',
    };
    return map[module] ?? '🤖';
  }

  static String _title(String module) {
    const map = {
      'sleep': 'Sleep Analysis', 'feeding': 'Feeding Analysis',
      'growth': 'Growth Analysis', 'trimester': 'Pregnancy Insight',
      'wellbeing': 'Wellbeing Check', 'appointments': 'Visit Prep',
      'notifications': 'Smart Alerts', 'dashboard': 'Daily Brief',
      'recommendation': 'Weekly Guidance',
    };
    return map[module] ?? 'AI Insight';
  }
}

// -------------------------------------------------------
// HEADER
// -------------------------------------------------------
class _Header extends StatelessWidget {
  final String module;
  final AiInsightResult? result;
  final VoidCallback? onRefresh;
  final bool isLoading;

  const _Header({
    required this.module,
    this.result,
    this.onRefresh,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              AiInsightCard._emoji(module),
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Insight',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                Text(
                  AiInsightCard._title(module),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Severity badge
          if (result != null && result!.severityLevel != SeverityLevel.normal)
            _SeverityBadge(level: result!.severityLevel),
          // Refresh button
          if (onRefresh != null)
            IconButton(
              onPressed: isLoading ? null : onRefresh,
              icon: Icon(
                Icons.refresh_rounded,
                color: Colors.white.withOpacity(0.8),
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------
// BODY STATES
// -------------------------------------------------------
class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 20, width: 20,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            'Analysing your data...',
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Text(
        'Log some data to get personalised AI insights.',
        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
      ),
    );
  }
}

// -------------------------------------------------------
// CONTENT — routes to the right layout per module
// -------------------------------------------------------
class _Body extends StatelessWidget {
  final AiInsightResult result;
  const _Body({required this.result});

  @override
  Widget build(BuildContext context) {
    switch (result.module) {
      case 'trimester':    return _TrimesterBody(r: result);
      case 'wellbeing':    return _WellbeingBody(r: result);
      case 'appointments': return _AppointmentsBody(r: result);
      case 'notifications':return _NotificationsBody(r: result);
      default:             return _DefaultBody(r: result);
    }
  }
}

// -------------------------------------------------------
// DEFAULT — works for sleep, feeding, growth, dashboard
// -------------------------------------------------------
class _DefaultBody extends StatelessWidget {
  final AiInsightResult r;
  const _DefaultBody({required this.r});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (r.insight != null) _InsightText(r.insight!),
        if (r.whoComparison != null) ...[
          _Label('WHO norms'),
          _InsightText(r.whoComparison!),
        ],
        if (r.milestonePrediction != null) ...[
          _Label('Milestone'),
          _Bullet(r.milestonePrediction!),
        ],
        if (r.tip != null) ...[
          _Label('Tip'),
          _Bullet(r.tip!),
        ],
        if (r.action != null || r.trend != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Wrap(
              spacing: 8, runSpacing: 6,
              children: [
                if (r.trend != null) _Chip('Trend: ${r.trend}'),
                if (r.action != null) _Chip(r.action!),
              ],
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// -------------------------------------------------------
// TRIMESTER
// -------------------------------------------------------
class _TrimesterBody extends StatelessWidget {
  final AiInsightResult r;
  const _TrimesterBody({required this.r});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (r.weekSummary != null) _InsightText(r.weekSummary!),
        if (r.symptomAssessment != null && r.symptomAssessment!.isNotEmpty) ...[
          _Label('Symptom check'),
          ...r.symptomAssessment!.map((s) => _SymptomRow(s: s)),
        ],
        if (r.actionItems != null && r.actionItems!.isNotEmpty) ...[
          _Label('This week'),
          ...r.actionItems!.map((a) => _Bullet(a)),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}

// -------------------------------------------------------
// WELLBEING
// -------------------------------------------------------
class _WellbeingBody extends StatelessWidget {
  final AiInsightResult r;
  const _WellbeingBody({required this.r});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (r.insight != null) _InsightText(r.insight!),
        if (r.copingSuggestion != null) ...[
          _Label('What helps'),
          _Bullet(r.copingSuggestion!),
        ],
        if (r.showHelpline)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Text('💛', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "You're not alone. Consider speaking to a healthcare provider or counsellor.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// -------------------------------------------------------
// APPOINTMENTS
// -------------------------------------------------------
class _AppointmentsBody extends StatelessWidget {
  final AiInsightResult r;
  const _AppointmentsBody({required this.r});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (r.insight != null) _InsightText(r.insight!),
        if (r.urgentItems != null && r.urgentItems!.isNotEmpty) ...[
          _Label('Mention first'),
          ...r.urgentItems!.map((u) => _Bullet('⚠️ $u')),
        ],
        if (r.questions != null && r.questions!.isNotEmpty) ...[
          _Label('Questions to ask'),
          ...r.questions!
              .asMap()
              .entries
              .map((e) => _Bullet('${e.key + 1}. ${e.value}')),
        ],
        if (r.bring != null && r.bring!.isNotEmpty) ...[
          _Label('Bring along'),
          ...r.bring!.map((b) => _Bullet(b)),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}

// -------------------------------------------------------
// NOTIFICATIONS
// -------------------------------------------------------
class _NotificationsBody extends StatelessWidget {
  final AiInsightResult r;
  const _NotificationsBody({required this.r});

  @override
  Widget build(BuildContext context) {
    if (r.alerts == null || r.alerts!.isEmpty) {
      return Column(children: [
        _InsightText('Everything looks good — no urgent alerts right now. ✅'),
        const SizedBox(height: 16),
      ]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...r.alerts!.map((a) => _AlertTile(alert: a)),
        const SizedBox(height: 16),
      ],
    );
  }
}

// -------------------------------------------------------
// SHARED SMALL WIDGETS
// -------------------------------------------------------

class _InsightText extends StatelessWidget {
  final String text;
  const _InsightText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.92),
          fontSize: 14,
          height: 1.55,
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 5, height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.88),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final SeverityLevel level;
  const _SeverityBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (level) {
      SeverityLevel.urgent => ('Urgent', Colors.red.shade300),
      SeverityLevel.watch  => ('Watch',  Colors.orange.shade300),
      SeverityLevel.normal => ('Good',   Colors.green.shade300),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _SymptomRow extends StatelessWidget {
  final SymptomCheck s;
  const _SymptomRow({required this.s});

  @override
  Widget build(BuildContext context) {
    final color = switch (s.status) {
      'urgent' => Colors.red.shade300,
      'watch'  => Colors.orange.shade300,
      _        => Colors.green.shade300,
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Text(s.status.toUpperCase(),
                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text('${s.symptom}: ${s.note}',
                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final SmartAlert alert;
  const _AlertTile({required this.alert});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (alert.severity) {
      'critical' => ('🚨', Colors.red.shade300),
      'moderate' => ('⚠️', Colors.orange.shade300),
      _          => ('ℹ️', Colors.blue.shade200),
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alert.title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(alert.message,
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
