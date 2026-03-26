import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

/// Web implementation of PwaService.
/// Manages PWA install prompt and online/offline status.
class PwaService {
  PwaService._();
  static final PwaService instance = PwaService._();

  html.Event? _deferredPrompt;
  final StreamController<bool> _installableController =
      StreamController<bool>.broadcast();
  final StreamController<bool> _onlineController =
      StreamController<bool>.broadcast();

  /// Whether an install prompt is available.
  bool get isInstallable => _deferredPrompt != null;

  /// Stream that emits `true` when the app becomes installable.
  Stream<bool> get installableStream => _installableController.stream;

  /// Stream that emits `true`/`false` for online/offline transitions.
  Stream<bool> get onlineStream => _onlineController.stream;

  /// Whether the device is currently online.
  bool get isOnline => html.window.navigator.onLine ?? true;

  /// Initialise listeners. Call once from `main()` on web.
  void init() {
    if (!kIsWeb) return;

    // Capture the beforeinstallprompt event
    html.window.addEventListener('beforeinstallprompt', (event) {
      event.preventDefault();
      _deferredPrompt = event;
      _installableController.add(true);
      debugPrint('[PWA] Install prompt captured');
    });

    // Listen for successful install
    html.window.addEventListener('appinstalled', (_) {
      _deferredPrompt = null;
      _installableController.add(false);
      debugPrint('[PWA] App installed successfully');
    });

    // Online / Offline listeners
    html.window.addEventListener('online', (_) {
      _onlineController.add(true);
      debugPrint('[PWA] Back online');
    });

    html.window.addEventListener('offline', (_) {
      _onlineController.add(false);
      debugPrint('[PWA] Gone offline');
    });
  }

  /// Trigger the native install prompt. Returns `true` if accepted.
  Future<bool> promptInstall() async {
    if (_deferredPrompt == null) return false;

    try {
      // Use JS interop to call prompt() on the deferred event
      final dynamic prompt = _deferredPrompt;
      prompt.prompt();
      final dynamic result = await prompt.userChoice;
      final accepted = result.outcome == 'accepted';
      if (accepted) {
        _deferredPrompt = null;
        _installableController.add(false);
      }
      return accepted;
    } catch (e) {
      debugPrint('[PWA] Install prompt error: $e');
      return false;
    }
  }

  /// Dispose streams.
  void dispose() {
    _installableController.close();
    _onlineController.close();
  }
}
