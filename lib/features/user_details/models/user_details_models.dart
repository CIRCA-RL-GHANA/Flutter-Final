/// ═══════════════════════════════════════════════════════════════════════════
/// USER DETAILS Models
/// Complete identity, security, privacy, accessibility, notifications,
/// audit trail, and device management models
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

// ─── Identity ────────────────────────────────────────────────────────────────

class UserIdentity {
  final String id;
  final String legalName;
  final String displayName;
  final String handle;
  final String? bio;
  final String? email;
  final bool emailVerified;
  final String? phone;
  final bool phoneVerified;
  final String? address;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final Gender gender;
  final String primaryLanguage;
  final List<String> secondaryLanguages;
  final DateTime joinedDate;
  final VerificationLevel verificationLevel;
  final double profileCompleteness;
  final String? taxId;
  final List<EmergencyContact> emergencyContacts;

  const UserIdentity({
    required this.id,
    required this.legalName,
    required this.displayName,
    required this.handle,
    this.bio,
    this.email,
    this.emailVerified = false,
    this.phone,
    this.phoneVerified = false,
    this.address,
    this.avatarUrl,
    this.dateOfBirth,
    this.gender = Gender.preferNotToSay,
    this.primaryLanguage = 'English',
    this.secondaryLanguages = const [],
    required this.joinedDate,
    this.verificationLevel = VerificationLevel.none,
    this.profileCompleteness = 0.0,
    this.taxId,
    this.emergencyContacts = const [],
  });

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int years = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      years--;
    }
    return years;
  }

  UserIdentity copyWith({
    String? legalName,
    String? displayName,
    String? handle,
    String? bio,
    String? email,
    bool? emailVerified,
    String? phone,
    bool? phoneVerified,
    String? address,
    String? avatarUrl,
    DateTime? dateOfBirth,
    Gender? gender,
    String? primaryLanguage,
    List<String>? secondaryLanguages,
    VerificationLevel? verificationLevel,
    double? profileCompleteness,
    String? taxId,
    List<EmergencyContact>? emergencyContacts,
  }) {
    return UserIdentity(
      id: id,
      legalName: legalName ?? this.legalName,
      displayName: displayName ?? this.displayName,
      handle: handle ?? this.handle,
      bio: bio ?? this.bio,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      phone: phone ?? this.phone,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      primaryLanguage: primaryLanguage ?? this.primaryLanguage,
      secondaryLanguages: secondaryLanguages ?? this.secondaryLanguages,
      joinedDate: joinedDate,
      verificationLevel: verificationLevel ?? this.verificationLevel,
      profileCompleteness: profileCompleteness ?? this.profileCompleteness,
      taxId: taxId ?? this.taxId,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
    );
  }
}

enum Gender {
  male,
  female,
  nonBinary,
  other,
  preferNotToSay;

  String get label {
    switch (this) {
      case Gender.male: return 'Male';
      case Gender.female: return 'Female';
      case Gender.nonBinary: return 'Non-binary';
      case Gender.other: return 'Other';
      case Gender.preferNotToSay: return 'Prefer not to say';
    }
  }
}

enum VerificationLevel {
  none,
  emailOnly,
  phoneOnly,
  basicKYC,
  fullKYC;

  String get label {
    switch (this) {
      case VerificationLevel.none: return 'Not Verified';
      case VerificationLevel.emailOnly: return 'Email Verified';
      case VerificationLevel.phoneOnly: return 'Phone Verified';
      case VerificationLevel.basicKYC: return 'Basic KYC';
      case VerificationLevel.fullKYC: return 'ID Verified';
    }
  }

  IconData get icon {
    switch (this) {
      case VerificationLevel.none: return Icons.warning_amber;
      case VerificationLevel.emailOnly:
      case VerificationLevel.phoneOnly: return Icons.check_circle_outline;
      case VerificationLevel.basicKYC: return Icons.verified_user_outlined;
      case VerificationLevel.fullKYC: return Icons.verified;
    }
  }

