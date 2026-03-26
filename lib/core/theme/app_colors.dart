import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF1A237E);
  static const Color primaryLight = Color(0xFF3F51B5);
  static const Color primaryDark = Color(0xFF0F0F23);
  static const Color secondary = Color(0xFF2D1B69);

  // Accent / CTA Colors
  static const Color accent = Color(0xFFFFD700);
  static const Color accentDark = Color(0xFFFFA000);
  static const Color ctaGradientStart = Color(0xFFFFD700);
  static const Color ctaGradientEnd = Color(0xFFFFA000);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF8F9FE);
  static const Color backgroundDark = Color(0xFF0F0F23);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E30);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textPrimaryDark = Color(0xFFF5F5F5);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // Input Colors
  static const Color inputFill = Color(0xFFF3F4F6);
  static const Color inputFillDark = Color(0xFF2A2A3E);
  static const Color inputBorder = Color(0xFFE5E7EB);
  static const Color inputBorderFocused = Color(0xFF3F51B5);

  // State Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Validation Colors
  static const Color validationEmpty = Color(0xFFD1D5DB);
  static const Color validationTyping = Color(0xFF3B82F6);
  static const Color validationValid = Color(0xFF10B981);
  static const Color validationInvalid = Color(0xFFEF4444);

  // Onboarding Gradient Colors
  static const Color splashGradient1 = Color(0xFF0F0F23);
  static const Color splashGradient2 = Color(0xFF2D1B69);
  static const Color splashGradient3 = Color(0xFF1A237E);

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

  // Shimmer
  static const Color shimmerBase = Color(0xFFE5E7EB);
  static const Color shimmerHighlight = Color(0xFFF3F4F6);

  // Confetti
  static const List<Color> confettiColors = [
    Color(0xFFFFD700),
    Color(0xFF3F51B5),
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
