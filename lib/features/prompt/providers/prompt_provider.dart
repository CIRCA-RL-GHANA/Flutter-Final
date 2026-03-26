/// ═══════════════════════════════════════════════════════════════════════════
/// PROMPT Provider
/// Master state for the PROMPT screen: widget ordering, notifications,
/// search, time adaptation, widget data, layout persistence
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import '../../../core/services/services.dart';
import '../../../core/network/api_response.dart';
import '../models/rbac_models.dart';

class PromptProvider extends ChangeNotifier {
  // ─── Services ───────────────────────────────────────────────────────────
  final ProductService _productService;
  // ignore: unused_field
  final AIService _aiService;
  // ignore: unused_field
  final OrderService _orderService;

  PromptProvider({
    ProductService? productService,
    AIService? aiService,
    OrderService? orderService,
  })  : _productService = productService ?? ProductService(),
        _aiService = aiService ?? AIService(),
        _orderService = orderService ?? OrderService();

  // ─── Global Loading / Error State ───────────────────────────────────────
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // ─── Init ───────────────────────────────────────────────────────────────
  /// Call once when the screen mounts to bootstrap data.
  Future<void> init() async {
    await loadNotifications();
  }

  // ─── Notifications ──────────────────────────────────────────────────────
  bool _isNotificationsLoading = false;
  bool get isNotificationsLoading => _isNotificationsLoading;

  int _notificationCount = 3;
  int get notificationCount => _notificationCount;

  List<PromptNotification> _notifications = [];
  List<PromptNotification> get notifications => _notifications;

