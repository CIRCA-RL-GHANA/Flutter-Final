/// Native / non-web stub for PWA haptic platform bridge.
/// All methods are no-ops on native since Flutter's HapticFeedback API
/// is used directly in GenieTactileActions.
void pwaVibrate(List<int> pattern) {
  // no-op on native – HapticFeedback handles haptics
}

void pwaPlayEarcon(String role) {
  // no-op on native – platform audio packages handle sound
}
