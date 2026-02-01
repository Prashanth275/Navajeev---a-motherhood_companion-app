import 'package:flutter/material.dart';
import 'screens/auth/auth_page.dart';
import 'screens/home/home_page.dart';
import 'services/auth_service.dart';
import 'package:navajeev_m/screens/onboarding/stage_selection_page.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: authService,
      builder: (context, child) {
        if (authService.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authService.isAuthenticated) {
          if (authService.isProfileComplete) {
            return const HomePage();
          } else {
            return const StageSelectionPage();
          }
        } else {
          return const AuthPage();
        }
      },
    );
  }
}


