import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/brand.dart';

/// Visual hierarchy variants for [BrandButton].
enum BrandButtonVariant {
  /// Primary CTA â€” filled cyan gradient with glow.
  primary,

  /// Secondary â€” transparent fill, cyan outline.
  secondary,

  /// Tertiary â€” text-only, cyan label, no fill or border.
  ghost,

  /// Destructive â€” danger-tinted fill.
  danger,
}

/// Sizes mapped to height + horizontal padding + label scale.
enum BrandButtonSize { sm, md, lg }

/// A premium, opinionated CTA button.
///
/// Features:
/// - Gradient fill with ambient cyan glow on primary
/// - Built-in loading state (preserves width, swaps to spinner)
/// - Press scale + opacity haptic micro-interaction
/// - Optional leading/trailing icons
/// - WCAG-min 44pt tap target
/// - Semantics with `button: true`
class BrandButton extends StatefulWidget {
  const BrandButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = BrandButtonVariant.primary,
    this.size = BrandButtonSize.md,
    this.leading,
    this.trailing,
    this.loading = false,
    this.expand = false,
    this.haptic = true,
    this.semanticLabel,
  });

  /// Convenience: full-width primary CTA.
  factory BrandButton.primary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    Widget? leading,
    Widget? trailing,
    bool loading = false,
    bool expand = true,
    BrandButtonSize size = BrandButtonSize.lg,
  }) =>
      BrandButton(
        key: key,
        label: label,
        onPressed: onPressed,
        variant: BrandButtonVariant.primary,
        size: size,
        leading: leading,
        trailing: trailing,
        loading: loading,
        expand: expand,
      );

  /// Convenience: outlined secondary action.
  factory BrandButton.secondary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    Widget? leading,
    Widget? trailing,
    bool expand = false,
    BrandButtonSize size = BrandButtonSize.md,
  }) =>
      BrandButton(
        key: key,
        label: label,
        onPressed: onPressed,
        variant: BrandButtonVariant.secondary,
        size: size,
        leading: leading,
        trailing: trailing,
        expand: expand,
      );

  /// Convenience: low-emphasis ghost action.
  factory BrandButton.ghost({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    Widget? leading,
    Widget? trailing,
    BrandButtonSize size = BrandButtonSize.md,
  }) =>
      BrandButton(
        key: key,
        label: label,
        onPressed: onPressed,
        variant: BrandButtonVariant.ghost,
        size: size,
        leading: leading,
        trailing: trailing,
      );

  final String label;
  final VoidCallback? onPressed;
  final BrandButtonVariant variant;
  final BrandButtonSize size;
  final Widget? leading;
  final Widget? trailing;
  final bool loading;
  final bool expand;
  final bool haptic;
  final String? semanticLabel;

  @override
  State<BrandButton> createState() => _BrandButtonState();
}

class _BrandButtonState extends State<BrandButton> {
  bool _pressed = false;
  bool _hovered = false;

  bool get _enabled =>
      widget.onPressed != null && !widget.loading;

  double get _height {
    switch (widget.size) {
      case BrandButtonSize.sm: return 40;
      case BrandButtonSize.md: return 48;
      case BrandButtonSize.lg: return 56;
    }
  }

  EdgeInsets get _padding {
    switch (widget.size) {
      case BrandButtonSize.sm: return const EdgeInsets.symmetric(horizontal: 14);
      case BrandButtonSize.md: return const EdgeInsets.symmetric(horizontal: 18);
      case BrandButtonSize.lg: return const EdgeInsets.symmetric(horizontal: 22);
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case BrandButtonSize.sm: return 13;
      case BrandButtonSize.md: return 15;
      case BrandButtonSize.lg: return 16;
    }
  }

  void _handleTap() {
    if (!_enabled) return;
    if (widget.haptic) HapticFeedback.lightImpact();
    widget.onPressed!.call();
  }

  Color _labelColor() {
    if (!_enabled) return Brand.textDisabled;
    switch (widget.variant) {
      case BrandButtonVariant.primary:
      case BrandButtonVariant.danger:
        return Colors.white;
      case BrandButtonVariant.secondary:
      case BrandButtonVariant.ghost:
        return Brand.cyan;
    }
  }

  BoxDecoration _decoration() {
    final radius = BorderRadius.circular(_height / 2); // pill
    switch (widget.variant) {
      case BrandButtonVariant.primary:
        return BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Brand.cyan, Brand.cyanDim],
          ),
          borderRadius: radius,
          boxShadow: _enabled
              ? [
                  BoxShadow(
                    color: Brand.cyan.withValues(alpha: _hovered ? 0.38 : 0.24),
                    blurRadius: _hovered ? 28 : 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        );
      case BrandButtonVariant.secondary:
        return BoxDecoration(
          color: _hovered
              ? Brand.cyan.withValues(alpha: 0.08)
              : Colors.transparent,
          border: Border.all(
            color: _enabled
                ? Brand.cyan.withValues(alpha: _hovered ? 1.0 : 0.7)
                : Brand.outline,
            width: 1.5,
          ),
          borderRadius: radius,
        );
      case BrandButtonVariant.ghost:
        return BoxDecoration(
          color: _hovered ? Brand.cyan.withValues(alpha: 0.06) : Colors.transparent,
          borderRadius: radius,
        );
      case BrandButtonVariant.danger:
        return BoxDecoration(
          color: Brand.danger,
          borderRadius: radius,
          boxShadow: _enabled
              ? [
                  BoxShadow(
                    color: Brand.danger.withValues(alpha: _hovered ? 0.36 : 0.22),
                    blurRadius: _hovered ? 24 : 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _labelColor();
    final radius = BorderRadius.circular(_height / 2);

    final children = <Widget>[];
    if (widget.leading != null) {
      children.add(IconTheme.merge(
        data: IconThemeData(color: color, size: _fontSize + 3),
        child: widget.leading!,
      ));
      children.add(const SizedBox(width: 8));
    }
    children.add(Flexible(
      child: Text(
        widget.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: _fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          height: 1.0,
          color: color,
        ),
      ),
    ));
    if (widget.trailing != null) {
      children.add(const SizedBox(width: 8));
      children.add(IconTheme.merge(
        data: IconThemeData(color: color, size: _fontSize + 3),
        child: widget.trailing!,
      ));
    }

    Widget content = widget.loading
        ? SizedBox(
            width: _fontSize + 4,
            height: _fontSize + 4,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          )
        : Row(
            mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          );

    Widget btn = AnimatedScale(
      duration: Brand.motionFast,
      curve: Brand.curveStandard,
      scale: _pressed && _enabled ? 0.97 : 1.0,
      child: AnimatedContainer(
        duration: Brand.motionNormal,
        curve: Brand.curveStandard,
        height: _height,
        width: widget.expand ? double.infinity : null,
        padding: _padding,
        decoration: _decoration(),
        alignment: Alignment.center,
        child: AnimatedOpacity(
          duration: Brand.motionFast,
          opacity: _enabled ? 1.0 : 0.55,
          child: content,
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.semanticLabel ?? widget.label,
      child: MouseRegion(
        cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
          onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
          onTap: _enabled ? _handleTap : null,
          child: ClipRRect(borderRadius: radius, child: btn),
        ),
      ),
    );
  }
}
