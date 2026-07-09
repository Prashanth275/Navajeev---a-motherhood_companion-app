import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:navajeev_m/providers/Sleep/sleep_providers.dart';
import 'package:navajeev_m/providers/chat_provider.dart';
import 'package:navajeev_m/providers/feeding/feeding_provider.dart';
import 'package:navajeev_m/providers/growth/growth_provider.dart';
import 'package:navajeev_m/providers/profile_provider.dart';
import 'package:navajeev_m/providers/trimester/trimester_provider.dart';
import 'package:navajeev_m/providers/wellbeing/wellbeing_provider.dart';
import 'package:navajeev_m/repositories/feeding/feeding_repository.dart';
import 'package:navajeev_m/repositories/trimester/trimester_repository.dart';
import 'package:navajeev_m/repositories/wellbeing/wellbeing_repository.dart';
import 'package:navajeev_m/services/auth_service.dart';
import 'package:navajeev_m/wrapper.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme/app_theme.dart';
import 'routes.dart';
import 'providers/vaccine_providers.dart';
import 'services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/ai_insight_provider.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting();
  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProxyProvider<AuthService, SleepProvider>(
          create: (context) => SleepProvider(
            auth: context.read<AuthService>(),
            firestore: FirebaseFirestore.instance,
          ),
          update: (context, auth, previous) =>
              SleepProvider(
                auth: auth,
                firestore: FirebaseFirestore.instance,
              ),
        ),
        ChangeNotifierProvider(
          create: (context) => VaccineProvider(
            authService: context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        Provider<FeedingRepository>(
          create: (_) => FeedingRepository(),
        ),

        ChangeNotifierProxyProvider<AuthService, FeedingProvider>(
          create: (context) => FeedingProvider(
            repository: context.read<FeedingRepository>(),
            authService: context.read<AuthService>(),
          )..initialize(),
          update: (context, auth, previous) =>
          FeedingProvider(
            repository: context.read<FeedingRepository>(),
            authService: auth,
          )..initialize(),
        ),
        Provider<TrimesterRepository>(
          create: (_) => TrimesterRepository(),
        ),

        ChangeNotifierProvider(
          create: (context) => TrimesterProvider(
            repository: context.read<TrimesterRepository>(),
            authService: context.read<AuthService>(),
          ),
        ),

        Provider<WellbeingRepository>(
          create: (_) => WellbeingRepository(
            FirebaseFirestore.instance,
          ),
        ),

        // Wellbeing Provider
        ChangeNotifierProxyProvider<AuthService, WellbeingProvider>(
          create: (context) => WellbeingProvider(
            repo: context.read<WellbeingRepository>(),
            auth: context.read<AuthService>(),
          )..initialize(),
          update: (context, auth, previous) =>
          WellbeingProvider(
            repo: context.read<WellbeingRepository>(),
            auth: auth,
          )..initialize(),
        ),

        ChangeNotifierProxyProvider<AuthService, GrowthProvider>(
          create: (context) => GrowthProvider(
            auth: context.read<AuthService>(),
          )..initialize(),
          update: (context, auth, previous) =>
          GrowthProvider(
            auth: auth,
          )..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => AiInsightProvider()),

          ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MaterialApp(
        title: 'Navajeev',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const Wrapper(),
        routes: AppRoutes.routes,
      ),
    );
  }
}
