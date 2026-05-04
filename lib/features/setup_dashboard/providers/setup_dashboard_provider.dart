/// ═══════════════════════════════════════════════════════════════════════════
/// SETUP DASHBOARD MODULE — Provider (State Management)
/// RBAC-aware data management wired to real API services with fallback data
/// Manages: Dashboard Hub, Products, Vehicles, Tabs, Discounts, Staff,
/// Places, Zones, Bands, Branches, Campaigns, Social, Connections,
/// Audit, Outlook, Q-Points, My Activity, Profile, Subscription, Interests
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/services/services.dart';
import '../../prompt/models/rbac_models.dart';
import '../models/setup_dashboard_models.dart';
import '../models/setup_rbac.dart';

class SetupDashboardProvider extends ChangeNotifier {
  // ═══════════════════════════════════════════════════════════════════════════
  // SERVICE INSTANCES
  // ═══════════════════════════════════════════════════════════════════════════

  final ProductService _productService = ProductService();
  final VehicleService _vehicleService = VehicleService();
  final PlaceService _placeService = PlaceService();
  final SocialService _socialService = SocialService();
  final InterestService _interestService = InterestService();
  final SubscriptionService _subscriptionService = SubscriptionService();
  final QPointsService _qPointsService = QPointsService();
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();

  // ═══════════════════════════════════════════════════════════════════════════
  // MUTABLE INSTANCE DATA (loaded from API)
  // ═══════════════════════════════════════════════════════════════════════════

  List<Product> _products = [];
  List<Vehicle> _vehicles = [];
  List<VehicleBand> _bands = [];
  List<Place> _places = [];
  List<SocialPost> _posts = [];
  List<Connection> _connections = [];
  List<QPointsTransaction> _qPointsTransactions = [];
  List<UserInterest> _interests = [];
  SubscriptionInfo? _subscriptionInfo;
  UserProfile? _userProfile;
  DashboardHeaderInfo? _headerInfoData;

  // Fallback-only sections (no backend endpoint yet)
  List<MaintenanceRecord> _maintenanceRecords = [];
  List<FuelEntry> _fuelEntries = [];
  List<CustomerTab> _tabs = [];
  List<TabTransaction> _tabTransactions = [];
  List<DiscountTier> _discounts = [];
  List<StaffMember> _staff = [];
  List<DeliveryZone> _zones = [];
  List<Branch> _branches = [];
  List<Campaign> _campaigns = [];
  List<AuditEntry> _auditEntries = [];
  List<KPIMetric> _kpiMetrics = [];
  List<AIInsight> _aiInsights = [];
  List<UserTask> _tasks = [];
  List<UserGoal> _goals = [];
  List<ActivityTimelineEntry> _timeline = [];
  List<InterestRecommendation> _recommendations = [];

