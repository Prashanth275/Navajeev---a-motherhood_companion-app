import 'package:flutter_test/flutter_test.dart';
import 'package:navajeev_m/models/ai_insight_result.dart';

void main() {
  group('AiInsightResult.fromJson & Provider Caching Tests', () {
    test('Correctly unboxes 3-day stringified JSON in insight field', () {
      final rawNestedJson = '''{
  "insight": "The mother's mood has been fluctuating with a recent decline, possibly due to sleep deprivation and emotional adjustment to motherhood. However, there is a trend of improvement as seen on the 22nd day postpartum.",
  "trend": "declining",
  "sleep_mood_correlation": "There is a strong correlation between sleep and mood, with the mother experiencing low mood and no sleep.",
  "coping_suggestion": "Prioritize sleep and establish a consistent sleep routine to help regulate mood.",
  "severity": "watch",
  "show_helpline": true,
  "action": "Establish a sleep routine and consider taking a nap during the day to help improve mood and energy levels."
}''';

      final apiResponse = {
        "module": "wellbeing",
        "success": true,
        "result": {
          "module": "wellbeing",
          "insight": rawNestedJson,
          "trend": "stable",
          "action": "Review your recent logs."
        }
      };

      final parsed = AiInsightResult.fromJson(apiResponse, 'wellbeing');

      expect(parsed.module, 'wellbeing');
      expect(parsed.success, true);
      // Main insight must be the human-readable sentence, NOT the raw JSON string
      expect(parsed.insight, "The mother's mood has been fluctuating with a recent decline, possibly due to sleep deprivation and emotional adjustment to motherhood. However, there is a trend of improvement as seen on the 22nd day postpartum.");
      expect(parsed.insight, isNot(startsWith('{')));
      expect(parsed.copingSuggestion, "Prioritize sleep and establish a consistent sleep routine to help regulate mood.");
      expect(parsed.severity, 'watch');
      expect(parsed.severityLevel, SeverityLevel.watch);
      expect(parsed.showHelpline, true);
      expect(parsed.trend, 'declining');
    });

    test('Correctly handles when result itself is a stringified JSON string', () {
      final rawResultString = '''{
  "insight": "Mood is stable and positive.",
  "trend": "improving",
  "coping_suggestion": "Continue daily walks.",
  "severity": "normal",
  "show_helpline": false,
  "action": "Keep up the routine."
}''';

      final apiResponse = {
        "module": "wellbeing",
        "success": true,
        "result": rawResultString,
      };

      final parsed = AiInsightResult.fromJson(apiResponse, 'wellbeing');

      expect(parsed.module, 'wellbeing');
      expect(parsed.success, true);
      expect(parsed.insight, "Mood is stable and positive.");
      expect(parsed.copingSuggestion, "Continue daily walks.");
      expect(parsed.severity, "normal");
      expect(parsed.showHelpline, false);
      expect(parsed.action, "Keep up the routine.");
    });

    test('Handles unclosed / truncated JSON missing the trailing closing brace', () {
      // Missing closing brace at the end
      const truncatedJson = '{\n  "insight": "The mother\'s mood has been improving.",\n  "trend": "improving",\n  "coping_suggestion": "Prioritize restful breaks.",\n  "severity": "normal",\n  "show_helpline": false,\n  "action": "Maintain healthy routine."';

      final apiResponse = {
        "module": "wellbeing",
        "success": true,
        "result": {
          "module": "wellbeing",
          "insight": truncatedJson,
          "trend": "stable"
        }
      };

      final parsed = AiInsightResult.fromJson(apiResponse, 'wellbeing');
      expect(parsed.insight, "The mother's mood has been improving.");
      expect(parsed.insight, isNot(contains('{')));
      expect(parsed.copingSuggestion, "Prioritize restful breaks.");
      expect(parsed.trend, 'improving');
      expect(parsed.severity, 'normal');
      expect(parsed.showHelpline, false);
    });

    test('Handles markdown code fences and conversational preamble text', () {
      const fencedWithPreamble = '''Here is the analysis based on recent logs:
```json
{
  "insight": "Sleep deprivation is impacting mood score.",
  "trend": "declining",
  "coping_suggestion": "Take short naps when possible.",
  "severity": "watch",
  "show_helpline": true,
  "action": "Ask partner for support during night feeds."
}
```
Hope this is helpful!''';

      final apiResponse = {
        "module": "wellbeing",
        "success": true,
        "result": fencedWithPreamble
      };

      final parsed = AiInsightResult.fromJson(apiResponse, 'wellbeing');
      expect(parsed.insight, "Sleep deprivation is impacting mood score.");
      expect(parsed.insight, isNot(contains('```')));
      expect(parsed.copingSuggestion, "Take short naps when possible.");
      expect(parsed.severity, 'watch');
      expect(parsed.showHelpline, true);
      expect(parsed.action, "Ask partner for support during night feeds.");
    });

    test('Handles malformed JSON using regex field extraction fallback', () {
      // Broken JSON syntax (missing quotes/braces around some keys)
      const malformedJson = '{\n  "insight": "Daily routine is stabilizing nicely.",\n  "coping_suggestion": "Continue staying hydrated.",\n  "severity": "normal",\n  "trend": "improving"\n';

      final apiResponse = {
        "module": "wellbeing",
        "success": true,
        "insight": malformedJson
      };

      final parsed = AiInsightResult.fromJson(apiResponse, 'wellbeing');
      expect(parsed.insight, "Daily routine is stabilizing nicely.");
      expect(parsed.insight, isNot(contains('{')));
      expect(parsed.copingSuggestion, "Continue staying hydrated.");
      expect(parsed.trend, "improving");
    });

    test('Preserves standard 7-day clean Map response', () {
      final apiResponse = {
        "module": "wellbeing",
        "success": true,
        "result": {
          "insight": "The mother's mood has been fluctuating between 1/5 and 5/5, with a trend of improvement over the last few days.",
          "trend": "improving",
          "sleep_mood_correlation": "Higher energy observed following restful nights.",
          "coping_suggestion": "Prioritize self-care and ask for help from her support system when needed.",
          "severity": "normal",
          "show_helpline": false,
          "action": "Stay hydrated and take small rests."
        }
      };

      final parsed = AiInsightResult.fromJson(apiResponse, 'wellbeing');

      expect(parsed.module, 'wellbeing');
      expect(parsed.success, true);
      expect(parsed.insight, "The mother's mood has been fluctuating between 1/5 and 5/5, with a trend of improvement over the last few days.");
      expect(parsed.copingSuggestion, "Prioritize self-care and ask for help from her support system when needed.");
      expect(parsed.severity, 'normal');
      expect(parsed.severityLevel, SeverityLevel.normal);
      expect(parsed.showHelpline, false);
      expect(parsed.action, "Stay hydrated and take small rests.");
      expect(parsed.trend, 'improving');
    });

    test('Cache simulation: storing and retrieving parsed AiInsightResult preserves human-readable fields', () {
      final Map<String, AiInsightResult> memoryCache = {};

      final apiResponse3Days = {
        "module": "wellbeing",
        "success": true,
        "result": {
          "module": "wellbeing",
          "insight": '''{
            "insight": "Adjustment to postpartum period is improving.",
            "coping_suggestion": "Take 10 minutes for mindfulness.",
            "severity": "normal",
            "show_helpline": false
          }''',
          "trend": "improving"
        }
      };

      // 1. First load parses API response and caches
      final firstParsed = AiInsightResult.fromJson(apiResponse3Days, 'wellbeing');
      memoryCache['user1-wellbeing-mother'] = firstParsed;

      // 2. Subsequent load retrieves from cache
      final cachedResult = memoryCache['user1-wellbeing-mother'];
      expect(cachedResult, isNotNull);
      expect(cachedResult!.insight, "Adjustment to postpartum period is improving.");
      expect(cachedResult.copingSuggestion, "Take 10 minutes for mindfulness.");
      expect(cachedResult.insight, isNot(contains('{')));
    });
  });
}
