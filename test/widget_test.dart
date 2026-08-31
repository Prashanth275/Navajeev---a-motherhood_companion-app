// This tests the AnimatedSplashScreen in the Navajeev app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navajeev_m/screens/onboarding/animated_splash_screen.dart';

void main() {
  testWidgets('Splash screen loads with app title and logo icon', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AnimatedSplashScreen(),
      ),
    );

    // Verify app title is displayed
    expect(find.text('Navajeev'), findsOneWidget);
    expect(find.text('Your Motherhood Companion'), findsOneWidget);
    
    // Verify care icon is present (1 orbiting icon)
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    
    // Verify custom logo image is loaded
    expect(find.byType(Image), findsOneWidget);
  });
}


