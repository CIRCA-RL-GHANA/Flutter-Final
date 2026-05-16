/// Web implementation of the PWA haptic platform bridge.
/// Uses the Vibration API (navigator.vibrate). Earcons are intentionally
/// no-op on web (Web Audio earcons removed for cross-SDK compatibility —
/// `dart:web_audio` is no longer part of the Dart SDK).
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:js_util' as js_util;

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

/// Web earcon hook. Intentionally a no-op to keep the web build
/// independent of `dart:web_audio` (removed from the Dart SDK).
/// Role-distinct feedback is delivered via [pwaVibrate]; audible earcons
/// can be reintroduced later via `package:web` + `dart:js_interop`.
void pwaPlayEarcon(String role) {
  // intentionally empty
}
