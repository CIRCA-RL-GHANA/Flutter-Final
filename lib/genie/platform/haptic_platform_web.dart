/// Web implementation of the PWA haptic platform bridge.
/// Uses the Vibration API (navigator.vibrate) and Web Audio API for earcons.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'dart:web_audio';

/// Triggers navigator.vibrate() with a role-distinct pattern.
/// Silently no-ops on browsers that do not support the Vibration API.
void pwaVibrate(List<int> pattern) {
  try {
    final nav = html.window.navigator;
    js_util.callMethod(nav, 'vibrate', [pattern]);
  } catch (_) {
    // Vibration API unsupported – silently ignored.
  }
}

/// Plays a short synthesised earcon for the given role key.
/// Earcons are generated via the Web Audio API — no asset files required.
///
/// Role earcon signatures:
///   owner  → warm, low-frequency descending two-note (A3 → F3, 80ms each)
///   administrator → higher double-beep (D5 → D5, 60ms gap, 40ms each)
///   driver → gentle ascending sweep (B3 → D4, 120ms ramp)
///   default → neutral single mid-tone (C4, 60ms)
void pwaPlayEarcon(String role) {
  try {
    final ctx = AudioContext();
    _scheduleEarcon(ctx, role);
  } catch (_) {
    // Web Audio API not supported — silently ignored.
  }
}

void _scheduleEarcon(AudioContext ctx, String role) {
  final now = (ctx.currentTime ?? 0).toDouble();

  switch (role.toLowerCase()) {
    case 'owner':
      _tone(ctx, 220.0, now, 0.08, 0.18);          // A3 – warm low
      _tone(ctx, 174.6, now + 0.10, 0.06, 0.18);   // F3 – descend
    case 'administrator':
      _tone(ctx, 587.3, now, 0.04, 0.22);           // D5
      _tone(ctx, 587.3, now + 0.07, 0.04, 0.22);   // D5 repeat
    case 'driver':
      _sweepTone(ctx, 246.9, 293.7, now, 0.12);    // B3→D4 sweep
    default:
      _tone(ctx, 261.6, now, 0.06, 0.16);           // C4 neutral
  }
}

/// Single decaying oscillator tone.
void _tone(AudioContext ctx, double freq, double startTime,
    double duration, double gain) {
  final osc = ctx.createOscillator()!;
  final gainNode = ctx.createGain()!;
  osc.frequency!.value = freq;
  osc.type = 'sine';
  gainNode.gain!.value = gain;
  gainNode.gain!.linearRampToValueAtTime(0.0, startTime + duration);
  osc.connectNode(gainNode);
  gainNode.connectNode(ctx.destination!);
  osc.start();
  osc.stop(startTime + duration + 0.02);
}

/// Linear-frequency sweep from [startFreq] to [endFreq].
void _sweepTone(AudioContext ctx, double startFreq, double endFreq,
    double startTime, double duration) {
  final osc = ctx.createOscillator()!;
  final gainNode = ctx.createGain()!;
  osc.type = 'sine';
  osc.frequency!.value = startFreq;
  osc.frequency!.linearRampToValueAtTime(endFreq, startTime + duration);
  gainNode.gain!.value = 0.18;
  gainNode.gain!.linearRampToValueAtTime(0.0, startTime + duration);
  osc.connectNode(gainNode);
  gainNode.connectNode(ctx.destination!);
  osc.start();
  osc.stop(startTime + duration + 0.02);
}
