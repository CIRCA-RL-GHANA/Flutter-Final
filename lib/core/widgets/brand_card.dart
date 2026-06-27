import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/brand.dart';

/// A premium card surface with hairline border, subtle gradient,
/// optional glassmorphism blur, and depth-tuned shadow.
///
/// Use as the canonical container for any grouped content  feature cards,
/// settings rows, summaries, modals.
class BrandCard extends StatelessWidget {
  const BrandCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Brand.space5),
    this.radius = Brand.radiusLg,
    this.glass = false,
    this.gradient,
    this.border,
    this.onTap,
  });

  /// Higher-emphasis variant: cyan glow + 1.5px cyan border.
  factory BrandCard.glow({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(Brand.space5),
    VoidCallback? onTap,
    double radius = Brand.radiusLg,
  }) =>
      BrandCard(
        key: key,
        padding: padding,
        radius: radius,
        border: Border.all(color: Brand.cyan.withValues(alpha: 0.45), width: 1.5),
        onTap: onTap,
        child: child,
      );

  /// Glassmorphism variant  backdrop-blurred translucent fill.
  factory BrandCard.glass({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(Brand.space5),
    VoidCallback? onTap,
    double radius = Brand.radiusLg,
  }) =>
      BrandCard(
        key: key,
        padding: padding,
        radius: radius,
        glass: true,
        onTap: onTap,
        child: child,
      );

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool glass;
  final Gradient? gradient;
  final BoxBorder? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(radius);

    Widget content = AnimatedContainer(
      duration: Brand.motionNormal,
      curve: Brand.curveStandard,
      padding: padding,
      decoration: BoxDecoration(
        color: glass ? Brand.bgElevated.withValues(alpha: 0.55) : Brand.bgElevated,
        gradient: gradient,
        borderRadius: br,
        border: border ?? Border.all(color: Brand.outline, width: 1),
      ),
      child: child,
    );

    if (glass) {
      content = ClipRRect(
        borderRadius: br,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: content,
        ),
      );
    }

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: br,
        splashColor: Brand.cyan.withValues(alpha: 0.08),
        highlightColor: Brand.cyan.withValues(alpha: 0.04),
        child: content,
      ),
    );
  }
}
