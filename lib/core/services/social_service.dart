import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';
import 'ai_service.dart';

/// Service for social features: Heyya, chat, and updates.
/// Maps to backend SocialController.
/// Extends basic social features with AI-powered content analysis.
class SocialService {
  final ApiClient _api;
  final AIService _aiService;

  SocialService([ApiClient? api, AIService? aiService])
      : _api = api ?? ApiClient.instance,
        _aiService = aiService ?? AIService();

  /// Send a Heyya request to another user.
  Future<ApiResponse<Map<String, dynamic>>> sendHeyya({
    required String targetUserId,
    String? message,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.social.heyya,
      data: {
        'recipientId': targetUserId,
        if (message != null) 'message': message,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Respond to a Heyya request.
  Future<ApiResponse<Map<String, dynamic>>> respondToHeyya({
    required String heyyaId,
    required bool accepted,
    String? message,
  }) async {
    return _api.patch<Map<String, dynamic>>(
      ApiRoutes.social.heyyaRespond(heyyaId),
      data: {
        'accept': accepted,
        if (message != null) 'message': message,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get all chat sessions.
  Future<ApiResponse<List<Map<String, dynamic>>>> getChatSessions() async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.social.chatSessions,
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Create a new chat session.
  Future<ApiResponse<Map<String, dynamic>>> createChatSession({
    required String user1Id,
    required String user2Id,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.social.chatSessions,
      data: {'user1Id': user1Id, 'user2Id': user2Id},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Send a message in a chat session.
  Future<ApiResponse<Map<String, dynamic>>> sendMessage({
    required String sessionId,
    required String content,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.social.sessionMessages(sessionId),
      data: {'content': content},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get paginated messages for a chat session.
  Future<ApiResponse<List<Map<String, dynamic>>>> getMessages({
    required String sessionId,
    int page = 1,
    int limit = 50,
  }) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.social.sessionMessages(sessionId),
      queryParameters: {
        'page': page,
        'limit': limit,
      },
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Create a social update (post).
  Future<ApiResponse<Map<String, dynamic>>> createUpdate({
    required String content,
    List<String>? attachments,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.social.updates,
      data: {
        'content': content,
        if (attachments != null) 'attachments': attachments,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get paginated social updates feed.
  Future<ApiResponse<List<Map<String, dynamic>>>> getUpdates({
    int page = 1,
    int limit = 20,
  }) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.social.updates,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Like/engage with a social update.
  Future<ApiResponse<Map<String, dynamic>>> likeUpdate(
    String updateId,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.social.engagements,
      data: {'targetType': 'update', 'targetId': updateId, 'type': 'like'},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Comment on a social update.
  Future<ApiResponse<Map<String, dynamic>>> commentOnUpdate({
    required String updateId,
    required String content,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.social.commentsByUpdate(updateId),
      data: {'content': content},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Delete a comment by ID.
  Future<ApiResponse<Map<String, dynamic>>> deleteComment(String id) async {
    return _api.delete<Map<String, dynamic>>(
      ApiRoutes.social.commentById(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get all Heyya requests.
  Future<ApiResponse<List<Map<String, dynamic>>>> getHeyYaRequests() async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.social.heyya,
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Mark messages as read in a chat session.
  Future<ApiResponse<Map<String, dynamic>>> markMessagesAsRead(
    String sessionId,
  ) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.social.markRead(sessionId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get a social update by ID.
  Future<ApiResponse<Map<String, dynamic>>> getUpdateById(String id) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.social.updateById(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Update a social update.
  Future<ApiResponse<Map<String, dynamic>>> updateUpdate(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.social.updateById(id),
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Delete a social update.
  Future<ApiResponse<Map<String, dynamic>>> deleteUpdate(String id) async {
    return _api.delete<Map<String, dynamic>>(
      ApiRoutes.social.updateById(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Remove an engagement (unlike). Backend expects query params.
  Future<ApiResponse<Map<String, dynamic>>> removeEngagement({
    required String updateId,
    required String type,
  }) async {
    return _api.delete<Map<String, dynamic>>(
      ApiRoutes.social.engagements,
      queryParameters: {
        'targetType': 'update',
        'targetId': updateId,
        'type': type,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get engagements for a user.
  Future<ApiResponse<List<Map<String, dynamic>>>> getUserEngagements(
    String userId,
  ) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.social.userEngagements(userId),
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // AI-ENHANCED METHODS
  // ═══════════════════════════════════════════════════════════════════════

  /// Analyze sentiment of a social message or update.
  /// Returns score (-1 to +1), label, confidence.
  Future<ApiResponse<Map<String, dynamic>>> analyzeMessageSentiment(
    String content,
  ) {
    return _aiService.analyzeSentiment(content);
  }

  /// Detect intent from a Heyya message for smart suggestions.
  Future<ApiResponse<Map<String, dynamic>>> detectMessageIntent(
    String message,
  ) {
    return _aiService.detectIntent(message);
  }

  /// Extract keywords from social update for tagging/discovery.
  Future<ApiResponse<Map<String, dynamic>>> extractUpdateKeywords(
    String content, {
    int topN = 5,
  }) {
    return _aiService.extractKeywords(content, topN: topN);
  }

  /// Get personalized social feed based on user interests.
  Future<ApiResponse<List<Map<String, dynamic>>>> getPersonalizedFeed({
    required String userInterestText,
    required List<Map<String, dynamic>> feedItems,
    int topN = 20,
  }) {
    return _aiService.getPersonalizedFeed(
      interestText: userInterestText,
      contentItems: feedItems,
      topN: topN,
    );
  }

  /// Summarize conversation thread for quick overview.
  Future<ApiResponse<Map<String, dynamic>>> summarizeConversation(
    List<String> messages,
  ) {
    final combined = messages.join(' ');
    return _aiService.summariseText(combined);
  }

  /// Compute similarity between messages for thread grouping.
  Future<ApiResponse<Map<String, dynamic>>> computeMessageSimilarity(
    String message1,
    String message2,
  ) {
    return _aiService.textSimilarity(message1, message2);
  }

  /// Report a piece of content (update, comment, user).
  Future<ApiResponse<Map<String, dynamic>>> reportContent({
    required String contentId,
    required String contentType,
    required String reason,
    String? details,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.social.reports,
      data: {
        'contentId': contentId,
        'contentType': contentType,
        'reason': reason,
        if (details != null && details.isNotEmpty) 'details': details,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
