import 'package:flutter/material.dart';
import 'screens/auth/auth_page.dart';
import 'screens/home/home_page.dart';
import 'wrapper.dart';
import 'screens/tracker/vaccination_tracker_page.dart';
import 'screens/onboarding/stage_selection_page.dart';

class AppRoutes {
  static const String wrapper = '/';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String tracker = '/tracker';
  static const String onboarding = '/onboarding';

  static Map<String, WidgetBuilder> get routes => {
    wrapper: (context) => const Wrapper(),
    auth: (context) => const AuthPage(),
    home: (context) => const HomePage(),
    tracker: (context) => const VaccinationTrackerPage(),
    onboarding: (context) => const StageSelectionPage(),
  };
}