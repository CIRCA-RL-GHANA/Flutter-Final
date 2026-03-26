import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'ai_service.dart';

/// Service for chat conversations and messages.
/// Extends basic chat CRUD with AI-powered message analysis.
class ChatService extends ChangeNotifier {
  final Dio _dio;
  final AIService _aiService;
  static const String _baseEndpoint = '/chat';

  ChatService(this._dio, [AIService? aiService])
      : _aiService = aiService ?? AIService();

  // Get conversations
  Future<List<Map<String, dynamic>>> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseEndpoint/conversations',
        queryParameters: {
          'page': page,
          'limit': limit,
          'sortBy': 'updatedAt',
          'sortOrder': 'DESC',
        },
      );

      final data = response.data['data'];
      if (data is Map && data.containsKey('items')) {
        return List<Map<String, dynamic>>.from(data['items']);
      }
      return [];
    } catch (e) {
      debugPrint('[ChatService] Error fetching conversations: $e');
      return [];
    }
  }

  // Get conversation details
  Future<Map<String, dynamic>?> getConversation(String conversationId) async {
    try {
      final response = await _dio.get('$_baseEndpoint/conversations/$conversationId');
      return response.data['data'];
    } catch (e) {
      debugPrint('[ChatService] Error fetching conversation: $e');
      return null;
    }
  }

  // Get messages for conversation
  Future<List<Map<String, dynamic>>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseEndpoint/$conversationId/messages',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final data = response.data['data'];
      if (data is Map && data.containsKey('items')) {
        return List<Map<String, dynamic>>.from(data['items']);
      }
      return [];
    } catch (e) {
      debugPrint('[ChatService] Error fetching messages: $e');
      return [];
    }
  }

  // Create conversation
  Future<Map<String, dynamic>?> createConversation({
    required List<String> participantIds,
    String type = 'direct',
  }) async {
    try {
      final response = await _dio.post(
        '$_baseEndpoint/conversations',
        data: {
          'participantIds': participantIds,
          'type': type,
        },
      );

      return response.data['data'];
    } catch (e) {
      debugPrint('[ChatService] Error creating conversation: $e');
      return null;
    }
  }

  // Delete message
  Future<bool> deleteMessage(String messageId) async {
    try {
      await _dio.delete('$_baseEndpoint/messages/$messageId');
      return true;
    } catch (e) {
      debugPrint('[ChatService] Error deleting message: $e');
      return false;
    }
  }

  // Archive conversation
  Future<bool> archiveConversation(String conversationId) async {
    try {
      await _dio.patch(
        '$_baseEndpoint/conversations/$conversationId',
        data: {'isArchived': true},
      );
      return true;
    } catch (e) {
      debugPrint('[ChatService] Error archiving conversation: $e');
      return false;
    }
  }

  // Unarchive conversation
  Future<bool> unarchiveConversation(String conversationId) async {
    try {
      await _dio.patch(
        '$_baseEndpoint/conversations/$conversationId',
        data: {'isArchived': false},
      );
      return true;
    } catch (e) {
      debugPrint('[ChatService] Error unarchiving: $e');
      return false;
    }
  }

  // Search conversations
  Future<List<Map<String, dynamic>>> searchConversations(String query) async {
    try {
      final response = await _dio.get(
        '$_baseEndpoint/conversations/search',
        queryParameters: {'q': query},
      );

      final data = response.data['data'];
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      debugPrint('[ChatService] Error searching: $e');
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // AI-ENHANCED METHODS
  // ═══════════════════════════════════════════════════════════════════════

  /// Analyze sentiment of a message for tone detection.
  /// Returns score (-1 to +1), label (positive/negative/neutral), confidence.
  Future<Map<String, dynamic>?> analyzeMessageSentiment(String message) async {
    final response = await _aiService.analyzeSentiment(message);
    return response.isSuccess ? response.data : null;
  }

  /// Detect intent and entities from a message for smart routing.
  /// Useful for customer support routing and quick replies.
  Future<Map<String, dynamic>?> detectMessageIntent(String message) async {
    final response = await _aiService.detectIntent(message);
    return response.isSuccess ? response.data : null;
  }

  /// Get AI-generated smart reply suggestions based on conversation context.
  Future<Map<String, dynamic>?> getSmartReplySuggestions(
    String conversationContext,
  ) async {
    final response = await _aiService.detectIntent(conversationContext);
    return response.isSuccess ? response.data : null;
  }

  /// Extract keywords from messages for tagging/categorization.
  Future<Map<String, dynamic>?> extractMessageKeywords(
    String messageText, {
    int topN = 5,
  }) async {
    final response = await _aiService.extractKeywords(messageText, topN: topN);
    return response.isSuccess ? response.data : null;
  }

  /// Summarize a long conversation thread for quick overview.
  Future<Map<String, dynamic>?> summarizeConversation(
    List<String> messages,
  ) async {
    final combinedText = messages.join(' ');
    final response = await _aiService.summariseText(combinedText);
    return response.isSuccess ? response.data : null;
  }

  /// Compute similarity between two messages for de-duplication.
  Future<Map<String, dynamic>?> computeMessageSimilarity(
    String message1,
    String message2,
  ) async {
    final response = await _aiService.textSimilarity(message1, message2);
    return response.isSuccess ? response.data : null;
  }
}
