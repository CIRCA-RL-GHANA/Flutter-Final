import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/brand.dart';

/// Premium tap-feedback wrapper. Applies a subtle scale + opacity dip on
/// press, fires a light haptic, and exposes proper [Semantics] for a11y.
///
/// Use this for primary CTAs, list rows, cards, and any tappable surface
/// where the platform [InkWell] ripple is undesirable (e.g. on dark gradient
/// fills where ripple is invisible).
class BrandPressable extends StatefulWidget {
  const BrandPressable({
    super.key,
    required this.child,
    required this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.haptic = true,
    this.pressedScale = 0.97,
    this.pressedOpacity = 0.85,
    this.duration = Brand.motionFast,
    this.borderRadius,
    this.semanticLabel,
    this.button = true,
    this.cursor = SystemMouseCursors.click,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final bool haptic;
  final double pressedScale;
  final double pressedOpacity;
  final Duration duration;
  final BorderRadius? borderRadius;
  final String? semanticLabel;
  final bool button;
  final MouseCursor cursor;

  @override
  State<BrandPressable> createState() => _BrandPressableState();
}

class _BrandPressableState extends State<BrandPressable> {
  bool _pressed = false;

  bool get _interactive => widget.enabled && widget.onTap != null;

  void _setPressed(bool v) {
    if (!_interactive || _pressed == v) return;
    setState(() => _pressed = v);
  }

  void _handleTap() {
    if (!_interactive) return;
    if (widget.haptic) HapticFeedback.lightImpact();
    widget.onTap!.call();
  }

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? widget.pressedScale : 1.0;
    final opacity = _pressed ? widget.pressedOpacity : 1.0;

    Widget content = AnimatedScale(
      duration: widget.duration,
      curve: Brand.curveStandard,
      scale: scale,
      child: AnimatedOpacity(
        duration: widget.duration,
        curve: Brand.curveStandard,
        opacity: opacity,
        child: widget.child,
      ),
    );

    if (widget.borderRadius != null) {
      content = ClipRRect(borderRadius: widget.borderRadius!, child: content);
    }

    return Semantics(
      button: widget.button,
      enabled: _interactive,
      label: widget.semanticLabel,
      child: MouseRegion(
        cursor: _interactive ? widget.cursor : SystemMouseCursors.basic,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: _interactive ? _handleTap : null,
          onLongPress: widget.enabled ? widget.onLongPress : null,
          child: content,
        ),
      ),
    );
  }
}
