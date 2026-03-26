import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

class LocalStorageService extends ChangeNotifier {
  late Box<Map> _messagesBox;
  late Box<Map> _conversationsBox;
  late Box<String> _preferencesBox;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      _messagesBox = await Hive.openBox<Map>('local_messages');
      _conversationsBox = await Hive.openBox<Map>('local_conversations');
      _preferencesBox = await Hive.openBox<String>('preferences');
      
      _isInitialized = true;
      debugPrint('[LocalStorage] Initialized');
      
      notifyListeners();
    } catch (e) {
      debugPrint('[LocalStorage] Init error: $e');
    }
  }

  /// Save message locally
  Future<void> saveMessage(String conversationId, Map<String, dynamic> message) async {
    if (!_isInitialized) return;

    try {
      final key = '${conversationId}_${message['id'] ?? DateTime.now().millisecondsSinceEpoch}';
      await _messagesBox.put(key, message);
      debugPrint('[LocalStorage] Message saved: $key');
    } catch (e) {
      debugPrint('[LocalStorage] Save message error: $e');
    }
  }

  /// Get messages for conversation
  Future<List<Map<String, dynamic>>> getMessages(String conversationId) async {
    if (!_isInitialized) return [];

    try {
      final allMessages = _messagesBox.values
          .map((m) => Map<String, dynamic>.from(m))
          .where((m) => m['conversationId'] == conversationId)
          .toList();

      return allMessages;
    } catch (e) {
      debugPrint('[LocalStorage] Get messages error: $e');
      return [];
    }
  }

  /// Save conversation locally
  Future<void> saveConversation(Map<String, dynamic> conversation) async {
    if (!_isInitialized) return;

    try {
      await _conversationsBox.put(conversation['id'], conversation);
      debugPrint('[LocalStorage] Conversation saved: ${conversation['id']}');
    } catch (e) {
      debugPrint('[LocalStorage] Save conversation error: $e');
    }
  }

  /// Get all conversations
  Future<List<Map<String, dynamic>>> getConversations() async {
    if (!_isInitialized) return [];

    try {
      final conversations = _conversationsBox.values
          .map((c) => Map<String, dynamic>.from(c))
          .toList();

      return conversations;
    } catch (e) {
      debugPrint('[LocalStorage] Get conversations error: $e');
      return [];
    }
  }

  /// Save preference
  Future<void> savePreference(String key, String value) async {
    if (!_isInitialized) return;

    try {
      await _preferencesBox.put(key, value);
    } catch (e) {
      debugPrint('[LocalStorage] Save preference error: $e');
    }
  }

  /// Get preference
  String? getPreference(String key) {
    if (!_isInitialized) return null;
    return _preferencesBox.get(key);
  }

  /// Clear local data
  Future<void> clearAll() async {
    if (!_isInitialized) return;

    try {
      await _messagesBox.clear();
      await _conversationsBox.clear();
      debugPrint('[LocalStorage] Cleared all data');
    } catch (e) {
      debugPrint('[LocalStorage] Clear error: $e');
    }
  }

  /// Get storage size
  Future<int> getStorageSize() async {
    if (!_isInitialized) return 0;

    try {
      int size = 0;
      size += _messagesBox.values.length;
      size += _conversationsBox.values.length;
      return size;
    } catch (e) {
      debugPrint('[LocalStorage] Get size error: $e');
      return 0;
    }
  }
}
