/// ═══════════════════════════════════════════════════════════════════════════
/// UTILITY MODULE Models
/// Complete data models for all 9 screens: Dashboard, Settings, Notifications,
/// Search, Help, Privacy, Accessibility, Advanced Data, System Monitor
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// U0 - DASHBOARD MODELS
// ═══════════════════════════════════════════════════════════════════════════════

/// Quick action item for the utility dashboard
class UtilityQuickAction {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  final int? badgeCount;
  final bool enabled;

  const UtilityQuickAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.route,
    this.badgeCount,
    this.enabled = true,
  });
}

/// System health summary card
class SystemHealthSummary {
  final double overallScore;
  final int activeAlerts;
  final double storageUsedMB;
  final double storageTotalMB;
  final DateTime lastBackup;
  final int pendingUpdates;
  final ConnectionStatus connectionStatus;

  const SystemHealthSummary({
    required this.overallScore,
    required this.activeAlerts,
    required this.storageUsedMB,
    required this.storageTotalMB,
    required this.lastBackup,
    required this.pendingUpdates,
    required this.connectionStatus,
  });

  double get storagePercentage =>
      storageTotalMB > 0 ? storageUsedMB / storageTotalMB : 0.0;
}

enum ConnectionStatus { online, offline, degraded }

/// Recent activity item
class RecentActivity {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final DateTime timestamp;
  final ActivityCategory category;

  const RecentActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.timestamp,
    required this.category,
  });
}

enum ActivityCategory { system, security, data, user, notification }

// ═══════════════════════════════════════════════════════════════════════════════
// U1 - SETTINGS MODELS
// ═══════════════════════════════════════════════════════════════════════════════

/// App theme preference
enum ThemePreference { light, dark, system }

/// Language option
class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final bool isRTL;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    this.isRTL = false,
  });
}

/// Date format preference
enum DateFormatPreference { ddMMYYYY, mmDDYYYY, yyyyMMDD }

/// Time format preference
enum TimeFormatPreference { twelve, twentyFour }

/// Settings group
class SettingsGroup {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final List<SettingItem> items;

  const SettingsGroup({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });
}

/// Individual setting item
class SettingItem {
  final String id;
  final String label;
  final String? subtitle;
  final IconData icon;
  final SettingType type;
  final dynamic value;

  const SettingItem({
    required this.id,
    required this.label,
    this.subtitle,
    required this.icon,
    required this.type,
    this.value,
  });
}

enum SettingType { toggle, selector, navigation, action, slider }

/// User preferences model
class UserPreferences {
  final ThemePreference theme;
  final String languageCode;
  final DateFormatPreference dateFormat;
  final TimeFormatPreference timeFormat;
  final bool hapticFeedback;
  final bool soundEffects;
  final bool autoUpdate;
  final bool analyticsEnabled;
  final bool crashReportingEnabled;
  final double textScaleFactor;
  final bool compactMode;
  final bool showAnimations;

  const UserPreferences({
    this.theme = ThemePreference.system,
    this.languageCode = 'en',
    this.dateFormat = DateFormatPreference.ddMMYYYY,
    this.timeFormat = TimeFormatPreference.twelve,
    this.hapticFeedback = true,
    this.soundEffects = true,
    this.autoUpdate = true,
    this.analyticsEnabled = true,
    this.crashReportingEnabled = true,
    this.textScaleFactor = 1.0,
    this.compactMode = false,
    this.showAnimations = true,
  });

