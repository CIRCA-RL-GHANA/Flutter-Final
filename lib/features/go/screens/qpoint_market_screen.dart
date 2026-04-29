/// Q Points Market Screen — Full production implementation
/// Sections: Stats Bar | Order Book | Place Order | Open Orders | Trade History
///
/// Access is gated behind Q Points ToS acceptance (v1.0.0).
/// Users who have not accepted are shown the ToS screen first.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/qpoint_market_provider.dart';
import '../providers/qpoints_tos_provider.dart';
import '../models/qpoint_market_models.dart';
import 'qpoints_tos_screen.dart';

// ── Brand colour for the market module ──────────────────────────────────────
const Color kMarketColor = Color(0xFF6C47FF); // deep violet

/// Entry point: checks ToS acceptance, shows ToS screen or the market.
class QPointMarketScreen extends StatefulWidget {
  const QPointMarketScreen({super.key});

  @override
  State<QPointMarketScreen> createState() => _QPointMarketScreenState();
}

class _QPointMarketScreenState extends State<QPointMarketScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  bool _tosCheckComplete = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkTos());
  }

  Future<void> _checkTos() async {
    final tosProvider = context.read<QPointsTosProvider>();
    await tosProvider.loadTosStatus();
    if (!mounted) return;
    if (tosProvider.isAccepted) {
      setState(() => _tosCheckComplete = true);
      context.read<QPointMarketProvider>().loadAll();
    } else {
      // Navigate to the ToS acceptance screen; replace so Back doesn't loop
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: tosProvider,
            child: QPointsTosScreen(
              onAccepted: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: tosProvider,
                      child: const QPointMarketScreen(),
                    ),
                  ),
                );
              },
              onDeclined: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading spinner while the ToS status is being checked
    if (!_tosCheckComplete) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F3FF),
        body: Center(
          child: CircularProgressIndicator(color: kMarketColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F3FF),
      appBar: AppBar(
        backgroundColor: kMarketColor,
        foregroundColor: Colors.white,
        title: const Text('Q Points Market',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Fees & Disclosures (§7)',
            onPressed: () => _showFeeSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
            onPressed: () => _showNotificationsSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<QPointMarketProvider>().loadAll(),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Market'),
            Tab(text: 'Orders'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: Consumer<QPointMarketProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // ── Stats banner ─────────────────────────────────────────────
              _StatsBanner(provider: provider),

              // ── Tabs ─────────────────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tab,
                  children: [
                    _MarketTab(provider: provider),
                    _OrdersTab(provider: provider),
                    _HistoryTab(provider: provider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<QPointMarketProvider>(
        builder: (_, p, __) => FloatingActionButton.extended(
          backgroundColor: kMarketColor,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Place Order'),
          onPressed: () => _showPlaceOrderSheet(context, p),
        ),
      ),
    );
  }

  // ── Sheets ────────────────────────────────────────────────────────────────

  void _showPlaceOrderSheet(BuildContext ctx, QPointMarketProvider provider) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: const _PlaceOrderSheet(),
      ),
    );
  }

  void _showNotificationsSheet(BuildContext ctx) {
    context.read<QPointMarketProvider>().loadNotifications();
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<QPointMarketProvider>(),
        child: const _NotificationsSheet(),
      ),
    );
  }

  /// Fee & Disclosure sheet — TOS §7.1 requires fees to be disclosed on the Platform.
  void _showFeeSheet(BuildContext ctx) {
    context.read<QPointMarketProvider>().loadFeeSchedule();
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<QPointMarketProvider>(),
        child: const _FeeDisclosureSheet(),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Stats Banner
// ════════════════════════════════════════════════════════════════════════════

class _StatsBanner extends StatelessWidget {
  final QPointMarketProvider provider;
  const _StatsBanner({required this.provider});

  @override
  Widget build(BuildContext context) {
    final stats = provider.stats;
    final balance = provider.balance;

    return Container(
      color: kMarketColor,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Stat(
                label: 'Balance',
                value: balance != null
                    ? '${balance.balance.toStringAsFixed(2)} QP'
                    : '—',
              ),
              const SizedBox(width: 16),
              const _Stat(
                label: 'Price',
                value: '\$1.00',
              ),
              const SizedBox(width: 16),
              _Stat(
                label: 'Vol 24h (QP)',
                value: stats != null ? _formatVol(stats.volume24h) : '—',
              ),
            ],
          ),
          const SizedBox(height: 8),
          // TOS §5.2 — AI last-resort counterparty indicator (operational, not a legal guarantee)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade700,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.smart_toy_outlined, color: Colors.white, size: 12),
                SizedBox(width: 4),
                Text(
                  'AI Standby at \$1.00',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatVol(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white60, fontSize: 10)),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      );
}

