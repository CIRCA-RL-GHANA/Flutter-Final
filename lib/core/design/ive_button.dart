import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ive_text.dart';
import 'ive_tokens.dart';

/// Honest, single-color buttons. No gradients. The accent does the talking.
///
/// Three weights:
/// - [IveButton.primary]  — filled accent, the page's one action
/// - [IveButton.secondary] — hairline-bordered, neutral
/// - [IveButton.text]     — text-only, used for tertiary actions
///
/// Sized to a 44pt minimum tap target.
///
/// Interaction polish (Jony-Ive grade):
///  • Pointer cursor on hover (web/desktop)
///  • Subtle press-scale (97%) for tactile feedback
///  • Light haptic on tap (medium for destructive)
///  • Visible focus ring for keyboard / accessibility users
class IveButton extends StatefulWidget {
  const IveButton._({
    super.key,
    required this.label,
    required this.onPressed,
    required _IveButtonVariant variant,
    this.icon,
    this.isLoading = false,
    this.isDestructive = false,
    this.expand = true,
    this.compact = false,
  }) : _variant = variant;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isDestructive;
  final bool expand;
  final bool compact;
  final _IveButtonVariant _variant;

  factory IveButton.primary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isDestructive = false,
    bool expand = true,
    bool compact = false,
  }) =>
      IveButton._(
        key: key,
        label: label,
        onPressed: onPressed,
        icon: icon,
        isLoading: isLoading,
        isDestructive: isDestructive,
        expand: expand,
        compact: compact,
        variant: _IveButtonVariant.primary,
      );

  factory IveButton.secondary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool expand = true,
    bool compact = false,
  }) =>
      IveButton._(
        key: key,
        label: label,
        onPressed: onPressed,
        icon: icon,
        isLoading: isLoading,
        expand: expand,
        compact: compact,
        variant: _IveButtonVariant.secondary,
      );

  factory IveButton.text({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isDestructive = false,
  }) =>
      IveButton._(
        key: key,
        label: label,
        onPressed: onPressed,
        icon: icon,
        isDestructive: isDestructive,
        expand: false,
        compact: true,
        variant: _IveButtonVariant.text,
      );

  @override
  State<IveButton> createState() => _IveButtonState();
}

class _IveButtonState extends State<IveButton> {
  bool _pressed = false;
  bool _focused = false;

  void _handleTap() {
    if (widget.isDestructive) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null && !widget.isLoading;
    final isPrimary = widget._variant == _IveButtonVariant.primary;
    final isText    = widget._variant == _IveButtonVariant.text;

    final fg = widget.isDestructive
        ? IveTokens.danger
        : isPrimary
            ? Colors.white
            : IveTokens.label;

    final bg = isPrimary
        ? (widget.isDestructive ? IveTokens.danger : IveTokens.accent)
        : Colors.transparent;

    final border = isPrimary || isText
        ? null
        : Border.all(color: IveTokens.hairline, width: 1);

    final height = widget.compact ? 40.0 : IveTokens.tap;
    final hPad   = widget.compact ? 14.0 : IveTokens.s5;

    final content = widget.isLoading
        ? SizedBox(
            width: 18, height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : Row(
            mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18, color: fg),
                const SizedBox(width: IveTokens.s2),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: IveType.bodyEmphasis.copyWith(
                    color: fg.withValues(alpha: disabled ? 0.4 : 1),
                  ),
                ),
              ),
            ],
          );

    final container = AnimatedContainer(
      duration: IveTokens.dMicro,
      curve: IveTokens.standard,
      height: height,
      padding: EdgeInsets.symmetric(horizontal: hPad),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: disabled ? 0.4 : 1),
        border: border,
        borderRadius: IveTokens.brMd,
      ),
      child: Center(child: content),
    );

    // Press-scale gives a tactile, physical response.
    final scaled = AnimatedScale(
      duration: IveTokens.dMicro,
      curve: IveTokens.standard,
      scale: _pressed && !disabled ? 0.97 : 1.0,
      child: container,
    );

    // Focus ring for keyboard / accessibility users; matches the press radius.
    final ringed = AnimatedContainer(
      duration: IveTokens.dMicro,
      curve: IveTokens.standard,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(IveTokens.rMd + 2)),
        border: Border.all(
          color: _focused && !disabled
              ? IveTokens.accent.withValues(alpha: 0.55)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: scaled,
    );

    final tappable = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled || widget.isLoading ? null : _handleTap,
        onHighlightChanged: (v) {
          if (mounted) setState(() => _pressed = v);
        },
        onFocusChange: (v) {
          if (mounted) setState(() => _focused = v);
        },
        borderRadius: IveTokens.brMd,
        splashColor: IveTokens.accentSoft,
        highlightColor: IveTokens.accentSoft,
        focusColor: Colors.transparent, // we paint our own ring
        child: Semantics(
          button: true,
          enabled: !disabled,
          label: widget.label,
          child: ringed,
        ),
      ),
    );

    final hoverable = MouseRegion(
      cursor: disabled
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      child: tappable,
    );

    return widget.expand
        ? SizedBox(width: double.infinity, child: hoverable)
        : hoverable;
  }
}

enum _IveButtonVariant { primary, secondary, text }
