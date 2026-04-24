/// ═══════════════════════════════════════════════════════════════════════════
/// LIVE MODULE — Screen 2: Orders Tab (Detailed View)
/// Complete order management: sub-tabs (New/In Progress/Ready/All),
/// order cards, bulk operations, auto-assign
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../models/live_models.dart';
import '../providers/live_provider.dart';
import '../widgets/live_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class LiveOrdersScreen extends StatefulWidget {
  const LiveOrdersScreen({super.key});

  @override
  State<LiveOrdersScreen> createState() => _LiveOrdersScreenState();
}

class _LiveOrdersScreenState extends State<LiveOrdersScreen> with SingleTickerProviderStateMixin {
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
    return Consumer<LiveProvider>(
      builder: (context, prov, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, size: 22, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('ORDERS • LIVE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            actions: [
              IconButton(icon: const Icon(Icons.search, size: 20), color: AppColors.textSecondary, onPressed: () {}),
              IconButton(icon: const Icon(Icons.settings, size: 20), color: AppColors.textSecondary, onPressed: () => Navigator.pushNamed(context, AppRoutes.liveSettings)),
              IconButton(icon: const Icon(Icons.bar_chart, size: 20), color: AppColors.textSecondary, onPressed: () => Navigator.pushNamed(context, AppRoutes.liveAnalytics)),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: kLiveColor,
              indicatorWeight: 3,
              labelColor: kLiveColor,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              tabs: [
                Tab(text: 'NEW (${prov.newOrders.length})'),
                Tab(text: 'IN PROGRESS (${prov.inProgressOrders.length})'),
                Tab(text: 'READY (${prov.readyOrders.length})'),
                Tab(text: 'ALL (${prov.orders.length})'),
              ],
            ),
          ),
          body: Column(
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kLiveColor.withOpacity(0.06),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 13, color: kLiveColor),
                        const SizedBox(width: 8),
                        Expanded(child: Text('AI: ${ai.insights.first['title'] ?? ''}', style: const TextStyle(fontSize: 12, color: kLiveColor), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  );
                },
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOrderList(context, prov, prov.newOrders),
                    _buildOrderList(context, prov, prov.inProgressOrders),
                    _buildOrderList(context, prov, prov.readyOrders),
                    _buildOrderList(context, prov, prov.orders),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.select_all, size: 16),
                      label: const Text('BULK ASSIGN', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(foregroundColor: kLiveColor, padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.auto_fix_high, size: 16),
                      label: const Text('AUTO-ASSIGN ALL', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kLiveColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('EXPORT', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.textSecondary, padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderList(BuildContext context, LiveProvider prov, List<LiveOrder> orders) {
    if (orders.isEmpty) {
      return const LiveEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No Orders',
        subtitle: 'No orders in this category.',
        suggestions: ['Review pending returns', 'Optimize driver schedules', 'Check inventory levels'],
        tip: 'Use quiet periods to create bundled packages for anticipated orders.',
      );
    }
    return RefreshIndicator(
      color: kLiveColor,
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        await prov.loadOrders();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final o = orders[index];
          return LiveOrderCard(
            order: o,
            onTap: () {
              prov.selectOrder(o.id);
              Navigator.pushNamed(context, AppRoutes.liveOrderDetail);
            },
            onAssign: () {
              prov.selectOrder(o.id);
              Navigator.pushNamed(context, AppRoutes.liveDriverAssignment);
            },
          );
        },
      ),
    );
  }
}
