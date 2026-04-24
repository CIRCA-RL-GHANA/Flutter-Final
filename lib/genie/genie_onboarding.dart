/// ═══════════════════════════════════════════════════════════════════════════
/// GenieOnboarding
///
/// Recommendations 8 — Proactive Onboarding That Disappears:
///   • Graduated revelation: role-specific greeting cards for first launch
///   • Contextual tip cards: interject when repeated manual navigation detected
///   • Confusion detection: offer a help lifeline after N failed intents
///   • All state persisted in SharedPreferences → tips never repeat once dismissed
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:shared_preferences/shared_preferences.dart';

import '../features/prompt/models/rbac_models.dart';
import 'genie_intent.dart';

// ─── Tip Card Model ───────────────────────────────────────────────────────────

class GenieTipCard {
  final String id;
  final String message;
  final String? actionLabel;
  final GenieIntent? actionIntent;

  const GenieTipCard({
    required this.id,
    required this.message,
    this.actionLabel,
    this.actionIntent,
  });
}

// ─── First-Launch Greeting Data ───────────────────────────────────────────────

class RoleGreetingData {
  final String headline;
  final String subline;
  final List<String> exampleCommands;
  final String? ctaLabel;

  const RoleGreetingData({
    required this.headline,
    required this.subline,
    required this.exampleCommands,
    this.ctaLabel,
  });
}

// ─── Main Service ─────────────────────────────────────────────────────────────

const String _firstLaunchPrefix = 'genie_first_launch_';
const String _dismissedTipsKey = 'genie_dismissed_tips';
const String _navPatternKey = 'genie_nav_pattern';
const String _confusionCountKey = 'genie_confusion_count';
const int _confusionThreshold = 3; // fail count before lifeline offer
const int _tipRepeatNavigationCount = 3; // nav visits before tip

class GenieOnboarding {
  GenieOnboarding._();

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ─── First-Launch Detection ───────────────────────────────────────────────

  /// Returns true on the very first time this role opens Genie.
  static bool isFirstLaunchForRole(UserRole role) {
    return !(_prefs?.getBool('$_firstLaunchPrefix${role.name}') ?? false);
  }

  static Future<void> markFirstLaunchComplete(UserRole role) async {
    await _prefs?.setBool('$_firstLaunchPrefix${role.name}', true);
  }

  // ─── Role Greeting Data ───────────────────────────────────────────────────

