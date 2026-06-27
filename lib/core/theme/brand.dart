import 'package:flutter/material.dart';

/// Centralized brand design tokens for PROMPT Genie.
///
/// Single source of truth for color, spacing, radii, motion, and typography.
/// Organized by layer: void (background)  surface  foreground  signal  Genie.
///
/// V2.0 Perfection Pass changes:
/// - Accent switched from cyan (#22BDD8) to indigo (#4361EE)
/// - Surface colors tightened for deeper contrast
/// - Text colors moved to solid values (no alpha hacks)
/// - Radii standardized to 3 values: 6 / 10 / 100
/// - All elevation shadows removed (luminance lift replaces them)
/// - Gold palette updated to Genie-specific warm (#C9A84C)
@immutable
class Brand {
  const Brand._();

  //  Void / Background 
  static const Color bg          = Color(0xFF08080F); // void  deepest background
  static const Color void2       = Color(0xFF0B0B14); // subtle lift above void
  static const Color bgElevated  = Color(0xFF0E0E1A); // surface  cards, sheets
  static const Color bgRaised    = Color(0xFF14141F); // raised  modals, headers
  static const Color outline     = Color(0xFF1C1C2E); // hairline  borders, dividers
  static const Color outline2    = Color(0xFF26263A); // hair-2  stronger dividers

  //  System Accent (indigo) 
  // V2.0: switched from cyan 0xFF22BDD8  indigo 0xFF4361EE
  static const Color cyan        = Color(0xFF4361EE); // accent indigo
  static const Color cyanDim     = Color(0xFF3451D1); // pressed / dimmed
  static const Color cyanGlow    = Color(0x264361EE); // ambient soft glow

  //  Genie Warm Palette (gold  use sparingly, one per screen) 
  static const Color gold        = Color(0xFFC9A84C); // Genie gold
  static const Color goldBright  = Color(0xFFE6C766); // Genie bright
  static const Color genieSoft   = Color(0x1AC9A84C); // Genie background tint
  static const Color genieLine   = Color(0x44C9A84C); // Genie border

  //  Signal Colors 
  static const Color success     = Color(0xFF34D399); // ok / positive
  static const Color warning     = Color(0xFFF5B544); // warn / caution
  static const Color danger      = Color(0xFFF26D6D); // bad / error
  static const Color info        = Color(0xFF5BA8E8); // informational

  //  Text (solid values  no alpha on text) 
  static const Color textPrimary   = Color(0xFFE8E8F0); // ink  primary
  static const Color textSecondary = Color(0xFFA6A6BE); // ink-2  secondary
  static const Color textTertiary  = Color(0xFF6B6B88); // mute  tertiary
  static const Color textDisabled  = Color(0xFF41415A); // faint  disabled

  //  Gradients 
  static const LinearGradient ctaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cyan, cyanDim],
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

  //  Spacing scale (4-pt grid) 
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

  //  Corner radii (3-value system) 
  // Rule: 6 = atom (chips, tags), 10 = container (cards, inputs), 100 = pill
  // No other values are canonical. Use the nearest canonical value.
  static const double radiusXs   = 6;    // atom
  static const double radiusSm   = 10;   // container
  static const double radiusPill = 100;  // pill / identity chip

  // Deprecated aliases  kept for backward compat, all resolve to radiusSm
  static const double radiusMd   = radiusSm;
  static const double radiusLg   = radiusSm;
  static const double radiusXl   = radiusSm;

  static const BorderRadius brXs   = BorderRadius.all(Radius.circular(radiusXs));
  static const BorderRadius brSm   = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius brMd   = brSm;
  static const BorderRadius brLg   = brSm;
  static const BorderRadius brXl   = brSm;
  static const BorderRadius brPill = BorderRadius.all(Radius.circular(radiusPill));

  //  Motion (durations + curves) 
  static const Duration motionFast     = Duration(milliseconds: 120); // state change
  static const Duration motionNormal   = Duration(milliseconds: 240); // surface transition
  static const Duration motionSlow     = Duration(milliseconds: 400); // choreography
  static const Duration motionEntrance = Duration(milliseconds: 640); // signature entrance

  static const Curve curveEmphasized = Cubic(0.2, 0.0, 0.0, 1.0); // M3 emphasized
  static const Curve curveEnter      = Cubic(0.0, 0.0, 0.2, 1.0); // content reveal
  static const Curve curveExit       = Cubic(0.4, 0.0, 1.0, 1.0); // swift dismiss
  static const Curve curveStandard   = Cubic(0.4, 0.0, 0.2, 1.0); // symmetric

  //  Touch targets 
  static const double minTapTarget = 44; // WCAG / Apple HIG / MD3 minimum

  //  Hairlines 
  static const BorderSide hairline = BorderSide(color: outline, width: 1);
  static Border get cardBorder => Border.all(color: outline, width: 1);

  //  Genie beam glow  the ONLY permitted shadow in the app 
  // All other BoxShadow use is prohibited. Replace with luminance lift.
  static const List<BoxShadow> glowGenie = [
    BoxShadow(color: genieSoft, blurRadius: 24, spreadRadius: 0),
  ];
}

/// Brand-aligned text style ramp.
///
/// Fonts: Space Grotesk (display/headings)  IBM Plex Sans (body)  IBM Plex Mono (code/numbers)
/// Use [IveType] for the full typed ramp. This class is for quick raw access.
@immutable
class BrandText {
  const BrandText._();

  static const TextStyle display = TextStyle(
    fontSize: 36, height: 1.15, fontWeight: FontWeight.w700,
    letterSpacing: -0.5, color: Brand.textPrimary,
  );
  static const TextStyle h1 = TextStyle(
    fontSize: 28, height: 1.2, fontWeight: FontWeight.w700,
    letterSpacing: -0.3, color: Brand.textPrimary,
  );
  static const TextStyle h2 = TextStyle(
    fontSize: 22, height: 1.25, fontWeight: FontWeight.w600,
    letterSpacing: -0.2, color: Brand.textPrimary,
  );
  static const TextStyle h3 = TextStyle(
    fontSize: 18, height: 1.3, fontWeight: FontWeight.w600,
    color: Brand.textPrimary,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16, height: 1.45, fontWeight: FontWeight.w400,
    color: Brand.textPrimary,
  );
  static const TextStyle body = TextStyle(
    fontSize: 14, height: 1.5, fontWeight: FontWeight.w400,
    color: Brand.textSecondary,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12, height: 1.45, fontWeight: FontWeight.w400,
    color: Brand.textTertiary,
  );
  static const TextStyle mono = TextStyle(
    fontSize: 14, height: 1.3, fontWeight: FontWeight.w400,
    color: Brand.textPrimary,
    fontFamily: 'monospace',
  );
  static const TextStyle caption = TextStyle(
    fontSize: 11, height: 1.3, fontWeight: FontWeight.w500,
    letterSpacing: 0.4, color: Brand.textTertiary,
  );
}