  UserPreferences copyWith({
    ThemePreference? theme,
    String? languageCode,
    DateFormatPreference? dateFormat,
    TimeFormatPreference? timeFormat,
    bool? hapticFeedback,
    bool? soundEffects,
    bool? autoUpdate,
    bool? analyticsEnabled,
    bool? crashReportingEnabled,
    double? textScaleFactor,
    bool? compactMode,
    bool? showAnimations,
  }) {
    return UserPreferences(
      theme: theme ?? this.theme,
      languageCode: languageCode ?? this.languageCode,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      soundEffects: soundEffects ?? this.soundEffects,
      autoUpdate: autoUpdate ?? this.autoUpdate,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      crashReportingEnabled: crashReportingEnabled ?? this.crashReportingEnabled,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      compactMode: compactMode ?? this.compactMode,
      showAnimations: showAnimations ?? this.showAnimations,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// U2 - NOTIFICATION MODELS
// ═══════════════════════════════════════════════════════════════════════════════

/// Notification priority
enum NotificationPriority { critical, high, medium, low }

/// Notification type
enum NotificationType {
  system,
  security,
  transaction,
  social,
  promotion,
  reminder,
  alert,
  update,
}

/// Notification item
class NotificationItem {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime timestamp;
  final bool isRead;
  final bool isArchived;
  final String? actionRoute;
  final String? imageUrl;
  final String? senderName;
  final Map<String, dynamic>? metadata;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.priority,
    required this.timestamp,
    this.isRead = false,
    this.isArchived = false,
    this.actionRoute,
    this.imageUrl,
    this.senderName,
    this.metadata,
  });

  NotificationItem copyWith({
    bool? isRead,
    bool? isArchived,
  }) {
    return NotificationItem(
      id: id,
      title: title,
      body: body,
      type: type,
      priority: priority,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      isArchived: isArchived ?? this.isArchived,
      actionRoute: actionRoute,
      imageUrl: imageUrl,
      senderName: senderName,
      metadata: metadata,
    );
  }

  IconData get typeIcon {
    switch (type) {
      case NotificationType.system:
        return Icons.settings;
      case NotificationType.security:
        return Icons.security;
      case NotificationType.transaction:
        return Icons.payment;
      case NotificationType.social:
        return Icons.people;
      case NotificationType.promotion:
        return Icons.local_offer;
      case NotificationType.reminder:
        return Icons.alarm;
      case NotificationType.alert:
        return Icons.warning_amber;
      case NotificationType.update:
        return Icons.system_update;
    }
  }

  Color get priorityColor {
    switch (priority) {
      case NotificationPriority.critical:
        return const Color(0xFFEF4444);
      case NotificationPriority.high:
        return const Color(0xFFF59E0B);
      case NotificationPriority.medium:
        return const Color(0xFF3B82F6);
      case NotificationPriority.low:
        return const Color(0xFF9CA3AF);
    }
  }
}

/// Notification filter
enum NotificationFilter { all, unread, read, archived }

// ═══════════════════════════════════════════════════════════════════════════════
// U3 - SEARCH MODELS
// ═══════════════════════════════════════════════════════════════════════════════

/// Search category
enum SearchCategory {
  all,
  people,
  transactions,
  messages,
  settings,
  help,
  products,
  orders,
}

/// Search result
class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final SearchCategory category;
  final IconData icon;
  final Color iconColor;
  final String? route;
  final double relevanceScore;
  final String? highlightedText;
  final DateTime? lastAccessed;

  const SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    required this.iconColor,
    this.route,
    this.relevanceScore = 1.0,
    this.highlightedText,
    this.lastAccessed,
  });
}

/// Recent search
class RecentSearch {
  final String query;
  final SearchCategory? category;
  final DateTime timestamp;

  const RecentSearch({
    required this.query,
    this.category,
    required this.timestamp,
  });
}

/// Search suggestion
class SearchSuggestion {
  final String text;
  final IconData icon;
  final SearchCategory category;

