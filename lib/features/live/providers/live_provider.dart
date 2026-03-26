/// ═══════════════════════════════════════════════════════════════════════════
/// LIVE MODULE — Provider (State Management)
/// Orders, packages, returns, drivers, rides, analytics, incidents,
/// emergency, settings, verification — real API with fallback demo data
///
/// Migrated from hardcoded demo data to real API calls with fallback.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../models/live_models.dart';
import '../../../core/services/services.dart';

class LiveProvider extends ChangeNotifier {
  // ═══════════════════════════════════════════════════════════════════════════
  // SERVICES
  // ═══════════════════════════════════════════════════════════════════════════

  final OrderService _orderService = OrderService();
  final RideService _rideService = RideService();
  // ignore: unused_field
  final VehicleService _vehicleService = VehicleService();

  // ═══════════════════════════════════════════════════════════════════════════
  // LOADING / ERROR STATE
  // ═══════════════════════════════════════════════════════════════════════════

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _ordersLoading = false;
  bool get ordersLoading => _ordersLoading;

  bool _driversLoading = false;
  bool get driversLoading => _driversLoading;

  bool _packagesLoading = false;
  bool get packagesLoading => _packagesLoading;

  bool _returnsLoading = false;
  bool get returnsLoading => _returnsLoading;

  bool _ridesLoading = false;
  bool get ridesLoading => _ridesLoading;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INIT — Load everything on startup
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      loadOrders(),
      loadDrivers(),
      loadPackages(),
      loadReturns(),
      loadRides(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  /// Get current authenticated user ID from auth service
  /// Returns the user ID from JWT token context or fallback ID
  Future<String> _getCurrentUserId() async {
    try {
      final authService = AuthService();
      final response = await authService.getMe();
      if (response.success && response.data != null) {
        final userId = response.data!['id']?.toString();
        if (userId != null && userId.isNotEmpty) {
          return userId;
        }
      }
    } catch (e) {
      debugPrint('LiveProvider: Failed to get user ID: $e');
    }
    // Fallback ID when auth context unavailable (use 'me' which backend resolves)
    return 'me';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 1: DASHBOARD STATE (client-side only)
  // ═══════════════════════════════════════════════════════════════════════════

  LiveDashboardTab _dashboardTab = LiveDashboardTab.orders;
  LiveDashboardTab get dashboardTab => _dashboardTab;

  void setDashboardTab(LiveDashboardTab tab) {
    _dashboardTab = tab;
    notifyListeners();
  }

  OrderSubTab _orderSubTab = OrderSubTab.newOrders;
  OrderSubTab get orderSubTab => _orderSubTab;

  void setOrderSubTab(OrderSubTab tab) {
    _orderSubTab = tab;
    notifyListeners();
  }

  ReturnSubTab _returnSubTab = ReturnSubTab.pending;
  ReturnSubTab get returnSubTab => _returnSubTab;

  void setReturnSubTab(ReturnSubTab tab) {
    _returnSubTab = tab;
    notifyListeners();
  }

  PackageSubTab _packageSubTab = PackageSubTab.active;
  PackageSubTab get packageSubTab => _packageSubTab;

  void setPackageSubTab(PackageSubTab tab) {
    _packageSubTab = tab;
    notifyListeners();
  }

  LiveWidgetState _widgetState = LiveWidgetState.activeOperations;
  LiveWidgetState get widgetState => _widgetState;

  void setWidgetState(LiveWidgetState state) {
    _widgetState = state;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 2: ORDERS
  // ═══════════════════════════════════════════════════════════════════════════

  List<LiveOrder> _orders = [];

  LiveOrder? _selectedOrder;
  LiveOrder? get selectedOrder => _selectedOrder;

  void selectOrder(String id) {
    _selectedOrder = _orders.firstWhere(
      (o) => o.id == id,
      orElse: () => _orders.first,
    );
    notifyListeners();
  }

  List<LiveOrder> get orders => _orders;

  List<LiveOrder> get newOrders =>
      _orders.where((o) => o.status == LiveOrderStatus.newOrder).toList();

  List<LiveOrder> get inProgressOrders =>
      _orders.where((o) =>
        o.status == LiveOrderStatus.assigned ||
        o.status == LiveOrderStatus.preparing).toList();

  List<LiveOrder> get readyOrders =>
      _orders.where((o) => o.status == LiveOrderStatus.readyForPickup).toList();

  List<LiveOrder> get urgentActions =>
      _orders.where((o) => o.priority == OrderPriority.urgent || o.isOverdue).toList();

  int get activeOrderCount =>
      _orders.where((o) =>
        o.status != LiveOrderStatus.delivered &&
        o.status != LiveOrderStatus.cancelled).length;

  /// Assign a driver to an order via API.
  Future<void> assignDriver(String orderId, String driverId) async {
    try {
      final response = await _orderService.updateOrderStatus(
        id: orderId,
        status: 'assigned',
        notes: 'Assigned to driver $driverId',
      );
      if (response.success) {
        await loadOrders();
      } else {
        _error = response.message ?? 'Failed to assign driver';
      }
    } catch (e) {
      debugPrint('LiveProvider.assignDriver error: $e');
      _error = 'Failed to assign driver';
    }
    notifyListeners();
  }

  void markSelfPickup(String orderId) {
    // In production: update order to selfPickup via API
    notifyListeners();
  }

  void holdOrder(String orderId) {
    // In production: update order to held via API
    notifyListeners();
  }

  /// Cancel an order via API.
  Future<void> cancelOrder(String orderId) async {
    try {
      final response = await _orderService.updateOrderStatus(
        id: orderId,
        status: 'cancelled',
      );
      if (response.success) {
        await loadOrders();
      } else {
        _error = response.message ?? 'Failed to cancel order';
      }
    } catch (e) {
      debugPrint('LiveProvider.cancelOrder error: $e');
      _error = 'Failed to cancel order';
    }
    notifyListeners();
  }

  /// Load orders from API. Falls back to demo data on error.
  Future<void> loadOrders() async {
    _ordersLoading = true;
    notifyListeners();

    try {
      final userId = await _getCurrentUserId();
      final response = await _orderService.getUserOrders(userId: userId, limit: 50);
      if (response.success && response.data != null && response.data!.isNotEmpty) {
        _orders = response.data!.map((json) => _orderFromJson(json)).toList();
      } else {
        _orders = _fallbackOrders;
      }
    } catch (e) {
      debugPrint('LiveProvider.loadOrders error: $e');
      _orders = _fallbackOrders;
    }

    _ordersLoading = false;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 3: DRIVERS
  // ═══════════════════════════════════════════════════════════════════════════

  List<LiveDriver> _drivers = [];

  LiveDriver? _selectedDriver;
  LiveDriver? get selectedDriver => _selectedDriver;

  void selectDriver(String id) {
    _selectedDriver = _drivers.firstWhere(
      (d) => d.id == id,
      orElse: () => _drivers.first,
    );
    notifyListeners();
  }

  List<LiveDriver> get drivers => _drivers;

  List<LiveDriver> get availableDrivers =>
      _drivers.where((d) => d.availability == DriverAvailability.online).toList();

  List<LiveDriver> get shopDrivers =>
      _drivers.where((d) => d.driverType == LiveDriverType.shopLogistics).toList();

  List<LiveDriver> get transportDrivers =>
      _drivers.where((d) => d.driverType == LiveDriverType.transport).toList();

  DriverAvailability _driverAvailability = DriverAvailability.online;
  DriverAvailability get driverAvailability => _driverAvailability;

  void setDriverAvailability(DriverAvailability avail) {
    _driverAvailability = avail;
    notifyListeners();
  }

  /// Load drivers. No backend driver-list endpoint yet — uses fallback.
  Future<void> loadDrivers() async {
    _driversLoading = true;
    notifyListeners();

    try {
      // No dedicated driver-list endpoint yet; use fallback
      _drivers = _fallbackDrivers;
    } catch (e) {
      debugPrint('LiveProvider.loadDrivers error: $e');
      _drivers = _fallbackDrivers;
    }

    _driversLoading = false;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 4: PACKAGES
  // ═══════════════════════════════════════════════════════════════════════════

  List<LivePackage> _packages = [];

  LivePackage? _selectedPackage;
  LivePackage? get selectedPackage => _selectedPackage;

  void selectPackage(String id) {
    _selectedPackage = _packages.firstWhere(
      (p) => p.id == id,
      orElse: () => _packages.first,
    );
    notifyListeners();
  }

  List<LivePackage> get packages => _packages;

  List<LivePackage> get activePackages =>
      _packages.where((p) => p.status == PackageStatus.active).toList();

  List<LivePackage> get inTransitPackages =>
      _packages.where((p) => p.status == PackageStatus.inTransit).toList();

  List<LivePackage> get deliveredPackages =>
      _packages.where((p) => p.status == PackageStatus.delivered).toList();

  int get activePackageCount => activePackages.length + inTransitPackages.length;

  /// Load packages. No backend package endpoint yet — uses fallback.
  Future<void> loadPackages() async {
    _packagesLoading = true;
    notifyListeners();

    try {
      // No dedicated package endpoint yet; use fallback
      _packages = _fallbackPackages;
    } catch (e) {
      debugPrint('LiveProvider.loadPackages error: $e');
      _packages = _fallbackPackages;
    }

    _packagesLoading = false;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 5: RETURNS
  // ═══════════════════════════════════════════════════════════════════════════

  List<LiveReturn> _returns = [];

  LiveReturn? _selectedReturn;
  LiveReturn? get selectedReturn => _selectedReturn;

  void selectReturn(String id) {
    _selectedReturn = _returns.firstWhere(
      (r) => r.id == id,
      orElse: () => _returns.first,
    );
    notifyListeners();
  }

  List<LiveReturn> get returns => _returns;

  List<LiveReturn> get pendingReturns =>
      _returns.where((r) => r.status == LiveReturnStatus.pending).toList();

  List<LiveReturn> get underReviewReturns =>
      _returns.where((r) => r.status == LiveReturnStatus.underReview).toList();

  List<LiveReturn> get resolvedReturns =>
      _returns.where((r) =>
        r.status == LiveReturnStatus.approved ||
        r.status == LiveReturnStatus.rejected ||
        r.status == LiveReturnStatus.partiallyApproved).toList();

  int get activeReturnCount => pendingReturns.length + underReviewReturns.length;

  /// Approve a return via API.
  Future<void> approveReturn(String id) async {
    try {
      final ret = _returns.firstWhere((r) => r.id == id);
      final response = await _orderService.createReturnRequest(
        orderId: ret.originalOrderId,
        reason: 'approved',
        items: [{'returnId': id, 'action': 'approve'}],
      );
      if (response.success) {
        await loadReturns();
      } else {
        _error = response.message ?? 'Failed to approve return';
      }
    } catch (e) {
      debugPrint('LiveProvider.approveReturn error: $e');
      _error = 'Failed to approve return';
    }
    notifyListeners();
  }

  /// Reject a return via API.
  Future<void> rejectReturn(String id, RejectionReason reason, String notes) async {
    try {
      final ret = _returns.firstWhere((r) => r.id == id);
      final response = await _orderService.createReturnRequest(
        orderId: ret.originalOrderId,
        reason: 'rejected:${reason.name}',
        items: [{'returnId': id, 'action': 'reject', 'notes': notes}],
      );
      if (response.success) {
        await loadReturns();
      } else {
        _error = response.message ?? 'Failed to reject return';
      }
    } catch (e) {
      debugPrint('LiveProvider.rejectReturn error: $e');
      _error = 'Failed to reject return';
    }
    notifyListeners();
  }

  /// Load returns from API. Falls back to demo data on error.
  Future<void> loadReturns() async {
    _returnsLoading = true;
    notifyListeners();

    try {
      final userId = await _getCurrentUserId();
      final response = await _orderService.getReturnRequests(userId);
      if (response.success && response.data != null && response.data!.isNotEmpty) {
        _returns = response.data!.map((json) => _returnFromJson(json)).toList();
      } else {
        _returns = _fallbackReturns;
      }
    } catch (e) {
      debugPrint('LiveProvider.loadReturns error: $e');
      _returns = _fallbackReturns;
    }

    _returnsLoading = false;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 6: RIDES (TRANSPORT)
  // ═══════════════════════════════════════════════════════════════════════════

  List<LiveRide> _rides = [];

  LiveRide? _activeRide;
  LiveRide? get activeRide => _activeRide;

  void selectRide(String id) {
    _activeRide = _rides.firstWhere(
      (r) => r.id == id,
      orElse: () => _rides.first,
    );
    notifyListeners();
  }

  List<LiveRide> get rides => _rides;

  List<LiveRide> get availableRides =>
      _rides.where((r) => r.status == LiveRideStatus.available).toList();

  TransportEarnings get transportEarnings => const TransportEarnings();

  /// Load rides from API. Falls back to demo data on error.
  Future<void> loadRides() async {
    _ridesLoading = true;
    notifyListeners();

    try {
      final userId = await _getCurrentUserId();
      final response = await _rideService.getUserRides(userId: userId, limit: 50);
      if (response.success && response.data != null && response.data!.isNotEmpty) {
        _rides = response.data!.map((json) => _rideFromJson(json)).toList();
      } else {
        _rides = _fallbackRides;
      }
    } catch (e) {
      debugPrint('LiveProvider.loadRides error: $e');
      _rides = _fallbackRides;
    }

    _ridesLoading = false;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 7: ANALYTICS (client-side)
  // ═══════════════════════════════════════════════════════════════════════════

  AnalyticsPeriod _analyticsPeriod = AnalyticsPeriod.today;
  AnalyticsPeriod get analyticsPeriod => _analyticsPeriod;

  void setAnalyticsPeriod(AnalyticsPeriod period) {
    _analyticsPeriod = period;
    notifyListeners();
  }

  OperationsMetrics get metrics => const OperationsMetrics();

  List<PredictiveInsight> get insights => _fallbackInsights;

  List<UrgentAction> get urgentActionItems => _fallbackUrgentActions;

  List<DeliveryZone> get deliveryZones => _fallbackDeliveryZones;

  List<BottleneckAlert> get bottlenecks => _fallbackBottlenecks;

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 8: INCIDENTS & EMERGENCY
  // ═══════════════════════════════════════════════════════════════════════════

  bool _sosTriggered = false;
  bool get sosTriggered => _sosTriggered;

  /// Trigger SOS via API (attempts ride status update, falls back to local).
  Future<void> triggerSOS() async {
    _sosTriggered = true;
    notifyListeners();

    try {
      // Attempt to notify backend via ride status update if there's an active ride
      if (_activeRide != null) {
        await _rideService.updateRideStatus(
          rideId: _activeRide!.id,
          status: 'emergency',
        );
      }
    } catch (e) {
      debugPrint('LiveProvider.triggerSOS error: $e');
      // SOS is already triggered locally — graceful degradation
    }
  }

  void cancelSOS() {
    _sosTriggered = false;
    notifyListeners();
  }

  List<EmergencyContact> get emergencyContacts => _fallbackEmergencyContacts;

  List<LiveNotification> get notifications => _fallbackNotifications;

  int get unreadNotificationCount =>
      _fallbackNotifications.where((n) => !n.isRead).length;

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 9: SETTINGS (client-side)
  // ═══════════════════════════════════════════════════════════════════════════

  LiveSettings _settings = const LiveSettings();
  LiveSettings get settings => _settings;

  void updateSettings(LiveSettings newSettings) {
    _settings = newSettings;
    notifyListeners();
  }

  void resetSettings() {
    _settings = const LiveSettings();
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 10: VERIFICATION (client-side)
  // ═══════════════════════════════════════════════════════════════════════════

  bool _verificationComplete = false;
  bool get verificationComplete => _verificationComplete;

  void completeVerification() {
    _verificationComplete = true;
    notifyListeners();
  }

  void resetVerification() {
    _verificationComplete = false;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // JSON → MODEL PARSERS
  // ═══════════════════════════════════════════════════════════════════════════

  LiveOrder _orderFromJson(Map<String, dynamic> json) {
    return LiveOrder(
      id: json['id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      customerPhone: json['customerPhone']?.toString() ?? '',
      customerEmail: json['customerEmail']?.toString() ?? '',
      customerCompany: json['customerCompany']?.toString() ?? '',
      customerRating: _toDouble(json['customerRating']),
      customerOrderCount: _toInt(json['customerOrderCount']),
      deliveryAddress: json['deliveryAddress']?.toString() ?? '',
      deliveryFloor: json['deliveryFloor']?.toString() ?? '',
      deliveryReception: json['deliveryReception']?.toString() ?? '',
      accessCode: json['accessCode']?.toString() ?? '',
      parkingNote: json['parkingNote']?.toString() ?? '',
      items: _orderItemsFromJson(json['items']),
      subtotal: _toDouble(json['subtotal']),
      total: _toDouble(json['total']),
      status: _parseLiveOrderStatus(json['status']?.toString()),
      priority: _parseOrderPriority(json['priority']?.toString()),
      customerNote: json['customerNote']?.toString() ?? '',
      assignedDriverId: json['assignedDriverId']?.toString() ?? '',
      assignedDriverName: json['assignedDriverName']?.toString() ?? '',
      driverDistanceMiles: _toDouble(json['driverDistanceMiles']),
      driverEtaMinutes: _toInt(json['driverEtaMinutes']),
      prepTimeMinutes: _toInt(json['prepTimeMinutes']),
      deliveryTimeMinutes: _toInt(json['deliveryTimeMinutes']),
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      preparationProgress: _toDouble(json['preparationProgress']),
      requiresIdVerification: json['requiresIdVerification'] == true,
      requiresColdStorage: json['requiresColdStorage'] == true,
      isFragile: json['isFragile'] == true,
      timeline: _timelineFromJson(json['timeline']),
    );
  }

  List<OrderItem> _orderItemsFromJson(dynamic value) {
    if (value == null || value is! List) return [];
    return value.map((item) {
      final json = item as Map<String, dynamic>;
      return OrderItem(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        sku: json['sku']?.toString() ?? '',
        serialNumber: json['serialNumber']?.toString() ?? '',
        stockLocation: json['stockLocation']?.toString() ?? '',
        price: _toDouble(json['price']),
        quantity: _toInt(json['quantity'], fallback: 1),
      );
    }).toList();
  }

  List<OrderTimelineEntry> _timelineFromJson(dynamic value) {
    if (value == null || value is! List) return [];
    return value.map((item) {
      final json = item as Map<String, dynamic>;
      return OrderTimelineEntry(
        title: json['title']?.toString() ?? '',
        timestamp: _parseDateTime(json['timestamp']) ?? DateTime.now(),
      );
    }).toList();
  }

  LiveReturn _returnFromJson(Map<String, dynamic> json) {
    return LiveReturn(
      id: json['id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      customerRating: _toDouble(json['customerRating']),
      customerReturnCount: _toInt(json['customerReturnCount']),
      customerTotalOrders: _toInt(json['customerTotalOrders']),
      customerLifetimeValue: _toDouble(json['customerLifetimeValue']),
      originalOrderId: json['originalOrderId']?.toString() ?? '',
      daysSincePurchase: _toInt(json['daysSincePurchase']),
      itemName: json['itemName']?.toString() ?? '',
      itemModel: json['itemModel']?.toString() ?? '',
      serialNumber: json['serialNumber']?.toString() ?? '',
      itemPrice: _toDouble(json['itemPrice']),
      restockingFee: _toDouble(json['restockingFee']),
      reason: json['reason']?.toString() ?? '',
      reasonDetail: json['reasonDetail']?.toString() ?? '',
      status: _parseLiveReturnStatus(json['status']?.toString()),
      reviewerName: json['reviewerName']?.toString() ?? '',
      reviewStartedAt: _parseDateTime(json['reviewStartedAt']),
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      usageDays: _toInt(json['usageDays']),
    );
  }

  LiveRide _rideFromJson(Map<String, dynamic> json) {
    return LiveRide(
      id: json['id']?.toString() ?? '',
      passengerName: json['passengerName']?.toString() ?? '',
      passengerRating: _toDouble(json['passengerRating']),
      passengerRideCount: _toInt(json['passengerRideCount']),
      pickupAddress: json['pickupAddress']?.toString() ??
          json['pickupLocation']?['address']?.toString() ?? '',
      dropoffAddress: json['dropoffAddress']?.toString() ??
          json['dropoffLocation']?['address']?.toString() ?? '',
      distanceKm: _toDouble(json['distanceKm']),
      fare: _toDouble(json['fare'] ?? json['estimatedFare']),
      surgeMultiplier: _toDouble(json['surgeMultiplier'], fallback: 1.0),
      etaMinutes: _toInt(json['etaMinutes']),
      status: _parseLiveRideStatus(json['status']?.toString()),
      specialRequest: json['specialRequest']?.toString() ?? '',
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      baseFare: _toDouble(json['baseFare']),
      distanceCharge: _toDouble(json['distanceCharge']),
      timeCharge: _toDouble(json['timeCharge']),
      surgeCharge: _toDouble(json['surgeCharge']),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ENUM PARSERS
  // ═══════════════════════════════════════════════════════════════════════════

  LiveOrderStatus _parseLiveOrderStatus(String? value) {
    switch (value) {
      case 'newOrder': return LiveOrderStatus.newOrder;
      case 'assigned': return LiveOrderStatus.assigned;
      case 'preparing': return LiveOrderStatus.preparing;
      case 'readyForPickup': return LiveOrderStatus.readyForPickup;
      case 'inTransit': return LiveOrderStatus.inTransit;
      case 'delivered': return LiveOrderStatus.delivered;
      case 'selfPickup': return LiveOrderStatus.selfPickup;
      case 'held': return LiveOrderStatus.held;
      case 'cancelled': return LiveOrderStatus.cancelled;
      case 'overdue': return LiveOrderStatus.overdue;
      default: return LiveOrderStatus.newOrder;
    }
  }

  OrderPriority _parseOrderPriority(String? value) {
    switch (value) {
      case 'urgent': return OrderPriority.urgent;
      case 'normal': return OrderPriority.normal;
      case 'flexible': return OrderPriority.flexible;
      case 'scheduled': return OrderPriority.scheduled;
      default: return OrderPriority.normal;
    }
  }

  LiveReturnStatus _parseLiveReturnStatus(String? value) {
    switch (value) {
      case 'pending': return LiveReturnStatus.pending;
      case 'underReview': return LiveReturnStatus.underReview;
      case 'approved': return LiveReturnStatus.approved;
      case 'partiallyApproved': return LiveReturnStatus.partiallyApproved;
      case 'rejected': return LiveReturnStatus.rejected;
      case 'escalated': return LiveReturnStatus.escalated;
      default: return LiveReturnStatus.pending;
    }
  }

  LiveRideStatus _parseLiveRideStatus(String? value) {
    switch (value) {
      case 'available': return LiveRideStatus.available;
      case 'accepted': return LiveRideStatus.accepted;
      case 'pickingUp': return LiveRideStatus.pickingUp;
      case 'arrived': return LiveRideStatus.arrived;
      case 'inProgress': return LiveRideStatus.inProgress;
      case 'completed': return LiveRideStatus.completed;
      case 'cancelled': return LiveRideStatus.cancelled;
      default: return LiveRideStatus.available;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PARSING UTILITIES
  // ═══════════════════════════════════════════════════════════════════════════

  double _toDouble(dynamic value, {double fallback = 0.0}) {
    if (value == null) return fallback;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  // ignore: unused_element
  List<String> _toStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FALLBACK DATA — used when API is unavailable (graceful offline mode)
  // ═══════════════════════════════════════════════════════════════════════════

  final List<LiveOrder> _fallbackOrders = [
    LiveOrder(
      id: '1298',
      customerId: 'C001',
      customerName: 'Michael Chen',
      customerPhone: '+233 24 123 4567',
      customerEmail: 'michael@email.com',
      customerCompany: 'TechCorp',
      customerRating: 4.8,
      customerOrderCount: 14,
      deliveryAddress: '123 Business District, Accra',
      deliveryFloor: '5',
      deliveryReception: 'Jane',
      accessCode: '#1234*',
      parkingNote: 'Visitor lot, 30min max',
      items: const [
        OrderItem(id: 'I1', name: 'MacBook Pro 16"', sku: 'MPXK3LL/A', serialNumber: 'MPXK3LL/A', stockLocation: 'Shelf A4', price: 5299.0),
        OrderItem(id: 'I2', name: 'USB-C Cable', sku: 'ACC-USB-C', stockLocation: 'Drawer B2', price: 29.0),
      ],
      subtotal: 5328.0,
      total: 5343.0,
      status: LiveOrderStatus.newOrder,
      priority: OrderPriority.urgent,
      customerNote: 'Leave with reception, 5th floor',
      prepTimeMinutes: 8,
      deliveryTimeMinutes: 12,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      preparationProgress: 0.85,
      requiresIdVerification: true,
      isFragile: true,
      timeline: [
        OrderTimelineEntry(title: 'Order received', timestamp: DateTime.now().subtract(const Duration(minutes: 15))),
        OrderTimelineEntry(title: 'Payment confirmed', timestamp: DateTime.now().subtract(const Duration(minutes: 13))),
        OrderTimelineEntry(title: 'Inventory check started', timestamp: DateTime.now().subtract(const Duration(minutes: 10))),
        OrderTimelineEntry(title: 'Items gathered (2/2)', timestamp: DateTime.now().subtract(const Duration(minutes: 3))),
      ],
    ),
    LiveOrder(
      id: '1297',
      customerId: 'C002',
      customerName: 'Sarah Johnson',
      customerPhone: '+233 24 234 5678',
      customerRating: 4.6,
      customerOrderCount: 8,
      deliveryAddress: '45 Residential Ave, Accra',
      items: const [
        OrderItem(id: 'I3', name: 'Groceries Bundle', price: 89.50, quantity: 12),
      ],
      subtotal: 89.50,
      total: 104.50,
      status: LiveOrderStatus.assigned,
      priority: OrderPriority.normal,
      assignedDriverId: 'D001',
      assignedDriverName: 'James Wilson',
      driverDistanceMiles: 1.2,
      driverEtaMinutes: 4,
      createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      requiresColdStorage: true,
      preparationProgress: 0.4,
      timeline: [
        OrderTimelineEntry(title: 'Order received', timestamp: DateTime.now().subtract(const Duration(minutes: 2))),
        OrderTimelineEntry(title: 'Payment confirmed', timestamp: DateTime.now().subtract(const Duration(minutes: 1))),
      ],
    ),
    LiveOrder(
      id: '1296',
      customerId: 'C003',
      customerName: 'David Kwame',
      customerPhone: '+233 24 345 6789',
      customerRating: 4.2,
      customerOrderCount: 3,
      deliveryAddress: '78 Industrial Area, Accra',
      items: const [
        OrderItem(id: 'I4', name: 'Phone Case', price: 25.0),
        OrderItem(id: 'I5', name: 'Screen Protector', price: 15.0),
      ],
      subtotal: 40.0,
      total: 55.0,
      status: LiveOrderStatus.readyForPickup,
      priority: OrderPriority.flexible,
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      preparationProgress: 1.0,
      timeline: [
        OrderTimelineEntry(title: 'Order received', timestamp: DateTime.now().subtract(const Duration(minutes: 45))),
        OrderTimelineEntry(title: 'Payment confirmed', timestamp: DateTime.now().subtract(const Duration(minutes: 44))),
        OrderTimelineEntry(title: 'Preparation complete', timestamp: DateTime.now().subtract(const Duration(minutes: 10))),
      ],
    ),
    LiveOrder(
      id: '1300',
      customerId: 'C004',
      customerName: 'Lisa Prah',
      customerRating: 4.9,
      customerOrderCount: 22,
      deliveryAddress: '130 Business District, Accra',
      items: const [
        OrderItem(id: 'I6', name: 'Wireless Mouse', price: 45.0),
      ],
      subtotal: 45.0,
      total: 60.0,
      status: LiveOrderStatus.newOrder,
      priority: OrderPriority.normal,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      preparationProgress: 0.0,
      timeline: [
        OrderTimelineEntry(title: 'Order received', timestamp: DateTime.now().subtract(const Duration(minutes: 5))),
      ],
    ),
    LiveOrder(
      id: '1299',
      customerId: 'C005',
      customerName: 'Alex Kufuor',
      customerRating: 4.0,
      customerOrderCount: 2,
      deliveryAddress: '210 Residential North, Accra',
      items: const [
        OrderItem(id: 'I7', name: 'Bluetooth Speaker', price: 150.0),
        OrderItem(id: 'I8', name: 'AUX Cable', price: 8.0),
      ],
      subtotal: 158.0,
      total: 173.0,
      status: LiveOrderStatus.preparing,
      priority: OrderPriority.normal,
      assignedDriverId: 'D002',
      assignedDriverName: 'Sarah Chen',
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
      preparationProgress: 0.6,
      timeline: [
        OrderTimelineEntry(title: 'Order received', timestamp: DateTime.now().subtract(const Duration(minutes: 20))),
        OrderTimelineEntry(title: 'Payment confirmed', timestamp: DateTime.now().subtract(const Duration(minutes: 19))),
        OrderTimelineEntry(title: 'Driver assigned', timestamp: DateTime.now().subtract(const Duration(minutes: 12))),
      ],
    ),
  ];

  final List<LiveDriver> _fallbackDrivers = [
    LiveDriver(
      id: 'D001',
      name: 'James Wilson',
      rating: 4.9,
      completionRate: 0.98,
      distanceMiles: 0.8,
      etaToStoreMinutes: 4,
      etaToCustomerMinutes: 16,
      specialties: const ['Electronics', 'Business deliveries'],
      availability: DriverAvailability.online,
      driverType: LiveDriverType.shopLogistics,
      todayDeliveries: 8,
      todayCompletedDeliveries: 4,
      todayStopsCompleted: 12,
      todayTotalStops: 24,
      todayEarnings: 186.40,
      efficiencyBonus: 12.50,
      ratingImpact: 0.1,
      onTimeRate: 0.98,
      totalDeliveries: 284,
      averageDeliveryTime: 16.0,
      distanceEfficiency: 0.94,
      totalEarnings: 2845.0,
      completedTrainingModules: 4,
      totalTrainingModules: 4,
      activePackageId: 'P-901',
      badges: const [
        DriverBadge(name: 'Speed Master', description: '50+ on-time deliveries', icon: Icons.flash_on, color: Color(0xFFFFD700)),
        DriverBadge(name: 'Quality Expert', description: '4.8+ rating for 2 weeks', icon: Icons.diamond, color: Color(0xFF3B82F6)),
        DriverBadge(name: 'Bundle Pro', description: '20+ multi-stop packages', icon: Icons.inventory_2, color: Color(0xFF10B981)),
        DriverBadge(name: 'Security Star', description: '100% verification rate', icon: Icons.shield, color: Color(0xFF8B5CF6)),
      ],
      recentFeedback: [
        DriverFeedback(customerName: 'Sarah', comment: 'James was punctual and professional!', rating: 5.0, date: DateTime(2026, 2, 7)),
        DriverFeedback(customerName: 'Michael', comment: 'Very careful with fragile items', rating: 5.0, date: DateTime(2026, 2, 6)),
        DriverFeedback(customerName: 'Lisa', comment: 'Went above and beyond to help', rating: 5.0, date: DateTime(2026, 2, 5)),
      ],
    ),
    LiveDriver(
      id: 'D002',
      name: 'Sarah Chen',
      rating: 4.7,
      completionRate: 0.94,
      distanceMiles: 1.2,
      etaToStoreMinutes: 6,
      etaToCustomerMinutes: 18,
      specialties: const ['Groceries', 'Residential'],
      availability: DriverAvailability.online,
      driverType: LiveDriverType.shopLogistics,
      todayDeliveries: 6,
      todayCompletedDeliveries: 4,
      todayEarnings: 142.20,
      onTimeRate: 0.94,
      totalDeliveries: 198,
      totalEarnings: 1920.0,
      badges: const [
        DriverBadge(name: 'Speed Master', description: '50+ on-time deliveries', icon: Icons.flash_on, color: Color(0xFFFFD700)),
      ],
      recentFeedback: [
        DriverFeedback(customerName: 'David', comment: 'Always on time!', rating: 4.5, date: DateTime(2026, 2, 7)),
      ],
    ),
    const LiveDriver(
      id: 'D003',
      name: 'Kwame Boateng',
      rating: 4.5,
      completionRate: 0.89,
      distanceMiles: 0.5,
      etaToStoreMinutes: 3,
      etaToCustomerMinutes: 14,
      specialties: ['General'],
      availability: DriverAvailability.online,
      driverType: LiveDriverType.shopLogistics,
      todayDeliveries: 5,
      todayCompletedDeliveries: 3,
      todayEarnings: 98.50,
      onTimeRate: 0.89,
      totalDeliveries: 122,
      totalEarnings: 1245.0,
    ),
    LiveDriver(
      id: 'D004',
      name: 'Alex Brown',
      rating: 4.8,
      completionRate: 0.96,
      distanceMiles: 1.5,
      etaToStoreMinutes: 8,
      etaToCustomerMinutes: 20,
      specialties: const ['Airport', 'Long distance'],
      availability: DriverAvailability.online,
      driverType: LiveDriverType.transport,
      todayDeliveries: 7,
      todayCompletedDeliveries: 7,
      todayEarnings: 242.90,
      onTimeRate: 0.96,
      totalDeliveries: 340,
      totalEarnings: 4250.0,
      onlineTime: const Duration(hours: 4, minutes: 15),
      badges: const [
        DriverBadge(name: 'Road Warrior', description: '300+ rides completed', icon: Icons.directions_car, color: Color(0xFFFFD700)),
        DriverBadge(name: 'Top Rated', description: '4.8+ avg rating', icon: Icons.star, color: Color(0xFFF59E0B)),
      ],
    ),
    const LiveDriver(
      id: 'D005',
      name: 'Grace Mensah',
      rating: 4.3,
      distanceMiles: 2.0,
      availability: DriverAvailability.offline,
      driverType: LiveDriverType.shopLogistics,
      totalDeliveries: 65,
      totalEarnings: 680.0,
    ),
  ];

  final List<LivePackage> _fallbackPackages = [
    LivePackage(
      id: 'P-901',
      driverId: 'D001',
      driverName: 'James Wilson',
      driverRating: 4.9,
      status: PackageStatus.active,
      type: PackageType.highValue,
      completedStops: 1,
      totalDistanceMiles: 4.8,
      estimatedTimeMinutes: 32,
      driverEarnings: 43.50,
      priorityBonus: 4.35,
      biometricRequired: true,
      pinRequired: true,
      fallbackPin: '482931',
      signatureRequired: true,
      photoRequired: true,
      recordHandoff: true,
      insuranceCoverage: 5500.0,
      highValueItems: true,
      createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
      stops: [
        PackageStop(
          id: 'S1', sequence: 1, type: StopType.delivery, status: StopStatus.completed,
          address: '123 Business District', customerName: 'Michael Chen',
          orderId: '1298', itemDescription: 'MacBook Pro, USB-C Cable',
          distanceMiles: 1.8, etaMinutes: 12, idVerificationRequired: true,
          signatureRequired: true, photoRequired: true,
          completedAt: DateTime(2026, 2, 8, 12, 4),
          evidenceUrls: ['evidence_1.jpg', 'evidence_2.jpg'],
        ),
        PackageStop(
          id: 'S2', sequence: 2, type: StopType.returnPickup, status: StopStatus.inProgress,
          address: '125 Business District', customerName: 'Sarah M.',
          returnId: '567', itemDescription: 'Wireless Headphones (Defective)',
          distanceMiles: 0.4, etaMinutes: 4, photoRequired: true,
        ),
        PackageStop(
          id: 'S3', sequence: 3, type: StopType.delivery, status: StopStatus.upcoming,
          address: '130 Business District', customerName: 'David K.',
          orderId: '1300', itemDescription: 'Phone case',
          distanceMiles: 0.8, etaMinutes: 8, photoRequired: true,
          specialNote: 'Leave with neighbor OK',
        ),
      ],
    ),
    LivePackage(
      id: 'P-902',
      driverId: 'D002',
      driverName: 'Sarah Chen',
      driverRating: 4.7,
      status: PackageStatus.inTransit,
      type: PackageType.standard,
      completedStops: 3,
      totalDistanceMiles: 6.2,
      estimatedTimeMinutes: 42,
      driverEarnings: 32.50,
      photoRequired: true,
      createdAt: DateTime.now().subtract(const Duration(minutes: 48)),
      stops: [
        PackageStop(
          id: 'S4', sequence: 1, type: StopType.delivery, status: StopStatus.completed,
          address: '45 Residential Ave', customerName: 'Lisa P.',
          orderId: '1295', itemDescription: 'Book',
          completedAt: DateTime(2026, 2, 8, 11, 20),
        ),
        PackageStop(
          id: 'S5', sequence: 2, type: StopType.returnPickup, status: StopStatus.completed,
          address: '52 Residential Ave', customerName: 'Mark T.',
          returnId: '571', itemDescription: 'Programming Book (Wrong item)',
          completedAt: DateTime(2026, 2, 8, 11, 35),
        ),
        PackageStop(
          id: 'S6', sequence: 3, type: StopType.returnPickup, status: StopStatus.completed,
          address: '60 Residential Ave', customerName: 'Ama K.',
          returnId: '573', itemDescription: 'T-shirt',
          completedAt: DateTime(2026, 2, 8, 11, 45),
        ),
      ],
    ),
    LivePackage(
      id: 'P-905',
      status: PackageStatus.created,
      type: PackageType.fragile,
      totalDistanceMiles: 6.2,
      estimatedTimeMinutes: 42,
      driverEarnings: 32.50,
      priorityBonus: 3.25,
      biometricRequired: true,
      pinRequired: true,
      fallbackPin: '725184',
      photoRequired: true,
      recordHandoff: true,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      stops: const [
        PackageStop(
          id: 'S7', sequence: 1, type: StopType.delivery, status: StopStatus.upcoming,
          address: '88 West End', customerName: 'Lisa P.',
          orderId: '1301', itemDescription: 'Ceramic vase',
          distanceMiles: 2.1, etaMinutes: 8, idVerificationRequired: true,
        ),
        PackageStop(
          id: 'S8', sequence: 2, type: StopType.returnPickup, status: StopStatus.upcoming,
          address: '92 West End', customerName: 'Mark T.',
          returnId: '575', itemDescription: 'Watch (Wrong size)',
          distanceMiles: 1.8, etaMinutes: 7, photoRequired: true,
        ),
        PackageStop(
          id: 'S9', sequence: 3, type: StopType.delivery, status: StopStatus.upcoming,
          address: '105 North Rd', customerName: 'Alex K.',
          orderId: '1302', itemDescription: 'Headphones',
          distanceMiles: 2.3, etaMinutes: 9,
        ),
      ],
    ),
    LivePackage(
      id: 'P-906',
      status: PackageStatus.created,
      type: PackageType.standard,
      totalDistanceMiles: 2.1,
      estimatedTimeMinutes: 15,
      driverEarnings: 18.0,
      createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
      stops: const [
        PackageStop(
          id: 'S10', sequence: 1, type: StopType.delivery, status: StopStatus.upcoming,
          address: '15 Main St', customerName: 'Kofi M.',
          orderId: '1303', itemDescription: 'Stationery set',
          distanceMiles: 2.1, etaMinutes: 15,
        ),
      ],
    ),
  ];

  final List<LiveReturn> _fallbackReturns = [
    LiveReturn(
      id: '567',
      customerId: 'C006',
      customerName: 'Sarah M.',
      customerRating: 4.5,
      customerReturnCount: 3,
      customerTotalOrders: 14,
      customerLifetimeValue: 2450.0,
      originalOrderId: '1234',
      daysSincePurchase: 5,
      itemName: 'Wireless Headphones',
      itemModel: 'WH-2023',
      serialNumber: 'SN-48291-2023-567',
      itemPrice: 129.0,
      restockingFee: 12.90,
      reason: 'Defective',
      reasonDetail: 'Right earbud not working',
      status: LiveReturnStatus.pending,
      videoEvidence: const Duration(minutes: 3, seconds: 42),
      voiceNote: const Duration(seconds: 45),
      voiceNoteTranscript: 'The right earbud stopped working after 2 days...',
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      usageDays: 2,
    ),
    LiveReturn(
      id: '571',
      customerId: 'C007',
      customerName: 'Lisa P.',
      customerRating: 4.8,
      customerReturnCount: 1,
      customerTotalOrders: 8,
      customerLifetimeValue: 890.0,
      originalOrderId: '1289',
      daysSincePurchase: 2,
      itemName: 'Programming Book',
      itemPrice: 45.0,
      reason: 'Wrong item',
      reasonDetail: 'Received beginner book instead of advanced',
      status: LiveReturnStatus.underReview,
      reviewerName: 'James Wilson',
      reviewStartedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      voiceNote: const Duration(minutes: 1, seconds: 22),
      createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    LiveReturn(
      id: '575',
      customerId: 'C008',
      customerName: 'Mark T.',
      customerRating: 4.2,
      customerReturnCount: 2,
      customerTotalOrders: 6,
      customerLifetimeValue: 420.0,
      originalOrderId: '1290',
      daysSincePurchase: 3,
      itemName: 'Watch',
      itemPrice: 85.0,
      restockingFee: 8.50,
      reason: 'Wrong size',
      status: LiveReturnStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  final List<LiveRide> _fallbackRides = [
    LiveRide(
      id: 'R-912',
      passengerName: 'Michael Chen',
      passengerRating: 4.8,
      passengerRideCount: 42,
      pickupAddress: 'Business District Entrance',
      dropoffAddress: 'Airport Terminal 2',
      distanceKm: 18.0,
      fare: 24.50,
      surgeMultiplier: 1.2,
      etaMinutes: 12,
      status: LiveRideStatus.inProgress,
      specialRequest: 'Help with luggage',
      createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
      baseFare: 15.0,
      distanceCharge: 6.40,
      timeCharge: 3.10,
      surgeCharge: 4.90,
    ),
    LiveRide(
      id: 'R-915',
      passengerName: 'Ama Osei',
      passengerRating: 4.6,
      pickupAddress: 'Mall Entrance',
      dropoffAddress: '45 Residential Ave',
      distanceKm: 2.3,
      fare: 12.50,
      status: LiveRideStatus.available,
      createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    LiveRide(
      id: 'R-916',
      passengerName: 'John Boateng',
      passengerRating: 4.9,
      pickupAddress: 'Airport Terminal 1',
      dropoffAddress: '123 City Center',
      distanceKm: 18.0,
      fare: 45.0,
      surgeMultiplier: 1.3,
      status: LiveRideStatus.available,
      createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
  ];

  final List<PredictiveInsight> _fallbackInsights = const [
    PredictiveInsight(
      title: 'Expected peak: 2:00 PM (12 orders)',
      description: 'Based on historical patterns, prepare additional drivers',
      icon: Icons.trending_up,
      color: Color(0xFF3B82F6),
    ),
    PredictiveInsight(
      title: 'Driver shortage predicted in 45min',
      description: 'Consider activating standby drivers',
      icon: Icons.people_outline,
      color: Color(0xFFF59E0B),
    ),
    PredictiveInsight(
      title: 'Bundle opportunity: 3 nearby returns',
      description: 'Combine returns for 24% route savings',
      icon: Icons.route,
      color: Color(0xFF10B981),
    ),
  ];

  final List<UrgentAction> _fallbackUrgentActions = const [
    UrgentAction(
      title: 'Order #1298 - 15min overdue',
      orderId: '1298',
      minutesOverdue: 15,
      actions: ['CALL CUSTOMER', 'ASSIGN URGENT'],
    ),
  ];

  final List<DeliveryZone> _fallbackDeliveryZones = const [
    DeliveryZone(name: 'Business District', orderCount: 42, intensity: 'hot'),
    DeliveryZone(name: 'Residential North', orderCount: 28, intensity: 'medium'),
    DeliveryZone(name: 'Industrial Area', orderCount: 3, intensity: 'cold'),
  ];

  final List<BottleneckAlert> _fallbackBottlenecks = const [
    BottleneckAlert(title: 'Order #1345: Stuck in preparation (25min)', icon: Icons.hourglass_bottom),
    BottleneckAlert(title: 'Driver shortage predicted: 3:00 PM (need +2)', icon: Icons.person_off),
    BottleneckAlert(title: 'Return processing backlog: 7 items', icon: Icons.assignment_late),
  ];

  final List<EmergencyContact> _fallbackEmergencyContacts = const [
    EmergencyContact(name: 'Police', phone: '999', type: EmergencyContactType.police, etaMinutes: 4, isNotified: true),
    EmergencyContact(name: 'Security Company', phone: '0555-789012', type: EmergencyContactType.security, etaMinutes: 6, isNotified: true),
    EmergencyContact(name: 'Branch Manager', phone: '0302-123456', type: EmergencyContactType.branchManager, isNotified: true),
    EmergencyContact(name: 'Personal Emergency', phone: '0244-567890', type: EmergencyContactType.personalContact, isNotified: true),
  ];

  final List<LiveNotification> _fallbackNotifications = [
    LiveNotification(
      id: 'N1', type: LiveNotificationType.orderAlert,
      title: 'NEW ORDER #1298', body: 'Michael Chen • ₵5,343 • MacBook Pro',
      actions: const ['ASSIGN NOW', 'VIEW'],
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    LiveNotification(
      id: 'N2', type: LiveNotificationType.driverUpdate,
      title: 'DRIVER STATUS', body: 'James Wilson is finishing package #P-901',
      actions: const ['VIEW'],
      timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
    ),
    LiveNotification(
      id: 'N3', type: LiveNotificationType.returnRequest,
      title: 'RETURN #567 PENDING', body: 'Sarah M. • Headphones • Video evidence available',
      actions: const ['REVIEW', 'SCHEDULE PICKUP'],
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    LiveNotification(
      id: 'N4', type: LiveNotificationType.performanceMilestone,
      title: 'MILESTONE ACHIEVED', body: '1000 orders processed this month!',
      actions: const ['CELEBRATE'],
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
    ),
  ];
}
