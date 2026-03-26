/// ═══════════════════════════════════════════════════════════════════════════
/// MARKET MODULE — Screen 7: My Transactions Dashboard
/// Active orders, order history, returns, rides, FAB for new order
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/routes/app_routes.dart';
import '../models/market_models.dart';
import '../providers/market_provider.dart';
import '../widgets/market_widgets.dart';

class MarketTransactionsScreen extends StatefulWidget {
  const MarketTransactionsScreen({super.key});

  @override
  State<MarketTransactionsScreen> createState() => _MarketTransactionsScreenState();
}

class _MarketTransactionsScreenState extends State<MarketTransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketProvider>(
      builder: (context, prov, _) {
        final txnSummary = prov.transactionSummary;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: MarketAppBar(
            title: 'My Transactions',
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: AppColors.textPrimary),
                onPressed: () {},
              ),
            ],
          ),
          body: Column(
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kMarketColor.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kMarketColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI: ${ai.insights.first['title'] ?? ''}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kMarketColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // KPI row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.white,
                child: Row(
                  children: [
                    _KPICard(
                      icon: Icons.receipt_long,
                      label: 'Active',
                      value: '${txnSummary.activeOrders}',
                      color: kMarketColor,
                    ),
                    const SizedBox(width: 12),
                    _KPICard(
                      icon: Icons.check_circle,
                      label: 'Completed',
                      value: '${txnSummary.orderCount}',
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 12),
                    _KPICard(
                      icon: Icons.attach_money,
                      label: 'Spent',
                      value: '\$${txnSummary.totalSpent.toStringAsFixed(0)}',
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 12),
                    _KPICard(
                      icon: Icons.star,
                      label: 'QP Earned',
                      value: '\$${txnSummary.savedViaDiscounts.toStringAsFixed(0)}',
                      color: const Color(0xFF8B5CF6),
                    ),
                  ],
                ),
              ),
              // Tab bar
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: kMarketColorDark,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  indicatorColor: kMarketColor,
                  indicatorWeight: 3,
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    Tab(text: 'Active (${prov.activeOrders.length})'),
                    const Tab(text: 'History'),
                    Tab(text: 'Returns (${prov.activeReturns.length})'),
                    Tab(text: 'Rides (${prov.rideHistory.length})'),
                  ],
                ),
              ),
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _ActiveTab(prov: prov),
                    _HistoryTab(prov: prov),
                    _ReturnsTab(prov: prov),
                    _RidesTab(prov: prov),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.marketHub),
            backgroundColor: kMarketColor,
            icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
            label: const Text('New Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        );
      },
    );
  }
}

// ── KPI Card ───────────────────────────────────────────────────────
class _KPICard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _KPICard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: color.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Active Orders Tab ──────────────────────────────────────────────
class _ActiveTab extends StatelessWidget {
  final MarketProvider prov;

  const _ActiveTab({required this.prov});

  @override
  Widget build(BuildContext context) {
    final orders = prov.activeOrders;

    if (orders.isEmpty) {
      return const MarketEmptyState(
        icon: Icons.receipt_long,
        title: 'No active orders',
        subtitle: 'Place an order to see it here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, i) {
        final order = orders[i];
        return _OrderCard(
          order: order,
          onTap: () {
            prov.selectOrder(order.id);
            if (order.status == OrderStatus.readyForPickup) {
              Navigator.pushNamed(context, AppRoutes.marketPickup);
            } else if (order.status == OrderStatus.onTheWay) {
              Navigator.pushNamed(context, AppRoutes.marketDeliveryTracker);
            }
          },
        );
      },
    );
  }
}

// ── History Tab ────────────────────────────────────────────────────
class _HistoryTab extends StatelessWidget {
  final MarketProvider prov;

  const _HistoryTab({required this.prov});

  @override
  Widget build(BuildContext context) {
    final orders = [...prov.completedOrders, ...prov.cancelledOrders];

    if (orders.isEmpty) {
      return const MarketEmptyState(
        icon: Icons.history,
        title: 'No order history',
        subtitle: 'Completed orders will appear here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, i) {
        final order = orders[i];
        return _OrderCard(
          order: order,
          onTap: () {
            prov.selectOrder(order.id);
          },
          showActions: true,
        );
      },
    );
  }
}

// ── Returns Tab ────────────────────────────────────────────────────
class _ReturnsTab extends StatelessWidget {
  final MarketProvider prov;

  const _ReturnsTab({required this.prov});

  @override
  Widget build(BuildContext context) {
    final returns = prov.activeReturns;

    if (returns.isEmpty) {
      return const MarketEmptyState(
        icon: Icons.assignment_return,
        title: 'No returns',
        subtitle: 'Return requests will appear here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: returns.length,
      itemBuilder: (context, i) {
        final ret = returns[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: ret.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ret.statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: ret.statusColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '#${ret.id.substring(0, 8).toUpperCase()}',
                      style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Return for Order #${ret.orderId.substring(0, 8).toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '${ret.items.length} item(s) • ${ret.reason.name}',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 13, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      'Requested ${_formatDate(ret.createdAt)}',
                      style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                    ),
                    const Spacer(),
                    Text(
                      '\$${ret.estimatedRefund.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kMarketColorDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ── Rides Tab ──────────────────────────────────────────────────────
class _RidesTab extends StatelessWidget {
  final MarketProvider prov;

  const _RidesTab({required this.prov});

  @override
  Widget build(BuildContext context) {
    final rides = prov.rideHistory;

    if (rides.isEmpty) {
      return MarketEmptyState(
        icon: Icons.directions_car,
        title: 'No rides yet',
        subtitle: 'Your ride history will appear here',
        actionLabel: 'Hail a Ride',
        onAction: () => Navigator.pushNamed(context, AppRoutes.marketRideHailing),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rides.length,
      itemBuilder: (context, i) {
        final ride = rides[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ride.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.directions_car, size: 20, color: ride.statusColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ride.typeLabel,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          Text(
                            ride.status.name,
                            style: TextStyle(fontSize: 12, color: ride.statusColor),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${ride.estimatedFare.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Pickup & dropoff
                Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: kMarketColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(width: 2, height: 20, color: AppColors.inputBorder),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ride.pickupAddress,
                            style: const TextStyle(fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            ride.destinationAddress,
                            style: const TextStyle(fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 13, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      '${ride.estimatedMinutes} min',
                      style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.straighten, size: 13, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      '${ride.estimatedDistance.toStringAsFixed(1)} km',
                      style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Order Card ─────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final MarketOrder order;
  final VoidCallback? onTap;
  final bool showActions;

  const _OrderCard({
    required this.order,
    this.onTap,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: kMarketColorLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.store, size: 20, color: kMarketColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.merchantName,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        Text(
                          '#${order.id.substring(0, 8).toUpperCase()}',
                          style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: order.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: order.statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Items preview
              Text(
                order.items.map((i) => '${i.quantity}x ${i.name}').join(', '),
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Footer
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 13, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                    style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                  ),
                  const Spacer(),
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kMarketColorDark,
                    ),
                  ),
                ],
              ),
              // Actions
              if (showActions && order.canReturn) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        final prov = Provider.of<MarketProvider>(context, listen: false);
                        prov.selectOrder(order.id);
                        Navigator.pushNamed(context, AppRoutes.marketReturn);
                      },
                      icon: const Icon(Icons.assignment_return, size: 16),
                      label: const Text('Request Return'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.warning,
                        side: const BorderSide(color: AppColors.warning),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Reorder'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kMarketColor,
                        side: const BorderSide(color: kMarketColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
