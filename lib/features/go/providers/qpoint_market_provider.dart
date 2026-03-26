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

  // ── Loaders ───────────────────────────────────────────────────────────────

  Future<void> loadAll() async {
    await Future.wait([
      loadBalance(),
      loadOrderBook(),
      loadOpenOrders(),
      loadStats(),
    ]);
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
}
