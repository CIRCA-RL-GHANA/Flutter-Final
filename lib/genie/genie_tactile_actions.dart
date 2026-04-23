/// ═══════════════════════════════════════════════════════════════════════════
/// GenieTactileActions – Haptic Feedback Service
///
/// Centralised haptic & audio feedback for every Genie interaction type.
/// Maps action categories to platform haptic patterns.
/// All methods are no-ops if haptics are disabled in accessibility settings.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/services.dart';

enum GenieTactileEvent {
  /// Light tick – social, chat, informational taps
  lightTick,
  /// Medium impact – navigation, card expansion
  mediumImpact,
  /// Heavy / deep pulse – financial transactions (finance module)
  heavyPulse,
  /// Double pulse – destructive / irreversible action confirmation
  doubleConfirm,
  /// Success pattern – action completed successfully
  success,
  /// Error pattern – action failed or denied
  error,
  /// Drag edge tension – approaching swipe threshold
  dragTension,
  /// SOS – urgent, escalating pulses
  sos,
}

class GenieTactileActions {
  GenieTactileActions._();

  static bool _enabled = true;

  static void setEnabled(bool value) => _enabled = value;

  static Future<void> trigger(GenieTactileEvent event) async {
    if (!_enabled) return;

    switch (event) {
      case GenieTactileEvent.lightTick:
        await HapticFeedback.lightImpact();

      case GenieTactileEvent.mediumImpact:
        await HapticFeedback.mediumImpact();

      case GenieTactileEvent.heavyPulse:
        await HapticFeedback.heavyImpact();

      case GenieTactileEvent.doubleConfirm:
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 120));
        await HapticFeedback.heavyImpact();

      case GenieTactileEvent.success:
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 80));
        await HapticFeedback.lightImpact();

      case GenieTactileEvent.error:
        await HapticFeedback.vibrate();

      case GenieTactileEvent.dragTension:
        await HapticFeedback.selectionClick();

      case GenieTactileEvent.sos:
        for (int i = 0; i < 3; i++) {
          await HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 100));
        }
    }
  }

  /// Convenience shortcuts
  static Future<void> onTap() => trigger(GenieTactileEvent.lightTick);
  static Future<void> onFinancialAction() => trigger(GenieTactileEvent.heavyPulse);
  static Future<void> onSuccess() => trigger(GenieTactileEvent.success);
  static Future<void> onError() => trigger(GenieTactileEvent.error);
  static Future<void> onDestructiveConfirm() => trigger(GenieTactileEvent.doubleConfirm);
  static Future<void> onSOS() => trigger(GenieTactileEvent.sos);
  static Future<void> onNavigate() => trigger(GenieTactileEvent.mediumImpact);
}
