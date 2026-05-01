/// ═══════════════════════════════════════════════════════════════════════════
/// GenieIntentResolver – NLU via Keyword-Regex Tree
///
/// Maps raw text (from voice or keyboard) to a structured GenieIntent.
/// Uses a priority-ordered list of pattern sets per module. ~200 built-in
/// intents covering all platform actions. Fully offline, no server call.
/// ═══════════════════════════════════════════════════════════════════════════

import 'genie_intent.dart';

class GenieIntentResolver {
  GenieIntentResolver._();

  /// Resolve an intent from raw user input. Returns null if unmatched.
  static GenieIntent? resolve(String input) {
    final text = input.toLowerCase().trim();
    if (text.isEmpty) return null;

    // Walk through all module resolvers in priority order
    return _resolveGoPage(text) ??
        _resolveMarket(text) ??
        _resolveEPlay(text) ??
        _resolveCommunity(text) ??
        _resolveMyUpdates(text) ??
        _resolveLive(text) ??
        _resolveAlerts(text) ??
        _resolveQualChat(text) ??
        _resolveApril(text) ??
        _resolveSetupDashboard(text) ??
        _resolveUserDetails(text) ??
        _resolveFintech(text) ??
        _resolveUtility(text) ??
        _resolveNavigation(text) ??
        _resolveGenieNative(text);
  }

  // ─── GO PAGE ───────────────────────────────────────────────────────────────
  static GenieIntent? _resolveGoPage(String t) {
    if (_any(t, ['balance', 'qpoints balance', 'qp balance', 'how many qp',
        'my balance', 'check balance', 'wallet'])) {
      return const GenieIntent(module: GenieModule.goPage, action: 'check_balance');
    }
    if (_any(t, ['buy qp', 'buy qpoints', 'purchase qpoints', 'buy points'])) {
      return GenieIntent(module: GenieModule.goPage, action: 'buy', params: _extractAmount(t));
    }
    if (_any(t, ['sell qp', 'sell qpoints', 'cash out'])) {
      return GenieIntent(module: GenieModule.goPage, action: 'sell', params: _extractAmount(t));
    }
    if (_any(t, ['send qp', 'transfer qp', 'send qpoints', 'transfer qpoints',
        'pay qpoints', 'give qpoints'])) {
      return GenieIntent(
        module: GenieModule.goPage,
        action: 'transfer',
        params: {..._extractAmount(t), ..._extractRecipient(t)},
      );
    }
    if (_any(t, ['transactions', 'last transaction', 'transaction history',
        'recent transfers', 'payment history'])) {
      return const GenieIntent(module: GenieModule.goPage, action: 'transaction_history');
    }
    if (_any(t, ['gateway', 'gateway health', 'gateway status'])) {
      return const GenieIntent(module: GenieModule.goPage, action: 'gateway_status');
    }
    if (_any(t, ['qpoint rate', 'exchange rate', 'qp rate', 'how much is qpoint'])) {
      return const GenieIntent(module: GenieModule.goPage, action: 'exchange_rate');
    }
    if (_any(t, ['open go', 'go page', 'go module'])) {
      return const GenieIntent(
          module: GenieModule.goPage, action: 'open_full', requiresFullScreen: true);
    }
    if (_any(t, ['go tab', 'tabs', 'my tabs', 'qpoint tab'])) {
      return const GenieIntent(module: GenieModule.goPage, action: 'go_tabs');
    }
    if (_any(t, ['pending requests', 'qp requests'])) {
      return const GenieIntent(module: GenieModule.goPage, action: 'go_requests');
    }
    return null;
  }

