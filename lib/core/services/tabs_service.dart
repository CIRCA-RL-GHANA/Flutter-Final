/// 
/// Tabs Service  Flutter  Backend Integration
///
/// Maps to TabsController endpoints:
///   GET  /tabs
///   POST /tabs
///   GET  /tabs/{id}
///   PUT  /tabs/{id}
///   DELETE /tabs/{id}
///   POST /tabs/{id}/charge
///   POST /tabs/{id}/settle
///   GET  /tabs/{id}/transactions
/// 
library;

import '../network/api_client.dart';
import '../network/api_response.dart';

class TabsService {
  final ApiClient _api;

  TabsService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  //  Tabs CRUD 

  Future<ApiResponse<List<dynamic>>> getTabs(String entityId) {
    return _api.get<List<dynamic>>(
      '/tabs',
      queryParameters: {'entityId': entityId},
      fromJson: (json) => json as List<dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> createTab(
    Map<String, dynamic> data,
  ) {
    return _api.post<Map<String, dynamic>>(
      '/tabs',
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getTabById(String id) {
    return _api.get<Map<String, dynamic>>(
      '/tabs/$id',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateTab(
    String id,
    Map<String, dynamic> updates,
  ) {
    return _api.put<Map<String, dynamic>>(
      '/tabs/$id',
      data: updates,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<void>> deleteTab(String id) {
    return _api.delete<void>('/tabs/$id');
  }

  //  Tab Operations 

  Future<ApiResponse<Map<String, dynamic>>> chargeTab(
    String id,
    double amount, {
    String? description,
  }) {
    return _api.post<Map<String, dynamic>>(
      '/tabs/$id/charge',
      data: {
        'amount': amount,
        if (description != null) 'description': description,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> settleTab(
    String id,
    double amount,
  ) {
    return _api.post<Map<String, dynamic>>(
      '/tabs/$id/settle',
      data: {'amount': amount},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<List<dynamic>>> getTabTransactions(String id) {
    return _api.get<List<dynamic>>(
      '/tabs/$id/transactions',
      fromJson: (json) => json as List<dynamic>,
    );
  }
}
