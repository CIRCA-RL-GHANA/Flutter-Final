/// ═══════════════════════════════════════════════════════════════════════════
/// GenieInlineCard – Rich Module Cards Rendered Inside the Chat Thread
///
/// Each card type renders a functional micro-widget. Cards reuse module
/// color identities and expose action buttons that feed back into the
/// GenieController. Pinch-out triggers full-screen navigation.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../genie_intent.dart';
import '../genie_tactile_actions.dart';

/// Module accent colors matching the original spec.
const _moduleColors = {
  'go': Color(0xFFFFD700),
  'market': Color(0xFF2563EB),
  'updates': Color(0xFF8B5CF6),
  'live': Color(0xFF10B981),
  'alerts': Color(0xFFEF4444),
  'qualchat': Color(0xFF06B6D4),
  'april': Color(0xFFF59E0B),
  'setup': Color(0xFF6366F1),
  'utility': Color(0xFF6B7280),
  'user': Color(0xFF059669),
  'genie': Color(0xFFFFD700),
};

class GenieInlineCard extends StatelessWidget {
  final GenieMessage message;
  final VoidCallback? onExpandToFullScreen;

  const GenieInlineCard({
    super.key,
    required this.message,
    this.onExpandToFullScreen,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleEnd: (details) {
        if (details.velocity.pixelsPerSecond.distance > 200) {
          GenieTactileActions.onNavigate();
          onExpandToFullScreen?.call();
        }
      },
      child: _buildCard(),
    );
  }

  Widget _buildCard() {
    switch (message.cardType) {
      case GenieCardType.balance:
        return _BalanceCard(data: message.cardData);
      case GenieCardType.transaction:
        return _TransactionCard(data: message.cardData);
      case GenieCardType.orderSummary:
        return _OrderSummaryCard(data: message.cardData);
      case GenieCardType.orderTracker:
        return _OrderTrackerCard(data: message.cardData);
      case GenieCardType.shopCarousel:
        return _ShopCarouselCard(data: message.cardData);
      case GenieCardType.feedCard:
        return _FeedCard(data: message.cardData);
      case GenieCardType.liveOrders:
        return _LiveOrdersCard(data: message.cardData);
      case GenieCardType.driverDelivery:
        return _DriverDeliveryCard(data: message.cardData);
      case GenieCardType.alertList:
        return _AlertListCard(data: message.cardData);
      case GenieCardType.chatList:
        return _ChatListCard(data: message.cardData);
      case GenieCardType.operationsOverview:
        return _OperationsCard(data: message.cardData);
      case GenieCardType.profileStrength:
        return _ProfileStrengthCard(data: message.cardData);
      case GenieCardType.notificationHub:
        return _NotificationHubCard(data: message.cardData);
      case GenieCardType.helpGuide:
        return _HelpGuideCard(data: message.cardData);
      case GenieCardType.confirmation:
        return _ConfirmationCard(data: message.cardData);
      case GenieCardType.greeting:
        return _GreetingCard(data: message.cardData);
      case GenieCardType.comingSoon:
        return _ComingSoonCard();
      case GenieCardType.error:
        return _ErrorCard(data: message.cardData);
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── Card Shell ───────────────────────────────────────────────────────────────
class _CardShell extends StatelessWidget {
  final Color accentColor;
  final Widget child;
  final String? moduleLabel;

  const _CardShell({
    required this.accentColor,
    required this.child,
    this.moduleLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 320),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (moduleLabel != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    moduleLabel!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          child,
        ],
      ),
    );
  }
}

// ─── Action Button ────────────────────────────────────────────────────────────
class _CardActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDestructive;

