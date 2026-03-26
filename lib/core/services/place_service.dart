import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';

/// Service for place discovery and management.
/// Maps to backend PlacesController.
class PlaceService {
  final ApiClient _api;

  PlaceService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  /// Create a new place.
  Future<ApiResponse<Map<String, dynamic>>> createPlace(
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.places.create,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get paginated list of places with optional filters.
  Future<ApiResponse<List<Map<String, dynamic>>>> getPlaces({
    int page = 1,
    int limit = 20,
    String? entityId,
    String? category,
  }) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.places.list,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (entityId != null) 'entityId': entityId,
        if (category != null) 'category': category,
      },
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Search places by query string.
  Future<ApiResponse<List<Map<String, dynamic>>>> searchPlaces(
    String query,
  ) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.places.search,
      queryParameters: {'q': query},
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get places by category.
  Future<ApiResponse<List<Map<String, dynamic>>>> getPlacesByCategory(
    String category,
  ) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.places.byCategory(category),
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get nearby places by coordinates and radius.
  Future<ApiResponse<List<Map<String, dynamic>>>> getNearbyPlaces({
    required double lat,
    required double lng,
    double radius = 10.0,
  }) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.places.nearby,
      queryParameters: {
        'latitude': lat,
        'longitude': lng,
        'radius': radius,
      },
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get a single place by ID.
  Future<ApiResponse<Map<String, dynamic>>> getPlaceById(String id) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.places.byId(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Verify a place.
  Future<ApiResponse<Map<String, dynamic>>> verifyPlace(String id) async {
    return _api.patch<Map<String, dynamic>>(
      ApiRoutes.places.verify(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Rate and review a place.
  Future<ApiResponse<Map<String, dynamic>>> ratePlace({
    required String id,
    required int rating,
    String? review,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.places.rate(id),
      data: {
        'rating': rating,
        if (review != null) 'review': review,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get places by entity ID.
  Future<ApiResponse<List<Map<String, dynamic>>>> getPlacesByEntity(
    String entityId,
  ) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.places.byEntity(entityId),
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get ratings for a place.
  Future<ApiResponse<List<Map<String, dynamic>>>> getPlaceRatings(
    String id,
  ) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.places.ratings(id),
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get a place by its unique ID.
  Future<ApiResponse<Map<String, dynamic>>> getPlaceByUniqueId(
    String uniqueId,
  ) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.places.byUniqueId(uniqueId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Update a place.
  Future<ApiResponse<Map<String, dynamic>>> updatePlace(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.places.byId(id),
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Delete a place.
  Future<ApiResponse<Map<String, dynamic>>> deletePlace(String id) async {
    return _api.delete<Map<String, dynamic>>(
      ApiRoutes.places.byId(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
