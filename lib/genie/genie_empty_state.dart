/// ═══════════════════════════════════════════════════════════════════════════
/// GenieEmptyState
///
/// Recommendation 12 — Empty States as Delight.
///
/// Returns a contextual Genie message for every module's empty state,
/// turning "No data" into an opportunity: Genie proactively suggests an
/// action rooted in the user's history and role.
///
/// Usage:
///   GenieEmptyState.forModule(GenieModule.market, role: UserRole.owner)
///   → GenieTipCard with a warm, opportunity-framing message.
/// ═══════════════════════════════════════════════════════════════════════════

import '../features/prompt/models/rbac_models.dart';
import 'genie_intent.dart';
import 'genie_onboarding.dart';  // re-uses GenieTipCard

class GenieEmptyState {
  GenieEmptyState._();

  /// Returns a tip card to display when a module screen has no content.
  static GenieTipCard forModule(
    GenieModule module, {
    required UserRole role,
    Map<String, dynamic> context = const {},
  }) {
    switch (module) {
      case GenieModule.market:
        if (role == UserRole.owner || role == UserRole.administrator) {
          return const GenieTipCard(
            id: 'empty_market_owner',
            message: 'Your shop has no products yet. Want me to walk you through '
                'adding your first listing? Just say "Add a product".',
            actionLabel: 'Add product',
            actionIntent: GenieIntent(
              module: GenieModule.setupDashboard,
              action: 'add_product',
            ),
          );
        }
        return const GenieTipCard(
          id: 'empty_market_customer',
          message: 'No shops in range yet. Shall I notify you when one opens nearby?',
          actionLabel: 'Enable alerts',
          actionIntent: GenieIntent(module: GenieModule.alerts, action: 'location_alerts'),
        );

      case GenieModule.live:
        return const GenieTipCard(
          id: 'empty_live_orders',
          message: 'No orders right now — great time to review your delivery routes. '
              'Say "Optimise my route" and I\'ll plan it.',
          actionLabel: 'Optimise route',
          actionIntent: GenieIntent(module: GenieModule.live, action: 'optimise_route'),
        );

      case GenieModule.qualChat:
        return const GenieTipCard(
          id: 'empty_qualchat',
          message: 'No conversations yet. Start one — say "Message Alex" and I\'ll connect you.',
          actionLabel: 'Start a chat',
          actionIntent: GenieIntent(module: GenieModule.qualChat, action: 'new_conversation'),
        );

      case GenieModule.myUpdates:
        return const GenieTipCard(
          id: 'empty_updates',
          message: 'Your feed is quiet. Want me to find communities '
              'based on your interests?',
          actionLabel: 'Discover communities',
          actionIntent: GenieIntent(module: GenieModule.community, action: 'discover'),
        );

      case GenieModule.eplay:
        return const GenieTipCard(
          id: 'empty_eplay_locker',
          message: 'Your locker is empty. Want me to recommend your first '
              'title based on your e-Play history?',
          actionLabel: 'Get recommendations',
          actionIntent: GenieIntent(module: GenieModule.eplay, action: 'recommendations'),
        );

      case GenieModule.community:
        return const GenieTipCard(
          id: 'empty_community',
          message: 'You haven\'t joined any communities yet. '
              'Say "Find communities about [topic]" and I\'ll show you the best ones.',
          actionLabel: 'Discover communities',
          actionIntent: GenieIntent(module: GenieModule.community, action: 'discover'),
        );

      case GenieModule.goPage:
        return const GenieTipCard(
          id: 'empty_go_transactions',
          message: 'No transactions yet. You can say "Buy QPoints" to get started '
              'or "Check exchange rate" to see the current value.',
          actionLabel: 'Buy QPoints',
          actionIntent: GenieIntent(module: GenieModule.goPage, action: 'buy'),
        );

      case GenieModule.alerts:
        return const GenieTipCard(
          id: 'empty_alerts',
          message: 'All clear — no active alerts. You can ask me to send a '
              'test alert or configure notification preferences.',
          actionLabel: 'Alert settings',
          actionIntent: GenieIntent(module: GenieModule.setupDashboard, action: 'alert_settings'),
        );

      case GenieModule.setupDashboard:
        return GenieTipCard(
          id: 'empty_setup',
          message: role == UserRole.owner
              ? 'Your dashboard is a blank canvas. Say "Add a branch" or '
                '"Set up my shop" to begin building your business.'
              : 'Nothing configured yet. Your admin will set this up — '
                'ask me to remind them.',
          actionLabel: role == UserRole.owner ? 'Add a branch' : 'Remind admin',
          actionIntent: role == UserRole.owner
              ? const GenieIntent(
                  module: GenieModule.setupDashboard,
                  action: 'add_branch')
              : const GenieIntent(
                  module: GenieModule.qualChat,
                  action: 'send_message'),
        );

      default:
        return const GenieTipCard(
          id: 'empty_generic',
          message: 'Nothing here yet. Ask me anything — I\'m here to help.',
          actionLabel: 'What can you do?',
          actionIntent: GenieIntent(module: GenieModule.genie, action: 'help'),
        );
    }
  }
}
