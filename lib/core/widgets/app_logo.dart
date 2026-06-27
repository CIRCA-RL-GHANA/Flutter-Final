import 'package:flutter/material.dart';
import 'hex_mark.dart';

// Kept for call-site backward compat; variant has no visual effect on the hex mark.
enum AppLogoVariant { auto, light, dark }

/// Commerce OS brand mark wrapper.
/// Use [AppLogo.icon] for the hex mark. [glow] adds the splash-screen radial aura.
class AppLogo extends StatelessWidget {
  final double size;
  final bool glow;
  final String? semanticsLabel;

  const AppLogo._({
    required this.size,
    this.glow = false,
    this.semanticsLabel,
  });

  const AppLogo.icon({
    Key? key,
    double size = 64,
    AppLogoVariant variant = AppLogoVariant.auto,
    bool glow = false,
    String? semanticsLabel,
  }) : this._(size: size, glow: glow, semanticsLabel: semanticsLabel);

  // Kept for API completeness — renders the mark only (no text lockup needed).
  const AppLogo.wordmark({
    Key? key,
    double size = 48,
    AppLogoVariant variant = AppLogoVariant.auto,
    String? semanticsLabel,
  }) : this._(size: size, semanticsLabel: semanticsLabel);

  @override
  Widget build(BuildContext context) {
    return HexMark(
      size: size,
      glow: glow,
      semanticsLabel: semanticsLabel ?? 'Commerce OS',
    );
  }
}
