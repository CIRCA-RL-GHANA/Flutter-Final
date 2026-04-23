/// ═══════════════════════════════════════════════════════════════════════════
/// RBAC (Role-Based Access Control) Models
/// Complete role, context, entity, and permission definitions
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

// ─── User Roles ──────────────────────────────────────────────────────────────

/// All 11 roles in the PROMPT Genie ecosystem
enum UserRole {
  // Individual Entity
  owner,

  // Business Entity
  administrator,
  socialOfficer,
  responseOfficer,
  monitor,

  // Branch Roles
  branchManager,
  branchResponseOfficer,
  branchMonitor,
  branchSocialOfficer,

  // Driver
  driver,

  // Fallback
  none,
}

/// Branch types determine LIVE widget behavior and Setup Dashboard scope
enum BranchType {
  shop,
  logisticsProvider,
  transportProvider,
}

/// Driver specialization within a branch type
enum DriverType {
  shopDriver,
  logisticsDriver,
  transportDriver,
}

/// The entity context the user is operating within
enum EntityType {
  personal,
  business,
  branch,
}

/// Presence status for avatars and qualChat
enum PresenceStatus {
  online,
  idle,
  offline,
}

// ─── App Context ─────────────────────────────────────────────────────────────

/// Represents the active context a user is operating in.
/// A user can switch between personal, business, and branch contexts.
class AppContextModel {
  final String id;
  final String name;
  final String subtitle;
  final EntityType entityType;
  final UserRole role;
  final BranchType? branchType;
  final DriverType? driverType;
  final String? avatarUrl;
  final PresenceStatus presence;

  const AppContextModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.entityType,
    required this.role,
    this.branchType,
    this.driverType,
    this.avatarUrl,
    this.presence = PresenceStatus.online,
  });

  /// Display label for the context
  String get displayLabel => '$name - ${roleLabel}';

  /// Human-readable role label
  String get roleLabel {
    switch (role) {
      case UserRole.owner:
        return 'Owner';
      case UserRole.administrator:
        return 'Administrator';
      case UserRole.socialOfficer:
        return 'Social Officer';
      case UserRole.responseOfficer:
        return 'Response Officer';
      case UserRole.monitor:
        return 'Monitor';
      case UserRole.branchManager:
        return 'Branch Manager';
      case UserRole.branchResponseOfficer:
        return 'Branch Response Officer';
      case UserRole.branchMonitor:
        return 'Branch Monitor';
      case UserRole.branchSocialOfficer:
        return 'Branch Social Officer';
      case UserRole.driver:
        return 'Driver';
      case UserRole.none:
        return 'User';
    }
  }
}

// ─── Module Widget Identifiers ───────────────────────────────────────────────

/// The 10 module widgets on the PROMPT screen
enum PromptModule {
  goPage,
  market,
  myUpdates,
  setupDashboard,
  alerts,
  live,
  qualChat,
  april,
  userDetails,
  utility,
}

// ─── Role Colors ─────────────────────────────────────────────────────────────

/// Color-coded pill colors per spec
class RoleColors {
  RoleColors._();

  static Color forRole(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return const Color(0xFF7C3AED); // Purple
      case UserRole.administrator:
        return const Color(0xFF2563EB); // Blue
      case UserRole.branchManager:
        return const Color(0xFF059669); // Green
      case UserRole.socialOfficer:
      case UserRole.branchSocialOfficer:
        return const Color(0xFFEC4899); // Pink
      case UserRole.responseOfficer:
      case UserRole.branchResponseOfficer:
        return const Color(0xFFF59E0B); // Amber
      case UserRole.monitor:
      case UserRole.branchMonitor:
        return const Color(0xFF6B7280); // Gray
      case UserRole.driver:
        return const Color(0xFFD97706); // Orange
      case UserRole.none:
        return const Color(0xFF9CA3AF);
    }
  }

  /// Module widget accent colors
  static Color forModule(PromptModule module) {
    switch (module) {
      case PromptModule.goPage:
        return const Color(0xFF10B981); // Green (Financial)
      case PromptModule.market:
        return const Color(0xFFF59E0B); // Amber (Commerce)
      case PromptModule.myUpdates:
        return const Color(0xFFEC4899); // Pink (Social)
      case PromptModule.setupDashboard:
        return const Color(0xFF3B82F6); // Blue (Operations)
      case PromptModule.alerts:
        return const Color(0xFFEF4444); // Red (Alerts)
      case PromptModule.live:
        return const Color(0xFF8B5CF6); // Violet (Real-time)
      case PromptModule.qualChat:
        return const Color(0xFF06B6D4); // Cyan (Chat)
      case PromptModule.april:
        return const Color(0xFFFFD700); // Gold (Assistant)
      case PromptModule.userDetails:
        return const Color(0xFF6366F1); // Indigo (Profile)
      case PromptModule.utility:
        return const Color(0xFF64748B); // Slate (Utility)
    }
  }
}

