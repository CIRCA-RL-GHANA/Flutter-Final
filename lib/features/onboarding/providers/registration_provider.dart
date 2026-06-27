import 'package:flutter/foundation.dart';
import '../../../core/services/user_service.dart';

class RegistrationProvider extends ChangeNotifier {
  //  Required fields 
  String _username = '';     // socialUsername
  String _wireId = '';       // starts with @
  String _password = '';

  //  Optional fields 
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  DateTime? _dateOfBirth;

  //  Privacy 
  bool _marketingEmails = false;
  bool _dataSharing = false;
  bool _personalizedAds = false;
  bool _termsAccepted = false;

  //  State 
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;
  String? _userId;

  //  Getters 
  String get username => _username;
  String get wireId => _wireId;
  String get password => _password;
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  String get fullName => '$_firstName $_lastName'.trim();
  DateTime? get dateOfBirth => _dateOfBirth;
  bool get marketingEmails => _marketingEmails;
  bool get dataSharing => _dataSharing;
  bool get personalizedAds => _personalizedAds;
  bool get termsAccepted => _termsAccepted;
  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  String? get error => _error;
  String? get userId => _userId;

  //  Validation 
  bool get isUsernameValid =>
      _username.length >= 3 &&
      RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(_username);

  bool get isWireIdValid =>
      _wireId.startsWith('@') && _wireId.length >= 4 &&
      RegExp(r'^@[a-zA-Z0-9_]+$').hasMatch(_wireId);

  bool get isPasswordValid =>
      _password.length >= 8 &&
      RegExp(r'(?=.*[a-z])').hasMatch(_password) &&
      RegExp(r'(?=.*[A-Z])').hasMatch(_password) &&
      RegExp(r'(?=.*\d)').hasMatch(_password) &&
      RegExp(r'(?=.*[@#!$%^&*])').hasMatch(_password);

  bool get isEmailValid =>
      _email.isEmpty ||
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_email);

  /// Password strength: 04
  int get passwordStrength {
    int score = 0;
    if (_password.length >= 8) score++;
    if (RegExp(r'(?=.*[A-Z])').hasMatch(_password)) score++;
    if (RegExp(r'(?=.*\d)').hasMatch(_password)) score++;
    if (RegExp(r'(?=.*[@#!$%^&*])').hasMatch(_password)) score++;
    return score;
  }

  bool get canProceed => isUsernameValid && isWireIdValid && isPasswordValid;

  //  Setters 
  void setUsername(String value) {
    _username = value.trim().toLowerCase();
    // Auto-populate wireId from username if user hasn't customised it
    if (_wireId.isEmpty || _wireId == '@${_getPrevUsername()}') {
      _wireId = _username.isNotEmpty ? '@$_username' : '';
    }
    notifyListeners();
  }

  String _prevUsername = '';
  String _getPrevUsername() {
    final prev = _prevUsername;
    _prevUsername = _username;
    return prev;
  }

  void setWireId(String value) {
    _wireId = value.trim().toLowerCase();
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void setFirstName(String value) { _firstName = value; notifyListeners(); }
  void setLastName(String value)  { _lastName = value;  notifyListeners(); }
  void setEmail(String value)     { _email = value;     notifyListeners(); }
  void setDateOfBirth(DateTime? v){ _dateOfBirth = v;   notifyListeners(); }
  void setMarketingEmails(bool v) { _marketingEmails = v; notifyListeners(); }
  void setDataSharing(bool v)     { _dataSharing = v;   notifyListeners(); }
  void setPersonalizedAds(bool v) { _personalizedAds = v; notifyListeners(); }
  void setTermsAccepted(bool v)   { _termsAccepted = v; notifyListeners(); }

  //  API 
  final UserService _userService = UserService();

  Future<bool> saveRegistration({required String phoneNumber}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _userService.register(
        phoneNumber: phoneNumber,
        socialUsername: _username,
        wireId: _wireId,
        password: _password,
        firstName: _firstName.isNotEmpty ? _firstName : null,
        lastName: _lastName.isNotEmpty ? _lastName : null,
        email: _email.isNotEmpty ? _email : null,
      );

      if (response.success && response.data != null) {
        _userId = response.data!['userId'] as String?;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      _error = response.error?.userMessage ?? "Registration failed. Check your details.";
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = "Connection error. Try again.";
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _username = ''; _wireId = ''; _password = '';
    _firstName = ''; _lastName = ''; _email = '';
    _dateOfBirth = null;
    _marketingEmails = false; _dataSharing = false; _personalizedAds = false;
    _termsAccepted = false; _isLoading = false; _error = null;
    notifyListeners();
  }
}
