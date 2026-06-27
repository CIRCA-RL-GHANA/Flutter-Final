import 'package:flutter/material.dart';
import '../theme/brand.dart';

/// Applied design tokens for PROMPT Genie.
///
/// [Brand] is the raw palette. [IveTokens] is what we actually ship:
/// the specific colors, radii, spacing, and motion we use on every surface.
///
/// Single import: `import 'package:thepg/core/design/ive.dart';`
@immutable
class IveTokens {
  const IveTokens._();

  //  Background / Void 
  static const Color bg            = Brand.bg;          // #08080F  deepest void
  static const Color void2         = Brand.void2;       // #0B0B14  near-void
  static const Color surface       = Brand.bgElevated;  // #0E0E1A  cards, sheets
  static const Color surfaceRaised = Brand.bgRaised;    // #14141F  modals, headers
  static const Color hairline      = Brand.outline;     // #1C1C2E  borders
  static const Color hairline2     = Brand.outline2;    // #26263A  stronger borders

  //  Text 
  static const Color label         = Brand.textPrimary;    // #E8E8F0  ink
  static const Color labelSecondary = Brand.textSecondary; // #A6A6BE  ink-2
  static const Color labelTertiary  = Brand.textTertiary;  // #6B6B88  mute
  static const Color labelDisabled  = Brand.textDisabled;  // #41415A  faint

  // Short-form aliases (spec names)
  static const Color ink   = Brand.textPrimary;
  static const Color ink2  = Brand.textSecondary;
  static const Color mute  = Brand.textTertiary;
  static const Color faint = Brand.textDisabled;

  //  System Accent (indigo) 
  static const Color accent        = Brand.cyan;      // #4361EE
  static const Color accentPressed = Brand.cyanDim;   // #3451D1
  static const Color accentSoft    = Brand.cyanGlow;  // 15% indigo

  //  Genie Warm (gold  one per screen, APRIL is the exception) 
  static const Color genie       = Brand.gold;       // #C9A84C
  static const Color genieBright = Brand.goldBright; // #E6C766
  static const Color genieSoft   = Brand.genieSoft;  // 10% gold tint
  static const Color genieLine   = Brand.genieLine;  // 27% gold border

  //  Signals 
  static const Color success = Brand.success; // #34D399  ok
  static const Color warning = Brand.warning; // #F5B544  warn
  static const Color danger  = Brand.danger;  // #F26D6D  bad
  static const Color info    = Brand.info;    // #5BA8E8  informational

  //  Spacing (4-pt grid) 
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

  //  Corner radii  3 values only 
  // 6  = atom       chips, tags, small controls
  // 10 = container  cards, inputs, buttons, sheets
  // 100 = pill      identity chips, toggles
  static const double rXs   = 6;
  static const double rSm   = 10;
  static const double rPill = 100;

  // Backward-compat aliases  all resolve to canonical values
  static const double rMd = rSm;
  static const double rLg = rSm;

  static const BorderRadius brXs   = BorderRadius.all(Radius.circular(rXs));
  static const BorderRadius brSm   = BorderRadius.all(Radius.circular(rSm));
  static const BorderRadius brMd   = brSm;
  static const BorderRadius brLg   = brSm;
  static const BorderRadius brPill = BorderRadius.all(Radius.circular(rPill));

  //  Motion 
  static const Duration dMicro = Duration(milliseconds: 120); // state change
  static const Duration dFast  = Duration(milliseconds: 200); // quick feedback
  static const Duration dBase  = Duration(milliseconds: 240); // surface transition
  static const Duration dSlow  = Duration(milliseconds: 400); // choreography

  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve enter      = Cubic(0.0, 0.0, 0.2, 1.0);
  static const Curve exit       = Cubic(0.4, 0.0, 1.0, 1.0);
  static const Curve standard   = Cubic(0.4, 0.0, 0.2, 1.0);

  //  Touch target 
  static const double tap = 44;

