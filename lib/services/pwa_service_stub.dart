import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Progressive Web App (PWA) Service for web platform features.
/// Handles app installability, online/offline state, and PWA lifecycle.
class PwaService {
  PwaService._();
  static final PwaService instance = PwaService._();

  late StreamController<bool> _installableController;
  late StreamController<bool> _onlineController;
  bool _isInstallable = false;
  bool _isOnline = true;
  StreamSubscription? _connectivitySubscription;
  bool _initialized = false;

  /// Whether an install prompt is available.
  bool get isInstallable => _isInstallable;

  /// Stream that emits `true` when the app becomes installable.
  Stream<bool> get installableStream => _installableController.stream;

  /// Stream that emits `true`/`false` for online/offline transitions.
  Stream<bool> get onlineStream => _onlineController.stream;

  /// Whether the device is currently online.
  bool get isOnline => _isOnline;

  /// Initialise PWA listeners and connectivity monitoring.
  Future<void> init() async {
    if (_initialized) return;

    _installableController = StreamController<bool>.broadcast();
    _onlineController = StreamController<bool>.broadcast();

    // Monitor connectivity status
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (result) {
        final isOnline = result != ConnectivityResult.none;
        if (_isOnline != isOnline) {
          _isOnline = isOnline;
          _onlineController.add(isOnline);
        }
      },
    );

    // Check initial online status
    final connectivityResult = await Connectivity().checkConnectivity();
    _isOnline = connectivityResult != ConnectivityResult.none;

    _initialized = true;
  }

  /// Set installability state (typically called by web platform).
  void setInstallable(bool value) {
    if (_isInstallable != value) {
      _isInstallable = value;
      _installableController.add(value);
    }
  }

  /// Trigger the native install prompt.
  /// Returns true if installation was initiated, false otherwise.
  Future<bool> promptInstall() async {
    if (!_isInstallable) {
      return false;
    }
    // Native implementation would trigger the browser's install prompt
    // For Flutter web, this would call JavaScript via web_socket or similar
    return true;
  }

  /// Dispose all streams and listeners.
  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    await _installableController.close();
    await _onlineController.close();
    _initialized = false;
  }
}