  const _CardActionButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: () async {
          if (isDestructive) {
            await GenieTactileActions.onDestructiveConfirm();
          } else {
            await GenieTactileActions.onTap();
          }
          onTap();
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Balance Card ────────────────────────────────────────────────────────────
class _BalanceCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _BalanceCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final balance = data['balance'] ?? 14250;
    final rate = data['rate'] ?? 0.85;
    final color = _moduleColors['go']!;

    return _CardShell(
      accentColor: color,
      moduleLabel: 'GO PAGE',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              label: 'QPoints balance: $balance',
              child: Text(
                '${_formatNumber(balance)} QP',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '≈ \$${(balance * rate).toStringAsFixed(2)} USD · Rate: \$$rate',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _CardActionButton(
                  label: 'Buy',
                  color: color,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                _CardActionButton(
                  label: 'Sell',
                  color: AppColors.textSecondary,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                _CardActionButton(
                  label: 'Transfer',
                  color: AppColors.info,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(num n) {
    return n.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}

// ─── Transaction Card ─────────────────────────────────────────────────────────
class _TransactionCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _TransactionCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final txs = (data['transactions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final color = _moduleColors['go']!;

    return _CardShell(
      accentColor: color,
      moduleLabel: 'GO PAGE · TRANSACTIONS',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: txs.map((tx) {
            final isReceived = tx['type'] == 'received';
            return ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 16,
                backgroundColor: (isReceived ? AppColors.success : AppColors.error)
                    .withOpacity(0.12),
                child: Icon(
                  isReceived ? Icons.arrow_downward : Icons.arrow_upward,
                  size: 14,
                  color: isReceived ? AppColors.success : AppColors.error,
                ),
              ),
              title: Text(
                tx['id'] as String,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                tx['ago'] as String,
                style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
              ),
              trailing: Text(
                '${isReceived ? '+' : '-'}${tx['amount']} QP',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isReceived ? AppColors.success : AppColors.error,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── Order Summary Card ───────────────────────────────────────────────────────
class _OrderSummaryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _OrderSummaryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final items = data['items'] ?? 0;
    final total = data['total'] ?? 0;
    final color = _moduleColors['market']!;

    return _CardShell(
      accentColor: color,
      moduleLabel: 'MARKET · CART',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.shopping_cart_outlined, color: color, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$items items in cart',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('Total: $total QP',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            _CardActionButton(label: 'Checkout', color: color, onTap: () {}),
          ],
        ),
      ),
    );
  }
}

// ─── Order Tracker Card ───────────────────────────────────────────────────────
class _OrderTrackerCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _OrderTrackerCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final color = _moduleColors['market']!;
    return _CardShell(
      accentColor: color,
      moduleLabel: 'MARKET · TRACKING',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order #${data['orderId'] ?? ''}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.local_shipping_outlined,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${data['status'] ?? 'In transit'} · ETA: ${data['eta'] ?? '—'}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
            if (data['driverName'] != null) ...[
              const SizedBox(height: 8),
              Text('Driver: ${data['driverName']}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
            const SizedBox(height: 12),
            _CardActionButton(label: 'Track on Map', color: color, onTap: () {}),
          ],
        ),
      ),
    );
  }
}

// ─── Shop Carousel Card ───────────────────────────────────────────────────────
class _ShopCarouselCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ShopCarouselCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final shops = (data['shops'] as List?)?.cast<Map<String, dynamic>>() ?? [
      {'name': 'TechHub Store', 'distance': '0.3 km', 'rating': 4.8},
      {'name': 'Fresh Greens', 'distance': '0.7 km', 'rating': 4.6},
    ];
    final color = _moduleColors['market']!;

    return _CardShell(
      accentColor: color,
      moduleLabel: 'MARKET · SHOPS',
      child: Column(
        children: [
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: shops.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final shop = shops[i];
                return GestureDetector(
                  onTap: () => GenieTactileActions.onTap(),
                  child: Container(
                    width: 130,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: color.withOpacity(0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(shop['name'] as String,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text('${shop['distance']} · ⭐ ${shop['rating']}',
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: _CardActionButton(
                label: 'Browse All', color: color, onTap: () {}),
          ),
        ],
      ),
    );
  }
}

// ─── Feed Card ────────────────────────────────────────────────────────────────
class _FeedCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _FeedCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final color = _moduleColors['updates']!;
    return _CardShell(
      accentColor: color,
      moduleLabel: 'MY UPDATES · FEED',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.rss_feed, color: color, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Your personalised feed is ready. Tap to browse.',
                style: TextStyle(fontSize: 13),
              ),
            ),
            _CardActionButton(label: 'View', color: color, onTap: () {}),
          ],
        ),
      ),
    );
  }
}