// ─── Widget Visibility RBAC Matrix ───────────────────────────────────────────

/// Pedantic enforcement of RBAC visibility matrix.
/// Returns the list of visible modules for a given role.
class WidgetVisibility {
  WidgetVisibility._();

  /// Full access (all features interactive)
  static const _fullAccess = _WidgetAccess.full;

  /// Partial access (some features restricted)
  static const _partial = _WidgetAccess.partial;

  /// View-only access (40% opacity, no edit)
  static const _viewOnly = _WidgetAccess.viewOnly;

  /// Hidden (widget not rendered)
  static const _hidden = _WidgetAccess.hidden;

  /// Master RBAC visibility matrix
  static Map<PromptModule, _WidgetAccess> getAccessMap(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return {
          PromptModule.goPage: _fullAccess,
          PromptModule.market: _fullAccess,
          PromptModule.myUpdates: _fullAccess,
          PromptModule.setupDashboard: _fullAccess,
          PromptModule.alerts: _hidden, // Owner NEVER sees Alerts
          PromptModule.live: _hidden,
          PromptModule.qualChat: _fullAccess, // Includes HeyYa
          PromptModule.april: _fullAccess, // ONLY for Owner
          PromptModule.userDetails: _fullAccess,
          PromptModule.utility: _fullAccess,
        };
      case UserRole.administrator:
        return {
          PromptModule.goPage: _fullAccess,
          PromptModule.market: _fullAccess,
          PromptModule.myUpdates: _fullAccess,
          PromptModule.setupDashboard: _fullAccess,
          PromptModule.alerts: _fullAccess,
          PromptModule.live: _hidden,
          PromptModule.qualChat: _fullAccess, // No HeyYa
          PromptModule.april: _hidden,
          PromptModule.userDetails: _fullAccess,
          PromptModule.utility: _fullAccess,
        };
      case UserRole.branchManager:
        return {
          PromptModule.goPage: _hidden,
          PromptModule.market: _hidden,
          PromptModule.myUpdates: _hidden,
          PromptModule.setupDashboard: _partial, // Branch-scoped
          PromptModule.alerts: _fullAccess,
          PromptModule.live: _fullAccess,
          PromptModule.qualChat: _fullAccess,
          PromptModule.april: _hidden,
          PromptModule.userDetails: _fullAccess,
          PromptModule.utility: _fullAccess,
        };
      case UserRole.socialOfficer:
      case UserRole.branchSocialOfficer:
        return {
          PromptModule.goPage: _hidden,
          PromptModule.market: _hidden,
          PromptModule.myUpdates: _fullAccess,
          PromptModule.setupDashboard: _partial, // Engagement row emphasis
          PromptModule.alerts: _fullAccess,
          PromptModule.live: _hidden,
          PromptModule.qualChat: _fullAccess,
          PromptModule.april: _hidden,
          PromptModule.userDetails: _fullAccess,
          PromptModule.utility: _fullAccess,
        };
      case UserRole.monitor:
      case UserRole.branchMonitor:
        return {
          PromptModule.goPage: _hidden,
          PromptModule.market: _hidden,
          PromptModule.myUpdates: _hidden,
          PromptModule.setupDashboard: _viewOnly, // 40% opacity
          PromptModule.alerts: _fullAccess,
          PromptModule.live: _hidden,
          PromptModule.qualChat: _fullAccess,
          PromptModule.april: _hidden,
          PromptModule.userDetails: _fullAccess,
          PromptModule.utility: _fullAccess,
        };
      case UserRole.responseOfficer:
      case UserRole.branchResponseOfficer:
        return {
          PromptModule.goPage: _hidden,
          PromptModule.market: _hidden,
          PromptModule.myUpdates: _hidden,
          PromptModule.setupDashboard: _partial,
          PromptModule.alerts: _fullAccess,
          PromptModule.live: _fullAccess,
          PromptModule.qualChat: _fullAccess,
          PromptModule.april: _hidden,
          PromptModule.userDetails: _fullAccess,
          PromptModule.utility: _fullAccess,
        };
      case UserRole.driver:
        return {
          PromptModule.goPage: _hidden,
          PromptModule.market: _hidden,
          PromptModule.myUpdates: _hidden,
          PromptModule.setupDashboard: _partial,
          PromptModule.alerts: _hidden,
          PromptModule.live: _fullAccess,
          PromptModule.qualChat: _fullAccess,
          PromptModule.april: _hidden,
          PromptModule.userDetails: _fullAccess,
          PromptModule.utility: _fullAccess,
        };
      case UserRole.none:
        return {
          PromptModule.goPage: _hidden,
          PromptModule.market: _hidden,
          PromptModule.myUpdates: _hidden,
          PromptModule.setupDashboard: _hidden,
          PromptModule.alerts: _hidden,
          PromptModule.live: _hidden,
          PromptModule.qualChat: _hidden,
          PromptModule.april: _hidden,
          PromptModule.userDetails: _fullAccess, // Always visible
          PromptModule.utility: _fullAccess,
        };
    }
  }

  /// Get the ordered list of visible modules for a role
  static List<PromptModule> getVisibleModules(UserRole role) {
    final accessMap = getAccessMap(role);
    return accessMap.entries
        .where((e) => e.value != _WidgetAccess.hidden)
        .map((e) => e.key)
        .toList();
  }

  /// Check if a specific module is visible for a role
  static bool isVisible(UserRole role, PromptModule module) {
    return getAccessMap(role)[module] != _WidgetAccess.hidden;
  }

  /// Check if a module is view-only for a role
  static bool isViewOnly(UserRole role, PromptModule module) {
    return getAccessMap(role)[module] == _WidgetAccess.viewOnly;
  }

  /// Check if a module has partial access
  static bool isPartial(UserRole role, PromptModule module) {
    return getAccessMap(role)[module] == _WidgetAccess.partial;
  }

  /// Whether the role can see HeyYa in qualChat
  static bool canSeeHeyYa(UserRole role) => role == UserRole.owner;

  /// Whether Emergency SOS is visible
  static bool canSeeSOS(UserRole role) {
    return role == UserRole.owner ||
        role == UserRole.administrator ||
        role == UserRole.branchManager;
  }

  /// ZapActionMenu items by role
  static List<_ZapAction> getZapActions(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return [
          const _ZapAction(Icons.chat_bubble_outline, 'qualChat'),
          const _ZapAction(Icons.assistant, 'APRIL'),
          const _ZapAction(Icons.person_outline, 'User Details'),
        ];
      case UserRole.administrator:
        return [
          const _ZapAction(Icons.chat_bubble_outline, 'qualChat'),
          const _ZapAction(Icons.warning_amber, 'Alerts'),
          const _ZapAction(Icons.dashboard_customize, 'Setup Dashboard'),
        ];
      case UserRole.branchManager:
        return [
          const _ZapAction(Icons.chat_bubble_outline, 'qualChat'),
          const _ZapAction(Icons.warning_amber, 'Alerts'),
          const _ZapAction(Icons.live_tv, 'LIVE'),
        ];
      case UserRole.driver:
        return [
          const _ZapAction(Icons.chat_bubble_outline, 'qualChat'),
          const _ZapAction(Icons.warning_amber, 'Alerts'),
          const _ZapAction(Icons.live_tv, 'LIVE'),
        ];
      default:
        return [
          const _ZapAction(Icons.chat_bubble_outline, 'qualChat'),
          const _ZapAction(Icons.warning_amber, 'Alerts'),
          const _ZapAction(Icons.person_outline, 'User Details'),
        ];
    }
  }
}

