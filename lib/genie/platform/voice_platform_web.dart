/// Web implementation of the Genie voice platform bridge.
///
/// Uses the browser's Web Speech API (`SpeechRecognition` /
/// `webkitSpeechRecognition`). Falls back gracefully if the API is
/// unavailable or the user denies microphone permission.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS('globalThis')
external JSObject get _globalThis;

typedef VoiceTranscriptCallback = void Function(String transcript);
typedef VoiceStatusCallback = void Function(String status);

JSObject? _recognition;
VoiceTranscriptCallback? _onResult;
VoiceStatusCallback? _onStatus;

bool voiceIsSupported() {
  try {
    return _globalThis.has('SpeechRecognition') ||
        _globalThis.has('webkitSpeechRecognition');
  } catch (_) {
    return false;
  }
}

void voiceConfigure({
  VoiceTranscriptCallback? onResult,
  VoiceStatusCallback? onStatus,
}) {
  _onResult = onResult;
  _onStatus = onStatus;
}

Future<bool> voiceStart() async {
  if (!voiceIsSupported()) {
    _onStatus?.call('unavailable');
    return false;
  }
  try {
    final ctorAny = _globalThis.has('SpeechRecognition')
        ? _globalThis['SpeechRecognition']
        : _globalThis['webkitSpeechRecognition'];
    final ctor = ctorAny as JSFunction?;
    if (ctor == null) {
      _onStatus?.call('unavailable');
      return false;
    }
    // Tear down a previous instance if the user re-taps mid-session.
    await voiceStop();
    _recognition = ctor.callAsConstructor<JSObject>();

    _recognition!['continuous'] = false.toJS;
    _recognition!['interimResults'] = false.toJS;
    _recognition!['maxAlternatives'] = 1.toJS;
    _recognition!['lang'] = (html.window.navigator.language ?? 'en-US').toJS;

    _recognition!['onstart'] =
        ((JSAny? _) => _onStatus?.call('listening')).toJS;

    _recognition!['onresult'] = ((JSAny? event) {
      try {
        final ev = event as JSObject?;
        if (ev == null) return;
        final results = ev['results'] as JSObject?;
        if (results == null) return;
        final length = (results['length'] as JSNumber?)?.toDartInt ?? 0;
        if (length == 0) return;
        final firstResult = results['0'] as JSObject?;
        if (firstResult == null) return;
        final firstAlt = firstResult['0'] as JSObject?;
        if (firstAlt == null) return;
        final transcript = (firstAlt['transcript'] as JSString?)?.toDart ?? '';
        final trimmed = transcript.trim();
        if (trimmed.isNotEmpty) {
          _onResult?.call(trimmed);
        }
      } catch (_) {
        // Ignore malformed events
      }
    }).toJS;

    _recognition!['onerror'] = ((JSAny? event) {
      try {
        final ev = event as JSObject?;
        final err = (ev?['error'] as JSString?)?.toDart ?? '';
        if (err == 'not-allowed' || err == 'service-not-allowed') {
          _onStatus?.call('unavailable');
        } else {
          _onStatus?.call('error');
        }
      } catch (_) {
        _onStatus?.call('error');
      }
    }).toJS;

    _recognition!['onend'] = ((JSAny? _) => _onStatus?.call('idle')).toJS;

    _recognition!.callMethod<JSAny?>('start'.toJS);
    return true;
  } catch (_) {
    _onStatus?.call('error');
    return false;
  }
}

Future<void> voiceStop() async {
  try {
    _recognition?.callMethod<JSAny?>('stop'.toJS);
  } catch (_) {
    // Ignore — onend will fire regardless
  }
}

Future<void> voiceCancel() async {
  try {
    _recognition?.callMethod<JSAny?>('abort'.toJS);
  } catch (_) {
    // ignore
  } finally {
    _recognition = null;
    _onStatus?.call('idle');
  }
}