  Color get color {
    switch (this) {
      case VerificationLevel.none: return const Color(0xFFF59E0B);
      case VerificationLevel.emailOnly:
      case VerificationLevel.phoneOnly: return const Color(0xFF3B82F6);
      case VerificationLevel.basicKYC: return const Color(0xFF8B5CF6);
      case VerificationLevel.fullKYC: return const Color(0xFF10B981);
    }
  }
}

class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String relationship;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relationship,
  });
}

// ─── Security ────────────────────────────────────────────────────────────────

class SecuritySettings {
  final AuthMethod primaryAuth;
  final AuthMethod? secondaryAuth;
  final AuthMethod? tertiaryAuth;
  final bool twoFactorEnabled;
  final TwoFactorType? twoFactorType;
  final List<ActiveSession> activeSessions;
  final int failedAttempts;
  final int maxFailedAttempts;
  final DateTime? lastPasswordChange;
  final int passwordHealthScore;
  final DateTime? lastSecurityAudit;
  final List<SecurityEvent> securityLog;
  final bool autoLockEnabled;
  final Duration autoLockTimeout;
  final bool deadManSwitchEnabled;
  final Duration? deadManSwitchPeriod;

  const SecuritySettings({
    this.primaryAuth = AuthMethod.biometric,
    this.secondaryAuth = AuthMethod.pin,
    this.tertiaryAuth,
    this.twoFactorEnabled = true,
    this.twoFactorType = TwoFactorType.authenticator,
    this.activeSessions = const [],
    this.failedAttempts = 0,
    this.maxFailedAttempts = 5,
    this.lastPasswordChange,
    this.passwordHealthScore = 85,
    this.lastSecurityAudit,
    this.securityLog = const [],
    this.autoLockEnabled = true,
    this.autoLockTimeout = const Duration(minutes: 5),
    this.deadManSwitchEnabled = false,
    this.deadManSwitchPeriod,
  });

  SecuritySettings copyWith({
    AuthMethod? primaryAuth,
    AuthMethod? secondaryAuth,
    AuthMethod? tertiaryAuth,
    bool? twoFactorEnabled,
    TwoFactorType? twoFactorType,
    List<ActiveSession>? activeSessions,
    int? failedAttempts,
    int? passwordHealthScore,
    bool? autoLockEnabled,
    Duration? autoLockTimeout,
    bool? deadManSwitchEnabled,
    Duration? deadManSwitchPeriod,
  }) {
    return SecuritySettings(
      primaryAuth: primaryAuth ?? this.primaryAuth,
      secondaryAuth: secondaryAuth ?? this.secondaryAuth,
      tertiaryAuth: tertiaryAuth ?? this.tertiaryAuth,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      twoFactorType: twoFactorType ?? this.twoFactorType,
      activeSessions: activeSessions ?? this.activeSessions,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      maxFailedAttempts: maxFailedAttempts,
      lastPasswordChange: lastPasswordChange,
      passwordHealthScore: passwordHealthScore ?? this.passwordHealthScore,
      lastSecurityAudit: lastSecurityAudit,
      securityLog: securityLog,
      autoLockEnabled: autoLockEnabled ?? this.autoLockEnabled,
      autoLockTimeout: autoLockTimeout ?? this.autoLockTimeout,
      deadManSwitchEnabled: deadManSwitchEnabled ?? this.deadManSwitchEnabled,
      deadManSwitchPeriod: deadManSwitchPeriod ?? this.deadManSwitchPeriod,
    );
  }
}

enum AuthMethod {
  biometric,
  pin,
  pattern,
  password,
  none;

  String get label {
    switch (this) {
      case AuthMethod.biometric: return 'Biometric (Face ID / Fingerprint)';
      case AuthMethod.pin: return '6-Digit PIN';
      case AuthMethod.pattern: return 'Pattern Lock';
      case AuthMethod.password: return 'Password';
      case AuthMethod.none: return 'None';
    }
  }

