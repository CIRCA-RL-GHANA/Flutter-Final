import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../providers/device_check_provider.dart';

/// Screen 0: Pre-Loading Validation (Hidden System Check)
/// Runs before splash to validate device capability
class PreLoadingScreen extends StatefulWidget {
  const PreLoadingScreen({super.key});

  @override
  State<PreLoadingScreen> createState() => _PreLoadingScreenState();
}

class _PreLoadingScreenState extends State<PreLoadingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runChecks();
    });
  }

  Future<void> _runChecks() async {
    final deviceCheck = context.read<DeviceCheckProvider>();

    // Detect screen size
    final screenWidth = MediaQuery.of(context).size.width;
    deviceCheck.setScreenSize(screenWidth);

    // Run all device checks (target: <2s)
    final passed = await deviceCheck.runAllChecks();

    if (!mounted) return;

    if (passed) {
      // All checks passed → go to splash
      Navigator.of(context).pushReplacementNamed(AppRoutes.splash);
    } else {
      // Failed checks → show appropriate error
      _handleFailure(deviceCheck);
    }
  }

  void _handleFailure(DeviceCheckProvider deviceCheck) {
    switch (deviceCheck.errorType) {
      case DeviceCheckError.insufficientStorage:
        _showErrorScreen(
          icon: Icons.storage_rounded,
          title: 'Not Enough Storage',
          message: deviceCheck.errorMessage ??
              'You need at least 100MB of free storage to use PROMPT Genie.',
          actionLabel: 'Open Storage Settings',
          onAction: () {
            // In production: Open device storage settings
          },
          secondaryLabel: 'Try Anyway',
          onSecondary: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.splash),
        );
        break;
      case DeviceCheckError.incompatibleOs:
        _showErrorScreen(
          icon: Icons.system_update_rounded,
          title: 'OS Update Required',
          message: deviceCheck.errorMessage ??
              'PROMPT Genie requires iOS 13+ or Android 8+. Please update your device.',
          actionLabel: 'Check for Updates',
          onAction: () {
            // In production: Open system update settings
          },
        );
        break;
      case DeviceCheckError.noNetwork:
        _showErrorScreen(
          icon: Icons.wifi_off_rounded,
          title: 'No Internet Connection',
          message: 'You appear to be offline. Some features will be limited.',
          actionLabel: 'Try Again',
          onAction: () => _runChecks(),
          secondaryLabel: 'Continue in Offline Mode',
          onSecondary: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.splash),
        );
        break;
      default:
        _showErrorScreen(
          icon: Icons.error_outline_rounded,
          title: 'Something Went Wrong',
          message: deviceCheck.errorMessage ?? 'An unexpected error occurred.',
          actionLabel: 'Retry',
          onAction: () => _runChecks(),
        );
    }
  }

  void _showErrorScreen({
    required IconData icon,
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
    String? secondaryLabel,
    VoidCallback? onSecondary,
  }) {
    setState(() {
      _errorWidget = _ErrorDisplay(
        icon: icon,
        title: title,
        message: message,
        actionLabel: actionLabel,
        onAction: onAction,
        secondaryLabel: secondaryLabel,
        onSecondary: onSecondary,
      );
    });
  }

  Widget? _errorWidget;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: _errorWidget ??
          Consumer<DeviceCheckProvider>(
            builder: (context, deviceCheck, child) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Loading indicator
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        value: deviceCheck.progress,
                        strokeWidth: 3,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.accent),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Preparing PROMPT Genie...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Check status indicators
                    _CheckStatusRow(
                      label: 'Network',
                      isDone: deviceCheck.progress >= 0.25,
                    ),
                    _CheckStatusRow(
                      label: 'Storage',
                      isDone: deviceCheck.progress >= 0.50,
                    ),
                    _CheckStatusRow(
                      label: 'Compatibility',
                      isDone: deviceCheck.progress >= 0.75,
                    ),
                    _CheckStatusRow(
                      label: 'Security',
                      isDone: deviceCheck.progress >= 1.0,
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }
}

class _CheckStatusRow extends StatelessWidget {
  final String label;
  final bool isDone;

  const _CheckStatusRow({required this.label, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 48),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isDone
                ? const Icon(Icons.check_circle, color: AppColors.success, size: 16, key: ValueKey('done'))
                : const SizedBox(
                    width: 16,
                    height: 16,
                    key: ValueKey('loading'),
                    child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white24),
                  ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isDone ? Colors.white70 : Colors.white30,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorDisplay extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const _ErrorDisplay({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppColors.error),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(actionLabel),
              ),
            ),
            if (secondaryLabel != null && onSecondary != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: onSecondary,
                child: Text(
                  secondaryLabel!,
                  style: const TextStyle(color: Colors.white60),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