  // ─── MARKET ────────────────────────────────────────────────────────────────
  static GenieIntent? _resolveMarket(String t) {
    if (_any(t, ['nearby shops', 'show shops', 'browse', 'shops near me',
        'explore market', 'market'])) {
      return const GenieIntent(module: GenieModule.market, action: 'browse_shops');
    }
    if (_any(t, ['cart', 'my cart', 'shopping cart'])) {
      return const GenieIntent(module: GenieModule.market, action: 'view_cart');
    }
    if (_any(t, ['checkout', 'place order', 'complete order'])) {
      return const GenieIntent(module: GenieModule.market, action: 'checkout', requiresFullScreen: true);
    }
    if (_any(t, ['track order', 'order status', 'where is my order',
        'delivery status'])) {
      return GenieIntent(
          module: GenieModule.market,
          action: 'track_order',
          params: _extractOrderId(t));
    }
    if (_any(t, ['book ride', 'hail ride', 'book transport', 'get a ride',
        'taxi', 'transport'])) {
      return const GenieIntent(module: GenieModule.market, action: 'hail_ride', requiresFullScreen: true);
    }
    if (_any(t, ["today's deals", 'deals', 'discounts', 'offers', 'promotions'])) {
      return const GenieIntent(module: GenieModule.market, action: 'today_deals');
    }
    if (_any(t, ['bundle', 'bundle orders', 'combine orders'])) {
      return const GenieIntent(module: GenieModule.market, action: 'bundle_orders');
    }
    if (_any(t, ['pickup', 'ready for pickup', 'self pickup', 'collect order'])) {
      return const GenieIntent(module: GenieModule.market, action: 'self_pickup');
    }
    if (_any(t, ['return', 'return order', 'refund order'])) {
      return const GenieIntent(module: GenieModule.market, action: 'return_order', requiresFullScreen: true);
    }
    if (_any(t, ['my orders', 'order history', 'past orders'])) {
      return const GenieIntent(module: GenieModule.market, action: 'my_orders');
    }
    if (_any(t, ['open market', 'go to market'])) {
      return const GenieIntent(module: GenieModule.market, action: 'open_full', requiresFullScreen: true);
    }
    return null;
  }

  // ─── e-PLAY ─────────────────────────────────────────────────────────────────
  static GenieIntent? _resolveEPlay(String t) {
    if (_any(t, ['my locker', 'cloud locker', 'e-play locker', 'eplay locker',
        'my digital content', 'my purchased content'])) {
      return const GenieIntent(module: GenieModule.eplay, action: 'open_locker', requiresFullScreen: true);
    }
    if (_any(t, ['browse music', 'browse movies', 'browse podcasts',
        'browse ebooks', 'browse e-play', 'browse eplay', 'digital content'])) {
      return const GenieIntent(module: GenieModule.eplay, action: 'browse', requiresFullScreen: true);
    }
    if (_any(t, ['sell content', 'upload content', 'creator studio',
        'my creator studio', 'digital branch', 'open digital branch'])) {
      return const GenieIntent(module: GenieModule.eplay, action: 'creator_studio', requiresFullScreen: true);
    }
    if (_any(t, ['my creator profile', 'creator earnings', 'royalties',
        'my earnings from e-play', 'eplay earnings'])) {
      return const GenieIntent(module: GenieModule.eplay, action: 'creator_profile');
    }
    if (_any(t, ['play music', 'play a song', 'stream music', 'listen to',
        'watch movie', 'read ebook', 'play podcast'])) {
      return const GenieIntent(module: GenieModule.eplay, action: 'open_full', requiresFullScreen: true);
    }
    if (_any(t, ['open e-play', 'open eplay', 'go to eplay', 'go to e-play',
        'launch eplay', 'eplay module'])) {
      return const GenieIntent(module: GenieModule.eplay, action: 'open_full', requiresFullScreen: true);
    }
    return null;
  }

  // ─── COMMUNITY ─────────────────────────────────────────────────────────────
  static GenieIntent? _resolveCommunity(String t) {
    if (_any(t, ['my communities', 'communities i joined', 'joined communities'])) {
      return const GenieIntent(module: GenieModule.community, action: 'my_communities', requiresFullScreen: true);
    }
    if (_any(t, ['discover communities', 'browse communities', 'find communities',
        'explore communities', 'community hub'])) {
      return const GenieIntent(module: GenieModule.community, action: 'discover', requiresFullScreen: true);
    }
    if (_any(t, ['create community', 'start a community', 'new community',
        'create a library', 'create a hub', 'create a theater', 'create a hangout',
        'create a fair', 'create a playlist', 'create a journal'])) {
      return const GenieIntent(module: GenieModule.community, action: 'create', requiresFullScreen: true);
    }
    if (_any(t, ['community feed', 'community posts', 'my community feed'])) {
      return const GenieIntent(module: GenieModule.community, action: 'my_communities', requiresFullScreen: true);
    }
    if (_any(t, ['open community', 'go to community', 'launch community',
        'community module'])) {
      return const GenieIntent(module: GenieModule.community, action: 'open_full', requiresFullScreen: true);
    }
    return null;
  }

