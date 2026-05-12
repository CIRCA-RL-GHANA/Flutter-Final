import 'package:flutter/material.dart';

// OS palette
const Color _kBg       = Color(0xFF08080F);
const Color _kSurface  = Color(0xFF0E0E1A);
const Color _kBorder   = Color(0xFF1C1C2E);
const Color _kAccent   = Color(0xFF4361EE);
const Color _kText     = Color(0xFFE8E8F0);
const Color _kTextDim  = Color(0xFF6B6B88);
const Color _kTextMuted= Color(0xFF3A3A52);

/// Primary OS button — flat electric-blue, uppercase, monospace-ish spacing.
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

/// Secondary OS button — surface bg with border.
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

/// Outlined OS action button — border, no fill.
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
    this.height = 56,
    this.width,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        gradient: onPressed != null && !isLoading
            ? AppColors.ctaGradient
            : const LinearGradient(
                colors: [Color(0xFFD1D5DB), Color(0xFFB0B0B0)],
              ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: onPressed != null && !isLoading
            ? [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      if (icon != null) ...[
                        const SizedBox(width: 8),
                        Icon(icon, size: 24, color: AppColors.textPrimary),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Secondary text button
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
          color: color ?? AppColors.primaryLight,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          decoration: underline ? TextDecoration.underline : null,
        ),
      ),
    );
  }
}

/// Outlined button variant
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
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: AppColors.primaryLight),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
