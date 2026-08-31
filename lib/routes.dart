import 'package:flutter/material.dart';
import 'package:navajeev_m/screens/appointments/appointment_page.dart';
import 'package:navajeev_m/screens/tracker/baby_growth_tracker/growth_input_page.dart';
import 'package:navajeev_m/screens/tracker/feeding%20tracker/log_feeding_screen.dart';
import 'package:navajeev_m/screens/tracker/sleep_tracker/sleep_log_screen.dart';
import 'package:navajeev_m/screens/tracker/trimester_tracker/trimester_tracker_screen.dart';
import 'package:navajeev_m/screens/wellbeing/edit_mood.dart';
import 'screens/auth/auth_page.dart';
import 'screens/auth/forgot_password_page.dart';
import 'screens/auth/email_verification_page.dart';
import 'screens/home/home_page.dart';
import 'screens/tracker/vaccination_tracker_page.dart';
import 'screens/onboarding/stage_selection_page.dart';

class AppRoutes {
  static const String auth = '/auth';
  static const String home = '/home';
  static const String tracker = '/tracker';
  static const String onboarding = '/onboarding';
  static const String mood = '/wellbeing';
  static const String sleep = '/sleep';
  static const String feeding = '/feeding';
  static const String trimester = '/trimester';
  static const String growth = '/growth';
  static const String appointments = '/appointments';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/email-verification';

  static Map<String, WidgetBuilder> get routes => {
    auth: (context) => const AuthPage(),
    home: (context) => const HomePage(),
    tracker: (context) => const VaccinationTrackerPage(),
    onboarding: (context) => const StageSelectionPage(),
    feeding: (context) => const LogFeedingScreen(),
    trimester: (context) => const TrimesterTrackerScreen(),
    sleep: (context) => const SleepLogScreen(),
    mood: (context) => const AddEditWellbeingScreen(),
    growth: (context) => const AddGrowthPage(),
    appointments: (context) => const AppointmentsPage(),
    forgotPassword: (context) => const ForgotPasswordPage(),
    emailVerification: (context) => const EmailVerificationPage(),
  };
}