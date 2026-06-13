import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';

/// Canonical order-management service.
/// All callers should use this class; the legacy OrderService is removed.
class OrdersService {
  final ApiClient _api;

  OrdersService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  /// Fetch paginated order list for the authenticated user.
  Future<ApiResponse<List<Map<String, dynamic>>>> getOrders({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.orders.byUser('me'),
      queryParameters: {
        'page': page,
        'limit': limit,
        'sortBy': 'createdAt',
        'sortOrder': 'DESC',
        if (status != null) 'status': status,
      },
      fromJson: (json) {
        if (json is List) {
          return List<Map<String, dynamic>>.from(json);
        }
        if (json is Map && json.containsKey('items')) {
          return List<Map<String, dynamic>>.from(json['items'] as List);
        }
        return const [];
      },
    );
  }

  /// Alias used by MarketProvider — fetches orders for the authenticated user.
  Future<ApiResponse<List<Map<String, dynamic>>>> getUserOrders({
    String userId = 'me',
    int limit = 20,
  }) =>
      getOrders(limit: limit);

  /// Fetch a single order by ID.
  Future<ApiResponse<Map<String, dynamic>>> getOrder(String orderId) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.orders.byId(orderId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Place a new order.
  /// [deliveryAddress] is a free-form map matching the backend DeliveryAddressDto
  /// shape: { street, city, coordinates? }.
  Future<ApiResponse<Map<String, dynamic>>> createOrder({
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> deliveryAddress,
    String paymentMethod = 'QPOINTS',
    String? branchId,
    String? deliveryNotes,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.orders.create,
      data: {
        'items': items,
        'deliveryAddress': deliveryAddress,
        'paymentMethod': paymentMethod,
        if (branchId != null) 'branchId': branchId,
        if (deliveryNotes != null) 'deliveryNotes': deliveryNotes,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Cancel an order.
  Future<ApiResponse<Map<String, dynamic>>> cancelOrder(
    String orderId, {
    String? reason,
  }) async {
    return _api.patch<Map<String, dynamic>>(
      ApiRoutes.orders.updateStatus(orderId),
      data: {
        'status': 'cancelled',
        if (reason != null) 'reason': reason,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get live tracking data for an order in transit.
  Future<ApiResponse<Map<String, dynamic>>> trackOrder(String orderId) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.orders.delivery(orderId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Submit a star rating and review for a completed order.
  Future<ApiResponse<Map<String, dynamic>>> rateOrder(
    String orderId, {
    required double rating,
    required String review,
  }) async {
    return _api.post<Map<String, dynamic>>(
      '${ApiRoutes.orders.byId(orderId)}/rate',
      data: {'rating': rating, 'review': review},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Update order status (admin / fulfilment use).
  Future<ApiResponse<Map<String, dynamic>>> updateStatus(
    String orderId,
    String status,
  ) async {
    return _api.patch<Map<String, dynamic>>(
      ApiRoutes.orders.updateStatus(orderId),
      data: {'status': status},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get all returns filed by the authenticated user.
  Future<ApiResponse<List<Map<String, dynamic>>>> getReturns() async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.orders.returns,
      fromJson: (json) {
        if (json is List) return List<Map<String, dynamic>>.from(json);
        if (json is Map && json.containsKey('items')) {
          return List<Map<String, dynamic>>.from(json['items'] as List);
        }
        return const [];
      },
    );
  }

  /// Alias used by MarketProvider — fetches returns for the authenticated user.
  Future<ApiResponse<List<Map<String, dynamic>>>> getReturnRequests(
          [String userId = 'me']) =>
      getReturns();

  /// Request a return for a specific order.
  Future<ApiResponse<Map<String, dynamic>>> createReturnRequest({
    required String orderId,
    required String reason,
    List<Map<String, dynamic>>? items,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.orders.returns,
      data: {
        'orderId': orderId,
        'reason': reason,
        if (items != null && items.isNotEmpty) 'items': items,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
