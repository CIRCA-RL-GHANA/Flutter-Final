import 'package:flutter/material.dart';
import '../../../core/design/ive.dart';
import '../../../core/utils/responsive.dart';

/// Error types for the recovery screen (must stay — used by app router).
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

/// Screen 14 — Error recovery.
/// Class name and ErrorType enum are referenced by the app router.
class ErrorRecoveryScreen extends StatelessWidget {
  final ErrorType errorType;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const ErrorRecoveryScreen({
    super.key,
    required this.errorType,
    this.errorMessage,
    this.onRetry,
  });

  String get _description {
    if (errorMessage != null && errorMessage!.isNotEmpty) return errorMessage!;
    return "We couldn't reach the commerce layer. Check your connection and try one of the options below.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IveTokens.bg,
      body: SafeArea(
        child: Responsive.constrained(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),

                // Red "!" icon tile (top-left aligned)
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: IveTokens.danger.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: IveTokens.danger.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(
                    Icons.priority_high_rounded,
                    size: 28,
                    color: IveTokens.danger,
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                const Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: IveTokens.ink,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 10),

                // Description
                Text(
                  _description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: IveTokens.ink2,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                // Action rows
                _ActionRow(
                  icon: Icons.refresh_rounded,
                  title: 'Retry connection',
                  subtitle: 'Attempt to reconnect now',
                  onTap: onRetry ?? () {},
                ),
                const Divider(
                    height: 1, thickness: 1, color: IveTokens.hairline),
                _ActionRow(
                  icon: Icons.search_rounded,
                  title: 'Run diagnostics',
                  subtitle: 'Check network & storage',
                  onTap: () {},
                ),
                const Divider(
                    height: 1, thickness: 1, color: IveTokens.hairline),
                _ActionRow(
                  icon: Icons.help_outline_rounded,
                  title: 'Contact support',
                  subtitle: "We'll help you recover",
                  onTap: () {},
                ),

                const Spacer(),

                // RETRY button
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: IveButton.primary(
                    label: 'RETRY',
                    onPressed: onRetry ?? () => Navigator.of(context).maybePop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            // Icon tile
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: IveTokens.surface,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: IveTokens.hairline),
              ),
              child: Icon(icon, size: 18, color: IveTokens.ink2),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: IveTokens.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: IveTokens.mute,
                    ),
                  ),
                ],
              ),
            ),

            const Text(
              '>',
              style: TextStyle(fontSize: 14, color: IveTokens.mute),
            ),
          ],
        ),
      ),
    );
  }
}
