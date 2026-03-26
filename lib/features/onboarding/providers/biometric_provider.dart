import 'package:flutter/foundation.dart';
import '../../../core/services/user_service.dart';

/// Biometric type enum
enum BiometricType { faceId, touchId, fingerprint, iris, none }

/// Biometric setup state
enum BiometricSetupState { idle, requesting, enrolling, testing, complete, failed, skipped }

/// Authentication fallback method
enum AuthFallback { pin, password, pattern }

class BiometricProvider extends ChangeNotifier {
  // Detected capability
  BiometricType _biometricType = BiometricType.none;
  BiometricType get biometricType => _biometricType;
  bool get hasBiometrics => _biometricType != BiometricType.none;

  // Setup state
  BiometricSetupState _setupState = BiometricSetupState.idle;
  BiometricSetupState get setupState => _setupState;

  // Biometric enabled
  bool _biometricEnabled = true;
  bool get biometricEnabled => _biometricEnabled;

  // Consent
  bool _consentGiven = false;
  bool get consentGiven => _consentGiven;

  // Fallback
  AuthFallback _selectedFallback = AuthFallback.pin;
  AuthFallback get selectedFallback => _selectedFallback;
  String _pin = '';
  String get pin => _pin;

  // State
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _error;
  String? get error => _error;

  String get biometricName {
    switch (_biometricType) {
      case BiometricType.faceId:
        return 'Face ID';
      case BiometricType.touchId:
        return 'Touch ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris Scan';
      case BiometricType.none:
        return 'None';
    }
  }

  void setBiometricType(BiometricType type) {
    _biometricType = type;
    notifyListeners();
  }

  void setBiometricEnabled(bool enabled) {
    _biometricEnabled = enabled;
    notifyListeners();
  }

  void setConsent(bool consent) {
    _consentGiven = consent;
    notifyListeners();
  }

  void setFallback(AuthFallback fallback) {
    _selectedFallback = fallback;
    notifyListeners();
  }

  void setPin(String pin) {
    _pin = pin;
    notifyListeners();
  }

  final UserService _userService = UserService();

  // Track the userId to update biometric status
  String? _userId;
  void setUserId(String userId) => _userId = userId;

  /// Setup biometrics
  Future<bool> setupBiometrics() async {
    if (!hasBiometrics || !_biometricEnabled) {
      _setupState = BiometricSetupState.skipped;
      // Notify backend that biometrics were skipped
      if (_userId != null) {
        await _userService.verifyBiometric(
          userId: _userId!,
          biometricStatus: false,
        );
      }
      notifyListeners();
      return true;
    }

    _setupState = BiometricSetupState.requesting;
    _error = null;
    notifyListeners();

    try {
      // Step 1: Request permission (local_auth)
      await Future.delayed(const Duration(milliseconds: 500));
      _setupState = BiometricSetupState.enrolling;
      notifyListeners();

      // Step 2: Capture biometric sample (local_auth)
      await Future.delayed(const Duration(milliseconds: 500));
      _setupState = BiometricSetupState.testing;
      notifyListeners();

      // Step 3: Notify backend of biometric verification
      if (_userId != null) {
        final response = await _userService.verifyBiometric(
          userId: _userId!,
          biometricStatus: true,
        );
        if (!response.success) {
          _setupState = BiometricSetupState.failed;
          _error = response.error?.userMessage ?? 'Biometric setup failed.';
          notifyListeners();
          return false;
        }
      }

      _setupState = BiometricSetupState.complete;
      notifyListeners();
      return true;
    } catch (e) {
      _setupState = BiometricSetupState.failed;
      _error = 'Biometric setup failed. You can try again later in settings.';
      notifyListeners();
      return false;
    }
  }

  /// Skip biometrics and use fallback
  void skipBiometrics() {
    _biometricEnabled = false;
    _setupState = BiometricSetupState.skipped;
    notifyListeners();
  }

  void reset() {
    _biometricType = BiometricType.none;
    _setupState = BiometricSetupState.idle;
    _biometricEnabled = true;
    _consentGiven = false;
    _selectedFallback = AuthFallback.pin;
    _pin = '';
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
