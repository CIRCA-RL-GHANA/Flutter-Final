import 'dart:async';
import 'dart:math';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/foundation.dart';
import '../network/api_client.dart';

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String content;
  final String type;
  final DateTime createdAt;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? 'Unknown',
      content: json['content'] ?? '',
      type: json['type'] ?? 'text',
      createdAt: DateTime.tryParse(json['createdAt'] ?? DateTime.now().toIso8601String()) ?? DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }
}

class TypingIndicator {
  final String userId;
  final String username;
  final String conversationId;

  TypingIndicator({
    required this.userId,
    required this.username,
    required this.conversationId,
  });

  factory TypingIndicator.fromJson(Map<String, dynamic> json) {
    return TypingIndicator(
      userId: json['userId'] ?? '',
      username: json['username'] ?? 'User',
      conversationId: json['conversationId'] ?? '',
    );
  }
}

class WebSocketService extends ChangeNotifier {
  static final WebSocketService _instance = WebSocketService._internal();
  
  io.Socket? _socket;
  final _messageController = StreamController<ChatMessage>.broadcast();
  final _typingController = StreamController<TypingIndicator>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  
  String? _currentToken;
  String? _currentUserId;
  String? _currentBaseUrl;   // stored so reconnect after disconnect works
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const _maxReconnectAttempts = 10;
  bool _isDisposed = false;
  bool _permanentlyDisconnected = false;

  factory WebSocketService() => _instance;
  
  WebSocketService._internal();
  
  Stream<ChatMessage> get messages => _messageController.stream;
  Stream<TypingIndicator> get typing => _typingController.stream;
  Stream<bool> get connectionStatus => _connectionController.stream;

  /// Resets the permanent-disconnect flag so the service can reconnect.
  /// Call this when the user manually triggers a reconnect after max attempts.
  void resetReconnect() {
    _permanentlyDisconnected = false;
    _reconnectAttempts = 0;
  }

  bool get isConnected => _socket?.connected ?? false;

  /// Initialize and connect
  Future<void> connect({
    required String token,
    required String userId,
    required String baseUrl,
  }) async {
    _currentToken = token;
    _currentUserId = userId;
    _currentBaseUrl = baseUrl;

    try {
      _socket = io.io(
        '$baseUrl/chat',
        <String, dynamic>{
          'transports': ['websocket', 'polling'],
          'upgrade': true,
          'reconnection': true,
          'reconnectionDelay': 1000,
          'reconnectionDelayMax': 5000,
          'reconnectionAttempts': _maxReconnectAttempts,
          'auth': {
            'token': token,
          },
          'autoConnect': false,
        },
      );

      _setupEventListeners();
      _socket!.connect();
    } catch (e) {
      debugPrint('[WebSocket] Connection error: $e');
      _connectionController.add(false);
      _scheduleReconnect(baseUrl);
    }
  }

  void _setupEventListeners() {
    final s = _socket!;
    s.onConnect((_) {
      debugPrint('[WebSocket] Connected');
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
      _reconnectAttempts = 0;
      _connectionController.add(true);
      notifyListeners();
    });

    s.on('connection:confirmed', (data) {
      debugPrint('[WebSocket] Confirmed: $data');
    });

    s.on('message:new', (data) {
      final message = ChatMessage.fromJson(data);
      _messageController.add(message);
      notifyListeners();
    });

    s.on('message:ack', (data) {
      final message = ChatMessage.fromJson(data);
      _messageController.add(message);
    });

    s.on('user:typing', (data) {
      final typing = TypingIndicator.fromJson(data);
      _typingController.add(typing);
      notifyListeners();
    });

    s.on('user:stopped-typing', (data) {
      debugPrint('[WebSocket] User stopped typing');
    });

    s.on('message:read-receipt', (data) {
      debugPrint('[WebSocket] Message read: ${data['messageId']}');
    });

    s.on('message:deleted', (data) {
      debugPrint('[WebSocket] Message deleted: ${data['messageId']}');
    });

    s.on('error', (error) {
      debugPrint('[WebSocket] Error: $error');
    });

    s.onDisconnect((_) {
      debugPrint('[WebSocket] Disconnected');
      _connectionController.add(false);
      // Use the stored _currentBaseUrl — passing '' would block reconnection.
      _scheduleReconnect(_currentBaseUrl ?? '');
      notifyListeners();
    });

    s.onError((error) {
      debugPrint('[WebSocket] Error event: $error');
      _connectionController.add(false);
    });
  }

  /// Send message
  void sendMessage({
    required String conversationId,
    required String content,
    String type = 'text',
    List<String>? attachmentUrls,
  }) {
    if (!isConnected) {
      debugPrint('[WebSocket] Not connected, cannot send message');
      return;
    }

    _socket?.emit('message:send', {
      'conversationId': conversationId,
      'content': content,
      'type': type,
      'attachments': attachmentUrls ?? [],
    });
  }

  /// Emit typing indicator
  void emitTyping(String conversationId) {
    if (isConnected) {
      _socket?.emit('typing:start', {
        'conversationId': conversationId,
      });
    }
  }

  void stopTyping(String conversationId) {
    if (isConnected) {
      _socket?.emit('typing:stop', {
        'conversationId': conversationId,
      });
    }
  }

  /// Mark message as read
  void markMessageAsRead(String messageId) {
    if (isConnected) {
      _socket?.emit('message:read', {
        'messageId': messageId,
      });
    }
  }

  /// Join conversation
  void joinConversation(String conversationId) {
    if (isConnected) {
      _socket?.emit('conversation:join', {
        'conversationId': conversationId,
      });
    }
  }

  /// Leave conversation
  void leaveConversation(String conversationId) {
    if (isConnected) {
      _socket?.emit('conversation:leave', {
        'conversationId': conversationId,
      });
    }
  }

  /// Delete message
  void deleteMessage(String messageId) {
    if (isConnected) {
      _socket?.emit('message:delete', {
        'messageId': messageId,
      });
    }
  }

  /// Schedule reconnection
  void _scheduleReconnect(String baseUrl) {
    if (_permanentlyDisconnected) return;
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('[WebSocket] Max reconnect attempts reached — permanently disconnecting');
      _permanentlyDisconnected = true;
      // Signal the app to re-authenticate; emit false so UI can react.
      _connectionController.add(false);
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectAttempts++;

    final delaySeconds = (1000 * pow(1.5, _reconnectAttempts - 1)).toInt();
    debugPrint('[WebSocket] Reconnecting in ${delaySeconds}ms (attempt $_reconnectAttempts)');

    _reconnectTimer = Timer(Duration(milliseconds: delaySeconds), () {
      if (_currentToken != null && _currentUserId != null && baseUrl.isNotEmpty) {
        final freshToken = ApiClient.instance.cachedToken ?? _currentToken!;
        _currentToken = freshToken;
        connect(
          token: freshToken,
          userId: _currentUserId!,
          baseUrl: baseUrl,
        );
      }
    });
  }

  /// Disconnect
  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  /// Disconnect and prevent any auto-reconnect. Call this on user logout.
  /// Wire this up from the auth logout flow.
  void disconnectForLogout() {
    _permanentlyDisconnected = true;
    _reconnectAttempts = _maxReconnectAttempts;
    _currentToken = null;
    _currentUserId = null;
    disconnect();
  }

  /// Dispose
  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _messageController.close();
    _typingController.close();
    _connectionController.close();
    _socket?.dispose();
    _socket = null;
    _reconnectTimer?.cancel();
    super.dispose();
  }
}
