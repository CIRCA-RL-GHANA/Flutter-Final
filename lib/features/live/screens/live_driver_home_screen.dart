/// ═══════════════════════════════════════════════════════════════════════════
/// LIVE MODULE — Screen 11: Driver Home (Shop/Logistics)
/// Driver's main dashboard: active package, earnings, queue,
/// availability toggle, stats, and quick actions
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

class LiveDriverHomeScreen extends StatelessWidget {
  const LiveDriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveProvider>(
      builder: (context, prov, _) {
        final driver = prov.drivers.first; // Current driver
        final activePackage = prov.packages.where((p) => p.driverId == driver.id && p.status == PackageStatus.inTransit).firstOrNull;
        final pendingPackages = prov.packages.where((p) => p.status == PackageStatus.created).toList();

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 12, 16, 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [kLiveColor, kLiveAccent], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Text(driver.name.substring(0, 1), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Hey, ${driver.name.split(' ').first}! 👋', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                                Text(driver.driverType.name, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))),
                              ],
                            ),
                          ),
                          // Availability Toggle
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: driver.availability == DriverAvailability.online ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8, height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: driver.availability == DriverAvailability.online ? const Color(0xFF10B981) : AppColors.textTertiary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(driver.availability == DriverAvailability.online ? 'ONLINE' : 'OFFLINE',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.9)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Stats Row
                      Row(
                        children: [
                          _DriverStat(label: 'Rating', value: '${driver.rating}', icon: Icons.star),
                          _DriverStat(label: 'Today', value: '${driver.todayDeliveries}', icon: Icons.check_circle),
                          _DriverStat(label: 'Earnings', value: '₵${(driver.todayDeliveries * 18.5).toStringAsFixed(0)}', icon: Icons.account_balance_wallet),
                          _DriverStat(label: 'On-Time', value: '${driver.onTimeRate.toStringAsFixed(0)}%', icon: Icons.timer),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // AI Driver Insights
              SliverToBoxAdapter(
                child: Consumer<AIInsightsNotifier>(
                  builder: (context, ai, _) {
                    if (ai.insights.isEmpty) return const SizedBox.shrink();
                    return Container(
                      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kLiveColor.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kLiveColor.withOpacity(0.25)),
                      ),
                      child: Column(
                        children: ai.insights.take(2).map((i) => Row(
                          children: [
                            const Icon(Icons.auto_awesome, size: 13, color: kLiveColor),
                            const SizedBox(width: 8),
                            Expanded(child: Text(i.label, style: const TextStyle(fontSize: 12, color: kLiveColor), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ],
                        )).toList(),
                      ),
                    );
                  },
                ),
              ),

              // Active Package
              if (activePackage != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🚚 ACTIVE DELIVERY', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        LivePackageCard(
                          package: activePackage,
                          onTap: () {
                            prov.selectPackage(activePackage.id);
                            Navigator.pushNamed(context, AppRoutes.liveDeliveryVerification);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

              // Quick Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('⚡ QUICK ACTIONS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _QuickAction(icon: Icons.qr_code_scanner, label: 'Scan Package', color: const Color(0xFF8B5CF6), onTap: () {})),
                          const SizedBox(width: 8),
                          Expanded(child: _QuickAction(icon: Icons.camera_alt, label: 'Take Photo', color: const Color(0xFF3B82F6), onTap: () {})),
                          const SizedBox(width: 8),
                          Expanded(child: _QuickAction(icon: Icons.sos, label: 'Emergency', color: kLiveColor, onTap: () => Navigator.pushNamed(context, AppRoutes.liveEmergencySOS))),
                          const SizedBox(width: 8),
                          Expanded(child: _QuickAction(icon: Icons.report_problem, label: 'Report', color: const Color(0xFFF59E0B), onTap: () => Navigator.pushNamed(context, AppRoutes.liveIncidentReport))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Pending Packages Queue
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('📋 PACKAGE QUEUE (${pendingPackages.length})', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      TextButton(
                        onPressed: () {},
                        child: const Text('View All', style: TextStyle(fontSize: 12, color: kLiveColor)),
                      ),
                    ],
                  ),
                ),
              ),

              if (pendingPackages.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: LiveEmptyState(
                      icon: Icons.inbox,
                      title: 'No packages in queue',
                      subtitle: 'New package assignments will appear here.',
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, i == pendingPackages.length - 1 ? 24 : 0),
                      child: LivePackageCard(
                        package: pendingPackages[i],
                        onTap: () {
                          prov.selectPackage(pendingPackages[i].id);
                          Navigator.pushNamed(context, AppRoutes.livePackageAcceptance);
                        },
                      ),
                    ),
                    childCount: pendingPackages.length,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DriverStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _DriverStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Icon(icon, size: 16, color: Colors.white.withOpacity(0.8)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
            Text(label, style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))]),
        child: Column(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
