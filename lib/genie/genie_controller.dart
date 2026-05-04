/// ═══════════════════════════════════════════════════════════════════════════
/// GenieController – Central Orchestrator (ChangeNotifier)
///
/// Sits between the GenieScreen UI and all module services/providers.
/// Handles: NLU → RBAC → Response building → Message thread management.
/// Maintains conversation history, context memory, and offline queue.
/// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../features/prompt/models/rbac_models.dart';
import '../features/prompt/providers/context_provider.dart';
import 'genie_empty_state.dart';
import 'genie_haptic_role_signature.dart';
import 'genie_input_sanitizer.dart';
import 'genie_intent.dart';
import 'genie_intent_resolver.dart';
import 'genie_offline_cache.dart';
import 'genie_onboarding.dart';
import 'genie_outbox.dart';
import 'genie_performance_telemetry.dart';
import 'genie_rbac_enforcer.dart';
import 'genie_tactile_actions.dart';
import 'genie_voice.dart';

class GenieController extends ChangeNotifier {
  final ContextProvider _contextProvider;

  GenieController({required ContextProvider contextProvider})
      : _contextProvider = contextProvider {
    _init();
  }

  // ─── State ─────────────────────────────────────────────────────────────────
  final List<GenieMessage> _messages = [];
  List<GenieMessage> get messages => List.unmodifiable(_messages);

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  bool _isListening = false;
  bool get isListening => _isListening;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  // Pinned floating tiles (module → card data)
  final Map<GenieModule, Map<String, dynamic>> _pinnedTiles = {};
  Map<GenieModule, Map<String, dynamic>> get pinnedTiles =>
      Map.unmodifiable(_pinnedTiles);

  UserRole get _role => _contextProvider.currentRole;
  AppContextModel get _activeContext => _contextProvider.activeContext;

  // ─── Init ──────────────────────────────────────────────────────────────────
  void _init() {
    // Bootstrap persistent services
    unawaited(_bootstrapServices());
    _sendGreeting();
    _configureVoice();
  }

  Future<void> _bootstrapServices() async {
    await Future.wait([
      GenieOfflineCache.init(),
      GenieOutbox.init(),
      GenieOnboarding.init(),
      GeniePerformanceTelemetry.init(),
    ]);
    // Fire role signature on first open
    await GenieHapticRoleSignature.onGenieOpen(_role);
    // Resume any interrupted orchestrations
    final pending = GenieOutbox.getPendingOrchestrations();
    if (pending.isNotEmpty) {
      _addGenieMessage(
        text: 'Resuming ${pending.length} incomplete action(s) from your last session…',
        cardType: GenieCardType.text,
        cardData: {'pendingOrchestrations': pending.map((o) => o.id).toList()},
      );
    }
    // Show onboarding greeting on first launch
    if (GenieOnboarding.isFirstLaunchForRole(_role)) {
      final greet = GenieOnboarding.greetingForRole(_role);
      _addGenieMessage(
        text: greet.headline,
        cardType: GenieCardType.greeting,
        cardData: {
          'subline': greet.subline,
          'examples': greet.exampleCommands,
          'ctaLabel': greet.ctaLabel,
          'isOnboarding': true,
        },
      );
      await GenieOnboarding.markFirstLaunchComplete(_role);
    }
  }

  void _configureVoice() {
    GenieVoice.instance.configure(
      onResult: (transcript) => handleInput(transcript),
      onStatus: (status) {
        _isListening = status == GenieVoiceStatus.listening;
        notifyListeners();
      },
    );
  }

  // ─── Greeting ─────────────────────────────────────────────────────────────
  void _sendGreeting() {
    final hour = DateTime.now().hour;
    final timeGreet = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    final name = _activeContext.name.isNotEmpty
        ? _activeContext.name
        : 'there';

    final roleLabel = _activeContext.roleLabel;
    final greeting = '$timeGreet, $roleLabel $name. '
        'I\'m Genie — tap a shortcut, type, or say "Hey Genie" '
        'to get started. What can I do for you?';

    _addGenieMessage(
      text: greeting,
      cardType: GenieCardType.greeting,
      cardData: {
        'role': _role.name,
        'name': name,
        'chips': GenieRBACEnforcer.getDefaultChips(_role)
            .map((c) => {'label': c.label, 'emoji': c.emoji})
            .toList(),
      },
    );
  }

