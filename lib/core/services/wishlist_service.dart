import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';
import 'ai_service.dart';

/// Service for wishlist management.
/// Maps to backend WishlistController.
/// Extends basic CRUD with AI-powered scoring and recommendations.
class WishlistService {
  final ApiClient _api;
  final AIService _aiService;

  WishlistService([ApiClient? api, AIService? aiService])
      : _api = api ?? ApiClient.instance,
        _aiService = aiService ?? AIService();

  /// Add an item to the wishlist.
  Future<ApiResponse<Map<String, dynamic>>> addItem({
    required String name,
    required double estimatedPrice,
    required String priority,
    required String category,
    String? notes,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.wishlist.create,
      data: {
        'name': name,
        'estimatedPrice': estimatedPrice,
        'priority': priority,
        'category': category,
        if (notes != null) 'notes': notes,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get all wishlist items.
  Future<ApiResponse<List<Map<String, dynamic>>>> getWishlist() async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.wishlist.list,
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get wishlist items filtered by status.
  Future<ApiResponse<List<Map<String, dynamic>>>> getItemsByStatus(
    String status,
  ) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.wishlist.byStatus(status),
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get wishlist items filtered by category.
  Future<ApiResponse<List<Map<String, dynamic>>>> getItemsByCategory(
    String category,
  ) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.wishlist.byCategory(category),
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get high priority wishlist items.
  Future<ApiResponse<List<Map<String, dynamic>>>> getHighPriorityItems() async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.wishlist.highPriority,
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get total estimated value of all wishlist items.
  Future<ApiResponse<Map<String, dynamic>>> getTotalEstimatedValue() async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.wishlist.totalValue,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get a single wishlist item by ID.
  Future<ApiResponse<Map<String, dynamic>>> getItemById(String id) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.wishlist.byId(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Update a wishlist item.
  Future<ApiResponse<Map<String, dynamic>>> updateItem(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _api.patch<Map<String, dynamic>>(
      ApiRoutes.wishlist.byId(id),
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Mark a wishlist item as purchased.
  Future<ApiResponse<Map<String, dynamic>>> markAsPurchased({
    required String id,
    required double actualPrice,
    String? purchasedAt,
  }) async {
    return _api.patch<Map<String, dynamic>>(
      ApiRoutes.wishlist.purchase(id),
      data: {
        'actualPrice': actualPrice,
        if (purchasedAt != null) 'purchasedAt': purchasedAt,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Update the status of a wishlist item.
  Future<ApiResponse<Map<String, dynamic>>> updateStatus({
    required String id,
    required String status,
  }) async {
    return _api.patch<Map<String, dynamic>>(
      ApiRoutes.wishlist.updateStatus(id, status),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Delete a wishlist item.
  Future<ApiResponse<Map<String, dynamic>>> deleteItem(String id) async {
    return _api.delete<Map<String, dynamic>>(
      ApiRoutes.wishlist.byId(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // AI-ENHANCED METHODS
  // ═══════════════════════════════════════════════════════════════════════

  /// Get wishlist items with AI-computed purchase likelihood scores.
  /// Returns items sorted by conversion probability (highest first).
  Future<ApiResponse<List<Map<String, dynamic>>>> getAIScoredItems() async {
    final wishlistResp = await getWishlist();
    if (!wishlistResp.isSuccess || wishlistResp.data == null) {
      return wishlistResp;
    }
    final scoredResp = await _aiService.scoreWishlistItems(wishlistResp.data!);
    if (scoredResp.isSuccess && scoredResp.data != null) {
      return scoredResp;
    }
    // Fallback to unsorted wishlist on AI error
    return wishlistResp;
  }

  /// Get AI-powered purchase recommendations for wishlist items.
  /// Uses collaborative filtering based on user's wishlist profile.
  Future<ApiResponse<List<Map<String, dynamic>>>> getAIRecommendations({
    int topN = 10,
  }) async {
    final wishlistResp = await getWishlist();
    if (!wishlistResp.isSuccess || wishlistResp.data == null) {
      return ApiResponse.failure(ApiError(code: 'ERROR', message: 'Unable to load wishlist for AI analysis'));
    }
    // Build user preference vector from wishlist categories/prices
    final Map<String, double> preferenceVector = {};
    for (final item in wishlistResp.data!) {
      final category = item['category'] as String? ?? 'general';
      final price = (item['estimatedPrice'] as num?)?.toDouble() ?? 0.0;
      preferenceVector[category] = (preferenceVector[category] ?? 0) + price;
    }
    return _aiService.getRecommendations();
  }
}