  // ─── MY UPDATES ───────────────────────────────────────────────────────────
  static GenieIntent? _resolveMyUpdates(String t) {
    if (_any(t, ['feed', 'my feed', 'show my feed', 'updates feed', 'news feed'])) {
      return const GenieIntent(module: GenieModule.myUpdates, action: 'show_feed');
    }
    if (_any(t, ['post update', 'create post', 'new post', 'share update',
        'post something'])) {
      return const GenieIntent(module: GenieModule.myUpdates, action: 'create_post', requiresFullScreen: true);
    }
    if (_any(t, ['saved posts', 'saved', 'my saved'])) {
      return const GenieIntent(module: GenieModule.myUpdates, action: 'saved_posts');
    }
    if (_any(t, ['engagement', 'post engagement', 'likes', 'shares',
        'my post stats'])) {
      return const GenieIntent(module: GenieModule.myUpdates, action: 'post_engagement');
    }
    if (_any(t, ['following', 'who i follow', 'my following'])) {
      return const GenieIntent(module: GenieModule.myUpdates, action: 'following', requiresFullScreen: true);
    }
    if (_any(t, ['open updates', 'go to updates', 'updates module'])) {
      return const GenieIntent(module: GenieModule.myUpdates, action: 'open_full', requiresFullScreen: true);
    }
    return null;
  }

  // ─── LIVE ──────────────────────────────────────────────────────────────────
  static GenieIntent? _resolveLive(String t) {
    if (_any(t, ['incoming orders', 'incoming', 'new orders', 'pending orders'])) {
      return const GenieIntent(module: GenieModule.live, action: 'incoming_orders');
    }
    if (_any(t, ['active deliveries', 'active packages', 'in transit',
        'current deliveries', 'ongoing deliveries'])) {
      return const GenieIntent(module: GenieModule.live, action: 'active_packages');
    }
    if (_any(t, ['available deliveries', 'available packages', 'pick up packages',
        'available jobs'])) {
      return const GenieIntent(module: GenieModule.live, action: 'available_packages');
    }
    if (_any(t, ['current delivery', 'my delivery', 'my current ride',
        'where am i going', 'navigation'])) {
      return const GenieIntent(module: GenieModule.live, action: 'current_delivery');
    }
    if (_any(t, ['confirm delivery', 'delivery done', 'package delivered',
        'complete delivery'])) {
      return const GenieIntent(module: GenieModule.live, action: 'confirm_delivery', requiresFullScreen: true);
    }
    if (_any(t, ['sos', 'emergency', 'help me', 'danger', "i'm in danger",
        'call for help'])) {
      return const GenieIntent(module: GenieModule.live, action: 'emergency_sos', requiresFullScreen: true);
    }
    if (_any(t, ['assign driver', 'assign package', 'create package'])) {
      return const GenieIntent(module: GenieModule.live, action: 'assign_driver', requiresFullScreen: true);
    }
    if (_any(t, ['live operations', 'operations feed', 'live overview'])) {
      return const GenieIntent(module: GenieModule.live, action: 'live_operations');
    }
    if (_any(t, ['returns', 'pending returns', 'return requests'])) {
      return const GenieIntent(module: GenieModule.live, action: 'live_returns');
    }
    if (_any(t, ['open live', 'go to live', 'live dashboard'])) {
      return const GenieIntent(module: GenieModule.live, action: 'open_full', requiresFullScreen: true);
    }
    return null;
  }

  // ─── ALERTS ────────────────────────────────────────────────────────────────
  static GenieIntent? _resolveAlerts(String t) {
    if (_any(t, ['alerts', 'recent alerts', 'alert list', 'show alerts',
        'my alerts'])) {
      return const GenieIntent(module: GenieModule.alerts, action: 'recent_alerts');
    }
    if (_any(t, ['resolved alerts', 'recent resolutions', 'closed alerts'])) {
      return const GenieIntent(module: GenieModule.alerts, action: 'resolved_alerts');
    }
    if (_any(t, ['alert types', 'alert distribution', 'alert stats',
        'alert breakdown'])) {
      return const GenieIntent(module: GenieModule.alerts, action: 'alert_distribution');
    }
    if (_any(t, ['open alerts', 'go to alerts', 'alerts dashboard'])) {
      return const GenieIntent(module: GenieModule.alerts, action: 'open_full', requiresFullScreen: true);
    }
    return null;
  }

