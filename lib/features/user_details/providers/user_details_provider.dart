/// ═══════════════════════════════════════════════════════════════════════════
/// USER DETAILS Provider
/// Master state management for the entire User Details module:
/// identity, security, privacy, accessibility, notifications, audit trail
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/user_details_models.dart';
import '../../prompt/models/rbac_models.dart';
import '../../../core/services/services.dart';
import '../../../core/network/api_response.dart';

class UserDetailsProvider extends ChangeNotifier {
  // ─── Services ───────────────────────────────────────────────────────────
  final ProfileService _profileService;
  final AuthService _authService;
  final EntityService _entityService;
  // ignore: unused_field
  final UserService _userService;

  UserDetailsProvider({
    ProfileService? profileService,
    AuthService? authService,
    EntityService? entityService,
    UserService? userService,
  })  : _profileService = profileService ?? ProfileService(),
        _authService = authService ?? AuthService(),
        _entityService = entityService ?? EntityService(),
        _userService = userService ?? UserService();

  // ─── Loading / Error State ──────────────────────────────────────────────
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ─── Fallback Identity (offline / default) ──────────────────────────────
  static final UserIdentity _fallbackIdentity = UserIdentity(
    id: 'usr_001',
    legalName: 'John Doe',
    displayName: 'John Doe',
    handle: '@johndoe',
    bio: 'Building the future of commerce in West Africa. Tech enthusiast & community leader.',
    email: 'user@genieinprompt.app',
    emailVerified: true,
    phone: '+1 (555) 123-4567',
    phoneVerified: true,
    address: '123 Main Street, Accra, Ghana',
    joinedDate: DateTime(2023, 1, 15),
    verificationLevel: VerificationLevel.fullKYC,
    profileCompleteness: 0.75,
    gender: Gender.male,
    dateOfBirth: DateTime(1992, 6, 15),
    primaryLanguage: 'English',
    secondaryLanguages: ['French'],
    emergencyContacts: const [
      EmergencyContact(id: 'ec1', name: 'Jane Doe', phone: '+1 555 987 6543', relationship: 'Spouse'),
      EmergencyContact(id: 'ec2', name: 'Bob Smith', phone: '+1 555 456 7890', relationship: 'Brother'),
    ],
  );

  // ─── Identity ────────────────────────────────────────────────────────────
  UserIdentity _identity = _fallbackIdentity;

  UserIdentity get identity => _identity;

  void updateIdentity(UserIdentity updated) {
    _identity = updated;
    notifyListeners();
  }

  /// Initialise the provider – call once after construction.
  Future<void> init() async {
    await loadIdentity();
  }

  /// Load user identity from the backend, falling back to hardcoded data.
  Future<void> loadIdentity() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Try fetching the authenticated user first
      final ApiResponse<Map<String, dynamic>> meResponse =
          await _authService.getMe();

