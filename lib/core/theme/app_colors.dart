import 'package:flutter/material.dart';

import '../design/ive_tokens.dart';

/// Legacy palette API — preserved verbatim by name so hundreds of existing
/// screens keep compiling. Every token now resolves to an [IveTokens] value
/// so the entire app inherits the Jony-Ive dark-first system at once.
///
/// New code should import `package:thepg/core/design/ive.dart` directly and
/// use `IveTokens` / `IveType`. This shim exists purely for migration.
class AppColors {
  AppColors._();

  // ── Primary Brand ──────────────────────────────────────────────────────
  static const Color primary       = IveTokens.accent;        // brand cyan
  static const Color primaryLight  = IveTokens.accent;
  static const Color primaryDark   = IveTokens.bg;
  static const Color secondary     = Color(0xFFC99B2C);       // brand gold (preserved — distinct semantic)

  // ── Accent / CTA (brand gold ramp retained) ────────────────────────────
  static const Color accent           = Color(0xFFC99B2C);
  static const Color accentDark       = Color(0xFFB5871A);
  static const Color ctaGradientStart = Color(0xFFE5B743);
  static const Color ctaGradientEnd   = Color(0xFFC99B2C);

  // ── Background / Surface ───────────────────────────────────────────────
  static const Color backgroundLight = IveTokens.bg;          // dark-first
  static const Color backgroundDark  = IveTokens.bg;
  static const Color surfaceLight    = IveTokens.surface;
  static const Color surfaceDark     = IveTokens.surfaceRaised;

  // ── Text ───────────────────────────────────────────────────────────────
  static const Color textPrimary       = IveTokens.label;
  static const Color textSecondary     = IveTokens.labelSecondary;
  static const Color textTertiary      = IveTokens.labelTertiary;
  static const Color textPrimaryDark   = IveTokens.label;
  static const Color textSecondaryDark = IveTokens.labelSecondary;

  // ── Inputs ─────────────────────────────────────────────────────────────
  static const Color inputFill          = IveTokens.surface;
  static const Color inputFillDark      = IveTokens.surfaceRaised;
  static const Color inputBorder        = IveTokens.hairline;
  static const Color inputBorderFocused = IveTokens.accent;

  // ── Semantic state ─────────────────────────────────────────────────────
  static const Color success = IveTokens.success;
  static const Color error   = IveTokens.danger;
  static const Color warning = IveTokens.warning;
  static const Color info    = IveTokens.accent;

  // ── Validation ─────────────────────────────────────────────────────────
  static const Color validationEmpty   = IveTokens.hairline;
  static const Color validationTyping  = IveTokens.accent;
  static const Color validationValid   = IveTokens.success;
  static const Color validationInvalid = IveTokens.danger;

  // Onboarding Gradient Colors — brand-dark ramp (matches Brand.bg → bgRaised)
  static const Color splashGradient1 = Color(0xFF08080F);
  static const Color splashGradient2 = Color(0xFF11131C);
  static const Color splashGradient3 = Color(0xFF181B27);

  // Role Card Colors
  static const Color roleBuyer = Color(0xFF7C3AED);
  static const Color roleShop = Color(0xFF059669);
  static const Color roleDelivery = Color(0xFFD97706);
  static const Color roleTransport = Color(0xFF2563EB);
  static const Color roleIndividual = Color(0xFF6366F1);
  static const Color roleBusiness = Color(0xFF0891B2);

  // Overlay
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  // Shimmer (dark-first tuned)
  static const Color shimmerBase = IveTokens.surface;
  static const Color shimmerHighlight = IveTokens.surfaceRaised;

  // Confetti
  static const List<Color> confettiColors = [
    Color(0xFFFFD700),
    Color(0xFF22BDD8),
    Color(0xFF10B981),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFFF59E0B),
  ];

  // Gradients
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
