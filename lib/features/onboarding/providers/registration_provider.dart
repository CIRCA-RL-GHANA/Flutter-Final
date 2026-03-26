import 'package:flutter/foundation.dart';
import '../../../core/services/user_service.dart';

class RegistrationProvider extends ChangeNotifier {
  // Form fields
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  DateTime? _dateOfBirth;

  // Getters
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  DateTime? get dateOfBirth => _dateOfBirth;
  String get fullName => '$_firstName $_lastName'.trim();

  // Validation
  bool get isFirstNameValid => _firstName.trim().length >= 2;
  bool get isLastNameValid => _lastName.trim().length >= 2;
  bool get isNameValid => isFirstNameValid && isLastNameValid;
  bool get isEmailValid =>
      _email.isEmpty ||
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_email);
  bool get isDobValid {
    if (_dateOfBirth == null) return true; // optional
    final age = DateTime.now().difference(_dateOfBirth!).inDays ~/ 365;
    return age >= 13 && age <= 120;
  }

  bool get canProceed => isNameValid;

  // Privacy
  bool _marketingEmails = false;
  bool _dataSharing = false;
  bool _personalizedAds = false;
  bool _termsAccepted = false;

  bool get marketingEmails => _marketingEmails;
  bool get dataSharing => _dataSharing;
  bool get personalizedAds => _personalizedAds;
  bool get termsAccepted => _termsAccepted;

  // State
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _error;
  String? get error => _error;

  // Setters
  void setFirstName(String value) {
    _firstName = value;
    notifyListeners();
  }

  void setLastName(String value) {
    _lastName = value;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setDateOfBirth(DateTime? value) {
    _dateOfBirth = value;
    notifyListeners();
  }

  void setMarketingEmails(bool value) {
    _marketingEmails = value;
    notifyListeners();
  }

  void setDataSharing(bool value) {
    _dataSharing = value;
    notifyListeners();
  }

  void setPersonalizedAds(bool value) {
    _personalizedAds = value;
    notifyListeners();
  }

  void setTermsAccepted(bool value) {
    _termsAccepted = value;
    notifyListeners();
  }

  final UserService _userService = UserService();

  // Track registered userId from backend
  String? _userId;
  String? get userId => _userId;

  /// Save registration data
  Future<bool> saveRegistration({
    required String phoneNumber,
    required String socialUsername,
    required String wireId,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _userService.register(
        phoneNumber: phoneNumber,
        socialUsername: socialUsername,
        wireId: wireId,
        password: password,
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
      _error = response.error?.userMessage ?? "Couldn't save. Please check connection";
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = "Couldn't save. Please check connection";
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _firstName = '';
    _lastName = '';
    _email = '';
    _dateOfBirth = null;
    _marketingEmails = false;
    _dataSharing = false;
    _personalizedAds = false;
    _termsAccepted = false;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