  IconData get icon {
    switch (this) {
      case AuthMethod.biometric: return Icons.fingerprint;
      case AuthMethod.pin: return Icons.dialpad;
      case AuthMethod.pattern: return Icons.pattern;
      case AuthMethod.password: return Icons.lock;
      case AuthMethod.none: return Icons.lock_open;
    }
  }
}

enum TwoFactorType {
  authenticator,
  sms,
  email;

  String get label {
    switch (this) {
      case TwoFactorType.authenticator: return 'Google Authenticator';
      case TwoFactorType.sms: return 'SMS Code';
      case TwoFactorType.email: return 'Email Code';
    }
  }
}

class ActiveSession {
  final String id;
  final String deviceName;
  final String deviceType;
  final String os;
  final String location;
  final DateTime lastActive;
  final bool isCurrent;
  final bool isTrusted;

  const ActiveSession({
    required this.id,
    required this.deviceName,
    required this.deviceType,
    required this.os,
    required this.location,
    required this.lastActive,
    this.isCurrent = false,
    this.isTrusted = false,
  });

  IconData get deviceIcon {
    switch (deviceType) {
      case 'phone': return Icons.phone_android;
      case 'tablet': return Icons.tablet;
      case 'desktop': return Icons.computer;
      case 'web': return Icons.language;
      default: return Icons.devices;
    }
  }
}

class SecurityEvent {
  final String id;
  final String description;
  final DateTime timestamp;
  final SecurityEventSeverity severity;
  final String? deviceName;
  final String? location;

  const SecurityEvent({
    required this.id,
    required this.description,
    required this.timestamp,
    this.severity = SecurityEventSeverity.info,
    this.deviceName,
    this.location,
  });
}

enum SecurityEventSeverity {
  info,
  warning,
  critical;

  Color get color {
    switch (this) {
      case SecurityEventSeverity.info: return const Color(0xFF3B82F6);
      case SecurityEventSeverity.warning: return const Color(0xFFF59E0B);
      case SecurityEventSeverity.critical: return const Color(0xFFEF4444);
    }
  }
}

// ─── Privacy ─────────────────────────────────────────────────────────────────

class PrivacySettings {
  final ProfileVisibility profileVisibility;
  final DataSharingLevel dataSharingLevel;
  final LocationTracking locationTracking;
  final bool contactSyncEnabled;
  final bool usageAnalyticsEnabled;
  final bool socialGraphEnabled;
  final Map<String, bool> moduleDataSharing;
  final bool thirdPartyIntegrations;
  final bool marketingCommunications;
  final AutoDeleteSchedule autoDeleteSchedule;
  final Duration? archiveFrequency;
  final String? deceasedAccountHandler;
  final bool profileViewsEnabled;
  final int privacyScore;
  final DateTime? lastDataExport;

  const PrivacySettings({
    this.profileVisibility = ProfileVisibility.contactsOnly,
    this.dataSharingLevel = DataSharingLevel.minimal,
    this.locationTracking = LocationTracking.whileUsingApp,
    this.contactSyncEnabled = false,
    this.usageAnalyticsEnabled = true,
    this.socialGraphEnabled = false,
    this.moduleDataSharing = const {},
    this.thirdPartyIntegrations = false,
    this.marketingCommunications = false,
    this.autoDeleteSchedule = AutoDeleteSchedule.yearly,
    this.archiveFrequency,
    this.deceasedAccountHandler,
    this.profileViewsEnabled = false,
    this.privacyScore = 85,
    this.lastDataExport,
  });

