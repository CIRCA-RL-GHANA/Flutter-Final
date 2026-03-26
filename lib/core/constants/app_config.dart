/// App-wide configuration constants
class AppConfig {
  AppConfig._();

  // App Store / Play Store
  static const String androidPackageId = 'com.promptgenie.app';
  static const String iosBundleId = 'com.promptgenie.app';
  static const String appStoreId = ''; // Fill after App Store submission
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=$androidPackageId';

  // Deep Linking
  static const String deepLinkScheme = 'promptgenie';
  static const String deepLinkHost = 'promptgenie.app';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // File upload limits
  static const int maxImageSizeBytes = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  // Biometric
  static const bool enableBiometric = true;

  // Cache keys
  static const String tokenCacheKey = 'auth_token';
  static const String refreshTokenCacheKey = 'refresh_token';
  static const String userCacheKey = 'cached_user';
  static const String themeCacheKey = 'app_theme_mode';
}
