import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/design/ive_tokens.dart';
import 'core/routes/app_routes.dart';
import 'core/providers/app_providers.dart';
import 'core/network/api_client.dart';
import 'features/onboarding/providers/onboarding_provider.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // FLUTTER-074: Warn in debug mode if ENVIRONMENT dart-define is not set
    assert(() {
      if (const String.fromEnvironment('ENVIRONMENT').isEmpty) {
        debugPrint('[ENV WARNING] ENVIRONMENT dart-define not set. Defaulting to production.');
      }
      return true;
    }());

    // FLUTTER-047: Initialize Hive for local storage — guarded so corruption doesn't crash
    try {
      await Hive.initFlutter();
    } catch (e, st) {
      debugPrint('[HIVE INIT ERROR] $e\n$st');
    }

    // FLUTTER-046: Initialize API client (loads saved auth tokens) — guarded so failures are logged
    try {
      await ApiClient.instance.init();
    } catch (e, st) {
      debugPrint('[API CLIENT INIT ERROR] $e\n$st');
    }

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set system UI overlay style — aligned to brand-dark surfaces
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: IveTokens.bg,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: IveTokens.hairline,
      ),
    );

    runApp(const PromptGenieApp());
  }, (error, stack) => debugPrint('[UNHANDLED] $error\n$stack'));
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
            title: 'genie help',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            initialRoute: AppRoutes.preLoading,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
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
