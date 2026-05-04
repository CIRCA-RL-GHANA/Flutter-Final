import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Consumer;
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/providers/app_providers.dart';
import 'core/network/api_client.dart';
import 'features/onboarding/providers/onboarding_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize API client (loads saved auth tokens)
  await ApiClient.instance.init();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F0F23),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: PromptGenieApp()));
}

class PromptGenieApp extends StatelessWidget {
  const PromptGenieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: Consumer<OnboardingProvider>(
        builder: (context, onboardingProvider, child) {
          return MaterialApp(
            title: 'PROMPT Genie',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            initialRoute: AppRoutes.preLoading,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            builder: (context, child) {
              // Apply text scaling limits for accessibility
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(
                    MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 2.0).toDouble(),
                  ),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
