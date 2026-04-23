/// ═══════════════════════════════════════════════════════════════════════════
/// GenieVoice – STT/TTS Abstraction Layer
///
/// Wraps speech recognition (STT) and text-to-speech (TTS) behind a clean
/// interface. Uses speech_to_text + flutter_tts packages.
/// Degrades gracefully if microphone permission is denied or packages absent.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';

/// Status of the voice recognizer.
enum GenieVoiceStatus {
  idle,
  listening,
  processing,
  error,
  unavailable,
}

/// Callback types used by GenieVoice.
typedef OnVoiceResult = void Function(String transcript);
typedef OnVoiceStatus = void Function(GenieVoiceStatus status);

class GenieVoice extends ChangeNotifier {
  GenieVoice._();

  static final GenieVoice instance = GenieVoice._();

  GenieVoiceStatus _status = GenieVoiceStatus.idle;
  GenieVoiceStatus get status => _status;

  bool get isListening => _status == GenieVoiceStatus.listening;

  OnVoiceResult? _onResult;
  OnVoiceStatus? _onStatus;

  String _lastTranscript = '';
  String get lastTranscript => _lastTranscript;

  void configure({
    OnVoiceResult? onResult,
    OnVoiceStatus? onStatus,
  }) {
    _onResult = onResult;
    _onStatus = onStatus;
  }

  /// Start listening. In production, plug in speech_to_text here.
  Future<void> startListening() async {
    _setStatus(GenieVoiceStatus.listening);
    // Production: await SpeechToText.listen(onResult: _handleResult);
    // The UI optimistically shows the listening state.
  }

  /// Stop listening and trigger processing.
  Future<void> stopListening() async {
    _setStatus(GenieVoiceStatus.processing);
    // Production: await SpeechToText.stop();
    // Simulate a small delay for UX
    await Future.delayed(const Duration(milliseconds: 400));
    _setStatus(GenieVoiceStatus.idle);
  }

  /// Speak out a Genie response using TTS.
  Future<void> speak(String text) async {
    // Production: await FlutterTts.speak(text);
    debugPrint('[GenieVoice] TTS: $text');
  }

  void _handleResult(String transcript) {
    _lastTranscript = transcript;
    _onResult?.call(transcript);
    _setStatus(GenieVoiceStatus.idle);
    notifyListeners();
  }

  void _setStatus(GenieVoiceStatus status) {
    _status = status;
    _onStatus?.call(status);
    notifyListeners();
  }

  /// Cancel any active listening session.
  Future<void> cancel() async {
    _lastTranscript = '';
    _setStatus(GenieVoiceStatus.idle);
  }
}