  /// Returns a role-specific first-launch greeting payload.
  static RoleGreetingData greetingForRole(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return const RoleGreetingData(
          headline: 'Hi Owner 👋  I\'m Genie.',
          subline: 'Your personal command centre. Here are a few things you can ask:',
          exampleCommands: [
            'What\'s my balance?',
            'Show incoming orders',
            'Start an e-Play broadcast',
          ],
          ctaLabel: 'Show me more →',
        );
      case UserRole.administrator:
        return const RoleGreetingData(
          headline: 'Welcome, Admin. I\'m Genie.',
          subline: 'Manage your business with a single voice command:',
          exampleCommands: [
            'How many orders today?',
            'Show staff roster',
            'Send announcement',
          ],
          ctaLabel: 'Explore commands →',
        );
      case UserRole.driver:
        return const RoleGreetingData(
          headline: 'Hey Driver 🚗  Genie here.',
          subline: 'I\'ll keep your hands free. Try saying:',
          exampleCommands: [
            'Available packages',
            'My current delivery',
            'SOS',
          ],
          ctaLabel: 'Ready to go →',
        );
      case UserRole.socialOfficer:
      case UserRole.branchSocialOfficer:
        return const RoleGreetingData(
          headline: 'Hi Social Officer 📣  I\'m Genie.',
          subline: 'Manage your community and content:',
          exampleCommands: [
            'Post an update',
            'Check engagement',
            'Schedule a broadcast',
          ],
        );
      default:
        return const RoleGreetingData(
          headline: 'Hi there 👋  I\'m Genie.',
          subline: 'Your AI assistant. You can ask me things like:',
          exampleCommands: [
            '"What\'s my balance?"',
            '"Incoming orders"',
            '"Send a message to Alex"',
          ],
        );
    }
  }

  // ─── Confusion Detection ──────────────────────────────────────────────────

  /// Call whenever Genie fails to resolve an intent (unknown intent returned).
  static Future<bool> recordIntentFailure() async {
    final count = (_prefs?.getInt(_confusionCountKey) ?? 0) + 1;
    await _prefs?.setInt(_confusionCountKey, count);
    return count >= _confusionThreshold;
  }

  /// Reset confusion counter on successful intent resolution.
  static Future<void> resetConfusion() async {
    await _prefs?.setInt(_confusionCountKey, 0);
  }

  /// Returns the confusion lifeline tip if the threshold has been reached.
  static GenieTipCard? confusionLifeline() {
    final count = _prefs?.getInt(_confusionCountKey) ?? 0;
    if (count < _confusionThreshold) return null;
    return const GenieTipCard(
      id: 'confusion_lifeline',
      message: 'Here\'s a list of things you can ask me right now. '
          'Tap any to run it instantly.',
      actionLabel: 'Show all commands',
      actionIntent: GenieIntent(module: GenieModule.genie, action: 'help'),
    );
  }

  // ─── Navigation Pattern Tips ──────────────────────────────────────────────

  /// Records a manual navigation to a module route.
  static Future<GenieTipCard?> recordManualNavigation(
      String route, GenieModule module) async {
    final raw = _prefs?.getString('$_navPatternKey$route') ?? '0';
    final count = int.tryParse(raw) ?? 0;
    final newCount = count + 1;
    await _prefs?.setString('$_navPatternKey$route', '$newCount');

    if (newCount >= _tipRepeatNavigationCount &&
        !await _isTipDismissed('nav_tip_$route')) {
      return _navTipForModule(module, route);
    }
    return null;
  }

  static GenieTipCard? _navTipForModule(GenieModule module, String route) {
    final voiceCommand = _voiceCommandForModule(module);
    if (voiceCommand == null) return null;
    return GenieTipCard(
      id: 'nav_tip_$route',
      message: 'I notice you often visit ${_moduleLabel(module)}. '
          'Say "$voiceCommand" next time and I\'ll show you instantly.',
      actionLabel: 'Try it',
      actionIntent: GenieIntentResolver_staticResolve(voiceCommand),
    );
  }

  static String? _voiceCommandForModule(GenieModule m) {
    const map = {
      GenieModule.goPage: 'Check balance',
      GenieModule.market: 'Browse shops',
      GenieModule.live: 'Incoming orders',
      GenieModule.qualChat: 'Open chat',
      GenieModule.myUpdates: 'Show feed',
      GenieModule.eplay: 'Browse e-Play',
      GenieModule.community: 'Discover communities',
      GenieModule.alerts: 'Recent alerts',
      GenieModule.setupDashboard: 'Setup dashboard',
    };
    return map[m];
  }

  static String _moduleLabel(GenieModule m) {
    return m.name
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match[0]}')
        .trim()
        .toUpperCase();
  }

  // ─── Tip Dismissal ────────────────────────────────────────────────────────

  static Future<void> dismissTip(String tipId) async {
    final dismissed = _getDismissedTips();
    dismissed.add(tipId);
    await _prefs?.setString(_dismissedTipsKey, dismissed.join(','));
  }

  static Future<bool> _isTipDismissed(String tipId) async {
    return _getDismissedTips().contains(tipId);
  }

  static Set<String> _getDismissedTips() {
    final raw = _prefs?.getString(_dismissedTipsKey) ?? '';
    return raw.isEmpty ? {} : raw.split(',').toSet();
  }
}

/// Minimal static resolver shim for the onboarding tips.
/// Avoids a circular dependency on GenieIntentResolver.
GenieIntent? GenieIntentResolver_staticResolve(String command) {
  final t = command.toLowerCase();
  if (t.contains('balance')) {
    return const GenieIntent(module: GenieModule.goPage, action: 'check_balance');
  }
  if (t.contains('shop') || t.contains('browse')) {
    return const GenieIntent(module: GenieModule.market, action: 'browse_shops');
  }
  if (t.contains('order')) {
    return const GenieIntent(module: GenieModule.live, action: 'incoming_orders');
  }
  if (t.contains('chat')) {
    return const GenieIntent(module: GenieModule.qualChat, action: 'open_chat');
  }
  if (t.contains('feed') || t.contains('update')) {
    return const GenieIntent(module: GenieModule.myUpdates, action: 'show_feed');
  }
  if (t.contains('e-play') || t.contains('eplay')) {
    return const GenieIntent(module: GenieModule.eplay, action: 'browse');
  }
  if (t.contains('communit')) {
    return const GenieIntent(module: GenieModule.community, action: 'discover');
  }
  if (t.contains('alert')) {
    return const GenieIntent(module: GenieModule.alerts, action: 'recent_alerts');
  }
  if (t.contains('setup')) {
    return const GenieIntent(module: GenieModule.setupDashboard, action: 'open');
  }
  return null;
}
