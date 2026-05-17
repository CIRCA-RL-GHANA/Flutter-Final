/// Web implementation of the Genie voice platform bridge.
///
/// Uses the browser's Web Speech API (`SpeechRecognition` /
/// `webkitSpeechRecognition`). Falls back gracefully if the API is
/// unavailable or the user denies microphone permission.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:js_util' as js_util;

typedef VoiceTranscriptCallback = void Function(String transcript);
typedef VoiceStatusCallback = void Function(String status);

dynamic _recognition;
VoiceTranscriptCallback? _onResult;
VoiceStatusCallback? _onStatus;

bool voiceIsSupported() {
  try {
    return js_util.hasProperty(html.window, 'SpeechRecognition') ||
        js_util.hasProperty(html.window, 'webkitSpeechRecognition');
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
    final ctor = js_util.getProperty(html.window, 'SpeechRecognition') ??
        js_util.getProperty(html.window, 'webkitSpeechRecognition');
    if (ctor == null) {
      _onStatus?.call('unavailable');
      return false;
    }
    // Tear down a previous instance if the user re-taps mid-session.
    await voiceStop();
    _recognition = js_util.callConstructor(ctor, const []);

    js_util.setProperty(_recognition, 'continuous', false);
    js_util.setProperty(_recognition, 'interimResults', false);
    js_util.setProperty(_recognition, 'maxAlternatives', 1);
    js_util.setProperty(_recognition, 'lang',
        (html.window.navigator.language ?? 'en-US'));

    js_util.setProperty(
      _recognition,
      'onstart',
      js_util.allowInterop((dynamic _) => _onStatus?.call('listening')),
    );

    js_util.setProperty(
      _recognition,
      'onresult',
      js_util.allowInterop((dynamic event) {
        try {
          final results = js_util.getProperty(event, 'results');
          final length = js_util.getProperty(results, 'length') as int? ?? 0;
          if (length == 0) return;
          final firstResult = js_util.getProperty(results, 0);
          final firstAlt = js_util.getProperty(firstResult, 0);
          final transcript =
              js_util.getProperty(firstAlt, 'transcript') as String? ?? '';
          final trimmed = transcript.trim();
          if (trimmed.isNotEmpty) {
            _onResult?.call(trimmed);
          }
        } catch (_) {
          // Ignore malformed events
        }
      }),
    );

    js_util.setProperty(
      _recognition,
      'onerror',
      js_util.allowInterop((dynamic event) {
        try {
          final err = js_util.getProperty(event, 'error') as String? ?? '';
          if (err == 'not-allowed' || err == 'service-not-allowed') {
            _onStatus?.call('unavailable');
          } else {
            _onStatus?.call('error');
          }
        } catch (_) {
          _onStatus?.call('error');
        }
      }),
    );

    js_util.setProperty(
      _recognition,
      'onend',
      js_util.allowInterop((dynamic _) => _onStatus?.call('idle')),
    );

    js_util.callMethod(_recognition, 'start', const []);
    return true;
  } catch (_) {
    _onStatus?.call('error');
    return false;
  }
}

Future<void> voiceStop() async {
  try {
    if (_recognition != null) {
      js_util.callMethod(_recognition, 'stop', const []);
    }
  } catch (_) {
    // Ignore — onend will fire regardless
  }
}

Future<void> voiceCancel() async {
  try {
    if (_recognition != null) {
      js_util.callMethod(_recognition, 'abort', const []);
    }
  } catch (_) {
    // ignore
  } finally {
    _recognition = null;
    _onStatus?.call('idle');
  }
}
