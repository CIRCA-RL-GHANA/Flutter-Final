import 'package:flutter/foundation.dart';
import '../../core/services/qpoint_market_service.dart';
import '../models/qpoint_market_models.dart';

/// ChangeNotifier backing the Q Points Market screens.
/// Manages all market state: balance, order book, open orders, trades, stats.
class QPointMarketProvider extends ChangeNotifier {
  final QPointMarketService _service;

  QPointMarketProvider([QPointMarketService? service])
      : _service = service ?? QPointMarketService();

  // ── State ─────────────────────────────────────────────────────────────────

  QPointMarketBalance? balance;
  QPointOrderBook? orderBook;
  QPointMarketStats? stats;
  List<QPointOrder> openOrders = [];
  List<QPointTrade> tradeHistory = [];
  int tradeTotal = 0;

  bool isLoadingBalance = false;
  bool isLoadingBook = false;
  bool isLoadingOrders = false;
  bool isPlacingOrder = false;
  bool isCashingIn = false;
  bool isCashingOut = false;

  String? errorMessage;

  // ── Notifications state ──────────────────────────────────────────────────

  List<QPointNotification> notifications = [];
  int unreadCount = 0;

  // ── Fee schedule state (TOS §7.1) ────────────────────────────────────────

  QPointFeeSchedule? feeSchedule;
  bool isLoadingFees = false;

  // ── Facilitator state (TOS §2.2) ─────────────────────────────────────────

  List<QPointFacilitatorInfo> availableFacilitators = [];
  List<QPointFacilitatorAccount> myFacilitatorAccounts = [];
  bool isLoadingFacilitators = false;
  bool isLoadingFacilitatorAccounts = false;
  bool isRegisteringFacilitatorAccount = false;
  String? facilitatorError;

  // ── Cross-Facilitator Bridge state ────────────────────────────────────────

  /// The facilitator ID the user is currently trading through.
  /// Derived from [myFacilitatorAccounts] — the most recently added account.
  String? get activeFacilitatorId =>
      myFacilitatorAccounts.isNotEmpty ? myFacilitatorAccounts.first.provider : null;

  /// Whether the bridge is currently active for [activeFacilitatorId].
  /// False = "Cash-out via this payment method is temporarily limited."
  bool isBridgeActive = true; // optimistic default — corrected on load

  /// Human-readable bridge suspension message (null when bridge is active).
  String? get bridgeUnavailableMessage => isBridgeActive
      ? null
      : 'Cash-out via this payment method is temporarily limited. Please try again later.';

  bool isLoadingBridgeStatus = false;

  // ── Loaders ───────────────────────────────────────────────────────────────

  Future<void> loadAll() async {
    await Future.wait([
      loadBalance(),
      loadOrderBook(),
      loadOpenOrders(),
      loadStats(),
    ]);
    // Load facilitator accounts first, then bridge status (depends on active account)
    await loadMyFacilitatorAccounts();
    await loadBridgeStatus();
  }

  Future<void> loadBalance() async {
    isLoadingBalance = true;
    notifyListeners();
    final res = await _service.getBalance();
    isLoadingBalance = false;
    if (res.isSuccess && res.data != null) {
      balance = res.data;
    } else {
      errorMessage = res.message;
    }
    notifyListeners();
  }

  Future<void> loadOrderBook() async {
    isLoadingBook = true;
    notifyListeners();
    final res = await _service.getOrderBook();
    isLoadingBook = false;
    if (res.isSuccess && res.data != null) {
      orderBook = res.data;
    }
    notifyListeners();
  }

  Future<void> loadOpenOrders() async {
    isLoadingOrders = true;
    notifyListeners();
    final res = await _service.getOpenOrders();
    isLoadingOrders = false;
    if (res.isSuccess && res.data != null) {
      openOrders = res.data!;
    }
    notifyListeners();
  }

  Future<void> loadStats() async {
    final res = await _service.getMarketStats();
    if (res.isSuccess && res.data != null) {
      stats = res.data;
      notifyListeners();
    }
  }

  Future<void> loadTradeHistory({int limit = 20, int offset = 0}) async {
    final res = await _service.getTradeHistory(limit: limit, offset: offset);
    if (res.isSuccess && res.data != null) {
      final raw = res.data!;
      final list = raw['trades'] as List<dynamic>? ?? [];
      tradeHistory = list
          .map((e) => QPointTrade.fromJson(e as Map<String, dynamic>))
          .toList();
      tradeTotal = (raw['total'] as num?)?.toInt() ?? tradeHistory.length;
      notifyListeners();
    }
  }

  // ── Order placement ────────────────────────────────────────────────────────

  /// Returns an error string on failure, null on success.
  Future<String?> placeOrder({
    required String type,
    required double price,
    required double quantity,
  }) async {
    isPlacingOrder = true;
    errorMessage = null;
    notifyListeners();

    final res = await _service.createOrder(
      type: type,
      price: price,
      quantity: quantity,
    );

    isPlacingOrder = false;
    if (res.isSuccess) {
      // Refresh state after placement
      await Future.wait([loadBalance(), loadOrderBook(), loadOpenOrders()]);
      return null;
    } else {
      errorMessage = res.message;
      notifyListeners();
      return res.message ?? 'Order placement failed';
    }
  }

