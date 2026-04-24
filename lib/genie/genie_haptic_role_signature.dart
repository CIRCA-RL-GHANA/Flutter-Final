/// ═══════════════════════════════════════════════════════════════════════════
/// GenieHapticRoleSignature
///
/// Bridges haptic feedback, PWA Vibration API polyfill, role-distinct audio
/// earcons, and visual pulse events into a single cohesive signal per role.
///
/// Recommendation 1 implementation:
///   • Native: uses Flutter HapticFeedback with role-distinct patterns
///   • PWA / Web: maps patterns to navigator.vibrate() payloads
///   • Audio: Web Audio API earcons (owner / admin / driver / default)
///   • Visual: exposes a Stream<RoleSignalEvent> for the pulse ring widget
/// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../features/prompt/models/rbac_models.dart';
import 'platform/haptic_platform_stub.dart'
    if (dart.library.html) 'platform/haptic_platform_web.dart';

/// Payload emitted on the [GenieHapticRoleSignature.pulseStream] whenever a
/// role signature fires. The pulse ring widget listens to this stream.
class RoleSignalEvent {
  final UserRole role;
  final Color pulseColor;

  const RoleSignalEvent({required this.role, required this.pulseColor});
}

class GenieHapticRoleSignature {
  GenieHapticRoleSignature._();

  // ─── Configuration ────────────────────────────────────────────────────────
  static bool _hapticsEnabled = true;
  static bool _audioEnabled = true;

  static void configure({bool? haptics, bool? audio}) {
    if (haptics != null) _hapticsEnabled = haptics;
    if (audio != null) _audioEnabled = audio;
  }

  // ─── Visual Pulse Stream ──────────────────────────────────────────────────
  static final StreamController<RoleSignalEvent> _pulseController =
      StreamController<RoleSignalEvent>.broadcast();

  /// Listen to this stream to animate the pulse ring in sync with haptics.
  static Stream<RoleSignalEvent> get pulseStream => _pulseController.stream;

  // ─── Role → Vibration Patterns ───────────────────────────────────────────
  /// PWA vibration patterns expressed as [on, off, on, off …] milliseconds.
  ///
  ///   Owner        → short-short-long:    80,60,80,60,220
  ///   Administrator→ two fast bursts:     60,50,60
  ///   Driver       → single long gentle:  180
  ///   Branch roles → medium double pulse: 100,80,100
  ///   Default      → single medium:       120
  static List<int> _vibrationPattern(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return [80, 60, 80, 60, 220];
      case UserRole.administrator:
        return [60, 50, 60];
      case UserRole.driver:
        return [180];
      case UserRole.branchManager:
      case UserRole.branchResponseOfficer:
      case UserRole.branchMonitor:
      case UserRole.branchSocialOfficer:
        return [100, 80, 100];
      default:
        return [120];
    }
  }

  // ─── Role → Native Haptic Sequence ───────────────────────────────────────
  static Future<void> _nativePattern(UserRole role) async {
    switch (role) {
      case UserRole.owner:
        // short-short-long: matches PWA pattern above
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 60));
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 60));
        await HapticFeedback.heavyImpact();
      case UserRole.administrator:
        // two fast bursts
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 50));
        await HapticFeedback.mediumImpact();
      case UserRole.driver:
        // single long gentle pulse — selectionClick is the softest available
        await HapticFeedback.selectionClick();
        await Future.delayed(const Duration(milliseconds: 80));
        await HapticFeedback.lightImpact();
      case UserRole.branchManager:
      case UserRole.branchResponseOfficer:
      case UserRole.branchMonitor:
      case UserRole.branchSocialOfficer:
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 80));
        await HapticFeedback.mediumImpact();
      default:
        await HapticFeedback.selectionClick();
    }
  }

  // ─── Role → Pulse Color ───────────────────────────────────────────────────
  static Color _pulseColor(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return const Color(0xFF9C27B0); // deep purple — "royal heartbeat"
      case UserRole.administrator:
        return const Color(0xFF2196F3); // blue — "crisp authority"
      case UserRole.driver:
        return const Color(0xFF4CAF50); // green — "on the move"
      case UserRole.branchManager:
        return const Color(0xFFFF9800); // amber — "branch warmth"
      default:
        return const Color(0xFF3F51B5); // indigo — brand default
    }
  }

  // ─── Public API ──────────────────────────────────────────────────────────
  /// Fire the full multimodal role signature: native haptic + PWA vibration +
  /// audio earcon (if enabled) + visual pulse event.
  static Future<void> fireForRole(UserRole role) async {
    // 1. Emit visual pulse signal first (UI can start animating immediately)
    _pulseController.add(
      RoleSignalEvent(role: role, pulseColor: _pulseColor(role)),
    );

    if (!_hapticsEnabled) return;

    // 2. Native haptic pattern
    if (!kIsWeb) {
      await _nativePattern(role);
    } else {
      // 3. PWA Vibration API polyfill
      pwaVibrate(_vibrationPattern(role));
      // 4. Audio earcon (web only — native apps use the platform audio stack)
      if (_audioEnabled) {
        pwaPlayEarcon(role.name);
      }
    }
  }

  /// Convenience: fire signature for an active role switch (role-aware welcome).
  static Future<void> onRoleSwitch(UserRole newRole) =>
      fireForRole(newRole);

  /// Convenience: fire on Genie chat open (greeting moment).
  static Future<void> onGenieOpen(UserRole currentRole) =>
      fireForRole(currentRole);

  // ─── Lifecycle ────────────────────────────────────────────────────────────
  static void dispose() {
    _pulseController.close();
  }
}
