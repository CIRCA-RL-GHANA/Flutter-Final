/// ═══════════════════════════════════════════════════════════════════════════
/// QPoints Market Service — Flutter ↔ Backend Integration
///
/// Maps to QPointsMarketController and related endpoints:
///   Terms of Service, Market stats, Orders, Cash operations,
///   Payment accounts, Settlement, Facilitator, Notifications
/// ═══════════════════════════════════════════════════════════════════════════
library;

import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';

class QPointsMarketService {
  final ApiClient _api;

  QPointsMarketService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  // ─── Terms of Service ────────────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> getTosStatus() {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.qpointMarket.tosStatus,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getCurrentTos() {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.qpointMarket.tos,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> acceptTos(
    Map<String, dynamic> acceptance,
  ) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.qpointMarket.tosAccept,
      data: acceptance,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ─── Market ───────────────────────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> getBalance() {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.qpointMarket.balance,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getMarketStats() {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.qpointMarket.market,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<List<dynamic>>> getTradeHistory({
    int limit = 50,
    int offset = 0,
  }) {
    return _api.get<List<dynamic>>(
      ApiRoutes.qpointMarket.trades,
      queryParameters: {'limit': limit, 'offset': offset},
      fromJson: (json) => json as List<dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getFeeSchedule() {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.qpointMarket.fees,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ─── Orders ───────────────────────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> createOrder(
    String type,
    double quantity,
  ) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.qpointMarket.orderBook,
      data: {'type': type, 'quantity': quantity},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<void>> cancelOrder(String orderId) {
    return _api.delete<void>(ApiRoutes.qpointMarket.cancelOrder(orderId));
  }

  Future<ApiResponse<List<dynamic>>> getOpenOrders() {
    return _api.get<List<dynamic>>(
      ApiRoutes.qpointMarket.openOrders,
      fromJson: (json) => json as List<dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getOrderBook() {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.qpointMarket.orderBook,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ─── Cash ─────────────────────────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> cashOut(double quantity) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.qpointMarket.cashOut,
      data: {'quantity': quantity},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> cashIn(double quantity) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.qpointMarket.cashIn,
      data: {'quantity': quantity},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ─── Payment Accounts ─────────────────────────────────────────────────────

  Future<ApiResponse<List<dynamic>>> getPaymentAccounts() {
    return _api.get<List<dynamic>>(
      ApiRoutes.qpointMarket.paymentAccounts,
      fromJson: (json) => json as List<dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getCashBalance() {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.qpointMarket.cashBalance,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> registerPaymentAccount(
    Map<String, dynamic> data,
  ) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.qpointMarket.paymentRegister,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> deposit(
    double amount,
    String currency,
  ) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.qpointMarket.deposit,
      data: {'amount': amount, 'currency': currency},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> withdraw(
    double amount,
    String currency,
    String payoutMethodId,
  ) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.qpointMarket.withdraw,
      data: {
        'amount': amount,
        'currency': currency,
        'payoutMethodId': payoutMethodId,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<List<dynamic>>> listTransactions({
    int limit = 20,
    int offset = 0,
  }) {
    return _api.get<List<dynamic>>(
      ApiRoutes.qpointMarket.paymentTransactions,
      queryParameters: {'limit': limit, 'offset': offset},
      fromJson: (json) => json as List<dynamic>,
    );
  }

  // ─── Settlement ───────────────────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> initiateSettlement(
    String fromEntityId,
    String toEntityId,
    double amount, {
    String? reference,
  }) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.qpointSettlement.initiate,
      data: {
        'fromEntityId': fromEntityId,
        'toEntityId': toEntityId,
        'amount': amount,
        if (reference != null) 'reference': reference,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ─── Facilitator ──────────────────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> getInstitutionBalance(
    String entityId,
  ) {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.facilitator.institutionBalance(entityId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> issueQp(
    String entityId,
    double amount, {
    String? reason,
  }) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.facilitator.issueQp,
      data: {
        'entityId': entityId,
        'amount': amount,
        if (reason != null) 'reason': reason,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ─── Notifications ────────────────────────────────────────────────────────

  Future<ApiResponse<List<dynamic>>> getNotifications({
    int limit = 20,
    int offset = 0,
  }) {
    return _api.get<List<dynamic>>(
      ApiRoutes.qpointMarket.notifications,
      queryParameters: {'limit': limit, 'offset': offset},
      fromJson: (json) => json as List<dynamic>,
    );
  }

  Future<ApiResponse<void>> markNotificationsRead(List<String> ids) {
    return _api.post<void>(
      ApiRoutes.qpointMarket.notificationsRead,
      data: {'notificationIds': ids},
    );
  }

  // ─── Facilitators List ────────────────────────────────────────────────────

  Future<ApiResponse<List<dynamic>>> getFacilitators({String? country}) {
    return _api.get<List<dynamic>>(
      ApiRoutes.qpointMarket.facilitators,
      queryParameters: {
        if (country != null) 'country': country,
      },
      fromJson: (json) => json as List<dynamic>,
    );
  }
}
