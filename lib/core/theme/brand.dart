import 'package:flutter/material.dart';

/// Centralized brand design tokens for genie help.
///
/// Single source of truth for color, spacing, radii, motion, elevation,
/// and typography. Prefer these over hard-coded values for any new UI.
@immutable
class Brand {
  const Brand._();

  // ─── Color (core brand palette) ──────────────────────────────────────
  static const Color bg          = Color(0xFF08080F); // page background
  static const Color bgElevated  = Color(0xFF11131C); // cards / sheets
  static const Color bgRaised    = Color(0xFF181B27); // raised surface
  static const Color outline     = Color(0xFF22273A); // hairline borders

  static const Color dark        = Color(0xFF1F2A33); // brand dark stroke
  static const Color cyan        = Color(0xFF22BDD8); // primary accent
  static const Color cyanDim     = Color(0xFF1798B0); // pressed/dim
  static const Color cyanGlow    = Color(0x3322BDD8); // ambient glow
  static const Color gold        = Color(0xFFC99B2C); // secondary accent
  static const Color goldBright  = Color(0xFFE5B743); // hover/highlight

  // Semantic colors
  static const Color success     = Color(0xFF10B981);
  static const Color warning     = Color(0xFFF59E0B);
  static const Color danger      = Color(0xFFEF4444);
  static const Color info        = cyan;

  // Text on dark surfaces
  static const Color textPrimary   = Color(0xFFE8E8F0);
  static const Color textSecondary = Color(0xB3E8E8F0); // 70%
  static const Color textTertiary  = Color(0x80E8E8F0); // 50%
  static const Color textDisabled  = Color(0x4DE8E8F0); // 30%

  // ─── Gradients ───────────────────────────────────────────────────────
  static const LinearGradient ctaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cyan, Color(0xFF1798B0)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldBright, gold],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgElevated, bg],
  );

  // ─── Spacing scale (4-pt grid) ───────────────────────────────────────
  static const double space1  = 4;
  static const double space2  = 8;
  static const double space3  = 12;
  static const double space4  = 16;
  static const double space5  = 20;
  static const double space6  = 24;
  static const double space8  = 32;
  static const double space10 = 40;
  static const double space12 = 48;
  static const double space16 = 64;

  // ─── Corner radii ────────────────────────────────────────────────────
  static const double radiusXs   = 6;
  static const double radiusSm   = 10;
  static const double radiusMd   = 14;
  static const double radiusLg   = 20;
  static const double radiusXl   = 28;
  static const double radiusPill = 999;

  static const BorderRadius brSm   = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius brMd   = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius brLg   = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius brXl   = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius brPill = BorderRadius.all(Radius.circular(radiusPill));

  // ─── Motion (durations + curves) ─────────────────────────────────────
  /// Instant micro-feedback (focus ring, press)
  static const Duration motionFast    = Duration(milliseconds: 120);
  /// Default transition (button press, hover)
  static const Duration motionNormal  = Duration(milliseconds: 240);
  /// Surface/page transitions
  static const Duration motionSlow    = Duration(milliseconds: 400);
  /// Choreographed entrances
  static const Duration motionEntrance = Duration(milliseconds: 640);

  /// Material 3 "emphasized" — perfect for primary interactions.
  static const Curve curveEmphasized = Cubic(0.2, 0.0, 0.0, 1.0);
  /// Gentle entrance for content reveal.
  static const Curve curveEnter      = Cubic(0.0, 0.0, 0.2, 1.0);
  /// Swift exit / dismissal.
  static const Curve curveExit       = Cubic(0.4, 0.0, 1.0, 1.0);
  /// Standard symmetric.
  static const Curve curveStandard   = Cubic(0.4, 0.0, 0.2, 1.0);

  // ─── Elevation (shadows tuned for dark UI) ───────────────────────────
  static const List<BoxShadow> elevation1 = [
    BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> elevation2 = [
    BoxShadow(color: Color(0x40000000), blurRadius: 16, offset: Offset(0, 4)),
  ];
  static const List<BoxShadow> elevation3 = [
    BoxShadow(color: Color(0x4D000000), blurRadius: 24, offset: Offset(0, 8)),
  ];
  static const List<BoxShadow> glowCyan = [
    BoxShadow(color: cyanGlow, blurRadius: 24, spreadRadius: 0),
  ];

  // ─── Touch targets ───────────────────────────────────────────────────
  static const double minTapTarget = 44; // WCAG / Apple HIG / MD3 minimum

  // ─── Hairline / dividers ─────────────────────────────────────────────
  static const BorderSide hairline = BorderSide(color: outline, width: 1);
  static Border get cardBorder => Border.all(color: outline, width: 1);
}

/// Brand-aligned text style ramp.
///
/// Build atop `Theme.of(context).textTheme` where possible; use these for
/// quick access without context.
@immutable
class BrandText {
  const BrandText._();

  static const TextStyle display = TextStyle(
    fontSize: 36, height: 1.15, fontWeight: FontWeight.w800,
    letterSpacing: -0.5, color: Brand.textPrimary,
  );
  static const TextStyle h1 = TextStyle(
    fontSize: 28, height: 1.2, fontWeight: FontWeight.w800,
    letterSpacing: -0.3, color: Brand.textPrimary,
  );
  static const TextStyle h2 = TextStyle(
    fontSize: 22, height: 1.25, fontWeight: FontWeight.w700,
    letterSpacing: -0.2, color: Brand.textPrimary,
  );
  static const TextStyle h3 = TextStyle(
    fontSize: 18, height: 1.3, fontWeight: FontWeight.w700,
    color: Brand.textPrimary,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16, height: 1.45, fontWeight: FontWeight.w500,
    color: Brand.textPrimary,
  );
  static const TextStyle body = TextStyle(
    fontSize: 14, height: 1.5, fontWeight: FontWeight.w500,
    color: Brand.textSecondary,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12, height: 1.45, fontWeight: FontWeight.w500,
    color: Brand.textTertiary,
  );
  static const TextStyle label = TextStyle(
    fontSize: 12, height: 1.2, fontWeight: FontWeight.w700,
    letterSpacing: 0.8, color: Brand.textSecondary,
  );
  static const TextStyle button = TextStyle(
    fontSize: 15, height: 1.0, fontWeight: FontWeight.w700,
    letterSpacing: 0.2, color: Brand.textPrimary,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 11, height: 1.3, fontWeight: FontWeight.w500,
    color: Brand.textTertiary,
  );
}
