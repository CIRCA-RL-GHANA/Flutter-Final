import 'package:flutter/material.dart';
import '../design/ive_tokens.dart';

/// Ambient page background — the "Living Void".
///
/// Renders [IveTokens.voidColor] as the base with a barely-perceptible
/// radial gradient that drifts across a 40-second cycle, giving the app a
/// sense of quiet depth without any literal shadow.
///
/// CRITICAL: Disables completely when [MediaQueryData.disableAnimations] is
/// true (OS reduce-motion). The gradient freezes to static in that case.
///
/// Usage: wrap the top-level Scaffold child, or use as the Scaffold background
/// via [LivingVoid.asBackground].
///
/// ```dart
/// Scaffold(
///   body: LivingVoid(child: YourContent()),
/// )
/// ```
class LivingVoid extends StatefulWidget {
  const LivingVoid({super.key, required this.child});

  final Widget child;

  @override
  State<LivingVoid> createState() => _LivingVoidState();
}

class _LivingVoidState extends State<LivingVoid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    );
    // Defer start so we can read MediaQuery
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStart());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeStart();
  }

  void _maybeStart() {
    if (!mounted) return;
    final reduced = MediaQuery.of(context).disableAnimations;
    if (reduced) {
      _ctrl.stop();
    } else if (!_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.of(context).disableAnimations;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Solid base — always rendered
        const ColoredBox(color: IveTokens.voidColor),

        // Drifting radial — skipped under reduce-motion
        if (!reduced)
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) {
              final t = Curves.easeInOut.transform(_ctrl.value);
              // Center drifts gently: x −0.10→+0.10, y −0.15→+0.15
              final dx = -0.10 + t * 0.20;
              final dy = -0.15 + t * 0.30;
              return DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(dx, dy),
                    radius: 1.1,
                    colors: const [
                      Color(0xFF0D0D20), // barely-visible blue-violet lift
                      IveTokens.voidColor,
                    ],
                    stops: const [0.0, 0.80],
                  ),
                ),
              );
            },
          ),

        // Content on top
        widget.child,
      ],
    );
  }
}
