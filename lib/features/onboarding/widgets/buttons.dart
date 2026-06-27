import 'package:flutter/material.dart';
import '../../../core/design/ive_tokens.dart';

// OS palette  V2 tokens
const Color _kSurface   = IveTokens.surface;
const Color _kBorder    = IveTokens.hairline;
const Color _kAccent    = IveTokens.accent;
const Color _kTextMuted = IveTokens.mute;

/// Primary OS button  flat electric-blue, uppercase, monospace-ish spacing.
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double height;
  final double? width;
  final EdgeInsetsGeometry? margin;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 50,
    this.width,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    return Container(
      height: height,
      width: width ?? double.infinity,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 24),
      child: Material(
        color: enabled ? _kAccent : _kSurface,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(6),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        text.toUpperCase(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: enabled ? Colors.white : _kTextMuted,
                          letterSpacing: 1.5,
                        ),
                      ),
                      if (icon != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          icon,
                          size: 16,
                          color: enabled ? Colors.white : _kTextMuted,
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Secondary OS button  surface bg with border.
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final bool underline;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
    this.underline = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: color ?? _kAccent,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          decoration: underline ? TextDecoration.underline : null,
          decorationColor: color ?? _kAccent,
        ),
      ),
    );
  }
}

/// Outlined OS action button  border, no fill.
class OutlinedActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  const OutlinedActionButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _kBorder, width: 1),
          foregroundColor: _kAccent,
          backgroundColor: _kSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: _kAccent),
              const SizedBox(width: 8),
            ],
            Text(
              text.toUpperCase(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _kAccent,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
