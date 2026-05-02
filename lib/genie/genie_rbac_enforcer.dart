/// ═══════════════════════════════════════════════════════════════════════════
/// GenieRBACEnforcer – Real-Time Role-Based Access Control for Genie
///
/// Hard-codes the EXACT same visibility matrix as the PROMPT screen.
/// Every intent is validated here before execution. The enforcer never
/// reveals the existence of forbidden data – it redirects politely.
/// ═══════════════════════════════════════════════════════════════════════════

import '../features/prompt/models/rbac_models.dart';
import 'genie_intent.dart';

class GenieRBACEnforcer {
  GenieRBACEnforcer._();

  // ─── Module Visibility Matrix ─────────────────────────────────────────────
  /// Returns true if the given role may access the module at all.
  static bool canAccessModule(UserRole role, GenieModule module) {
    switch (module) {
      case GenieModule.goPage:
        return role == UserRole.owner || role == UserRole.administrator;

      case GenieModule.market:
        return role == UserRole.owner || role == UserRole.administrator;

      case GenieModule.myUpdates:
        return role == UserRole.owner ||
            role == UserRole.administrator ||
            role == UserRole.socialOfficer ||
            role == UserRole.branchSocialOfficer;

      case GenieModule.setupDashboard:
        // All roles get setup dashboard, but with different scopes
        return role != UserRole.none;

      case GenieModule.alerts:
        // Owner is explicitly excluded from Alerts
        return role != UserRole.owner && role != UserRole.none;

      case GenieModule.live:
        return role == UserRole.branchManager ||
            role == UserRole.responseOfficer ||
            role == UserRole.branchResponseOfficer ||
            role == UserRole.driver;

      case GenieModule.qualChat:
        return role != UserRole.none;

      case GenieModule.april:
        // APRIL is Owner-only, now subsumed into Genie's personal layer
        return role == UserRole.owner;

      case GenieModule.userDetails:
        return role != UserRole.none;

      case GenieModule.utility:
        return role != UserRole.none;

      // e-Play: all authenticated users can browse & use locker;
      // creator studio requires owner or admin role
      case GenieModule.eplay:
        return role != UserRole.none;

      // Community: all authenticated users
      case GenieModule.community:
        return role != UserRole.none;

      case GenieModule.crossModule:
      case GenieModule.genie:
        return role != UserRole.none;

      // Fintech: any authenticated user can view/apply; FI roles have extra access
      case GenieModule.fintech:
        return role != UserRole.none;

      // Enterprise: only owner and administrator roles can access enterprise features
      case GenieModule.enterprise:
        return role == UserRole.owner || role == UserRole.administrator;
    }
  }

  // ─── Sub-Module / Action Restrictions ────────────────────────────────────
  /// Returns true if the role may perform the specific action within a module.
  static bool canPerformAction(
      UserRole role, GenieModule module, String action) {
    if (!canAccessModule(role, module)) return false;

    switch (module) {
      case GenieModule.qualChat:
        // Hey Ya is Owner-only
        if (action == 'hey_ya' || action == 'sparks' || action == 'nudges') {
          return role == UserRole.owner;
        }
        return true;

      case GenieModule.setupDashboard:
        // Monitor gets view-only
        final isMonitor = role == UserRole.monitor ||
            role == UserRole.branchMonitor;
        if (isMonitor && _isWriteAction(action)) return false;
        // Vehicle Bands only for Admin & Branch Manager
        if (action == 'vehicle_bands') {
          return role == UserRole.administrator ||
              role == UserRole.branchManager;
        }
        // Social Officer can only access social/updates-related rows
        if (role == UserRole.socialOfficer ||
            role == UserRole.branchSocialOfficer) {
          return _isSocialAction(action);
        }
        return true;

      case GenieModule.goPage:
        // Both Owner & Admin: full access
        return true;

      case GenieModule.market:
        // Hail Ride only if transport is configured
        return true;

      case GenieModule.live:
        // Driver-specific actions
        if (action == 'emergency_sos') return role == UserRole.driver;
        if (action == 'assign_driver') {
          return role == UserRole.branchManager ||
              role == UserRole.responseOfficer ||
              role == UserRole.branchResponseOfficer;
        }
        return true;

      case GenieModule.eplay:
        // Creator studio only for owner/admin; everyone else can browse + locker
        if (action == 'creator_studio' || action == 'creator_profile') {
          return role == UserRole.owner || role == UserRole.administrator;
        }
        return true;

      case GenieModule.community:
        // Everyone can browse/join; only owner/admin can moderate
        return true;

      case GenieModule.enterprise:
        // API key management and KYB verification are owner-only
        if (action == 'create_api_key' || action == 'revoke_api_key' || action == 'verify_enterprise') {
          return role == UserRole.owner;
        }
        // Channel and fulfillment management require owner or admin
        if (action == 'register_channel' || action == 'dispatch_fulfillment' || action == 'create_routing_rule') {
          return role == UserRole.owner || role == UserRole.administrator;
        }
        // Dashboard and analytics are owner/admin
        return role == UserRole.owner || role == UserRole.administrator;

      default:
        return true;
    }
  }

