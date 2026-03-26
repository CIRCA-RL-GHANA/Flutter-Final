import 'package:flutter/foundation.dart';
import '../../../core/services/user_service.dart';

/// Phone number check result
enum NumberCheckResult { valid, invalid, existingUser, newUser, error }

/// OTP verification state
enum OtpState { idle, sending, sent, verifying, verified, error, expired }

class PhoneAuthProvider extends ChangeNotifier {
  // Phone number
  String _phoneNumber = '';
  String _countryCode = '+1';
  String _countryIso = 'US';
  bool _isPhoneValid = false;
  NumberCheckResult _numberCheckResult = NumberCheckResult.invalid;

  String get phoneNumber => _phoneNumber;
  String get countryCode => _countryCode;
  String get countryIso => _countryIso;
  bool get isPhoneValid => _isPhoneValid;
  NumberCheckResult get numberCheckResult => _numberCheckResult;
  String get formattedNumber => '$_countryCode $_phoneNumber';

  // OTP state
  OtpState _otpState = OtpState.idle;
  OtpState get otpState => _otpState;

  String _otp = '';
  String get otp => _otp;

  int _otpAttemptsRemaining = 3;
  int get otpAttemptsRemaining => _otpAttemptsRemaining;

  int _resendAttemptsRemaining = 5;
  int get resendAttemptsRemaining => _resendAttemptsRemaining;

  int _timerSeconds = 299; // 4:59
  int get timerSeconds => _timerSeconds;
  bool get canResend => _timerSeconds <= 0 && _resendAttemptsRemaining > 0;

  // Error
  String? _error;
  String? get error => _error;

  // Loading
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setPhoneNumber(String number) {
    _phoneNumber = number;
    notifyListeners();
  }

  void setCountry(String code, String iso) {
    _countryCode = code;
    _countryIso = iso;
    notifyListeners();
  }

  void setPhoneValid(bool valid) {
    _isPhoneValid = valid;
    notifyListeners();
  }

  final UserService _userService = UserService();

  /// Check if number exists in system
  Future<NumberCheckResult> checkNumber() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _userService.checkPhone(formattedNumber);

      if (response.success && response.data != null) {
        final exists = response.data!['exists'] as bool? ?? false;
        _numberCheckResult = exists
            ? NumberCheckResult.existingUser
            : NumberCheckResult.newUser;
      } else {
        _numberCheckResult = NumberCheckResult.error;
        _error = response.error?.userMessage ?? "Can't verify number. Try again.";
      }

      _isLoading = false;
      notifyListeners();
      return _numberCheckResult;
    } catch (e) {
      _error = "Can't verify number. Try again or use email";
      _isLoading = false;
      _numberCheckResult = NumberCheckResult.error;
      notifyListeners();
      return NumberCheckResult.error;
    }
  }

  /// Send OTP
  Future<bool> sendOtp() async {
    _otpState = OtpState.sending;
    _error = null;
    notifyListeners();

    try {
      final response = await _userService.resendOtp(formattedNumber);

      if (!response.success) {
        _otpState = OtpState.error;
        _error = response.error?.userMessage ?? 'Failed to send verification code';
        notifyListeners();
        return false;
      }

      _otpState = OtpState.sent;
      _timerSeconds = 299;
      notifyListeners();
      return true;
    } catch (e) {
      _otpState = OtpState.error;
      _error = 'Failed to send verification code';
      notifyListeners();
      return false;
    }
  }

  /// Verify OTP
  Future<bool> verifyOtp(String code) async {
    _otpState = OtpState.verifying;
    _error = null;
    notifyListeners();

    try {
      final response = await _userService.verifyOtp(
        phoneNumber: formattedNumber,
        code: code,
      );

      if (response.success) {
        _otp = code;
        _otpState = OtpState.verified;
        notifyListeners();
        return true;
      }

      _otpAttemptsRemaining--;
      final errorMsg = response.error?.message ?? 'Invalid code';
      if (_otpAttemptsRemaining <= 0) {
        _error = 'Too many failed attempts. Please request a new code.';
        _otpState = OtpState.error;
      } else {
        _error = '$errorMsg. $_otpAttemptsRemaining attempts remaining.';
        _otpState = OtpState.error;
      }
      notifyListeners();
      return false;
    } catch (e) {
      _otpAttemptsRemaining--;
      if (_otpAttemptsRemaining <= 0) {
        _error = 'Too many failed attempts. Please request a new code.';
        _otpState = OtpState.error;
      } else {
        _error = 'Invalid code. $_otpAttemptsRemaining attempts remaining.';
        _otpState = OtpState.error;
      }
      notifyListeners();
      return false;
    }
  }

  /// Resend OTP
  Future<bool> resendOtp() async {
    if (_resendAttemptsRemaining <= 0) {
      _error = 'Too many attempts. Please wait 5 minutes';
      notifyListeners();
      return false;
    }

    _resendAttemptsRemaining--;
    return await sendOtp();
  }

  void updateTimer(int seconds) {
    _timerSeconds = seconds;
    if (seconds <= 0) {
      _otpState = OtpState.expired;
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _phoneNumber = '';
    _countryCode = '+1';
    _countryIso = 'US';
    _isPhoneValid = false;
    _numberCheckResult = NumberCheckResult.invalid;
    _otpState = OtpState.idle;
    _otp = '';
    _otpAttemptsRemaining = 3;
    _resendAttemptsRemaining = 5;
    _timerSeconds = 299;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
