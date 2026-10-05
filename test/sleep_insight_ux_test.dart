import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navajeev_m/models/ai_insight_result.dart';
import 'package:navajeev_m/widgets/ai_insight_card.dart';

void main() {
  group('Sleep AI Insight UX Tests', () {
    testWidgets('0 sleep entries: shows empty-state "Log your sleep to get personalized AI insights."', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AiInsightCard(
              module: 'sleep',
              isLoading: false,
              result: null,
              emptyMessage: "Log your sleep to get personalized AI insights.",
            ),
          ),
        ),
      );

      expect(find.text('Sleep Analysis'), findsOneWidget);
      expect(find.text('Log your sleep to get personalized AI insights.'), findsOneWidget);
      expect(find.text('Log at least 2 days of sleep to get a personalized AI insight.'), findsNothing);
    });

    testWidgets('1 sleep entry: shows "Log at least 2 days of sleep to get a personalized AI insight."', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AiInsightCard(
              module: 'sleep',
              isLoading: false,
              result: null,
              emptyMessage: "Log at least 2 days of sleep to get a personalized AI insight.",
            ),
          ),
        ),
      );

      expect(find.text('Sleep Analysis'), findsOneWidget);
      expect(find.text('Log at least 2 days of sleep to get a personalized AI insight.'), findsOneWidget);
      expect(find.text('Log your sleep to get personalized AI insights.'), findsNothing);
    });

    testWidgets('2 sleep entries: renders AI insight and does not falsely describe as trend when insufficient_data', (tester) async {
      const result2Days = AiInsightResult(
        module: 'sleep',
        success: true,
        insight: 'Over the logged 2 days, sleep averaged 7.5 hours per day.',
        trend: 'insufficient_data',
        whoComparison: 'Averaging 7.5 hrs/night, meeting standard adult rest guidelines.',
        action: 'Maintain a consistent bedtime routine.',
        severity: 'normal',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AiInsightCard(
              module: 'sleep',
              isLoading: false,
              result: result2Days,
            ),
          ),
        ),
      );

      expect(find.text('Sleep Analysis'), findsOneWidget);
      expect(find.text('Over the logged 2 days, sleep averaged 7.5 hours per day.'), findsOneWidget);
      // Must NOT falsely describe as multi-day trend or show raw insufficient_data
      expect(find.text('Trend: insufficient_data'), findsNothing);
      expect(find.text('Trend: Needs 3+ days'), findsOneWidget);
      expect(find.text('Maintain a consistent bedtime routine.'), findsOneWidget);
    });

    testWidgets('3+ sleep entries: preserves normal trend behavior', (tester) async {
      const result3Days = AiInsightResult(
        module: 'sleep',
        success: true,
        insight: 'Over the logged 3 days, sleep averaged 8.0 hours per day with consistent sleep quality.',
        trend: 'improving',
        whoComparison: 'Averaging 8.0 hrs/night, meeting standard adult rest guidelines.',
        action: 'Keep up the healthy sleep schedule.',
        severity: 'normal',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AiInsightCard(
              module: 'sleep',
              isLoading: false,
              result: result3Days,
            ),
          ),
        ),
      );

      expect(find.text('Sleep Analysis'), findsOneWidget);
      expect(find.text('Trend: improving'), findsOneWidget);
      expect(find.text('Keep up the healthy sleep schedule.'), findsOneWidget);
    });
  });
}
