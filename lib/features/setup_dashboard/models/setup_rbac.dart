/// ═══════════════════════════════════════════════════════════════════════════
/// SETUP DASHBOARD — Complete RBAC Authority
/// Canonical permission model for all 19 Setup Dashboard screens.
///
/// Hierarchy (Tier 1→4):
///   Owner → Administrator → Branch Manager → [Specialists] → Driver
///
/// Enforces:
///   • Card-level visibility (hub dashboard)
///   • Per-screen action gating (create / edit / delete / export)
///   • OTP requirements for sensitive mutations
///   • Redacted data views for Monitor roles
///   • Export permission matrix
///   • SOS button visibility
///   • Tooltip messages for locked / view-only UI elements
/// ═══════════════════════════════════════════════════════════════════════════

import '../../prompt/models/rbac_models.dart';

// ─── Action Permission Value Object ──────────────────────────────────────────

/// Granular action-level permission for a given card + role combination.
class SetupActionPermission {
  /// May create new records
  final bool canCreate;

  /// May edit existing records
  final bool canEdit;

  /// May delete records
  final bool canDelete;

  /// May export / download data
  final bool canExport;

  /// Write action requires OTP/PIN verification step
  final bool requiresOtp;

  /// Data must be shown with PII/sensitive fields masked
  final bool isRedacted;

  /// Data scope is limited to the user's assigned branch
  final bool isBranchScoped;

  /// Tooltip / snackbar message to show for locked features.
  /// null = no tooltip needed (full access).
  final String? tooltipMessage;

  const SetupActionPermission({
    this.canCreate = false,
    this.canEdit = false,
    this.canDelete = false,
    this.canExport = false,
    this.requiresOtp = false,
    this.isRedacted = false,
    this.isBranchScoped = false,
    this.tooltipMessage,
  });

  bool get canWrite => canCreate || canEdit || canDelete;

  /// No permissions at all.
  static const SetupActionPermission none = SetupActionPermission(
    tooltipMessage: 'Contact your Administrator for access.',
  );
}

// ─── Setup Dashboard Canonical RBAC ──────────────────────────────────────────

/// Static authority class. All RBAC decisions for Setup Dashboard screens
/// flow through this class. Do NOT duplicate permission logic elsewhere.
class SetupDashboardRBAC {
  SetupDashboardRBAC._();

  // ══════════════════════════════════════════════════════════════════════════
  // SOS BUTTON
  // ══════════════════════════════════════════════════════════════════════════

  /// Emergency SOS visible to Tier 1–3 leads only.
  static bool canSeeSOS(UserRole role) =>
      role == UserRole.owner ||
      role == UserRole.administrator ||
      role == UserRole.branchManager;

  // ══════════════════════════════════════════════════════════════════════════
  // OTP / PIN REQUIREMENTS
  // ══════════════════════════════════════════════════════════════════════════

