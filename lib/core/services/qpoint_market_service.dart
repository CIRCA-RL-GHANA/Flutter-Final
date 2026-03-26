import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../go/models/qpoint_market_models.dart';

/// Service for the Q Points liquid market.
/// Covers balance, order book, orders, trades, market stats, and notifications.
class QPointMarketService {
  final ApiClient _api;

  QPointMarketService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  // ── Balance ──────────────────────────────────────────────────────────────

  Future<ApiResponse<QPointMarketBalance>> getBalance() => _api.get(
        '/qpoints/balance',
        fromJson: (json) =>
            QPointMarketBalance.fromJson(json as Map<String, dynamic>),
      );

  // ── Order Book ───────────────────────────────────────────────────────────

  Future<ApiResponse<QPointOrderBook>> getOrderBook() => _api.get(
        '/qpoints/orders',
        fromJson: (json) =>
            QPointOrderBook.fromJson(json as Map<String, dynamic>),
      );

  Future<ApiResponse<List<QPointOrder>>> getOpenOrders() => _api.get(
        '/qpoints/orders/open',
        fromJson: (json) => (json as List<dynamic>)
            .map((e) => QPointOrder.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  // ── Orders ───────────────────────────────────────────────────────────────

  /// Place a limit order. Returns the order + any immediate trade fills.
  Future<ApiResponse<Map<String, dynamic>>> createOrder({
    required String type, // 'buy' | 'sell'
    required double price,
    required double quantity,
  }) =>
      _api.post(
        '/qpoints/orders',
        data: {'type': type, 'price': price, 'quantity': quantity},
        fromJson: (json) => json as Map<String, dynamic>,
      );

  Future<ApiResponse<Map<String, dynamic>>> cancelOrder(String orderId) =>
      _api.delete(
        '/qpoints/orders/$orderId',
        fromJson: (json) => json as Map<String, dynamic>,
      );

  // ── Instant Buy / Sell ───────────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> cashIn(double quantity) =>
      _api.post(
        '/qpoints/cashin',
        data: {'quantity': quantity},
        fromJson: (json) => json as Map<String, dynamic>,
      );

  Future<ApiResponse<Map<String, dynamic>>> cashOut(double quantity) =>
      _api.post(
        '/qpoints/cashout',
        data: {'quantity': quantity},
        fromJson: (json) => json as Map<String, dynamic>,
      );

  // ── Trades ───────────────────────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> getTradeHistory({
    int limit = 20,
    int offset = 0,
  }) =>
      _api.get(
        '/qpoints/trades',
        queryParameters: {'limit': limit, 'offset': offset},
        fromJson: (json) => json as Map<String, dynamic>,
      );

  // ── Market Stats ─────────────────────────────────────────────────────────

  Future<ApiResponse<QPointMarketStats>> getMarketStats() => _api.get(
        '/qpoints/market',
        fromJson: (json) =>
            QPointMarketStats.fromJson(json as Map<String, dynamic>),
      );

  // ── Notifications ─────────────────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> getNotifications({
    int limit = 20,
    int offset = 0,
  }) =>
      _api.get(
        '/qpoints/notifications',
        queryParameters: {'limit': limit, 'offset': offset},
        fromJson: (json) => json as Map<String, dynamic>,
      );

  Future<ApiResponse<Map<String, dynamic>>> markNotificationsRead({
    List<String>? ids,
    bool all = false,
  }) =>
      _api.post(
        '/qpoints/notifications/read',
        data: all ? {'all': true} : {'notificationIds': ids ?? []},
        fromJson: (json) => json as Map<String, dynamic>,
      );
}