  // ─── QUALCHAT ──────────────────────────────────────────────────────────────
  static GenieIntent? _resolveQualChat(String t) {
    if (_any(t, ['chats', 'recent chats', 'messages', 'my messages',
        'chat list'])) {
      return const GenieIntent(module: GenieModule.qualChat, action: 'recent_chats');
    }
    if (_any(t, ['who is online', "who's online", 'online users',
        'presence', 'active users'])) {
      return const GenieIntent(module: GenieModule.qualChat, action: 'presence_dashboard');
    }
    if (_any(t, ['hey ya', 'heyya', 'sparks', 'nudges', 'action center'])) {
      return const GenieIntent(module: GenieModule.qualChat, action: 'hey_ya');
    }
    if (_any(t, ['message ', 'chat with ', 'talk to ', 'dm ', 'send message to '])) {
      return GenieIntent(
          module: GenieModule.qualChat,
          action: 'direct_message',
          params: _extractRecipient(t));
    }
    if (_any(t, ['fleet chat', 'driver chat', 'team chat'])) {
      return const GenieIntent(module: GenieModule.qualChat, action: 'fleet_chat');
    }
    if (_any(t, ['open qualchat', 'go to chat', 'open chat'])) {
      return const GenieIntent(module: GenieModule.qualChat, action: 'open_full', requiresFullScreen: true);
    }
    return null;
  }

  // ─── APRIL ─────────────────────────────────────────────────────────────────
  static GenieIntent? _resolveApril(String t) {
    if (_any(t, ['reminders', 'any reminders', 'my reminders', 'schedule',
        'upcoming'])) {
      return const GenieIntent(module: GenieModule.april, action: 'reminders');
    }
    if (_any(t, ['budget', 'review budget', 'my budget', 'spending'])) {
      return const GenieIntent(module: GenieModule.april, action: 'budget_review');
    }
    if (_any(t, ['add expense', 'log expense', 'record expense'])) {
      return const GenieIntent(module: GenieModule.april, action: 'add_expense', requiresFullScreen: true);
    }
    if (_any(t, ['calendar', 'my calendar', 'events', 'appointments'])) {
      return const GenieIntent(module: GenieModule.april, action: 'calendar', requiresFullScreen: true);
    }
    if (_any(t, ['wishlist', 'my wishlist', 'wish list'])) {
      return const GenieIntent(module: GenieModule.april, action: 'wishlist');
    }
    if (_any(t, ['manage plugins', 'plugins', 'april plugins'])) {
      return const GenieIntent(module: GenieModule.april, action: 'manage_plugins');
    }
    if (_any(t, ['open april'])) {
      return const GenieIntent(module: GenieModule.april, action: 'open_full', requiresFullScreen: true);
    }
    return null;
  }

  // ─── SETUP DASHBOARD ──────────────────────────────────────────────────────
  static GenieIntent? _resolveSetupDashboard(String t) {
    if (_any(t, ['operations', 'operations overview', 'dashboard overview',
        'my operations', 'setup overview'])) {
      return const GenieIntent(module: GenieModule.setupDashboard, action: 'operations_overview');
    }
    if (_any(t, ['how many sku', 'products count', 'inventory count',
        'how many products', 'stock count'])) {
      return const GenieIntent(module: GenieModule.setupDashboard, action: 'product_count');
    }
    if (_any(t, ['staff list', 'my staff', 'team members', 'employees'])) {
      return const GenieIntent(module: GenieModule.setupDashboard, action: 'staff_list');
    }
    if (_any(t, ['sales today', "today's sales", 'revenue today', 'sales report'])) {
      return const GenieIntent(module: GenieModule.setupDashboard, action: 'sales_today');
    }
    if (_any(t, ['vehicles', 'my vehicles', 'fleet', 'vehicle list'])) {
      return const GenieIntent(module: GenieModule.setupDashboard, action: 'vehicles');
    }
    if (_any(t, ['vehicle bands', 'bands', 'transport bands'])) {
      return const GenieIntent(module: GenieModule.setupDashboard, action: 'vehicle_bands');
    }
    if (_any(t, ['branches', 'my branches', 'branch list'])) {
      return const GenieIntent(module: GenieModule.setupDashboard, action: 'branches');
    }
    if (_any(t, ['campaigns', 'my campaigns', 'active campaigns'])) {
      return const GenieIntent(module: GenieModule.setupDashboard, action: 'campaigns');
    }
    if (_any(t, ['open setup', 'go to setup', 'setup dashboard'])) {
      return const GenieIntent(module: GenieModule.setupDashboard, action: 'open_full', requiresFullScreen: true);
    }
    return null;
  }

