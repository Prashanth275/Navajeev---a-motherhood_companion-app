import 'package:flutter_test/flutter_test.dart';
import 'package:navajeev_m/models/recommendation_result.dart';

void main() {
  group('RecommendationResult JSON & Parsing Tests', () {
    test('Correctly parses clean Pregnancy recommendation payload', () {
      final json = {
        "success": true,
        "result": {
          "weekly_focus": "Stay hydrated and prioritize gentle prenatal stretching during week 24.",
          "daily_routine": [
            "10-minute morning mindful breathing",
            "Midday elevation of feet",
            "Evening relaxation routine"
          ],
          "nutrition_tips": [
            "Incorporate iron-rich leafy greens",
            "Drink plenty of water with lemon",
            "Snack on almonds and yogurt"
          ],
          "self_care": [
            "Take a relaxing warm shower",
            "Read an uplifting book for 15 minutes"
          ],
          "dev_activity": "Sing or speak gently to your baby bump during quiet evening moments."
        }
      };

      final result = RecommendationResult.fromJson(json);

      expect(result.success, isTrue);
      expect(result.weeklyFocus, contains("week 24"));
      expect(result.dailyRoutine.length, equals(3));
      expect(result.nutritionTips.length, equals(3));
      expect(result.selfCare.length, equals(2));
      expect(result.devActivity, contains("baby bump"));
      expect(result.hasContent, isTrue);
    });

    test('Correctly parses Postpartum recommendation payload', () {
      final json = {
        "success": true,
        "result": {
          "weekly_focus": "Support baby's 8-week developmental leap with calm, cue-based responsive care.",
          "daily_routine": [
            "Morning tummy time on playmat",
            "Midday gentle responsive soothing",
            "Predictable bedtime wind-down"
          ],
          "nutrition_tips": [
            "Protein-rich snacks for lactation and energy",
            "Stay well hydrated throughout the day"
          ],
          "self_care": [
            "Rest while baby rests during afternoon naps"
          ],
          "dev_activity": "Engage with high-contrast visual cards 12 inches from baby's eyes."
        }
      };

      final result = RecommendationResult.fromJson(json);

      expect(result.success, isTrue);
      expect(result.weeklyFocus, contains("8-week"));
      expect(result.dailyRoutine.first, contains("tummy time"));
      expect(result.nutritionTips.length, equals(2));
      expect(result.selfCare.first, contains("afternoon naps"));
      expect(result.devActivity, contains("high-contrast"));
      expect(result.hasContent, isTrue);
    });

    test('Correctly unboxes markdown code fences in result string', () {
      final json = {
        "success": true,
        "result": """```json
{
  "weekly_focus": "Focus on rest and recovery.",
  "daily_routine": ["Short walks", "Rest periods"],
  "nutrition_tips": ["Warm broths"],
  "self_care": ["Gentle bath"],
  "dev_activity": "Skin-to-skin bonding"
}
```"""
      };

      final result = RecommendationResult.fromJson(json);

      expect(result.success, isTrue);
      expect(result.weeklyFocus, equals("Focus on rest and recovery."));
      expect(result.dailyRoutine.length, equals(2));
      expect(result.nutritionTips, equals(["Warm broths"]));
      expect(result.devActivity, equals("Skin-to-skin bonding"));
    });

    test('Handles error result gracefully', () {
      final result = RecommendationResult.error("Network timeout");

      expect(result.success, isFalse);
      expect(result.errorMessage, equals("Network timeout"));
      expect(result.hasContent, isFalse);
    });
  });
}
