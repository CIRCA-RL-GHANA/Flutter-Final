import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

/// Canonical brand colors for the genie help mark/wordmark.
class GenieHelpBrand {
  GenieHelpBrand._();
  static const Color dark = Color(0xFF1F2A33);
  static const Color gold = Color(0xFFC99B2C);
  static const Color cyan = Color(0xFF22BDD8);
}

/// Which color palette the icon mark uses.
/// - [AppLogoVariant.light] = dark "g" stroke (use on light backgrounds).
/// - [AppLogoVariant.dark]  = gold "g" stroke (use on dark backgrounds).
/// - [AppLogoVariant.auto]  = pick based on the current [Theme.brightness].
enum AppLogoVariant { auto, light, dark }

/// Reusable genie help logo. Use [AppLogo.icon] for the mark only, or
/// [AppLogo.wordmark] for the mark + "genie help" lockup.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;
  final AppLogoVariant variant;
  final Color? wordmarkPrimaryColor; // overrides "genie" color
  final Color? wordmarkAccentColor;  // overrides "help" color
  final double wordmarkSpacing;
  final String? semanticsLabel;

  const AppLogo._({
    required this.size,
    required this.showWordmark,
    required this.variant,
    this.wordmarkPrimaryColor,
    this.wordmarkAccentColor,
    this.wordmarkSpacing = 10,
    this.semanticsLabel,
  });

  /// Icon-only mark, square box of [size] px.
  const AppLogo.icon({
    Key? key,
    double size = 64,
    AppLogoVariant variant = AppLogoVariant.auto,
    String? semanticsLabel,
  }) : this._(
          size: size,
          showWordmark: false,
          variant: variant,
          semanticsLabel: semanticsLabel,
        );

  /// Mark + "genie help" wordmark side-by-side. [size] is the icon height;
  /// the wordmark scales relative to it.
  const AppLogo.wordmark({
    Key? key,
    double size = 48,
    AppLogoVariant variant = AppLogoVariant.auto,
    Color? primaryColor,
    Color? accentColor,
    double spacing = 10,
    String? semanticsLabel,
  }) : this._(
          size: size,
          showWordmark: true,
          variant: variant,
          wordmarkPrimaryColor: primaryColor,
          wordmarkAccentColor: accentColor,
          wordmarkSpacing: spacing,
          semanticsLabel: semanticsLabel,
        );

  bool _useDarkAsset(BuildContext context) {
    switch (variant) {
      case AppLogoVariant.light:
        return false;
      case AppLogoVariant.dark:
        return true;
      case AppLogoVariant.auto:
        return Theme.of(context).brightness == Brightness.dark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final useDark = _useDarkAsset(context);
    final asset = useDark
        ? 'assets/images/genie_help_icon_dark.svg'
        : 'assets/images/genie_help_icon.svg';

    final mark = SvgPicture.asset(
      asset,
      width: size,
      height: size,
      semanticsLabel: semanticsLabel ?? 'genie help logo',
    );

    if (!showWordmark) return mark;

    final primary = wordmarkPrimaryColor ??
        (useDark ? GenieHelpBrand.gold : GenieHelpBrand.dark);
    final accent = wordmarkAccentColor ?? GenieHelpBrand.cyan;

    // Wordmark sized relative to the icon for a balanced lockup.
    final fontSize = size * 0.58;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        mark,
        SizedBox(width: wordmarkSpacing),
        RichText(
          text: TextSpan(
            style: GoogleFonts.nunito(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              height: 1.0,
              letterSpacing: -0.5,
            ),
            children: [
              TextSpan(text: 'genie ', style: TextStyle(color: primary)),
              TextSpan(text: 'help', style: TextStyle(color: accent)),
            ],
          ),
        ),
      ],
    );
  }
}
