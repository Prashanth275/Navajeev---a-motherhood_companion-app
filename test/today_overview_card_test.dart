import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navajeev_m/widgets/home_page_widgets/today_summary_card.dart';

void main() {
  group("TodayOverviewCard Tests", () {
    testWidgets("Pregnancy mode displays Baby Size | Sleep | Mood (no Feeds)", (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TodayOverviewCard(
              isPregnancy: true,
              babySize: "30 cm",
              babySizeSubtitle: "This week",
              sleepHours: 7.5,
              mood: "Happy",
            ),
          ),
        ),
      );

      // Verify Baby Size card
      expect(find.text("Baby Size"), findsOneWidget);
      expect(find.text("30 cm"), findsOneWidget);
      expect(find.text("This week"), findsOneWidget);
      expect(find.byIcon(Icons.child_care), findsOneWidget);

      // Verify Sleep and Mood cards
      expect(find.text("Sleep"), findsOneWidget);
      expect(find.text("7.5h"), findsOneWidget);
      expect(find.text("Mood"), findsOneWidget);
      expect(find.text("Happy"), findsOneWidget);

      // Verify Feeds is NOT present in Pregnancy mode
      expect(find.text("Feeds"), findsNothing);
      expect(find.byIcon(Icons.restaurant), findsNothing);
    });

    testWidgets("Postpartum mode displays Feeds | Sleep | Mood (no Baby Size)", (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TodayOverviewCard(
              isPregnancy: false,
              feeds: 6,
              sleepHours: 5.0,
              mood: "Tired",
            ),
          ),
        ),
      );

      // Verify Feeds card is preserved for Postpartum
      expect(find.text("Feeds"), findsOneWidget);
      expect(find.text("6"), findsOneWidget);
      expect(find.byIcon(Icons.restaurant), findsOneWidget);

      // Verify Sleep and Mood cards
      expect(find.text("Sleep"), findsOneWidget);
      expect(find.text("5.0h"), findsOneWidget);
      expect(find.text("Mood"), findsOneWidget);
      expect(find.text("Tired"), findsOneWidget);

      // Verify Baby Size is NOT present in Postpartum mode
      expect(find.text("Baby Size"), findsNothing);
      expect(find.byIcon(Icons.child_care), findsNothing);
    });

    testWidgets("Graceful fallback when babySize is missing/null in Pregnancy mode", (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TodayOverviewCard(
              isPregnancy: true,
              babySize: null,
              babySizeSubtitle: "This week",
              sleepHours: 8.0,
              mood: "Calm",
            ),
          ),
        ),
      );

      // Should display "--" gracefully
      expect(find.text("Baby Size"), findsOneWidget);
      expect(find.text("--"), findsOneWidget);
      expect(find.text("This week"), findsOneWidget);
      expect(find.text("Feeds"), findsNothing);
    });
  });
}
