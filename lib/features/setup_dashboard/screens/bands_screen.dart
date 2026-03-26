/// ═══════════════════════════════════════════════════════════════════════════
/// SD1.8: VEHICLE BANDS — Fleet Grouping
/// Band list, utilization, vehicle assignment
/// RBAC: Admin(full), BM(branch), Monitor/BrMon(view)
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../prompt/providers/context_provider.dart';
import '../models/setup_dashboard_models.dart';
import '../providers/setup_dashboard_provider.dart';
import '../widgets/shared_widgets.dart';

class BandsScreen extends StatelessWidget {
  const BandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        final bands = setupProv.bands;

        return SetupRbacGate(
          cardId: 'bands',
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FC),
            appBar: SetupAppBar(
              title: 'Vehicle Bands',
              actions: [
                DataScopeIndicator(access: setupProv.getCardAccess('bands', ctxProv.currentRole)),
                SizedBox(width: 16),
              ],
            ),
            floatingActionButton: SetupRbacFAB(
              cardId: 'bands',
              onPressed: () {},
              label: 'New Band',
              icon: Icons.add,
            ),
          body: CustomScrollView(
            slivers: [
              // ─── KPI Row ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: KPIBadge(
                          label: 'Total Bands',
                          value: '${bands.length}',
                          icon: Icons.category,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: KPIBadge(
                          label: 'Total Vehicles',
                          value: '${bands.fold<int>(0, (sum, b) => sum + b.vehicleCount)}',
                          icon: Icons.directions_car,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: KPIBadge(
                          label: 'Avg. Utilization',
                          value: bands.isEmpty
                              ? '—'
                              : '${(bands.fold<double>(0, (sum, b) => sum + b.utilization) / bands.length).round()}%',
                          icon: Icons.speed,
                          color: (() {
                            if (bands.isEmpty) return AppColors.textTertiary;
                            final avg = bands.fold<double>(0, (sum, b) => sum + b.utilization) / bands.length;
                            return avg >= 70 ? AppColors.success : avg >= 40 ? AppColors.warning : AppColors.error;
                          })(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Fleet Health ─────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Container(
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
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.health_and_safety, size: 16, color: AppColors.success),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Fleet Health Overview',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _FleetStat(label: 'Capacity', value: '${bands.fold<int>(0, (s, b) => s + b.maxCapacity)}', icon: Icons.garage)),
                            const SizedBox(width: 10),
                            Expanded(child: _FleetStat(label: 'Maint. Cost', value: '₵${bands.fold<double>(0, (s, b) => s + b.maintenanceCostMonthly).toStringAsFixed(0)}/mo', icon: Icons.build)),
                            const SizedBox(width: 10),
                            Expanded(child: _FleetStat(label: 'Available', value: '${bands.fold<int>(0, (s, b) => s + b.maxCapacity - b.vehicleCount)}', icon: Icons.check_circle, color: AppColors.success)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: const SetupSectionTitle(title: 'All Bands', icon: Icons.category),
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
                    (context, i) => _BandCard(band: bands[i]),
                    childCount: bands.length,
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

class _BandCard extends StatelessWidget {
  final VehicleBand band;
  const _BandCard({required this.band});

  @override
  Widget build(BuildContext context) {
    final utilizationColor = band.utilization >= 80
        ? AppColors.success
        : band.utilization >= 40
            ? AppColors.warning
            : AppColors.error;

    return Container(
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
                child: const Icon(Icons.category, size: 22, color: kSetupColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      band.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      band.purpose,
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Utilization bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Utilization',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                '${band.utilization}%',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: utilizationColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (band.utilization / 100).clamp(0.0, 1.0),
              backgroundColor: AppColors.inputBorder,
              valueColor: AlwaysStoppedAnimation(utilizationColor),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${band.vehicleCount}/${band.maxCapacity} vehicles',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                '₵${band.maintenanceCostMonthly.toStringAsFixed(0)}/mo',
                style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Fleet Stat ──────────────────────────────────────────────────────────────

class _FleetStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _FleetStat({required this.label, required this.value, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? kSetupColor;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: c.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: c),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
