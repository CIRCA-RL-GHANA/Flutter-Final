import 'package:flutter/material.dart';
import '../design/ive_tokens.dart';

/// Legacy color aliases  kept so existing screens compile unchanged.
///
/// New code should use [IveTokens] directly via `ive.dart`.
/// This shim is intentionally thin: every value resolves to an IveTokens entry.
class AppColors {
  AppColors._();

  //  Primary / Accent 
  static const Color primary      = IveTokens.accent;
  static const Color primaryLight = IveTokens.accent;
  static const Color primaryDark  = IveTokens.bg;
  static const Color secondary    = IveTokens.genie;   // warm gold (Genie only)

  //  Accent ramp 
  static const Color accent           = IveTokens.accent;
  static const Color accentDark       = IveTokens.accentPressed;
  static const Color ctaGradientStart = IveTokens.accent;
  static const Color ctaGradientEnd   = IveTokens.accentPressed;

  //  Backgrounds 
  static const Color backgroundLight  = IveTokens.bg;
  static const Color backgroundDark   = IveTokens.bg;
  static const Color surfaceLight     = IveTokens.surface;
  static const Color surfaceDark      = IveTokens.surfaceRaised;

  //  Text 
  static const Color textPrimary       = IveTokens.label;
  static const Color textSecondary     = IveTokens.labelSecondary;
  static const Color textTertiary      = IveTokens.labelTertiary;
  static const Color textPrimaryDark   = IveTokens.label;
  static const Color textSecondaryDark = IveTokens.labelSecondary;

  //  Inputs 
  static const Color inputFill          = IveTokens.surface;
  static const Color inputFillDark      = IveTokens.surfaceRaised;
  static const Color inputBorder        = IveTokens.hairline;
  static const Color inputBorderFocused = IveTokens.accent;

  //  Semantic 
  static const Color success = IveTokens.success;
  static const Color error   = IveTokens.danger;
  static const Color warning = IveTokens.warning;
  static const Color info    = IveTokens.info;

  //  Validation states 
  static const Color validationEmpty   = IveTokens.hairline;
  static const Color validationTyping  = IveTokens.accent;
  static const Color validationValid   = IveTokens.success;
  static const Color validationInvalid = IveTokens.danger;

  //  Splash gradient 
  static const Color splashGradient1 = Color(0xFF08080F);
  static const Color splashGradient2 = Color(0xFF0E0E1A);
  static const Color splashGradient3 = Color(0xFF14141F);

  //  Role colors 
  static const Color roleBuyer      = Color(0xFF7C3AED);
  static const Color roleShop       = Color(0xFF059669);
  static const Color roleDelivery   = Color(0xFFD97706);
  static const Color roleTransport  = Color(0xFF2563EB);
  static const Color roleIndividual = Color(0xFF6366F1);
  static const Color roleBusiness   = Color(0xFF0891B2);

  //  Overlay 
  static const Color overlay      = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  //  Shimmer (content-shaped skeleton) 
  static const Color shimmerBase      = IveTokens.surface;
  static const Color shimmerHighlight = IveTokens.surfaceRaised;

  //  Confetti  blue + green only (no gold per Move 02) 
  static const List<Color> confettiColors = [
    Color(0xFF4361EE), // indigo
    Color(0xFF22D3EE), // cyan
    Color(0xFF34D399), // green
    Color(0xFF5BA8E8), // info blue
    Color(0xFF818CF8), // soft indigo
    Color(0xFF6FA8FF), // market blue
  ];

  //  Gradients 
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [splashGradient1, splashGradient2, splashGradient3],
  );

  static const LinearGradient ctaGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [ctaGradientStart, ctaGradientEnd],
  );

  static const LinearGradient overlayGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [overlay, Colors.transparent],
  );
}
