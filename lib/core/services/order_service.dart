import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';
import 'ai_service.dart';

/// Service for order management and fulfillment.
/// Maps to backend OrdersController.
/// Extends basic order CRUD with AI-powered fraud detection and analytics.
class OrderService {
  final ApiClient _api;
  final AIService _aiService;

  OrderService([ApiClient? api, AIService? aiService])
      : _api = api ?? ApiClient.instance,
        _aiService = aiService ?? AIService();

  /// Create a new order.
  Future<ApiResponse<Map<String, dynamic>>> createOrder({
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> deliveryAddress,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.orders.create,
      data: {
        'items': items,
        'deliveryAddress': deliveryAddress,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get an order by ID.
  Future<ApiResponse<Map<String, dynamic>>> getOrder(String id) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.orders.byId(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get orders for a specific user.
  Future<ApiResponse<List<Map<String, dynamic>>>> getUserOrders({
    required String userId,
    int limit = 20,
  }) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.orders.byUser(userId),
      queryParameters: {'limit': limit},
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get items for a specific order.
  Future<ApiResponse<List<Map<String, dynamic>>>> getOrderItems(
    String id,
  ) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.orders.items(id),
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Update the status of an order.
  Future<ApiResponse<Map<String, dynamic>>> updateOrderStatus({
    required String id,
    required String status,
    String? notes,
  }) async {
    return _api.patch<Map<String, dynamic>>(
      ApiRoutes.orders.updateStatus(id),
      data: {
        'status': status,
        if (notes != null) 'notes': notes,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Start fulfillment for an order.
  Future<ApiResponse<Map<String, dynamic>>> startFulfillment(
    String orderId,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.orders.startFulfillment(orderId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Complete fulfillment for a session.
  Future<ApiResponse<Map<String, dynamic>>> completeFulfillment(
    String sessionId,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.orders.completeFulfillment(sessionId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Create a return request for an order.
  Future<ApiResponse<Map<String, dynamic>>> createReturnRequest({
    required String orderId,
    required String reason,
    required List<Map<String, dynamic>> items,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.orders.returns,
      data: {
        'orderId': orderId,
        'reason': reason,
        'items': items,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get return requests for a user.
  Future<ApiResponse<List<Map<String, dynamic>>>> getReturnRequests(
    String userId,
  ) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.orders.returnsByUser(userId),
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Update the status of a return request.
  Future<ApiResponse<Map<String, dynamic>>> updateReturnStatus({
    required String id,
    required String status,
    String? notes,
  }) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.orders.returnStatus(id),
      data: {
        'status': status,
        if (notes != null) 'notes': notes,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Create a delivery for an order.
  Future<ApiResponse<Map<String, dynamic>>> createDelivery({
    required String orderId,
    required Map<String, dynamic> data,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.orders.delivery(orderId),
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Update a delivery status.
  Future<ApiResponse<Map<String, dynamic>>> updateDeliveryStatus({
    required String id,
    required String status,
  }) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.orders.deliveryStatus(id),
      data: {'status': status},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get deliveries for a driver.
  Future<ApiResponse<List<Map<String, dynamic>>>> getDriverDeliveries(
    String driverId,
  ) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.orders.deliveriesByDriver(driverId),
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Create a delivery package.
  Future<ApiResponse<Map<String, dynamic>>> createDeliveryPackage(
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.orders.packages,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get packages for a driver.
  Future<ApiResponse<List<Map<String, dynamic>>>> getDriverPackages(
    String driverId,
  ) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.orders.packagesByDriver(driverId),
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // AI-ENHANCED METHODS
  // ═══════════════════════════════════════════════════════════════════════

  /// Score an order transaction for fraud risk using AI.
  /// Returns riskScore (0-1) and risk signals/flags.
  Future<ApiResponse<Map<String, dynamic>>> getAIFraudScore({
    required String userId,
    required double amount,
    required String currency,
    required String paymentMethod,
    List<double>? recentAmounts,
    int? recentCountInHour,
    double? avgHistoricAmount,
  }) {
    return _aiService.scoreFraud(
      userId: userId,
      amount: amount,
      currency: currency,
      paymentMethod: paymentMethod,
      recentAmounts: recentAmounts,
      recentCountInHour: recentCountInHour,
      avgHistoricAmount: avgHistoricAmount,
    );
  }

  /// Analyze order return request reason using AI NLP.
  /// Returns sentiment and intent to help categorize returns.
  Future<ApiResponse<Map<String, dynamic>>> analyzeReturnReason(
    String reason,
  ) {
    return _aiService.detectIntent(reason);
  }

  /// Get AI-summarized order history insights for a user.
  /// Returns key patterns and trends from order descriptions.
  Future<ApiResponse<Map<String, dynamic>>> getOrderHistorySummary(
    List<String> orderDescriptions,
  ) {
    final combinedText = orderDescriptions.join(' ');
    return _aiService.summariseText(combinedText);
  }

  /// Extract keywords from order items for categorization.
  Future<ApiResponse<Map<String, dynamic>>> extractOrderKeywords(
    String orderDescription, {
    int topN = 5,
  }) {
    return _aiService.extractKeywords(orderDescription, topN: topN);
  }
}