  /// Whether [action] on [cardId] requires OTP verification for [role].
  ///
  /// Actions: 'create', 'edit', 'delete', 'change_role', 'upgrade',
  ///          'financial_adjust', 'campaign_budget'
  static bool requiresOtpFor(String cardId, String action, UserRole role) {
    switch (cardId) {
      case 'staff':
        // Branch Manager changing a staff member's role needs Admin OTP.
        if (action == 'change_role' && role == UserRole.branchManager) return true;
        return false;

      case 'subscription':
        // Subscription upgrades require verification.
        if (action == 'upgrade') {
          return role == UserRole.owner || role == UserRole.administrator;
        }
        return false;

      case 'branches':
        // Creating a new branch is highly privileged.
        if (action == 'create' && role == UserRole.administrator) return true;
        return false;

      case 'activity_log':
        // Exporting full audit logs requires extra confirmation.
        if (action == 'export' && role == UserRole.administrator) return true;
        return false;

      case 'marketing':
        // Campaign budget changes over threshold require SO approval.
        if (action == 'campaign_budget') {
          return role == UserRole.socialOfficer || role == UserRole.branchSocialOfficer;
        }
        return false;

      default:
        return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // EXPORT PERMISSIONS
  // ══════════════════════════════════════════════════════════════════════════

  /// Export permission matrix per data type.
  ///
  /// Data types: 'audit_full', 'audit_branch', 'personal_activity',
  ///             'connection_list', 'transaction_history', 'product_catalog',
  ///             'staff_directory', 'campaign_report'
  static bool canExport(String dataType, UserRole role) {
    switch (dataType) {
      case 'audit_full':
        return role == UserRole.administrator;

      case 'audit_branch':
        return role == UserRole.administrator || role == UserRole.branchManager;

      case 'personal_activity':
        // Every role can export their own activity.
        return true;

      case 'connection_list':
        return role == UserRole.administrator ||
            role == UserRole.socialOfficer ||
            role == UserRole.branchSocialOfficer;

      case 'transaction_history':
        return role == UserRole.owner || role == UserRole.administrator;

      case 'product_catalog':
        return role == UserRole.administrator || role == UserRole.branchManager;

      case 'staff_directory':
        return role == UserRole.administrator;

      case 'campaign_report':
        return role == UserRole.administrator ||
            role == UserRole.socialOfficer ||
            role == UserRole.branchSocialOfficer;

      default:
        return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // REDACTED DATA VIEW
  // ══════════════════════════════════════════════════════════════════════════

  /// Whether [role] must see [cardId] in redacted mode (PII masked).
  ///
  /// Spec: Audit log — full details for Admin only; redacted for Monitor roles.
  static bool isRedactedView(String cardId, UserRole role) {
    if (cardId == 'activity_log') {
      return role == UserRole.monitor || role == UserRole.branchMonitor;
    }
    return false;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TOOLTIP MESSAGES
  // ══════════════════════════════════════════════════════════════════════════

  /// Tooltip / snackbar message shown when a locked feature is tapped.
  /// Returns null when the role has full access (no tooltip needed).
  static String? getTooltipMessage(String cardId, UserRole role) {
    switch (cardId) {
      // ─── Admin-only cards ─────────────────────────────────────────────
      case 'branches':
        if (role == UserRole.administrator) return null;
        if (role == UserRole.monitor) return 'Branch Monitor view only.';
        return 'Requires Administrator role.';

      // ─── Operations cards ─────────────────────────────────────────────
      case 'products':
        if (role == UserRole.owner || role == UserRole.socialOfficer ||
            role == UserRole.branchSocialOfficer || role == UserRole.driver) {
          return 'Contact your Administrator for access.';
        }
        if (role == UserRole.monitor || role == UserRole.responseOfficer) {
          return 'View-only access to products.';
        }
        if (role == UserRole.branchMonitor || role == UserRole.branchResponseOfficer) {
          return 'Branch view-only access to products.';
        }
        return null;

      case 'vehicles':
        if (role == UserRole.owner || role == UserRole.socialOfficer ||
            role == UserRole.branchSocialOfficer) {
          return 'Contact your Administrator for access.';
        }
        if (role == UserRole.driver) return 'View your assigned vehicle only.';
        if (role == UserRole.monitor) return 'View-only fleet access.';
        if (role == UserRole.branchMonitor) return 'Branch view-only fleet access.';
        return null;

      case 'tabs':
        if (role == UserRole.owner || role == UserRole.socialOfficer ||
            role == UserRole.branchSocialOfficer || role == UserRole.responseOfficer ||
            role == UserRole.branchResponseOfficer || role == UserRole.driver) {
          return 'Contact your Administrator for access.';
        }
        if (role == UserRole.monitor) return 'View-only access to customer tabs.';
        if (role == UserRole.branchMonitor) return 'Branch view-only tab access.';
        return null;

      // ─── Finance & Staff cards ────────────────────────────────────────
      case 'discounts':
        if (role == UserRole.owner || role == UserRole.responseOfficer ||
            role == UserRole.branchResponseOfficer || role == UserRole.driver) {
          return 'Contact your Administrator for access.';
        }
        if (role == UserRole.monitor) return 'View-only access to discounts.';
        if (role == UserRole.branchMonitor) return 'Branch view-only discount access.';
        return null;

      case 'staff':
        if (role == UserRole.owner || role == UserRole.socialOfficer ||
            role == UserRole.branchSocialOfficer || role == UserRole.responseOfficer ||
            role == UserRole.branchResponseOfficer || role == UserRole.driver) {
          return 'Contact your Administrator for access.';
        }
        if (role == UserRole.monitor) return 'View-only staff directory.';
        if (role == UserRole.branchMonitor) return 'Branch view-only staff access.';
        if (role == UserRole.branchManager) return 'Branch staff management. Role changes require Admin OTP.';
        return null;

      case 'activity_log':
        if (role == UserRole.socialOfficer || role == UserRole.branchSocialOfficer ||
            role == UserRole.driver) {
          return 'Contact your Administrator for access.';
        }
        if (role == UserRole.monitor || role == UserRole.branchMonitor) {
          return 'Redacted view — user identities are masked.';
        }
        if (role == UserRole.responseOfficer || role == UserRole.branchResponseOfficer) {
          return 'View-only access to your own audit activity.';
        }
        return null;

      // ─── Logistics cards ──────────────────────────────────────────────
      case 'places':
        if (role == UserRole.socialOfficer || role == UserRole.branchSocialOfficer) {
          return 'View-only access to places for marketing context.';
        }
        if (role == UserRole.monitor) return 'View-only places access.';
        if (role == UserRole.branchMonitor) return 'Branch view-only places access.';
        if (role == UserRole.responseOfficer) return 'View-only access to places.';
        if (role == UserRole.branchResponseOfficer) return 'Branch view-only places.';
        if (role == UserRole.driver) return 'View-only access to delivery places.';
        return null;

      case 'delivery_zones':
        if (role == UserRole.owner || role == UserRole.socialOfficer ||
            role == UserRole.branchSocialOfficer) {
          return 'Contact your Administrator for access.';
        }
        if (role == UserRole.monitor) return 'View-only zone access.';
        if (role == UserRole.branchMonitor) return 'Branch view-only zone access.';
        if (role == UserRole.responseOfficer) return 'View-only delivery zones.';
        if (role == UserRole.branchResponseOfficer) return 'Branch view-only zones.';
        if (role == UserRole.driver) return 'View your assigned delivery zones.';
        return null;

      case 'vehicle_bands':
        if (role == UserRole.owner || role == UserRole.socialOfficer ||
            role == UserRole.branchSocialOfficer || role == UserRole.responseOfficer ||
            role == UserRole.branchResponseOfficer || role == UserRole.driver) {
          return 'Contact your Administrator for access.';
        }
        if (role == UserRole.monitor) return 'View-only vehicle band access.';
        if (role == UserRole.branchMonitor) return 'Branch view-only band access.';
        return null;

      // ─── Engagement cards ─────────────────────────────────────────────
      case 'marketing':
        if (role == UserRole.responseOfficer || role == UserRole.branchResponseOfficer ||
            role == UserRole.driver) {
          return 'Contact your Administrator for access.';
        }
        if (role == UserRole.monitor) return 'View-only campaign access.';
        if (role == UserRole.branchMonitor) return 'Branch view-only campaign access.';
        return null;

      case 'social':
        if (role == UserRole.monitor) return 'View-only social feed access.';
        if (role == UserRole.branchMonitor) return 'Branch view-only feed access.';
        if (role == UserRole.responseOfficer || role == UserRole.branchResponseOfficer) {
          return 'View and comment on social posts.';
        }
        if (role == UserRole.driver) return 'View and comment on assigned content.';
        return null;

      case 'connections':
        if (role == UserRole.monitor) return 'View-only connections access.';
        if (role == UserRole.branchMonitor) return 'Branch view-only connections.';
        if (role == UserRole.responseOfficer || role == UserRole.branchResponseOfficer ||
            role == UserRole.driver) {
          return 'Manage your personal connections only.';
        }
        return null;

      // ─── Branch Identity cards ────────────────────────────────────────
      case 'profile':
        return null; // All roles can access profile (personal scope).

      case 'outlook':
        if (role == UserRole.driver) return 'Contact your Administrator for access.';
        if (role == UserRole.socialOfficer) return 'View marketing and engagement analytics.';
        if (role == UserRole.branchSocialOfficer) return 'Branch marketing analytics.';
        if (role == UserRole.monitor) return 'View-only analytics access.';
        if (role == UserRole.branchMonitor) return 'Branch view-only analytics.';
        if (role == UserRole.responseOfficer) return 'Operational performance analytics.';
        if (role == UserRole.branchResponseOfficer) return 'Branch OPS analytics.';
        return null;

      case 'subscription':
        if (role == UserRole.socialOfficer || role == UserRole.branchSocialOfficer ||
            role == UserRole.monitor || role == UserRole.branchMonitor ||
            role == UserRole.responseOfficer || role == UserRole.branchResponseOfficer ||
            role == UserRole.driver) {
          return 'Contact your Administrator for access.';
        }
        if (role == UserRole.branchManager) return 'Branch Manager can view only — switch to Owner context.';
        return null;

      // ─── Personal & History cards ─────────────────────────────────────
      case 'interests':
        if (role == UserRole.monitor) return 'View-only interest analytics.';
        if (role == UserRole.branchMonitor) return 'Branch view-only interests.';
        if (role == UserRole.responseOfficer) return 'View-only interests.';
        if (role == UserRole.branchResponseOfficer) return 'Branch view-only interests.';
        if (role == UserRole.driver) return 'Manage your personal interests only.';
        return null;

      case 'qpoints':
        if (role == UserRole.socialOfficer || role == UserRole.branchSocialOfficer ||
            role == UserRole.responseOfficer || role == UserRole.branchResponseOfficer ||
            role == UserRole.driver) {
          return 'Contact your Administrator for access.';
        }
        if (role == UserRole.monitor) return 'View Q-Points summary (no details).';
        if (role == UserRole.branchMonitor) return 'Branch Q-Points summary.';
        return null;

      case 'my_activity':
        return null; // All roles have full personal access.

      default:
        return null;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PER-SCREEN ACTION PERMISSIONS
  // ══════════════════════════════════════════════════════════════════════════

  /// Returns the full action permission for [cardId] for [role].
  ///
  /// Screens should use this to gate individual buttons/menus rather than
  /// re-implementing permission logic.
  static SetupActionPermission getActionPermission(String cardId, UserRole role) {
    switch (cardId) {
      case 'products':         return _products(role);
      case 'vehicles':         return _vehicles(role);
      case 'tabs':             return _tabs(role);
      case 'discounts':        return _discounts(role);
      case 'staff':            return _staff(role);
      case 'activity_log':     return _activityLog(role);
      case 'places':           return _places(role);
      case 'delivery_zones':   return _deliveryZones(role);
      case 'vehicle_bands':    return _vehicleBands(role);
      case 'branches':         return _branches(role);
      case 'marketing':        return _marketing(role);
      case 'social':           return _social(role);
      case 'connections':      return _connections(role);
      case 'profile':          return _profile(role);
      case 'outlook':          return _outlook(role);
      case 'subscription':     return _subscription(role);
      case 'interests':        return _interests(role);
      case 'qpoints':          return _qpoints(role);
      case 'my_activity':      return _myActivity(role);
      default:                 return SetupActionPermission.none;
    }
  }

  // ─── Screen 1.1: Products ─────────────────────────────────────────────────
  static SetupActionPermission _products(UserRole role) {
    switch (role) {
      case UserRole.administrator:
        return const SetupActionPermission(
          canCreate: true, canEdit: true, canDelete: true, canExport: true,
          tooltipMessage: null,
        );
      case UserRole.branchManager:
        return const SetupActionPermission(
          canCreate: true, canEdit: true, canDelete: false, canExport: true,
          isBranchScoped: true,
          tooltipMessage: 'Branch Manager: Cannot delete entity-level products.',
        );
      case UserRole.monitor:
        return const SetupActionPermission(tooltipMessage: 'View-only access.');
      case UserRole.branchMonitor:
        return const SetupActionPermission(isBranchScoped: true, tooltipMessage: 'Branch view-only.');
      case UserRole.responseOfficer:
        return const SetupActionPermission(tooltipMessage: 'View-only access for operational needs.');
      case UserRole.branchResponseOfficer:
        return const SetupActionPermission(isBranchScoped: true, tooltipMessage: 'Branch view-only.');
      default:
        return SetupActionPermission.none;
    }
  }

  // ─── Screen 1.2: Vehicles (Fleet Command) ────────────────────────────────
  static SetupActionPermission _vehicles(UserRole role) {
    switch (role) {
      case UserRole.administrator:
        return const SetupActionPermission(
          canCreate: true, canEdit: true, canDelete: true, canExport: true,
        );
      case UserRole.branchManager:
        return const SetupActionPermission(
          canCreate: true, canEdit: true, canDelete: false, canExport: true,
          isBranchScoped: true,
          tooltipMessage: 'Branch-scoped fleet management.',
        );
      case UserRole.responseOfficer:
        // Can assign vehicles and update status; cannot delete.
        return const SetupActionPermission(
          canCreate: false, canEdit: true, canDelete: false,
          tooltipMessage: 'Assign vehicles and update status. Cannot delete.',
        );
      case UserRole.branchResponseOfficer:
        return const SetupActionPermission(
          canCreate: false, canEdit: true, canDelete: false,
          isBranchScoped: true,
          tooltipMessage: 'Branch vehicle assignments only.',
        );
      case UserRole.driver:
        // View own vehicle only.
        return const SetupActionPermission(
          canCreate: false, canEdit: false, canDelete: false,
          tooltipMessage: 'View your assigned vehicle and update your status.',
        );
      case UserRole.monitor:
        return const SetupActionPermission(tooltipMessage: 'View-only fleet access.');
      case UserRole.branchMonitor:
        return const SetupActionPermission(isBranchScoped: true, tooltipMessage: 'Branch view-only fleet.');
      default:
        return SetupActionPermission.none;
    }
  }

  // ─── Screen 1.3: Tabs ────────────────────────────────────────────────────
  static SetupActionPermission _tabs(UserRole role) {
    switch (role) {
      case UserRole.administrator:
        return const SetupActionPermission(
          canCreate: true, canEdit: true, canDelete: true,
        );
      case UserRole.branchManager:
        return const SetupActionPermission(
          canCreate: true, canEdit: true, canDelete: false,
          isBranchScoped: true,
        );
      case UserRole.monitor:
        return const SetupActionPermission(tooltipMessage: 'View-only tab access.');
      case UserRole.branchMonitor:
        return const SetupActionPermission(isBranchScoped: true, tooltipMessage: 'Branch view-only tabs.');
      default:
        return SetupActionPermission.none;
    }
  }

  // ─── Screen 1.4: Discounts ───────────────────────────────────────────────
  static SetupActionPermission _discounts(UserRole role) {
    switch (role) {
      case UserRole.administrator:
        return const SetupActionPermission(
          canCreate: true, canEdit: true, canDelete: true,
        );
      case UserRole.branchManager:
        return const SetupActionPermission(
          canCreate: true, canEdit: true, canDelete: false,
          isBranchScoped: true,
        );
      case UserRole.socialOfficer:
        // Marketing access: create promotional discounts.
        return const SetupActionPermission(
          canCreate: true, canEdit: true, canDelete: false,
          tooltipMessage: 'Marketing access — create promotional discounts.',
        );
      case UserRole.branchSocialOfficer:
        return const SetupActionPermission(
          canCreate: true, canEdit: true, canDelete: false,
          isBranchScoped: true,
          tooltipMessage: 'Create branch promotions.',
        );
      case UserRole.monitor:
        return const SetupActionPermission(tooltipMessage: 'View-only discount access.');
      case UserRole.branchMonitor:
        return const SetupActionPermission(isBranchScoped: true, tooltipMessage: 'Branch view-only discounts.');
      default:
        return SetupActionPermission.none;
    }
  }

  // ─── Screen 1.5: Staff ───────────────────────────────────────────────────
  static SetupActionPermission _staff(UserRole role) {
    switch (role) {
      case UserRole.administrator:
        return const SetupActionPermission(
          canCreate: true, canEdit: true, canDelete: true, canExport: true,
          tooltipMessage: 'Full control — add/remove staff, assign roles.',
        );
      case UserRole.branchManager:
        // Role changes require Admin OTP.
        return const SetupActionPermission(
          canCreate: true, canEdit: true, canDelete: false,
          isBranchScoped: true, requiresOtp: true,
          tooltipMessage: 'Branch staff management. Role changes require Admin OTP.',
        );
      case UserRole.monitor:
        return const SetupActionPermission(tooltipMessage: 'View-only staff directory.');
      case UserRole.branchMonitor:
        return const SetupActionPermission(isBranchScoped: true, tooltipMessage: 'Branch view-only staff.');
      default:
        return SetupActionPermission.none;
    }
  }

  // ─── Screen 2.1: Activity Log (Audit) ────────────────────────────────────
  static SetupActionPermission _activityLog(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return const SetupActionPermission(tooltipMessage: 'Your personal activity only.');
      case UserRole.administrator:
        // Full details + export (OTP required for export).
        return const SetupActionPermission(
          canExport: true, requiresOtp: true,
          tooltipMessage: 'Full audit access with export capability.',
        );
      case UserRole.branchManager:
        return const SetupActionPermission(
          canExport: true,
          isBranchScoped: true,
          tooltipMessage: 'Branch audit logs only.',
        );
      case UserRole.monitor:
        // Redacted view — user identities masked.
        return const SetupActionPermission(
          isRedacted: true,
          tooltipMessage: 'Redacted view — user identities are masked.',
        );
      case UserRole.branchMonitor:
        return const SetupActionPermission(
          isRedacted: true,
          isBranchScoped: true,
          tooltipMessage: 'Branch redacted audit view.',
        );
      case UserRole.responseOfficer:
        return const SetupActionPermission(tooltipMessage: 'View your personal actions only.');
      case UserRole.branchResponseOfficer:
        return const SetupActionPermission(isBranchScoped: true, tooltipMessage: 'View your branch actions only.');
      default:
        return SetupActionPermission.none;
    }
  }

  // ─── Screen 1.6: Places ──────────────────────────────────────────────────
  static SetupActionPermission _places(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return const SetupActionPermission(canCreate: true, canEdit: true, canDelete: true);
      case UserRole.administrator:
        return const SetupActionPermission(canCreate: true, canEdit: true, canDelete: true);
      case UserRole.branchManager:
        return const SetupActionPermission(
          canCreate: true, canEdit: true, canDelete: false,
          isBranchScoped: true,
        );
      case UserRole.socialOfficer:
        return const SetupActionPermission(tooltipMessage: 'View-only for marketing context.');
      case UserRole.branchSocialOfficer:
        return const SetupActionPermission(isBranchScoped: true, tooltipMessage: 'Branch view-only places.');
      case UserRole.monitor:
        return const SetupActionPermission(tooltipMessage: 'View-only places access.');
      case UserRole.branchMonitor:
        return const SetupActionPermission(isBranchScoped: true, tooltipMessage: 'Branch view-only places.');
      case UserRole.responseOfficer:
        return const SetupActionPermission(tooltipMessage: 'View-only access for operational needs.');
      case UserRole.branchResponseOfficer:
        return const SetupActionPermission(isBranchScoped: true, tooltipMessage: 'Branch view-only places.');
      case UserRole.driver:
        return const SetupActionPermission(tooltipMessage: 'View-only access for deliveries.');
      default:
        return SetupActionPermission.none;
    }
  }

  // ─── Screen 1.7: Delivery Zones ──────────────────────────────────────────
  static SetupActionPermission _deliveryZones(UserRole role) {
    switch (role) {
      case UserRole.administrator:
        return const SetupActionPermission(canCreate: true, canEdit: true, canDelete: true);
      case UserRole.branchManager:
        return const SetupActionPermission(
          canCreate: true, canEdit: true, canDelete: false,
          isBranchScoped: true,
        );
      case UserRole.monitor:
        return const SetupActionPermission(tooltipMessage: 'View zone maps only.');
      case UserRole.branchMonitor:
        return const SetupActionPermission(isBranchScoped: true, tooltipMessage: 'Branch view-only zones.');
      case UserRole.responseOfficer:
        return const SetupActionPermission(tooltipMessage: 'View-only for operational planning.');
      case UserRole.branchResponseOfficer:
        return const SetupActionPermission(isBranchScoped: true, tooltipMessage: 'Branch view-only zones.');
      case UserRole.driver:
        return const SetupActionPermission(tooltipMessage: 'View assigned delivery zones.');
      default:
        return SetupActionPermission.none;
    }
  }

  // ─── Screen 1.8: Vehicle Bands ───────────────────────────────────────────
  static SetupActionPermission _vehicleBands(UserRole role) {
    switch (role) {
      case UserRole.administrator:
        return const SetupActionPermission(canCreate: true, canEdit: true, canDelete: true);
      case UserRole.branchManager:
        return const SetupActionPermission(
          canCreate: true, canEdit: true, canDelete: false,
          isBranchScoped: true,
        );
      case UserRole.monitor:
        return const SetupActionPermission(tooltipMessage: 'View band assignments only.');
      case UserRole.branchMonitor:
        return const SetupActionPermission(isBranchScoped: true, tooltipMessage: 'Branch view-only bands.');
      default:
        return SetupActionPermission.none;
    }
  }

  // ─── Screen 1.9: Branches ────────────────────────────────────────────────
  static SetupActionPermission _branches(UserRole role) {
    switch (role) {
      case UserRole.administrator:
        // Creating a branch requires OTP.
        return const SetupActionPermission(
          canCreate: true, canEdit: true, canDelete: true,
          requiresOtp: true,
          tooltipMessage: 'Create/delete requires OTP verification.',
        );
      case UserRole.monitor:
        return const SetupActionPermission(tooltipMessage: 'View branch hierarchy only.');
      default:
        return SetupActionPermission.none;
    }
  }

  // ─── Screen 1.10: Campaign Manager (Marketing) ───────────────────────────
  static SetupActionPermission _marketing(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return const SetupActionPermission(
          canCreate: true, canEdit: true, canDelete: false,
          tooltipMessage: 'Create personal marketing campaigns.',
        );
      case UserRole.administrator:
        return const SetupActionPermission(canCreate: true, canEdit: true, canDelete: true);
      case UserRole.branchManager:
        return const SetupActionPermission(
          canCreate: true, canEdit: true, canDelete: false,
          isBranchScoped: true,
        );
      case UserRole.socialOfficer:
        return const SetupActionPermission(canCreate: true, canEdit: true, canDelete: true);
      case UserRole.branchSocialOfficer:
        return const SetupActionPermission(
          canCreate: true, canEdit: true, canDelete: true,
          isBranchScoped: true,
        );
      case UserRole.monitor:
        return const SetupActionPermission(tooltipMessage: 'View campaign analytics only.');
      case UserRole.branchMonitor:
        return const SetupActionPermission(isBranchScoped: true, tooltipMessage: 'Branch view-only campaigns.');
      default:
        return SetupActionPermission.none;
    }
  }

  // ─── Screen 1.11: Social & Updates ───────────────────────────────────────
  static SetupActionPermission _social(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return const SetupActionPermission(
          canCreate: true, canEdit: true, canDelete: false,
          tooltipMessage: 'Create personal social posts.',
        );
      case UserRole.administrator:
        return const SetupActionPermission(canCreate: true, canEdit: true, canDelete: true);
      case UserRole.branchManager:
        return const SetupActionPermission(
          canCreate: true, canEdit: true, canDelete: false,
          isBranchScoped: true,
        );
      case UserRole.socialOfficer:
        return const SetupActionPermission(canCreate: true, canEdit: true, canDelete: true);
      case UserRole.branchSocialOfficer:
        return const SetupActionPermission(
          canCreate: true, canEdit: true, canDelete: true,
          isBranchScoped: true,
        );
      case UserRole.monitor:
        return const SetupActionPermission(tooltipMessage: 'View feed only.');
      case UserRole.branchMonitor:
        return const SetupActionPermission(isBranchScoped: true, tooltipMessage: 'Branch view-only feed.');
      case UserRole.responseOfficer:
      case UserRole.branchResponseOfficer:
      case UserRole.driver:
        // Can view and comment.
        return const SetupActionPermission(
          canCreate: false, canEdit: false, canDelete: false,
          tooltipMessage: 'View and comment on posts.',
        );
      default:
        return SetupActionPermission.none;
    }
  }

  // ─── Screen 1.12: Connections ────────────────────────────────────────────
  static SetupActionPermission _connections(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return const SetupActionPermission(canCreate: true, canEdit: true, canDelete: true);
      case UserRole.administrator:
        return const SetupActionPermission(canCreate: true, canEdit: true, canDelete: true);
      case UserRole.branchManager:
        return const SetupActionPermission(
          canCreate: true, canEdit: true, canDelete: false,
          isBranchScoped: true,
        );
      case UserRole.socialOfficer:
        return const SetupActionPermission(canCreate: true, canEdit: true, canDelete: true);
      case UserRole.branchSocialOfficer:
        return const SetupActionPermission(
          canCreate: true, canEdit: true, canDelete: true,
          isBranchScoped: true,
        );
      case UserRole.monitor:
        return const SetupActionPermission(tooltipMessage: 'View connection network only.');
      case UserRole.branchMonitor:
        return const SetupActionPermission(isBranchScoped: true, tooltipMessage: 'Branch view-only connections.');
      case UserRole.responseOfficer:
      case UserRole.branchResponseOfficer:
      case UserRole.driver:
        // Own connections only.
        return const SetupActionPermission(
          canCreate: true, canEdit: true, canDelete: true,
          tooltipMessage: 'Manage your personal connections only.',
        );
      default:
        return SetupActionPermission.none;
    }
  }

  // ─── Screen 3.1: Profile ─────────────────────────────────────────────────
  static SetupActionPermission _profile(UserRole role) {
    // All roles can edit their personal profile.
    switch (role) {
      case UserRole.owner:
      case UserRole.administrator:
      case UserRole.branchManager:
        return const SetupActionPermission(
          canCreate: false, canEdit: true, canDelete: false,
          tooltipMessage: null,
        );
      default:
        // All others edit personal profile only.
        return const SetupActionPermission(
          canCreate: false, canEdit: true, canDelete: false,
          tooltipMessage: 'Edit your personal profile only.',
        );
    }
  }

  // ─── Screen 2.2: Outlook ─────────────────────────────────────────────────
  static SetupActionPermission _outlook(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return const SetupActionPermission(tooltipMessage: 'Personal performance metrics.');
      case UserRole.administrator:
        return const SetupActionPermission(canExport: true);
      case UserRole.branchManager:
        return const SetupActionPermission(canExport: true, isBranchScoped: true);
      case UserRole.socialOfficer:
        return const SetupActionPermission(tooltipMessage: 'Engagement and campaign metrics.');
      case UserRole.branchSocialOfficer:
        return const SetupActionPermission(isBranchScoped: true, tooltipMessage: 'Branch engagement metrics.');
      case UserRole.monitor:
        return const SetupActionPermission(tooltipMessage: 'View-only analytics dashboard.');
      case UserRole.branchMonitor:
        return const SetupActionPermission(isBranchScoped: true, tooltipMessage: 'Branch view-only analytics.');
      case UserRole.responseOfficer:
        return const SetupActionPermission(tooltipMessage: 'OPS performance metrics.');
      case UserRole.branchResponseOfficer:
        return const SetupActionPermission(isBranchScoped: true, tooltipMessage: 'Branch OPS metrics.');
      default:
        return SetupActionPermission.none;
    }
  }

  // ─── Screen 3.2: Subscription ────────────────────────────────────────────
  static SetupActionPermission _subscription(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return const SetupActionPermission(
          canEdit: true, requiresOtp: true,
          tooltipMessage: 'Manage personal plan. Upgrade requires verification.',
        );
      case UserRole.administrator:
        return const SetupActionPermission(
          canEdit: true, requiresOtp: true,
          tooltipMessage: 'Manage entity plan. Upgrade requires verification.',
        );
      case UserRole.branchManager:
        return const SetupActionPermission(
          tooltipMessage: 'Branch Manager can view subscription status only.',
        );
      default:
        return SetupActionPermission.none;
    }
  }