  // ═══════════════════════════════════════════════════════════════════════════
  // INIT — loads all API-backed data
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      loadHeaderInfo(),
      loadProducts(),
      loadVehicles(),
      loadVehicleBands(),
      loadPlaces(),
      loadPosts(),
      loadConnections(),
      loadQPointsTransactions(),
      loadInterests(),
      loadSubscription(),
      loadProfile(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOAD METHODS (API-backed)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> loadHeaderInfo() async {
    try {
      final response = await _authService.getMe();
      if (response.success && response.data != null) {
        final d = response.data!;
        _headerInfoData = DashboardHeaderInfo(
          userName: d['firstName'] != null
              ? '${d['firstName']} ${d['lastName'] ?? ''}'.trim()
              : 'John Doe',
          roleName: d['role'] as String? ?? 'Administrator',
          branchName: d['branch'] as String? ?? 'East Ridge',
          syncState: _syncState,
          lastUpdated: DateTime.now(),
        );
      }
    } catch (_) {
      // fall back to hardcoded
    }
  }

  Future<void> loadProducts() async {
    try {
      _sectionStates['products'] = CardState.loading;
      notifyListeners();
      final response = await _productService.getProducts(limit: 100);
      if (response.success && response.data != null) {
        _products = response.data!.map(_productFromJson).toList();
      }
      _sectionStates['products'] = CardState.loaded;
    } catch (_) {
      _products = [];
      _sectionStates['products'] = CardState.error;
    }
    notifyListeners();
  }

  Future<void> loadVehicles() async {
    try {
      _sectionStates['vehicles'] = CardState.loading;
      notifyListeners();
      final response = await _vehicleService.getVehicles(limit: 100);
      if (response.success && response.data != null) {
        _vehicles = response.data!.map(_vehicleFromJson).toList();
      }
      _sectionStates['vehicles'] = CardState.loaded;
    } catch (_) {
      _vehicles = [];
      _sectionStates['vehicles'] = CardState.error;
    }
    notifyListeners();
  }

  Future<void> loadVehicleBands() async {
    try {
      _sectionStates['vehicle_bands'] = CardState.loading;
      notifyListeners();
      final response = await _vehicleService.getBands(limit: 100);
      if (response.success && response.data != null) {
        _bands = response.data!.map(_vehicleBandFromJson).toList();
      }
      _sectionStates['vehicle_bands'] = CardState.loaded;
    } catch (_) {
      _bands = [];
      _sectionStates['vehicle_bands'] = CardState.error;
    }
    notifyListeners();
  }

  Future<void> loadPlaces() async {
    try {
      _sectionStates['places'] = CardState.loading;
      notifyListeners();
      final response = await _placeService.getPlaces(limit: 100);
      if (response.success && response.data != null) {
        _places = response.data!.map(_placeFromJson).toList();
      }
      _sectionStates['places'] = CardState.loaded;
    } catch (_) {
      _places = [];
      _sectionStates['places'] = CardState.error;
    }
    notifyListeners();
  }

  Future<void> loadPosts() async {
    try {
      _sectionStates['social'] = CardState.loading;
      notifyListeners();
      final response = await _socialService.getUpdates(limit: 100);
      if (response.success && response.data != null) {
        _posts = response.data!.map(_socialPostFromJson).toList();
      }
      _sectionStates['social'] = CardState.loaded;
    } catch (_) {
      _posts = [];
      _sectionStates['social'] = CardState.error;
    }
    notifyListeners();
  }

  Future<void> loadConnections() async {
    try {
      _sectionStates['connections'] = CardState.loading;
      notifyListeners();
      // Need a userId — try to get from auth
      final meResponse = await _authService.getMe();
      final userId = meResponse.data?['id'] as String? ?? '';
      if (userId.isNotEmpty) {
        final response = await _interestService.getConnections(userId);
        if (response.success && response.data != null) {
          _connections = response.data!.map(_connectionFromJson).toList();
        }
      }
      _sectionStates['connections'] = CardState.loaded;
    } catch (_) {
      _connections = [];
      _sectionStates['connections'] = CardState.error;
    }
    notifyListeners();
  }

  Future<void> loadQPointsTransactions() async {
    try {
      _sectionStates['qpoints'] = CardState.loading;
      notifyListeners();
      final response = await _qPointsService.getTransactions(limit: 100);
      if (response.success && response.data != null) {
        _qPointsTransactions =
            response.data!.map(_qPointsTransactionFromJson).toList();
      }
      _sectionStates['qpoints'] = CardState.loaded;
    } catch (_) {
      _qPointsTransactions = [];
      _sectionStates['qpoints'] = CardState.error;
    }
    notifyListeners();
  }

  Future<void> loadInterests() async {
    try {
      _sectionStates['interests'] = CardState.loading;
      notifyListeners();
      final meResponse = await _authService.getMe();
      final userId = meResponse.data?['id'] as String? ?? '';
      if (userId.isNotEmpty) {
        final response = await _interestService.getInterests(userId);
        if (response.success && response.data != null) {
          _interests = response.data!.map(_userInterestFromJson).toList();
        }
      }
      _sectionStates['interests'] = CardState.loaded;
    } catch (_) {
      _interests = [];
      _sectionStates['interests'] = CardState.error;
    }
    notifyListeners();
  }

  Future<void> loadSubscription() async {
    try {
      _sectionStates['subscription'] = CardState.loading;
      notifyListeners();
      final meResponse = await _authService.getMe();
      final userId = meResponse.data?['id'] as String? ?? '';
      if (userId.isNotEmpty) {
        final response = await _subscriptionService.getActiveSubscription(
          targetType: 'user',
          targetId: userId,
        );
        if (response.success && response.data != null) {
          _subscriptionInfo = _subscriptionInfoFromJson(response.data!);
        }
      }
      _sectionStates['subscription'] = CardState.loaded;
    } catch (_) {
      _subscriptionInfo = null;
      _sectionStates['subscription'] = CardState.error;
    }
    notifyListeners();
  }

  Future<void> loadProfile() async {
    try {
      _sectionStates['profile'] = CardState.loading;
      notifyListeners();
      final meResponse = await _authService.getMe();
      final userId = meResponse.data?['id'] as String? ?? '';
      if (userId.isNotEmpty) {
        final response = await _profileService.getProfileByUserId(userId);
        if (response.success && response.data != null) {
          _userProfile = _userProfileFromJson(response.data!);
        }
      }
      _sectionStates['profile'] = CardState.loaded;
    } catch (_) {
      _userProfile = null;
      _sectionStates['profile'] = CardState.error;
    }
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 1: DASHBOARD HUB STATE
  // ═══════════════════════════════════════════════════════════════════════════

  DashboardHeaderInfo get headerInfo =>
      _headerInfoData ??
      DashboardHeaderInfo(
        userName: 'John Doe',
        roleName: 'Administrator',
        branchName: 'East Ridge',
        syncState: _syncState,
        lastUpdated: DateTime.now(),
      );

  SyncState _syncState = SyncState.synced;
  SyncState get syncState => _syncState;

  /// Get the cards visible for a given role, with proper access levels
  List<DashboardCard> getCardsForRole(UserRole role) {
    final allCards = _allDashboardCards;
    return allCards
        .map((card) {
          final access = _getCardAccess(card.id, role);
          if (access == CardAccessLevel.hidden) return null;
          return DashboardCard(
            id: card.id,
            title: card.title,
            icon: card.icon,
            route: card.route,
            state: card.state,
            alertCount: card.alertCount,
            metrics: card.metrics,
            actionLabels: access == CardAccessLevel.viewOnly ||
                    access == CardAccessLevel.branchViewOnly
                ? ['View']
                : card.actionLabels,
            accessLevel: access,
          );
        })
        .whereType<DashboardCard>()
        .toList();
  }

  /// Master RBAC matrix for dashboard cards
  CardAccessLevel _getCardAccess(String cardId, UserRole role) {
    final matrix = _rbacMatrix[cardId];
    if (matrix == null) return CardAccessLevel.hidden;
    return matrix[role] ?? CardAccessLevel.hidden;
  }

  /// Public accessor for RBAC — screens use this to gate UI
  CardAccessLevel getCardAccess(String cardId, UserRole role) =>
      _getCardAccess(cardId, role);

  /// Convenience: does the role allow write actions?
  bool canEdit(String cardId, UserRole role) {
    final level = _getCardAccess(cardId, role);
    return level == CardAccessLevel.fullAccess ||
        level == CardAccessLevel.branchScoped ||
        level == CardAccessLevel.personalOnly ||
        level == CardAccessLevel.ownOnly;
  }

  /// Convenience: is the view scoped to a branch?
  bool isBranchScoped(String cardId, UserRole role) {
    final level = _getCardAccess(cardId, role);
    return level == CardAccessLevel.branchScoped ||
        level == CardAccessLevel.branchViewOnly;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RBAC AUTHORITY DELEGATION — delegates to SetupDashboardRBAC
  // ═══════════════════════════════════════════════════════════════════════════

  /// Full action-level permission for a card + role pair.
  SetupActionPermission getActionPermission(String cardId, UserRole role) =>
      SetupDashboardRBAC.getActionPermission(cardId, role);

  /// Whether [role] can export [dataType].
  bool canExportData(String dataType, UserRole role) =>
      SetupDashboardRBAC.canExport(dataType, role);

  /// Whether [action] on [cardId] requires OTP for [role].
  bool requiresOtpFor(String cardId, String action, UserRole role) =>
      SetupDashboardRBAC.requiresOtpFor(cardId, action, role);

  /// Whether [role] sees [cardId] in redacted mode (PII masked).
  bool isRedactedView(String cardId, UserRole role) =>
      SetupDashboardRBAC.isRedactedView(cardId, role);

  /// Tooltip / snackbar message for a locked feature, or null if no tooltip.
  String? getTooltipMessage(String cardId, UserRole role) =>
      SetupDashboardRBAC.getTooltipMessage(cardId, role);

  static final Map<String, Map<UserRole, CardAccessLevel>> _rbacMatrix = {
    'products': {
      UserRole.administrator: CardAccessLevel.fullAccess,
      UserRole.branchManager: CardAccessLevel.branchScoped,
      UserRole.monitor: CardAccessLevel.viewOnly,
      UserRole.branchMonitor: CardAccessLevel.branchViewOnly,
      UserRole.responseOfficer: CardAccessLevel.viewOnly,
      UserRole.branchResponseOfficer: CardAccessLevel.branchViewOnly,
    },
    'vehicles': {
      UserRole.administrator: CardAccessLevel.fullAccess,
      UserRole.branchManager: CardAccessLevel.branchScoped,
      UserRole.monitor: CardAccessLevel.viewOnly,
      UserRole.branchMonitor: CardAccessLevel.branchViewOnly,
      UserRole.responseOfficer: CardAccessLevel.fullAccess,
      UserRole.branchResponseOfficer: CardAccessLevel.branchScoped,
      UserRole.driver: CardAccessLevel.ownOnly,
    },
    'tabs': {
      UserRole.administrator: CardAccessLevel.fullAccess,
      UserRole.branchManager: CardAccessLevel.branchScoped,
      UserRole.monitor: CardAccessLevel.viewOnly,
      UserRole.branchMonitor: CardAccessLevel.branchViewOnly,
    },
    'discounts': {
      UserRole.administrator: CardAccessLevel.fullAccess,
      UserRole.branchManager: CardAccessLevel.branchScoped,
      UserRole.socialOfficer: CardAccessLevel.fullAccess,
      UserRole.branchSocialOfficer: CardAccessLevel.branchScoped,
      UserRole.monitor: CardAccessLevel.viewOnly,
      UserRole.branchMonitor: CardAccessLevel.branchViewOnly,
    },
    'staff': {
      UserRole.administrator: CardAccessLevel.fullAccess,
      UserRole.branchManager: CardAccessLevel.branchScoped,
      UserRole.monitor: CardAccessLevel.viewOnly,
      UserRole.branchMonitor: CardAccessLevel.branchViewOnly,
    },
    'activity_log': {
      UserRole.owner: CardAccessLevel.personalOnly,
      UserRole.administrator: CardAccessLevel.fullAccess,
      UserRole.branchManager: CardAccessLevel.branchScoped,
      UserRole.monitor: CardAccessLevel.viewOnly,
      UserRole.branchMonitor: CardAccessLevel.branchViewOnly,
      UserRole.responseOfficer: CardAccessLevel.viewOnly,
      UserRole.branchResponseOfficer: CardAccessLevel.branchViewOnly,
    },
    'places': {
      UserRole.owner: CardAccessLevel.fullAccess,
      UserRole.administrator: CardAccessLevel.fullAccess,
      UserRole.branchManager: CardAccessLevel.branchScoped,
      UserRole.socialOfficer: CardAccessLevel.viewOnly,
      UserRole.branchSocialOfficer: CardAccessLevel.branchViewOnly,
      UserRole.monitor: CardAccessLevel.viewOnly,
      UserRole.branchMonitor: CardAccessLevel.branchViewOnly,
      UserRole.responseOfficer: CardAccessLevel.viewOnly,
      UserRole.branchResponseOfficer: CardAccessLevel.branchViewOnly,
      UserRole.driver: CardAccessLevel.viewOnly,
    },
    'delivery_zones': {
      UserRole.administrator: CardAccessLevel.fullAccess,
      UserRole.branchManager: CardAccessLevel.branchScoped,
      UserRole.monitor: CardAccessLevel.viewOnly,
      UserRole.branchMonitor: CardAccessLevel.branchViewOnly,
      UserRole.responseOfficer: CardAccessLevel.viewOnly,
      UserRole.branchResponseOfficer: CardAccessLevel.branchViewOnly,
      UserRole.driver: CardAccessLevel.viewOnly,
    },
    'vehicle_bands': {
      UserRole.administrator: CardAccessLevel.fullAccess,
      UserRole.branchManager: CardAccessLevel.branchScoped,
      UserRole.monitor: CardAccessLevel.viewOnly,
      UserRole.branchMonitor: CardAccessLevel.branchViewOnly,
    },
    'branches': {
      UserRole.administrator: CardAccessLevel.fullAccess,
      UserRole.monitor: CardAccessLevel.viewOnly,
    },
    'marketing': {
      UserRole.owner: CardAccessLevel.personalOnly,
      UserRole.administrator: CardAccessLevel.fullAccess,
      UserRole.branchManager: CardAccessLevel.branchScoped,
      UserRole.socialOfficer: CardAccessLevel.fullAccess,
      UserRole.branchSocialOfficer: CardAccessLevel.branchScoped,
      UserRole.monitor: CardAccessLevel.viewOnly,
      UserRole.branchMonitor: CardAccessLevel.branchViewOnly,
    },
    'social': {
      UserRole.owner: CardAccessLevel.personalOnly,
      UserRole.administrator: CardAccessLevel.fullAccess,
      UserRole.branchManager: CardAccessLevel.branchScoped,
      UserRole.socialOfficer: CardAccessLevel.fullAccess,
      UserRole.branchSocialOfficer: CardAccessLevel.branchScoped,
      UserRole.monitor: CardAccessLevel.viewOnly,
      UserRole.branchMonitor: CardAccessLevel.branchViewOnly,
      UserRole.responseOfficer: CardAccessLevel.viewOnly,
      UserRole.branchResponseOfficer: CardAccessLevel.branchViewOnly,
      UserRole.driver: CardAccessLevel.viewOnly,
    },
    'connections': {
      UserRole.owner: CardAccessLevel.personalOnly,
      UserRole.administrator: CardAccessLevel.fullAccess,
      UserRole.branchManager: CardAccessLevel.branchScoped,
      UserRole.socialOfficer: CardAccessLevel.fullAccess,
      UserRole.branchSocialOfficer: CardAccessLevel.branchScoped,
      UserRole.monitor: CardAccessLevel.viewOnly,
      UserRole.branchMonitor: CardAccessLevel.branchViewOnly,
      UserRole.responseOfficer: CardAccessLevel.ownOnly,
      UserRole.branchResponseOfficer: CardAccessLevel.ownOnly,
      UserRole.driver: CardAccessLevel.ownOnly,
    },
    'profile': {
      UserRole.owner: CardAccessLevel.personalOnly,
      UserRole.administrator: CardAccessLevel.fullAccess,
      UserRole.branchManager: CardAccessLevel.branchScoped,
      UserRole.socialOfficer: CardAccessLevel.personalOnly,
      UserRole.branchSocialOfficer: CardAccessLevel.personalOnly,
      UserRole.monitor: CardAccessLevel.personalOnly,
      UserRole.branchMonitor: CardAccessLevel.personalOnly,
      UserRole.responseOfficer: CardAccessLevel.personalOnly,
      UserRole.branchResponseOfficer: CardAccessLevel.personalOnly,
      UserRole.driver: CardAccessLevel.personalOnly,
    },
    'outlook': {
      UserRole.owner: CardAccessLevel.personalOnly,
      UserRole.administrator: CardAccessLevel.fullAccess,
      UserRole.branchManager: CardAccessLevel.branchScoped,
      UserRole.socialOfficer: CardAccessLevel.viewOnly,
      UserRole.branchSocialOfficer: CardAccessLevel.branchViewOnly,
      UserRole.monitor: CardAccessLevel.viewOnly,
      UserRole.branchMonitor: CardAccessLevel.branchViewOnly,
      UserRole.responseOfficer: CardAccessLevel.viewOnly,
      UserRole.branchResponseOfficer: CardAccessLevel.branchViewOnly,
    },
    'subscription': {
      UserRole.owner: CardAccessLevel.personalOnly,
      UserRole.administrator: CardAccessLevel.fullAccess,
      UserRole.branchManager: CardAccessLevel.branchViewOnly,
    },
    'interests': {
      UserRole.owner: CardAccessLevel.personalOnly,
      UserRole.administrator: CardAccessLevel.fullAccess,
      UserRole.branchManager: CardAccessLevel.branchScoped,
      UserRole.socialOfficer: CardAccessLevel.fullAccess,
      UserRole.branchSocialOfficer: CardAccessLevel.branchScoped,
      UserRole.monitor: CardAccessLevel.viewOnly,
      UserRole.branchMonitor: CardAccessLevel.branchViewOnly,
      UserRole.responseOfficer: CardAccessLevel.viewOnly,
      UserRole.branchResponseOfficer: CardAccessLevel.branchViewOnly,
      UserRole.driver: CardAccessLevel.personalOnly,
    },
    'qpoints': {
      UserRole.owner: CardAccessLevel.personalOnly,
      UserRole.administrator: CardAccessLevel.fullAccess,
      UserRole.branchManager: CardAccessLevel.branchScoped,
      UserRole.monitor: CardAccessLevel.viewOnly,
      UserRole.branchMonitor: CardAccessLevel.branchViewOnly,
    },
    'my_activity': {
      UserRole.owner: CardAccessLevel.personalOnly,
      UserRole.administrator: CardAccessLevel.personalOnly,
      UserRole.branchManager: CardAccessLevel.personalOnly,
      UserRole.socialOfficer: CardAccessLevel.personalOnly,
      UserRole.branchSocialOfficer: CardAccessLevel.personalOnly,
      UserRole.monitor: CardAccessLevel.personalOnly,
      UserRole.branchMonitor: CardAccessLevel.personalOnly,
      UserRole.responseOfficer: CardAccessLevel.personalOnly,
      UserRole.branchResponseOfficer: CardAccessLevel.personalOnly,
      UserRole.driver: CardAccessLevel.personalOnly,
    },
  };

  /// All possible dashboard cards with hardcoded UI layout config
  List<DashboardCard> get _allDashboardCards => [
        // Row 1: Operations Snapshot
        DashboardCard(
          id: 'products',
          title: 'Products',
          icon: Icons.inventory_2,
          route: '/setup/products',
          alertCount: 3,
          progress: 0.85,
          progressLabel: '85% in stock',
          subtitle: '1,245 SKUs · 32 low stock',
          metrics: {
            'Total SKUs': '1,245',
            'Low Stock': '32',
            'Out of Stock': '8',
          },
          summaryLine: 'Reorder Alert (3 items)',
          actionLabels: ['View Products', 'Reorder Alert (3)'],
          highlightColor: const Color(0xFF3B82F6),
        ),
        DashboardCard(
          id: 'vehicles',
          title: 'Vehicles',
          icon: Icons.local_shipping,
          route: '/setup/vehicles',
          subtitle: '24 Vehicles · 3 in maintenance',
          statusDots: const [
            StatusDot(color: Color(0xFF10B981), label: 'A'),
            StatusDot(color: Color(0xFFF59E0B), label: 'M'),
            StatusDot(color: Color(0xFFEF4444), label: 'O'),
            StatusDot(color: Color(0xFF10B981), label: 'A'),
            StatusDot(color: Color(0xFF10B981), label: 'A'),
          ],
          metrics: {
            'Active': '18',
            'Maintenance': '3',
            'Offline': '2',
          },
          summaryLine: 'Zones: East(12) West(8) Central(4)',
          actionLabels: ['Manage Fleet', 'Service Schedule'],
        ),
        DashboardCard(
          id: 'tabs',
          title: 'Customer Tabs',
          icon: Icons.receipt_long,
          route: '/setup/tabs',
          subtitle: '₵312,450 total credit',
          progress: 0.75,
          progressLabel: 'Credit Utilization: 75%',
          metrics: {
            'Active': '312',
            'Overdue': '24',
            'Limit': '₵500K',
          },
          summaryLine: 'Next repayment: Jan 15 (5 days)',
          actionLabels: ['View All Tabs', 'Send Reminders'],
          highlightColor: const Color(0xFFF59E0B),
        ),
        // Row 2: Finance & Staff
        DashboardCard(
          id: 'discounts',
          title: 'Discount Tiers',
          icon: Icons.local_offer,
          route: '/setup/discounts',
          subtitle: '3 active · Revenue Impact +12%',
          metrics: {
            'Active': '3',
            'Paused': '1',
            'Draft': '2',
          },
          summaryLine: 'Tier 1: ₵100→5% | Tier 2: ₵250→10%',
          actionLabels: ['Manage Discounts', 'Create New'],
          highlightColor: const Color(0xFF10B981),
        ),
        DashboardCard(
          id: 'staff',
          title: 'Staff',
          icon: Icons.people,
          route: '/setup/staff',
          alertCount: 3,
          subtitle: '42 total · 28 online',
          statusDots: const [
            StatusDot(color: Color(0xFF10B981), label: 'On'),
            StatusDot(color: Color(0xFFF59E0B), label: 'Id'),
            StatusDot(color: Color(0xFFEF4444), label: 'Of'),
            StatusDot(color: Color(0xFF10B981), label: 'On'),
            StatusDot(color: Color(0xFF10B981), label: 'On'),
          ],
          metrics: {
            'Online': '28',
            'Offline': '8',
            'Idle': '6',
          },
          summaryLine: 'Pending Approvals: 3',
          actionLabels: ['View Staff', 'Approve (3)'],
        ),
        DashboardCard(
          id: 'activity_log',
          title: 'Activity Log',
          icon: Icons.history,
          route: '/setup/audit',
          subtitle: 'Live · 42 actions today',
          metrics: {
            'Today': '42 actions',
            'Failures': '3',
            'Last': '2 min ago',
          },
          actionLabels: ['View Full Log', 'Export Today'],
        ),
        // Row 3: Logistics
        DashboardCard(
          id: 'places',
          title: 'Places',
          icon: Icons.place,
          route: '/setup/places',
          subtitle: '128 locations',
          metrics: {
            'Public': '98',
            'Private': '30',
            'New': '12 this week',
          },
          actionLabels: ['View Places', 'Add New Place'],
        ),
        DashboardCard(
          id: 'delivery_zones',
          title: 'Delivery Zones',
          icon: Icons.map,
          route: '/setup/zones',
          subtitle: '8 active zones',
          progress: 0.85,
          progressLabel: 'Coverage: 85% of target',
          metrics: {
            'Active': '8',
            'Inactive': '2',
            'Avg Time': '45 min',
          },
          actionLabels: ['Manage Zones', 'Optimize Routes'],
        ),
        DashboardCard(
          id: 'vehicle_bands',
          title: 'Vehicle Bands',
          icon: Icons.category,
          route: '/setup/bands',
          subtitle: '3 bands · 18/24 assigned',
          metrics: {
            'Band A': '85%',
            'Band B': '42%',
            'Band C': '23%',
          },
          summaryLine: 'Optimal: 70-85% · Alert: >90%',
          actionLabels: ['Manage Bands', 'Reassign Vehicles'],
        ),
        DashboardCard(
          id: 'branches',
          title: 'Branches',
          icon: Icons.business,
          route: '/setup/branches',
          subtitle: '12 total · 9 online',
          statusDots: const [
            StatusDot(color: Color(0xFF10B981), label: 'On'),
            StatusDot(color: Color(0xFF10B981), label: 'On'),
            StatusDot(color: Color(0xFFEF4444), label: 'Of'),
            StatusDot(color: Color(0xFF10B981), label: 'On'),
          ],
          metrics: {
            'Online': '9',
            'Offline': '3',
            'Avg Rating': '4.7 ⭐',
          },
          summaryLine: 'Staff: 142 · Vehicles: 48',
          actionLabels: ['View All Branches', 'Add Branch'],
        ),
        // Row 4: Engagement
        DashboardCard(
          id: 'marketing',
          title: 'Marketing',
          icon: Icons.campaign,
          route: '/setup/campaigns',
          subtitle: '5 active campaigns',
          progress: 0.50,
          progressLabel: 'Budget: ₵5,000/₵10K',
          metrics: {
            'ROI': '142%',
            'Reach': '45,000',
            'Conv': '1,234',
          },
          actionLabels: ['View Campaigns', 'Create New'],
          highlightColor: const Color(0xFF8B5CF6),
        ),
        DashboardCard(
          id: 'social',
          title: 'Social & Updates',
          icon: Icons.forum,
          route: '/setup/social',
          subtitle: 'Engagement Rate: 4.2% ↑ 12%',
          metrics: {
            'Followers': '2,345',
            'Posts/week': '8',
            'Scheduled': '3',
          },
          summaryLine: '+124 followers this week',
          actionLabels: ['View Feed', 'Create Post'],
        ),
        DashboardCard(
          id: 'connections',
          title: 'Connections',
          icon: Icons.handshake,
          route: '/setup/connections',
          subtitle: '342 total · Strength 85%',
          statusDots: const [
            StatusDot(color: Color(0xFF10B981), label: 'A'),
            StatusDot(color: Color(0xFFF59E0B), label: 'P'),
            StatusDot(color: Color(0xFF10B981), label: 'A'),
          ],
          metrics: {
            'Active': '324',
            'Pending': '12',
            'Blocked': '6',
          },
          actionLabels: ['Manage Network', 'Import Contacts'],
        ),
        // Row 5: Branch Identity
        DashboardCard(
          id: 'profile',
          title: 'Branch Profile',
          icon: Icons.badge,
          route: '/setup/profile',
          subtitle: '✅ Verified · ⭐ 4.8 (428)',
          metrics: {
            'Response Rate': '98%',
            'Avg Time': '12 min',
            'Reviews': '428',
          },
          summaryLine: 'Member since Jan 2022',
          actionLabels: ['Edit Profile', 'View Analytics'],
          highlightColor: const Color(0xFF10B981),
        ),
        DashboardCard(
          id: 'outlook',
          title: 'Outlook & Analytics',
          icon: Icons.insights,
          route: '/setup/outlook',
          subtitle: 'Customer Satisfaction: 92%',
          progress: 0.92,
          progressLabel: 'Overall Health',
          metrics: {
            'Revenue': '₵245K',
            'Growth': '+12%',
            'Customers': '2,450',
          },
          actionLabels: ['View Analytics', 'Respond to Feedback'],
          highlightColor: const Color(0xFF10B981),
        ),
        DashboardCard(
          id: 'subscription',
          title: 'Subscription',
          icon: Icons.diamond,
          route: '/setup/subscription',
          subtitle: '💎 Premium · Auto-renew ON',
          progress: 0.75,
          progressLabel: 'Usage: 75% of allocation',
          metrics: {
            'Q-Points': '15,240',
            'Monthly': '₵500',
            'Renews': '15 days',
          },
          actionLabels: ['Manage Plan', 'Add Q-Points'],
          highlightColor: const Color(0xFF8B5CF6),
        ),
        // Row 6: Personal & History
        DashboardCard(
          id: 'interests',
          title: 'Interests',
          icon: Icons.interests,
          route: '/setup/interests',
          subtitle: 'Following 24 categories',
          metrics: {
            'Following': '24',
            'Updates': '45/day',
            'Score': '78/100',
          },
          actionLabels: ['Manage Interests', 'Discover More'],
        ),
        DashboardCard(
          id: 'qpoints',
          title: 'Q-Points History',
          icon: Icons.monetization_on,
          route: '/setup/qpoints',
          subtitle: 'Balance: 15,240 QP ≈ ₵1,295',
          metrics: {
            'Today': '+320 / -150',
            'Rate': '1 QP = 0.085',
            'Expiring': '450 (3 days)',
          },
          summaryLine: 'This month: +2,450 earned',
          actionLabels: ['View History', 'Transfer'],
          highlightColor: const Color(0xFFFFD700),
        ),
        DashboardCard(
          id: 'my_activity',
          title: 'My Activity',
          icon: Icons.task_alt,
          route: '/setup/my-activity',
          subtitle: 'Efficiency: 85% · Streak: 12 days',
          progress: 0.43,
          progressLabel: 'Progress: 3/7 (43%)',
          metrics: {
            'Pending': '4 tasks',
            'Completed': '3 today',
            'Hours': '32/40',
          },
          actionLabels: ['View All Tasks', 'Set Goals'],
        ),
      ];

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 2: PRODUCTS STATE
  // ═══════════════════════════════════════════════════════════════════════════

  String _productSearchQuery = '';
  String get productSearchQuery => _productSearchQuery;
  void setProductSearch(String q) {
    _productSearchQuery = q;
    notifyListeners();
  }

  bool _isGridView = true;
  bool get isGridView => _isGridView;
  void toggleProductView() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  List<Product> get products =>
      _products.isNotEmpty ? _products : _fallbackProducts;
  List<Product> get filteredProducts {
    final source = products;
    if (_productSearchQuery.isEmpty) return source;
    final q = _productSearchQuery.toLowerCase();
    return source
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.sku.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q))
        .toList();
  }

  int get lowStockCount => products.where((p) => p.isLowStock).length;
  int get outOfStockCount => products.where((p) => p.isOutOfStock).length;

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 3: VEHICLES STATE
  // ═══════════════════════════════════════════════════════════════════════════

  List<Vehicle> get vehicles =>
      _vehicles.isNotEmpty ? _vehicles : _fallbackVehicles;
  int get activeVehicleCount =>
      vehicles.where((v) => v.status == VehicleStatus.active).length;
  int get maintenanceVehicleCount =>
      vehicles.where((v) => v.status == VehicleStatus.maintenance).length;

  List<MaintenanceRecord> get maintenanceRecords =>
      _maintenanceRecords.isNotEmpty
          ? _maintenanceRecords
          : _fallbackMaintenanceRecords;
  List<FuelEntry> get fuelEntries =>
      _fuelEntries.isNotEmpty ? _fuelEntries : _fallbackFuelEntries;

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 4: TABS STATE
  // ═══════════════════════════════════════════════════════════════════════════

  List<CustomerTab> get tabs =>
      _tabs.isNotEmpty ? _tabs : _fallbackTabs;
  double get totalCredit => tabs.fold(0, (sum, t) => sum + t.amountUsed);
  int get overdueTabCount => tabs.where((t) => t.isOverdue).length;
  List<TabTransaction> get tabTransactions =>
      _tabTransactions.isNotEmpty
          ? _tabTransactions
          : _fallbackTabTransactions;

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 5: DISCOUNTS STATE
  // ═══════════════════════════════════════════════════════════════════════════

  List<DiscountTier> get discounts =>
      _discounts.isNotEmpty ? _discounts : _fallbackDiscounts;
  int get activeDiscountCount =>
      discounts.where((d) => d.status == DiscountStatus.active).length;

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 6: STAFF STATE
  // ═══════════════════════════════════════════════════════════════════════════

  List<StaffMember> get staffMembers =>
      _staff.isNotEmpty ? _staff : _fallbackStaff;
  int get onlineStaffCount =>
      staffMembers.where((s) => s.status == StaffStatus.online).length;

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 7: PLACES STATE
  // ═══════════════════════════════════════════════════════════════════════════

  List<Place> get places =>
      _places.isNotEmpty ? _places : _fallbackPlaces;

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 8: DELIVERY ZONES STATE
  // ═══════════════════════════════════════════════════════════════════════════

  List<DeliveryZone> get zones =>
      _zones.isNotEmpty ? _zones : _fallbackZones;

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 9: VEHICLE BANDS STATE
  // ═══════════════════════════════════════════════════════════════════════════

  List<VehicleBand> get bands =>
      _bands.isNotEmpty ? _bands : _fallbackBands;

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 10: BRANCHES STATE
  // ═══════════════════════════════════════════════════════════════════════════

  List<Branch> get branches =>
      _branches.isNotEmpty ? _branches : _fallbackBranches;

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 11: CAMPAIGNS STATE
  // ═══════════════════════════════════════════════════════════════════════════

  List<Campaign> get campaigns =>
      _campaigns.isNotEmpty ? _campaigns : _fallbackCampaigns;

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 12: SOCIAL STATE
  // ═══════════════════════════════════════════════════════════════════════════

  List<SocialPost> get posts =>
      _posts.isNotEmpty ? _posts : _fallbackPosts;

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 13: CONNECTIONS STATE
  // ═══════════════════════════════════════════════════════════════════════════

  List<Connection> get connections =>
      _connections.isNotEmpty ? _connections : _fallbackConnections;
  int get activeConnectionCount =>
      connections.where((c) => c.status == ConnectionStatus.active).length;

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 14: AUDIT LOG STATE
  // ═══════════════════════════════════════════════════════════════════════════

  List<AuditEntry> get auditEntries =>
      _auditEntries.isNotEmpty ? _auditEntries : _fallbackAuditEntries;
  String _auditFilter = 'all';
  String get auditFilter => _auditFilter;
  void setAuditFilter(String f) {
    _auditFilter = f;
    notifyListeners();
  }

  List<AuditEntry> get filteredAuditEntries {
    final source = auditEntries;
    if (_auditFilter == 'all') return source;
    return source.where((e) => e.outcome.name == _auditFilter).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 15: OUTLOOK STATE
  // ═══════════════════════════════════════════════════════════════════════════

  List<KPIMetric> get kpiMetrics =>
      _kpiMetrics.isNotEmpty ? _kpiMetrics : _fallbackKPIs;
  List<AIInsight> get aiInsights =>
      _aiInsights.isNotEmpty ? _aiInsights : _fallbackInsights;

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 16: Q-POINTS STATE
  // ═══════════════════════════════════════════════════════════════════════════

  QPointsBalance get qPointsBalance => const QPointsBalance(
        available: 15240,
        lifetime: 45890,
        redeemed: 12450,
        pending: 320,
        tier: 'Gold Member',
        expiringPoints: 450,
        daysToExpiry: 15,
        earnedThisMonth: 2450,
        spentThisMonth: 1890,
        expiringAmount: 450,
      );

  List<QPointsTransaction> get qPointsTransactions =>
      _qPointsTransactions.isNotEmpty
          ? _qPointsTransactions
          : _fallbackQPointsTransactions;

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 17: MY ACTIVITY STATE
  // ═══════════════════════════════════════════════════════════════════════════

  List<UserTask> get tasks =>
      _tasks.isNotEmpty ? _tasks : _fallbackTasks;
  List<UserGoal> get goals =>
      _goals.isNotEmpty ? _goals : _fallbackGoals;
  List<ActivityTimelineEntry> get todayTimeline =>
      _timeline.isNotEmpty ? _timeline : _fallbackTimeline;
  List<ActivityTimelineEntry> get timeline =>
      _timeline.isNotEmpty ? _timeline : _fallbackTimeline;

  int get completedTaskCount =>
      tasks.where((t) => t.status == TaskStatus.completed).length;
  int get totalTaskCount => tasks.length;

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 18: PROFILE STATE
  // ═══════════════════════════════════════════════════════════════════════════

  UserProfile get userProfile =>
      _userProfile ??
      UserProfile(
        id: 'usr_001',
        firstName: 'John',
        lastName: 'Doe',
        displayName: 'John Doe',
        title: 'Administrator',
        company: 'Wizdom Shop',
        department: 'Operations',
        bio:
            'Experienced operations manager with 8+ years in retail and logistics.',
        email: 'john@wizdomshop.com',
        phone: '+233 24 123 4567',
        address: '123 Main Street',
        city: 'Accra',
        country: 'Ghana',
        profileCompleteness: 85.0,
        rating: 4.8,
        reviewCount: 45,
        memberSince: _memberSince,
        skills: [
          'Operations Management',
          'Team Leadership',
          'Inventory Management',
          'Customer Service'
        ],
        socialLinks: {
          'LinkedIn': 'linkedin.com/in/johndoe',
          'Twitter': 'twitter.com/johndoe'
        },
        isVerified: true,
        connectionCount: 28,
      );

  static final DateTime _memberSince = DateTime(2022, 1, 15);

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 19: SUBSCRIPTION STATE
  // ═══════════════════════════════════════════════════════════════════════════

  SubscriptionInfo get subscription =>
      _subscriptionInfo ??
      SubscriptionInfo(
        plan: SubscriptionPlan.basic,
        monthlyPrice: 0,
        renewalDate: DateTime.now().add(const Duration(days: 30)),
        staffLimit: 50,
        staffUsed: 12,
        storageGB: 100,
        storageUsedGB: 45.8,
        apiCallLimit: 50000,
        apiCallsUsed: 12450,
        utilizationPercent: 75.0,
        staffCount: 12,
        pricePerStaffQPoints: 4,
        isInFreeTrial: true,
        freeTrialEndsAt: DateTime.now().add(const Duration(days: 30)),
        includesSocialFeatures: false,
        includesMarketingTools: false,
        txCountThisMonth: 0,
        txFreeQuota: 100,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 20: INTERESTS STATE
  // ═══════════════════════════════════════════════════════════════════════════

  List<UserInterest> get interests =>
      _interests.isNotEmpty ? _interests : _fallbackInterests;
  List<InterestRecommendation> get recommendations =>
      _recommendations.isNotEmpty
          ? _recommendations
          : _fallbackRecommendations;

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 21: LOADING / ERROR STATES
  // ═══════════════════════════════════════════════════════════════════════════

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final Map<String, CardState> _sectionStates = {};
  CardState getSectionState(String sectionId) =>
      _sectionStates[sectionId] ?? CardState.loaded;

  void setSectionState(String sectionId, CardState state) {
    _sectionStates[sectionId] = state;
    notifyListeners();
  }

  Future<void> refreshSection(String sectionId) async {
    _sectionStates[sectionId] = CardState.loading;
    notifyListeners();

    try {
      switch (sectionId) {
        case 'products':
          await loadProducts();
          return;
        case 'vehicles':
          await loadVehicles();
          return;
        case 'vehicle_bands':
          await loadVehicleBands();
          return;
        case 'places':
          await loadPlaces();
          return;
        case 'social':
          await loadPosts();
          return;
        case 'connections':
          await loadConnections();
          return;
        case 'qpoints':
          await loadQPointsTransactions();
          return;
        case 'interests':
          await loadInterests();
          return;
        case 'subscription':
          await loadSubscription();
          return;
        case 'profile':
          await loadProfile();
          return;
        default:
          // Sections without a backend endpoint — simulate refresh
          await Future.delayed(const Duration(milliseconds: 800));
          _sectionStates[sectionId] = CardState.loaded;
          notifyListeners();
      }
    } catch (_) {
      _sectionStates[sectionId] = CardState.error;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 22: SELECTED ITEM TRACKING (for detail views)
  // ═══════════════════════════════════════════════════════════════════════════

  String? _selectedProductId;
  String? get selectedProductId => _selectedProductId;
  Product? get selectedProduct => _selectedProductId == null
      ? null
      : products.cast<Product?>().firstWhere(
            (p) => p?.id == _selectedProductId,
            orElse: () => null,
          );
  void selectProduct(String? id) {
    _selectedProductId = id;
    notifyListeners();
  }

  String? _selectedVehicleId;
  String? get selectedVehicleId => _selectedVehicleId;
  Vehicle? get selectedVehicle => _selectedVehicleId == null
      ? null
      : vehicles.cast<Vehicle?>().firstWhere(
            (v) => v?.id == _selectedVehicleId,
            orElse: () => null,
          );
  void selectVehicle(String? id) {
    _selectedVehicleId = id;
    notifyListeners();
  }

  String? _selectedTabId;
  String? get selectedTabId => _selectedTabId;
  CustomerTab? get selectedTab => _selectedTabId == null
      ? null
      : tabs.cast<CustomerTab?>().firstWhere(
            (t) => t?.id == _selectedTabId,
            orElse: () => null,
          );
  void selectTab(String? id) {
    _selectedTabId = id;
    notifyListeners();
  }

  String? _selectedStaffId;
  String? get selectedStaffId => _selectedStaffId;
  StaffMember? get selectedStaff => _selectedStaffId == null
      ? null
      : staffMembers.cast<StaffMember?>().firstWhere(
            (s) => s?.id == _selectedStaffId,
            orElse: () => null,
          );
  void selectStaff(String? id) {
    _selectedStaffId = id;
    notifyListeners();
  }

  String? _selectedBranchId;
  String? get selectedBranchId => _selectedBranchId;
  Branch? get selectedBranch => _selectedBranchId == null
      ? null
      : branches.cast<Branch?>().firstWhere(
            (b) => b?.id == _selectedBranchId,
            orElse: () => null,
          );
  void selectBranch(String? id) {
    _selectedBranchId = id;
    notifyListeners();
  }

  String? _selectedCampaignId;
  String? get selectedCampaignId => _selectedCampaignId;
  Campaign? get selectedCampaign => _selectedCampaignId == null
      ? null
      : campaigns.cast<Campaign?>().firstWhere(
            (c) => c?.id == _selectedCampaignId,
            orElse: () => null,
          );
  void selectCampaign(String? id) {
    _selectedCampaignId = id;
    notifyListeners();
  }

  String? _selectedPlaceId;
  String? get selectedPlaceId => _selectedPlaceId;
  Place? get selectedPlace => _selectedPlaceId == null
      ? null
      : places.cast<Place?>().firstWhere(
            (p) => p?.id == _selectedPlaceId,
            orElse: () => null,
          );
  void selectPlace(String? id) {
    _selectedPlaceId = id;
    notifyListeners();
  }

  String? _selectedZoneId;
  String? get selectedZoneId => _selectedZoneId;
  DeliveryZone? get selectedZone => _selectedZoneId == null
      ? null
      : zones.cast<DeliveryZone?>().firstWhere(
            (z) => z?.id == _selectedZoneId,
            orElse: () => null,
          );
  void selectZone(String? id) {
    _selectedZoneId = id;
    notifyListeners();
  }

  String? _selectedDiscountId;
  String? get selectedDiscountId => _selectedDiscountId;
  DiscountTier? get selectedDiscount => _selectedDiscountId == null
      ? null
      : discounts.cast<DiscountTier?>().firstWhere(
            (d) => d?.id == _selectedDiscountId,
            orElse: () => null,
          );
  void selectDiscount(String? id) {
    _selectedDiscountId = id;
    notifyListeners();
  }

  String? _selectedConnectionId;
  String? get selectedConnectionId => _selectedConnectionId;
  Connection? get selectedConnection => _selectedConnectionId == null
      ? null
      : connections.cast<Connection?>().firstWhere(
            (c) => c?.id == _selectedConnectionId,
            orElse: () => null,
          );
  void selectConnection(String? id) {
    _selectedConnectionId = id;
    notifyListeners();
  }

  String? _selectedPostId;
  String? get selectedPostId => _selectedPostId;
  SocialPost? get selectedPost => _selectedPostId == null
      ? null
      : posts.cast<SocialPost?>().firstWhere(
            (p) => p?.id == _selectedPostId,
            orElse: () => null,
          );
  void selectPost(String? id) {
    _selectedPostId = id;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 23: SEARCH / FILTER FOR ALL SECTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  String _vehicleSearchQuery = '';
  String get vehicleSearchQuery => _vehicleSearchQuery;
  void setVehicleSearch(String q) {
    _vehicleSearchQuery = q;
    notifyListeners();
  }

  List<Vehicle> get filteredVehicles {
    final source = vehicles;
    if (_vehicleSearchQuery.isEmpty) return source;
    final q = _vehicleSearchQuery.toLowerCase();
    return source
        .where((v) =>
            v.plateNumber.toLowerCase().contains(q) ||
            v.make.toLowerCase().contains(q) ||
            v.model.toLowerCase().contains(q) ||
            (v.assignedDriverName?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  String _staffSearchQuery = '';
  String get staffSearchQuery => _staffSearchQuery;
  void setStaffSearch(String q) {
    _staffSearchQuery = q;
    notifyListeners();
  }

  List<StaffMember> get filteredStaff {
    final source = staffMembers;
    if (_staffSearchQuery.isEmpty) return source;
    final q = _staffSearchQuery.toLowerCase();
    return source
        .where((s) =>
            s.name.toLowerCase().contains(q) ||
            s.role.toLowerCase().contains(q) ||
            s.department.toLowerCase().contains(q))
        .toList();
  }

  String _tabSearchQuery = '';
  String get tabSearchQuery => _tabSearchQuery;
  void setTabSearch(String q) {
    _tabSearchQuery = q;
    notifyListeners();
  }

  List<CustomerTab> get filteredTabs {
    final source = tabs;
    if (_tabSearchQuery.isEmpty) return source;
    final q = _tabSearchQuery.toLowerCase();
    return source
        .where((t) =>
            t.customerName.toLowerCase().contains(q) ||
            t.tabNumber.toLowerCase().contains(q))
        .toList();
  }

  String _connectionSearchQuery = '';
  String get connectionSearchQuery => _connectionSearchQuery;
  void setConnectionSearch(String q) {
    _connectionSearchQuery = q;
    notifyListeners();
  }

  List<Connection> get filteredConnections {
    final source = connections;
    if (_connectionSearchQuery.isEmpty) return source;
    final q = _connectionSearchQuery.toLowerCase();
    return source
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            (c.category?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  String _campaignSearchQuery = '';
  String get campaignSearchQuery => _campaignSearchQuery;
  void setCampaignSearch(String q) {
    _campaignSearchQuery = q;
    notifyListeners();
  }

  List<Campaign> get filteredCampaigns {
    final source = campaigns;
    if (_campaignSearchQuery.isEmpty) return source;
    final q = _campaignSearchQuery.toLowerCase();
    return source.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  String _branchSearchQuery = '';
  String get branchSearchQuery => _branchSearchQuery;
  void setBranchSearch(String q) {
    _branchSearchQuery = q;
    notifyListeners();
  }

  List<Branch> get filteredBranches {
    final source = branches;
    if (_branchSearchQuery.isEmpty) return source;
    final q = _branchSearchQuery.toLowerCase();
    return source
        .where((b) =>
            b.name.toLowerCase().contains(q) ||
            (b.managerName?.toLowerCase().contains(q) ?? false) ||
            (b.area?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 24: CRUD OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  // Products — wired to real API
  Future<void> addProduct(Product product) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _productService.createProduct({
        'name': product.name,
        'sku': product.sku,
        'category': product.category,
        if (product.brand != null) 'brand': product.brand,
        if (product.description != null) 'description': product.description,
        'basePrice': product.basePrice,
        'currentPrice': product.currentPrice,
        'stock': product.stock,
        'lowStockThreshold': product.lowStockThreshold,
        'tags': product.tags,
      });
      await loadProducts();
    } catch (_) {
      _errorMessage = 'Failed to add product';
      // Fallback: add locally
      _products = List.from(products)..add(product);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProduct(String id, Product updated) async {
    try {
      await _productService.updateProduct(id, {
        'name': updated.name,
        'sku': updated.sku,
        'category': updated.category,
        if (updated.brand != null) 'brand': updated.brand,
        if (updated.description != null) 'description': updated.description,
        'basePrice': updated.basePrice,
        'currentPrice': updated.currentPrice,
        'stock': updated.stock,
        'lowStockThreshold': updated.lowStockThreshold,
        'tags': updated.tags,
      });
      final list = List<Product>.from(products);
      final index = list.indexWhere((p) => p.id == id);
      if (index != -1) {
        list[index] = updated;
        _products = list;
      }
    } catch (_) {
      _errorMessage = 'Failed to update product';
      // Fallback: update locally
      final list = List<Product>.from(products);
      final index = list.indexWhere((p) => p.id == id);
      if (index != -1) {
        list[index] = updated;
        _products = list;
      }
    }
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _productService.deleteProduct(id);
      _products = List.from(products)..removeWhere((p) => p.id == id);
    } catch (_) {
      _errorMessage = 'Failed to delete product';
      // Fallback: remove locally
      _products = List.from(products)..removeWhere((p) => p.id == id);
    }
    if (_selectedProductId == id) _selectedProductId = null;
    notifyListeners();
  }

  // Staff — local fallback (no staff endpoint)
  Future<void> addStaffMember(StaffMember staff) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _staff = List.from(staffMembers)..add(staff);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteStaffMember(String id) async {
    _staff = List.from(staffMembers)..removeWhere((s) => s.id == id);
    if (_selectedStaffId == id) _selectedStaffId = null;
    notifyListeners();
  }

  // Campaigns — local fallback (no campaign endpoint)
  Future<void> addCampaign(Campaign campaign) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _campaigns = List.from(campaigns)..add(campaign);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteCampaign(String id) async {
    _campaigns = List.from(campaigns)..removeWhere((c) => c.id == id);
    if (_selectedCampaignId == id) _selectedCampaignId = null;
    notifyListeners();
  }

  // Tasks — local fallback (no task endpoint)
  Future<void> addTask(UserTask task) async {
    _tasks = List.from(tasks)..add(task);
    notifyListeners();
  }

  Future<void> updateTaskStatus(String id, TaskStatus status) async {
    final source = List<UserTask>.from(tasks);
    final index = source.indexWhere((t) => t.id == id);
    if (index != -1) {
      final t = source[index];
      source[index] = UserTask(
        id: t.id,
        title: t.title,
        description: t.description,
        status: status,
        dueDate: t.dueDate,
        tags: t.tags,
        progress: status == TaskStatus.completed ? 1.0 : t.progress,
        assignee: t.assignee,
        priority: t.priority,
        checklist: t.checklist,
        completedAt: status == TaskStatus.completed ? DateTime.now() : null,
      );
      _tasks = source;
      notifyListeners();
    }
  }

  // Branches — local fallback
  Future<void> addBranch(Branch branch) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _branches = List.from(branches)..add(branch);
    _isLoading = false;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 25: BRANCH-SCOPE FILTERING
  // ═══════════════════════════════════════════════════════════════════════════

  String? _activeBranchFilter;
  String? get activeBranchFilter => _activeBranchFilter;
  void setBranchFilter(String? branchName) {
    _activeBranchFilter = branchName;
    notifyListeners();
  }

  List<StaffMember> get branchScopedStaff {
    if (_activeBranchFilter == null) return filteredStaff;
    return filteredStaff
        .where((s) => s.branch == _activeBranchFilter)
        .toList();
  }

  List<Vehicle> get branchScopedVehicles {
    if (_activeBranchFilter == null) return filteredVehicles;
    return filteredVehicles
        .where((v) => v.zone == _activeBranchFilter)
        .toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 26: UTILITY GETTERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// KPI: Total revenue across all branches
  double get totalRevenue =>
      branches.fold(0, (sum, b) => sum + b.monthlyRevenue);

  /// KPI: Average branch rating
  double get averageBranchRating {
    if (branches.isEmpty) return 0;
    return branches.fold(0.0, (sum, b) => sum + b.rating) / branches.length;
  }

  /// KPI: Total staff count
  int get totalStaffCount => staffMembers.length;

  /// KPI: Online branches
  int get onlineBranchCount =>
      branches.where((b) => b.status == BranchStatus.online).length;

  /// Get maintenance records for a specific vehicle
  List<MaintenanceRecord> getMaintenanceForVehicle(String vehicleId) =>
      maintenanceRecords.where((m) => m.vehicleId == vehicleId).toList();

  /// Get fuel entries for a specific vehicle
  List<FuelEntry> getFuelForVehicle(String vehicleId) =>
      fuelEntries.where((f) => f.vehicleId == vehicleId).toList();

  /// Get transactions for a specific tab
  List<TabTransaction> getTransactionsForTab(String tabId) =>
      tabTransactions.where((t) => t.tabId == tabId).toList();

  /// Get staff by branch
  List<StaffMember> getStaffByBranch(String branch) =>
      staffMembers.where((s) => s.branch == branch).toList();

  @override
  void dispose() {
    _sectionStates.clear();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // JSON PARSING HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  Product _productFromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      category: json['category'] as String? ?? '',
      brand: json['brand'] as String?,
      description: json['description'] as String?,
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0,
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 10,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      stockLevel: _parseStockLevel(json['stockLevel'] as String?),
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      lastSold: json['lastSold'] != null
          ? DateTime.tryParse(json['lastSold'].toString())
          : null,
      soldToday: (json['soldToday'] as num?)?.toInt() ?? 0,
    );
  }

  Vehicle _vehicleFromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String? ?? '',
      plateNumber: json['plateNumber'] as String? ?? '',
      make: json['make'] as String? ?? '',
      model: json['model'] as String? ?? '',
      year: (json['year'] as num?)?.toInt() ?? 0,
      status: _parseVehicleStatus(json['status'] as String?),
      assignedDriverId: json['assignedDriverId'] as String?,
      assignedDriverName: json['assignedDriverName'] as String?,
      zone: json['zone'] as String?,
      fuelLevel: (json['fuelLevel'] as num?)?.toDouble() ?? 0,
      distanceToday: (json['distanceToday'] as num?)?.toDouble() ?? 0,
      deliveriesToday: (json['deliveriesToday'] as num?)?.toInt() ?? 0,
      deliveriesTarget: (json['deliveriesTarget'] as num?)?.toInt() ?? 0,
      onTimeRate: (json['onTimeRate'] as num?)?.toDouble() ?? 0,
      capacityKg: (json['capacityKg'] as num?)?.toInt() ?? 0,
      lastMaintenance: json['lastMaintenance'] != null
          ? DateTime.tryParse(json['lastMaintenance'].toString())
          : null,
      nextServiceKm: (json['nextServiceKm'] as num?)?.toDouble(),
    );
  }

  VehicleBand _vehicleBandFromJson(Map<String, dynamic> json) {
    return VehicleBand(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      purpose: json['purpose'] as String? ?? '',
      vehicleCount: (json['vehicleCount'] as num?)?.toInt() ?? 0,
      utilization: (json['utilization'] as num?)?.toDouble() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      vehicleIds: (json['vehicleIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      maxCapacity: (json['maxCapacity'] as num?)?.toInt() ?? 12,
      maintenanceCostMonthly:
          (json['maintenanceCostMonthly'] as num?)?.toDouble() ?? 0,
    );
  }

  Place _placeFromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: _parsePlaceType(json['type'] as String?),
      visibility: _parsePlaceVisibility(json['visibility'] as String?),
      address: json['address'] as String?,
      area: json['area'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      staffCount: (json['staffCount'] as num?)?.toInt() ?? 0,
      productCount: (json['productCount'] as num?)?.toInt() ?? 0,
      hoursDisplay: json['hoursDisplay'] as String?,
    );
  }

  SocialPost _socialPostFromJson(Map<String, dynamic> json) {
    return SocialPost(
      id: json['id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      status: _parsePostStatus(json['status'] as String?),
      platforms: (json['platforms'] as List<dynamic>?)
              ?.map((e) => _parseSocialPlatform(e.toString()))
              .toList() ??
          [],
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
      shares: (json['shares'] as num?)?.toInt() ?? 0,
      reach: (json['reach'] as num?)?.toInt() ?? 0,
      engagementRate: (json['engagementRate'] as num?)?.toDouble() ?? 0,
      publishDate: json['publishDate'] != null
          ? DateTime.tryParse(json['publishDate'].toString())
          : null,
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.tryParse(json['scheduledDate'].toString())
          : null,
      hasMedia: json['hasMedia'] as bool? ?? false,
      mediaType: json['mediaType'] as String?,
    );
  }

  Connection _connectionFromJson(Map<String, dynamic> json) {
    return Connection(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: _parseConnectionType(json['type'] as String?),
      status: _parseConnectionStatus(json['status'] as String?),
      category: json['category'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      strengthPercent: (json['strengthPercent'] as num?)?.toDouble() ?? 0,
      connectedSince: json['connectedSince'] != null
          ? DateTime.tryParse(json['connectedSince'].toString())
          : null,
      lastInteraction: json['lastInteraction'] as String?,
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      totalValue: (json['totalValue'] as num?)?.toDouble() ?? 0,
    );
  }

  QPointsTransaction _qPointsTransactionFromJson(Map<String, dynamic> json) {
    return QPointsTransaction(
      id: json['id'] as String? ?? '',
      type: _parseQPointsTransactionType(json['type'] as String?),
      status: _parseQPointsTransactionStatus(json['status'] as String?),
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      description: json['description'] as String? ?? '',
      relatedId: json['relatedId'] as String?,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      source: json['source'] as String?,
    );
  }

  UserInterest _userInterestFromJson(Map<String, dynamic> json) {
    return UserInterest(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '📌',
      updateCount: (json['updateCount'] as num?)?.toInt() ?? 0,
      isFollowing: json['isFollowing'] as bool? ?? true,
      category: json['category'] as String?,
    );
  }

  SubscriptionInfo _subscriptionInfoFromJson(Map<String, dynamic> json) {
    return SubscriptionInfo(
      plan: _parseSubscriptionPlan(json['plan'] as String?),
      monthlyPrice: (json['monthlyPrice'] as num?)?.toDouble() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      renewalDate: json['renewalDate'] != null
          ? DateTime.tryParse(json['renewalDate'].toString())
          : null,
      autoRenew: json['autoRenew'] as bool? ?? true,
      staffLimit: (json['staffLimit'] as num?)?.toInt() ?? 50,
      staffUsed: (json['staffUsed'] as num?)?.toInt() ?? 0,
      storageGB: (json['storageGB'] as num?)?.toDouble() ?? 100,
      storageUsedGB: (json['storageUsedGB'] as num?)?.toDouble() ?? 0,
      apiCallLimit: (json['apiCallLimit'] as num?)?.toInt() ?? 50000,
      apiCallsUsed: (json['apiCallsUsed'] as num?)?.toInt() ?? 0,
      utilizationPercent:
          (json['utilizationPercent'] as num?)?.toDouble() ?? 0,
      staffCount: (json['staffCount'] as num?)?.toInt() ?? 1,
      pricePerStaffQPoints: (json['pricePerStaffQPoints'] as num?)?.toDouble() ?? 0,
      isInFreeTrial: json['isInFreeTrial'] as bool? ?? false,
      freeTrialEndsAt: json['freeTrialEndsAt'] != null
          ? DateTime.tryParse(json['freeTrialEndsAt'].toString())
          : null,
      includesSocialFeatures: json['includesSocialFeatures'] as bool? ?? false,
      includesMarketingTools: json['includesMarketingTools'] as bool? ?? false,
      txCountThisMonth: (json['monthlyTransactionCount'] as num?)?.toInt() ?? 0,
      txFreeQuota: (json['freeTransactionQuota'] as num?)?.toInt() ?? 100,
    );
  }

  UserProfile _userProfileFromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      displayName: json['displayName'] as String? ??
          '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim(),
      title: json['title'] as String? ?? '',
      company: json['company'] as String? ?? '',
      department: json['department'] as String? ?? '',
      bio: json['bio'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      profileCompleteness:
          (json['profileCompleteness'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      memberSince: json['memberSince'] != null
          ? DateTime.tryParse(json['memberSince'].toString()) ??
              DateTime(2022, 1, 15)
          : DateTime(2022, 1, 15),
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      socialLinks: (json['socialLinks'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ??
          {},
      isVerified: json['isVerified'] as bool? ?? false,
      connectionCount: (json['connectionCount'] as num?)?.toInt() ?? 0,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ENUM PARSER HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  StockLevel _parseStockLevel(String? s) {
    switch (s?.toLowerCase()) {
      case 'lowstock':
      case 'low_stock':
        return StockLevel.lowStock;
      case 'outofstock':
      case 'out_of_stock':
        return StockLevel.outOfStock;
      default:
        return StockLevel.inStock;
    }
  }

  VehicleStatus _parseVehicleStatus(String? s) {
    switch (s?.toLowerCase()) {
      case 'maintenance':
        return VehicleStatus.maintenance;
      case 'offline':
        return VehicleStatus.offline;
      case 'idle':
        return VehicleStatus.idle;
      default:
        return VehicleStatus.active;
    }
  }

  PlaceType _parsePlaceType(String? s) {
    switch (s?.toLowerCase()) {
      case 'warehouse':
        return PlaceType.warehouse;
      case 'office':
        return PlaceType.office;
      case 'home':
        return PlaceType.home;
      case 'custom':
        return PlaceType.custom;
      default:
        return PlaceType.retail;
    }
  }

  PlaceVisibility _parsePlaceVisibility(String? s) {
    switch (s?.toLowerCase()) {
      case 'private':
        return PlaceVisibility.private;
      default:
        return PlaceVisibility.public;
    }
  }

  PostStatus _parsePostStatus(String? s) {
    switch (s?.toLowerCase()) {
      case 'published':
        return PostStatus.published;
      case 'scheduled':
        return PostStatus.scheduled;
      default:
        return PostStatus.draft;
    }
  }

  SocialPlatform _parseSocialPlatform(String s) {
    switch (s.toLowerCase()) {
      case 'instagram':
        return SocialPlatform.instagram;
      case 'twitter':
        return SocialPlatform.twitter;
      case 'linkedin':
        return SocialPlatform.linkedIn;
      case 'tiktok':
        return SocialPlatform.tikTok;
      default:
        return SocialPlatform.facebook;
    }
  }

  ConnectionType _parseConnectionType(String? s) {
    switch (s?.toLowerCase()) {
      case 'customer':
        return ConnectionType.customer;
      case 'partner':
        return ConnectionType.partner;
      case 'other':
        return ConnectionType.other;
      default:
        return ConnectionType.supplier;
    }
  }

  ConnectionStatus _parseConnectionStatus(String? s) {
    switch (s?.toLowerCase()) {
      case 'pending':
        return ConnectionStatus.pending;
      case 'blocked':
        return ConnectionStatus.blocked;
      default:
        return ConnectionStatus.active;
    }
  }

  QPointsTransactionType _parseQPointsTransactionType(String? s) {
    switch (s?.toLowerCase()) {
      case 'redeemed':
        return QPointsTransactionType.redeemed;
      case 'expired':
        return QPointsTransactionType.expired;
      case 'bonus':
        return QPointsTransactionType.bonus;
      case 'transferred':
        return QPointsTransactionType.transferred;
      default:
        return QPointsTransactionType.earned;
    }
  }

  QPointsTransactionStatus _parseQPointsTransactionStatus(String? s) {
    switch (s?.toLowerCase()) {
      case 'pending':
        return QPointsTransactionStatus.pending;
      case 'failed':
        return QPointsTransactionStatus.failed;
      default:
        return QPointsTransactionStatus.completed;
    }
  }

  SubscriptionPlan _parseSubscriptionPlan(String? s) {
    switch (s?.toLowerCase()) {
      case 'free':
        return SubscriptionPlan.free;
      case 'basic':
        return SubscriptionPlan.basic;
      case 'enterprise':
        return SubscriptionPlan.enterprise;
      default:
        return SubscriptionPlan.professional;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FALLBACK DATA
  // ═══════════════════════════════════════════════════════════════════════════

  static final List<Product> _fallbackProducts = [
    Product(id: 'p1', name: 'iPhone 13 Pro', sku: 'IP13P-BLK', category: 'Electronics', brand: 'Apple', basePrice: 3999, currentPrice: 3499, stock: 45, rating: 4.8, reviewCount: 128, tags: ['Best Seller', 'On Sale'], soldToday: 12, lastSold: DateTime.now().subtract(const Duration(hours: 2))),
    const Product(id: 'p2', name: 'Samsung Galaxy S22', sku: 'SGS22-GRY', category: 'Electronics', brand: 'Samsung', basePrice: 3199, currentPrice: 2899, stock: 12, lowStockThreshold: 15, rating: 4.5, reviewCount: 89, stockLevel: StockLevel.lowStock, tags: ['Low Stock']),
    const Product(id: 'p3', name: 'MacBook Pro 14"', sku: 'MBP14-SLV', category: 'Computers', brand: 'Apple', basePrice: 5999, currentPrice: 5999, stock: 23, rating: 4.9, reviewCount: 234, tags: ['New Arrival']),
    const Product(id: 'p4', name: 'AirPods Pro', sku: 'APP-WHT', category: 'Audio', brand: 'Apple', basePrice: 999, currentPrice: 899, stock: 0, rating: 4.7, reviewCount: 456, stockLevel: StockLevel.outOfStock, tags: ['Out of Stock']),
    const Product(id: 'p5', name: 'Dell Monitor 27"', sku: 'DM27-BLK', category: 'Computers', brand: 'Dell', basePrice: 1499, currentPrice: 1499, stock: 67, rating: 4.4, reviewCount: 56),
    const Product(id: 'p6', name: 'Logitech MX Master 3', sku: 'LMX3-BLK', category: 'Accessories', brand: 'Logitech', basePrice: 399, currentPrice: 349, stock: 89, rating: 4.6, reviewCount: 178, tags: ['On Sale']),
    const Product(id: 'p7', name: 'Sony WH-1000XM5', sku: 'SWH5-BLK', category: 'Audio', brand: 'Sony', basePrice: 1599, currentPrice: 1399, stock: 34, rating: 4.8, reviewCount: 312, tags: ['Best Seller', 'On Sale']),
    const Product(id: 'p8', name: 'iPad Air', sku: 'IPA-BLU', category: 'Tablets', brand: 'Apple', basePrice: 2499, currentPrice: 2499, stock: 8, lowStockThreshold: 10, rating: 4.7, reviewCount: 167, stockLevel: StockLevel.lowStock),
  ];

  static final List<Vehicle> _fallbackVehicles = [
    const Vehicle(id: 'V-789', plateNumber: 'GA-789-AB', make: 'Toyota', model: 'Hilux', year: 2022, status: VehicleStatus.active, assignedDriverId: 'drv1', assignedDriverName: 'John Driver', zone: 'East', fuelLevel: 65, distanceToday: 45, deliveriesToday: 12, deliveriesTarget: 15, onTimeRate: 92, capacityKg: 1500),
    const Vehicle(id: 'V-456', plateNumber: 'GA-456-CD', make: 'Nissan', model: 'NV350', year: 2021, status: VehicleStatus.maintenance, zone: 'West', fuelLevel: 0, distanceToday: 0, capacityKg: 2000),
    const Vehicle(id: 'V-123', plateNumber: 'GA-123-EF', make: 'Ford', model: 'Transit', year: 2023, status: VehicleStatus.active, assignedDriverId: 'drv2', assignedDriverName: 'Sarah Driver', zone: 'Central', fuelLevel: 80, distanceToday: 38, deliveriesToday: 8, deliveriesTarget: 12, onTimeRate: 95, capacityKg: 1200),
    const Vehicle(id: 'V-890', plateNumber: 'GA-890-GH', make: 'Toyota', model: 'HiAce', year: 2022, status: VehicleStatus.active, assignedDriverId: 'drv3', assignedDriverName: 'Mike Driver', zone: 'North', fuelLevel: 42, distanceToday: 78, deliveriesToday: 18, deliveriesTarget: 20, onTimeRate: 88, capacityKg: 1800),
    const Vehicle(id: 'V-234', plateNumber: 'GA-234-IJ', make: 'Honda', model: 'PCX', year: 2023, status: VehicleStatus.active, assignedDriverId: 'drv4', assignedDriverName: 'Alex Rider', zone: 'East', fuelLevel: 90, distanceToday: 22, capacityKg: 50),
    const Vehicle(id: 'V-567', plateNumber: 'GA-567-KL', make: 'Isuzu', model: 'NPR', year: 2020, status: VehicleStatus.offline, zone: 'West', fuelLevel: 15, distanceToday: 0, capacityKg: 3000),
  ];

  static final List<MaintenanceRecord> _fallbackMaintenanceRecords = [
    MaintenanceRecord(id: 'm1', vehicleId: 'V-789', serviceType: 'Oil Change', date: DateTime.now().subtract(const Duration(days: 7)), cost: 450),
    MaintenanceRecord(id: 'm2', vehicleId: 'V-456', serviceType: 'Brake Inspection', date: DateTime.now().subtract(const Duration(days: 2)), cost: 300, isUrgent: true),
    MaintenanceRecord(id: 'm3', vehicleId: 'V-123', serviceType: 'Tire Rotation', date: DateTime.now().subtract(const Duration(days: 30)), cost: 200),
  ];

  static final List<FuelEntry> _fallbackFuelEntries = [
    FuelEntry(id: 'f1', vehicleId: 'V-789', liters: 45, cost: 279, odometer: 45230, date: DateTime.now().subtract(const Duration(days: 2))),
    FuelEntry(id: 'f2', vehicleId: 'V-123', liters: 38, cost: 236, odometer: 32100, date: DateTime.now().subtract(const Duration(days: 5))),
    FuelEntry(id: 'f3', vehicleId: 'V-890', liters: 50, cost: 310, odometer: 28500, date: DateTime.now().subtract(const Duration(days: 1))),
  ];

  static final List<CustomerTab> _fallbackTabs = [
    CustomerTab(id: 't1', tabNumber: '#7891', customerName: 'John Smith', creditLimit: 5000, amountUsed: 3750, customerRating: 4.8, createdAt: DateTime(2023, 1, 15), nextPaymentDate: DateTime.now().add(const Duration(days: 8)), nextPaymentAmount: 500, autoPayEnabled: true),
    CustomerTab(id: 't2', tabNumber: '#7892', customerName: 'Sarah Johnson', creditLimit: 2000, amountUsed: 2100, status: TabStatus.overdue, customerRating: 4.5, createdAt: DateTime(2022, 12, 1), nextPaymentDate: DateTime.now().subtract(const Duration(days: 3)), nextPaymentAmount: 350),
    CustomerTab(id: 't3', tabNumber: '#7893', customerName: 'Mike Chen', creditLimit: 3000, amountUsed: 1200, customerRating: 4.9, createdAt: DateTime(2023, 3, 20), nextPaymentDate: DateTime.now().add(const Duration(days: 15)), nextPaymentAmount: 400),
    CustomerTab(id: 't4', tabNumber: '#7894', customerName: 'Emma Wilson', creditLimit: 1500, amountUsed: 1500, status: TabStatus.atLimit, customerRating: 4.2, createdAt: DateTime(2023, 6, 10)),
  ];

  static final List<TabTransaction> _fallbackTabTransactions = [
    TabTransaction(id: 'tt1', tabId: 't1', description: 'Purchase - Electronics', amount: 250, isPayment: false, category: 'Electronics', date: DateTime.now().subtract(const Duration(days: 2))),
    TabTransaction(id: 'tt2', tabId: 't1', description: 'Payment - Credit card', amount: 500, isPayment: true, date: DateTime.now().subtract(const Duration(days: 4))),
    TabTransaction(id: 'tt3', tabId: 't1', description: 'Purchase - Groceries', amount: 150, isPayment: false, category: 'Groceries', date: DateTime.now().subtract(const Duration(days: 7))),
  ];

  static final List<DiscountTier> _fallbackDiscounts = [
    DiscountTier(id: 'd1', name: 'Winter Sale', code: 'WINTER24', type: DiscountType.percentage, value: 15, minimumPurchase: 500, productScope: 'All electronics', customerCount: 245, revenueImpact: 12450, startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 1, 31)),
    const DiscountTier(id: 'd2', name: 'Loyalty Program', code: 'LOYALTY10', type: DiscountType.percentage, value: 10, minimumPurchase: 100, productScope: 'All', customerCount: 245, revenueImpact: 8900),
    const DiscountTier(id: 'd3', name: 'Free Shipping', code: 'FREESHIP', type: DiscountType.fixedAmount, value: 25, minimumPurchase: 200, productScope: 'All', customerCount: 189, revenueImpact: 4725),
    DiscountTier(id: 'd4', name: 'Summer Preview', code: 'SUMMER25', type: DiscountType.percentage, status: DiscountStatus.draft, value: 20, productScope: 'Seasonal', startDate: DateTime(2024, 6, 1)),
  ];

  static final List<StaffMember> _fallbackStaff = [
    StaffMember(id: 's1', name: 'John Manager', role: 'Administrator', department: 'Management', branch: 'East Ridge', rating: 4.8, reviewCount: 45, joinedDate: DateTime(2022, 1, 15), hoursThisWeek: 32, tasksCompleted: 7, tasksTotal: 12, email: 'john@company.com', phone: '024 123 4567'),
    StaffMember(id: 's2', name: 'Sarah Driver', role: 'Driver', department: 'Operations', branch: 'East Ridge', status: StaffStatus.idle, rating: 4.6, reviewCount: 32, joinedDate: DateTime(2023, 3, 1), hoursThisWeek: 28, vehicleId: 'V-789'),
    StaffMember(id: 's3', name: 'Mike Sales', role: 'Branch Manager', department: 'Sales', branch: 'West Hills', rating: 4.5, reviewCount: 28, joinedDate: DateTime(2022, 6, 15), hoursThisWeek: 38, tasksCompleted: 5, tasksTotal: 8),
    StaffMember(id: 's4', name: 'Emma Cashier', role: 'Staff', department: 'Sales', branch: 'East Ridge', rating: 4.7, reviewCount: 56, joinedDate: DateTime(2023, 1, 10), hoursThisWeek: 40, tasksCompleted: 10, tasksTotal: 10),
    StaffMember(id: 's5', name: 'Alex Support', role: 'Response Officer', department: 'Support', status: StaffStatus.offline, rating: 4.3, joinedDate: DateTime(2023, 8, 1), hoursThisWeek: 0),
    StaffMember(id: 's6', name: 'Grace Marketing', role: 'Social Officer', department: 'Marketing', rating: 4.9, reviewCount: 34, joinedDate: DateTime(2022, 9, 1), hoursThisWeek: 35, tasksCompleted: 8, tasksTotal: 10),
  ];

  static const List<Place> _fallbackPlaces = [
    Place(id: 'pl1', name: 'Main Store', type: PlaceType.retail, address: '123 Main St', area: 'East Ridge', rating: 4.8, reviewCount: 428, staffCount: 12, productCount: 1245, hoursDisplay: '8AM-10PM'),
    Place(id: 'pl2', name: 'East Warehouse', type: PlaceType.warehouse, visibility: PlaceVisibility.private, address: '456 Industry Rd', area: 'Industrial Area', staffCount: 8),
    Place(id: 'pl3', name: 'West Branch', type: PlaceType.retail, address: '789 West Ave', area: 'West Hills', rating: 4.6, reviewCount: 256, staffCount: 8, productCount: 890, hoursDisplay: '9AM-9PM'),
    Place(id: 'pl4', name: 'Head Office', type: PlaceType.office, address: '1 Business Rd', area: 'CBD', staffCount: 15),
  ];

  static const List<DeliveryZone> _fallbackZones = [
    DeliveryZone(id: 'z1', name: 'East Ridge', fee: 5, estimatedTime: '30-45 min', vehicleCount: 12, dailyDeliveries: 45, coverageKm2: 15, populationServed: 45000),
    DeliveryZone(id: 'z2', name: 'West Hills', fee: 7, estimatedTime: '45-60 min', vehicleCount: 8, dailyDeliveries: 32, coverageKm2: 22, populationServed: 38000),
    DeliveryZone(id: 'z3', name: 'Central District', status: ZoneStatus.partial, fee: 10, estimatedTime: '20-30 min', vehicleCount: 6, dailyDeliveries: 28, coverageKm2: 8, populationServed: 52000),
    DeliveryZone(id: 'z4', name: 'North Quarter', fee: 8, estimatedTime: '35-50 min', vehicleCount: 4, dailyDeliveries: 18, coverageKm2: 12, populationServed: 32000),
  ];

  static const List<VehicleBand> _fallbackBands = [
    VehicleBand(id: 'b1', name: 'Delivery Trucks', purpose: 'Primary delivery fleet', vehicleCount: 8, utilization: 85, vehicleIds: ['V-789', 'V-456', 'V-123', 'V-890'], maxCapacity: 12, maintenanceCostMonthly: 1245),
    VehicleBand(id: 'b2', name: 'Service Vehicles', purpose: 'Customer service visits', vehicleCount: 6, utilization: 42, vehicleIds: ['V-234', 'V-567'], maxCapacity: 8, maintenanceCostMonthly: 890),
    VehicleBand(id: 'b3', name: 'Express Bikes', purpose: 'Quick local deliveries', vehicleCount: 4, utilization: 23, vehicleIds: ['V-234'], maxCapacity: 6, maintenanceCostMonthly: 320),
  ];

  static final List<Branch> _fallbackBranches = [
    Branch(id: 'br1', name: 'East Ridge Branch', type: 'Retail', managerName: 'John Manager', rating: 4.8, staffCount: 12, vehicleCount: 6, monthlyRevenue: 245000, lastSync: DateTime.now().subtract(const Duration(minutes: 2)), area: 'East Ridge'),
    Branch(id: 'br2', name: 'West Hills Branch', type: 'Retail', status: BranchStatus.offline, managerName: 'Sarah Manager', rating: 4.6, staffCount: 8, vehicleCount: 4, monthlyRevenue: 189000, lastSync: DateTime.now().subtract(const Duration(minutes: 45)), area: 'West Hills'),
    Branch(id: 'br3', name: 'Central District', type: 'Retail', managerName: 'Mike Manager', rating: 4.7, staffCount: 10, vehicleCount: 5, monthlyRevenue: 156000, lastSync: DateTime.now().subtract(const Duration(minutes: 5)), area: 'Central'),
    const Branch(id: 'br4', name: 'North Quarter', type: 'Logistics', status: BranchStatus.maintenance, managerName: 'Alex Manager', rating: 4.5, staffCount: 6, vehicleCount: 8, monthlyRevenue: 120000, area: 'North'),
  ];

  static final List<Campaign> _fallbackCampaigns = [
    Campaign(id: 'c1', name: 'Winter Sale', type: CampaignType.discount, goal: CampaignGoal.increaseSales, budget: 10000, spent: 2450, reach: 12450, conversions: 245, roi: 165, startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 1, 31)),
    Campaign(id: 'c2', name: 'New Product Launch', type: CampaignType.multiChannel, goal: CampaignGoal.brandAwareness, budget: 5000, spent: 1200, reach: 8900, conversions: 189, roi: 142, startDate: DateTime(2024, 1, 15), endDate: DateTime(2024, 2, 15)),
    Campaign(id: 'c3', name: 'Loyalty Rewards', type: CampaignType.email, goal: CampaignGoal.customerRetention, status: CampaignStatus.scheduled, budget: 3000, startDate: DateTime(2024, 2, 1), endDate: DateTime(2024, 3, 31)),
  ];

  static final List<SocialPost> _fallbackPosts = [
    SocialPost(id: 'sp1', content: 'Winter Sale is Here! ❄️ Get up to 50% off on all electronics.', status: PostStatus.published, platforms: [SocialPlatform.facebook, SocialPlatform.instagram, SocialPlatform.twitter], likes: 245, comments: 42, shares: 12, reach: 12450, engagementRate: 4.8, publishDate: DateTime.now().subtract(const Duration(hours: 4)), hasMedia: true, mediaType: 'Image'),
    SocialPost(id: 'sp2', content: 'Behind the scenes at our warehouse! 📦', status: PostStatus.scheduled, platforms: [SocialPlatform.instagram], scheduledDate: DateTime.now().add(const Duration(hours: 18)), hasMedia: true, mediaType: 'Video'),
    const SocialPost(id: 'sp3', content: 'Customer spotlight: How Sarah transformed her kitchen.', status: PostStatus.draft, platforms: [SocialPlatform.facebook, SocialPlatform.linkedIn]),
  ];

  static const List<Connection> _fallbackConnections = [
    Connection(id: 'cn1', name: 'John Supplier', type: ConnectionType.supplier, category: 'Electronics', rating: 4.8, strengthPercent: 92, totalOrders: 45, totalValue: 245000, lastInteraction: '2 days ago'),
    Connection(id: 'cn2', name: 'Sarah Customer', type: ConnectionType.customer, status: ConnectionStatus.pending, category: 'Retail', rating: 4.6, strengthPercent: 0),
    Connection(id: 'cn3', name: 'Mike Partner', type: ConnectionType.partner, category: 'Logistics', rating: 4.7, strengthPercent: 78, totalOrders: 12, totalValue: 89000, lastInteraction: '1 week ago'),
    Connection(id: 'cn4', name: 'Emma Distributor', type: ConnectionType.supplier, category: 'Fashion', rating: 4.5, strengthPercent: 85, totalOrders: 28, totalValue: 156000, lastInteraction: 'Yesterday'),
  ];

  static final List<AuditEntry> _fallbackAuditEntries = [
    AuditEntry(id: 'a1', action: AuditAction.update, description: 'John updated Product #123', userName: 'John Manager', userRole: 'Administrator', entityType: 'Product', entityId: 'p1', timestamp: DateTime.now().subtract(const Duration(minutes: 5)), ipAddress: '192.168.1.45', deviceInfo: 'iPhone 13 Pro'),
    AuditEntry(id: 'a2', action: AuditAction.read, description: 'Sarah viewed Customer Tab #7891', userName: 'Sarah Driver', userRole: 'Driver', entityType: 'Tab', entityId: 't1', timestamp: DateTime.now().subtract(const Duration(minutes: 15))),
    AuditEntry(id: 'a3', action: AuditAction.update, description: 'System auto-updated inventory levels', userName: 'System', userRole: 'System', entityType: 'Inventory', timestamp: DateTime.now().subtract(const Duration(minutes: 30))),
    AuditEntry(id: 'a4', action: AuditAction.delete, outcome: AuditOutcome.failure, description: 'Mike attempted to delete branch', userName: 'Mike Sales', userRole: 'Branch Manager', entityType: 'Branch', timestamp: DateTime.now().subtract(const Duration(minutes: 45))),
    AuditEntry(id: 'a5', action: AuditAction.login, outcome: AuditOutcome.suspicious, description: 'Unknown device logged in', userName: 'Unknown', userRole: 'N/A', entityType: 'Session', timestamp: DateTime.now().subtract(const Duration(hours: 1)), ipAddress: '203.0.113.45', deviceInfo: 'Unknown Android'),
    AuditEntry(id: 'a6', action: AuditAction.create, description: 'Mike created Discount Tier', userName: 'Mike Sales', userRole: 'Branch Manager', entityType: 'Discount', entityId: 'd4', timestamp: DateTime.now().subtract(const Duration(hours: 2))),
  ];

  static const List<KPIMetric> _fallbackKPIs = [
    KPIMetric(label: 'Revenue', value: '₵245,000', changePercent: 12, isPositive: true, icon: Icons.attach_money),
    KPIMetric(label: 'Customers', value: '2,450', changePercent: 8, isPositive: true, icon: Icons.people),
    KPIMetric(label: 'Orders', value: '1,234', changePercent: 15, isPositive: true, icon: Icons.shopping_cart),
    KPIMetric(label: 'Satisfaction', value: '4.8/5', changePercent: 4, isPositive: true, icon: Icons.sentiment_satisfied),
    KPIMetric(label: 'Efficiency', value: '85%', changePercent: 5, isPositive: true, icon: Icons.speed),
    KPIMetric(label: 'Costs', value: '₵189,000', changePercent: 8, isPositive: false, icon: Icons.trending_up),
  ];

  static const List<AIInsight> _fallbackInsights = [
    AIInsight(title: 'Opportunity Detected', description: 'Evening hours (18:00-20:00) show 52% higher customer spend but 30% lower staff coverage.', recommendation: 'Increase evening staff by 2. Projected Impact: +₵12,450 monthly revenue.', priority: AlertPriority.important, impact: '+₵12,450/month', icon: Icons.lightbulb),
    AIInsight(title: 'Risk Identified', description: 'Supplier "John Electronics" has 3 delayed shipments this month (avg. +2 days).', recommendation: 'Diversify suppliers or renegotiate terms.', priority: AlertPriority.important, impact: '₵45,000 at risk', icon: Icons.warning_amber),
    AIInsight(title: 'Trend Identified', description: 'Mobile app users spend 35% more than web users.', recommendation: 'Promote app downloads. Target: +15% this quarter.', priority: AlertPriority.normal, icon: Icons.trending_up),
  ];

  static final List<QPointsTransaction> _fallbackQPointsTransactions = [
    QPointsTransaction(id: 'qp1', type: QPointsTransactionType.earned, amount: 45, description: 'Sale #TX-7891 - iPhone 13 Pro', date: DateTime.now().subtract(const Duration(hours: 1)), source: 'Commission'),
    QPointsTransaction(id: 'qp2', type: QPointsTransactionType.redeemed, amount: 150, description: 'Redeemed for AirPods Pro', date: DateTime.now().subtract(const Duration(hours: 3)), source: 'Redemption'),
    QPointsTransaction(id: 'qp3', type: QPointsTransactionType.earned, amount: 320, description: 'Referral #REF-123 - Sarah Johnson', date: DateTime.now().subtract(const Duration(hours: 5)), source: 'Referral'),
    QPointsTransaction(id: 'qp4', type: QPointsTransactionType.bonus, amount: 120, description: 'Monthly performance bonus', date: DateTime.now().subtract(const Duration(days: 1)), source: 'Bonus'),
    QPointsTransaction(id: 'qp5', type: QPointsTransactionType.transferred, status: QPointsTransactionStatus.pending, amount: 75, description: 'Transfer to Mike Driver', date: DateTime.now().subtract(const Duration(days: 1))),
    QPointsTransaction(id: 'qp6', type: QPointsTransactionType.expired, amount: 500, description: 'Points expired (Jan batch)', date: DateTime.now().subtract(const Duration(days: 2))),
  ];

  static final List<UserTask> _fallbackTasks = [
    UserTask(id: 'tk1', title: 'Inventory audit', description: 'Complete monthly inventory audit for all products.', status: TaskStatus.inProgress, dueDate: DateTime.now(), tags: ['Inventory', 'High Priority'], progress: 0.2, assignee: 'John Manager', priority: 'high', checklist: [const TaskChecklistItem(label: 'Count physical inventory', isCompleted: true), const TaskChecklistItem(label: 'Compare with system records', isCompleted: true), const TaskChecklistItem(label: 'Investigate discrepancies'), const TaskChecklistItem(label: 'Update system records'), const TaskChecklistItem(label: 'Generate report')]),
    UserTask(id: 'tk2', title: 'Approve staff schedule', status: TaskStatus.todo, dueDate: DateTime.now().add(const Duration(days: 1)), tags: ['Staff'], assignee: 'John Manager', priority: 'medium'),
    UserTask(id: 'tk3', title: 'Update product prices', status: TaskStatus.todo, dueDate: DateTime.now().add(const Duration(days: 2)), tags: ['Products'], assignee: 'Emma Cashier', priority: 'low'),
    UserTask(id: 'tk4', title: 'Review inventory report', status: TaskStatus.completed, completedAt: DateTime.now().subtract(const Duration(hours: 2)), tags: ['Inventory'], assignee: 'John Manager', priority: 'medium'),
    UserTask(id: 'tk5', title: 'Morning briefing', status: TaskStatus.completed, completedAt: DateTime.now().subtract(const Duration(hours: 4)), tags: ['Meeting'], assignee: 'John Manager', priority: 'low'),
    UserTask(id: 'tk6', title: 'Customer complaint resolution', status: TaskStatus.completed, completedAt: DateTime.now().subtract(const Duration(hours: 1)), tags: ['Support'], assignee: 'Alex Support', priority: 'high'),
    UserTask(id: 'tk7', title: 'Monthly report', status: TaskStatus.todo, dueDate: DateTime.now().add(const Duration(days: 5)), tags: ['Reports'], assignee: 'John Manager', priority: 'medium'),
  ];

  static final List<UserGoal> _fallbackGoals = [
    UserGoal(id: 'g1', title: 'Increase sales by 15%', status: GoalStatus.onTrack, progress: 48, target: '₵750K', current: '₵245K', currentValue: '₵245K', targetValue: '₵750K', unit: 'revenue', dueDate: DateTime(2024, 3, 31), deadline: DateTime(2024, 3, 31)),
    UserGoal(id: 'g2', title: 'Reduce operational costs by 10%', status: GoalStatus.ahead, progress: 32, target: '-₵50K', current: '-₵8K', currentValue: '₵8K', targetValue: '₵50K', unit: 'savings', dueDate: DateTime(2024, 3, 31), deadline: DateTime(2024, 3, 31)),
    UserGoal(id: 'g3', title: 'Improve team satisfaction to 4.8/5', status: GoalStatus.ahead, progress: 76, target: '4.8/5', current: '4.6/5', currentValue: '4.6', targetValue: '4.8', unit: 'rating', dueDate: DateTime(2024, 3, 31), deadline: DateTime(2024, 3, 31)),
    UserGoal(id: 'g4', title: 'Complete professional certification', status: GoalStatus.onTrack, progress: 60, target: '5 modules', current: '3 modules', currentValue: '3', targetValue: '5', unit: 'modules', dueDate: DateTime(2024, 2, 28), deadline: DateTime(2024, 2, 28), category: 'Personal'),
    const UserGoal(id: 'g5', title: 'Improve work-life balance', status: GoalStatus.needsAttention, progress: 20, target: '40 hrs/week', current: '48 hrs/week', currentValue: '48', targetValue: '40', unit: 'hrs/week', category: 'Personal'),
  ];

  static final List<ActivityTimelineEntry> _fallbackTimeline = [
    ActivityTimelineEntry(title: 'Clocked In', subtitle: 'Main office entrance', timestamp: DateTime(2024, 1, 15, 8, 0), action: 'login', time: '08:00', description: 'Clocked in', isCompleted: true),
    ActivityTimelineEntry(title: 'Morning Briefing', subtitle: 'Team sync with 6 members', timestamp: DateTime(2024, 1, 15, 8, 15), action: 'message', time: '08:15', description: 'Morning briefing with team', isCompleted: true),
    ActivityTimelineEntry(title: 'Inventory Reports', subtitle: 'Reviewed all departments', timestamp: DateTime(2024, 1, 15, 9, 0), action: 'update', time: '09:00', description: 'Reviewed inventory reports', isCompleted: true),
    ActivityTimelineEntry(title: 'Price Update', subtitle: 'Updated 12 product prices', timestamp: DateTime(2024, 1, 15, 10, 15), action: 'update', time: '10:15', description: 'Updated product prices (#123)', isCompleted: true),
    ActivityTimelineEntry(title: 'Staff Meeting', subtitle: 'Q1 planning discussion', timestamp: DateTime(2024, 1, 15, 11, 0), action: 'message', time: '11:00', description: 'Staff meeting (45 mins)', isCompleted: true),
    ActivityTimelineEntry(title: 'Lunch Break', subtitle: '1 hour break', timestamp: DateTime(2024, 1, 15, 12, 30), action: '', time: '12:30', description: 'Lunch break', isCompleted: true),
    ActivityTimelineEntry(title: 'Complaint Resolution', subtitle: 'Case #CR-456 resolved', timestamp: DateTime(2024, 1, 15, 13, 15), action: 'approval', time: '13:15', description: 'Customer complaint resolution', isCompleted: true),
    ActivityTimelineEntry(title: 'Campaign Review', subtitle: 'Winter Sale performance', timestamp: DateTime(2024, 1, 15, 14, 30), action: 'campaign', time: '14:30', description: 'Campaign performance review', isCurrent: true),
    ActivityTimelineEntry(title: 'Schedule Planning', subtitle: 'Next week optimization', timestamp: DateTime(2024, 1, 15, 15, 45), action: 'update', time: '15:45', description: 'Schedule optimization planning'),
    ActivityTimelineEntry(title: 'Weekly Review', subtitle: 'With regional manager', timestamp: DateTime(2024, 1, 15, 16, 30), action: 'message', time: '16:30', description: 'Weekly review with manager'),
    ActivityTimelineEntry(title: 'Task Planning', subtitle: 'Prepare tomorrow\'s agenda', timestamp: DateTime(2024, 1, 15, 17, 15), action: 'update', time: '17:15', description: 'Plan tomorrow\'s tasks'),
  ];

  static const List<UserInterest> _fallbackInterests = [
    UserInterest(id: 'i1', name: 'Technology', emoji: '📱', updateCount: 56, category: 'Tech'),
    UserInterest(id: 'i2', name: 'Food & Dining', emoji: '🍕', updateCount: 45, category: 'Lifestyle'),
    UserInterest(id: 'i3', name: 'Automotive', emoji: '🚗', updateCount: 32, category: 'Lifestyle'),
    UserInterest(id: 'i4', name: 'Home', emoji: '🏠', updateCount: 28, category: 'Lifestyle'),
    UserInterest(id: 'i5', name: 'Fashion', emoji: '👕', updateCount: 23, category: 'Lifestyle'),
    UserInterest(id: 'i6', name: 'Travel', emoji: '✈️', updateCount: 12, category: 'Lifestyle'),
    UserInterest(id: 'i7', name: 'Books', emoji: '📚', updateCount: 34, category: 'Education'),
    UserInterest(id: 'i8', name: 'Gaming', emoji: '🎮', updateCount: 67, category: 'Entertainment'),
    UserInterest(id: 'i9', name: 'Fitness', emoji: '🏃', updateCount: 45, category: 'Health'),
    UserInterest(id: 'i10', name: 'Music', emoji: '🎵', updateCount: 56, category: 'Entertainment'),
    UserInterest(id: 'i11', name: 'Photography', emoji: '📷', updateCount: 23, category: 'Creative'),
    UserInterest(id: 'i12', name: 'Gardening', emoji: '🌿', updateCount: 31, category: 'Lifestyle'),
  ];

  static const List<InterestRecommendation> _fallbackRecommendations = [
    InterestRecommendation(name: 'Smart Home Devices', followerGrowth: 245, matchPercent: 92),
    InterestRecommendation(name: 'DIY Electronics', followerGrowth: 189, matchPercent: 85),
    InterestRecommendation(name: 'Sustainable Living', followerGrowth: 345, matchPercent: 78),
  ];
}
