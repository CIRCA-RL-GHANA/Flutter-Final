/// 
/// Alerts Service  Flutter  Backend Integration
///
/// Maps to AlertsController endpoints:
///   GET    /alerts
///   POST   /alerts
///   POST   /alerts/bulk
///   GET    /alerts/{id}
///   PATCH  /alerts/{id}/resolve
///   PATCH  /alerts/{id}/dismiss
///   DELETE /alerts/{id}
///   GET    /alerts/analytics
///   GET    /alerts/templates
///   GET    /alerts/search
/// 
library;

import '../network/api_client.dart';
import '../network/api_response.dart';

class AlertsService {
  final ApiClient _api;

  AlertsService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  //  Alerts CRUD 

  Future<ApiResponse<List<dynamic>>> getAlerts({
    String? status,
    String? priority,
    String? category,
  }) {
    return _api.get<List<dynamic>>(
      '/alerts',
      queryParameters: {
        if (status != null) 'status': status,
        if (priority != null) 'priority': priority,
        if (category != null) 'category': category,
      },
      fromJson: (json) => json as List<dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> createAlert(
    Map<String, dynamic> data,
  ) {
    return _api.post<Map<String, dynamic>>(
      '/alerts',
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> createAlertsBulk(
    List<Map<String, dynamic>> alerts,
  ) {
    return _api.post<Map<String, dynamic>>(
      '/alerts/bulk',
      data: {'alerts': alerts},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getAlertById(String id) {
    return _api.get<Map<String, dynamic>>(
      '/alerts/$id',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> resolveAlert(String id) {
    return _api.patch<Map<String, dynamic>>(
      '/alerts/$id/resolve',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> dismissAlert(String id) {
    return _api.patch<Map<String, dynamic>>(
      '/alerts/$id/dismiss',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<void>> deleteAlert(String id) {
    return _api.delete<void>('/alerts/$id');
  }

  //  Analytics & Templates 

  Future<ApiResponse<Map<String, dynamic>>> getAnalytics() {
    return _api.get<Map<String, dynamic>>(
      '/alerts/analytics',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<List<dynamic>>> getTemplates() {
    return _api.get<List<dynamic>>(
      '/alerts/templates',
      fromJson: (json) => json as List<dynamic>,
    );
  }

  //  Search 

  Future<ApiResponse<List<dynamic>>> searchAlerts(String query) {
    return _api.get<List<dynamic>>(
      '/alerts/search',
      queryParameters: {'q': query},
      fromJson: (json) => json as List<dynamic>,
    );
  }
}
