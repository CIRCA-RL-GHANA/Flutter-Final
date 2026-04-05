import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../services/websocket_service.dart';
import '../services/chat_service.dart';
import '../services/orders_service.dart';
import '../services/localstorage_service.dart';
import '../services/sync/sync_manager.dart';
import '../network/api_client.dart';
import '../services/ai_service.dart';
import '../services/ai_assistant_service.dart';
import '../services/ai_insights_notifier.dart';

// ignore_for_file: unused_import
// Dio import kept because ChatService / OrdersService constructors require it.

class AppProviders {
  static List<ChangeNotifierProvider> get providers => [
    // API Client
    ChangeNotifierProvider(
      create: (context) {
        final client = ApiClient.instance;
        return client;
      },
    ),

    // WebSocket Service
    ChangeNotifierProvider(
      create: (context) {
        final ws = WebSocketService();
        // Initialize will be called from main.dart with token
        return ws;
      },
    ),

    // Local Storage
    ChangeNotifierProvider(
      create: (context) {
        final storage = LocalStorageService();
        storage.init();
        return storage;
      },
    ),

    // Sync Manager
    ChangeNotifierProvider(
      create: (context) {
        final sync = SyncManager();
        sync.init();
        return sync;
      },
    ),

    // Chat Service
    ChangeNotifierProvider(
      create: (context) {
        final dio = context.read<ApiClient>().dio;
        return ChatService(dio);
      },
    ),

    // Orders Service
    ChangeNotifierProvider(
      create: (context) {
        final dio = context.read<ApiClient>().dio;
        return OrdersService(dio);
      },
    ),

    // AI Service (plain service — not a ChangeNotifier)
    Provider<AIService>(
      create: (_) => AIService(),
    ),

    // AI Assistant (conversational AI with history)
    ChangeNotifierProvider<AIAssistantService>(
      create: (_) => AIAssistantService(),
    ),

    // AI Insights Notifier (planner/financial AI state)
    ChangeNotifierProvider<AIInsightsNotifier>(
      create: (_) => AIInsightsNotifier(),
    ),
  ];

  // Provider shortcuts for easy access
  static ChatService chatService(context) =>
      context.read<ChatService>();

  static OrdersService ordersService(context) =>
      context.read<OrdersService>();

  static WebSocketService webSocket(context) =>
      context.read<WebSocketService>();

  static LocalStorageService localStorage(context) =>
      context.read<LocalStorageService>();

  static SyncManager syncManager(context) =>
      context.read<SyncManager>();

  static AIService aiService(context) =>
      context.read<AIService>();

  static AIAssistantService aiAssistant(context) =>
      context.read<AIAssistantService>();

  static AIInsightsNotifier aiInsights(context) =>
      context.read<AIInsightsNotifier>();
}

// ── Riverpod providers (for ConsumerWidget / ConsumerStatefulWidget screens) ─

final chatServiceProvider = ChangeNotifierProvider<ChatService>(
  (ref) => ChatService(ApiClient.instance.dio),
);

final ordersServiceProvider = ChangeNotifierProvider<OrdersService>(
  (ref) => OrdersService(ApiClient.instance.dio),
);