      if (meResponse.success && meResponse.data != null) {
        final userId = meResponse.data!['id']?.toString() ?? _identity.id;

        // Now fetch the full profile
        final ApiResponse<Map<String, dynamic>> profileResponse =
            await _profileService.getProfileByUserId(userId);

        if (profileResponse.success && profileResponse.data != null) {
          _identity = _identityFromJson(
            {...meResponse.data!, ...profileResponse.data!},
          );
          _isOnline = true;
        } else {
          // Auth succeeded but profile fetch failed – build from auth data only
          _identity = _identityFromJson(meResponse.data!);
          _isOnline = true;
        }
      } else {
        // Could not reach backend – use fallback
        _isOnline = false;
        _identity = _fallbackIdentity;
        debugPrint('UserDetailsProvider: offline – using fallback identity');
      }
    } catch (e) {
      _isOnline = false;
      _identity = _fallbackIdentity;
      _errorMessage = 'Failed to load profile. Using offline data.';
      debugPrint('UserDetailsProvider.loadIdentity error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Map a raw JSON map into a [UserIdentity].
  UserIdentity _identityFromJson(Map<String, dynamic> json) {
    final firstLast =
        '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim();

    return UserIdentity(
      id: json['id']?.toString() ?? _fallbackIdentity.id,
      legalName: json['legalName'] as String? ??
          (firstLast.isNotEmpty ? firstLast : _fallbackIdentity.legalName),
      displayName: json['displayName'] as String? ??
          json['username'] as String? ??
          _fallbackIdentity.displayName,
      handle: json['handle'] as String? ??
          (json['username'] != null
              ? '@${json['username']}'
              : _fallbackIdentity.handle),
      bio: json['bio'] as String? ?? _fallbackIdentity.bio,
      email: json['email'] as String? ?? _fallbackIdentity.email,
      emailVerified:
          json['emailVerified'] as bool? ?? _fallbackIdentity.emailVerified,
      phone: json['phone'] as String? ??
          json['phoneNumber'] as String? ??
          _fallbackIdentity.phone,
      phoneVerified:
          json['phoneVerified'] as bool? ?? _fallbackIdentity.phoneVerified,
      address: json['address'] as String? ?? _fallbackIdentity.address,
      avatarUrl: json['avatarUrl'] as String? ?? json['photoPath'] as String?,
      joinedDate: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ??
              _fallbackIdentity.joinedDate
          : _fallbackIdentity.joinedDate,
      verificationLevel: _parseVerificationLevel(json['verificationLevel']),
      profileCompleteness:
          (json['profileCompleteness'] as num?)?.toDouble() ??
              _fallbackIdentity.profileCompleteness,
      gender: _parseGender(json['gender']),
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'].toString())
          : _fallbackIdentity.dateOfBirth,
      primaryLanguage: json['primaryLanguage'] as String? ??
          _fallbackIdentity.primaryLanguage,
      secondaryLanguages: json['secondaryLanguages'] != null
          ? List<String>.from(json['secondaryLanguages'] as List)
          : _fallbackIdentity.secondaryLanguages,
      emergencyContacts:
          _fallbackIdentity.emergencyContacts, // not returned by API yet
    );
  }

  static VerificationLevel _parseVerificationLevel(dynamic value) {
    if (value == null) return _fallbackIdentity.verificationLevel;
    if (value is String) {
      return VerificationLevel.values.firstWhere(
        (v) => v.name == value,
        orElse: () => _fallbackIdentity.verificationLevel,
      );
    }
    return _fallbackIdentity.verificationLevel;
  }

  static Gender _parseGender(dynamic value) {
    if (value == null) return _fallbackIdentity.gender;
    if (value is String) {
      return Gender.values.firstWhere(
        (g) => g.name == value,
        orElse: () => _fallbackIdentity.gender,
      );
    }
    return _fallbackIdentity.gender;
  }

  // ─── Update Field (local + API persist) ─────────────────────────────────
  void updateField({
    String? displayName,
    String? bio,
    String? email,
    String? phone,
    String? address,
    Gender? gender,
    DateTime? dateOfBirth,
    String? primaryLanguage,
  }) {
    _identity = _identity.copyWith(
      displayName: displayName,
      bio: bio,
      email: email,
      phone: phone,
      address: address,
      gender: gender,
      dateOfBirth: dateOfBirth,
      primaryLanguage: primaryLanguage,
    );
    _addAuditEntry(AuditAction.update, 'Profile field updated');
    notifyListeners();

    // Persist to backend in the background
    _persistFieldUpdate(
      displayName: displayName,
      bio: bio,
      email: email,
      phone: phone,
      address: address,
      gender: gender,
      dateOfBirth: dateOfBirth,
      primaryLanguage: primaryLanguage,
    );
  }

  Future<void> _persistFieldUpdate({
    String? displayName,
    String? bio,
    String? email,
    String? phone,
    String? address,
    Gender? gender,
    DateTime? dateOfBirth,
    String? primaryLanguage,
  }) async {
    try {
      // Build a map of only the changed fields
      final Map<String, dynamic> changedFields = {};
      if (displayName != null) changedFields['displayName'] = displayName;
      if (bio != null) changedFields['bio'] = bio;
      if (email != null) changedFields['email'] = email;
      if (phone != null) changedFields['phone'] = phone;
      if (address != null) changedFields['address'] = address;
      if (gender != null) changedFields['gender'] = gender.name;
      if (dateOfBirth != null) {
        changedFields['dateOfBirth'] = dateOfBirth.toIso8601String();
      }
      if (primaryLanguage != null) {
        changedFields['primaryLanguage'] = primaryLanguage;
      }

      if (changedFields.isEmpty) return;

      // ProfileService accepts bio and username (displayName)
      await _profileService.updateProfile(
        id: _identity.id,
        bio: changedFields['bio'] as String?,
        username: changedFields['displayName'] as String?,
      );

      debugPrint('UserDetailsProvider: field update persisted');
    } catch (e) {
      debugPrint('UserDetailsProvider: failed to persist field update: $e');
      // Local state is already updated – user can retry later
    }
  }

  // ─── Edit Mode ──────────────────────────────────────────────────────────
  bool _editMode = false;
  bool get editMode => _editMode;

  void toggleEditMode() {
    _editMode = !_editMode;
    notifyListeners();
  }

  // ─── Context Management ──────────────────────────────────────────────────
  ContextFilter _contextFilter = ContextFilter.all;
  ContextFilter get contextFilter => _contextFilter;

  String _contextSearch = '';
  String get contextSearch => _contextSearch;

  List<AppContextModel> _archivedContexts = [];
  List<AppContextModel> get archivedContexts => _archivedContexts;

  void setContextFilter(ContextFilter filter) {
    _contextFilter = filter;
    notifyListeners();
  }

  void setContextSearch(String query) {
    _contextSearch = query;
    notifyListeners();
  }

  void archiveContext(AppContextModel ctx) {
    _archivedContexts.add(ctx);
    _addAuditEntry(AuditAction.update, 'Archived context: ${ctx.name}');
    notifyListeners();
  }

  void restoreContext(AppContextModel ctx) {
    _archivedContexts.removeWhere((c) => c.id == ctx.id);
    _addAuditEntry(AuditAction.update, 'Restored context: ${ctx.name}');
    notifyListeners();
  }

  List<AppContextModel> filterContexts(List<AppContextModel> all) {
    var filtered = List<AppContextModel>.from(all);

    // Remove archived
    final archivedIds = _archivedContexts.map((c) => c.id).toSet();
    filtered.removeWhere((c) => archivedIds.contains(c.id));

    // Apply type filter
    if (_contextFilter != ContextFilter.all) {
      filtered = filtered.where((c) {
        switch (_contextFilter) {
          case ContextFilter.personal:
            return c.entityType == EntityType.personal;
          case ContextFilter.business:
            return c.entityType == EntityType.business;
          case ContextFilter.branch:
            return c.entityType == EntityType.branch;
          case ContextFilter.all:
            return true;
        }
      }).toList();
    }

    // Apply search
    if (_contextSearch.isNotEmpty) {
      final q = _contextSearch.toLowerCase();
      filtered = filtered
          .where((c) =>
              c.name.toLowerCase().contains(q) ||
              c.subtitle.toLowerCase().contains(q) ||
              c.roleLabel.toLowerCase().contains(q))
          .toList();
    }

    return filtered;
  }

  // ─── Entity Creation ────────────────────────────────────────────────────
  EntityCreationType? _selectedEntityType;
  EntityCreationType? get selectedEntityType => _selectedEntityType;

  int _creationStep = 0;
  int get creationStep => _creationStep;
  static const int totalCreationSteps = 5;

  // Step 2 fields
  String _entityName = '';
  String _entitySubtitle = '';
  String? _entityRegistration;
  String? _entityIndustry;
  String? _entityEmployeeRange;
  BranchType? _entityBranchType;
  String? _parentEntityId;

  String get entityName => _entityName;
  String get entitySubtitle => _entitySubtitle;
  String? get entityRegistration => _entityRegistration;
  BranchType? get entityBranchType => _entityBranchType;

  // Step 3 verification
  bool _emailVerificationSent = false;
  bool _phoneVerificationSent = false;
  bool _documentUploaded = false;
  bool _addressVerified = false;

  bool get emailVerificationSent => _emailVerificationSent;
  bool get phoneVerificationSent => _phoneVerificationSent;
  bool get documentUploaded => _documentUploaded;
  bool get addressVerified => _addressVerified;

  // Step 4 role
  UserRole? _selectedRole;
  UserRole? get selectedRole => _selectedRole;

  // Entity creation loading state
  bool _isCreatingEntity = false;
  bool get isCreatingEntity => _isCreatingEntity;

  String? _entityCreationError;
  String? get entityCreationError => _entityCreationError;

  void selectEntityType(EntityCreationType type) {
    _selectedEntityType = type;
    _creationStep = 1;
    notifyListeners();
  }

  void setCreationStep(int step) {
    _creationStep = step;
    notifyListeners();
  }

  void updateEntityFields({
    String? name,
    String? subtitle,
    String? registration,
    String? industry,
    String? employeeRange,
    BranchType? branchType,
    String? parentEntityId,
  }) {
    if (name != null) _entityName = name;
    if (subtitle != null) _entitySubtitle = subtitle;
    if (registration != null) _entityRegistration = registration;
    if (industry != null) _entityIndustry = industry;
    if (employeeRange != null) _entityEmployeeRange = employeeRange;
    if (branchType != null) _entityBranchType = branchType;
    if (parentEntityId != null) _parentEntityId = parentEntityId;
    notifyListeners();
  }

  void sendEmailVerification() {
    _emailVerificationSent = true;
    notifyListeners();
  }

  void sendPhoneVerification() {
    _phoneVerificationSent = true;
    notifyListeners();
  }

  void setDocumentUploaded(bool v) {
    _documentUploaded = v;
    notifyListeners();
  }

  void setAddressVerified(bool v) {
    _addressVerified = v;
    notifyListeners();
  }

  void selectRole(UserRole role) {
    _selectedRole = role;
    notifyListeners();
  }

  /// Submit entity creation (step 5) – calls EntityService to persist.
  Future<bool> submitEntityCreation() async {
    if (_selectedEntityType == null || _entityName.isEmpty) return false;

    _isCreatingEntity = true;
    _entityCreationError = null;
    notifyListeners();

    try {
      final entityType = _selectedEntityType!.name;
      final role = _selectedRole?.name ?? 'owner';

      ApiResponse<Map<String, dynamic>> response;

      if (_selectedEntityType == EntityCreationType.personal) {
        response = await _entityService.createIndividual(
          ownerId: _identity.id,
          entityType: entityType,
          role: role,
          displayName: _entityName,
          metadata: {
            if (_entitySubtitle.isNotEmpty) 'subtitle': _entitySubtitle,
            if (_entityRegistration != null)
              'registration': _entityRegistration,
            if (_entityIndustry != null) 'industry': _entityIndustry,
          },
        );
      } else {
        response = await _entityService.createOther(
          ownerId: _identity.id,
          entityType: entityType,
          businessName: _entityName,
          description: _entitySubtitle.isNotEmpty ? _entitySubtitle : null,
          metadata: {
            if (_entityRegistration != null)
              'registration': _entityRegistration,
            if (_entityIndustry != null) 'industry': _entityIndustry,
            if (_entityEmployeeRange != null)
              'employeeRange': _entityEmployeeRange,
            if (_entityBranchType != null)
              'branchType': _entityBranchType!.name,
            if (_parentEntityId != null) 'parentEntityId': _parentEntityId,
          },
        );
      }

      if (response.success) {
        _addAuditEntry(AuditAction.create, 'Created entity: $_entityName');
        resetCreation();
        return true;
      } else {
        _entityCreationError =
            response.error?.message ?? 'Failed to create entity';
        return false;
      }
    } catch (e) {
      _entityCreationError = 'Failed to create entity: $e';
      debugPrint('UserDetailsProvider.submitEntityCreation error: $e');
      return false;
    } finally {
      _isCreatingEntity = false;
      notifyListeners();
    }
  }

  void resetCreation() {
    _selectedEntityType = null;
    _creationStep = 0;
    _entityName = '';
    _entitySubtitle = '';
    _entityRegistration = null;
    _entityIndustry = null;
    _entityEmployeeRange = null;
    _entityBranchType = null;
    _parentEntityId = null;
    _emailVerificationSent = false;
    _phoneVerificationSent = false;
    _documentUploaded = false;
    _addressVerified = false;
    _selectedRole = null;
    _entityCreationError = null;
    notifyListeners();
  }

  // ─── Security ────────────────────────────────────────────────────────────
  SecuritySettings _security = SecuritySettings(
    activeSessions: [
      ActiveSession(
        id: 's1',
        deviceName: 'iPhone 15 Pro',
        deviceType: 'phone',
        os: 'iOS 17.2',
        location: 'Accra, Ghana',
        lastActive: DateTime.now(),
        isCurrent: true,
        isTrusted: true,
      ),
      ActiveSession(
        id: 's2',
        deviceName: 'MacBook Pro',
        deviceType: 'desktop',
        os: 'macOS Sonoma',
        location: 'Accra, Ghana',
        lastActive: DateTime.now().subtract(const Duration(hours: 2)),
        isTrusted: true,
      ),
      ActiveSession(
        id: 's3',
        deviceName: 'Chrome Browser',
        deviceType: 'web',
        os: 'Windows 11',
        location: 'London, UK',
        lastActive: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ],
    securityLog: [
      SecurityEvent(
        id: 'se1',
        description: 'Successful login via Face ID',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        severity: SecurityEventSeverity.info,
        deviceName: 'iPhone 15 Pro',
      ),
      SecurityEvent(
        id: 'se2',
        description: 'Password changed',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        severity: SecurityEventSeverity.info,
      ),
      SecurityEvent(
        id: 'se3',
        description: 'Login from new location',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        severity: SecurityEventSeverity.warning,
        location: 'London, UK',
      ),
    ],
  );

  SecuritySettings get security => _security;

  void updateSecurity(SecuritySettings updated) {
    _security = updated;
    _addAuditEntry(AuditAction.settingsChange, 'Security settings updated');
    notifyListeners();
  }

  void setPrimaryAuth(AuthMethod method) {
    _security = _security.copyWith(primaryAuth: method);
    _addAuditEntry(
        AuditAction.securityEvent, 'Primary auth changed to ${method.label}');
    notifyListeners();
  }

  void toggle2FA(bool enabled) {
    _security = _security.copyWith(twoFactorEnabled: enabled);
    _addAuditEntry(AuditAction.securityEvent,
        '2FA ${enabled ? 'enabled' : 'disabled'}');
    notifyListeners();
  }

  void revokeSession(String sessionId) {
    final sessions =
        _security.activeSessions.where((s) => s.id != sessionId).toList();
    _security = _security.copyWith(activeSessions: sessions);
    _addAuditEntry(AuditAction.securityEvent, 'Session revoked');
    notifyListeners();
    // AuthService has no dedicated revoke endpoint – keep local-only for now
  }

  void revokeAllOtherSessions() {
    final sessions =
        _security.activeSessions.where((s) => s.isCurrent).toList();
    _security = _security.copyWith(activeSessions: sessions);
    _addAuditEntry(
        AuditAction.securityEvent, 'All other sessions revoked');
    notifyListeners();
  }

  // ─── Privacy ─────────────────────────────────────────────────────────────
  PrivacySettings _privacy = const PrivacySettings();
  PrivacySettings get privacy => _privacy;

  void updatePrivacy(PrivacySettings updated) {
    _privacy = updated;
    _addAuditEntry(AuditAction.settingsChange, 'Privacy settings updated');
    notifyListeners();
  }

  void setProfileVisibility(ProfileVisibility v) {
    _privacy = _privacy.copyWith(profileVisibility: v);
    notifyListeners();
  }

  void setDataSharing(DataSharingLevel v) {
    _privacy = _privacy.copyWith(dataSharingLevel: v);
    notifyListeners();
  }

  void setLocationTracking(LocationTracking v) {
    _privacy = _privacy.copyWith(locationTracking: v);
    notifyListeners();
  }

  void toggleContactSync(bool v) {
    _privacy = _privacy.copyWith(contactSyncEnabled: v);
    notifyListeners();
  }

  void toggleAnalytics(bool v) {
    _privacy = _privacy.copyWith(usageAnalyticsEnabled: v);
    notifyListeners();
  }

  void requestDataExport() {
    _privacy = _privacy.copyWith(lastDataExport: DateTime.now());
    _addAuditEntry(AuditAction.export, 'Data export requested');
    notifyListeners();
  }

  // ─── Accessibility ──────────────────────────────────────────────────────
  AccessibilitySettings _accessibility = const AccessibilitySettings();
  AccessibilitySettings get accessibility => _accessibility;

  List<AccessibilityPreset> _accessibilityPresets = [
    const AccessibilityPreset(
      name: 'Default',
      settings: AccessibilitySettings(),
    ),
    const AccessibilityPreset(
      name: 'Large Text',
      settings: AccessibilitySettings(textScale: 1.4),
    ),
    const AccessibilityPreset(
      name: 'High Contrast',
      settings: AccessibilitySettings(highContrast: true, textScale: 1.2),
    ),
    const AccessibilityPreset(
      name: 'Reduced Motion',
      settings: AccessibilitySettings(
          reducedMotion: true, simplifiedLayout: true),
    ),
  ];
  List<AccessibilityPreset> get accessibilityPresets => _accessibilityPresets;

  void updateAccessibility(AccessibilitySettings updated) {
    _accessibility = updated;
    _addAuditEntry(
        AuditAction.settingsChange, 'Accessibility settings updated');
    notifyListeners();
  }

  void setTextScale(double scale) {
    _accessibility = _accessibility.copyWith(textScale: scale);
    notifyListeners();
  }

  void toggleReducedMotion(bool v) {
    _accessibility = _accessibility.copyWith(reducedMotion: v);
    notifyListeners();
  }

  void toggleHighContrast(bool v) {
    _accessibility = _accessibility.copyWith(highContrast: v);
    notifyListeners();
  }

  void applyPreset(AccessibilityPreset preset) {
    _accessibility = preset.settings;
    _addAuditEntry(AuditAction.settingsChange,
        'Accessibility preset applied: ${preset.name}');
    notifyListeners();
  }

  void saveCurrentAsPreset(String name) {
    _accessibilityPresets.add(AccessibilityPreset(
      name: name,
      settings: _accessibility,
    ));
    notifyListeners();
  }

  // ─── Notifications ──────────────────────────────────────────────────────
  NotificationSettings _notifications = const NotificationSettings(
    moduleConfigs: {
      'GO PAGE': ModuleNotificationConfig(
          moduleName: 'GO PAGE', priority: 4),
      'MARKET': ModuleNotificationConfig(
          moduleName: 'MARKET', priority: 3),
      'MY UPDATES': ModuleNotificationConfig(
          moduleName: 'MY UPDATES', priority: 2),
      'SETUP DASHBOARD': ModuleNotificationConfig(
          moduleName: 'SETUP DASHBOARD', priority: 3),
      'ALERTS': ModuleNotificationConfig(
          moduleName: 'ALERTS', priority: 5, overrideQuietHours: true),
      'LIVE': ModuleNotificationConfig(
          moduleName: 'LIVE', priority: 5, overrideQuietHours: true),
      'qualChat': ModuleNotificationConfig(
          moduleName: 'qualChat', priority: 4),
      'APRIL': ModuleNotificationConfig(
          moduleName: 'APRIL', priority: 2),
      'USER DETAILS': ModuleNotificationConfig(
          moduleName: 'USER DETAILS', priority: 1),
      'UTILITY': ModuleNotificationConfig(
          moduleName: 'UTILITY', priority: 1),
    },
    smartRules: [
      SmartNotificationRule(
        id: 'r1',
        condition: 'If notification from MANAGER',
        action: 'Always show immediately',
      ),
      SmartNotificationRule(
        id: 'r2',
        condition: 'If MARKET notification after 8 PM',
        action: 'Delay until morning',
      ),
      SmartNotificationRule(
        id: 'r3',
        condition: 'During LIVE shifts',
        action: 'Prioritize OPERATIONAL alerts',
      ),
      SmartNotificationRule(
        id: 'r4',
        condition: 'When battery < 20%',
        action: 'Reduce non-critical notifications',
        enabled: false,
      ),
    ],
  );

  NotificationSettings get notifications => _notifications;

  void updateNotifications(NotificationSettings updated) {
    _notifications = updated;
    _addAuditEntry(
        AuditAction.settingsChange, 'Notification settings updated');
    notifyListeners();
  }

  void toggleGlobalNotifications(bool v) {
    _notifications = _notifications.copyWith(globalEnabled: v);
    notifyListeners();
  }

  void setNotificationMode(NotificationMode mode) {
    _notifications = _notifications.copyWith(activeMode: mode);
    _addAuditEntry(
        AuditAction.settingsChange, 'Notification mode: ${mode.label}');
    notifyListeners();
  }

  void toggleModuleNotification(String moduleName, bool enabled) {
    final configs =
        Map<String, ModuleNotificationConfig>.from(_notifications.moduleConfigs);
    final existing = configs[moduleName];
    if (existing != null) {
      configs[moduleName] = existing.copyWith(pushEnabled: enabled);
    }
    _notifications = _notifications.copyWith(moduleConfigs: configs);
    notifyListeners();
  }

  void toggleQuietHours(bool v) {
    _notifications = _notifications.copyWith(quietHoursEnabled: v);
    notifyListeners();
  }

  void toggleSmartRule(String ruleId, bool enabled) {
    final rules = _notifications.smartRules.map((r) {
      if (r.id == ruleId) {
        return SmartNotificationRule(
          id: r.id,
          condition: r.condition,
          action: r.action,
          enabled: enabled,
        );
      }
      return r;
    }).toList();
    _notifications = _notifications.copyWith(smartRules: rules);
    notifyListeners();
  }

  // ─── Audit Log ──────────────────────────────────────────────────────────
  final List<AuditLogEntry> _auditLog = [
    AuditLogEntry(
      id: 'a1',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      action: AuditAction.login,
      description: 'Logged in via Face ID',
      contextName: 'Personal',
      deviceName: 'iPhone 15 Pro',
      location: 'Accra, Ghana',
    ),
    AuditLogEntry(
      id: 'a2',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      action: AuditAction.contextSwitch,
      description: 'Switched to Business context',
      contextName: 'Wizdom Shop',
      deviceName: 'iPhone 15 Pro',
      moduleName: 'USER DETAILS',
    ),
    AuditLogEntry(
      id: 'a3',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      action: AuditAction.update,
      description: 'Updated business hours',
      contextName: 'Wizdom Shop',
      moduleName: 'SETUP DASHBOARD',
    ),
    AuditLogEntry(
      id: 'a4',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      action: AuditAction.create,
      description: 'Created new product listing',
      contextName: 'Wizdom Shop',
      moduleName: 'MARKET',
    ),
    AuditLogEntry(
      id: 'a5',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      action: AuditAction.securityEvent,
      description: 'Login from new location detected',
      deviceName: 'Chrome Browser',
      location: 'London, UK',
      anomaly: AuditAnomaly.unusualActivity,
    ),
    AuditLogEntry(
      id: 'a6',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      action: AuditAction.read,
      description: 'Viewed financial report',
      contextName: 'Personal',
      moduleName: 'GO PAGE',
    ),
    AuditLogEntry(
      id: 'a7',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      action: AuditAction.settingsChange,
      description: 'Privacy settings modified',
      moduleName: 'USER DETAILS',
    ),
    AuditLogEntry(
      id: 'a8',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      action: AuditAction.export,
      description: 'Data export completed (GDPR)',
      contextName: 'Personal',
    ),
  ];

  List<AuditLogEntry> get auditLog => _auditLog;

  AuditTimeFilter _auditTimeFilter = AuditTimeFilter.last7Days;
  AuditTimeFilter get auditTimeFilter => _auditTimeFilter;

  Set<AuditAction> _auditActionFilter = {};
  Set<AuditAction> get auditActionFilter => _auditActionFilter;

  String? _auditModuleFilter;
  String? get auditModuleFilter => _auditModuleFilter;

  void setAuditTimeFilter(AuditTimeFilter f) {
    _auditTimeFilter = f;
    notifyListeners();
  }

  void toggleAuditActionFilter(AuditAction action) {
    if (_auditActionFilter.contains(action)) {
      _auditActionFilter.remove(action);
    } else {
      _auditActionFilter.add(action);
    }
    notifyListeners();
  }

  void setAuditModuleFilter(String? module) {
    _auditModuleFilter = module;
    notifyListeners();
  }

  List<AuditLogEntry> get filteredAuditLog {
    return _auditLog.where((entry) {
      // Time filter
      final now = DateTime.now();
      final cutoff = switch (_auditTimeFilter) {
        AuditTimeFilter.today => DateTime(now.year, now.month, now.day),
        AuditTimeFilter.yesterday =>
          DateTime(now.year, now.month, now.day - 1),
        AuditTimeFilter.last7Days => now.subtract(const Duration(days: 7)),
        AuditTimeFilter.last30Days => now.subtract(const Duration(days: 30)),
        AuditTimeFilter.custom => DateTime(2000), // No cutoff for custom
      };
      if (entry.timestamp.isBefore(cutoff)) return false;

      // Action filter
      if (_auditActionFilter.isNotEmpty &&
          !_auditActionFilter.contains(entry.action)) {
        return false;
      }

      // Module filter
      if (_auditModuleFilter != null &&
          entry.moduleName != _auditModuleFilter) {
        return false;
      }

      return true;
    }).toList();
  }

  void _addAuditEntry(AuditAction action, String description) {
    _auditLog.insert(
      0,
      AuditLogEntry(
        id: 'a${_auditLog.length + 1}',
        timestamp: DateTime.now(),
        action: action,
        description: description,
      ),
    );
  }

  // ─── Business/Branch Context Settings ────────────────────────────────────
  BusinessSettings _businessSettings = const BusinessSettings();
  BusinessSettings get businessSettings => _businessSettings;

  BranchSettings _branchSettings = const BranchSettings();
  BranchSettings get branchSettings => _branchSettings;

  // ─── Data Privacy Categories (for Privacy Control Center) ────────────────
  List<DataCategory> get dataCategories => const [
        DataCategory(
          name: 'Personal Info',
          description: 'Name, email, phone, address',
          purpose: 'Account identification & communication',
          visibility: 'You, admins of your entities',
          retention: 'Until account deletion',
          relativeSize: 3.0,
          color: Color(0xFF6366F1),
        ),
        DataCategory(
          name: 'Financial Data',
          description: 'QPoints balance, transactions, tabs',
          purpose: 'Payment processing & history',
          visibility: 'You only (encrypted)',
          retention: '7 years (regulatory)',
          relativeSize: 2.5,
          color: Color(0xFF10B981),
        ),
        DataCategory(
          name: 'Location',
          description: 'GPS data during delivery/rides',
          purpose: 'Logistics, safety, navigation',
          visibility: 'You, assigned drivers (during active delivery)',
          retention: '30 days',
          relativeSize: 2.0,
          color: Color(0xFFF59E0B),
        ),
        DataCategory(
          name: 'Messages',
          description: 'qualChat messages, HeyYa interactions',
          purpose: 'Communication',
          visibility: 'You and recipients',
          retention: '1 year (configurable)',
          relativeSize: 2.0,
          color: Color(0xFF06B6D4),
        ),
        DataCategory(
          name: 'Usage Analytics',
          description: 'Feature usage, session duration',
          purpose: 'Product improvement',
          visibility: 'Aggregated (anonymized)',
          retention: '2 years',
          relativeSize: 1.5,
          color: Color(0xFF8B5CF6),
        ),
        DataCategory(
          name: 'Biometrics',
          description: 'Face ID / fingerprint templates',
          purpose: 'Authentication',
          visibility: 'Device secure enclave only',
          retention: 'Until biometric reset',
          relativeSize: 1.0,
          color: Color(0xFFEF4444),
        ),
        DataCategory(
          name: 'Social Graph',
          description: 'Contacts, connections, interactions',
          purpose: 'Social features, recommendations',
          visibility: 'You (contacts visible to mutual connections)',
          retention: 'Until removal',
          relativeSize: 1.5,
          color: Color(0xFFEC4899),
        ),
      ];
}
