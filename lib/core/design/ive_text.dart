import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ive_tokens.dart';

/// Ive typography.
///
/// Inter — chosen for its neutral, optically tuned mechanics and tight default
/// metrics that mimic SF Pro on small surfaces. We use a narrow, intentional
/// ramp: display / title / body / label / caption. No "headline6" lottery.
@immutable
class IveType {
  const IveType._();

  // Hard-coded sizes in case TextTheme isn't resolved (e.g. in custom paint).
  static const double dDisplay = 34; // hero (rare)
  static const double dTitle1  = 28; // page large title
  static const double dTitle2  = 22; // section
  static const double dTitle3  = 18; // card / subsection
  static const double dHeadline = 16; // list row title
  static const double dBody    = 15;
  static const double dCallout = 14;
  static const double dSubhead = 13;
  static const double dFootnote = 12;
  static const double dCaption = 11;

  static TextStyle _base(double size, FontWeight w, {
    Color color = IveTokens.label,
    double letter = 0,
    double height = 1.25,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: w,
        color: color,
        letterSpacing: letter,
        height: height,
      );

  // ─── Display & titles ─────────────────────────────────────────────────
  static TextStyle get display  => _base(dDisplay, FontWeight.w700, letter: -0.6, height: 1.1);
  static TextStyle get title1   => _base(dTitle1,  FontWeight.w700, letter: -0.4, height: 1.15);
  static TextStyle get title2   => _base(dTitle2,  FontWeight.w600, letter: -0.2, height: 1.2);
  static TextStyle get title3   => _base(dTitle3,  FontWeight.w600, letter: -0.1, height: 1.25);
  static TextStyle get headline => _base(dHeadline, FontWeight.w600, height: 1.3);

  // ─── Body ─────────────────────────────────────────────────────────────
  static TextStyle get body         => _base(dBody, FontWeight.w400, height: 1.45);
  static TextStyle get bodyEmphasis => _base(dBody, FontWeight.w600, height: 1.45);
  static TextStyle get callout      => _base(dCallout, FontWeight.w400,
      color: IveTokens.labelSecondary, height: 1.4);

  // ─── Detail ───────────────────────────────────────────────────────────
  static TextStyle get subhead  => _base(dSubhead, FontWeight.w500,
      color: IveTokens.labelSecondary, letter: 0.1, height: 1.35);
  static TextStyle get footnote => _base(dFootnote, FontWeight.w400,
      color: IveTokens.labelSecondary, height: 1.35);
  static TextStyle get caption  => _base(dCaption, FontWeight.w500,
      color: IveTokens.labelTertiary, letter: 0.4, height: 1.3);

  // ─── Mono (numbers, codes) ────────────────────────────────────────────
  static TextStyle get mono =>
      GoogleFonts.jetBrainsMono(fontSize: dCallout, color: IveTokens.label, height: 1.3);

  // ─── TextTheme bound to Material widgets ──────────────────────────────
  static TextTheme buildTextTheme() {
    return TextTheme(
      displayLarge:  display,
      displayMedium: title1,
      displaySmall:  title2,
      headlineLarge: title1,
      headlineMedium: title2,
      headlineSmall:  title3,
      titleLarge:  title3,
      titleMedium: headline,
      titleSmall:  bodyEmphasis,
      bodyLarge:  body,
      bodyMedium: callout,
      bodySmall:  footnote,
      labelLarge:  subhead,
      labelMedium: footnote,
      labelSmall:  caption,
    );
  }
}