  const SearchSuggestion({
    required this.text,
    required this.icon,
    required this.category,
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// U4 - HELP & SUPPORT MODELS
// ═══════════════════════════════════════════════════════════════════════════════

/// Help category
enum HelpCategory {
  gettingStarted,
  account,
  payments,
  orders,
  security,
  troubleshooting,
  contact,
}

/// FAQ article
class HelpArticle {
  final String id;
  final String title;
  final String content;
  final HelpCategory category;
  final IconData icon;
  final int viewCount;
  final bool isPinned;
  final List<String> tags;
  final DateTime updatedAt;

  const HelpArticle({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.icon,
    this.viewCount = 0,
    this.isPinned = false,
    this.tags = const [],
    required this.updatedAt,
  });
}

/// Support ticket
class SupportTicket {
  final String id;
  final String subject;
  final String description;
  final TicketStatus status;
  final TicketPriority priority;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? assignedAgent;
  final List<TicketMessage> messages;

  const SupportTicket({
    required this.id,
    required this.subject,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.resolvedAt,
    this.assignedAgent,
    this.messages = const [],
  });
}

enum TicketStatus { open, inProgress, waitingOnUser, resolved, closed }

enum TicketPriority { low, medium, high, urgent }

/// Ticket message
class TicketMessage {
  final String id;
  final String content;
  final bool isAgent;
  final DateTime timestamp;

  const TicketMessage({
    required this.id,
    required this.content,
    required this.isAgent,
    required this.timestamp,
  });
}

/// Contact option
class ContactOption {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String action;

  const ContactOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.action,
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// U5 - DATA & PRIVACY MODELS
// ═══════════════════════════════════════════════════════════════════════════════

/// Privacy setting
class PrivacySetting {
  final String id;
  final String label;
  final String description;
  final IconData icon;
  final bool enabled;
  final PrivacyLevel level;

  const PrivacySetting({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    this.enabled = true,
    this.level = PrivacyLevel.standard,
  });

  PrivacySetting copyWith({
    bool? enabled,
    PrivacyLevel? level,
  }) {
    return PrivacySetting(
      id: id,
      label: label,
      description: description,
      icon: icon,
      enabled: enabled ?? this.enabled,
      level: level ?? this.level,
    );
  }
}

enum PrivacyLevel { minimal, standard, strict, maximum }

/// Data category for storage breakdown
class DataCategory {
  final String name;
  final IconData icon;
  final Color color;
  final double sizeMB;
  final int itemCount;

  const DataCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.sizeMB,
    required this.itemCount,
  });
}

/// Connected app / third-party integration
class ConnectedApp {
  final String id;
  final String name;
  final String? iconUrl;
  final IconData icon;
  final List<String> permissions;
  final DateTime connectedAt;
  final DateTime? lastAccessed;
  final bool isActive;

  const ConnectedApp({
    required this.id,
    required this.name,
    this.iconUrl,
    required this.icon,
    required this.permissions,
    required this.connectedAt,
    this.lastAccessed,
    this.isActive = true,
  });
}

/// Data export request
class DataExportRequest {
  final String id;
  final DataExportFormat format;
  final DataExportStatus status;
  final DateTime requestedAt;
  final DateTime? completedAt;
  final double? fileSizeMB;

  const DataExportRequest({
    required this.id,
    required this.format,
    required this.status,
    required this.requestedAt,
    this.completedAt,
    this.fileSizeMB,
  });
}

enum DataExportFormat { json, csv, pdf }
enum DataExportStatus { pending, processing, ready, expired, failed }

// ═══════════════════════════════════════════════════════════════════════════════
// U6 - ACCESSIBILITY MODELS
// ═══════════════════════════════════════════════════════════════════════════════

/// Accessibility configuration
class AccessibilityConfig {
  final double textScale;
  final bool boldText;
  final bool highContrast;
  final bool reduceMotion;
  final bool reduceTransparency;
  final bool screenReaderOptimized;
  final ColorBlindnessMode colorBlindnessMode;
  final bool hapticFeedback;
  final bool audioDescriptions;
  final double touchTargetSize;
  final bool showFocusIndicators;
  final bool largePointer;

  const AccessibilityConfig({
    this.textScale = 1.0,
    this.boldText = false,
    this.highContrast = false,
    this.reduceMotion = false,
    this.reduceTransparency = false,
    this.screenReaderOptimized = false,
    this.colorBlindnessMode = ColorBlindnessMode.none,
    this.hapticFeedback = true,
    this.audioDescriptions = false,
    this.touchTargetSize = 48.0,
    this.showFocusIndicators = false,
    this.largePointer = false,
  });

  AccessibilityConfig copyWith({
    double? textScale,
    bool? boldText,
    bool? highContrast,
    bool? reduceMotion,
    bool? reduceTransparency,
    bool? screenReaderOptimized,
    ColorBlindnessMode? colorBlindnessMode,
    bool? hapticFeedback,
    bool? audioDescriptions,
    double? touchTargetSize,
    bool? showFocusIndicators,
    bool? largePointer,
  }) {
    return AccessibilityConfig(
      textScale: textScale ?? this.textScale,
      boldText: boldText ?? this.boldText,
      highContrast: highContrast ?? this.highContrast,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      reduceTransparency: reduceTransparency ?? this.reduceTransparency,
      screenReaderOptimized: screenReaderOptimized ?? this.screenReaderOptimized,
      colorBlindnessMode: colorBlindnessMode ?? this.colorBlindnessMode,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      audioDescriptions: audioDescriptions ?? this.audioDescriptions,
      touchTargetSize: touchTargetSize ?? this.touchTargetSize,
      showFocusIndicators: showFocusIndicators ?? this.showFocusIndicators,
      largePointer: largePointer ?? this.largePointer,
    );
  }
}

enum ColorBlindnessMode {
  none,
  protanopia,
  deuteranopia,
  tritanopia,
  achromatopsia,
}

/// Accessibility preset
class AccessibilityPreset {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final AccessibilityConfig config;

  const AccessibilityPreset({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.config,
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// U7 - ADVANCED DATA TOOLS MODELS
// ═══════════════════════════════════════════════════════════════════════════════

/// Data backup
class DataBackup {
  final String id;
  final DateTime createdAt;
  final double sizeMB;
  final BackupStatus status;
  final BackupType type;
  final String? description;

  const DataBackup({
    required this.id,
    required this.createdAt,
    required this.sizeMB,
    required this.status,
    required this.type,
    this.description,
  });
}

enum BackupStatus { completed, inProgress, failed, scheduled }
enum BackupType { full, incremental, selective }

/// Cache info
class CacheInfo {
  final String category;
  final IconData icon;
  final double sizeMB;
  final int itemCount;
  final DateTime lastCleaned;

  const CacheInfo({
    required this.category,
    required this.icon,
    required this.sizeMB,
    required this.itemCount,
    required this.lastCleaned,
  });
}

/// Storage analytics
class StorageAnalytics {
  final double totalMB;
  final double usedMB;
  final List<DataCategory> breakdown;
  final DateTime lastAnalyzed;

  const StorageAnalytics({
    required this.totalMB,
    required this.usedMB,
    required this.breakdown,
    required this.lastAnalyzed,
  });

  double get freePercentage =>
      totalMB > 0 ? (totalMB - usedMB) / totalMB : 1.0;

  double get usedPercentage =>
      totalMB > 0 ? usedMB / totalMB : 0.0;
}

/// Sync status
class SyncStatus {
  final String module;
  final IconData icon;
  final DateTime lastSynced;
  final SyncState state;
  final int pendingItems;

  const SyncStatus({
    required this.module,
    required this.icon,
    required this.lastSynced,
    required this.state,
    required this.pendingItems,
  });
}

enum SyncState { synced, syncing, error, offline, pending }

// ═══════════════════════════════════════════════════════════════════════════════
// U8 - SYSTEM MONITOR MODELS
// ═══════════════════════════════════════════════════════════════════════════════

/// System metric
class SystemMetric {
  final String label;
  final String value;
  final String? unit;
  final IconData icon;
  final Color color;
  final double? percentage;
  final MetricTrend trend;

  const SystemMetric({
    required this.label,
    required this.value,
    this.unit,
    required this.icon,
    required this.color,
    this.percentage,
    this.trend = MetricTrend.stable,
  });
}

enum MetricTrend { up, down, stable }

/// Performance snapshot
class PerformanceSnapshot {
  final double cpuUsage;
  final double memoryUsage;
  final double batteryLevel;
  final double networkLatencyMs;
  final int fps;
  final DateTime timestamp;

  const PerformanceSnapshot({
    required this.cpuUsage,
    required this.memoryUsage,
    required this.batteryLevel,
    required this.networkLatencyMs,
    required this.fps,
    required this.timestamp,
  });
}

/// Device info
class DeviceInfoModel {
  final String deviceName;
  final String osVersion;
  final String appVersion;
  final String buildNumber;
  final String deviceId;
  final String screenResolution;
  final String locale;
  final String timezone;
  final double totalStorageMB;
  final double freeStorageMB;
  final double totalMemoryMB;

  const DeviceInfoModel({
    required this.deviceName,
    required this.osVersion,
    required this.appVersion,
    required this.buildNumber,
    required this.deviceId,
    required this.screenResolution,
    required this.locale,
    required this.timezone,
    required this.totalStorageMB,
    required this.freeStorageMB,
    required this.totalMemoryMB,
  });
}

/// System log entry
class SystemLogEntry {
  final String id;
  final String message;
  final LogLevel level;
  final String source;
  final DateTime timestamp;
  final Map<String, dynamic>? details;

  const SystemLogEntry({
    required this.id,
    required this.message,
    required this.level,
    required this.source,
    required this.timestamp,
    this.details,
  });

  Color get levelColor {
    switch (level) {
      case LogLevel.debug:
        return const Color(0xFF9CA3AF);
      case LogLevel.info:
        return const Color(0xFF3B82F6);
      case LogLevel.warning:
        return const Color(0xFFF59E0B);
      case LogLevel.error:
        return const Color(0xFFEF4444);
      case LogLevel.critical:
        return const Color(0xFF7C3AED);
    }
  }
}

enum LogLevel { debug, info, warning, error, critical }

/// Active session
class ActiveSession {
  final String id;
  final String deviceName;
  final String location;
  final String ipAddress;
  final DateTime startedAt;
  final bool isCurrent;

  const ActiveSession({
    required this.id,
    required this.deviceName,
    required this.location,
    required this.ipAddress,
    required this.startedAt,
    this.isCurrent = false,
  });
}