  static bool _isWriteAction(String action) {
    const writeActions = {
      'create', 'edit', 'delete', 'update', 'add', 'remove',
      'assign', 'publish', 'approve', 'reject',
    };
    return writeActions.any((w) => action.contains(w));
  }

  static bool _isSocialAction(String action) {
    const socialActions = {
      'post', 'feed', 'saved', 'notifications', 'interests',
      'following', 'social', 'create_post',
    };
    return socialActions.any((s) => action.contains(s));
  }

  // ─── Polite Denial Message ────────────────────────────────────────────────
  /// Returns a user-friendly denial message without revealing forbidden data.
  static String getDenialMessage(
      UserRole role, GenieModule module, String action) {
    switch (module) {
      case GenieModule.goPage:
        return "GO PAGE is available to Owner and Admin only. "
            "I can show you your branch's operational overview instead. "
            "Say 'open LIVE' or tap below.";
      case GenieModule.market:
        return "MARKET access is restricted to Owner and Admin. "
            "I can help you with Live orders or deliveries instead.";
      case GenieModule.alerts:
        return "Alerts management is handled by your team. "
            "You can check your personal notifications instead.";
      case GenieModule.april:
        return "Personal AI assistant features are available for Owners. "
            "I can help you with tasks within your role. What would you like?";
      case GenieModule.live:
        return "LIVE operations require a Branch Manager, "
            "Response Officer, or Driver role. "
            "I can redirect you to the right place. What do you need?";
      case GenieModule.setupDashboard:
        if (_isWriteAction(action)) {
          return "Your role has view-only access to Setup Dashboard. "
              "Contact your admin to make changes.";
        }
        return "You don't have access to that section. "
            "I can show you what's available in your dashboard.";
      case GenieModule.qualChat:
        return "That feature is restricted to Owners. "
            "You can still access regular chats and conversations.";
      case GenieModule.eplay:
        return "Creator Studio is available to Owner and Admin accounts. "
            "You can still browse and access your cloud locker.";
      case GenieModule.community:
        return "You don't have access to that community action. "
            "Try browsing or joining a public community.";
      default:
        return "I can't access that for you right now, "
            "but I can help with something related. What else can I do?";
    }
  }

