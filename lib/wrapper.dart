import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/auth/auth_page.dart';
import 'screens/home/home_page.dart';
import 'services/auth_service.dart';
import 'package:navajeev_m/screens/onboarding/stage_selection_page.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    // Loading
    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Not logged in
    if (!auth.isAuthenticated) {
      return const AuthPage();
    }

    // Logged in but profile incomplete
    if (!auth.isProfileComplete) {
      return const StageSelectionPage();
    }

    // Fully ready
    return const HomePage();
  }
}