// ─── Live Orders Card ─────────────────────────────────────────────────────────
class _LiveOrdersCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _LiveOrdersCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final orders = (data['orders'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final color = _moduleColors['live']!;

    return _CardShell(
      accentColor: color,
      moduleLabel: 'LIVE · ORDERS',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: orders.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No active orders right now.',
                    style: TextStyle(color: AppColors.textSecondary)),
              )
            : Column(
                children: orders.map((order) {
                  final urgent = order['urgent'] == true;
                  return ListTile(
                    dense: true,
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: (urgent ? AppColors.error : color).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        urgent ? Icons.priority_high : Icons.inventory_2_outlined,
                        size: 16,
                        color: urgent ? AppColors.error : color,
                      ),
                    ),
                    title: Text(
                      order['id'] as String,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${order['customer']} · ${order['items']} item(s)',
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: _CardActionButton(
                      label: 'Assign',
                      color: color,
                      onTap: () {},
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }
}

// ─── Driver Delivery Card ─────────────────────────────────────────────────────
class _DriverDeliveryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _DriverDeliveryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final color = _moduleColors['live']!;
    final packages = (data['packages'] as List?)?.cast<Map>() ?? [];

    return _CardShell(
      accentColor: color,
      moduleLabel: 'LIVE · DRIVER',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: data['type'] == 'current'
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.navigation, color: color, size: 20),
                    const SizedBox(width: 8),
                    Text(data['destination'] ?? 'Destination',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 4),
                  Text('ETA: ${data['eta'] ?? '—'}',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 12),
                  Row(children: [
                    _CardActionButton(
                        label: 'Navigate', color: color, onTap: () {}),
                    const SizedBox(width: 8),
                    _CardActionButton(
                        label: '🆘 SOS',
                        color: AppColors.error,
                        onTap: () {},
                        isDestructive: true),
                  ]),
                ],
              )
            : packages.isEmpty
                ? const Text('No packages available.',
                    style: TextStyle(color: AppColors.textSecondary))
                : Column(
                    children: packages.map((pkg) {
                      return ListTile(
                        dense: true,
                        title: Text(pkg['id']?.toString() ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          '${pkg['stops']} stops · ${pkg['distance']} · ETA ${pkg['eta']}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: _CardActionButton(
                          label: 'Accept',
                          color: color,
                          onTap: () {},
                        ),
                      );
                    }).toList(),
                  ),
      ),
    );
  }
}

// ─── Alert List Card ──────────────────────────────────────────────────────────
class _AlertListCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _AlertListCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final alerts = (data['alerts'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final color = _moduleColors['alerts']!;

    return _CardShell(
      accentColor: color,
      moduleLabel: 'ALERTS',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: alerts.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No alerts at this time.',
                    style: TextStyle(color: AppColors.textSecondary)),
              )
            : Column(
                children: alerts.map((alert) {
                  final resolved = alert['status'] == 'resolved';
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      resolved ? Icons.check_circle_outline : Icons.warning_amber_outlined,
                      color: resolved ? AppColors.success : color,
                      size: 20,
                    ),
                    title: Text(alert['id'] as String,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      '${alert['type']} · ${alert['age']}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: resolved
                        ? const Text('✓',
                            style: TextStyle(color: AppColors.success))
                        : _CardActionButton(
                            label: 'Resolve',
                            color: color,
                            onTap: () {}),
                  );
                }).toList(),
              ),
      ),
    );
  }
}

// ─── Chat List Card ───────────────────────────────────────────────────────────
class _ChatListCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ChatListCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final color = _moduleColors['qualchat']!;
    final type = data['type'] ?? 'chats';

    return _CardShell(
      accentColor: color,
      moduleLabel: 'qualChat${type == 'hey_ya' ? ' · HEY YA' : type == 'fleet' ? ' · FLEET' : ''}',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              type == 'presence'
                  ? Icons.people_outline
                  : type == 'hey_ya'
                      ? Icons.auto_awesome
                      : Icons.chat_bubble_outline,
              color: color,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Tap to open your conversations.',
                  style: TextStyle(fontSize: 13)),
            ),
            _CardActionButton(label: 'Open', color: color, onTap: () {}),
          ],
        ),
      ),
    );
  }
}

