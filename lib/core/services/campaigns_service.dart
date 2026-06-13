/// ═══════════════════════════════════════════════════════════════════════════
/// Campaigns Service — Flutter ↔ Backend Integration
///
/// Maps to CampaignsController endpoints:
///   GET   /campaigns
///   POST  /campaigns
///   GET   /campaigns/{id}
///   PUT   /campaigns/{id}
///   DELETE /campaigns/{id}
///   PATCH /campaigns/{id}/activate
///   PATCH /campaigns/{id}/pause
///   GET   /campaigns/{id}/analytics
/// ═══════════════════════════════════════════════════════════════════════════
library;

import '../network/api_client.dart';
import '../network/api_response.dart';

class CampaignsService {
  final ApiClient _api;

  CampaignsService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  // ─── Campaigns CRUD ───────────────────────────────────────────────────────

  Future<ApiResponse<List<dynamic>>> getCampaigns(
    String entityId, {
    String? status,
  }) {
    return _api.get<List<dynamic>>(
      '/campaigns',
      queryParameters: {
        'entityId': entityId,
        if (status != null) 'status': status,
      },
      fromJson: (json) => json as List<dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> createCampaign(
    Map<String, dynamic> data,
  ) {
    return _api.post<Map<String, dynamic>>(
      '/campaigns',
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getCampaignById(String id) {
    return _api.get<Map<String, dynamic>>(
      '/campaigns/$id',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateCampaign(
    String id,
    Map<String, dynamic> updates,
  ) {
    return _api.put<Map<String, dynamic>>(
      '/campaigns/$id',
      data: updates,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<void>> deleteCampaign(String id) {
    return _api.delete<void>('/campaigns/$id');
  }

  // ─── Campaign State ───────────────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> activateCampaign(String id) {
    return _api.patch<Map<String, dynamic>>(
      '/campaigns/$id/activate',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> pauseCampaign(String id) {
    return _api.patch<Map<String, dynamic>>(
      '/campaigns/$id/pause',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ─── Analytics ────────────────────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> getCampaignAnalytics(String id) {
    return _api.get<Map<String, dynamic>>(
      '/campaigns/$id/analytics',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
