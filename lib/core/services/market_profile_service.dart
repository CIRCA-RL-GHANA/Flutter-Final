import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';

/// Service for market profiles and notifications.
/// Maps to backend MarketProfilesController.
class MarketProfileService {
  final ApiClient _api;

  MarketProfileService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  /// Create a new market profile.
  Future<ApiResponse<Map<String, dynamic>>> createProfile(
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.marketProfiles.create,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get all market profiles for the current user.
  Future<ApiResponse<List<Map<String, dynamic>>>> getProfiles() async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.marketProfiles.list,
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get a single market profile by ID.
  Future<ApiResponse<Map<String, dynamic>>> getProfileById(String id) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.marketProfiles.byId(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Update a market profile.
  Future<ApiResponse<Map<String, dynamic>>> updateProfile(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.marketProfiles.byId(id),
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Delete a market profile.
  Future<ApiResponse<Map<String, dynamic>>> deleteProfile(String id) async {
    return _api.delete<Map<String, dynamic>>(
      ApiRoutes.marketProfiles.byId(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Apply AI segmentation to a market profile.
  Future<ApiResponse<Map<String, dynamic>>> applyAiSegmentation(
    String id, {
    required double clickRate,
    required int impressions,
    required int conversions,
    required Map<String, double> regionEngagement,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.marketProfiles.aiSegmentation(id),
      data: {
        'clickRate': clickRate,
        'impressions': impressions,
        'conversions': conversions,
        'regionEngagement': regionEngagement,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get notifications for the current user.
  Future<ApiResponse<List<Map<String, dynamic>>>> getNotifications() async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.marketProfiles.notifications,
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Mark a notification as read.
  Future<ApiResponse<Map<String, dynamic>>> markNotificationRead(
    String id,
  ) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.marketProfiles.markNotificationRead(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
