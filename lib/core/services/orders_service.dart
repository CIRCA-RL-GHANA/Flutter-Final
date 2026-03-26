import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class OrdersService extends ChangeNotifier {
  final Dio _dio;
  static const String _baseEndpoint = '/orders';

  OrdersService(this._dio);

  // Get user orders
  Future<List<Map<String, dynamic>>> getOrders({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final params = {
        'page': page,
        'limit': limit,
        'sortBy': 'createdAt',
        'sortOrder': 'DESC',
      };

      if (status != null) {
        params['status'] = status;
      }

      final response = await _dio.get(
        _baseEndpoint,
        queryParameters: params,
      );

      final data = response.data['data'];
      if (data is Map && data.containsKey('items')) {
        return List<Map<String, dynamic>>.from(data['items']);
      }
      return [];
    } catch (e) {
      debugPrint('[OrdersService] Error fetching orders: $e');
      return [];
    }
  }

  // Get order details
  Future<Map<String, dynamic>?> getOrder(String orderId) async {
    try {
      final response = await _dio.get('$_baseEndpoint/$orderId');
      return response.data['data'];
    } catch (e) {
      debugPrint('[OrdersService] Error fetching order: $e');
      return null;
    }
  }

  // Create order
  Future<Map<String, dynamic>?> createOrder({
    required List<Map<String, dynamic>> items,
    required String deliveryAddressId,
    String? notes,
    String paymentMethod = 'qpoints',
  }) async {
    try {
      final response = await _dio.post(
        _baseEndpoint,
        data: {
          'items': items,
          'deliveryAddressId': deliveryAddressId,
          'notes': notes,
          'paymentMethod': paymentMethod,
        },
      );

      return response.data['data'];
    } catch (e) {
      debugPrint('[OrdersService] Error creating order: $e');
      return null;
    }
  }

  // Cancel order
  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    try {
      await _dio.patch(
        '$_baseEndpoint/$orderId/cancel',
        data: {'reason': reason},
      );
      return true;
    } catch (e) {
      debugPrint('[OrdersService] Error canceling order: $e');
      return false;
    }
  }

  // Track order
  Future<Map<String, dynamic>?> trackOrder(String orderId) async {
    try {
      final response = await _dio.get('$_baseEndpoint/$orderId/track');
      return response.data['data'];
    } catch (e) {
      debugPrint('[OrdersService] Error tracking order: $e');
      return null;
    }
  }

  // Rate order
  Future<bool> rateOrder(
    String orderId, {
    required double rating,
    required String review,
  }) async {
    try {
      await _dio.post(
        '$_baseEndpoint/$orderId/rate',
        data: {
          'rating': rating,
          'review': review,
        },
      );
      return true;
    } catch (e) {
      debugPrint('[OrdersService] Error rating order: $e');
      return false;
    }
  }
}
