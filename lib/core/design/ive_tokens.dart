import 'package:flutter/material.dart';
import '../theme/brand.dart';

/// Ive design tokens.
///
/// A thin, opinionated layer over [Brand] that captures the Jony Ive design
/// philosophy: reduction, honesty, clarity. Use these in preference to raw
/// hex colors or magic numbers when authoring new UI.
///
/// Where [Brand] is the raw palette, [IveTokens] is the *applied* system:
/// the specific corner radii, the specific spacings, the specific motion
/// curves we choose to ship in every screen.
@immutable
class IveTokens {
  const IveTokens._();

  // ─── Surfaces ─────────────────────────────────────────────────────────
  /// Page background. The deepest level.
  static const Color bg = Brand.bg;
  /// Card / sheet / grouped-list background.
  static const Color surface = Brand.bgElevated;
  /// Raised surface (modal, sticky header).
  static const Color surfaceRaised = Brand.bgRaised;
  /// Hairline border / divider.
  static const Color hairline = Brand.outline;

  // ─── Foreground ───────────────────────────────────────────────────────
  static const Color label = Brand.textPrimary;       // primary text
  static const Color labelSecondary = Brand.textSecondary;
  static const Color labelTertiary = Brand.textTertiary;
  static const Color labelDisabled = Brand.textDisabled;

  // ─── Accent (single color of attention) ───────────────────────────────
  static const Color accent = Brand.cyan;
  static const Color accentPressed = Brand.cyanDim;
  static const Color accentSoft = Brand.cyanGlow;

  // ─── Semantic ─────────────────────────────────────────────────────────
  static const Color success = Brand.success;
  static const Color warning = Brand.warning;
  static const Color danger  = Brand.danger;

  // ─── Geometry (8-pt grid) ─────────────────────────────────────────────
  static const double s1  = 4;
  static const double s2  = 8;
  static const double s3  = 12;
  static const double s4  = 16;
  static const double s5  = 20;
  static const double s6  = 24;
  static const double s7  = 28;
  static const double s8  = 32;
  static const double s10 = 40;
  static const double s12 = 48;
  static const double s14 = 56;
  static const double s16 = 64;

  // ─── Corner radii (tight, mechanical) ─────────────────────────────────
  /// Inline controls (chips, small buttons).
  static const double rXs = 6;
  /// Inputs, cards, list rows.
  static const double rSm = 10;
  /// Buttons, sheets.
  static const double rMd = 12;
  /// Large surfaces, hero cards.
  static const double rLg = 16;
  /// Pill / fully rounded.
  static const double rPill = 999;

  static const BorderRadius brXs = BorderRadius.all(Radius.circular(rXs));
  static const BorderRadius brSm = BorderRadius.all(Radius.circular(rSm));
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(rMd));
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(rLg));
  static const BorderRadius brPill = BorderRadius.all(Radius.circular(rPill));

  // ─── Motion ───────────────────────────────────────────────────────────
  static const Duration dMicro = Duration(milliseconds: 120);
  static const Duration dFast  = Duration(milliseconds: 200);
  static const Duration dBase  = Duration(milliseconds: 320);
  static const Duration dSlow  = Duration(milliseconds: 480);

  /// Apple-feel emphasized curve.
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve enter      = Cubic(0.0, 0.0, 0.2, 1.0);
  static const Curve exit       = Cubic(0.4, 0.0, 1.0, 1.0);
  static const Curve standard   = Cubic(0.4, 0.0, 0.2, 1.0);

  // ─── Touch target ─────────────────────────────────────────────────────
  static const double tap = 44;

  // ─── Page padding ─────────────────────────────────────────────────────
  static const EdgeInsets pagePadding =
      EdgeInsets.symmetric(horizontal: s5, vertical: s4);
  static const EdgeInsets pagePaddingTight =
      EdgeInsets.symmetric(horizontal: s4, vertical: s3);

  // ─── Hairline border helpers ──────────────────────────────────────────
  static const BorderSide hairlineSide = BorderSide(color: hairline, width: 1);
  static Border get cardBorder => Border.all(color: hairline, width: 1);
}
