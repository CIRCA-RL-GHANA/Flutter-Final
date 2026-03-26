/// ═══════════════════════════════════════════════════════════════════════════
/// LIVE MODULE — Screen 1: Live Dashboard (Main Operations View)
/// Central command center: Tab bar (Orders/Returns/Packages),
/// operations overview, urgent actions, predictive insights, controls
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

class LiveDashboardScreen extends StatefulWidget {
  const LiveDashboardScreen({super.key});

  @override
  State<LiveDashboardScreen> createState() => _LiveDashboardScreenState();
}

class _LiveDashboardScreenState extends State<LiveDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final prov = context.read<LiveProvider>();
        prov.setDashboardTab(LiveDashboardTab.values[_tabController.index]);
      }
    });
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
            leading: Row(
              children: [
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 22),
                  color: AppColors.textPrimary,
                  onPressed: () => Navigator.pop(context),
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kLiveColor,
                    boxShadow: [BoxShadow(color: kLiveColor.withOpacity(0.4), blurRadius: 6, spreadRadius: 1)],
                  ),
                ),
              ],
            ),
            leadingWidth: 70,
            title: const Text('LIVE • Operations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            actions: [
              IconButton(icon: const Icon(Icons.business, size: 20), color: AppColors.textSecondary, onPressed: () {}),
              IconButton(
                icon: Badge(
                  label: Text('${prov.unreadNotificationCount}'),
                  isLabelVisible: prov.unreadNotificationCount > 0,
                  child: const Icon(Icons.notifications_outlined, size: 20),
                ),
                color: AppColors.textSecondary,
                onPressed: () {},
              ),
              IconButton(icon: const Icon(Icons.my_location, size: 20), color: AppColors.textSecondary, onPressed: () {}),
              IconButton(
                icon: const Icon(Icons.sos, size: 20),
                color: kLiveColor,
                onPressed: () => Navigator.pushNamed(context, AppRoutes.liveEmergencySOS),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: kLiveColor,
              indicatorWeight: 3,
              labelColor: kLiveColor,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              tabs: [
                Tab(text: 'ORDERS (${prov.activeOrderCount})'),
                Tab(text: 'RETURNS (${prov.activeReturnCount})'),
                Tab(text: 'PACKAGES (${prov.activePackageCount})'),
              ],
            ),
          ),
          body: Column(
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kLiveColor.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kLiveColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI: ${ai.insights.first['title'] ?? ''}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kLiveColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _OrdersView(prov: prov),
                    _ReturnsView(prov: prov),
                    _PackagesView(prov: prov),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Orders View ─────────────────────────────────────────────────────────────

class _OrdersView extends StatelessWidget {
  final LiveProvider prov;
  const _OrdersView({required this.prov});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: kLiveColor,
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Operations Overview
          LiveSectionCard(
            title: 'OPERATIONS OVERVIEW',
            icon: Icons.analytics_outlined,
            iconColor: const Color(0xFF3B82F6),
            onMore: () => Navigator.pushNamed(context, AppRoutes.liveAnalytics),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                LiveMetricBadge(
                  label: 'Active Drivers',
                  value: '${prov.metrics.activeDrivers}/${prov.metrics.totalDrivers}',
                  icon: Icons.local_shipping,
                  color: const Color(0xFF3B82F6),
                ),
                LiveMetricBadge(
                  label: 'Avg Response',
                  value: '${prov.metrics.avgResponseTimeMinutes}min',
                  icon: Icons.timer,
                  color: const Color(0xFF10B981),
                ),
                LiveMetricBadge(
                  label: 'Efficiency',
                  value: '${(prov.metrics.efficiencyScore * 100).toInt()}%',
                  icon: Icons.speed,
                  color: const Color(0xFFF59E0B),
                ),
                LiveMetricBadge(
                  label: "Today's Revenue",
                  value: '₵${prov.metrics.todayRevenue.toStringAsFixed(0)}',
                  icon: Icons.attach_money,
                  color: const Color(0xFF8B5CF6),
                ),
              ],
            ),
          ),
          // Urgent Actions
          if (prov.urgentActionItems.isNotEmpty)
            LiveSectionCard(
              title: 'URGENT ACTIONS (${prov.urgentActionItems.length})',
              icon: Icons.warning_amber,
              iconColor: kLiveColor,
              child: Column(
                children: prov.urgentActionItems.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.error, size: 16, color: Color(0xFFEF4444)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(a.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                      ...a.actions.take(2).map((act) => Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: InkWell(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: kLiveColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(act, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: kLiveColor)),
                          ),
                        ),
                      )),
                    ],
                  ),
                )).toList(),
              ),
            ),
          // Predictive Insights
          LiveSectionCard(
            title: 'PREDICTIVE INSIGHTS',
            icon: Icons.auto_awesome,
            iconColor: const Color(0xFF8B5CF6),
            child: Column(
              children: prov.insights.map((i) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(i.icon, size: 16, color: i.color),
                    const SizedBox(width: 8),
                    Expanded(child: Text(i.title, style: const TextStyle(fontSize: 13))),
                  ],
                ),
              )).toList(),
            ),
          ),
          // Order list
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Orders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.liveOrders), child: Text('View All', style: TextStyle(color: kLiveColor, fontSize: 13))),
            ],
          ),
          const SizedBox(height: 8),
          ...prov.orders.take(3).map((o) => LiveOrderCard(
            order: o,
            onTap: () {
              prov.selectOrder(o.id);
              Navigator.pushNamed(context, AppRoutes.liveOrderDetail);
            },
            onAssign: () {
              prov.selectOrder(o.id);
              Navigator.pushNamed(context, AppRoutes.liveDriverAssignment);
            },
          )),
          // Bottom actions
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.select_all, size: 16),
                  label: const Text('BULK ASSIGN'),
                  style: OutlinedButton.styleFrom(foregroundColor: kLiveColor, padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.auto_fix_high, size: 16),
                  label: const Text('AUTO-ASSIGN'),
                  style: OutlinedButton.styleFrom(foregroundColor: kLiveColor, padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Returns View ────────────────────────────────────────────────────────────

class _ReturnsView extends StatelessWidget {
  final LiveProvider prov;
  const _ReturnsView({required this.prov});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (prov.returns.isEmpty)
          const LiveEmptyState(
            icon: Icons.assignment_return,
            title: 'No Active Returns',
            subtitle: 'Return requests will appear here.',
          )
        else ...[
          ...prov.returns.map((r) => LiveReturnCard(
            ret: r,
            onTap: () {
              prov.selectReturn(r.id);
              Navigator.pushNamed(context, AppRoutes.liveReturnReview);
            },
            onReview: () {
              prov.selectReturn(r.id);
              Navigator.pushNamed(context, AppRoutes.liveReturnReview);
            },
          )),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.checklist, size: 16),
                  label: const Text('BULK REVIEW'),
                  style: OutlinedButton.styleFrom(foregroundColor: kLiveColor, padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: const Text('AUTO-APPROVE <₵50'),
                  style: OutlinedButton.styleFrom(foregroundColor: kLiveColor, padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ─── Packages View ───────────────────────────────────────────────────────────

class _PackagesView extends StatelessWidget {
  final LiveProvider prov;
  const _PackagesView({required this.prov});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (prov.packages.isEmpty)
          const LiveEmptyState(
            icon: Icons.inventory_2,
            title: 'No Active Packages',
            subtitle: 'Create a package to bundle orders and returns.',
            actionLabel: 'CREATE PACKAGE',
          )
        else ...[
          ...prov.packages.map((p) => LivePackageCard(
            package: p,
            onTap: () {
              prov.selectPackage(p.id);
              Navigator.pushNamed(context, AppRoutes.livePackageDetail);
            },
            onTrack: () {
              prov.selectPackage(p.id);
              Navigator.pushNamed(context, AppRoutes.livePackageDetail);
            },
          )),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.livePackageCreation),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('CREATE NEW PACKAGE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kLiveColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