  PrivacySettings copyWith({
    ProfileVisibility? profileVisibility,
    DataSharingLevel? dataSharingLevel,
    LocationTracking? locationTracking,
    bool? contactSyncEnabled,
    bool? usageAnalyticsEnabled,
    bool? socialGraphEnabled,
    Map<String, bool>? moduleDataSharing,
    bool? thirdPartyIntegrations,
    bool? marketingCommunications,
    AutoDeleteSchedule? autoDeleteSchedule,
    bool? profileViewsEnabled,
    int? privacyScore,
    DateTime? lastDataExport,
  }) {
    return PrivacySettings(
      profileVisibility: profileVisibility ?? this.profileVisibility,
      dataSharingLevel: dataSharingLevel ?? this.dataSharingLevel,
      locationTracking: locationTracking ?? this.locationTracking,
      contactSyncEnabled: contactSyncEnabled ?? this.contactSyncEnabled,
      usageAnalyticsEnabled: usageAnalyticsEnabled ?? this.usageAnalyticsEnabled,
      socialGraphEnabled: socialGraphEnabled ?? this.socialGraphEnabled,
      moduleDataSharing: moduleDataSharing ?? this.moduleDataSharing,
      thirdPartyIntegrations: thirdPartyIntegrations ?? this.thirdPartyIntegrations,
      marketingCommunications: marketingCommunications ?? this.marketingCommunications,
      autoDeleteSchedule: autoDeleteSchedule ?? this.autoDeleteSchedule,
      profileViewsEnabled: profileViewsEnabled ?? this.profileViewsEnabled,
      privacyScore: privacyScore ?? this.privacyScore,
      lastDataExport: lastDataExport ?? this.lastDataExport,
    );
  }
}

enum ProfileVisibility {
  everyone,
  contactsOnly,
  nobody;

  String get label {
    switch (this) {
      case ProfileVisibility.everyone: return 'Everyone';
      case ProfileVisibility.contactsOnly: return 'Contacts Only';
      case ProfileVisibility.nobody: return 'Nobody';
    }
  }
}

enum DataSharingLevel {
  full,
  moderate,
  minimal,
  none;

  String get label {
    switch (this) {
      case DataSharingLevel.full: return 'Full';
      case DataSharingLevel.moderate: return 'Moderate';
      case DataSharingLevel.minimal: return 'Minimal';
      case DataSharingLevel.none: return 'None';
    }
  }
}

enum LocationTracking {
  always,
  whileUsingApp,
  never;

  String get label {
    switch (this) {
      case LocationTracking.always: return 'Always';
      case LocationTracking.whileUsingApp: return 'While Using App';
      case LocationTracking.never: return 'Never';
    }
  }
}

enum AutoDeleteSchedule {
  monthly,
  quarterly,
  yearly,
  never;

  String get label {
    switch (this) {
      case AutoDeleteSchedule.monthly: return 'Monthly';
      case AutoDeleteSchedule.quarterly: return 'Every 3 Months';
      case AutoDeleteSchedule.yearly: return 'Yearly';
      case AutoDeleteSchedule.never: return 'Never';
    }
  }
}

// ─── Accessibility ───────────────────────────────────────────────────────────

class AccessibilitySettings {
  // Vision
  final double textScale;
  final String fontFamily;
  final bool highContrast;
  final bool screenMagnifier;

  // Hearing
  final bool visualAlerts;
  final bool captionsEnabled;
  final bool monoAudio;
  final double volumeBalance;

  // Motor
  final double touchSensitivity;
  final bool gestureSimplification;
  final bool switchControl;
  final bool voiceControl;

  // Cognitive
  final bool reducedMotion;
  final bool simplifiedLayout;
  final bool focusAssist;
  final bool readingAssistance;

  // Presets
  final String? activePresetName;

  const AccessibilitySettings({
    this.textScale = 1.0,
    this.fontFamily = 'System',
    this.highContrast = false,
    this.screenMagnifier = false,
    this.visualAlerts = false,
    this.captionsEnabled = false,
    this.monoAudio = false,
    this.volumeBalance = 0.5,
    this.touchSensitivity = 0.5,
    this.gestureSimplification = false,
    this.switchControl = false,
    this.voiceControl = false,
    this.reducedMotion = false,
    this.simplifiedLayout = false,
    this.focusAssist = false,
    this.readingAssistance = false,
    this.activePresetName,
  });