  // ─── Main Input Handler ────────────────────────────────────────────────────
  /// Entry point for all text, voice, and chip inputs.
  Future<void> handleInput(String rawInput) async {
    // ── 1. Input Sanitization ──────────────────────────────────────────────
    final sanitized = GenieInputSanitizer.sanitize(rawInput);
    if (sanitized.rejected) {
      await GenieTactileActions.onError();
      _addGenieMessage(
        text: 'I couldn\'t process that input. Please try again.',
        cardType: GenieCardType.text,
      );
      return;
    }
    final input = sanitized.cleanedText;
    if (input.isEmpty) return;

    // ── 2. Telemetry: start task completion timer ──────────────────────────
    final timerKey = 'task_${DateTime.now().millisecondsSinceEpoch}';
    GeniePerformanceTelemetry.startTimer(timerKey);

    // Add user bubble
    _addUserMessage(input);
    _isProcessing = true;
    notifyListeners();

    // ── 3. Intent Resolution ──────────────────────────────────────────────
    GeniePerformanceTelemetry.startTimer('nlu_resolve');
    final intent = GenieIntentResolver.resolve(input) ??
        const GenieIntent(module: GenieModule.genie, action: 'unknown');
    GeniePerformanceTelemetry.stopTimer(
        'nlu_resolve', TelemetryEventType.modelInference,
        meta: {'module': intent.module.name, 'action': intent.action});

    // ── 4. Confusion detection ────────────────────────────────────────────
    if (intent.action == 'unknown') {
      final shouldShowLifeline = await GenieOnboarding.recordIntentFailure();
      if (shouldShowLifeline) {
        final lifeline = GenieOnboarding.confusionLifeline();
        if (lifeline != null) {
          _addGenieMessage(
            text: lifeline.message,
            cardType: GenieCardType.text,
            cardData: {
              'actionLabel': lifeline.actionLabel,
              'actionIntent': lifeline.actionIntent?.action,
              'isTip': true,
            },
          );
        }
      }
    } else {
      await GenieOnboarding.resetConfusion();
    }

    // ── 5. RBAC gate ──────────────────────────────────────────────────────
    if (!GenieRBACEnforcer.canPerformAction(_role, intent.module, intent.action)) {
      final denial = GenieRBACEnforcer.getDenialMessage(
          _role, intent.module, intent.action);
      await GenieTactileActions.onError();
      _addGenieMessage(text: denial, cardType: GenieCardType.text);
      _isProcessing = false;
      notifyListeners();
      return;
    }

    // ── 6. Offline handling with cache ────────────────────────────────────
    if (!_isOnline) {
      final cached = GenieOfflineCache.retrieve(_role, intent.module, intent.action)
          ?? GenieOfflineCache.staticFallback(_role, intent.module, intent.action);
      if (cached != null) {
        _addGenieMessage(
          text: cached.text,
          cardType: GenieCardType.values
              .firstWhere((t) => t.name == cached.cardType,
                  orElse: () => GenieCardType.text),
          cardData: cached.cardData,
        );
      } else if (intent.requiresFullScreen) {
        _addGenieMessage(
          text: 'You\'re offline. This action will run when you reconnect.',
          cardType: GenieCardType.text,
        );
        _queueOfflineIntent(intent);
      }
      _isProcessing = false;
      notifyListeners();
      return;
    }

    // ── 7. Build response ─────────────────────────────────────────────────
    await Future.delayed(const Duration(milliseconds: 300));
    final response = _buildResponse(intent);
    await GenieTactileActions.onSuccess();
    _addGenieMessage(
      text: response.text,
      cardType: response.cardType,
      cardData: response.cardData,
    );

    // ── 8. Cache the live response for offline use ────────────────────────
    unawaited(GenieOfflineCache.store(
      _role,
      intent.module,
      intent.action,
      CachedIntentResponse(
        text: response.text ?? '',
        cardType: response.cardType.name,
        cardData: response.cardData,
        cachedAt: DateTime.now(),
      ),
    ));

    // ── 9. Stop task completion timer ─────────────────────────────────────
    GeniePerformanceTelemetry.stopTimer(
        timerKey, TelemetryEventType.taskCompletion,
        meta: {'module': intent.module.name, 'action': intent.action});

    _isProcessing = false;
    notifyListeners();
  }

