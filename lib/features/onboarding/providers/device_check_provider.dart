import 'package:flutter/foundation.dart';

/// Network connectivity quality states
enum NetworkQuality { excellent, good, poor, offline }

/// Device capability check results
enum DeviceCheckStatus { checking, passed, failed }

class DeviceCheckProvider extends ChangeNotifier {
  // Check states
  DeviceCheckStatus _overallStatus = DeviceCheckStatus.checking;
  DeviceCheckStatus get overallStatus => _overallStatus;

  // Individual checks
  NetworkQuality _networkQuality = NetworkQuality.offline;
  NetworkQuality get networkQuality => _networkQuality;

  bool _hasEnoughStorage = false;
  bool get hasEnoughStorage => _hasEnoughStorage;

  bool _isOsCompatible = false;
  bool get isOsCompatible => _isOsCompatible;

  String _screenSizeCategory = 'mobile'; // mobile, tablet, desktop
  String get screenSizeCategory => _screenSizeCategory;

  BiometricCapability _biometricCapability = BiometricCapability.none;
  BiometricCapability get biometricCapability => _biometricCapability;

  // Error info
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  DeviceCheckError? _errorType;
  DeviceCheckError? get errorType => _errorType;

  // Progress
  double _progress = 0.0;
  double get progress => _progress;

  /// Runs all device checks in parallel
  Future<bool> runAllChecks() async {
    _overallStatus = DeviceCheckStatus.checking;
    _progress = 0.0;
    notifyListeners();

    try {
      // Run all checks in parallel
      await Future.wait([
        _checkNetwork(),
        _checkStorage(),
        _checkOsCompatibility(),
        _detectBiometrics(),
      ]);

      _progress = 1.0;

      // Determine overall status
      if (!_isOsCompatible) {
        _overallStatus = DeviceCheckStatus.failed;
        _errorType = DeviceCheckError.incompatibleOs;
        _errorMessage = 'Your device OS needs to be updated to use PROMPT Genie.';
      } else if (!_hasEnoughStorage) {
        _overallStatus = DeviceCheckStatus.failed;
        _errorType = DeviceCheckError.insufficientStorage;
        _errorMessage = 'You need at least 100MB of free storage.';
      } else if (_networkQuality == NetworkQuality.offline) {
        // Allow offline but with notice
        _overallStatus = DeviceCheckStatus.passed;
        _errorType = DeviceCheckError.noNetwork;
        _errorMessage = 'You are offline. Some features will be limited.';
      } else {
        _overallStatus = DeviceCheckStatus.passed;
        _errorType = null;
        _errorMessage = null;
      }

      notifyListeners();
      return _overallStatus == DeviceCheckStatus.passed;
    } catch (e) {
      _overallStatus = DeviceCheckStatus.failed;
      _errorMessage = 'Failed to check device capabilities.';
      notifyListeners();
      return false;
    }
  }

  Future<void> _checkNetwork() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // In production: Use connectivity_plus to check real network
    // Simulating a good connection for now
    _networkQuality = NetworkQuality.good;
    _progress += 0.25;
    notifyListeners();
  }

  Future<void> _checkStorage() async {
    await Future.delayed(const Duration(milliseconds: 200));
    // In production: Use path_provider to check available storage
    _hasEnoughStorage = true;
    _progress += 0.25;
    notifyListeners();
  }

  Future<void> _checkOsCompatibility() async {
    await Future.delayed(const Duration(milliseconds: 250));
    // In production: Use device_info_plus to check OS version
    _isOsCompatible = true;
    _progress += 0.25;
    notifyListeners();
  }

  Future<void> _detectBiometrics() async {
    await Future.delayed(const Duration(milliseconds: 350));
    // In production: Use local_auth to detect biometric capability
    _biometricCapability = BiometricCapability.fingerprint;
    _progress += 0.25;
    notifyListeners();
  }

  void setScreenSize(double width) {
    if (width < 480) {
      _screenSizeCategory = 'mobile';
    } else if (width < 1024) {
      _screenSizeCategory = 'tablet';
    } else {
      _screenSizeCategory = 'desktop';
    }
    notifyListeners();
  }
}

enum BiometricCapability {
  faceId,
  touchId,
  fingerprint,
  iris,
  none,
}

enum DeviceCheckError {
  insufficientStorage,
  incompatibleOs,
  noNetwork,
  unknown,
}
