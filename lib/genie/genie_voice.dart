/// 
/// GenieVoice  STT/TTS Abstraction Layer
///
/// Wraps speech recognition (STT) behind a clean interface that delegates to
/// a platform implementation via conditional imports:
///    Web (PWA)   browser's Web Speech API (`SpeechRecognition`).
///    Native      currently a no-op stub. Plug in `speech_to_text` when
///     the package is added to pubspec.
/// Degrades gracefully if microphone permission is denied or the API is
/// unavailable in the current runtime.
/// 
library;

import 'package:flutter/foundation.dart';

import 'platform/voice_platform_stub.dart'
    if (dart.library.html) 'platform/voice_platform_web.dart' as platform;

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
  GenieVoice._() {
    // Wire the platform implementation back into the controller-facing API.
    platform.voiceConfigure(
      onResult: (transcript) => _handleResult(transcript),
      onStatus: (raw) => _setStatus(_parseStatus(raw)),
    );
  }

  static final GenieVoice instance = GenieVoice._();

  GenieVoiceStatus _status = GenieVoiceStatus.idle;
  GenieVoiceStatus get status => _status;

  bool get isListening => _status == GenieVoiceStatus.listening;
  bool get isSupported => platform.voiceIsSupported();

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

  /// Start listening. Delegates to the active platform implementation.
  /// Reports status=unavailable if the platform has no STT or the user
  /// denied microphone permission.
  Future<void> startListening() async {
    if (!platform.voiceIsSupported()) {
      _setStatus(GenieVoiceStatus.unavailable);
      return;
    }
    final started = await platform.voiceStart();
    if (!started) {
      _setStatus(GenieVoiceStatus.unavailable);
    }
  }

  /// Stop listening. The platform `onend` event drives the final status.
  Future<void> stopListening() async {
    if (_status == GenieVoiceStatus.listening) {
      _setStatus(GenieVoiceStatus.processing);
    }
    await platform.voiceStop();
  }

  /// Speak out a Genie response using TTS. TTS is currently a debug stub;
  /// pluggable behind the same platform pattern when needed.
  Future<void> speak(String text) async {
    debugPrint('[GenieVoice] TTS: $text');
  }

  void _handleResult(String transcript) {
    _lastTranscript = transcript;
    _onResult?.call(transcript);
    _setStatus(GenieVoiceStatus.idle);
  }

  GenieVoiceStatus _parseStatus(String raw) {
    switch (raw) {
      case 'listening':
        return GenieVoiceStatus.listening;
      case 'processing':
        return GenieVoiceStatus.processing;
      case 'error':
        return GenieVoiceStatus.error;
      case 'unavailable':
        return GenieVoiceStatus.unavailable;
      case 'idle':
      default:
        return GenieVoiceStatus.idle;
    }
  }

  void _setStatus(GenieVoiceStatus status) {
    if (_status == status) return;
    _status = status;
    _onStatus?.call(status);
    notifyListeners();
  }

  /// Cancel any active listening session.
  Future<void> cancel() async {
    _lastTranscript = '';
    await platform.voiceCancel();
    _setStatus(GenieVoiceStatus.idle);
  }
}