  AccessibilitySettings copyWith({
    double? textScale,
    String? fontFamily,
    bool? highContrast,
    bool? screenMagnifier,
    bool? visualAlerts,
    bool? captionsEnabled,
    bool? monoAudio,
    double? volumeBalance,
    double? touchSensitivity,
    bool? gestureSimplification,
    bool? switchControl,
    bool? voiceControl,
    bool? reducedMotion,
    bool? simplifiedLayout,
    bool? focusAssist,
    bool? readingAssistance,
    String? activePresetName,
  }) {
    return AccessibilitySettings(
      textScale: textScale ?? this.textScale,
      fontFamily: fontFamily ?? this.fontFamily,
      highContrast: highContrast ?? this.highContrast,
      screenMagnifier: screenMagnifier ?? this.screenMagnifier,
      visualAlerts: visualAlerts ?? this.visualAlerts,
      captionsEnabled: captionsEnabled ?? this.captionsEnabled,
      monoAudio: monoAudio ?? this.monoAudio,
      volumeBalance: volumeBalance ?? this.volumeBalance,
      touchSensitivity: touchSensitivity ?? this.touchSensitivity,
      gestureSimplification: gestureSimplification ?? this.gestureSimplification,
      switchControl: switchControl ?? this.switchControl,
      voiceControl: voiceControl ?? this.voiceControl,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      simplifiedLayout: simplifiedLayout ?? this.simplifiedLayout,
      focusAssist: focusAssist ?? this.focusAssist,
      readingAssistance: readingAssistance ?? this.readingAssistance,
      activePresetName: activePresetName ?? this.activePresetName,
    );
  }
}

class AccessibilityPreset {
  final String name;
  final AccessibilitySettings settings;
  final bool applyToAllDevices;

  const AccessibilityPreset({
    required this.name,
    required this.settings,
    this.applyToAllDevices = false,
  });
}

// ─── Notification Settings ───────────────────────────────────────────────────

class NotificationSettings {
  final bool globalEnabled;
  final NotificationMode activeMode;
  final Map<String, ModuleNotificationConfig> moduleConfigs;
  final TimeOfDay quietHoursStart;
  final TimeOfDay quietHoursEnd;
  final bool quietHoursEnabled;
  final List<SmartNotificationRule> smartRules;

  const NotificationSettings({
    this.globalEnabled = true,
    this.activeMode = NotificationMode.normal,
    this.moduleConfigs = const {},
    this.quietHoursStart = const TimeOfDay(hour: 22, minute: 0),
    this.quietHoursEnd = const TimeOfDay(hour: 7, minute: 0),
    this.quietHoursEnabled = true,
    this.smartRules = const [],
  });

  NotificationSettings copyWith({
    bool? globalEnabled,
    NotificationMode? activeMode,
    Map<String, ModuleNotificationConfig>? moduleConfigs,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
    bool? quietHoursEnabled,
    List<SmartNotificationRule>? smartRules,
  }) {
    return NotificationSettings(
      globalEnabled: globalEnabled ?? this.globalEnabled,
      activeMode: activeMode ?? this.activeMode,
      moduleConfigs: moduleConfigs ?? this.moduleConfigs,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      smartRules: smartRules ?? this.smartRules,
    );
  }
}

enum NotificationMode {
  normal,
  work,
  sleep,
  vacation,
  meeting;

  String get label {
    switch (this) {
      case NotificationMode.normal: return 'Normal';
      case NotificationMode.work: return 'Work Mode';
      case NotificationMode.sleep: return 'Sleep Mode';
      case NotificationMode.vacation: return 'Vacation Mode';
      case NotificationMode.meeting: return 'Meeting Mode';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationMode.normal: return Icons.notifications;
      case NotificationMode.work: return Icons.work;
      case NotificationMode.sleep: return Icons.bedtime;
      case NotificationMode.vacation: return Icons.beach_access;
      case NotificationMode.meeting: return Icons.meeting_room;
    }
  }
}

class ModuleNotificationConfig {
  final String moduleName;
  final bool pushEnabled;
  final String soundName;
  final bool vibrateOnly;
  final int priority;
  final bool overrideQuietHours;

