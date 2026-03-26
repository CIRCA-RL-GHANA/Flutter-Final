/// ═══════════════════════════════════════════════════════════════════════════
/// Context Provider
/// Manages active user context, role switching, entity management
/// Loads real user contexts from API, falls back to hardcoded defaults
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import '../../../core/services/services.dart';
import '../models/rbac_models.dart';

class ContextProvider extends ChangeNotifier {
  final EntityService _entityService;
  final AuthService _authService;

  ContextProvider({
    EntityService? entityService,
    AuthService? authService,
  })  : _entityService = entityService ?? EntityService(),
        _authService = authService ?? AuthService();

  // ─── Loading / Error State ───────────────────────────────────────────────
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ─── Active Context ──────────────────────────────────────────────────────
  AppContextModel _activeContext = _fallbackContexts.first;

  AppContextModel get activeContext => _activeContext;
  UserRole get currentRole => _activeContext.role;
  EntityType get currentEntityType => _activeContext.entityType;
  BranchType? get currentBranchType => _activeContext.branchType;
  DriverType? get currentDriverType => _activeContext.driverType;
  PresenceStatus get presence => _activeContext.presence;

  // ─── Available Contexts ──────────────────────────────────────────────────
  /// All contexts the user can switch to
  List<AppContextModel> _availableContexts = List.from(_fallbackContexts);

  List<AppContextModel> get availableContexts => _availableContexts;

  /// Contexts excluding the active one (for the switcher)
  List<AppContextModel> get otherContexts =>
      _availableContexts.where((c) => c.id != _activeContext.id).toList();

  // ─── Fallback Contexts ──────────────────────────────────────────────────
  static const List<AppContextModel> _fallbackContexts = [
    AppContextModel(
      id: 'ctx_personal_1',
      name: 'John Doe',
      subtitle: 'Personal Account',
      entityType: EntityType.personal,
      role: UserRole.owner,
      presence: PresenceStatus.online,
    ),
    AppContextModel(
      id: 'ctx_business_1',
      name: 'Wizdom Shop',
      subtitle: 'Business Account',
      entityType: EntityType.business,
      role: UserRole.administrator,
      branchType: BranchType.shop,
      presence: PresenceStatus.online,
    ),
    AppContextModel(
      id: 'ctx_branch_1',
      name: 'Wizdom Shop - Accra',
      subtitle: 'Branch',
      entityType: EntityType.branch,
      role: UserRole.branchManager,
      branchType: BranchType.shop,
      presence: PresenceStatus.online,
    ),
  ];

  // ─── Initialization ─────────────────────────────────────────────────────

  /// Call once after the provider is created to load real user contexts.
  Future<void> init() async {
    await loadContexts();
  }

  /// Fetches the authenticated user's profile and their entities from the API,
  /// builds [AppContextModel] objects, and sets the personal context as default.
  /// Falls back to [_fallbackContexts] on failure.
  Future<void> loadContexts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Get current authenticated user
      final profileResponse = await _authService.getMe();
      if (!profileResponse.success || profileResponse.data == null) {
        throw Exception(
          profileResponse.message ?? 'Failed to load user profile',
        );
      }

      final profile = profileResponse.data!;
      final userId = profile['id']?.toString() ?? '';
      final userName = profile['displayName']?.toString() ??
          profile['name']?.toString() ??
          '${profile['firstName'] ?? ''} ${profile['lastName'] ?? ''}'.trim();
      final avatarUrl = profile['avatarUrl']?.toString();

      // Build personal context from profile
      final personalContext = AppContextModel(
        id: userId.isNotEmpty ? userId : 'ctx_personal',
        name: userName.isNotEmpty ? userName : 'My Account',
        subtitle: 'Personal Account',
        entityType: EntityType.personal,
        role: UserRole.owner,
        avatarUrl: avatarUrl,
        presence: PresenceStatus.online,
      );

      final List<AppContextModel> contexts = [personalContext];

      // 2. Get user's entities (businesses, branches, etc.)
      if (userId.isNotEmpty) {
        final entitiesResponse =
            await _entityService.getEntitiesByOwnerId(userId);
        if (entitiesResponse.success && entitiesResponse.data != null) {
          for (final entityJson in entitiesResponse.data!) {
            final ctx = _contextFromJson(entityJson);
            if (ctx != null) {
              contexts.add(ctx);
            }

            // Load branches for business entities
            final entityType = _parseEntityType(
              entityJson['entityType']?.toString() ?? '',
            );
            final entityId = entityJson['id']?.toString() ?? '';

            if (entityType == EntityType.business && entityId.isNotEmpty) {
              final branchesResponse =
                  await _entityService.getBranches(entityId);
              if (branchesResponse.success && branchesResponse.data != null) {
                for (final branchJson in branchesResponse.data!) {
                  final branchCtx = _contextFromJson(branchJson);
                  if (branchCtx != null) {
                    contexts.add(branchCtx);
                  }
                }
              }
            }
          }
        }
      }

      _availableContexts = contexts;
      _activeContext = contexts.first;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('ContextProvider.loadContexts error: $e');
      _error = e.toString();
      _availableContexts = List.from(_fallbackContexts);
      _activeContext = _fallbackContexts.first;
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── JSON → Model Helpers ───────────────────────────────────────────────

