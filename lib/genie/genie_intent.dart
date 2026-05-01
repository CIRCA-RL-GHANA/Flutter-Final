/// ═══════════════════════════════════════════════════════════════════════════
/// GenieIntent – Structured Representation of Every User Request
/// Maps voice/text/tap inputs to a canonical module action with parameters.
/// ═══════════════════════════════════════════════════════════════════════════

/// The 12 platform modules Genie can orchestrate.
enum GenieModule {
  goPage,
  market,
  myUpdates,
  setupDashboard,
  alerts,
  live,
  qualChat,
  april,
  userDetails,
  utility,
  // Digital content marketplace
  eplay,
  // User-generated community spaces
  community,
  // Cross-module orchestration placeholder
  crossModule,
  // Genie-native (help, settings, unknown)
  genie,
  // Financial Institution Extension (loans, deposits, insurance, credit data)
  fintech,
}

/// A canonical action within a module.
class GenieIntent {
  final GenieModule module;
  final String action;
  final Map<String, dynamic> params;
  final bool requiresFullScreen;

  const GenieIntent({
    required this.module,
    required this.action,
    this.params = const {},
    this.requiresFullScreen = false,
  });

  @override
  String toString() =>
      'GenieIntent(module: ${module.name}, action: $action, params: $params)';
}

/// A single message/card in the Genie conversation thread.
class GenieMessage {
  final String id;
  final bool isUser;
  final String? text;
  final GenieCardType cardType;
  final Map<String, dynamic> cardData;
  final DateTime timestamp;

  const GenieMessage({
    required this.id,
    required this.isUser,
    this.text,
    this.cardType = GenieCardType.text,
    this.cardData = const {},
    required this.timestamp,
  });

  GenieMessage copyWith({
    String? text,
    GenieCardType? cardType,
    Map<String, dynamic>? cardData,
  }) {
    return GenieMessage(
      id: id,
      isUser: isUser,
      text: text ?? this.text,
      cardType: cardType ?? this.cardType,
      cardData: cardData ?? this.cardData,
      timestamp: timestamp,
    );
  }
}

/// The type of rich card Genie can render inline.
enum GenieCardType {
  text,
  greeting,
  balance,
  transaction,
  orderSummary,
  orderTracker,
  shopCarousel,
  feedCard,
  liveOrders,
  driverDelivery,
  alertList,
  chatList,
  operationsOverview,
  profileStrength,
  notificationHub,
  helpGuide,
  comingSoon,
  error,
  confirmation,
}

/// A quick-action chip shown in the bottom chip bar.
class GenieChip {
  final String label;
  final String emoji;
  final GenieIntent intent;
  final GenieModule module;

  const GenieChip({
    required this.label,
    required this.emoji,
    required this.intent,
    required this.module,
  });
}

/// A pinned shortcut in the persistent shortcut bar (max 4 per role).
class GeniePinnedShortcut {
  final String label;
  final String emoji;
  final GenieIntent intent;

  const GeniePinnedShortcut({
    required this.label,
    required this.emoji,
    required this.intent,
  });
}
