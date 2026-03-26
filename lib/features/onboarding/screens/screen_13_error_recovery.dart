import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive.dart';
import '../widgets/buttons.dart';

/// Error types for the recovery screen
enum ErrorType {
  network,
  server,
  validation,
  accountSuspended,
  accountDuplicate,
  accountCompromised,
  phoneLost,
  biometricChanged,
  deviceChange,
}

/// Screen 13: Error & Recovery Flows
/// Graceful degradation with clear recovery paths
class ErrorRecoveryScreen extends StatefulWidget {
  final ErrorType errorType;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const ErrorRecoveryScreen({
    super.key,
    required this.errorType,
    this.errorMessage,
    this.onRetry,
  });

  @override
  State<ErrorRecoveryScreen> createState() => _ErrorRecoveryScreenState();
}

class _ErrorRecoveryScreenState extends State<ErrorRecoveryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  _ErrorConfig _getErrorConfig() {
    switch (widget.errorType) {
      case ErrorType.network:
        return _ErrorConfig(
          icon: Icons.wifi_off_rounded,
          iconColor: AppColors.warning,
          title: AppStrings.offlineMode,
          message: widget.errorMessage ??
              'Check your internet connection and try again.',
          primaryAction: 'Try Again',
          primaryIcon: Icons.refresh,
          secondaryAction: 'Continue Offline',
          showRetryTimer: true,
          retryBackoff: true,
          suggestions: [
            'Check your Wi-Fi or mobile data',
            'Try moving to an area with better signal',
            'Restart your device and try again',
          ],
        );

      case ErrorType.server:
        return _ErrorConfig(
          icon: Icons.cloud_off_rounded,
          iconColor: AppColors.error,
          title: AppStrings.serverBusy,
          message: widget.errorMessage ??
              'Our servers are experiencing high traffic. Please try again shortly.',
          primaryAction: AppStrings.tryAgain,
          primaryIcon: Icons.refresh,
          secondaryAction: 'Use Demo Mode',
          showRetryTimer: true,
          retryBackoff: true,
          suggestions: [
            'Wait a few moments and try again',
            'Check our status page for updates',
            'Contact support if the issue persists',
          ],
        );

      case ErrorType.validation:
        return _ErrorConfig(
          icon: Icons.error_outline_rounded,
          iconColor: AppColors.warning,
          title: 'Validation Error',
          message: widget.errorMessage ??
              'Some information needs to be corrected.',
          primaryAction: 'Fix & Continue',
          primaryIcon: Icons.edit,
          suggestions: [
            'Check the highlighted fields',
            'Make sure all required fields are filled',
            'Use the correct format shown below each field',
          ],
        );

      case ErrorType.accountSuspended:
        return _ErrorConfig(
          icon: Icons.block_rounded,
          iconColor: AppColors.error,
          title: 'Account Suspended',
          message: widget.errorMessage ??
              'Your account has been suspended. Contact support for more information.',
          primaryAction: 'Contact Support',
          primaryIcon: Icons.support_agent,
          secondaryAction: 'View Reason',
          suggestions: [
            'Review our community guidelines',
            'Contact our support team for assistance',
            'Check your email for suspension details',
          ],
        );

      case ErrorType.accountDuplicate:
        return _ErrorConfig(
          icon: Icons.people_outline_rounded,
          iconColor: AppColors.info,
          title: 'Account Already Exists',
          message: widget.errorMessage ??
              'An account with this information already exists.',
          primaryAction: 'Log In Instead',
          primaryIcon: Icons.login,
          secondaryAction: 'Create New Account',
          suggestions: [
            'Try logging in with your existing account',
            'Use a different phone number or email',
            'Contact support to merge accounts',
          ],
        );

      case ErrorType.accountCompromised:
        return _ErrorConfig(
          icon: Icons.shield_rounded,
          iconColor: AppColors.error,
          title: 'Security Alert',
          message: widget.errorMessage ??
              'We detected unusual activity on your account.',
          primaryAction: 'Verify Identity',
          primaryIcon: Icons.verified_user,
          secondaryAction: 'Contact Support',
          suggestions: [
            'Verify your identity to secure your account',
            'Change your password immediately',
            'Review recent account activity',
          ],
        );

      case ErrorType.phoneLost:
        return _ErrorConfig(
          icon: Icons.phone_disabled_rounded,
          iconColor: AppColors.warning,
          title: 'Phone Number Changed?',
          message: 'Verify your identity through alternative methods.',
          primaryAction: 'Verify via Email',
          primaryIcon: Icons.email_outlined,
          secondaryAction: 'Security Questions',
          suggestions: [
            'Use your backup email to verify',
            'Answer your security questions',
            'Contact support with proof of identity',
          ],
        );

      case ErrorType.biometricChanged:
        return _ErrorConfig(
          icon: Icons.fingerprint,
          iconColor: AppColors.warning,
          title: 'Biometric Changed',
          message: 'Your biometric data has changed. Please verify with your PIN or password.',
          primaryAction: 'Use PIN',
          primaryIcon: Icons.pin,
          secondaryAction: 'Use Password',
          suggestions: [
            'Enter your backup PIN or password',
            'Re-enroll biometrics in settings after login',
            'Contact support if you cannot access your account',
          ],
        );

      case ErrorType.deviceChange:
        return _ErrorConfig(
          icon: Icons.devices_rounded,
          iconColor: AppColors.info,
          title: 'New Device Detected',
          message: 'Transfer your account to this device securely.',
          primaryAction: 'Scan QR Code',
          primaryIcon: Icons.qr_code_scanner,
          secondaryAction: 'Verify Manually',
          suggestions: [
            'Open PROMPT on your previous device',
            'Go to Settings > Account Transfer',
            'Scan the QR code shown on this screen',
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getErrorConfig();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Responsive.constrained(
          child: Column(
            children: [
              // Close / Back button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: FadeTransition(
                  opacity: _animController,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),

                        // Error icon
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: config.iconColor.withOpacity(0.12),
                          ),
                          child: Icon(
                            config.icon,
                            size: 48,
                            color: config.iconColor,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Title
                        Text(
                          config.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 12),

                        // Message
                        Text(
                          config.message,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // Suggestions
                        if (config.suggestions != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.inputFill,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'What you can do:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...config.suggestions!.asMap().entries.map(
                                  (entry) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryLight
                                                .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${entry.key + 1}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.primaryLight,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            entry.value,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppColors.textSecondary,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  children: [
                    PrimaryButton(
                      text: config.primaryAction,
                      icon: config.primaryIcon,
                      onPressed: widget.onRetry ?? () => Navigator.pop(context),
                      margin: EdgeInsets.zero,
                    ),
                    if (config.secondaryAction != null) ...[
                      const SizedBox(height: 12),
                      OutlinedActionButton(
                        text: config.secondaryAction!,
                        onPressed: () {
                          // Handle secondary action based on type
                          Navigator.pop(context);
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.needHelp,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorConfig {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String primaryAction;
  final IconData? primaryIcon;
  final String? secondaryAction;
  final bool showRetryTimer;
  final bool retryBackoff;
  final List<String>? suggestions;

  const _ErrorConfig({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.primaryAction,
    this.primaryIcon,
    this.secondaryAction,
    this.showRetryTimer = false,
    this.retryBackoff = false,
    this.suggestions,
  });
}
