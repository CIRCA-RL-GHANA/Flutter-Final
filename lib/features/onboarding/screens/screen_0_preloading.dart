import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../providers/device_check_provider.dart';


// OS palette � mirrors splash / welcome
const Color _kBg        = Color(0xFF08080F);
const Color _kSurface   = Color(0xFF0E0E1A);
const Color _kBorder    = Color(0xFF1C1C2E);
const Color _kAccent    = Color(0xFF22BDD8);
const Color _kAccentDim = Color(0xFF1E2A6E);
const Color _kText      = Color(0xFFE8E8F0);
const Color _kTextDim   = Color(0xFF6B6B88);
const Color _kTextMuted = Color(0xFF3A3A52);
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
              'You need at least 100MB of free storage to use genie help.',
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
              'genie help requires iOS 13+ or Android 8+. Please update your device.',
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
      backgroundColor: const Color(0xFF08080F),
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
                        backgroundColor: const Color(0xFF08080F),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF22BDD8)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Preparing genie help...',
                      style: TextStyle(
                        color: const Color(0xFF0E0E1A).withOpacity(0.7),
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
                ? const Icon(Icons.check_circle, color: const Color(0xFF10B981), size: 16, key: ValueKey('done'))
                : const SizedBox(
                    width: 16,
                    height: 16,
                    key: ValueKey('loading'),
                    child: CircularProgressIndicator(strokeWidth: 1.5, color: const Color(0xFF1C1C2E)),
                  ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isDone ? const Color(0xFF6B6B88) : const Color(0xFF3A3A52),
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
                color: const Color(0xFFEF4444).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: const Color(0xFFEF4444)),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                color: const Color(0xFF0E0E1A),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                color: const Color(0xFF6B6B88),
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
                  backgroundColor: const Color(0xFF22BDD8),
                  foregroundColor: const Color(0xFF0E0E1A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
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
                  style: const TextStyle(color: const Color(0xFF6B6B88)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
