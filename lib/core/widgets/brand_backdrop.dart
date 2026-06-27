import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../theme/brand.dart';

/// A cinematic, GPU-friendly backdrop for hero/onboarding screens.
///
/// Renders two slowly orbiting radial light blooms (cyan + gold) on top of a
/// deep brand-bg gradient. Pauses automatically when [TickerMode] is off and
/// honors `MediaQuery.disableAnimations` for reduced-motion users.
class BrandBackdrop extends StatefulWidget {
  const BrandBackdrop({
    super.key,
    this.child,
    this.intensity = 1.0,
  });

  final Widget? child;

  /// 0..1  scales bloom opacity. Use lower values behind content-heavy screens.
  final double intensity;

  @override
  State<BrandBackdrop> createState() => _BrandBackdropState();
}

class _BrandBackdropState extends State<BrandBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 24))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disable = MediaQuery.of(context).disableAnimations;
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Deep base gradient.
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Brand.bgElevated, Brand.bg],
                stops: [0.0, 0.75],
              ),
            ),
          ),
          // Animated brand blooms.
          if (!disable)
            AnimatedBuilder(
              animation: _c,
              builder: (_, __) => CustomPaint(
                painter: _BloomPainter(_c.value, widget.intensity),
              ),
            )
          else
            CustomPaint(painter: _BloomPainter(0.25, widget.intensity * 0.6)),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _BloomPainter extends CustomPainter {
  _BloomPainter(this.t, this.intensity);
  final double t; // 0..1
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    const tau = 2 * math.pi;

    // Cyan bloom  orbits the upper-left.
    final cx = size.width * (0.25 + 0.12 * math.cos(t * tau));
    final cy = size.height * (0.22 + 0.08 * math.sin(t * tau));
    final cyanR = size.shortestSide * 0.55;
    final cyanPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Brand.cyan.withValues(alpha: 0.22 * intensity),
          Brand.cyan.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: cyanR));
    canvas.drawCircle(Offset(cx, cy), cyanR, cyanPaint);

    // Gold bloom  orbits the lower-right, offset phase.
    final gx = size.width * (0.78 + 0.10 * math.cos(t * tau + math.pi));
    final gy = size.height * (0.80 + 0.10 * math.sin(t * tau + math.pi / 2));
    final goldR = size.shortestSide * 0.5;
    final goldPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Brand.gold.withValues(alpha: 0.14 * intensity),
          Brand.gold.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(gx, gy), radius: goldR));
    canvas.drawCircle(Offset(gx, gy), goldR, goldPaint);
  }

  @override
  bool shouldRepaint(covariant _BloomPainter old) =>
      old.t != t || old.intensity != intensity;
}
