import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive.dart';
import '../../../core/routes/app_routes.dart';
import '../providers/device_check_provider.dart';

/// Screen 0: Pre-Loading Validation (hidden device check).
/// Runs before splash to validate device capability.
class PreLoadingScreen extends StatefulWidget {
  const PreLoadingScreen({super.key});

  @override
  State<PreLoadingScreen> createState() => _PreLoadingScreenState();
}

class _PreLoadingScreenState extends State<PreLoadingScreen> {
  Widget? _errorWidget;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runChecks());
  }

  Future<void> _runChecks() async {
    final deviceCheck = context.read<DeviceCheckProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    deviceCheck.setScreenSize(screenWidth);

    final passed = await deviceCheck.runAllChecks();
    if (!mounted) return;

    if (passed) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.splash);
    } else {
      _handleFailure(deviceCheck);
    }
  }

  void _handleFailure(DeviceCheckProvider deviceCheck) {
    switch (deviceCheck.errorType) {
      case DeviceCheckError.insufficientStorage:
        _showErrorScreen(
          icon: Icons.storage_rounded,
          title: 'Not enough storage',
          message: deviceCheck.errorMessage ??
              'You need at least 100MB of free storage to use genie help.',
          actionLabel: 'Open storage settings',
          onAction: () {},
          secondaryLabel: 'Try anyway',
          onSecondary: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.splash),
        );
        break;
      case DeviceCheckError.incompatibleOs:
        _showErrorScreen(
          icon: Icons.system_update_rounded,
          title: 'OS update required',
          message: deviceCheck.errorMessage ??
              'genie help requires iOS 13+ or Android 8+. Please update your device.',
          actionLabel: 'Check for updates',
          onAction: () {},
        );
        break;
      case DeviceCheckError.noNetwork:
        _showErrorScreen(
          icon: Icons.wifi_off_rounded,
          title: 'No internet connection',
          message: 'You appear to be offline. Some features will be limited.',
          actionLabel: 'Try again',
          onAction: _runChecks,
          secondaryLabel: 'Continue in offline mode',
          onSecondary: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.splash),
        );
        break;
      default:
        _showErrorScreen(
          icon: Icons.error_outline_rounded,
          title: 'Something went wrong',
          message: deviceCheck.errorMessage ?? 'An unexpected error occurred.',
          actionLabel: 'Retry',
          onAction: _runChecks,
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

  @override
  Widget build(BuildContext context) {
    return IveScaffold(
      child: _errorWidget ??
          Consumer<DeviceCheckProvider>(
            builder: (context, deviceCheck, _) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        value: deviceCheck.progress,
                        strokeWidth: 2,
                        backgroundColor: IveTokens.surfaceRaised,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            IveTokens.accent),
                      ),
                    ),
                    const SizedBox(height: IveTokens.s5),
                    Text('Preparing genie help', style: IveType.callout),
                    const SizedBox(height: IveTokens.s4),
                    _CheckRow(
                        label: 'Network',
                        isDone: deviceCheck.progress >= 0.25),
                    _CheckRow(
                        label: 'Storage',
                        isDone: deviceCheck.progress >= 0.50),
                    _CheckRow(
                        label: 'Compatibility',
                        isDone: deviceCheck.progress >= 0.75),
                    _CheckRow(
                        label: 'Security',
                        isDone: deviceCheck.progress >= 1.0),
                  ],
                ),
              );
            },
          ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String label;
  final bool isDone;
  const _CheckRow({required this.label, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: IveTokens.s1, horizontal: IveTokens.s12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: IveTokens.dFast,
            child: isDone
                ? const Icon(Icons.check_rounded,
                    color: IveTokens.success,
                    size: 14,
                    key: ValueKey('done'))
                : const SizedBox(
                    width: 14,
                    height: 14,
                    key: ValueKey('loading'),
                    child: CircularProgressIndicator(
                      strokeWidth: 1.2,
                      color: IveTokens.labelTertiary,
                    ),
                  ),
          ),
          const SizedBox(width: IveTokens.s3),
          Text(
            label,
            style: IveType.footnote.copyWith(
              color: isDone
                  ? IveTokens.labelSecondary
                  : IveTokens.labelTertiary,
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
        padding: const EdgeInsets.all(IveTokens.s8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: IveTokens.surface,
                  borderRadius: IveTokens.brSm,
                  border: Border.fromBorderSide(IveTokens.hairlineSide),
                ),
                child: Icon(icon, size: 24, color: IveTokens.danger),
              ),
            ),
            const SizedBox(height: IveTokens.s6),
            Text(title,
                style: IveType.title3, textAlign: TextAlign.center),
            const SizedBox(height: IveTokens.s2),
            Text(message,
                style: IveType.callout, textAlign: TextAlign.center),
            const SizedBox(height: IveTokens.s8),
            IveButton.primary(label: actionLabel, onPressed: onAction),
            if (secondaryLabel != null && onSecondary != null) ...[
              const SizedBox(height: IveTokens.s3),
              IveButton.text(label: secondaryLabel!, onPressed: onSecondary!),
            ],
          ],
        ),
      ),
    );
  }
}
