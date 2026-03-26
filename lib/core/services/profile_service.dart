import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';
import 'ai_service.dart';

/// Service for managing user profiles.
/// Maps to backend ProfilesController.
/// Extends basic profile CRUD with AI-powered text analysis and recommendations.
class ProfileService {
  final ApiClient _api;
  final AIService _aiService;

  ProfileService([ApiClient? api, AIService? aiService])
      : _api = api ?? ApiClient.instance,
        _aiService = aiService ?? AIService();

  /// Create a new profile
  Future<ApiResponse<Map<String, dynamic>>> createProfile({
    required String userId,
    String? username,
    String? photoPath,
    String? bio,
    Map<String, dynamic>? visibility,
    Map<String, dynamic>? interactionPreferences,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.profiles.create,
      data: {
        'userId': userId,
        if (username != null) 'username': username,
        if (photoPath != null) 'photoPath': photoPath,
        if (bio != null) 'bio': bio,
        if (visibility != null) 'visibility': visibility,
        if (interactionPreferences != null)
          'interactionPreferences': interactionPreferences,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get profile by ID
  Future<ApiResponse<Map<String, dynamic>>> getProfileById(String id) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.profiles.byId(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get profile by user ID
  Future<ApiResponse<Map<String, dynamic>>> getProfileByUserId(
    String userId,
  ) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.profiles.byUser(userId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get profile by entity ID
  Future<ApiResponse<Map<String, dynamic>>> getProfileByEntityId(
    String entityId,
  ) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.profiles.byEntity(entityId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Update profile
  Future<ApiResponse<Map<String, dynamic>>> updateProfile({
    required String id,
    String? username,
    String? photoPath,
    String? bio,
  }) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.profiles.byId(id),
      data: {
        if (username != null) 'username': username,
        if (photoPath != null) 'photoPath': photoPath,
        if (bio != null) 'bio': bio,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Delete profile
  Future<ApiResponse<Map<String, dynamic>>> deleteProfile(String id) async {
    return _api.delete<Map<String, dynamic>>(
      ApiRoutes.profiles.byId(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Update visibility settings
  Future<ApiResponse<Map<String, dynamic>>> updateVisibility({
    required String profileId,
    required Map<String, dynamic> visibility,
  }) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.profiles.visibility(profileId),
      data: visibility,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Update interaction preferences
  Future<ApiResponse<Map<String, dynamic>>> updateInteractionPreferences({
    required String profileId,
    required Map<String, dynamic> preferences,
  }) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.profiles.interaction(profileId),
      data: preferences,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get visibility settings for a profile.
  Future<ApiResponse<Map<String, dynamic>>> getVisibilitySettings(
    String profileId,
  ) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.profiles.visibility(profileId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get interaction preferences for a profile.
  Future<ApiResponse<Map<String, dynamic>>> getInteractionPreferences(
    String profileId,
  ) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.profiles.interaction(profileId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // AI-ENHANCED METHODS
  // ═══════════════════════════════════════════════════════════════════════

  /// Extract keywords from user bio for interest tagging.
  Future<ApiResponse<Map<String, dynamic>>> extractBioKeywords(
    String bio, {
    int topN = 10,
  }) {
    return _aiService.extractKeywords(bio, topN: topN);
  }

  /// Analyze sentiment of user bio for tone assessment.
  Future<ApiResponse<Map<String, dynamic>>> analyzeBioSentiment(String bio) {
    return _aiService.analyzeSentiment(bio);
  }

  /// Get AI-summarized profile insights from bio and activity.
  Future<ApiResponse<Map<String, dynamic>>> getProfileSummary(
    String bioAndActivityText,
  ) {
    return _aiService.summariseText(bioAndActivityText);
  }

  /// Get personalized content feed based on user interests.
  Future<ApiResponse<List<Map<String, dynamic>>>> getPersonalizedFeed({
    required String userInterestText,
    required List<Map<String, dynamic>> contentItems,
    int topN = 20,
  }) {
    return _aiService.getPersonalizedFeed(
      interestText: userInterestText,
      contentItems: contentItems,
      topN: topN,
    );
  }

  /// Recommend subscription plan based on user activity.
  Future<ApiResponse<Map<String, dynamic>>> recommendSubscriptionPlan({
    required double usageScore,
    required String currentTier,
    required List<Map<String, dynamic>> availablePlans,
  }) {
    return _aiService.recommendSubscriptionPlan(
      usageScore: usageScore,
      currentTier: currentTier,
      plans: availablePlans,
    );
  }

  /// Get retention offer for a subscriber based on engagement.
  Future<ApiResponse<Map<String, dynamic>>> getRetentionOffer({
    required int monthsSubscribed,
    required int lastLoginDaysAgo,
    required double featureUsageScore,
    required double currentMonthlyPrice,
  }) {
    return _aiService.suggestRetentionOffer(
      monthsSubscribed: monthsSubscribed,
      lastLoginDaysAgo: lastLoginDaysAgo,
      featureUsageScore: featureUsageScore,
      currentMonthlyPrice: currentMonthlyPrice,
    );
  }
}
