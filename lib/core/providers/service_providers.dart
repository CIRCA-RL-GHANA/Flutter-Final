// ignore_for_file: unused_import
// This file provides Riverpod-scoped service providers consumed by Riverpod
// screens (ConsumerWidget / ConsumerStatefulWidget).  The global Provider tree
// is managed by AppProviders in app_providers.dart.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/chat_service.dart';
import '../services/orders_service.dart';

// ── Riverpod providers (for ConsumerWidget / ConsumerStatefulWidget screens) ─

// ChatService extends ChangeNotifier — still uses ChangeNotifierProvider.
final chatServiceProvider = ChangeNotifierProvider<ChatService>(
  (ref) => ChatService(),
);

// OrdersService is a plain service class (no longer a ChangeNotifier).
// Use Provider<T> so Riverpod doesn't require ChangeNotifier.
final ordersServiceProvider = Provider<OrdersService>(
  (ref) => OrdersService(),
);
