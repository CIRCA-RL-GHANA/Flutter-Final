/// ═══════════════════════════════════════════════════════════════════════════
/// SD1.7: DELIVERY ZONES — Zone Management
/// Zone list, coverage, fee structure, vehicle assignment
/// RBAC: Admin(full), BM(branch), Monitor/BrMon(view), RO/BRO(view),
///        Driver(view)
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../prompt/providers/context_provider.dart';
import '../models/setup_dashboard_models.dart';
import '../providers/setup_dashboard_provider.dart';
import '../widgets/shared_widgets.dart';

class ZonesScreen extends StatelessWidget {
  const ZonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        final zones = setupProv.zones;

        return SetupRbacGate(
          cardId: 'zones',
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FC),
            appBar: SetupAppBar(
              title: 'Delivery Zones',
              actions: [
                DataScopeIndicator(access: setupProv.getCardAccess('zones', ctxProv.currentRole)),
                SizedBox(width: 16),
              ],
            ),
            floatingActionButton: SetupRbacFAB(
              cardId: 'zones',
              onPressed: () {
                context.read<SetupDashboardProvider>().selectZone(null);
                Navigator.pushNamed(context, AppRoutes.setupZoneDetail);
              },
              label: 'Add Zone',
              icon: Icons.add,
            ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: KPIBadge(
                          label: 'Active Zones',
                          value: '${zones.where((z) => z.status == ZoneStatus.active).length}',
                          icon: Icons.map,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: KPIBadge(
                          label: 'Total Deliveries',
                          value: '${zones.fold<int>(0, (s, z) => s + z.dailyDeliveries)}/day',
                          icon: Icons.local_shipping,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: const SetupSectionTitle(title: 'All Zones', icon: Icons.map),
                ),
              ),
              // ─── AI Insights ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Consumer<AIInsightsNotifier>(
                  builder: (context, ai, _) {
                    if (ai.insights.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: kSetupColor.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome, size: 14, color: kSetupColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'AI: ${ai.insights.first['title'] ?? ''}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kSetupColor),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _ZoneCard(zone: zones[i]),
                    childCount: zones.length,
                  ),
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

class _ZoneCard extends StatelessWidget {
  final DeliveryZone zone;
  const _ZoneCard({required this.zone});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<SetupDashboardProvider>().selectZone(zone.id);
        Navigator.pushNamed(context, AppRoutes.setupZoneDetail);
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kSetupColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.map, size: 22, color: kSetupColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zone.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '₵${zone.fee.toStringAsFixed(0)} fee · ${zone.estimatedTime}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              SetupStatusIndicator(
                label: zone.status.name,
                color: zone.status == ZoneStatus.active
                    ? AppColors.success
                    : zone.status == ZoneStatus.partial
                        ? AppColors.warning
                        : AppColors.error,
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ZoneStat(label: 'Vehicles', value: '${zone.vehicleCount}'),
              _ZoneStat(label: 'Deliveries', value: '${zone.dailyDeliveries}/day'),
              _ZoneStat(label: 'Coverage', value: '${zone.coverageKm2} km²'),
              _ZoneStat(label: 'Population', value: _formatPop(zone.populationServed)),
            ],
          ),
        ],
      ),
      ),
    );
  }

  String _formatPop(int pop) {
    if (pop >= 1000) return '${(pop / 1000).toStringAsFixed(0)}K';
    return '$pop';
  }
}

class _ZoneStat extends StatelessWidget {
  final String label;
  final String value;
  const _ZoneStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
      ],
    );
  }
}
