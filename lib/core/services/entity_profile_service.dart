import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';

/// Service for entity profile settings, operating hours, and categories.
/// Maps to backend EntityProfilesController.
class EntityProfileService {
  final ApiClient _api;

  EntityProfileService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  // ==================== Profile Settings ====================

  /// Create profile settings for an entity or branch.
  Future<ApiResponse<Map<String, dynamic>>> createSettings(
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.entityProfiles.createSettings,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get profile settings by profile type and ID.
  Future<ApiResponse<Map<String, dynamic>>> getSettings({
    required String profileType,
    required String profileId,
  }) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.entityProfiles.settings(profileType, profileId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Update profile settings by ID.
  Future<ApiResponse<Map<String, dynamic>>> updateSettings(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.entityProfiles.settingsById(id),
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Delete profile settings by ID.
  Future<ApiResponse<Map<String, dynamic>>> deleteSettings(String id) async {
    return _api.delete<Map<String, dynamic>>(
      ApiRoutes.entityProfiles.settingsById(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ==================== Operating Hours ====================

  /// Create operating hours for a profile.
  Future<ApiResponse<Map<String, dynamic>>> createOperatingHours(
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.entityProfiles.createOperatingHours,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get operating hours for a specific profile.
  Future<ApiResponse<List<Map<String, dynamic>>>> getOperatingHours({
    required String profileType,
    required String profileId,
  }) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.entityProfiles.operatingHours(profileType, profileId),
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Update operating hours by ID.
  Future<ApiResponse<Map<String, dynamic>>> updateOperatingHours(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.entityProfiles.operatingHoursById(id),
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Delete operating hours by ID.
  Future<ApiResponse<Map<String, dynamic>>> deleteOperatingHours(
    String id,
  ) async {
    return _api.delete<Map<String, dynamic>>(
      ApiRoutes.entityProfiles.operatingHoursById(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ==================== Business Categories ====================

  /// Create a business category.
  Future<ApiResponse<Map<String, dynamic>>> createCategory(
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.entityProfiles.createCategory,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get all active business categories.
  Future<ApiResponse<List<Map<String, dynamic>>>> getCategories() async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.entityProfiles.categories,
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get a single category by ID.
  Future<ApiResponse<Map<String, dynamic>>> getCategoryById(
    String id,
  ) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.entityProfiles.categoryById(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Update a category by ID.
  Future<ApiResponse<Map<String, dynamic>>> updateCategory(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.entityProfiles.categoryById(id),
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Delete a category by ID.
  Future<ApiResponse<Map<String, dynamic>>> deleteCategory(String id) async {
    return _api.delete<Map<String, dynamic>>(
      ApiRoutes.entityProfiles.categoryById(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
