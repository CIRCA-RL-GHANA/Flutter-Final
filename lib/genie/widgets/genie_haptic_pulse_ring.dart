/// ═══════════════════════════════════════════════════════════════════════════
/// GenieHapticPulseRing
///
/// Visual pulse ring that animates in sync with [GenieHapticRoleSignature].
/// Wraps any child widget (avatar, input field, card) with a colour-matched
/// glow that fires once per role-signature event and fades out gracefully.
///
/// Recommendation 1 — "Visual Pulse" fallback for devices without vibration.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../genie_haptic_role_signature.dart';
import '../../features/prompt/models/rbac_models.dart';

class GenieHapticPulseRing extends StatefulWidget {
  final Widget child;

  /// If provided, overrides the role derived from the haptic stream for the
  /// initial pulse color (useful for always-visible avatars).
  final UserRole? staticRole;

  const GenieHapticPulseRing({
    super.key,
    required this.child,
    this.staticRole,
  });

  @override
  State<GenieHapticPulseRing> createState() => _GenieHapticPulseRingState();
}

class _GenieHapticPulseRingState extends State<GenieHapticPulseRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  Color _color = const Color(0xFF3F51B5);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _scale = Tween<double>(begin: 1.0, end: 1.22).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacity = Tween<double>(begin: 0.72, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Subscribe to role signature pulses
    GenieHapticRoleSignature.pulseStream.listen(_onPulse);
  }

  void _onPulse(RoleSignalEvent event) {
    if (!mounted) return;
    setState(() => _color = event.pulseColor);
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Glow ring behind the child
            if (_controller.isAnimating || _controller.value > 0)
              Opacity(
                opacity: _opacity.value,
                child: Transform.scale(
                  scale: _scale.value,
                  child: Container(
                    // Size matches the child via LayoutBuilder inside child
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _color.withOpacity(0.65),
                          blurRadius: 18,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                    child: child,
                  ),
                ),
              ),
            // The actual content — always rendered above the ring
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}
