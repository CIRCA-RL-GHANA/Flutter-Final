/// 
/// QPoints Market Service  Flutter  Backend Integration
///
/// Maps to QPointsMarketController and related endpoints:
///   Terms of Service, Market stats, Orders, Cash operations,
///   Payment accounts, Settlement, Facilitator, Notifications
/// 
library;

import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';

class QPointsMarketService {
  final ApiClient _api;

  QPointsMarketService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  //  Terms of Service 

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

  Future<ApiResponse<Map<String, dynamic>>> acceptTos({
    required String tosVersion,
    required bool readConfirmed,
    required bool riskConfirmed,
    bool ageConfirmed = false,
    String platform = 'mobile',
  }) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.qpointMarket.tosAccept,
      data: {
        'tosVersion': tosVersion,
        'readConfirmed': readConfirmed,
        'riskConfirmed': riskConfirmed,
        'ageConfirmed': ageConfirmed,
        'platform': platform,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  //  Market 

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

  //  Orders 

  Future<ApiResponse<Map<String, dynamic>>> createOrder({
    required String type,
    required double quantity,
    double? price,
  }) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.qpointMarket.orderBook,
      data: {
        'type': type,
        'quantity': quantity,
        if (price != null) 'price': price,
      },
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

  //  Cash 

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

  //  Payment Accounts 

  Future<ApiResponse<List<dynamic>>> getPaymentAccounts() {
    return _api.get<List<dynamic>>(
      ApiRoutes.qpointMarket.paymentAccounts,
      fromJson: (json) => json as List<dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getCashBalance({
    bool forceRefresh = false,
  }) {
    final route = forceRefresh
        ? ApiRoutes.qpointMarket.cashBalanceRefresh
        : ApiRoutes.qpointMarket.cashBalance;
    return _api.get<Map<String, dynamic>>(
      route,
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

  /// Named-param version used by QPointMarketProvider.
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
  }) {
    return registerPaymentAccount({
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
    });
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

  //  Settlement 

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

  //  Facilitator 

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

  //  Notifications 

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

  //  Facilitators List 

  Future<ApiResponse<List<dynamic>>> getFacilitators({String? country}) {
    return _api.get<List<dynamic>>(
      ApiRoutes.qpointMarket.facilitators,
      queryParameters: {
        if (country != null) 'country': country,
      },
      fromJson: (json) => json as List<dynamic>,
    );
  }

  //  Provider-facing aliases 

  /// Mark all or specific notifications as read.
  Future<ApiResponse<void>> markAllNotificationsRead({
    bool all = false,
    List<String>? ids,
  }) {
    return _api.post<void>(
      ApiRoutes.qpointMarket.notificationsRead,
      data: all ? {'all': true} : {'notificationIds': ids ?? []},
    );
  }

  /// Check whether the cross-facilitator bridge is active for a facilitator.
  Future<bool> isBridgeActiveForFacilitator(String facilitatorId) async {
    try {
      final res = await _api.get<Map<String, dynamic>>(
        '${ApiRoutes.qpointMarket.facilitators}/$facilitatorId/bridge-status',
        fromJson: (json) => json as Map<String, dynamic>,
      );
      return res.isSuccess && (res.data?['active'] as bool? ?? true);
    } catch (_) {
      return true;
    }
  }

  /// Convenience alias: get facilitators filtered by country code.
  Future<ApiResponse<List<dynamic>>> getFacilitatorsForCountry(String countryCode) =>
      getFacilitators(country: countryCode);

  /// Alias: get the user's registered payment/facilitator accounts.
  Future<ApiResponse<List<dynamic>>> getMyFacilitatorAccounts() =>
      getPaymentAccounts();

  /// Named-param alias for deposit().
  Future<ApiResponse<Map<String, dynamic>>> createDeposit({
    required double amount,
    String currency = 'USD',
  }) =>
      deposit(amount, currency);

  /// Named-param alias for withdraw().
  Future<ApiResponse<Map<String, dynamic>>> createWithdrawal({
    required double amount,
    String currency = 'USD',
    String? payoutMethodId,
  }) =>
      withdraw(amount, currency, payoutMethodId ?? '');

  /// Paginated transaction list  returns {items: List, total: int}.
  Future<ApiResponse<Map<String, dynamic>>> getTransactions({
    int limit = 20,
    int offset = 0,
  }) async {
    final res = await listTransactions(limit: limit, offset: offset);
    return ApiResponse(
      success: res.success,
      message: res.message,
      data: res.data != null
          ? {'items': res.data, 'total': res.data!.length}
          : null,
    );
  }
}