// ─── Operations Overview Card ─────────────────────────────────────────────────
class _OperationsCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _OperationsCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final color = _moduleColors['setup']!;

    return _CardShell(
      accentColor: color,
      moduleLabel: 'SETUP DASHBOARD',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _StatChip(label: 'Products', value: '1,245', color: color),
            _StatChip(label: 'Staff', value: '23', color: color),
            _StatChip(label: 'Branches', value: '3', color: color),
            _StatChip(label: 'Campaigns', value: '5', color: color),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ─── Profile Strength Card ────────────────────────────────────────────────────
class _ProfileStrengthCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ProfileStrengthCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final strength = (data['strength'] as num?)?.toDouble() ?? 78;
    final color = _moduleColors['user']!;

    return _CardShell(
      accentColor: color,
      moduleLabel: 'USER DETAILS',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Profile Strength',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text('${strength.toInt()}%',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: color)),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: strength / 100,
                backgroundColor: color.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            _CardActionButton(
                label: 'Complete Profile', color: color, onTap: () {}),
          ],
        ),
      ),
    );
  }
}

// ─── Notification Hub Card ────────────────────────────────────────────────────
class _NotificationHubCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _NotificationHubCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final color = _moduleColors['utility']!;

    return _CardShell(
      accentColor: color,
      moduleLabel: 'UTILITY · NOTIFICATIONS',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.notifications_outlined, color: color, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('3 unread notifications.',
                  style: TextStyle(fontSize: 13)),
            ),
            _CardActionButton(label: 'View All', color: color, onTap: () {}),
          ],
        ),
      ),
    );
  }
}

// ─── Help Guide Card ─────────────────────────────────────────────────────────
class _HelpGuideCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _HelpGuideCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final color = _moduleColors['utility']!;
    final reminders =
        (data['reminders'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return _CardShell(
      accentColor: color,
      moduleLabel: data['reminders'] != null ? 'APRIL · REMINDERS' : 'HELP',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: reminders.isNotEmpty
            ? Column(
                children: reminders.map((r) {
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.access_time, size: 18,
                        color: AppColors.textSecondary),
                    title: Text(r['title'] as String,
                        style: const TextStyle(fontSize: 13)),
                    subtitle: Text(r['time'] as String,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                  );
                }).toList(),
              )
            : Row(
                children: [
                  Icon(Icons.help_outline, color: color, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Tap to open the help center.',
                        style: TextStyle(fontSize: 13)),
                  ),
                  _CardActionButton(label: 'Help', color: color, onTap: () {}),
                ],
              ),
      ),
    );
  }
}

// ─── Confirmation Card ────────────────────────────────────────────────────────
class _ConfirmationCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ConfirmationCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final action = data['action'] as String? ?? '';
    final color = action == 'sos' ? AppColors.error : AppColors.primary;

    return _CardShell(
      accentColor: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (action == 'transfer') ...[
              Text(
                'Transfer ${data['amount']} QP to ${data['recipient']}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              const Text(
                'Double-tap Confirm to authorise with biometrics.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Row(children: [
                _CardActionButton(
                    label: 'Confirm',
                    color: color,
                    onTap: () {},
                    isDestructive: true),
                const SizedBox(width: 8),
                _CardActionButton(
                    label: 'Cancel',
                    color: AppColors.textSecondary,
                    onTap: () {}),
              ]),
            ] else if (action == 'sos') ...[
              const Text('🆘 Emergency SOS Activated',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.error,
                      fontSize: 16)),
              const SizedBox(height: 4),
              const Text('Fleet manager and emergency services notified.',
                  style: TextStyle(fontSize: 13)),
            ] else ...[
              Text('Confirm: $action',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _CardActionButton(label: 'Confirm', color: color, onTap: () {},
                  isDestructive: true),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Greeting Card ────────────────────────────────────────────────────────────
class _GreetingCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _GreetingCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // Greeting text is shown directly in bubble
  }
}

// ─── Coming Soon Card ─────────────────────────────────────────────────────────
class _ComingSoonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.open_in_new, size: 14, color: AppColors.textTertiary),
          SizedBox(width: 6),
          Text('Opening full screen…',
              style: TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ─── Error Card ───────────────────────────────────────────────────────────────
class _ErrorCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ErrorCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              data['message'] as String? ?? 'Something went wrong.',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
