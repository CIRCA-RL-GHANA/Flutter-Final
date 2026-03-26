import 'package:flutter/foundation.dart';
import '../../../core/services/services.dart';

/// Username availability state
enum UsernameStatus { idle, checking, available, taken, invalid }

class ProfileProvider extends ChangeNotifier {
  // Photo
  String? _photoPath;
  String? get photoPath => _photoPath;
  bool get hasPhoto => _photoPath != null && _photoPath!.isNotEmpty;

  // Username
  String _username = '';
  String get username => _username;
  UsernameStatus _usernameStatus = UsernameStatus.idle;
  UsernameStatus get usernameStatus => _usernameStatus;

  // AI-generated suggestions
  List<String> _suggestions = [];
  List<String> get suggestions => _suggestions;

  // User reference
  String? _userId;

  // Profile completeness
  int get photoPoints => hasPhoto ? 20 : 0;
  int get usernamePoints =>
      (_username.isNotEmpty && _usernameStatus == UsernameStatus.available) ? 10 : 0;
  int get totalPoints => photoPoints + usernamePoints;

  // State
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _error;
  String? get error => _error;

  bool get canProceed =>
      _username.isNotEmpty && _usernameStatus == UsernameStatus.available;

  final UserService _userService = UserService();
  final ProfileService _profileService = ProfileService();

  void setUserId(String userId) {
    _userId = userId;
  }

  void setPhoto(String path) {
    _photoPath = path;
    notifyListeners();
  }

  void removePhoto() {
    _photoPath = null;
    notifyListeners();
  }

  void setUsername(String value) {
    _username = value.toLowerCase().trim();
    notifyListeners();
  }

  /// Check username availability
  Future<void> checkUsername(String value) async {
    if (value.isEmpty) {
      _usernameStatus = UsernameStatus.idle;
      notifyListeners();
      return;
    }

    // Local validation first
    if (value.length < 3) {
      _usernameStatus = UsernameStatus.invalid;
      notifyListeners();
      return;
    }

    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(value)) {
      _usernameStatus = UsernameStatus.invalid;
      notifyListeners();
      return;
    }

    final reserved = ['admin', 'prompt', 'genie', 'support', 'help', 'system'];
    if (reserved.contains(value)) {
      _usernameStatus = UsernameStatus.taken;
      notifyListeners();
      return;
    }

    _usernameStatus = UsernameStatus.checking;
    notifyListeners();

    try {
      final response = await _userService.checkUsername(value);

      if (response.success && response.data != null) {
        final available = response.data!['available'] as bool? ?? false;
        _usernameStatus =
            available ? UsernameStatus.available : UsernameStatus.taken;
      } else {
        _usernameStatus = UsernameStatus.idle;
      }
      notifyListeners();
    } catch (e) {
      _usernameStatus = UsernameStatus.idle;
      notifyListeners();
    }
  }

  /// Generate username suggestions based on name
  void generateSuggestions(String firstName, String lastName) {
    final first = firstName.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    final last = lastName.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    final now = DateTime.now();

    _suggestions = [
      '${first}_$last',
      '$first${now.year % 100}',
      '${first[0]}$last${now.millisecond % 100}',
    ];
    notifyListeners();
  }

  /// Save profile data to backend
  Future<bool> saveProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Create profile on backend
      final response = await _profileService.createProfile(
        userId: _userId ?? '',
        username: _username,
        photoPath: _photoPath,
      );

      if (response.success) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _error = response.error?.userMessage ?? "Couldn't save profile. Please try again";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = "Couldn't save profile. Please try again";
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _photoPath = null;
    _username = '';
    _usernameStatus = UsernameStatus.idle;
    _suggestions = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
