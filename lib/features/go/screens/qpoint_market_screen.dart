/// Q Points Market Screen — Full production implementation
/// Sections: Stats Bar | Order Book | Place Order | Open Orders | Trade History

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/qpoint_market_provider.dart';
import '../models/qpoint_market_models.dart';

// ── Brand colour for the market module ──────────────────────────────────────
const Color kMarketColor = Color(0xFF6C47FF); // deep violet

class QPointMarketScreen extends StatefulWidget {
  const QPointMarketScreen({super.key});

  @override
  State<QPointMarketScreen> createState() => _QPointMarketScreenState();
}

class _QPointMarketScreenState extends State<QPointMarketScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QPointMarketProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F3FF),
      appBar: AppBar(
        backgroundColor: kMarketColor,
        foregroundColor: Colors.white,
        title: const Text('Q Points Market',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
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
      child: Row(
        children: [
          _Stat(
            label: 'Balance',
            value: balance != null
                ? '${balance.balance.toStringAsFixed(2)} QP'
                : '—',
          ),
          const SizedBox(width: 16),
          _Stat(
            label: 'Last Price',
            value: stats?.lastPrice != null
                ? '\$${stats!.lastPrice!.toStringAsFixed(4)}'
                : '—',
          ),
          const SizedBox(width: 16),
          _Stat(
            label: 'Spread',
            value: stats?.spreadPercent != null
                ? '${stats!.spreadPercent!.toStringAsFixed(2)}%'
                : '—',
          ),
          const SizedBox(width: 16),
          _Stat(
            label: 'Vol 24h',
            value: stats != null
                ? _formatVol(stats.volume24h)
                : '—',
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
        _QuickActions(provider: provider),
        const SizedBox(height: 16),
        _OrderBookWidget(provider: provider),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  final QPointMarketProvider provider;
  const _QuickActions({required this.provider});

  @override
  Widget build(BuildContext context) {
    final bestBid = provider.orderBook?.bestBid;
    final bestAsk = provider.orderBook?.bestAsk;

    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            label: 'Buy QP',
            subLabel: bestAsk != null
                ? 'Best ask: \$${bestAsk.toStringAsFixed(4)}'
                : 'No sell orders',
            color: Colors.green.shade600,
            icon: Icons.trending_up,
            onTap: () => _showCashInSheet(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            label: 'Sell QP',
            subLabel: bestBid != null
                ? 'Best bid: \$${bestBid.toStringAsFixed(4)}'
                : 'No buy orders',
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
  final _priceCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _type = 'buy';

  @override
  void dispose() {
    _priceCtrl.dispose();
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
              const Text('Place Limit Order',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                controller: _priceCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Price per QP (USD)',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Enter a valid price';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _qtyCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Quantity (QP)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Enter a valid quantity';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Estimated total
              if (_priceCtrl.text.isNotEmpty && _qtyCtrl.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Estimated: \$${(double.tryParse(_priceCtrl.text) ?? 0) * (double.tryParse(_qtyCtrl.text) ?? 0)}'
                        .replaceAllMapped(
                      RegExp(r'(\d+)\.(\d{2})\d*'),
                      (m) => '${m[1]}.${m[2]}',
                    ),
                    style: const TextStyle(
                      color: kMarketColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

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
                            price: double.parse(_priceCtrl.text),
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
        final refPrice = widget.isBuy
            ? provider.orderBook?.bestAsk
            : provider.orderBook?.bestBid;
        final qty = double.tryParse(_qtyCtrl.text) ?? 0;
        final estimated = refPrice != null ? refPrice * qty : null;
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
                if (refPrice != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 16),
                    child: Text(
                      widget.isBuy
                          ? 'Best ask: \$${refPrice.toStringAsFixed(4)}'
                          : 'Best bid: \$${refPrice.toStringAsFixed(4)}',
                      style:
                          TextStyle(color: color, fontWeight: FontWeight.w500),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      widget.isBuy
                          ? 'No sell orders available. Place a limit buy order instead.'
                          : 'No buy orders available. Place a limit sell order instead.',
                      style: const TextStyle(
                          color: Colors.orange, fontSize: 13),
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
                    onPressed: (isLoading || refPrice == null)
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
