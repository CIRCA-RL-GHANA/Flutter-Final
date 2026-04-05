/// Environment configuration for PROMPT Genie
/// Switch between environments by changing the active config.
class EnvConfig {
  static const String appName = 'PROMPT Genie';
  static const String appVersion = '1.0.0';

  // Active environment
  static const Environment current = Environment.production;

  static String get baseUrl {
    switch (current) {
      case Environment.development:
        return 'http://10.0.2.2:3000/api/v1';
      case Environment.staging:
        return 'https://staging-api.genieinprompt.app/api/v1';
      case Environment.production:
        return 'https://api.genieinprompt.app/api/v1';
    }
  }

  static String get webSocketUrl {
    switch (current) {
      case Environment.development:
        return 'ws://10.0.2.2:3000';
      case Environment.staging:
        return 'wss://staging-api.genieinprompt.app';
      case Environment.production:
        return 'wss://api.genieinprompt.app';
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
