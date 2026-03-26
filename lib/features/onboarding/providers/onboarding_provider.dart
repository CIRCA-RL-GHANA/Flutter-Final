import 'package:flutter/foundation.dart';

/// Master onboarding state coordinator
class OnboardingProvider extends ChangeNotifier {
  // Current step tracking
  int _currentStep = 0;
  int get currentStep => _currentStep;
  static const int totalSteps = 10;

  // Overall completion tracking
  double _completionRate = 0.0;
  double get completionRate => _completionRate;

  // Screen-specific completion flags
  bool _splashCompleted = false;
  bool _welcomeViewed = false;
  bool _phoneVerified = false;
  bool _otpVerified = false;
  bool _registrationCompleted = false;
  bool _profileSetup = false;
  bool _biometricSetup = false;
  bool _roleSelected = false;
  bool _permissionsHandled = false;
  bool _tutorialCompleted = false;

  // Getters
  bool get splashCompleted => _splashCompleted;
  bool get welcomeViewed => _welcomeViewed;
  bool get phoneVerified => _phoneVerified;
  bool get otpVerified => _otpVerified;
  bool get registrationCompleted => _registrationCompleted;
  bool get profileSetup => _profileSetup;
  bool get biometricSetup => _biometricSetup;
  bool get roleSelected => _roleSelected;
  bool get permissionsHandled => _permissionsHandled;
  bool get tutorialCompleted => _tutorialCompleted;

  // User data
  String _phoneNumber = '';
  String _countryCode = '+1';
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  DateTime? _dateOfBirth;
  String _username = '';
  String? _profilePhotoPath;
  String _selectedRole = '';
  String _selectedSubRole = '';

  // User data getters
  String get phoneNumber => _phoneNumber;
  String get countryCode => _countryCode;
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  DateTime? get dateOfBirth => _dateOfBirth;
  String get username => _username;
  String? get profilePhotoPath => _profilePhotoPath;
  String get selectedRole => _selectedRole;
  String get selectedSubRole => _selectedSubRole;
  String get fullName => '$_firstName $_lastName'.trim();

  // Returning user
  bool _isReturningUser = false;
  bool get isReturningUser => _isReturningUser;
  DateTime? _lastLoginDate;
  DateTime? get lastLoginDate => _lastLoginDate;

  // Privacy preferences
  bool _marketingEmails = false;
  bool _dataSharing = false;
  bool _personalizedAds = false;
  bool get marketingEmails => _marketingEmails;
  bool get dataSharing => _dataSharing;
  bool get personalizedAds => _personalizedAds;

  // Methods
  void setStep(int step) {
    _currentStep = step;
    _updateCompletion();
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < totalSteps) {
      _currentStep++;
      _updateCompletion();
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void completeSplash() {
    _splashCompleted = true;
    notifyListeners();
  }

  void completeWelcome() {
    _welcomeViewed = true;
    notifyListeners();
  }

  void setPhoneData(String phone, String code) {
    _phoneNumber = phone;
    _countryCode = code;
    _phoneVerified = true;
    notifyListeners();
  }

  void completeOtp() {
    _otpVerified = true;
    notifyListeners();
  }

  void setRegistrationData({
    required String firstName,
    required String lastName,
    String? email,
    DateTime? dateOfBirth,
  }) {
    _firstName = firstName;
    _lastName = lastName;
    _email = email ?? '';
    _dateOfBirth = dateOfBirth;
    _registrationCompleted = true;
    notifyListeners();
  }

  void setProfileData({
    String? photoPath,
    required String username,
  }) {
    _profilePhotoPath = photoPath;
    _username = username;
    _profileSetup = true;
    notifyListeners();
  }

  void completeBiometric() {
    _biometricSetup = true;
    notifyListeners();
  }

  void setRole(String role, String subRole) {
    _selectedRole = role;
    _selectedSubRole = subRole;
    _roleSelected = true;
    notifyListeners();
  }

  void completePermissions() {
    _permissionsHandled = true;
    notifyListeners();
  }

  void completeTutorial() {
    _tutorialCompleted = true;
    notifyListeners();
  }

  void setReturningUser(bool isReturning, {DateTime? lastLogin}) {
    _isReturningUser = isReturning;
    _lastLoginDate = lastLogin;
    notifyListeners();
  }

  void setPrivacyPreferences({
    bool? marketing,
    bool? sharing,
    bool? ads,
  }) {
    if (marketing != null) _marketingEmails = marketing;
    if (sharing != null) _dataSharing = sharing;
    if (ads != null) _personalizedAds = ads;
    notifyListeners();
  }

  void _updateCompletion() {
    int completed = 0;
    if (_splashCompleted) completed++;
    if (_welcomeViewed) completed++;
    if (_phoneVerified) completed++;
    if (_otpVerified) completed++;
    if (_registrationCompleted) completed++;
    if (_profileSetup) completed++;
    if (_biometricSetup) completed++;
    if (_roleSelected) completed++;
    if (_permissionsHandled) completed++;
    if (_tutorialCompleted) completed++;
    _completionRate = completed / totalSteps;
  }

  /// Profile completeness score (out of 100)
  int get profileCompleteness {
    int score = 0;
    if (_firstName.isNotEmpty && _lastName.isNotEmpty) score += 20;
    if (_email.isNotEmpty) score += 15;
    if (_dateOfBirth != null) score += 10;
    if (_profilePhotoPath != null) score += 20;
    if (_username.isNotEmpty) score += 10;
    if (_biometricSetup) score += 10;
    if (_roleSelected) score += 10;
    if (_tutorialCompleted) score += 5;
    return score;
  }

  /// Analytics event tracking
  Map<String, dynamic> get analyticsSnapshot => {
        'splash_completed': _splashCompleted,
        'welcome_viewed': _welcomeViewed,
        'phone_number_entered': _phoneVerified,
        'otp_verified': _otpVerified,
        'registration_completed': _registrationCompleted,
        'profile_photo_added': _profilePhotoPath != null,
        'biometric_setup': _biometricSetup,
        'role_selected': _roleSelected,
        'permissions_granted': _permissionsHandled,
        'tutorial_completed': _tutorialCompleted,
        'completion_rate': _completionRate,
        'profile_completeness': profileCompleteness,
      };

  void reset() {
    _currentStep = 0;
    _completionRate = 0.0;
    _splashCompleted = false;
    _welcomeViewed = false;
    _phoneVerified = false;
    _otpVerified = false;
    _registrationCompleted = false;
    _profileSetup = false;
    _biometricSetup = false;
    _roleSelected = false;
    _permissionsHandled = false;
    _tutorialCompleted = false;
    _phoneNumber = '';
    _countryCode = '+1';
    _firstName = '';
    _lastName = '';
    _email = '';
    _dateOfBirth = null;
    _username = '';
    _profilePhotoPath = null;
    _selectedRole = '';
    _selectedSubRole = '';
    _isReturningUser = false;
    _lastLoginDate = null;
    _marketingEmails = false;
    _dataSharing = false;
    _personalizedAds = false;
    notifyListeners();
  }
}
