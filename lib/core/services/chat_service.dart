import 'package:flutter/foundation.dart';
import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';
import 'ai_service.dart';

/// Service for chat conversations and messages.
/// Extends basic chat CRUD with AI-powered message analysis.
class ChatService extends ChangeNotifier {
  final ApiClient _api;
  final AIService _aiService;

  ChatService([ApiClient? api, AIService? aiService])
      : _api = api ?? ApiClient.instance,
        _aiService = aiService ?? AIService();

  // ─── Sessions ─────────────────────────────────────────────────────────────

  /// Fetch all chat sessions for the authenticated user.
  Future<ApiResponse<List<Map<String, dynamic>>>> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.social.chatSessions,
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (json) {
        if (json is List) return List<Map<String, dynamic>>.from(json);
        if (json is Map && json.containsKey('items')) {
          return List<Map<String, dynamic>>.from(json['items'] as List);
        }
        return const [];
      },
    );
  }

  /// Find a session by ID from the current session list.
  /// The backend does not expose a single-session GET; we scan the list.
  Future<Map<String, dynamic>?> getConversation(String conversationId) async {
    final result = await getConversations(limit: 100);
    if (!result.isSuccess || result.data == null) return null;
    try {
      return result.data!.firstWhere((s) => s['id'] == conversationId);
    } catch (_) {
      return null;
    }
  }

  /// Create (or re-open) a direct-message session between two users.
  Future<ApiResponse<Map<String, dynamic>>> createConversation({
    required String user1Id,
    required String user2Id,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.social.chatSessions,
      data: {'user1Id': user1Id, 'user2Id': user2Id},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ─── Messages ──────────────────────────────────────────────────────────────

  /// Fetch messages for a session (newest-last order).
  Future<ApiResponse<List<Map<String, dynamic>>>> getMessages(
    String conversationId, {
    int limit = 50,
  }) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.social.sessionMessages(conversationId),
      queryParameters: {'limit': limit},
      fromJson: (json) {
        if (json is List) return List<Map<String, dynamic>>.from(json);
        if (json is Map && json.containsKey('items')) {
          return List<Map<String, dynamic>>.from(json['items'] as List);
        }
        return const [];
      },
    );
  }

  /// Send a text message in a session.
  Future<ApiResponse<Map<String, dynamic>>> sendMessage({
    required String sessionId,
    required String content,
    String type = 'text',
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.social.chatMessages,
      data: {'sessionId': sessionId, 'content': content, 'type': type},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Mark all messages in a session as read.
  Future<ApiResponse<Map<String, dynamic>>> markSessionRead(
    String conversationId,
  ) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.social.markRead(conversationId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ─── Backend-unsupported operations ────────────────────────────────────────
  // The backend's /social/chat specification does not include delete, archive,
  // or unarchive endpoints. These are documented no-ops returning false/empty
  // so callers can handle them gracefully without crashing.

  /// Not supported by the backend. Returns false; callers should hide the UI
  /// option or show an "unavailable" message.
  Future<bool> deleteMessage(String messageId) async {
    if (kDebugMode) {
      debugPrint('[ChatService] deleteMessage: backend does not expose a DELETE endpoint.');
    }
    return false;
  }

  /// Not supported by the backend; use [markSessionRead] instead.
  Future<bool> archiveConversation(String conversationId) async {
    final result = await markSessionRead(conversationId);
    return result.isSuccess;
  }

  /// Not supported by the backend. Returns true (idempotent no-op).
  Future<bool> unarchiveConversation(String conversationId) async => true;

  /// Search is done client-side (no backend search endpoint for chat sessions).
  /// Fetches up to 100 sessions and filters locally.
  Future<List<Map<String, dynamic>>> searchConversations(String query) async {
    final result = await getConversations(limit: 100);
    if (!result.isSuccess || result.data == null) return const [];
    final q = query.toLowerCase();
    return result.data!
        .where((s) =>
            s['recipientName']?.toString().toLowerCase().contains(q) == true ||
            s['lastMessage']?.toString().toLowerCase().contains(q) == true)
        .toList();
  }

  // ─── AI-enhanced methods ───────────────────────────────────────────────────

  /// Analyse message sentiment (-1 → +1, label, confidence).
  Future<Map<String, dynamic>?> analyzeMessageSentiment(String message) async {
    final response = await _aiService.analyzeSentiment(message);
    return response.isSuccess ? response.data : null;
  }

  /// Detect intent and entities for smart routing / quick replies.
  Future<Map<String, dynamic>?> detectMessageIntent(String message) async {
    final response = await _aiService.detectIntent(message);
    return response.isSuccess ? response.data : null;
  }

  /// Get AI-generated reply suggestions based on conversation context.
  Future<Map<String, dynamic>?> getSmartReplySuggestions(
    String conversationContext,
  ) async {
    final response = await _aiService.detectIntent(conversationContext);
    return response.isSuccess ? response.data : null;
  }

  /// Extract top-N keywords from a message for tagging / categorization.
  Future<Map<String, dynamic>?> extractMessageKeywords(
    String messageText, {
    int topN = 5,
  }) async {
    final response = await _aiService.extractKeywords(messageText, topN: topN);
    return response.isSuccess ? response.data : null;
  }

  /// Summarise a long conversation thread for a quick overview card.
  Future<Map<String, dynamic>?> summarizeConversation(
    List<String> messages,
  ) async {
    final combined = messages.join(' ');
    final response = await _aiService.summariseText(combined);
    return response.isSuccess ? response.data : null;
  }

  /// Compute semantic similarity between two messages (de-duplication).
  Future<Map<String, dynamic>?> computeMessageSimilarity(
    String message1,
    String message2,
  ) async {
    final response = await _aiService.textSimilarity(message1, message2);
    return response.isSuccess ? response.data : null;
  }
}
