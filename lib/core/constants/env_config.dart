import 'package:flutter/foundation.dart' show kIsWeb;

/// Environment configuration for genie help
/// Switch between environments by changing the active config.
class EnvConfig {
  static const String appName = 'genie help';
  static const String appVersion = '1.0.5';

  // Resolved from --dart-define=ENVIRONMENT=... (defaults to production for safety).
  // Pass --dart-define=ENVIRONMENT=development to point at a local server during dev.
  static const String _envName = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'production',
  );
  static const Environment current = _envName == 'development'
      ? Environment.development
      : _envName == 'staging'
          ? Environment.staging
          : Environment.production;

  static String get baseUrl {
    switch (current) {
      case Environment.development:
        // localhost:3030 for web/desktop; 10.0.2.2:3030 for Android emulator
        return kIsWeb || !_isAndroidEmulator
            ? 'http://localhost:3030/api/v1'
            : 'http://10.0.2.2:3030/api/v1';
      case Environment.staging:
        return 'https://staging-api.genieinprompt.app/api/v1';
      case Environment.production:
        return 'https://api.genieinprompt.app/api/v1';
    }
  }

  static String get webSocketUrl {
    switch (current) {
      case Environment.development:
        return kIsWeb || !_isAndroidEmulator
            ? 'ws://localhost:3030'
            : 'ws://10.0.2.2:3030';
      case Environment.staging:
        return 'wss://staging-api.genieinprompt.app';
      case Environment.production:
        return 'wss://api.genieinprompt.app';
    }
  }

  static bool get _isAndroidEmulator {
    try {
      return const bool.fromEnvironment('ANDROID_EMULATOR', defaultValue: false);
    } catch (_) {
      return false;
    }
  }

  static bool get isProduction => current == Environment.production;
  static bool get isDevelopment => current == Environment.development;

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Cache
  static const Duration cacheMaxAge = Duration(hours: 1);
  static const int maxCacheSize = 50; // MB
}

enum Environment {
  development,
  staging,
  production,
}