  /// Directly execute a GenieIntent (from chip taps or card buttons).
  Future<void> executeIntent(GenieIntent intent) async {
    if (!GenieRBACEnforcer.canPerformAction(_role, intent.module, intent.action)) {
      final denial = GenieRBACEnforcer.getDenialMessage(
          _role, intent.module, intent.action);
      await GenieTactileActions.onError();
      _addGenieMessage(text: denial, cardType: GenieCardType.text);
      notifyListeners();
      return;
    }

    _isProcessing = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 200));
    final response = _buildResponse(intent);
    await GenieTactileActions.onSuccess();
    _addGenieMessage(
      text: response.text,
      cardType: response.cardType,
      cardData: response.cardData,
    );

    _isProcessing = false;
    notifyListeners();
  }

  // ─── Response Builder ─────────────────────────────────────────────────────
  _GenieResponse _buildResponse(GenieIntent intent) {
    switch (intent.module) {
      case GenieModule.goPage:
        return _buildGoResponse(intent);
      case GenieModule.market:
        return _buildMarketResponse(intent);
      case GenieModule.myUpdates:
        return _buildUpdatesResponse(intent);
      case GenieModule.live:
        return _buildLiveResponse(intent);
      case GenieModule.alerts:
        return _buildAlertsResponse(intent);
      case GenieModule.qualChat:
        return _buildQualChatResponse(intent);
      case GenieModule.april:
        return _buildAprilResponse(intent);
      case GenieModule.setupDashboard:
        return _buildSetupResponse(intent);
      case GenieModule.userDetails:
        return _buildUserDetailsResponse(intent);
      case GenieModule.utility:
        return _buildUtilityResponse(intent);
      case GenieModule.crossModule:
        return const _GenieResponse(text: 'Running cross-module workflow...', cardType: GenieCardType.text);
      case GenieModule.eplay:
        return _buildEPlayResponse(intent);
      case GenieModule.community:
        return _buildCommunityResponse(intent);
      case GenieModule.genie:
        return _buildGenieNativeResponse(intent);
      case GenieModule.fintech:
        return _buildFintechResponse(intent);
      case GenieModule.enterprise:
        return _buildEnterpriseResponse(intent);
    }
  }

  _GenieResponse _buildGoResponse(GenieIntent intent) {
    switch (intent.action) {
      case 'check_balance':
        return const _GenieResponse(
          text: 'Here\'s your QPoints balance:',
          cardType: GenieCardType.balance,
          cardData: {'balance': 14250, 'rate': 0.85, 'currency': 'USD'},
        );
      case 'transaction_history':
        return const _GenieResponse(
          text: 'Your last transactions:',
          cardType: GenieCardType.transaction,
          cardData: {
            'transactions': [
              {'id': 'TX-2041', 'type': 'received', 'amount': 500, 'from': 'Bob', 'ago': '1h ago'},
              {'id': 'TX-2040', 'type': 'transferred', 'amount': 200, 'to': 'Alice', 'ago': '3h ago'},
              {'id': 'TX-2039', 'type': 'bought', 'amount': 1000, 'ago': '1d ago'},
            ]
          },
        );
      case 'transfer':
        final recipient = intent.params['recipient'] ?? 'recipient';
        final amount = intent.params['amount'] ?? 0;
        return _GenieResponse(
          text: 'I\'ll transfer $amount QP to $recipient. Please confirm:',
          cardType: GenieCardType.confirmation,
          cardData: {
            'action': 'transfer',
            'amount': amount,
            'recipient': recipient,
            'requiresBiometric': true,
          },
        );
      case 'gateway_status':
        return const _GenieResponse(
          text: 'GO PAGE gateway status:',
          cardType: GenieCardType.text,
          cardData: {'status': 'operational', 'latency': '12ms'},
        );
      case 'exchange_rate':
        return const _GenieResponse(
          text: '1 QPoint = \$0.85 USD (live rate)',
          cardType: GenieCardType.text,
        );
      default:
        return const _GenieResponse(
          text: 'Opening GO PAGE…',
          cardType: GenieCardType.comingSoon,
        );
    }
  }

  _GenieResponse _buildMarketResponse(GenieIntent intent) {
    switch (intent.action) {
      case 'browse_shops':
        return const _GenieResponse(
          text: 'Nearby shops in your area:',
          cardType: GenieCardType.shopCarousel,
          cardData: {
            'shops': [
              {'name': 'TechHub Store', 'distance': '0.3 km', 'rating': 4.8},
              {'name': 'Fresh Greens', 'distance': '0.7 km', 'rating': 4.6},
              {'name': 'Glow Beauty', 'distance': '1.2 km', 'rating': 4.9},
            ]
          },
        );
      case 'view_cart':
        return const _GenieResponse(
          text: 'Your current cart:',
          cardType: GenieCardType.orderSummary,
          cardData: {
            'items': 3,
            'total': 4500,
            'currency': 'QP',
          },
        );
      case 'track_order':
        final id = intent.params['orderId'] ?? 'ORD-2041';
        return _GenieResponse(
          text: 'Tracking order #$id:',
          cardType: GenieCardType.orderTracker,
          cardData: {
            'orderId': id,
            'status': 'In transit',
            'eta': '15 min',
            'driverName': 'James K.',
          },
        );
      case 'today_deals':
        return const _GenieResponse(
          text: 'Today\'s featured deals:',
          cardType: GenieCardType.shopCarousel,
          cardData: {'type': 'deals'},
        );
      default:
        return const _GenieResponse(
          text: 'Opening MARKET…',
          cardType: GenieCardType.comingSoon,
        );
    }
  }

  _GenieResponse _buildUpdatesResponse(GenieIntent intent) {
    switch (intent.action) {
      case 'show_feed':
        return const _GenieResponse(
          text: 'Your updates feed:',
          cardType: GenieCardType.feedCard,
        );
      case 'saved_posts':
        return const _GenieResponse(
          text: 'Your saved posts:',
          cardType: GenieCardType.feedCard,
          cardData: {'type': 'saved'},
        );
      case 'post_engagement':
        return const _GenieResponse(
          text: 'Engagement on your latest post: 124 likes, 18 shares.',
          cardType: GenieCardType.feedCard,
          cardData: {'type': 'engagement'},
        );
      default:
        return const _GenieResponse(
          text: 'Opening MY UPDATES…',
          cardType: GenieCardType.comingSoon,
        );
    }
  }

  _GenieResponse _buildLiveResponse(GenieIntent intent) {
    switch (intent.action) {
      case 'incoming_orders':
        return const _GenieResponse(
          text: 'Incoming orders right now:',
          cardType: GenieCardType.liveOrders,
          cardData: {
            'orders': [
              {'id': 'ORD-2041', 'customer': 'Alice M.', 'items': 2, 'urgent': true},
              {'id': 'ORD-2042', 'customer': 'Bob T.', 'items': 1, 'urgent': false},
            ]
          },
        );
      case 'active_packages':
        return const _GenieResponse(
          text: 'Active packages in transit:',
          cardType: GenieCardType.liveOrders,
          cardData: {'type': 'active'},
        );
      case 'available_packages':
        return const _GenieResponse(
          text: 'Available packages waiting for pickup:',
          cardType: GenieCardType.driverDelivery,
          cardData: {
            'packages': [
              {'id': 'PKG-101', 'stops': 2, 'eta': '12 min', 'distance': '3.2 km'},
            ]
          },
        );
      case 'current_delivery':
        return const _GenieResponse(
          text: 'Your current delivery:',
          cardType: GenieCardType.driverDelivery,
          cardData: {'type': 'current', 'destination': '14 Oak Street', 'eta': '8 min'},
        );
      case 'emergency_sos':
        return const _GenieResponse(
          text: '🆘 SOS activated. Emergency services and fleet manager notified.',
          cardType: GenieCardType.confirmation,
          cardData: {'action': 'sos'},
        );
      case 'live_operations':
        return const _GenieResponse(
          text: 'Live operations overview:',
          cardType: GenieCardType.liveOrders,
          cardData: {'type': 'operations'},
        );
      default:
        return const _GenieResponse(
          text: 'Opening LIVE…',
          cardType: GenieCardType.comingSoon,
        );
    }
  }

  _GenieResponse _buildAlertsResponse(GenieIntent intent) {
    switch (intent.action) {
      case 'recent_alerts':
        return const _GenieResponse(
          text: 'Recent alerts:',
          cardType: GenieCardType.alertList,
          cardData: {
            'alerts': [
              {'id': 'TX-2041', 'type': 'payment', 'status': 'pending', 'age': '2h ago'},
              {'id': 'TX-2039', 'type': 'delivery', 'status': 'resolved', 'age': '5h ago'},
            ]
          },
        );
      case 'resolved_alerts':
        return const _GenieResponse(
          text: 'Recently resolved:',
          cardType: GenieCardType.alertList,
          cardData: {'type': 'resolved'},
        );
      case 'alert_distribution':
        return const _GenieResponse(
          text: 'Alert breakdown by type:',
          cardType: GenieCardType.alertList,
          cardData: {'type': 'distribution'},
        );
      default:
        return const _GenieResponse(
          text: 'Opening ALERTS…',
          cardType: GenieCardType.comingSoon,
        );
    }
  }

  _GenieResponse _buildQualChatResponse(GenieIntent intent) {
    switch (intent.action) {
      case 'recent_chats':
        return const _GenieResponse(
          text: 'Your recent conversations:',
          cardType: GenieCardType.chatList,
        );
      case 'presence_dashboard':
        return const _GenieResponse(
          text: 'Who\'s online right now:',
          cardType: GenieCardType.chatList,
          cardData: {'type': 'presence'},
        );
      case 'hey_ya':
        return const _GenieResponse(
          text: 'Your Hey Ya sparks & nudges:',
          cardType: GenieCardType.chatList,
          cardData: {'type': 'hey_ya'},
        );
      case 'direct_message':
        final recipient = intent.params['recipient'] ?? 'contact';
        return _GenieResponse(
          text: 'Opening chat with $recipient…',
          cardType: GenieCardType.comingSoon,
          cardData: {'recipient': recipient},
        );
      case 'fleet_chat':
        return const _GenieResponse(
          text: 'Fleet chat:',
          cardType: GenieCardType.chatList,
          cardData: {'type': 'fleet'},
        );
      default:
        return const _GenieResponse(
          text: 'Opening qualChat…',
          cardType: GenieCardType.comingSoon,
        );
    }
  }

  _GenieResponse _buildAprilResponse(GenieIntent intent) {
    switch (intent.action) {
      case 'reminders':
        return const _GenieResponse(
          text: 'Your upcoming reminders:',
          cardType: GenieCardType.helpGuide,
          cardData: {
            'reminders': [
              {'title': 'Team meeting', 'time': 'Today 3:00 PM'},
              {'title': 'Invoice due', 'time': 'Tomorrow 9:00 AM'},
            ]
          },
        );
      case 'budget_review':
        return const _GenieResponse(
          text: 'Your monthly budget summary:',
          cardType: GenieCardType.balance,
          cardData: {'type': 'budget', 'spent': 12400, 'budget': 20000},
        );
      case 'wishlist':
        return const _GenieResponse(
          text: 'Your wishlist:',
          cardType: GenieCardType.feedCard,
          cardData: {'type': 'wishlist'},
        );
      case 'manage_plugins':
        return const _GenieResponse(
          text: 'APRIL plugin manager:',
          cardType: GenieCardType.operationsOverview,
          cardData: {'type': 'plugins'},
        );
      default:
        return const _GenieResponse(
          text: 'Opening APRIL personal assistant…',
          cardType: GenieCardType.comingSoon,
        );
    }
  }

  _GenieResponse _buildSetupResponse(GenieIntent intent) {
    switch (intent.action) {
      case 'operations_overview':
        return const _GenieResponse(
          text: 'Operations overview:',
          cardType: GenieCardType.operationsOverview,
        );
      case 'product_count':
        return const _GenieResponse(
          text: 'You have 1,245 SKUs in your inventory.',
          cardType: GenieCardType.text,
        );
      case 'staff_list':
        return const _GenieResponse(
          text: 'Your team:',
          cardType: GenieCardType.operationsOverview,
          cardData: {'type': 'staff'},
        );
      case 'sales_today':
        return const _GenieResponse(
          text: 'Today\'s sales: 47 orders · 128,500 QP revenue.',
          cardType: GenieCardType.text,
        );
      default:
        return const _GenieResponse(
          text: 'Opening SETUP DASHBOARD…',
          cardType: GenieCardType.comingSoon,
        );
    }
  }

  _GenieResponse _buildUserDetailsResponse(GenieIntent intent) {
    switch (intent.action) {
      case 'profile_strength':
        return const _GenieResponse(
          text: 'Your profile is 78% complete.',
          cardType: GenieCardType.profileStrength,
          cardData: {'strength': 78},
        );
      case 'switch_context':
        final ctx = intent.params['context'] ?? 'context';
        return _GenieResponse(
          text: 'Switching to $ctx context…',
          cardType: GenieCardType.confirmation,
          cardData: {'action': 'switch_context', 'context': ctx},
        );
      default:
        return const _GenieResponse(
          text: 'Opening USER DETAILS…',
          cardType: GenieCardType.comingSoon,
        );
    }
  }

  _GenieResponse _buildUtilityResponse(GenieIntent intent) {
    switch (intent.action) {
      case 'notifications':
        return const _GenieResponse(
          text: 'Your notifications:',
          cardType: GenieCardType.notificationHub,
        );
      case 'help':
        final query = intent.params['query'] as String? ?? '';
        return _GenieResponse(
          text: 'Here\'s a guide for: "$query"',
          cardType: GenieCardType.helpGuide,
          cardData: {'query': query},
        );
      case 'universal_search':
        final q = intent.params['query'] as String? ?? '';
        return _GenieResponse(
          text: 'Search results for "$q":',
          cardType: GenieCardType.text,
          cardData: {'query': q},
        );
      default:
        return const _GenieResponse(
          text: 'Opening UTILITY…',
          cardType: GenieCardType.comingSoon,
        );
    }
  }

  _GenieResponse _buildGenieNativeResponse(GenieIntent intent) {
    switch (intent.action) {
      case 'classic_dashboard':
        return const _GenieResponse(
          text: 'Switching to classic dashboard…',
          cardType: GenieCardType.comingSoon,
          cardData: {'action': 'classic'},
        );
      case 'capabilities':
        return const _GenieResponse(
          text: 'I can help with: QPoints, MARKET orders, e-Play content, '
              'Communities, deliveries, alerts, chats, and more. Just ask or tap a shortcut.',
          cardType: GenieCardType.helpGuide,
        );
      default:
        return const _GenieResponse(
          text: 'I didn\'t quite catch that. Try “check balance”, '
              '“incoming orders”, or say “Hey Genie help”.',
          cardType: GenieCardType.text,
        );
    }
  }

  _GenieResponse _buildEPlayResponse(GenieIntent intent) {
    switch (intent.action) {
      case 'open_locker':
        return const _GenieResponse(
          text: 'Here\'s your e-Play Cloud Locker — your purchased digital content:',
          cardType: GenieCardType.feedCard,
          cardData: {
            'type': 'eplay_locker',
            'count': 12,
            'pinned': 3,
            'rentals': 2,
          },
        );
      case 'browse':
        return const _GenieResponse(
          text: 'Discover music, movies, podcasts, e-books and shows from African creators:',
          cardType: GenieCardType.shopCarousel,
          cardData: {'type': 'eplay_browse'},
        );
      case 'creator_studio':
        return const _GenieResponse(
          text: 'Opening your Creator Studio — manage content, earnings and royalties:',
          cardType: GenieCardType.operationsOverview,
          cardData: {'type': 'creator_studio'},
        );
      case 'creator_profile':
        return const _GenieResponse(
          text: 'Your creator profile & earnings:',
          cardType: GenieCardType.balance,
          cardData: {'type': 'creator_earnings', 'total': 127, 'currency': 'QP'},
        );
      default:
        return const _GenieResponse(
          text: 'Opening e-Play…',
          cardType: GenieCardType.comingSoon,
        );
    }
  }

  _GenieResponse _buildFintechResponse(GenieIntent intent) {
    switch (intent.action) {
      case 'apply_loan':
        return _GenieResponse(
          text: 'Opening loan application — comparing offers from verified FIs…',
          cardType: GenieCardType.comingSoon,
          cardData: {'action': 'apply_loan', ...intent.params},
        );
      case 'view_loan_offers':
        return const _GenieResponse(
          text: 'Fetching competitive loan offers for you:',
          cardType: GenieCardType.comingSoon,
          cardData: {'action': 'loan_offers'},
        );
      case 'repay_loan':
        return const _GenieResponse(
          text: 'Opening loan repayment screen:',
          cardType: GenieCardType.comingSoon,
          cardData: {'action': 'repay_loan'},
        );
      case 'create_deposit':
        return _GenieResponse(
          text: 'Opening term deposit — lock your QPoints and earn interest:',
          cardType: GenieCardType.comingSoon,
          cardData: {'action': 'create_deposit', ...intent.params},
        );
      case 'view_deposits':
        return const _GenieResponse(
          text: 'Your active term deposits:',
          cardType: GenieCardType.comingSoon,
          cardData: {'action': 'view_deposits'},
        );
      case 'purchase_policy':
        return const _GenieResponse(
          text: 'Browse and purchase insurance cover:',
          cardType: GenieCardType.comingSoon,
          cardData: {'action': 'insurance'},
        );
      case 'file_claim':
        return const _GenieResponse(
          text: 'Opening insurance claim submission:',
          cardType: GenieCardType.comingSoon,
          cardData: {'action': 'file_claim'},
        );
      case 'credit_score':
        return const _GenieResponse(
          text: 'Fetching your credit data profile:',
          cardType: GenieCardType.comingSoon,
          cardData: {'action': 'credit_score'},
        );
      default:
        return const _GenieResponse(
          text: 'Opening Fintech services…',
          cardType: GenieCardType.comingSoon,
        );
    }
  }

  _GenieResponse _buildEnterpriseResponse(GenieIntent intent) {
    switch (intent.action) {
      case 'onboard':
        return const _GenieResponse(
          text: 'Opening Enterprise Onboarding — register your business for API access:',
          cardType: GenieCardType.comingSoon,
          cardData: {'action': 'enterprise_onboard'},
        );
      case 'dashboard':
        return const _GenieResponse(
          text: 'Opening your Enterprise Dashboard:',
          cardType: GenieCardType.comingSoon,
          cardData: {'action': 'enterprise_dashboard'},
        );
      case 'create_api_key':
        return const _GenieResponse(
          text: 'Opening API key generator — your key will be shown once:',
          cardType: GenieCardType.comingSoon,
          cardData: {'action': 'create_api_key'},
        );
      case 'view_api_keys':
        return const _GenieResponse(
          text: 'Showing your active API keys (prefixes only):',
          cardType: GenieCardType.comingSoon,
          cardData: {'action': 'view_api_keys'},
        );
      case 'channels':
        return const _GenieResponse(
          text: 'Opening multi-channel management — connect Shopify, Amazon, Walmart and more:',
          cardType: GenieCardType.comingSoon,
          cardData: {'action': 'channels'},
        );
      case 'fulfillment':
        return const _GenieResponse(
          text: 'Opening fulfillment routing — set providers and dispatch orders:',
          cardType: GenieCardType.comingSoon,
          cardData: {'action': 'fulfillment'},
        );
      case 'concierge':
        return const _GenieResponse(
          text: 'Opening the Agentic Concierge embed — start an AI session:',
          cardType: GenieCardType.comingSoon,
          cardData: {'action': 'concierge'},
        );
      case 'analytics':
        return const _GenieResponse(
          text: 'Enterprise analytics and revenue insights:',
          cardType: GenieCardType.comingSoon,
          cardData: {'action': 'enterprise_analytics'},
        );
      default:
        return const _GenieResponse(
          text: 'Opening Enterprise hub…',
          cardType: GenieCardType.comingSoon,
        );
    }
  }



  _GenieResponse _buildCommunityResponse(GenieIntent intent) {
    switch (intent.action) {
      case 'my_communities':
        return const _GenieResponse(
          text: 'Your community spaces:',
          cardType: GenieCardType.feedCard,
          cardData: {
            'type': 'my_communities',
            'communities': [
              {'name': 'Afrobeats Book Club', 'type': 'library', 'unread': 4},
              {'name': 'Dev Hive Africa', 'type': 'hub', 'unread': 12},
            ],
          },
        );
      case 'discover':
        return const _GenieResponse(
          text: 'Trending communities to explore:',
          cardType: GenieCardType.shopCarousel,
          cardData: {'type': 'community_discover'},
        );
      case 'create':
        return const _GenieResponse(
          text: 'Create a new community — pick a type to get started:',
          cardType: GenieCardType.comingSoon,
          cardData: {'action': 'community_create'},
        );
      default:
        return const _GenieResponse(
          text: 'Opening Communities…',
          cardType: GenieCardType.comingSoon,
        );
    }
  }

  // ─── Voice Controls ───────────────────────────────────────────────────────
  Future<void> startVoice() async {
    await GenieTactileActions.onTap();
    await GenieVoice.instance.startListening();
  }

  Future<void> stopVoice() async {
    await GenieVoice.instance.stopListening();
  }

  // ─── Pinned Tiles ─────────────────────────────────────────────────────────
  void pinTile(GenieModule module, Map<String, dynamic> data) {
    _pinnedTiles[module] = data;
    notifyListeners();
  }

  void unpinTile(GenieModule module) {
    _pinnedTiles.remove(module);
    notifyListeners();
  }

  // ─── Offline Queue ────────────────────────────────────────────────────────
  final List<GenieIntent> _offlineQueue = [];

  void _queueOfflineIntent(GenieIntent intent) {
    _offlineQueue.add(intent);
  }

  void setOnline(bool online) {
    _isOnline = online;
    if (online) {
      if (_offlineQueue.isNotEmpty) {
        _replayOfflineQueue();
      }
      // Flush buffered telemetry now that we're online
      unawaited(GeniePerformanceTelemetry.flush(isOnline: true));
    }
    notifyListeners();
  }

  /// Called when the user manually switches role — fires the role signature.
  Future<void> onRoleSwitch(UserRole newRole) async {
    await GenieHapticRoleSignature.onRoleSwitch(newRole);
  }

  /// Returns a contextual empty-state tip for a module screen with no content.
  GenieTipCard emptyStateFor(GenieModule module) =>
      GenieEmptyState.forModule(module, role: _role);

  Future<void> _replayOfflineQueue() async {
    final queued = List.of(_offlineQueue);
    _offlineQueue.clear();
    _addGenieMessage(
      text: 'Back online! Replaying ${queued.length} queued action(s)…',
      cardType: GenieCardType.text,
    );
    for (final intent in queued) {
      await executeIntent(intent);
    }
  }

  // ─── Message Helpers ──────────────────────────────────────────────────────
  void _addUserMessage(String text) {
    _messages.add(GenieMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}-user',
      isUser: true,
      text: text,
      cardType: GenieCardType.text,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  void _addGenieMessage({
    String? text,
    required GenieCardType cardType,
    Map<String, dynamic> cardData = const {},
  }) {
    _messages.add(GenieMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}-genie',
      isUser: false,
      text: text,
      cardType: cardType,
      cardData: cardData,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  void clearHistory() {
    _messages.clear();
    _sendGreeting();
    notifyListeners();
  }
}

/// Internal response value object used within the controller.
class _GenieResponse {
  final String? text;
  final GenieCardType cardType;
  final Map<String, dynamic> cardData;

  const _GenieResponse({
    this.text,
    required this.cardType,
    this.cardData = const {},
  });
}
