import 'package:flutter/foundation.dart';
import 'ai_service.dart';
import '../network/api_response.dart';

/// Message in a conversation thread.
class AiChatMessage {
  final String id;
  final String role; // 'user' | 'assistant'
  final String content;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata; // sentiment, intent, etc.

  const AiChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.metadata,
  });
}

/// Conversational AI assistant — wraps AIService inference calls and
/// maintains in-memory conversation history for context.
class AIAssistantService extends ChangeNotifier {
  final AIService _aiService;

  AIAssistantService([AIService? aiService])
      : _aiService = aiService ?? AIService();

  final List<AiChatMessage> _history = [];
  bool _isLoading = false;
  String? _error;

  List<AiChatMessage> get history    => List.unmodifiable(_history);
  bool                 get isLoading  => _isLoading;
  String?              get error      => _error;

  // ─────────────────────────────────────────────────────────────────────────
  // SEND MESSAGE
  // ─────────────────────────────────────────────────────────────────────────

  /// Send a user message and receive an AI-generated reply.
  /// [modelId] must correspond to an active backend AIModel record
  /// configured as a chat/assistant model.
  Future<AiChatMessage?> sendMessage({
    required String modelId,
    required String message,
    String? userId,
  }) async {
    _setLoading(true);

    // Append user turn immediately (optimistic)
    final userMsg = AiChatMessage(
      id:        DateTime.now().millisecondsSinceEpoch.toString(),
      role:      'user',
      content:   message,
      timestamp: DateTime.now(),
    );
    _history.add(userMsg);
    notifyListeners();

    try {
      // Enrich with NLP sentiment + intent in parallel
      final sentimentFuture = _aiService.analyzeSentiment(message);
      final intentFuture    = _aiService.detectIntent(message);

      // Create backend inference
      final inferenceResp = await _aiService.createInference(
        modelId:   modelId,
        inputData: {
          'message':           message,
          'conversationHistory': _history
              .map((m) => {'role': m.role, 'content': m.content})
              .toList(),
          if (userId != null) 'userId': userId,
        },
      );

      final sentimentResult = await sentimentFuture;
      final intentResult    = await intentFuture;

      String assistantContent = 'Thinking…';
      if (inferenceResp.isSuccess && inferenceResp.data != null) {
        assistantContent =
            inferenceResp.data!['output']?['content'] as String? ??
            inferenceResp.data!['content'] as String? ??
            'I processed your request.';
      }

      final assistantMsg = AiChatMessage(
        id:        '${DateTime.now().millisecondsSinceEpoch}_ai',
        role:      'assistant',
        content:   assistantContent,
        timestamp: DateTime.now(),
        metadata: {
          'inferenceId': inferenceResp.data?['id'],
          'sentiment':   sentimentResult.data,
          'intent':      intentResult.data,
        },
      );

      _history.add(assistantMsg);
      _error = null;
      _setLoading(false);
      return assistantMsg;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // QUICK ACTIONS
  // ─────────────────────────────────────────────────────────────────────────

  /// Analyse the sentiment of any arbitrary text (no conversation context).
  Future<Map<String, dynamic>?> quickSentiment(String text) async {
    final resp = await _aiService.analyzeSentiment(text);
    return resp.isSuccess ? resp.data : null;
  }

  /// Detect intent from text (for smart routing / search suggestions).
  Future<Map<String, dynamic>?> quickIntent(String text) async {
    final resp = await _aiService.detectIntent(text);
    return resp.isSuccess ? resp.data : null;
  }

  /// Get AI-powered ride price estimate.
  Future<Map<String, dynamic>?> getRidePrice({
    required double distance,
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
    String? rideType,
  }) async {
    final resp = await _aiService.computeRidePrice(
      baseDistance: distance,
      pickupLat:    fromLat,
      pickupLng:    fromLng,
      dropoffLat:   toLat,
      dropoffLng:   toLng,
      rideType:     rideType,
    );
    return resp.isSuccess ? resp.data : null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HISTORY MANAGEMENT
  // ─────────────────────────────────────────────────────────────────────────

  void clearHistory() {
    _history.clear();
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