/// Widget access level
enum _WidgetAccess {
  full,
  partial,
  viewOnly,
  hidden,
}

/// Zap action menu item
class _ZapAction {
  final IconData icon;
  final String label;
  const _ZapAction(this.icon, this.label);
}

// ─── Module Info ─────────────────────────────────────────────────────────────

/// Metadata for each module widget
class ModuleInfo {
  final PromptModule module;
  final String name;
  final String shortName;
  final IconData icon;
  final Color color;
  final String description;

  const ModuleInfo({
    required this.module,
    required this.name,
    required this.shortName,
    required this.icon,
    required this.color,
    required this.description,
  });

  static ModuleInfo forModule(PromptModule module) {
    switch (module) {
      case PromptModule.goPage:
        return ModuleInfo(
          module: module,
          name: 'GO PAGE',
          shortName: 'Finance',
          icon: Icons.account_balance_wallet,
          color: RoleColors.forModule(module),
          description: 'Financial Hub - QPoints, Transfers, Tabs',
        );
      case PromptModule.market:
        return ModuleInfo(
          module: module,
          name: 'MARKET',
          shortName: 'Market',
          icon: Icons.storefront,
          color: RoleColors.forModule(module),
          description: 'Commerce & Logistics - Shop, Cart, Orders',
        );
      case PromptModule.myUpdates:
        return ModuleInfo(
          module: module,
          name: 'MY UPDATES',
          shortName: 'Updates',
          icon: Icons.feed,
          color: RoleColors.forModule(module),
          description: 'Social Feed - Posts, Engagement, Trends',
        );
      case PromptModule.setupDashboard:
        return ModuleInfo(
          module: module,
          name: 'SETUP DASHBOARD',
          shortName: 'Setup',
          icon: Icons.settings_applications,
          color: RoleColors.forModule(module),
          description: 'Operations Center - Products, Staff, Analytics',
        );
      case PromptModule.alerts:
        return ModuleInfo(
          module: module,
          name: 'ALERTS',
          shortName: 'Alerts',
          icon: Icons.notification_important,
          color: RoleColors.forModule(module),
          description: 'Resolution Log - Issues, Tracking, Reports',
        );
      case PromptModule.live:
        return ModuleInfo(
          module: module,
          name: 'LIVE',
          shortName: 'Live',
          icon: Icons.live_tv,
          color: RoleColors.forModule(module),
          description: 'Real-Time Operations - Orders, Deliveries, Rides',
        );
      case PromptModule.qualChat:
        return ModuleInfo(
          module: module,
          name: 'qualChat',
          shortName: 'Chat',
          icon: Icons.chat_bubble,
          color: RoleColors.forModule(module),
          description: 'Communications Hub - Messages, Presence, HeyYa',
        );
      case PromptModule.april:
        return ModuleInfo(
          module: module,
          name: 'APRIL',
          shortName: 'APRIL',
          icon: Icons.assistant,
          color: RoleColors.forModule(module),
          description: 'Personal Assistant - Voice, Plugins, Commands',
        );
      case PromptModule.userDetails:
        return ModuleInfo(
          module: module,
          name: 'USER DETAILS',
          shortName: 'Profile',
          icon: Icons.person,
          color: RoleColors.forModule(module),
          description: 'Profile & Entities - Contexts, Settings, Security',
        );
      case PromptModule.utility:
        return ModuleInfo(
          module: module,
          name: 'UTILITY',
          shortName: 'Tools',
          icon: Icons.build_circle,
          color: RoleColors.forModule(module),
          description: 'Global Tools - Search, Help, Settings, Accessibility',
        );
    }
  }
}

