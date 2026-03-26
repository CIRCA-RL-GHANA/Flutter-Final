import 'package:flutter/foundation.dart';

/// Permission group levels
enum PermissionGroup { essential, enhanced, premium }

/// Individual permission items
enum AppPermission {
  notifications,
  locationCoarse,
  locationPrecise,
  contacts,
  camera,
  microphone,
  files,
  calendar,
}

/// Permission state
enum PermissionState { notRequested, granted, denied, permanentlyDenied }

class PermissionProvider extends ChangeNotifier {
  // Current permission group being requested
  PermissionGroup _currentGroup = PermissionGroup.essential;
  PermissionGroup get currentGroup => _currentGroup;

  // Current permission index within group
  int _currentPermissionIndex = 0;
  int get currentPermissionIndex => _currentPermissionIndex;

  // Permission states
  final Map<AppPermission, PermissionState> _permissions = {
    for (var p in AppPermission.values) p: PermissionState.notRequested,
  };

  Map<AppPermission, PermissionState> get permissions =>
      Map.unmodifiable(_permissions);

  PermissionState getPermissionState(AppPermission permission) =>
      _permissions[permission] ?? PermissionState.notRequested;

  // State
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _allGroupsProcessed = false;
  bool get allGroupsProcessed => _allGroupsProcessed;

  /// Get permissions for a group
  List<AppPermission> getGroupPermissions(PermissionGroup group) {
    switch (group) {
      case PermissionGroup.essential:
        return [AppPermission.notifications, AppPermission.locationCoarse];
      case PermissionGroup.enhanced:
        return [
          AppPermission.locationPrecise,
          AppPermission.contacts,
          AppPermission.camera,
        ];
      case PermissionGroup.premium:
        return [
          AppPermission.microphone,
          AppPermission.files,
          AppPermission.calendar,
        ];
    }
  }

  /// Get benefit text for a permission
  String getBenefitText(AppPermission permission) {
    switch (permission) {
      case AppPermission.notifications:
        return 'Get order updates and security alerts';
      case AppPermission.locationCoarse:
        return 'Find nearby shops and services';
      case AppPermission.locationPrecise:
        return 'Accurate delivery tracking';
      case AppPermission.contacts:
        return 'Find friends already on PROMPT';
      case AppPermission.camera:
        return 'Scan QR codes and upload photos';
      case AppPermission.microphone:
        return 'Voice commands and calls';
      case AppPermission.files:
        return 'Upload documents and media';
      case AppPermission.calendar:
        return 'Sync appointments and reminders';
    }
  }

  /// Get icon name for a permission
  String getPermissionIcon(AppPermission permission) {
    switch (permission) {
      case AppPermission.notifications:
        return 'notifications';
      case AppPermission.locationCoarse:
      case AppPermission.locationPrecise:
        return 'location_on';
      case AppPermission.contacts:
        return 'contacts';
      case AppPermission.camera:
        return 'camera_alt';
      case AppPermission.microphone:
        return 'mic';
      case AppPermission.files:
        return 'folder';
      case AppPermission.calendar:
        return 'calendar_today';
    }
  }

  /// Get permission label
  String getPermissionLabel(AppPermission permission) {
    switch (permission) {
      case AppPermission.notifications:
        return 'Notifications';
      case AppPermission.locationCoarse:
        return 'Location';
      case AppPermission.locationPrecise:
        return 'Precise Location';
      case AppPermission.contacts:
        return 'Contacts';
      case AppPermission.camera:
        return 'Camera';
      case AppPermission.microphone:
        return 'Microphone';
      case AppPermission.files:
        return 'Files & Media';
      case AppPermission.calendar:
        return 'Calendar';
    }
  }

  /// Request a specific permission
  Future<bool> requestPermission(AppPermission permission) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate platform permission request
      await Future.delayed(const Duration(milliseconds: 500));

      // In production: Use permission_handler package
      _permissions[permission] = PermissionState.granted;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _permissions[permission] = PermissionState.denied;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Skip a permission (Not Now)
  void skipPermission(AppPermission permission) {
    _permissions[permission] = PermissionState.denied;
    notifyListeners();
  }

  /// Move to next permission in sequence
  void moveToNext() {
    final currentGroupPermissions = getGroupPermissions(_currentGroup);

    if (_currentPermissionIndex < currentGroupPermissions.length - 1) {
      _currentPermissionIndex++;
    } else {
      // Move to next group
      if (_currentGroup == PermissionGroup.essential) {
        _currentGroup = PermissionGroup.enhanced;
        _currentPermissionIndex = 0;
      } else if (_currentGroup == PermissionGroup.enhanced) {
        _currentGroup = PermissionGroup.premium;
        _currentPermissionIndex = 0;
      } else {
        _allGroupsProcessed = true;
      }
    }
    notifyListeners();
  }

  /// Get current permission being requested
  AppPermission? get currentPermission {
    final perms = getGroupPermissions(_currentGroup);
    if (_currentPermissionIndex < perms.length) {
      return perms[_currentPermissionIndex];
    }
    return null;
  }

  /// Overall progress
  double get progress {
    final total = AppPermission.values.length;
    final processed = _permissions.values
        .where((s) => s != PermissionState.notRequested)
        .length;
    return processed / total;
  }

  /// Count of granted permissions
  int get grantedCount =>
      _permissions.values.where((s) => s == PermissionState.granted).length;

  void reset() {
    _currentGroup = PermissionGroup.essential;
    _currentPermissionIndex = 0;
    for (var p in AppPermission.values) {
      _permissions[p] = PermissionState.notRequested;
    }
    _isLoading = false;
    _allGroupsProcessed = false;
    notifyListeners();
  }
}
