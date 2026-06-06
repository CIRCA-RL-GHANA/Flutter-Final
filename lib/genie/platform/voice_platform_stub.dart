/// Native / non-web stub for the Genie voice platform bridge.
///
/// Production voice on native (iOS / Android) requires the
/// `speech_to_text` package, which is not yet a dependency. Until then
/// every call here is a deterministic no-op and reports
/// `unavailable` so the UI can degrade gracefully.
library;

typedef VoiceTranscriptCallback = void Function(String transcript);
typedef VoiceStatusCallback = void Function(String status);

bool voiceIsSupported() => false;

void voiceConfigure({
  VoiceTranscriptCallback? onResult,
  VoiceStatusCallback? onStatus,
}) {
  // no-op on native — platform STT not wired yet
}

Future<bool> voiceStart() async => false;

Future<void> voiceStop() async {
  // no-op
}

Future<void> voiceCancel() async {
  // no-op
}