  /// Load notifications from the API.
  /// Falls back to [_fallbackNotifications] until a dedicated endpoint exists.
  Future<void> loadNotifications() async {
    _isNotificationsLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Production integration path:
      // 1. Inject NotificationService in constructor
      // 2. Get authenticated user ID: final userId = await _authService.getMe();
      // 3. Call: final response = await _notificationService.getUserNotifications(userId);
      // 4. Parse response and populate _notifications
      // For now, fallback to demo data until notifications API is ready
      _notifications = _fallbackNotifications();
      _notificationCount = _notifications.where((n) => !n.isRead).length;
    } catch (e) {
      debugPrint('PromptProvider.loadNotifications error: $e');
      _error = 'Failed to load notifications';
      // Ensure we always have something to display
      _notifications = _fallbackNotifications();
      _notificationCount = _notifications.where((n) => !n.isRead).length;
    } finally {
      _isNotificationsLoading = false;
      notifyListeners();
    }
  }

  /// Hardcoded fallback notifications used until a real API is wired.
  List<PromptNotification> _fallbackNotifications() {
    return [
      PromptNotification(
        id: '1',
        title: 'New order received',
        body: 'Order #ORD-2041 from Alice',
        time: DateTime.now().subtract(const Duration(minutes: 5)),
        type: NotificationType.order,
        isRead: false,
      ),
      PromptNotification(
        id: '2',
        title: 'QPoints received',
        body: '+500 QP from Bob via Transfer',
        time: DateTime.now().subtract(const Duration(hours: 1)),
        type: NotificationType.transaction,
        isRead: false,
      ),
      PromptNotification(
        id: '3',
        title: 'Alert resolved',
        body: 'Payment issue #TX-2041 resolved by Sarah',
        time: DateTime.now().subtract(const Duration(hours: 2)),
        type: NotificationType.alert,
        isRead: false,
      ),
    ];
  }

  void markNotificationRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      _notificationCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    }
  }

  void markAllNotificationsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _notificationCount = 0;
    notifyListeners();
  }

  // ─── Search ────────────────────────────────────────────────────────────
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  bool get isSearching => _searchQuery.isNotEmpty;

  List<SearchResult> _searchResults = [];
  List<SearchResult> get searchResults => _searchResults;
  bool _isSearchLoading = false;
  bool get isSearchLoading => _isSearchLoading;

  void updateSearch(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _searchResults = [];
      _isSearchLoading = false;
      notifyListeners();
      return;
    }
    _isSearchLoading = true;
    notifyListeners();

    _performSearch(query).then((results) {
      // Only apply if the query hasn't changed while we were awaiting
      if (_searchQuery == query) {
        _searchResults = results;
        _isSearchLoading = false;
        notifyListeners();
      }
    });
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _isSearchLoading = false;
    notifyListeners();
  }

  /// Searches products via [ProductService] and converts the API response
  /// into [SearchResult] objects. Falls back to local hardcoded logic on error.
  Future<List<SearchResult>> _performSearch(String query) async {
    try {
      final ApiResponse<List<Map<String, dynamic>>> response =
          await _productService.searchProducts(query);

      if (response.success && response.data != null && response.data!.isNotEmpty) {
        return response.data!.map((item) {
          return SearchResult(
            type: SearchResultType.product,
            title: (item['name'] as String?) ?? 'Product',
            subtitle: (item['description'] as String?) ??
                (item['category'] as String?) ??
                '',
            icon: 'inventory',
          );
        }).toList();
      }

      // API returned empty — fall through to local fallback
      return _fallbackSearch(query);
    } catch (e) {
      debugPrint('PromptProvider._performSearch error: $e');
      return _fallbackSearch(query);
    }
  }

  /// Local / hardcoded search results used as fallback when the API is
  /// unavailable or returns nothing.
  List<SearchResult> _fallbackSearch(String query) {
    final q = query.toLowerCase();
    final results = <SearchResult>[];

    // Simulated search across categories
    if ('qpoints transfer balance'.contains(q) || q.contains('qp')) {
      results.add(const SearchResult(
        type: SearchResultType.transaction,
        title: 'QPoints Balance',
        subtitle: '14,250 QP available',
        icon: 'account_balance_wallet',
      ));
    }
    if ('product item sku inventory'.contains(q)) {
      results.add(const SearchResult(
        type: SearchResultType.product,
        title: 'Product Search',
        subtitle: '1,245 products matching',
        icon: 'inventory',
      ));
    }
    if ('alice bob john sarah'.contains(q) || 'staff people contact'.contains(q)) {
      results.add(const SearchResult(
        type: SearchResultType.person,
        title: 'Alice Johnson',
        subtitle: 'Customer • Last order 2 days ago',
        icon: 'person',
      ));
    }
    if ('order delivery package'.contains(q)) {
      results.add(const SearchResult(
        type: SearchResultType.transaction,
        title: 'Order #ORD-2041',
        subtitle: 'In transit • ETA 15 min',
        icon: 'local_shipping',
      ));
    }
    if ('message chat'.contains(q)) {
      results.add(const SearchResult(
        type: SearchResultType.message,
        title: 'Chat with Sarah',
        subtitle: 'Last message: "Payment confirmed"',
        icon: 'chat_bubble',
      ));
    }
    if ('alert issue problem'.contains(q)) {
      results.add(const SearchResult(
        type: SearchResultType.alert,
        title: 'Alert #TX-2040',
        subtitle: 'Payment discrepancy • Pending',
        icon: 'warning',
      ));
    }

    return results;
  }

  // ─── Widget Layout / Ordering ─────────────────────────────────────────
  /// Custom module order (persisted per role via SharedPreferences in production)
  Map<UserRole, List<PromptModule>> _customOrders = {};

  List<PromptModule> getModuleOrder(UserRole role) {
    if (_customOrders.containsKey(role)) {
      return _customOrders[role]!;
    }
    // Default: priority-sorted visible modules
    final visible = WidgetVisibility.getVisibleModules(role);
    return PriorityEngine.sortByPriority(visible, getCurrentTimePeriod());
  }

  void reorderModules(UserRole role, List<PromptModule> newOrder) {
    _customOrders[role] = newOrder;
    notifyListeners();
  }

  // ─── Widget States ───────────────────────────────────────────────────
  final Map<PromptModule, ModuleWidgetState> _widgetStates = {};

  ModuleWidgetState getWidgetState(PromptModule module) =>
      _widgetStates[module] ?? ModuleWidgetState.normal;

  void setWidgetState(PromptModule module, ModuleWidgetState state) {
    _widgetStates[module] = state;
    notifyListeners();
  }

  // ─── Hidden Widgets ──────────────────────────────────────────────────
  final Set<PromptModule> _hiddenByUser = {};
  Set<PromptModule> get hiddenByUser => _hiddenByUser;

  void hideWidget(PromptModule module) {
    _hiddenByUser.add(module);
    notifyListeners();
  }

  void restoreWidget(PromptModule module) {
    _hiddenByUser.remove(module);
    notifyListeners();
  }

  void restoreAllWidgets() {
    _hiddenByUser.clear();
    notifyListeners();
  }

  // ─── Emergency SOS ──────────────────────────────────────────────────
  bool _sosActive = false;
  bool get sosActive => _sosActive;

  void triggerSOS() {
    _sosActive = true;
    notifyListeners();
    // In production: trigger emergency protocol, send alerts, log location
  }

  void cancelSOS() {
    _sosActive = false;
    notifyListeners();
  }

  // ─── Time-Based Adaptation ──────────────────────────────────────────
  TimePeriod get currentTimePeriod => getCurrentTimePeriod();

  String get timeGreeting {
    switch (currentTimePeriod) {
      case TimePeriod.morning:
        return 'Good morning';
      case TimePeriod.afternoon:
        return 'Good afternoon';
      case TimePeriod.evening:
        return 'Good evening';
      case TimePeriod.night:
        return 'Good night';
    }
  }

  String get timeEmoji {
    switch (currentTimePeriod) {
      case TimePeriod.morning:
        return '🌤️';
      case TimePeriod.afternoon:
        return '☀️';
      case TimePeriod.evening:
        return '🌙';
      case TimePeriod.night:
        return '🌙';
    }
  }
}

// ─── Data Models ──────────────────────────────────────────────────────────────

enum NotificationType { order, transaction, alert, social, system }

class PromptNotification {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final NotificationType type;
  final bool isRead;

  const PromptNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.isRead = false,
  });

  PromptNotification copyWith({bool? isRead}) {
    return PromptNotification(
      id: id,
      title: title,
      body: body,
      time: time,
      type: type,
      isRead: isRead ?? this.isRead,
    );
  }
}

enum SearchResultType { product, person, transaction, message, alert }

class SearchResult {
  final SearchResultType type;
  final String title;
  final String subtitle;
  final String icon;

  const SearchResult({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

/// Widget display states
enum ModuleWidgetState {
  normal,   // Full opacity, interactive
  viewOnly, // 40% opacity, no edit
  disabled, // Grayed out, "Upgrade required" tooltip
  loading,  // Skeleton shimmer
  error,    // Red border with retry
  empty,    // Illustrative empty state
}