  //  Page padding 
  static const EdgeInsets pagePadding =
      EdgeInsets.symmetric(horizontal: s5, vertical: s4);
  static const EdgeInsets pagePaddingTight =
      EdgeInsets.symmetric(horizontal: s4, vertical: s3);

  //  Content width 
  static const double maxContentWidth = 760;

  //  Hairline helpers 
  static const BorderSide hairlineSide = BorderSide(color: hairline, width: 1);
  static Border get cardBorder => Border.all(color: hairline, width: 1);

  //  Luminance lift  replaces ALL BoxShadow (Move 03) 
  // Apply topHighlight as a LinearGradient top stop on raised surfaces.
  // The only permitted true shadow is genieBeamGlow.
  static const Color topHighlight = Color(0x0FFFFFFF); // 6% white
  static const List<BoxShadow> genieBeamGlow = Brand.glowGenie;

  //  Module accent palette 
  static const Color moduleGo         = Color(0xFFFFD27A); // golden   finance
  static const Color moduleMarket     = Color(0xFF6FA8FF); // blue     commerce
  static const Color moduleLive       = Color(0xFF34D399); // green    logistics
  static const Color moduleUpdates    = Color(0xFFB591FF); // violet   social
  static const Color moduleAlerts     = Color(0xFFFBBF24); // amber    attention
  static const Color moduleUser       = Color(0xFF22D3EE); // cyan     identity
  static const Color moduleSetup      = Color(0xFF818CF8); // indigo   config
  static const Color moduleUtility    = Color(0xFF9BA3AE); // neutral  tools
  static const Color moduleQualChat   = Color(0xFF4ECFE1); // teal     chat
  static const Color moduleApril      = Color(0xFFFFB14E); // sunrise  personal AI
  static const Color moduleEplay      = Color(0xFFB591FF); // violet   entertainment
  static const Color moduleCommunity  = Color(0xFF4FC4D9); // aqua     collective
  static const Color moduleFintech    = Color(0xFF5BE0C2); // mint     capital
  static const Color moduleEnterprise = Color(0xFFC99B2C); // gold     enterprise

  static const Map<String, Color> moduleColors = {
    'go':             moduleGo,
    'goPage':         moduleGo,
    'market':         moduleMarket,
    'live':           moduleLive,
    'updates':        moduleUpdates,
    'myUpdates':      moduleUpdates,
    'alerts':         moduleAlerts,
    'user':           moduleUser,
    'userDetails':    moduleUser,
    'setup':          moduleSetup,
    'setupDashboard': moduleSetup,
    'utility':        moduleUtility,
    'qualChat':       moduleQualChat,
    'qualchat':       moduleQualChat,
    'april':          moduleApril,
    'eplay':          moduleEplay,
    'community':      moduleCommunity,
    'fintech':        moduleFintech,
    'enterprise':     moduleEnterprise,
  };

  static Color moduleColor(String key) => moduleColors[key] ?? accent;

  //  Spec-name aliases  used by pre-built components 
  // These mirror the canonical tokens above under the names used in
  // genie_strip, ive_empty_state, value_display, verify_sheet, etc.
  // Do not add new code using these; prefer the canonical names above.
  static const Color voidColor    = bg;
  static const Color void2Color   = void2;
  static const Color surfaceColor = surface;
  static const Color raisedColor  = surfaceRaised;
  static const Color hairColor    = hairline;
  static const Color hair2Color   = hairline2;
  static const Color accentColor    = accent;
  static const Color accentSoftBlue = accentSoft;
  static const Color genieColor   = genie;
  static const Color inkColor     = ink;
  static const Color ink2Color    = ink2;
  static const Color muteColor    = mute;
  static const Color faintColor   = faint;
  static const Color okColor      = success;
  static const Color warnColor    = warning;
  static const Color badColor     = danger;
  static const Color infoColor    = info;
  static const double rAtom      = rXs;
  static const double rContainer = rSm;
  static const double rChip      = rPill;
}
