class AppAnimations {
  AppAnimations._();

  // Durations (milliseconds)
  static const int durationFast = 200;
  static const int durationMedium = 400;
  static const int durationSlow = 800;
  static const int durationSplash = 3000;
  static const int durationTypewriter = 1200;
  static const int durationPulse = 2000;
  static const int durationParticle = 3000;
  static const int durationGlow = 800;
  static const int durationSparkle = 500;
  static const int durationStaggerDelay = 100;

  // OTP Timer
  static const int otpTimerDuration = 299; // 4:59 in seconds
  static const int otpFirstResend = 30;
  static const int otpSubsequentResend = 60;
  static const int otpMaxAttempts = 5;

  // Debounce
  static const int debounceSearch = 300;
  static const int debounceUsername = 500;
  static const int debouncePhone = 300;

  // Timeouts
  static const int apiTimeout = 3000;
  static const int preloadingTimeout = 2000;
  static const int emailSuggestionDelay = 10000; // 10 seconds
}
