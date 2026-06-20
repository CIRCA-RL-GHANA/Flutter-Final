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

  // ─── Responsive content width ─────────────────────────────────────────
  /// Maximum readable content width on tablet / desktop / PWA. Beyond this,
  /// content should be centered, never stretched. A single column of prose
  /// or a focused dashboard reads best at ≤ 760 px.
  static const double maxContentWidth = 760;

  // ─── Hairline border helpers ──────────────────────────────────────────
  static const BorderSide hairlineSide = BorderSide(color: hairline, width: 1);
  static Border get cardBorder => Border.all(color: hairline, width: 1);

  // ─── Module accent palette (single source of truth) ───────────────────
  /// One restrained accent per top-level module. Use this instead of
  /// inline hex values anywhere a module needs to be visually distinguished
  /// (cards, badges, accents). Order is intentional: golden = action,
  /// blue = information, green = motion, indigo = system.
  static const Color moduleGo         = Color(0xFFFFD27A); // golden  — action
  static const Color moduleMarket     = Color(0xFF6FA8FF); // blue    — information
  static const Color moduleLive       = Color(0xFF34D399); // green   — motion
  static const Color moduleUpdates    = Color(0xFFB591FF); // violet  — narrative
  static const Color moduleAlerts     = Color(0xFFFBBF24); // amber   — attention
  static const Color moduleUser       = Color(0xFF22D3EE); // cyan    — self
  static const Color moduleSetup      = Color(0xFF818CF8); // indigo  — configuration
  static const Color moduleUtility    = Color(0xFF9BA3AE); // neutral — tooling
  static const Color moduleQualChat   = Color(0xFF4ECFE1); // teal    — conversation
  static const Color moduleApril      = Color(0xFFFFB14E); // sunrise — personal AI
  static const Color moduleEplay      = Color(0xFFB591FF); // violet  — entertainment
  static const Color moduleCommunity  = Color(0xFF4FC4D9); // aqua    — collective
  static const Color moduleFintech    = Color(0xFF5BE0C2); // mint    — capital
  static const Color moduleEnterprise = Color(0xFFC99B2C); // gold    — enterprise
  static const Color moduleGenie      = Color(0xFFFFD27A); // golden  — native

  static const Map<String, Color> moduleColors = {
    'go':              moduleGo,
    'goPage':          moduleGo,
    'market':          moduleMarket,
    'live':            moduleLive,
    'updates':         moduleUpdates,
    'myUpdates':       moduleUpdates,
    'alerts':          moduleAlerts,
    'user':            moduleUser,
    'userDetails':     moduleUser,
    'setup':           moduleSetup,
    'setupDashboard':  moduleSetup,
    'utility':         moduleUtility,
    'qualChat':        moduleQualChat,
    'qualchat':        moduleQualChat,
    'april':           moduleApril,
    'eplay':           moduleEplay,
    'community':       moduleCommunity,
    'fintech':         moduleFintech,
    'enterprise':      moduleEnterprise,
    'genie':           moduleGenie,
  };

  /// Resolves a module's canonical accent by key. Unknown keys fall back to
  /// the brand accent so the UI never paints a missing module in a raw hex.
  static Color moduleColor(String key) => moduleColors[key] ?? accent;

  // ─── Commerce OS Color System — Perfection Pass (Phase 1) ─────────────────
  // Cold (System) — deep dark surfaces with luminance steps
  static const Color voidColor    = Color(0xFF08080F); // deepest void (= bg)
  static const Color void2Color   = Color(0xFF0B0B14); // near-void overlay
  static const Color surfaceColor = Color(0xFF0E0E1A); // default surface
  static const Color raisedColor  = Color(0xFF14141F); // raised card / modal
  static const Color hairColor    = Color(0xFF1C1C2E); // hairline divider
  static const Color hair2Color   = Color(0xFF26263A); // stronger divider
  static const Color accentColor  = Color(0xFF4361EE); // primary action blue
  static const Color accentSoftBlue = Color(0x264361EE); // blue ambient glow

  // Warm (Genie) — RESERVED for Genie intelligence layer only
  static const Color genieColor  = Color(0xFFC9A84C); // Genie gold
  static const Color genieBright = Color(0xFFE6C766); // Genie highlight
  static const Color genieSoft   = Color(0x1AC9A84C); // Genie ambient bg
  static const Color genieLine   = Color(0x44C9A84C); // Genie border

  // Semantic signals
  static const Color okColor   = Color(0xFF34D399); // success / ok
  static const Color warnColor = Color(0xFFF5B544); // warning
  static const Color badColor  = Color(0xFFF26D6D); // error / danger
  static const Color infoColor = Color(0xFF5BA8E8); // information

  // Ink hierarchy (text)
  static const Color inkColor   = Color(0xFFE8E8F0); // primary (integers)
  static const Color ink2Color  = Color(0xFFA6A6BE); // secondary (decimals)
  static const Color muteColor  = Color(0xFF6B6B88); // muted (units, labels)
  static const Color faintColor = Color(0xFF41415A); // faint (disabled)

  // ─── Luminance lift (replaces shadows — Move 03) ──────────────────────────
  /// Top inner highlight simulates surface elevation without any BoxShadow.
  /// Apply as a LinearGradient top stop on raised surfaces.
  static const Color topHighlight = Color(0x0FFFFFFF); // white ~6 %

  // ─── Canonical radius system (Perfection Pass audit — Move 01) ────────────
  /// Atoms: chips, tags, small buttons.
  static const double rAtom      = 6.0;
  /// Containers: inputs, cards, list rows, sheets.
  static const double rContainer = 10.0;
  /// Pills: fully rounded (large chips, toggles).
  static const double rChip      = 100.0;
}