// ════════════════════════════════════════════════════════════════════════════
// Market Tab: Order Book + Quick Buy/Sell
// ════════════════════════════════════════════════════════════════════════════

class _MarketTab extends StatelessWidget {
  final QPointMarketProvider provider;
  const _MarketTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Cash balance card — real-time facilitator liquidity with Refresh button
        _CashBalanceCard(provider: provider),
        const SizedBox(height: 16),
        // Bridge suspension banner — only shown when active facilitator's bridge is down
        if (provider.bridgeUnavailableMessage != null)
          _BridgeStatusBanner(message: provider.bridgeUnavailableMessage!),
        if (provider.bridgeUnavailableMessage != null)
          const SizedBox(height: 12),
        // Active payment method indicator
        if (provider.activeFacilitatorId != null)
          _ActiveFacilitatorChip(facilitatorId: provider.activeFacilitatorId!),
        if (provider.activeFacilitatorId != null)
          const SizedBox(height: 12),
        _QuickActions(provider: provider),
        const SizedBox(height: 16),
        _OrderBookWidget(provider: provider),
      ],
    );
  }
}

/// Shows the platform's real-time cash balance at the user's primary facilitator.
///
/// Displays:
///   - Balance amount (or "Unavailable" with a reason)
///   - "Via [Facilitator]" + cached/live badge
///   - Last updated timestamp
///   - Refresh icon button (force-bypasses the 30-second cache)
///   - Tooltip explaining the 0.1% liquidity fee on buy and sell prices
class _CashBalanceCard extends StatelessWidget {
  final QPointMarketProvider provider;
  const _CashBalanceCard({required this.provider});

  static const Map<String, String> _providerNames = {
    'stripe': 'Stripe',
    'paystack': 'Paystack',
    'flutterwave': 'Flutterwave',
    'mtn_momo': 'MTN MoMo',
    'mpesa': 'M-Pesa',
    'wise': 'Wise',
    'mock': 'Test Mode',
  };

  String _providerName(String? id) =>
      _providerNames[id ?? 'mock'] ?? (id ?? 'Facilitator');

