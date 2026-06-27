import 'package:flutter/material.dart';
import '../../../core/design/ive.dart';
import '../../../core/widgets/hex_mark.dart';

/// Wraps any onboarding screen body. When [isLoading] is true, an overlay
/// appears that blocks interaction and signals progress with the animated logo.
class OnboardingLoadingOverlay extends StatelessWidget {
  const OnboardingLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        AnimatedSwitcher(
          duration: IveTokens.dFast,
          child: isLoading
              ? const _Overlay(key: ValueKey('overlay'))
              : const SizedBox.shrink(key: ValueKey('empty')),
        ),
      ],
    );
  }
}

class _Overlay extends StatelessWidget {
  const _Overlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: IveTokens.bg.withValues(alpha: 0.80),
        child: const Center(
          child: HexMark(size: 52, animated: true),
        ),
      ),
    );
  }
}