  Future<String?> cancelOrder(String orderId) async {
    final res = await _service.cancelOrder(orderId);
    if (res.isSuccess) {
      await loadOpenOrders();
      return null;
    }
    return res.message ?? 'Cancel failed';
  }

  // ── Instant cash in/out ────────────────────────────────────────────────────

  Future<String?> cashIn(double quantity) async {
    isCashingIn = true;
    notifyListeners();
    final res = await _service.cashIn(quantity);
    isCashingIn = false;
    if (res.isSuccess) {
      await Future.wait([loadBalance(), loadOrderBook()]);
      return null;
    }
    notifyListeners();
    return res.message ?? 'Buy failed';
  }

  Future<String?> cashOut(double quantity) async {
    isCashingOut = true;
    notifyListeners();
    final res = await _service.cashOut(quantity);
    isCashingOut = false;
    if (res.isSuccess) {
      await Future.wait([loadBalance(), loadOrderBook()]);
      return null;
    }
    notifyListeners();
    return res.message ?? 'Sell failed';
  }

  // ── Notifications ──────────────────────────────────────────────────────────

  Future<void> loadNotifications() async {
    final res = await _service.getNotifications();
    if (res.isSuccess && res.data != null) {
      final raw = res.data!;
      final list = raw['notifications'] as List<dynamic>? ?? [];
      notifications = list
          .map((e) => QPointNotification.fromJson(e as Map<String, dynamic>))
          .toList();
      unreadCount = notifications.where((n) => !n.read).length;
      notifyListeners();
    }
  }

  Future<void> markAllNotificationsRead() async {
    await _service.markNotificationsRead(all: true);
    notifications = notifications.map((n) => QPointNotification(
          id: n.id,
          type: n.type,
          message: n.message,
          data: n.data,
          read: true,
          createdAt: n.createdAt,
        )).toList();
    unreadCount = 0;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  // ── Fee schedule (TOS §7.1 — must be disclosed on the Platform) ───────────

  /// Loads and caches the current fee schedule.
  /// GET /qpoints/fees — public endpoint, no ToS acceptance required.
  Future<void> loadFeeSchedule() async {
    if (isLoadingFees) return;
    isLoadingFees = true;
    notifyListeners();
    final res = await _service.getFeeSchedule();
    isLoadingFees = false;
    if (res.isSuccess && res.data != null) {
      feeSchedule = res.data;
    }
    notifyListeners();
  }

  // ── Facilitator loaders (TOS §2.2) ───────────────────────────────────────

  /// Loads the bridge availability for the user's active facilitator.
  /// This is a best-effort call — a network failure defaults to [isBridgeActive = true]
  /// to avoid blocking users unnecessarily.
  Future<void> loadBridgeStatus() async {
    final facilitatorId = activeFacilitatorId;
    if (facilitatorId == null) return;
    isLoadingBridgeStatus = true;
    notifyListeners();
    try {
      isBridgeActive = await _service.isBridgeActiveForFacilitator(facilitatorId);
    } catch (_) {
      isBridgeActive = true; // fail-open: do not block user on network error
    } finally {
      isLoadingBridgeStatus = false;
    }
    notifyListeners();
  }

  Future<void> loadFacilitatorsForCountry(String countryCode) async {
    if (isLoadingFacilitators) return;
    isLoadingFacilitators = true;
    facilitatorError = null;
    notifyListeners();
    final res = await _service.getFacilitatorsForCountry(countryCode);
    isLoadingFacilitators = false;
    if (res.isSuccess && res.data != null) {
      availableFacilitators = res.data!;
    } else {
      facilitatorError = res.message;
    }
    notifyListeners();
  }

  Future<void> loadMyFacilitatorAccounts() async {
    if (isLoadingFacilitatorAccounts) return;
    isLoadingFacilitatorAccounts = true;
    notifyListeners();
    final res = await _service.getMyFacilitatorAccounts();
    isLoadingFacilitatorAccounts = false;
    if (res.isSuccess && res.data != null) {
      myFacilitatorAccounts = res.data!;
    }
    notifyListeners();
  }

  /// Registers an account and refreshes the account list on success.
  /// Returns [true] if successful.
  Future<bool> registerFacilitatorAccount({
    String? provider,
    required String email,
    String? countryCode,
    String? accountNumber,
    String? bankCode,
    String? routingCode,
    String? accountName,
    String? currency,
    String? type,
    String? phone,
  }) async {
    isRegisteringFacilitatorAccount = true;
    facilitatorError = null;
    notifyListeners();
    final res = await _service.registerFacilitatorAccount(
      provider: provider,
      email: email,
      countryCode: countryCode,
      accountNumber: accountNumber,
      bankCode: bankCode,
      routingCode: routingCode,
      accountName: accountName,
      currency: currency,
      type: type,
      phone: phone,
    );
    isRegisteringFacilitatorAccount = false;
    if (res.isSuccess) {
      await loadMyFacilitatorAccounts();
      return true;
    }
    facilitatorError = res.message;
    notifyListeners();
    return false;
  }
}