  String _formatAmount(double? amount) {
    if (amount == null) return '—';
    return '\$${amount.toStringAsFixed(2)}';
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final cb = provider.cashBalance;
    final isLoading = provider.isLoadingCashBalance;
    final facilitatorId = provider.activeFacilitatorId;
    final providerName = _providerName(facilitatorId ?? cb?.facilitatorId);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C47FF), Color(0xFF9B79FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C47FF).withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────────────
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Available via $providerName',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              // Cached badge
              if (cb != null && cb.isCached)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'CACHED',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 9,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              // Refresh button
              SizedBox(
                width: 28,
                height: 28,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: isLoading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white70,
                          ),
                        )
                      : const Icon(Icons.refresh,
                          color: Colors.white70, size: 18),
                  tooltip: 'Refresh balance',
                  onPressed: isLoading
                      ? null
                      : () => provider.loadCashBalance(forceRefresh: true),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Balance amount ───────────────────────────────────────────
          if (isLoading && cb == null)
            const SizedBox(
              height: 32,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else if (cb == null)
            const Text(
              'Register a payment account to see balance',
              style: TextStyle(color: Colors.white60, fontSize: 13),
            )
          else if (!cb.isAvailable)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Balance unavailable',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cb.unavailableReason ?? '',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                ),
              ],
            )
          else
            Text(
              _formatAmount(cb.cashBalanceUsd),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),

          const SizedBox(height: 12),

          // ── Fee disclosure row (TOS §7.1) ────────────────────────────
          if (cb != null)
            Row(
              children: [
                Tooltip(
                  message: cb.feeDescription,
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D2B9F),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info_outline,
                          color: Colors.white54, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        '${cb.liquidityFeePercent}% liquidity fee  '
                        '·  Buy \$${cb.buyPrice.toStringAsFixed(3)}'
                        '  ·  Sell \$${cb.sellPrice.toStringAsFixed(3)}',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Last updated timestamp
                if (provider.cashBalanceLastUpdated != null)
                  Text(
                    'Updated ${_formatTime(provider.cashBalanceLastUpdated)}',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Shows a non-blocking warning banner when the bridge is temporarily suspended
/// for the user's active payment facilitator.
class _BridgeStatusBanner extends StatelessWidget {
  final String message;
  const _BridgeStatusBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        border: Border.all(color: Colors.amber.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.amber.shade800, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.amber.shade900,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small chip showing the user's active payment method provider name.
class _ActiveFacilitatorChip extends StatelessWidget {
  final String facilitatorId;
  const _ActiveFacilitatorChip({required this.facilitatorId});

  /// Returns a human-friendly display name for the provider ID.
  String _displayName(String id) {
    const names = {
      'stripe': 'Stripe',
      'paystack': 'Paystack',
      'flutterwave': 'Flutterwave',
      'mtn_momo': 'MTN MoMo',
      'mpesa': 'M-Pesa',
      'wise': 'Wise',
      'mock': 'Test Mode',
    };
    return names[id] ?? id;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                size: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 5),
            Text(
              'Via ${_displayName(facilitatorId)}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final QPointMarketProvider provider;
  const _QuickActions({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            label: 'Buy QP',
            subLabel: 'Pay \$1.001 per QP',
            color: Colors.green.shade600,
            icon: Icons.trending_up,
            onTap: () => _showCashInSheet(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            label: 'Sell QP',
            subLabel: 'Receive \$0.999 per QP',
            color: Colors.red.shade600,
            icon: Icons.trending_down,
            onTap: () => _showCashOutSheet(context),
          ),
        ),
      ],
    );
  }

  void _showCashInSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: const _CashInOutSheet(isBuy: true),
      ),
    );
  }

  void _showCashOutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: const _CashInOutSheet(isBuy: false),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String label;
  final String subLabel;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.label,
    required this.subLabel,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      Text(subLabel,
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _OrderBookWidget extends StatelessWidget {
  final QPointMarketProvider provider;
  const _OrderBookWidget({required this.provider});

  @override
  Widget build(BuildContext context) {
    final book = provider.orderBook;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.book, size: 18, color: kMarketColor),
            const SizedBox(width: 6),
            const Text('Order Book',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const Spacer(),
            if (provider.isLoadingBook)
              const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: kMarketColor)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Buys column
            Expanded(
              child: Column(
                children: [
                  const _BookHeader(label: 'BIDS', color: Colors.green),
                  if (book == null || book.buys.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child:
                          Text('No bids', style: TextStyle(color: Colors.black38, fontSize: 12)),
                    )
                  else
                    ...book.buys
                        .take(8)
                        .map((l) => _BookRow(level: l, isBuy: true)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Sells column
            Expanded(
              child: Column(
                children: [
                  const _BookHeader(label: 'ASKS', color: Colors.red),
                  if (book == null || book.sells.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No asks',
                          style:
                              TextStyle(color: Colors.black38, fontSize: 12)),
                    )
                  else
                    ...book.sells
                        .take(8)
                        .map((l) => _BookRow(level: l, isBuy: false)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BookHeader extends StatelessWidget {
  final String label;
  final Color color;
  const _BookHeader({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                    TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
            const Text('QTY',
                style: TextStyle(color: Colors.black38, fontSize: 10)),
          ],
        ),
      );
}

class _BookRow extends StatelessWidget {
  final OrderBookLevel level;
  final bool isBuy;
  const _BookRow({required this.level, required this.isBuy});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('\$${level.price.toStringAsFixed(4)}',
                style: TextStyle(
                    color: isBuy ? Colors.green.shade700 : Colors.red.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
            Text(level.quantity.toStringAsFixed(2),
                style:
                    const TextStyle(color: Colors.black54, fontSize: 11)),
          ],
        ),
      );
}

// ════════════════════════════════════════════════════════════════════════════
// Orders Tab
// ════════════════════════════════════════════════════════════════════════════

class _OrdersTab extends StatelessWidget {
  final QPointMarketProvider provider;
  const _OrdersTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.isLoadingOrders) {
      return const Center(child: CircularProgressIndicator(color: kMarketColor));
    }

    if (provider.openOrders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.black26),
            SizedBox(height: 12),
            Text('No open orders', style: TextStyle(color: Colors.black38)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.openOrders.length,
      itemBuilder: (ctx, i) => _OpenOrderTile(
        order: provider.openOrders[i],
        onCancel: () async {
          final err = await provider.cancelOrder(provider.openOrders[i].id);
          if (err != null && ctx.mounted) {
            ScaffoldMessenger.of(ctx)
                .showSnackBar(SnackBar(content: Text(err)));
          }
        },
      ),
    );
  }
}

class _OpenOrderTile extends StatelessWidget {
  final QPointOrder order;
  final VoidCallback onCancel;
  const _OpenOrderTile({required this.order, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final isBuy = order.type == QPointOrderType.buy;
    final color = isBuy ? Colors.green.shade600 : Colors.red.shade600;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(isBuy ? 'BUY' : 'SELL',
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 11)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('\$${order.price.toStringAsFixed(4)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(
                    '${order.filledQuantity.toStringAsFixed(2)} / ${order.quantity.toStringAsFixed(2)} QP',
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: onCancel,
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// History Tab
// ════════════════════════════════════════════════════════════════════════════

class _HistoryTab extends StatefulWidget {
  final QPointMarketProvider provider;
  const _HistoryTab({required this.provider});

  @override
  State<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<_HistoryTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.provider.loadTradeHistory());
  }

  @override
  Widget build(BuildContext context) {
    final trades = widget.provider.tradeHistory;

    if (trades.isEmpty) {
      return const Center(
        child: Text('No trade history', style: TextStyle(color: Colors.black38)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trades.length,
      itemBuilder: (ctx, i) => _TradeTile(trade: trades[i]),
    );
  }
}

class _TradeTile extends StatelessWidget {
  final QPointTrade trade;
  const _TradeTile({required this.trade});

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: kMarketColor.withOpacity(0.1),
            child:
                const Icon(Icons.swap_horiz, color: kMarketColor, size: 20),
          ),
          title: Text(
            '\$${trade.price.toStringAsFixed(4)} × ${trade.quantity.toStringAsFixed(2)} QP',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          subtitle: Text(
            _formatDate(trade.createdAt),
            style: const TextStyle(fontSize: 11, color: Colors.black45),
          ),
          trailing: Text(
            '\$${(trade.price * trade.quantity).toStringAsFixed(2)}',
            style: const TextStyle(
                color: kMarketColor, fontWeight: FontWeight.bold),
          ),
        ),
      );

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Place Order Bottom Sheet
// ════════════════════════════════════════════════════════════════════════════

class _PlaceOrderSheet extends StatefulWidget {
  const _PlaceOrderSheet();

  @override
  State<_PlaceOrderSheet> createState() => _PlaceOrderSheetState();
}

class _PlaceOrderSheetState extends State<_PlaceOrderSheet> {
  final _qtyCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _type = 'buy';

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QPointMarketProvider>(
      builder: (ctx, provider, _) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text('Place Order',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 4),
              const Text(
                '1 Q Point = \$1.00 USD (fixed)',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Buy / Sell toggle
              Row(
                children: [
                  _TypeButton(
                    label: 'Buy',
                    selected: _type == 'buy',
                    color: Colors.green.shade600,
                    onTap: () => setState(() => _type = 'buy'),
                  ),
                  const SizedBox(width: 12),
                  _TypeButton(
                    label: 'Sell',
                    selected: _type == 'sell',
                    color: Colors.red.shade600,
                    onTap: () => setState(() => _type = 'sell'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _qtyCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Quantity (QP)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Enter a valid quantity';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Estimated total using fixed $1.00
              if (_qtyCtrl.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Total: \$${(double.tryParse(_qtyCtrl.text) ?? 0).toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: kMarketColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kMarketColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: provider.isPlacingOrder
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          final err = await provider.placeOrder(
                            type: _type,
                            price: 1.0,
                            quantity: double.parse(_qtyCtrl.text),
                          );
                          if (!ctx.mounted) return;
                          if (err == null) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                content: Text('Order placed!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text(err),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: provider.isPlacingOrder
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text('Place ${_type == 'buy' ? 'Buy' : 'Sell'} Order'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? color : color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
}

// ════════════════════════════════════════════════════════════════════════════
// Cash In / Cash Out Bottom Sheet
// ════════════════════════════════════════════════════════════════════════════

class _CashInOutSheet extends StatefulWidget {
  final bool isBuy;
  const _CashInOutSheet({required this.isBuy});

  @override
  State<_CashInOutSheet> createState() => _CashInOutSheetState();
}

class _CashInOutSheetState extends State<_CashInOutSheet> {
  final _qtyCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QPointMarketProvider>(
      builder: (ctx, provider, _) {
        const fixedPrice = 1.0;
        final qty = double.tryParse(_qtyCtrl.text) ?? 0;
        final estimated = qty > 0 ? fixedPrice * qty : null;
        final isLoading =
            widget.isBuy ? provider.isCashingIn : provider.isCashingOut;
        final color =
            widget.isBuy ? Colors.green.shade600 : Colors.red.shade600;

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            24 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                Text(
                  widget.isBuy ? 'Buy Q Points' : 'Sell Q Points for Cash',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 16),
                    child: Text(
                      'Price: \$1.00 per QP (fixed)',
                      style: TextStyle(color: color, fontWeight: FontWeight.w500),
                    ),
                  ),
                TextFormField(
                  controller: _qtyCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Quantity (QP)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    if (n == null || n <= 0) return 'Enter a valid quantity';
                    return null;
                  },
                ),
                if (estimated != null && qty > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      widget.isBuy
                          ? 'Estimated cost: \$${estimated.toStringAsFixed(2)}'
                          : 'Estimated payout: \$${estimated.toStringAsFixed(2)}',
                      style: TextStyle(
                          color: color, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;
                            final q = double.parse(_qtyCtrl.text);
                            final err = widget.isBuy
                                ? await provider.cashIn(q)
                                : await provider.cashOut(q);
                            if (!ctx.mounted) return;
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text(err ?? 'Success!'),
                                backgroundColor:
                                    err != null ? Colors.red : Colors.green,
                              ),
                            );
                          },
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(widget.isBuy ? 'Confirm Buy' : 'Confirm Sell'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Notifications Bottom Sheet
// ════════════════════════════════════════════════════════════════════════════

class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet();

  @override
  Widget build(BuildContext context) {
    return Consumer<QPointMarketProvider>(
      builder: (ctx, provider, _) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: Row(
                children: [
                  const Text('Notifications',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const Spacer(),
                  if (provider.unreadCount > 0)
                    TextButton(
                      onPressed: provider.markAllNotificationsRead,
                      child: const Text('Mark all read'),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: provider.notifications.isEmpty
                  ? const Center(
                      child: Text('No notifications',
                          style: TextStyle(color: Colors.black38)))
                  : ListView.builder(
                      itemCount: provider.notifications.length,
                      itemBuilder: (c, i) =>
                          _NotificationTile(n: provider.notifications[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final QPointNotification n;
  const _NotificationTile({required this.n});

  @override
  Widget build(BuildContext context) {
    final icon = _iconFor(n.type);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: kMarketColor.withOpacity(n.read ? 0.05 : 0.15),
        child: Icon(icon,
            color: n.read ? Colors.black38 : kMarketColor, size: 18),
      ),
      title: Text(n.message,
          style: TextStyle(
              fontWeight: n.read ? FontWeight.normal : FontWeight.bold,
              fontSize: 13)),
      subtitle: Text(
        _formatDate(n.createdAt),
        style: const TextStyle(fontSize: 11, color: Colors.black38),
      ),
    );
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'trade_executed':
        return Icons.swap_horiz;
      case 'order_filled':
        return Icons.check_circle_outline;
      case 'order_cancelled':
        return Icons.cancel_outlined;
      case 'settlement_failed':
        return Icons.error_outline;
      case 'settlement_pending':
        return Icons.hourglass_bottom_outlined;
      case 'market_alert':
        return Icons.notifications_active_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.month}/${dt.day}';
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Fee Disclosure Sheet — TOS §7.1 & §7.2
// "Fees will be disclosed on the Platform and may be changed upon notice."
// ════════════════════════════════════════════════════════════════════════════

class _FeeDisclosureSheet extends StatelessWidget {
  const _FeeDisclosureSheet();

  @override
  Widget build(BuildContext context) {
    return Consumer<QPointMarketProvider>(
      builder: (ctx, provider, _) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long_outlined, color: kMarketColor, size: 22),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Fees & Disclosures',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: kMarketColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Q Points Terms of Service §7.1 — Fee Disclosure',
                style: TextStyle(fontSize: 11, color: kMarketColor, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            if (provider.isLoadingFees)
              const Center(child: CircularProgressIndicator(color: kMarketColor))
            else ...[
              _FeeRow(
                icon: Icons.swap_horiz,
                label: 'Trade Execution Fee',
                value: provider.feeSchedule != null
                    ? '\$${provider.feeSchedule!.tradeFeePerTrade.toStringAsFixed(2)} per trade (charged to taker)'
                    : '\$0.02 per matched trade (charged to taker)',
                detail: 'Charged on each successfully matched order.',
              ),
              _FeeRow(
                icon: Icons.add_circle_outline,
                label: 'Order Placement Fee',
                value: '\$0.00',
                detail: 'No fee for placing or cancelling a limit order.',
              ),
              _FeeRow(
                icon: Icons.output,
                label: 'Withdrawal Fee',
                value: '\$0.00 (Platform)',
                detail: 'No Platform fee for Q Points withdrawal. Facilitator fees may apply.',
              ),
              _FeeRow(
                icon: Icons.lock,
                label: 'Fixed Exchange Rate',
                value: provider.feeSchedule?.pegRate ?? '1.00 Q Points = \$1.00 USD (fixed)',
                detail: 'The price peg is fixed. 1 Q Point is always equal to \$1.00 USD.',
              ),
              const SizedBox(height: 16),
              // Tax disclosure — TOS §7.2
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFCC80)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.account_balance_outlined,
                            size: 16, color: Color(0xFFE65100)),
                        SizedBox(width: 6),
                        Text(
                          'Tax Disclosure — Q Points ToS §7.2',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Color(0xFFE65100),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.feeSchedule?.description.isNotEmpty == true
                          ? provider.feeSchedule!.description
                          : 'You are solely responsible for determining and paying any taxes '
                              'that may apply to your use of Q Points, including any taxes on '
                              'trades or gains. The Company does not withhold or remit taxes '
                              'on your behalf, except as required by law.',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF555555), height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Fees may be changed upon notice per Q Points Terms of Service §7.1.',
                style: TextStyle(fontSize: 11, color: Colors.black38),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String detail;

  const _FeeRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: kMarketColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text(value,
                    style: const TextStyle(
                        color: kMarketColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                Text(detail,
                    style: const TextStyle(
                        color: Colors.black45, fontSize: 11, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