// ─── Time Period for Adaptive Behavior ───────────────────────────────────────

/// Time periods that drive widget priority stacking
enum TimePeriod {
  morning,   // 6AM - 12PM
  afternoon, // 12PM - 6PM
  evening,   // 6PM - 12AM
  night,     // 12AM - 6AM
}

TimePeriod getCurrentTimePeriod() {
  final hour = DateTime.now().hour;
  if (hour >= 6 && hour < 12) return TimePeriod.morning;
  if (hour >= 12 && hour < 18) return TimePeriod.afternoon;
  if (hour >= 18) return TimePeriod.evening;
  return TimePeriod.night;
}

// ─── Widget Priority ────────────────────────────────────────────────────────

enum WidgetPriority { high, medium, low }

/// Priority stacking per time period
class PriorityEngine {
  PriorityEngine._();

  static WidgetPriority getPriority(PromptModule module, TimePeriod time) {
    switch (time) {
      case TimePeriod.morning:
        // Financial widgets prominent
        if (module == PromptModule.goPage || module == PromptModule.market) {
          return WidgetPriority.high;
        }
        if (module == PromptModule.alerts || module == PromptModule.live) {
          return WidgetPriority.medium;
        }
        return WidgetPriority.low;

      case TimePeriod.afternoon:
        // Operational widgets prominent
        if (module == PromptModule.live || module == PromptModule.alerts) {
          return WidgetPriority.high;
        }
        if (module == PromptModule.setupDashboard || module == PromptModule.market) {
          return WidgetPriority.medium;
        }
        return WidgetPriority.low;

      case TimePeriod.evening:
        // Social widgets prominent
        if (module == PromptModule.qualChat || module == PromptModule.myUpdates) {
          return WidgetPriority.high;
        }
        if (module == PromptModule.april || module == PromptModule.goPage) {
          return WidgetPriority.medium;
        }
        return WidgetPriority.low;

      case TimePeriod.night:
        // Minimal interface
        if (module == PromptModule.qualChat || module == PromptModule.utility) {
          return WidgetPriority.high;
        }
        return WidgetPriority.low;
    }
  }

  /// Sort modules by priority for the current time
  static List<PromptModule> sortByPriority(
    List<PromptModule> modules,
    TimePeriod time,
  ) {
    final sorted = List<PromptModule>.from(modules);
    sorted.sort((a, b) {
      final pa = getPriority(a, time).index;
      final pb = getPriority(b, time).index;
      return pa.compareTo(pb); // Lower index = higher priority
    });
    return sorted;
  }
}
