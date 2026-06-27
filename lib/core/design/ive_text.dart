import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ive_tokens.dart';

/// Typography system for PROMPT Genie.
///
/// Three fonts, each with a purpose:
/// - Space Grotesk    display, headings (geometric, confident)
/// - IBM Plex Sans    body, detail (readable, neutral, warm)
/// - IBM Plex Mono    numbers, codes, mono labels (tabular, precise)
///
/// Five tiers: display / title / body / detail / mono
/// No Material heading lottery  every style has one meaning.
@immutable
class IveType {
  const IveType._();

  //  Size constants 
  static const double dDisplay  = 34;
  static const double dTitle1   = 28;
  static const double dTitle2   = 22;
  static const double dTitle3   = 18;
  static const double dHeadline = 16;
  static const double dBody     = 15;
  static const double dCallout  = 14;
  static const double dSubhead  = 13;
  static const double dFootnote = 12;
  static const double dCaption  = 11;
  static const double dMono     = 14;

  //  Font builders 

  static TextStyle _grotesk(
    double size,
    FontWeight w, {
    Color color = IveTokens.label,
    double letter = 0,
    double height = 1.25,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: w,
        color: color,
        letterSpacing: letter,
        height: height,
      );

  static TextStyle _plex(
    double size,
    FontWeight w, {
    Color color = IveTokens.label,
    double letter = 0,
    double height = 1.4,
  }) =>
      GoogleFonts.ibmPlexSans(
        fontSize: size,
        fontWeight: w,
        color: color,
        letterSpacing: letter,
        height: height,
      );

  static TextStyle _mono(
    double size,
    FontWeight w, {
    Color color = IveTokens.label,
    double letter = 0,
    double height = 1.3,
    List<FontFeature>? features,
  }) =>
      GoogleFonts.ibmPlexMono(
        fontSize: size,
        fontWeight: w,
        color: color,
        letterSpacing: letter,
        height: height,
        fontFeatures: features ?? [const FontFeature.tabularFigures()],
      );

  //  Display & titles (Space Grotesk) 
  static TextStyle get display  => _grotesk(dDisplay,  FontWeight.w700, letter: -0.6, height: 1.1);
  static TextStyle get title1   => _grotesk(dTitle1,   FontWeight.w700, letter: -0.4, height: 1.15);
  static TextStyle get title2   => _grotesk(dTitle2,   FontWeight.w600, letter: -0.2, height: 1.2);
  static TextStyle get title3   => _grotesk(dTitle3,   FontWeight.w600, letter: -0.1, height: 1.25);
  static TextStyle get headline => _grotesk(dHeadline, FontWeight.w600, height: 1.3);

  //  Body (IBM Plex Sans) 
  static TextStyle get body         => _plex(dBody,    FontWeight.w400, height: 1.5);
  static TextStyle get bodyEmphasis => _plex(dBody,    FontWeight.w600, height: 1.5);
  static TextStyle get callout      => _plex(dCallout, FontWeight.w400, color: IveTokens.labelSecondary, height: 1.45);
  static TextStyle get subhead      => _plex(dSubhead, FontWeight.w500, color: IveTokens.labelSecondary, letter: 0.1, height: 1.35);
  static TextStyle get footnote     => _plex(dFootnote, FontWeight.w400, color: IveTokens.labelSecondary, height: 1.35);
  static TextStyle get caption      => _plex(dCaption, FontWeight.w500, color: IveTokens.labelTertiary, letter: 0.4, height: 1.3);

  //  Mono (IBM Plex Mono)  numbers, codes, system labels 
  // Always tabular figures for financial values (prevents reflow on update).
  static TextStyle get mono        => _mono(dMono,     FontWeight.w400);
  static TextStyle get monoEmphasis => _mono(dMono,    FontWeight.w600);
  static TextStyle get monoSmall   => _mono(dFootnote, FontWeight.w400, color: IveTokens.labelSecondary);
  static TextStyle get monoCaps    => _mono(dCaption,  FontWeight.w600, letter: 0.8, color: IveTokens.labelTertiary);

  //  Material TextTheme binding 
  static TextTheme buildTextTheme() => TextTheme(
    displayLarge:   display,
    displayMedium:  title1,
    displaySmall:   title2,
    headlineLarge:  title1,
    headlineMedium: title2,
    headlineSmall:  title3,
    titleLarge:     title3,
    titleMedium:    headline,
    titleSmall:     bodyEmphasis,
    bodyLarge:      body,
    bodyMedium:     callout,
    bodySmall:      footnote,
    labelLarge:     subhead,
    labelMedium:    footnote,
    labelSmall:     caption,
  );
}