  // ─── Smart Chips per Role ─────────────────────────────────────────────────
  /// Default quick-chips based on role for the bottom chip bar.
  static List<GenieChip> getDefaultChips(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return const [
          GenieChip(
            label: 'Balance',
            emoji: '💰',
            module: GenieModule.goPage,
            intent: GenieIntent(module: GenieModule.goPage, action: 'check_balance'),
          ),
          GenieChip(
            label: 'Feed',
            emoji: '📰',
            module: GenieModule.myUpdates,
            intent: GenieIntent(module: GenieModule.myUpdates, action: 'show_feed'),
          ),
          GenieChip(
            label: 'Hey Ya',
            emoji: '✨',
            module: GenieModule.qualChat,
            intent: GenieIntent(module: GenieModule.qualChat, action: 'hey_ya'),
          ),
          GenieChip(
            label: 'e-Play',
            emoji: '🎵',
            module: GenieModule.eplay,
            intent: GenieIntent(module: GenieModule.eplay, action: 'open_locker', requiresFullScreen: true),
          ),
          GenieChip(
            label: 'Communities',
            emoji: '🌍',
            module: GenieModule.community,
            intent: GenieIntent(module: GenieModule.community, action: 'my_communities', requiresFullScreen: true),
          ),
          GenieChip(
            label: 'Reminders',
            emoji: '📅',
            module: GenieModule.april,
            intent: GenieIntent(module: GenieModule.april, action: 'reminders'),
          ),
          GenieChip(
            label: 'Chats',
            emoji: '💬',
            module: GenieModule.qualChat,
            intent: GenieIntent(module: GenieModule.qualChat, action: 'recent_chats'),
          ),
        ];

      case UserRole.administrator:
        return const [
          GenieChip(
            label: 'QP Balance',
            emoji: '💰',
            module: GenieModule.goPage,
            intent: GenieIntent(module: GenieModule.goPage, action: 'check_balance'),
          ),
          GenieChip(
            label: 'Sales Today',
            emoji: '📈',
            module: GenieModule.setupDashboard,
            intent: GenieIntent(module: GenieModule.setupDashboard, action: 'sales_today'),
          ),
          GenieChip(
            label: 'Chats',
            emoji: '💬',
            module: GenieModule.qualChat,
            intent: GenieIntent(module: GenieModule.qualChat, action: 'recent_chats'),
          ),
          GenieChip(
            label: 'Alerts',
            emoji: '🔔',
            module: GenieModule.alerts,
            intent: GenieIntent(module: GenieModule.alerts, action: 'recent_alerts'),
          ),
          GenieChip(
            label: 'Market',
            emoji: '🛍️',
            module: GenieModule.market,
            intent: GenieIntent(module: GenieModule.market, action: 'browse_shops'),
          ),
          GenieChip(
            label: 'e-Play',
            emoji: '🎵',
            module: GenieModule.eplay,
            intent: GenieIntent(module: GenieModule.eplay, action: 'open_locker', requiresFullScreen: true),
          ),
          GenieChip(
            label: 'Communities',
            emoji: '🌍',
            module: GenieModule.community,
            intent: GenieIntent(module: GenieModule.community, action: 'discover', requiresFullScreen: true),
          ),
        ];

      case UserRole.branchManager:
        return const [
          GenieChip(
            label: 'Incoming',
            emoji: '📥',
            module: GenieModule.live,
            intent: GenieIntent(module: GenieModule.live, action: 'incoming_orders'),
          ),
          GenieChip(
            label: 'Active Orders',
            emoji: '🚚',
            module: GenieModule.live,
            intent: GenieIntent(module: GenieModule.live, action: 'active_packages'),
          ),
          GenieChip(
            label: 'Staff',
            emoji: '👥',
            module: GenieModule.setupDashboard,
            intent: GenieIntent(module: GenieModule.setupDashboard, action: 'staff_list'),
          ),
          GenieChip(
            label: 'Chats',
            emoji: '💬',
            module: GenieModule.qualChat,
            intent: GenieIntent(module: GenieModule.qualChat, action: 'recent_chats'),
          ),
          GenieChip(
            label: 'Alerts',
            emoji: '🔔',
            module: GenieModule.alerts,
            intent: GenieIntent(module: GenieModule.alerts, action: 'recent_alerts'),
          ),
        ];

      case UserRole.driver:
        return const [
          GenieChip(
            label: 'Current Delivery',
            emoji: '🗺️',
            module: GenieModule.live,
            intent: GenieIntent(module: GenieModule.live, action: 'current_delivery'),
          ),
          GenieChip(
            label: 'Available',
            emoji: '📦',
            module: GenieModule.live,
            intent: GenieIntent(module: GenieModule.live, action: 'available_packages'),
          ),
          GenieChip(
            label: 'Chat Fleet',
            emoji: '💬',
            module: GenieModule.qualChat,
            intent: GenieIntent(module: GenieModule.qualChat, action: 'fleet_chat'),
          ),
          GenieChip(
            label: 'SOS',
            emoji: '🆘',
            module: GenieModule.live,
            intent: GenieIntent(module: GenieModule.live, action: 'emergency_sos'),
          ),
        ];

      case UserRole.responseOfficer:
      case UserRole.branchResponseOfficer:
        return const [
          GenieChip(
            label: 'Alerts',
            emoji: '🔔',
            module: GenieModule.alerts,
            intent: GenieIntent(module: GenieModule.alerts, action: 'recent_alerts'),
          ),
          GenieChip(
            label: 'Live Feed',
            emoji: '📡',
            module: GenieModule.live,
            intent: GenieIntent(module: GenieModule.live, action: 'live_operations'),
          ),
          GenieChip(
            label: 'Chats',
            emoji: '💬',
            module: GenieModule.qualChat,
            intent: GenieIntent(module: GenieModule.qualChat, action: 'recent_chats'),
          ),
        ];

      default:
        return const [
          GenieChip(
            label: 'Chats',
            emoji: '💬',
            module: GenieModule.qualChat,
            intent: GenieIntent(module: GenieModule.qualChat, action: 'recent_chats'),
          ),
          GenieChip(
            label: 'Profile',
            emoji: '👤',
            module: GenieModule.userDetails,
            intent: GenieIntent(module: GenieModule.userDetails, action: 'profile_strength'),
          ),
          GenieChip(
            label: 'Settings',
            emoji: '⚙️',
            module: GenieModule.utility,
            intent: GenieIntent(module: GenieModule.utility, action: 'settings'),
          ),
        ];
    }
  }

  // ─── Pinned Shortcuts per Role ────────────────────────────────────────────
  static List<GeniePinnedShortcut> getDefaultPinnedShortcuts(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return const [
          GeniePinnedShortcut(
            label: 'Balance',
            emoji: '💰',
            intent: GenieIntent(module: GenieModule.goPage, action: 'check_balance'),
          ),
          GeniePinnedShortcut(
            label: 'Chats',
            emoji: '💬',
            intent: GenieIntent(module: GenieModule.qualChat, action: 'recent_chats'),
          ),
          GeniePinnedShortcut(
            label: 'Feed',
            emoji: '📰',
            intent: GenieIntent(module: GenieModule.myUpdates, action: 'show_feed'),
          ),
          GeniePinnedShortcut(
            label: 'Settings',
            emoji: '⚙️',
            intent: GenieIntent(module: GenieModule.utility, action: 'settings'),
          ),
        ];

      case UserRole.administrator:
        return const [
          GeniePinnedShortcut(
            label: 'QP Balance',
            emoji: '💰',
            intent: GenieIntent(module: GenieModule.goPage, action: 'check_balance'),
          ),
          GeniePinnedShortcut(
            label: 'Sales',
            emoji: '📈',
            intent: GenieIntent(module: GenieModule.setupDashboard, action: 'sales_today'),
          ),
          GeniePinnedShortcut(
            label: 'Chats',
            emoji: '💬',
            intent: GenieIntent(module: GenieModule.qualChat, action: 'recent_chats'),
          ),
          GeniePinnedShortcut(
            label: 'Alerts',
            emoji: '🔔',
            intent: GenieIntent(module: GenieModule.alerts, action: 'recent_alerts'),
          ),
        ];

      case UserRole.driver:
        return const [
          GeniePinnedShortcut(
            label: 'Delivery',
            emoji: '🗺️',
            intent: GenieIntent(module: GenieModule.live, action: 'current_delivery'),
          ),
          GeniePinnedShortcut(
            label: 'Chat Fleet',
            emoji: '💬',
            intent: GenieIntent(module: GenieModule.qualChat, action: 'fleet_chat'),
          ),
          GeniePinnedShortcut(
            label: 'Available',
            emoji: '📦',
            intent: GenieIntent(module: GenieModule.live, action: 'available_packages'),
          ),
          GeniePinnedShortcut(
            label: 'SOS',
            emoji: '🆘',
            intent: GenieIntent(module: GenieModule.live, action: 'emergency_sos'),
          ),
        ];

      default:
        return const [
          GeniePinnedShortcut(
            label: 'Chats',
            emoji: '💬',
            intent: GenieIntent(module: GenieModule.qualChat, action: 'recent_chats'),
          ),
          GeniePinnedShortcut(
            label: 'Profile',
            emoji: '👤',
            intent: GenieIntent(module: GenieModule.userDetails, action: 'profile_strength'),
          ),
          GeniePinnedShortcut(
            label: 'Notifications',
            emoji: '🔔',
            intent: GenieIntent(module: GenieModule.utility, action: 'notifications'),
          ),
          GeniePinnedShortcut(
            label: 'Settings',
            emoji: '⚙️',
            intent: GenieIntent(module: GenieModule.utility, action: 'settings'),
          ),
        ];
    }
  }
}