  const ModuleNotificationConfig({
    required this.moduleName,
    this.pushEnabled = true,
    this.soundName = 'default',
    this.vibrateOnly = false,
    this.priority = 3,
    this.overrideQuietHours = false,
  });

  ModuleNotificationConfig copyWith({
    bool? pushEnabled,
    String? soundName,
    bool? vibrateOnly,
    int? priority,
    bool? overrideQuietHours,
  }) {
    return ModuleNotificationConfig(
      moduleName: moduleName,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      soundName: soundName ?? this.soundName,
      vibrateOnly: vibrateOnly ?? this.vibrateOnly,
      priority: priority ?? this.priority,
      overrideQuietHours: overrideQuietHours ?? this.overrideQuietHours,
    );
  }
}

class SmartNotificationRule {
  final String id;
  final String condition;
  final String action;
  final bool enabled;

  const SmartNotificationRule({
    required this.id,
    required this.condition,
    required this.action,
    this.enabled = true,
  });
}

// ─── Audit Log ───────────────────────────────────────────────────────────────

class AuditLogEntry {
  final String id;
  final DateTime timestamp;
  final AuditAction action;
  final String description;
  final String? contextName;
  final String? deviceName;
  final String? location;
  final String? moduleName;
  final AuditAnomaly? anomaly;

  const AuditLogEntry({
    required this.id,
    required this.timestamp,
    required this.action,
    required this.description,
    this.contextName,
    this.deviceName,
    this.location,
    this.moduleName,
    this.anomaly,
  });

  IconData get actionIcon {
    switch (action) {
      case AuditAction.create: return Icons.add_circle_outline;
      case AuditAction.read: return Icons.visibility_outlined;
      case AuditAction.update: return Icons.edit_outlined;
      case AuditAction.delete: return Icons.delete_outline;
      case AuditAction.login: return Icons.login;
      case AuditAction.logout: return Icons.logout;
      case AuditAction.contextSwitch: return Icons.swap_horiz;
      case AuditAction.settingsChange: return Icons.settings;
      case AuditAction.securityEvent: return Icons.shield;
      case AuditAction.export: return Icons.download;
    }
  }

  Color get actionColor {
    if (anomaly == AuditAnomaly.securityConcern) return const Color(0xFFEF4444);
    if (anomaly == AuditAnomaly.unusualActivity) return const Color(0xFFF59E0B);
    switch (action) {
      case AuditAction.create: return const Color(0xFF10B981);
      case AuditAction.delete: return const Color(0xFFEF4444);
      case AuditAction.securityEvent: return const Color(0xFFF59E0B);
      default: return const Color(0xFF3B82F6);
    }
  }
}

enum AuditAction {
  create,
  read,
  update,
  delete,
  login,
  logout,
  contextSwitch,
  settingsChange,
  securityEvent,
  export;

  String get label {
    switch (this) {
      case AuditAction.create: return 'Create';
      case AuditAction.read: return 'Read';
      case AuditAction.update: return 'Update';
      case AuditAction.delete: return 'Delete';
      case AuditAction.login: return 'Login';
      case AuditAction.logout: return 'Logout';
      case AuditAction.contextSwitch: return 'Context Switch';
      case AuditAction.settingsChange: return 'Settings Change';
      case AuditAction.securityEvent: return 'Security Event';
      case AuditAction.export: return 'Export';
    }
  }
}

enum AuditAnomaly {
  unusualActivity,
  securityConcern,
}

enum AuditTimeFilter {
  today,
  yesterday,
  last7Days,
  last30Days,
  custom;

  String get label {
    switch (this) {
      case AuditTimeFilter.today: return 'Today';
      case AuditTimeFilter.yesterday: return 'Yesterday';
      case AuditTimeFilter.last7Days: return 'Last 7 days';
      case AuditTimeFilter.last30Days: return 'Last 30 days';
      case AuditTimeFilter.custom: return 'Custom';
    }
  }
}

enum AuditExportFormat { pdf, csv, json, print }

