import 'package:flutter/material.dart';
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
class IveButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final disabled = onPressed == null && !isLoading;
    final isPrimary = _variant == _IveButtonVariant.primary;
    final isText    = _variant == _IveButtonVariant.text;

    final fg = isDestructive
        ? IveTokens.danger
        : isPrimary
            ? Colors.white
            : IveTokens.label;

    final bg = isPrimary
        ? (isDestructive ? IveTokens.danger : IveTokens.accent)
        : Colors.transparent;

    final border = isPrimary || isText
        ? null
        : Border.all(color: IveTokens.hairline, width: 1);

    final height = compact ? 40.0 : IveTokens.tap;
    final hPad   = compact ? 14.0 : IveTokens.s5;

    final content = isLoading
        ? SizedBox(
            width: 18, height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: IveTokens.s2),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: IveType.bodyEmphasis.copyWith(
                    color: fg.withValues(alpha: disabled ? 0.4 : 1),
                  ),
                ),
              ),
            ],
          );

    final child = AnimatedContainer(
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

    final tappable = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled || isLoading ? null : onPressed,
        borderRadius: IveTokens.brMd,
        splashColor: IveTokens.accentSoft,
        highlightColor: IveTokens.accentSoft,
        child: Semantics(
          button: true,
          enabled: !disabled,
          label: label,
          child: child,
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: tappable) : tappable;
  }
}

enum _IveButtonVariant { primary, secondary, text }