  // ─── USER DETAILS ──────────────────────────────────────────────────────────
  static GenieIntent? _resolveUserDetails(String t) {
    if (_any(t, ['profile strength', 'complete profile', 'profile completeness',
        'my profile'])) {
      return const GenieIntent(module: GenieModule.userDetails, action: 'profile_strength');
    }
    if (_any(t, ['switch context', 'change context', 'switch to branch',
        'switch to business', 'switch to personal'])) {
      return GenieIntent(
          module: GenieModule.userDetails,
          action: 'switch_context',
          params: _extractContext(t));
    }
    if (_any(t, ['add entity', 'create entity', 'new entity'])) {
      return const GenieIntent(module: GenieModule.userDetails, action: 'add_entity', requiresFullScreen: true);
    }
    if (_any(t, ['security', 'change password', 'biometric', '2fa',
        'two factor'])) {
      return const GenieIntent(module: GenieModule.userDetails, action: 'security', requiresFullScreen: true);
    }
    if (_any(t, ['open profile', 'go to profile', 'user details'])) {
      return const GenieIntent(module: GenieModule.userDetails, action: 'open_full', requiresFullScreen: true);
    }
    return null;
  }

  // ─── UTILITY ───────────────────────────────────────────────────────────────
  static GenieIntent? _resolveUtility(String t) {
    if (_any(t, ['notifications', 'my notifications', 'notification hub',
        'notification center'])) {
      return const GenieIntent(module: GenieModule.utility, action: 'notifications');
    }
    if (_any(t, ['settings', 'app settings', 'open settings'])) {
      return const GenieIntent(module: GenieModule.utility, action: 'settings', requiresFullScreen: true);
    }
    if (_any(t, ['help', 'faq', 'how do i', 'how to', 'guide', 'support',
        'explain'])) {
      return GenieIntent(
          module: GenieModule.utility,
          action: 'help',
          params: {'query': t});
    }
    if (_any(t, ['search for', 'find ', 'look for ', 'search '])) {
      return GenieIntent(
          module: GenieModule.utility,
          action: 'universal_search',
          params: {'query': _extractSearchQuery(t)});
    }
    return null;
  }

  // ─── FULL-SCREEN NAVIGATION COMMANDS ─────────────────────────────────────
  static GenieIntent? _resolveNavigation(String t) {
    final moduleMap = {
      'go page': GenieModule.goPage,
      'market': GenieModule.market,
      'e-play': GenieModule.eplay,
      'eplay': GenieModule.eplay,
      'community': GenieModule.community,
      'updates': GenieModule.myUpdates,
      'my updates': GenieModule.myUpdates,
      'setup': GenieModule.setupDashboard,
      'alerts': GenieModule.alerts,
      'live': GenieModule.live,
      'qualchat': GenieModule.qualChat,
      'chat': GenieModule.qualChat,
      'april': GenieModule.april,
      'profile': GenieModule.userDetails,
      'user details': GenieModule.userDetails,
      'utility': GenieModule.utility,
    };

    for (final entry in moduleMap.entries) {
      if (t.contains('open ${entry.key}') ||
          t.contains('go to ${entry.key}') ||
          t.contains('launch ${entry.key}') ||
          t.contains('show me ${entry.key}')) {
        return GenieIntent(
            module: entry.value,
            action: 'open_full',
            requiresFullScreen: true);
      }
    }
    return null;
  }

