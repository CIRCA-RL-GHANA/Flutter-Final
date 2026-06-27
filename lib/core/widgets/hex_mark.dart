import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Commerce OS brand mark — flat-top hexagon, blue outline + gold inner fill.
///
/// [glow] adds a soft blue radial glow (splash screen only).
/// [animated] drives a bright arc traveling around the outer hex perimeter
/// (preloading screen only).
class HexMark extends StatefulWidget {
  final double size;
  final bool glow;
  final bool animated;
  final String semanticsLabel;

  const HexMark({
    super.key,
    required this.size,
    this.glow = false,
    this.animated = false,
    this.semanticsLabel = 'Commerce OS',
  });

  @override
  State<HexMark> createState() => _HexMarkState();
}

class _HexMarkState extends State<HexMark>
    with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;

  @override
  void initState() {
    super.initState();
    if (widget.animated) {
      _ctrl = AnimationController(
        duration: const Duration(milliseconds: 1800),
        vsync: this,
      )..repeat();
    }
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticsLabel,
      image: true,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: widget.animated && _ctrl != null
            ? AnimatedBuilder(
                animation: _ctrl!,
                builder: (_, __) => CustomPaint(
                  painter: _HexMarkPainter(
                    glow: widget.glow,
                    arcProgress: _ctrl!.value,
                  ),
                ),
              )
            : CustomPaint(
                painter: _HexMarkPainter(glow: widget.glow),
              ),
      ),
    );
  }
}

class _HexMarkPainter extends CustomPainter {
  final bool glow;
  final double? arcProgress;

  const _HexMarkPainter({required this.glow, this.arcProgress});

  static const Color _accent = Color(0xFF4361EE);
  static const Color _gold = Color(0xFFC9A84C);

  // Flat-top regular hexagon: vertices at 0°, 60°, 120°, 180°, 240°, 300°.
  Path _hexPath(Offset center, double r) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final a = i * 60.0 * math.pi / 180.0;
      final p = Offset(center.dx + r * math.cos(a), center.dy + r * math.sin(a));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);

    final strokeW = s * 0.07;
    final outerR = s * 0.42;
    final innerR = (outerR - strokeW / 2) * 0.68;

    // Glow
    if (glow) {
      canvas.drawCircle(
        center,
        outerR * 1.9,
        Paint()
          ..shader = RadialGradient(
            colors: [
              _accent.withValues(alpha: 0.22),
              _accent.withValues(alpha: 0.0),
            ],
          ).createShader(
            Rect.fromCircle(center: center, radius: outerR * 1.9),
          ),
      );
    }

    final outerPath = _hexPath(center, outerR);

    // Outer hex base — dim when animated, full when static
    canvas.drawPath(
      outerPath,
      Paint()
        ..color = _accent.withValues(alpha: arcProgress != null ? 0.28 : 1.0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeJoin = StrokeJoin.round,
    );

    // Traveling arc overlay
    if (arcProgress != null) {
      final metrics = outerPath.computeMetrics().toList();
      if (metrics.isNotEmpty) {
        final perimeter = metrics.first.length;
        // Arc covers ~22% of the perimeter (≈ 1.3 sides)
        final arcLen = perimeter * 0.22;
        final offset = arcProgress! * perimeter;

        final arcPath = Path();
        final end = offset + arcLen;

        if (end <= perimeter) {
          arcPath.addPath(
            metrics.first.extractPath(offset, end),
            Offset.zero,
          );
        } else {
          arcPath.addPath(
            metrics.first.extractPath(offset, perimeter),
            Offset.zero,
          );
          arcPath.addPath(
            metrics.first.extractPath(0, end - perimeter),
            Offset.zero,
          );
        }

        canvas.drawPath(
          arcPath,
          Paint()
            ..color = _accent
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeW
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }
    }

    // Inner hex (gold fill) — always static
    canvas.drawPath(
      _hexPath(center, innerR),
      Paint()
        ..color = _gold
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _HexMarkPainter old) =>
      old.glow != glow || old.arcProgress != arcProgress;
}