  // ─── Screen 3.3: Interests ───────────────────────────────────────────────
  static SetupActionPermission _interests(UserRole role) {
    switch (role) {
      case UserRole.owner:
      case UserRole.administrator:
      case UserRole.branchManager:
      case UserRole.socialOfficer:
      case UserRole.branchSocialOfficer:
        return const SetupActionPermission(canCreate: true, canEdit: true, canDelete: true);
      case UserRole.monitor:
        return const SetupActionPermission(tooltipMessage: 'View interest analytics only.');
      case UserRole.branchMonitor:
        return const SetupActionPermission(isBranchScoped: true, tooltipMessage: 'Branch view-only interests.');
      case UserRole.responseOfficer:
        return const SetupActionPermission(tooltipMessage: 'View-only interests.');
      case UserRole.branchResponseOfficer:
        return const SetupActionPermission(isBranchScoped: true, tooltipMessage: 'Branch view-only interests.');
      case UserRole.driver:
        return const SetupActionPermission(
          canCreate: true, canEdit: true, canDelete: true,
          tooltipMessage: 'Manage personal interests only.',
        );
      default:
        return SetupActionPermission.none;
    }
  }

  // ─── Screen 2.3: Q-Points History ────────────────────────────────────────
  static SetupActionPermission _qpoints(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return const SetupActionPermission(canExport: true, tooltipMessage: 'Full personal Q-points management.');
      case UserRole.administrator:
        return const SetupActionPermission(canExport: true);
      case UserRole.branchManager:
        return const SetupActionPermission(isBranchScoped: true, tooltipMessage: 'View branch Q-points activity.');
      case UserRole.monitor:
        return const SetupActionPermission(tooltipMessage: 'View Q-points summary (no details).');
      case UserRole.branchMonitor:
        return const SetupActionPermission(isBranchScoped: true, tooltipMessage: 'Branch Q-points summary.');
      default:
        return SetupActionPermission.none;
    }
  }

  // ─── Screen 2.4: My Activity ─────────────────────────────────────────────
  static SetupActionPermission _myActivity(UserRole role) {
    // All roles — personal dashboard scope.
    return const SetupActionPermission(
      canExport: true,
      tooltipMessage: 'Personal tasks and goals.',
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CROSS-BRANCH VISIBILITY HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  /// Whether [role] can see data from all branches.
  static bool canSeeAllBranches(UserRole role) {
    return role == UserRole.administrator ||
        role == UserRole.monitor ||
        role == UserRole.socialOfficer;
  }

  /// Whether [role] is limited to only their assigned branch.
  static bool isBranchOnlyRole(UserRole role) {
    return role == UserRole.branchManager ||
        role == UserRole.branchSocialOfficer ||
        role == UserRole.branchMonitor ||
        role == UserRole.branchResponseOfficer;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HIERARCHY OVERRIDE HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  /// Whether [overrider] can override decisions made by [subordinate].
  static bool canOverride(UserRole overrider, UserRole subordinate) {
    const hierarchy = [
      UserRole.administrator,
      UserRole.branchManager,
      UserRole.socialOfficer,
      UserRole.responseOfficer,
      UserRole.branchSocialOfficer,
      UserRole.branchResponseOfficer,
      UserRole.monitor,
      UserRole.branchMonitor,
      UserRole.driver,
    ];
    final overriderIndex = hierarchy.indexOf(overrider);
    final subordinateIndex = hierarchy.indexOf(subordinate);
    if (overriderIndex < 0 || subordinateIndex < 0) return false;
    return overriderIndex < subordinateIndex;
  }
}