  // ─── FINTECH ──────────────────────────────────────────────────────────────
  static GenieIntent? _resolveFintech(String t) {
    if (_any(t, ['apply for loan', 'need a loan', 'loan for', 'borrow qp',
        'borrow money', 'get a loan', 'loan application', 'take a loan'])) {
      return GenieIntent(module: GenieModule.fintech, action: 'apply_loan',
          params: _extractAmount(t), requiresFullScreen: true);
    }
    if (_any(t, ['loan offers', 'view loan offers', 'show loans', 'loan rates'])) {
      return const GenieIntent(module: GenieModule.fintech, action: 'view_loan_offers', requiresFullScreen: true);
    }
    if (_any(t, ['repay loan', 'pay back loan', 'loan repayment', 'pay my loan'])) {
      return const GenieIntent(module: GenieModule.fintech, action: 'repay_loan', requiresFullScreen: true);
    }
    if (_any(t, ['term deposit', 'lock qp', 'deposit qpoints', 'save qp',
        'lock my qp', 'earn interest', 'term savings'])) {
      return GenieIntent(module: GenieModule.fintech, action: 'create_deposit',
          params: _extractAmount(t), requiresFullScreen: true);
    }
    if (_any(t, ['my deposits', 'view deposits', 'show deposits'])) {
      return const GenieIntent(module: GenieModule.fintech, action: 'view_deposits', requiresFullScreen: true);
    }
    if (_any(t, ['buy insurance', 'purchase insurance', 'get insurance',
        'insure my', 'insurance cover', 'insurance policy', 'motor insurance',
        'health insurance', 'inventory insurance', 'life insurance'])) {
      return const GenieIntent(module: GenieModule.fintech, action: 'purchase_policy', requiresFullScreen: true);
    }
    if (_any(t, ['file claim', 'insurance claim', 'make a claim', 'submit claim'])) {
      return const GenieIntent(module: GenieModule.fintech, action: 'file_claim', requiresFullScreen: true);
    }
    if (_any(t, ['credit score', 'my credit', 'check credit', 'credit rating',
        'credit data', 'creditworthiness'])) {
      return const GenieIntent(module: GenieModule.fintech, action: 'credit_score', requiresFullScreen: true);
    }
    return null;
  }

  // ─── GENIE NATIVE ─────────────────────────────────────────────────────────
  static GenieIntent? _resolveGenieNative(String t) {
    if (_any(t, ['classic dashboard', 'show classic', 'old dashboard',
        'widget dashboard'])) {
      return const GenieIntent(module: GenieModule.genie, action: 'classic_dashboard');
    }
    if (_any(t, ['what can you do', 'help genie', 'genie help',
        'capabilities', 'what are your features'])) {
      return const GenieIntent(module: GenieModule.genie, action: 'capabilities');
    }
    return null;
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  static bool _any(String text, List<String> patterns) =>
      patterns.any((p) => text.contains(p));

  static Map<String, dynamic> _extractAmount(String t) {
    final match = RegExp(r'(\d+[\d,]*\.?\d*)').firstMatch(t);
    if (match != null) {
      return {'amount': double.tryParse(match.group(1)!.replaceAll(',', ''))};
    }
    return {};
  }

  static Map<String, dynamic> _extractRecipient(String t) {
    // Patterns: "to John", "for Mike", "with Sarah"
    final match = RegExp(r'(?:to|for|with)\s+([A-Za-z]+)').firstMatch(t);
    if (match != null) return {'recipient': match.group(1)};
    return {};
  }

  static Map<String, dynamic> _extractOrderId(String t) {
    final match = RegExp(r'#?([A-Z]{2,4}-\d{3,6}|\d{5,10})').firstMatch(t);
    if (match != null) return {'orderId': match.group(1)};
    return {};
  }

  static Map<String, dynamic> _extractContext(String t) {
    if (t.contains('branch')) return {'context': 'branch'};
    if (t.contains('business')) return {'context': 'business'};
    if (t.contains('personal')) return {'context': 'personal'};
    return {};
  }

  static String _extractSearchQuery(String t) {
    return t
        .replaceFirst(RegExp(r"search for|find |look for |search "), '')
        .trim();
  }
}
