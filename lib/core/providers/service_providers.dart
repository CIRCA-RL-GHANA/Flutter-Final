// ignore_for_file: unused_import
// This file provides Riverpod-scoped service providers consumed by Riverpod
// screens (ConsumerWidget / ConsumerStatefulWidget).  The global Provider tree
// is managed by AppProviders in app_providers.dart.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/chat_service.dart';
import '../services/orders_service.dart';
import '../network/api_client.dart';

// ── Riverpod providers (for ConsumerWidget / ConsumerStatefulWidget screens) ─

final chatServiceProvider = ChangeNotifierProvider<ChatService>(
  (ref) => ChatService(ApiClient.instance.dio),
);

final ordersServiceProvider = ChangeNotifierProvider<OrdersService>(
  (ref) => OrdersService(ApiClient.instance.dio),
);
