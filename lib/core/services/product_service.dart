import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';
import 'ai_service.dart';

/// Service for product management.
/// Maps to backend ProductsController.
/// Extends basic product CRUD with AI-powered recommendations and pricing.
class ProductService {
  final ApiClient _api;
  final AIService _aiService;

  ProductService([ApiClient? api, AIService? aiService])
      : _api = api ?? ApiClient.instance,
        _aiService = aiService ?? AIService();

  /// Create a new product.
  Future<ApiResponse<Map<String, dynamic>>> createProduct(
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.products.create,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get paginated list of products with optional filters.
  Future<ApiResponse<List<Map<String, dynamic>>>> getProducts({
    int page = 1,
    int limit = 20,
    String? entityId,
    String? category,
  }) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.products.list,
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

  /// Search products by query string.
  Future<ApiResponse<List<Map<String, dynamic>>>> searchProducts(
    String query,
  ) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.products.search,
      queryParameters: {'q': query},
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get a single product by ID.
  Future<ApiResponse<Map<String, dynamic>>> getProductById(String id) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.products.byId(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Update an existing product.
  Future<ApiResponse<Map<String, dynamic>>> updateProduct(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _api.patch<Map<String, dynamic>>(
      ApiRoutes.products.byId(id),
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Delete a product by ID.
  Future<ApiResponse<Map<String, dynamic>>> deleteProduct(String id) async {
    return _api.delete<Map<String, dynamic>>(
      ApiRoutes.products.byId(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Update stock quantity for a product.
  Future<ApiResponse<Map<String, dynamic>>> updateStock({
    required String id,
    required int quantity,
    required String operation,
  }) async {
    return _api.patch<Map<String, dynamic>>(
      ApiRoutes.products.updateStock(id),
      data: {
        'quantity': quantity,
        'operation': operation,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Record a product view.
  Future<ApiResponse<Map<String, dynamic>>> viewProduct(String id) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.products.view(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Rate and review a product.
  Future<ApiResponse<Map<String, dynamic>>> rateProduct({
    required String id,
    required int rating,
    int reviewCount = 1,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.products.rate(id),
      data: {
        'rating': rating,
        'reviewCount': reviewCount,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get products by entity ID.
  Future<ApiResponse<List<Map<String, dynamic>>>> getByEntity(
    String entityId,
  ) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.products.byEntity(entityId),
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Delete product media.
  Future<ApiResponse<Map<String, dynamic>>> deleteMedia(String id) async {
    return _api.delete<Map<String, dynamic>>(
      ApiRoutes.products.deleteMedia(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get a discount by ID.
  Future<ApiResponse<Map<String, dynamic>>> getDiscountById(
    String id,
  ) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.products.discountById(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Update a discount.
  Future<ApiResponse<Map<String, dynamic>>> updateDiscount(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.products.discountById(id),
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Delete a discount.
  Future<ApiResponse<Map<String, dynamic>>> deleteDiscount(String id) async {
    return _api.delete<Map<String, dynamic>>(
      ApiRoutes.products.discountById(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Resolve a product SOS.
  Future<ApiResponse<Map<String, dynamic>>> resolveSOS(String id) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.products.resolveSOS(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Cancel a product SOS.
  Future<ApiResponse<Map<String, dynamic>>> cancelSOS(String id) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.products.cancelSOS(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get a delivery zone by ID.
  Future<ApiResponse<Map<String, dynamic>>> getDeliveryZoneById(
    String id,
  ) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.products.deliveryZoneById(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get delivery zones by product.
  Future<ApiResponse<List<Map<String, dynamic>>>> getDeliveryZonesByProduct(
    String productId,
  ) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.products.deliveryZonesByProduct(productId),
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Update a delivery zone.
  Future<ApiResponse<Map<String, dynamic>>> updateDeliveryZone(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.products.deliveryZoneById(id),
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Delete a delivery zone.
  Future<ApiResponse<Map<String, dynamic>>> deleteDeliveryZone(
    String id,
  ) async {
    return _api.delete<Map<String, dynamic>>(
      ApiRoutes.products.deliveryZoneById(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Add media to a product.
  Future<ApiResponse<Map<String, dynamic>>> addProductMedia(
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.products.media,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get media for a product.
  Future<ApiResponse<List<Map<String, dynamic>>>> getProductMedia(
    String productId,
  ) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.products.mediaByProduct(productId),
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Create a discount tier.
  Future<ApiResponse<Map<String, dynamic>>> createDiscount(
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.products.discounts,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get all discount tiers.
  Future<ApiResponse<List<Map<String, dynamic>>>> getDiscounts() async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.products.discounts,
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get active discounts for a product.
  Future<ApiResponse<List<Map<String, dynamic>>>> getActiveDiscounts(
    String productId,
  ) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.products.activeDiscounts(productId),
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Create an SOS alert for a product.
  Future<ApiResponse<Map<String, dynamic>>> createSOSAlert(
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.products.sos,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get all SOS alerts.
  Future<ApiResponse<List<Map<String, dynamic>>>> getSOSAlerts() async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.products.sos,
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Create a delivery zone.
  Future<ApiResponse<Map<String, dynamic>>> createDeliveryZone(
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.products.deliveryZones,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get all delivery zones.
  Future<ApiResponse<List<Map<String, dynamic>>>> getDeliveryZones() async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.products.deliveryZones,
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Find a delivery zone by location.
  Future<ApiResponse<Map<String, dynamic>>> findDeliveryZoneByLocation({
    required double latitude,
    required double longitude,
  }) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.products.findDeliveryZoneByLocation,
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // AI-ENHANCED METHODS
  // ═══════════════════════════════════════════════════════════════════════

  /// Get AI-recommended discount percentage for a product.
  /// Analyzes views, conversion, stock, and days since last sale.
  Future<ApiResponse<Map<String, dynamic>>> getAIRecommendedDiscount({
    required double currentPrice,
    required int daysSinceLastSale,
    required int viewCount,
    required double conversionRate,
    required int stockLevel,
  }) {
    return _aiService.recommendDiscount(
      currentPrice: currentPrice,
      daysSinceLastSale: daysSinceLastSale,
      viewCount: viewCount,
      conversionRate: conversionRate,
      stockLevel: stockLevel,
    );
  }

  /// Get AI-powered similar products using content-based filtering.
  /// Finds items matching the target product's tags/description.
  Future<ApiResponse<List<Map<String, dynamic>>>> getAISimilarProducts({
    required String targetProductTags,
    required List<Map<String, dynamic>> catalogueItems,
    int topN = 10,
  }) {
    return _aiService.getSimilarItems(
      targetTags: targetProductTags,
      catalogueItems: catalogueItems,
      topN: topN,
    );
  }

  /// Get personalized product recommendations based on purchase history.
  Future<ApiResponse<List<Map<String, dynamic>>>> getAIProductRecommendations({
    required String purchaseHistoryText,
    required List<Map<String, dynamic>> catalogueItems,
    int topN = 10,
  }) {
    return _aiService.getProductRecommendations(
      purchasedTexts: purchaseHistoryText,
      catalogueItems: catalogueItems,
      topN: topN,
    );
  }

  /// Semantic search across products using AI TF-IDF.
  Future<ApiResponse<List<Map<String, dynamic>>>> aiSemanticSearch({
    required String query,
    required List<Map<String, dynamic>> products,
    int topN = 20,
  }) {
    final documents = products.map((p) => {
      'id': p['id'] ?? '',
      'text': '${p['name'] ?? ''} ${p['description'] ?? ''} ${p['category'] ?? ''}',
    }).toList();
    return _aiService.searchDocuments(
      query: query,
      documents: documents,
      topN: topN,
    );
  }

  /// Extract keywords from product description for SEO/tagging.
  Future<ApiResponse<Map<String, dynamic>>> extractProductKeywords(
    String productDescription, {
    int topN = 10,
  }) {
    return _aiService.extractKeywords(productDescription, topN: topN);
  }
}