  /// Converts an entity JSON map into an [AppContextModel].
  /// Returns null if the JSON is missing required fields.
  AppContextModel? _contextFromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString();
    if (id == null || id.isEmpty) return null;

    final name = json['name']?.toString() ??
        json['businessName']?.toString() ??
        json['displayName']?.toString() ??
        '';
    if (name.isEmpty) return null;

    final entityType = _parseEntityType(
      json['entityType']?.toString() ?? '',
    );
    final role = _parseUserRole(
      json['role']?.toString() ?? '',
    );
    final branchType = _parseBranchType(
      json['branchType']?.toString(),
    );

    final subtitle = json['subtitle']?.toString() ??
        json['description']?.toString() ??
        _defaultSubtitle(entityType);

    return AppContextModel(
      id: id,
      name: name,
      subtitle: subtitle,
      entityType: entityType,
      role: role,
      branchType: branchType,
      driverType: role == UserRole.driver ? DriverType.shopDriver : null,
      avatarUrl: json['avatarUrl']?.toString(),
      presence: PresenceStatus.online,
    );
  }

  String _defaultSubtitle(EntityType type) {
    switch (type) {
      case EntityType.personal:
        return 'Personal Account';
      case EntityType.business:
        return 'Business Account';
      case EntityType.branch:
        return 'Branch';
    }
  }

  // ─── Enum Parsers ───────────────────────────────────────────────────────

  EntityType _parseEntityType(String value) {
    switch (value.toLowerCase()) {
      case 'personal':
        return EntityType.personal;
      case 'business':
        return EntityType.business;
      case 'branch':
        return EntityType.branch;
      default:
        return EntityType.personal;
    }
  }

  UserRole _parseUserRole(String value) {
    switch (value.toLowerCase()) {
      case 'owner':
        return UserRole.owner;
      case 'administrator':
        return UserRole.administrator;
      case 'branchmanager':
      case 'branch_manager':
        return UserRole.branchManager;
      case 'branchresponseofficer':
      case 'branch_response_officer':
        return UserRole.branchResponseOfficer;
      case 'branchmonitor':
      case 'branch_monitor':
        return UserRole.branchMonitor;
      case 'branchsocialofficer':
      case 'branch_social_officer':
        return UserRole.branchSocialOfficer;
      case 'driver':
        return UserRole.driver;
      case 'viewer':
        return UserRole.none;
      default:
        return UserRole.none;
    }
  }

  BranchType? _parseBranchType(String? value) {
    if (value == null || value.isEmpty) return null;
    switch (value.toLowerCase()) {
      case 'shop':
        return BranchType.shop;
      case 'logistics':
      case 'logisticsprovider':
      case 'logistics_provider':
        return BranchType.logisticsProvider;
      case 'transport':
      case 'transportprovider':
      case 'transport_provider':
        return BranchType.transportProvider;
      default:
        return null;
    }
  }

  // ─── Context Switching ──────────────────────────────────────────────────

  void switchContext(AppContextModel context) {
    _activeContext = context;
    notifyListeners();
  }

  void switchToContextById(String contextId) {
    final ctx = _availableContexts.firstWhere(
      (c) => c.id == contextId,
      orElse: () => _activeContext,
    );
    _activeContext = ctx;
    notifyListeners();
  }

  // ─── Presence ────────────────────────────────────────────────────────────

  void updatePresence(PresenceStatus status) {
    _activeContext = AppContextModel(
      id: _activeContext.id,
      name: _activeContext.name,
      subtitle: _activeContext.subtitle,
      entityType: _activeContext.entityType,
      role: _activeContext.role,
      branchType: _activeContext.branchType,
      driverType: _activeContext.driverType,
      avatarUrl: _activeContext.avatarUrl,
      presence: status,
    );
    notifyListeners();
  }

  // ─── Entity Management ──────────────────────────────────────────────────

  void addContext(AppContextModel context) {
    _availableContexts.add(context);
    notifyListeners();
  }

  void removeContext(String contextId) {
    _availableContexts.removeWhere((c) => c.id == contextId);
    if (_activeContext.id == contextId && _availableContexts.isNotEmpty) {
      _activeContext = _availableContexts.first;
    }
    notifyListeners();
  }

  // ─── Demo / Debug Helpers ─────────────────────────────────────────────

  /// Quick-switch to a role for testing RBAC
  void debugSetRole(UserRole role) {
    _activeContext = AppContextModel(
      id: _activeContext.id,
      name: _activeContext.name,
      subtitle: _activeContext.subtitle,
      entityType: role == UserRole.owner
          ? EntityType.personal
          : role == UserRole.administrator
              ? EntityType.business
              : role == UserRole.branchManager ||
                      role == UserRole.branchResponseOfficer ||
                      role == UserRole.branchMonitor ||
                      role == UserRole.branchSocialOfficer
                  ? EntityType.branch
                  : EntityType.business,
      role: role,
      branchType: _activeContext.branchType ?? BranchType.shop,
      driverType: role == UserRole.driver ? DriverType.shopDriver : null,
      avatarUrl: _activeContext.avatarUrl,
      presence: _activeContext.presence,
    );
    notifyListeners();
  }
}
