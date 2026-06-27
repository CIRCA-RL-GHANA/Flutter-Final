import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/hex_mark.dart';
import '../providers/device_check_provider.dart';

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
          title: 'Not enough storage',
          message: 'Free up at least 100MB to continue.',
          actionLabel: 'Open storage settings',
          onAction: () {},
          secondaryLabel: 'Try anyway',
          onSecondary: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.splash),
        );
        break;
      case DeviceCheckError.incompatibleOs:
        _showErrorScreen(
          title: 'OS update required',
          message: deviceCheck.errorMessage ??
              'iOS 13+ or Android 8+ required.',
          actionLabel: 'Check for updates',
          onAction: () {},
        );
        break;
      case DeviceCheckError.noNetwork:
        _showErrorScreen(
          title: 'No internet connection',
          message: 'You appear to be offline.',
          actionLabel: 'Try again',
          onAction: _runChecks,
          secondaryLabel: 'Continue offline',
          onSecondary: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.splash),
        );
        break;
      default:
        _showErrorScreen(
          title: 'Something went wrong',
          message: deviceCheck.errorMessage ?? 'An unexpected error occurred.',
          actionLabel: 'Retry',
          onAction: _runChecks,
        );
    }
  }

  void _showErrorScreen({
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
    String? secondaryLabel,
    VoidCallback? onSecondary,
  }) {
    setState(() {
      _errorWidget = _ErrorDisplay(
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
    if (_errorWidget != null) return _errorWidget!;

    return Scaffold(
      backgroundColor: IveTokens.bg,
      body: Consumer<DeviceCheckProvider>(
        builder: (context, deviceCheck, _) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 3),

                  // Hex mark with traveling arc — the loading indicator
                  const Center(child: HexMark(size: 56, animated: true)),
                  const SizedBox(height: 20),

                  // Eyebrow
                  Center(
                    child: Text(
                      'COMMERCE OS',
                      style: IveType.mono.copyWith(
                        fontSize: 10,
                        color: IveTokens.mute,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Heading
                  Center(
                    child: Text(
                      'Initializing',
                      style: IveType.display.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: IveTokens.ink,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Progress line
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    height: 2,
                    width: (MediaQuery.of(context).size.width - 40) *
                        deviceCheck.progress,
                    decoration: BoxDecoration(
                      color: IveTokens.accent,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  // Track
                  Container(
                    height: 2,
                    color: IveTokens.hairline,
                    margin: const EdgeInsets.only(top: 0),
                  ),

                  const SizedBox(height: 28),

                  // Check rows
                  _CheckRow(
                    label: 'Network',
                    progress: deviceCheck.progress,
                    doneAt: 0.25,
                  ),
                  _CheckRow(
                    label: 'Storage',
                    progress: deviceCheck.progress,
                    doneAt: 0.50,
                  ),
                  _CheckRow(
                    label: 'Compatibility',
                    progress: deviceCheck.progress,
                    doneAt: 0.75,
                  ),
                  _CheckRow(
                    label: 'Security',
                    progress: deviceCheck.progress,
                    doneAt: 1.0,
                  ),

                  const Spacer(flex: 4),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String label;
  final double progress;
  final double doneAt;

  const _CheckRow({
    required this.label,
    required this.progress,
    required this.doneAt,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = progress >= doneAt;
    final isChecking = !isDone && progress >= doneAt - 0.25;

    final Color statusColor = isDone
        ? IveTokens.success
        : isChecking
            ? IveTokens.warning
            : IveTokens.mute;

    final String statusText = isDone
        ? 'OK'
        : isChecking
            ? 'CHECKING'
            : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Text(
            label,
            style: IveType.mono.copyWith(
              fontSize: 12,
              color: isDone ? IveTokens.ink2 : IveTokens.mute,
              letterSpacing: 0.2,
            ),
          ),
          const Spacer(),
          if (statusText.isNotEmpty) ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              statusText,
              style: IveType.mono.copyWith(
                fontSize: 11,
                color: statusColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorDisplay extends StatelessWidget {
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const _ErrorDisplay({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IveTokens.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title,
                  style: IveType.title3.copyWith(color: IveTokens.ink),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(message,
                  style: IveType.callout.copyWith(color: IveTokens.ink2),
                  textAlign: TextAlign.center),
              const SizedBox(height: 32),
              IveButton.primary(label: actionLabel, onPressed: onAction),
              if (secondaryLabel != null && onSecondary != null) ...[
                const SizedBox(height: 12),
                IveButton.text(label: secondaryLabel!, onPressed: onSecondary!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