// ─── Context Management ─────────────────────────────────────────────────────

enum ContextStatus {
  active,
  archived,
  pendingVerification;

  String get label {
    switch (this) {
      case ContextStatus.active: return 'Active';
      case ContextStatus.archived: return 'Archived';
      case ContextStatus.pendingVerification: return 'Pending';
    }
  }
}

enum ContextFilter {
  all,
  personal,
  business,
  branch;

  String get label {
    switch (this) {
      case ContextFilter.all: return 'All';
      case ContextFilter.personal: return 'Personal';
      case ContextFilter.business: return 'Business';
      case ContextFilter.branch: return 'Branch';
    }
  }
}

// ─── Entity Creation Steps ───────────────────────────────────────────────────

enum EntityCreationType {
  personal,
  business,
  branch,
  specialPurpose;

  String get label {
    switch (this) {
      case EntityCreationType.personal: return 'Personal Identity';
      case EntityCreationType.business: return 'Business Entity';
      case EntityCreationType.branch: return 'Branch Unit';
      case EntityCreationType.specialPurpose: return 'Special Purpose';
    }
  }

  String get subtitle {
    switch (this) {
      case EntityCreationType.personal: return 'Your personal profile and account';
      case EntityCreationType.business: return 'Company or organization entity';
      case EntityCreationType.branch: return 'Physical location or team unit';
      case EntityCreationType.specialPurpose: return 'Event, project, or campaign';
    }
  }

  IconData get icon {
    switch (this) {
      case EntityCreationType.personal: return Icons.person;
      case EntityCreationType.business: return Icons.business;
      case EntityCreationType.branch: return Icons.store;
      case EntityCreationType.specialPurpose: return Icons.star;
    }
  }

  Color get color {
    switch (this) {
      case EntityCreationType.personal: return const Color(0xFF6366F1);
      case EntityCreationType.business: return const Color(0xFF8B5CF6);
      case EntityCreationType.branch: return const Color(0xFF10B981);
      case EntityCreationType.specialPurpose: return const Color(0xFFF59E0B);
    }
  }
}

// ─── Business-Specific Settings ──────────────────────────────────────────────

class BusinessSettings {
  final String? registrationNumber;
  final String? industry;
  final String? employeeRange;
  final TimeOfDay businessHoursStart;
  final TimeOfDay businessHoursEnd;
  final String? autoReplyMessage;
  final bool vacationMode;

  const BusinessSettings({
    this.registrationNumber,
    this.industry,
    this.employeeRange,
    this.businessHoursStart = const TimeOfDay(hour: 9, minute: 0),
    this.businessHoursEnd = const TimeOfDay(hour: 17, minute: 0),
    this.autoReplyMessage,
    this.vacationMode = false,
  });
}

class BranchSettings {
  final String? shiftPattern;
  final Duration? breakDuration;
  final double coverageRadiusKm;
  final String? parentEntityId;

  const BranchSettings({
    this.shiftPattern,
    this.breakDuration,
    this.coverageRadiusKm = 10.0,
    this.parentEntityId,
  });
}

// ─── Sync & Conflict Resolution ──────────────────────────────────────────────

enum ConflictResolution { useLocal, useRemote, merge }

class SyncConflict {
  final String fieldName;
  final String localValue;
  final String remoteValue;
  final DateTime localTimestamp;
  final DateTime remoteTimestamp;
  final ConflictResolution? resolution;

  const SyncConflict({
    required this.fieldName,
    required this.localValue,
    required this.remoteValue,
    required this.localTimestamp,
    required this.remoteTimestamp,
    this.resolution,
  });
}

// ─── Data Privacy Types ──────────────────────────────────────────────────────

class DataCategory {
  final String name;
  final String description;
  final String purpose;
  final String visibility;
  final String retention;
  final double relativeSize;
  final Color color;

  const DataCategory({
    required this.name,
    required this.description,
    required this.purpose,
    required this.visibility,
    required this.retention,
    this.relativeSize = 1.0,
    required this.color,
  });
}
