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

  // ─── Perfection Pass — Phase 0 / Move 07 (Duration-typed) ────────────────
  /// Instant micro-feedback: state changes, focus rings, press.
  static const Duration dpStateChange = Duration(milliseconds: 120);
  /// Default surface / sheet transitions.
  static const Duration dpSurface = Duration(milliseconds: 240);
  /// Content reveal (skeleton → real content cross-fade).
  static const Duration dpContentReveal = Duration(milliseconds: 200);
  /// List stagger offset between successive items.
  static const Duration dpStagger = Duration(milliseconds: 60);

  // Module signature motions
  /// GO — balance count-up (hero entrance).
  static const Duration dpGoBalance = Duration(milliseconds: 600);
  /// Fintech — credit gauge sweep.
  static const Duration dpCreditGauge = Duration(milliseconds: 800);
  /// Updates — poll bar sweep.
  static const Duration dpPollBars = Duration(milliseconds: 500);
  /// ePlay — shared-element cover → player.
  static const Duration dpSharedElement = Duration(milliseconds: 300);
  /// Alerts — relation line draw.
  static const Duration dpAlertLine = Duration(milliseconds: 400);
  /// qualChat — thread fold.
  static const Duration dpThreadFold = Duration(milliseconds: 400);
  /// Market — pin drop & settle.
  static const Duration dpPinSettle = Duration(milliseconds: 400);
  /// User — privacy arc live update.
  static const Duration dpPrivacyArc = Duration(milliseconds: 240);
  /// Onboarding — boot-sequence step reveal.
  static const Duration dpBootStep = Duration(milliseconds: 180);

  // Exempt looping animations (only Genie spark + APRIL mic loop)
  /// Genie cursor breath cycle.
  static const Duration dpGenieSpark = Duration(seconds: 4);
  /// APRIL mic breath cycle.
  static const Duration dpAprilMic = Duration(seconds: 2);
  /// Living Void drift cycle.
  static const Duration dpLivingVoid = Duration(seconds: 40);
}
