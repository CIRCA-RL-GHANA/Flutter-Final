/// ═══════════════════════════════════════════════════════════════════════════
/// LIVE MODULE — Operations Feed
/// Real-time operations log wired to LiveProvider: active orders,
/// driver status, package events, and return updates
/// ═══════════════════════════════════════════════════════════════════════════
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../providers/live_provider.dart';
import '../widgets/live_widgets.dart';

class LiveOperationsScreen extends StatefulWidget {
  const LiveOperationsScreen({super.key});

  @override
  State<LiveOperationsScreen> createState() => _LiveOperationsScreenState();
}

class _LiveOperationsScreenState extends State<LiveOperationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<LiveProvider>();
      if (!prov.isLoading) prov.init();
    });
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
            title: const Text('LIVE • Operations Feed', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 20),
                color: AppColors.textSecondary,
                onPressed: () => Navigator.pushNamed(context, AppRoutes.utilityNotifications),
              ),
            ],
          ),
          body: prov.isLoading
              ? const Center(child: CircularProgressIndicator(color: kLiveColor))
              : prov.error != null && prov.orders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: kLiveColor),
                          const SizedBox(height: 12),
                          Text(prov.error!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary), textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: prov.init,
                            style: ElevatedButton.styleFrom(backgroundColor: kLiveColor, foregroundColor: Colors.white),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: kLiveColor,
                      onRefresh: prov.init,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // AI insights strip

                          // Operations overview metrics
                          LiveSectionCard(
                            title: 'OPERATIONS OVERVIEW',
                            icon: Icons.analytics_outlined,
                            iconColor: kLiveColor,
                            onMore: () => Navigator.pushNamed(context, AppRoutes.liveAnalytics),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                LiveMetricBadge(
                                  label: 'Active Orders',
                                  value: '${prov.activeOrderCount}',
                                  icon: Icons.receipt_long,
                                  color: kLiveColor,
                                ),
                                LiveMetricBadge(
                                  label: 'Pending Returns',
                                  value: '${prov.activeReturnCount}',
                                  icon: Icons.assignment_return,
                                  color: const Color(0xFFF59E0B),
                                ),
                                LiveMetricBadge(
                                  label: 'Active Packages',
                                  value: '${prov.activePackageCount}',
                                  icon: Icons.inventory_2,
                                  color: const Color(0xFF3B82F6),
                                ),
                                LiveMetricBadge(
                                  label: 'Available Drivers',
                                  value: '${prov.availableDrivers.length}',
                                  icon: Icons.local_shipping,
                                  color: const Color(0xFF10B981),
                                ),
                              ],
                            ),
                          ),

                          // Urgent actions
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
                                      const Icon(Icons.error, size: 16, color: kLiveColor),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(a.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                                    ],
                                  ),
                                )).toList(),
                              ),
                            ),

                          // Active orders
                          if (prov.inProgressOrders.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text('IN-PROGRESS ORDERS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
                            ),
                            ...prov.inProgressOrders.take(5).map((o) => LiveOrderCard(
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
                          ],

                          // Pending returns
                          if (prov.pendingReturns.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text('PENDING RETURNS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
                            ),
                            ...prov.pendingReturns.take(3).map((r) => LiveReturnCard(
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
                          ],

                          // Active packages
                          if (prov.inTransitPackages.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text('IN-TRANSIT PACKAGES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
                            ),
                            ...prov.inTransitPackages.take(3).map((p) => LivePackageCard(
                              package: p,
                              onTap: () {
                                prov.selectPackage(p.id);
                                Navigator.pushNamed(context, AppRoutes.livePackageDetail);
                              },
                            )),
                          ],

                          if (prov.orders.isEmpty && prov.returns.isEmpty && prov.packages.isEmpty)
                            const LiveEmptyState(
                              icon: Icons.history,
                              title: 'No Active Operations',
                              subtitle: 'Live order, return, and package events will appear here.',
                            ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
        );
      },
    );
  }
}
