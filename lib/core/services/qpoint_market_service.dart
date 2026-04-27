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

  // ── Terms of Service ──────────────────────────────────────────────────────

  /// Returns the current ToS version, effective date, content hash, and full text.
  Future<ApiResponse<QPointsTosContent>> getCurrentTos() => _api.get(
        '/qpoints/tos',
        fromJson: (json) =>
            QPointsTosContent.fromJson(json as Map<String, dynamic>),
      );

  /// Returns whether the current user has accepted the current ToS version.
  Future<ApiResponse<QPointsTosStatus>> getTosStatus() => _api.get(
        '/qpoints/tos/status',
        fromJson: (json) =>
            QPointsTosStatus.fromJson(json as Map<String, dynamic>),
      );

  /// Records the user's acceptance of the current Q Points ToS.
  /// All three confirmation flags must be true.
  Future<ApiResponse<Map<String, dynamic>>> acceptTos({
    required String tosVersion,
    required bool readConfirmed,
    required bool riskConfirmed,
    required bool ageConfirmed,
    required String platform,
  }) =>
      _api.post(
        '/qpoints/tos/accept',
        data: {
          'tosVersion': tosVersion,
          'readConfirmed': readConfirmed,
          'riskConfirmed': riskConfirmed,
          'ageConfirmed': ageConfirmed,
          'platform': platform,
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

  // ── Fee Schedule (TOS §7.1) ───────────────────────────────────────────────

  /// Returns the current fee schedule as required by TOS Section 7.1.
  /// Does NOT require ToS acceptance — always publicly accessible.
  Future<ApiResponse<QPointFeeSchedule>> getFeeSchedule() => _api.get(
        '/qpoints/fees',
        fromJson: (json) =>
            QPointFeeSchedule.fromJson(json as Map<String, dynamic>),
      );

  // ── Facilitators (TOS §2.2) ───────────────────────────────────────────────

  /// Returns available payment facilitators for a country (ISO 3166-1 alpha-2).
  /// Includes account field definitions for rendering the registration form.
  /// Does NOT require authentication or ToS acceptance.
  Future<ApiResponse<List<QPointFacilitatorInfo>>> getFacilitatorsForCountry(
    String countryCode,
  ) =>
      _api.get(
        '/qpoints/facilitators',
        queryParameters: {'country': countryCode},
        fromJson: (json) => (json as List<dynamic>)
            .map((e) =>
                QPointFacilitatorInfo.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Returns all registered facilitator accounts for the authenticated user.
  Future<ApiResponse<List<QPointFacilitatorAccount>>>
      getMyFacilitatorAccounts() => _api.get(
            '/qpoints/payment/accounts',
            fromJson: (json) => (json as List<dynamic>)
                .map((e) => QPointFacilitatorAccount.fromJson(
                    e as Map<String, dynamic>))
                .toList(),
          );

  /// Registers the user's payment account with a facilitator.
  /// Call [getFacilitatorsForCountry] first to get required fields per provider.
  Future<ApiResponse<Map<String, dynamic>>> registerFacilitatorAccount({
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
  }) =>
      _api.post(
        '/qpoints/payment/register',
        data: {
          if (provider != null) 'provider': provider,
          'email': email,
          if (countryCode != null) 'countryCode': countryCode,
          if (accountNumber != null) 'accountNumber': accountNumber,
          if (bankCode != null) 'bankCode': bankCode,
          if (routingCode != null) 'routingCode': routingCode,
          if (accountName != null) 'accountName': accountName,
          if (currency != null) 'currency': currency,
          if (type != null) 'type': type,
          if (phone != null) 'phone': phone,
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );
}
