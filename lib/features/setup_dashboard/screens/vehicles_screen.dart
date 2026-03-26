/// ═══════════════════════════════════════════════════════════════════════════
/// SD1.2: VEHICLES — Fleet Management
/// Vehicle list, live status, fuel/maintenance tracking, driver assignment
/// RBAC: Admin(full), BM(branch), RO(full), BRO(branch), Driver(own),
///        Monitor/BrMon(view)
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../prompt/providers/context_provider.dart';
import '../models/setup_dashboard_models.dart';
import '../providers/setup_dashboard_provider.dart';
import '../widgets/shared_widgets.dart';

class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        final vehicles = setupProv.vehicles;

        return SetupRbacGate(
          cardId: 'vehicles',
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FC),
            appBar: SetupAppBar(
              title: 'Vehicles',
              actions: [
                DataScopeIndicator(access: setupProv.getCardAccess('vehicles', ctxProv.currentRole)),
                SizedBox(width: 16),
              ],
            ),
            floatingActionButton: SetupRbacFAB(
              cardId: 'vehicles',
              onPressed: () {
                context.read<SetupDashboardProvider>().selectVehicle(null);
                Navigator.pushNamed(context, AppRoutes.setupVehicleDetail);
              },
              label: 'Add Vehicle',
              icon: Icons.add,
            ),
            body: CustomScrollView(
            slivers: [
              // ─── Fleet Overview ────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: KPIBadge(
                          label: 'Total Fleet',
                          value: '${vehicles.length}',
                          icon: Icons.local_shipping,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: KPIBadge(
                          label: 'Active',
                          value: '${setupProv.activeVehicleCount}',
                          icon: Icons.check_circle,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: KPIBadge(
                          label: 'Maintenance',
                          value: '${setupProv.maintenanceVehicleCount}',
                          icon: Icons.build,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Vehicle List ─────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: const SetupSectionTitle(
                    title: 'Fleet Overview',
                    icon: Icons.directions_car,
                  ),
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
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _VehicleCard(vehicle: vehicles[i]),
                    childCount: vehicles.length,
                  ),
                ),
              ),

              // ─── Maintenance Schedule ─────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SetupSectionTitle(
                        title: 'Recent Maintenance',
                        icon: Icons.build_circle,
                      ),
                      SetupSectionCard(
                        child: Column(
                          children: setupProv.maintenanceRecords.map((record) {
                            return _MaintenanceItem(record: record);
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Fuel Log ─────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SetupSectionTitle(
                        title: 'Recent Fuel Entries',
                        icon: Icons.local_gas_station,
                      ),
                      SetupSectionCard(
                        child: Column(
                          children: setupProv.fuelEntries.map((entry) {
                            return _FuelItem(entry: entry);
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
        );
      },
    );
  }
}

// ─── Vehicle Card ────────────────────────────────────────────────────────────

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  const _VehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<SetupDashboardProvider>().selectVehicle(vehicle.id);
        Navigator.pushNamed(context, AppRoutes.setupVehicleDetail);
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
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _statusColor(vehicle.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.local_shipping, size: 22,
                    color: _statusColor(vehicle.status)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${vehicle.make} ${vehicle.model}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${vehicle.plateNumber} · ${vehicle.zone ?? "Unassigned"}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              SetupStatusIndicator(
                label: vehicle.status.name,
                color: _statusColor(vehicle.status),
              ),
            ],
          ),

          if (vehicle.status == VehicleStatus.active) ...[
            const Divider(height: 20),
            // Live stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _VehicleStat(
                  label: 'Fuel',
                  value: '${vehicle.fuelLevel}%',
                  icon: Icons.local_gas_station,
                  color: vehicle.fuelLevel < 20 ? AppColors.error : AppColors.success,
                ),
                _VehicleStat(
                  label: 'Distance',
                  value: '${vehicle.distanceToday} km',
                  icon: Icons.straighten,
                ),
                if (vehicle.deliveriesToday > 0)
                  _VehicleStat(
                    label: 'Deliveries',
                    value: '${vehicle.deliveriesToday}/${vehicle.deliveriesTarget}',
                    icon: Icons.local_shipping,
                  ),
                if (vehicle.onTimeRate > 0)
                  _VehicleStat(
                    label: 'On-Time',
                    value: '${vehicle.onTimeRate}%',
                    icon: Icons.schedule,
                    color: vehicle.onTimeRate >= 90 ? AppColors.success : AppColors.warning,
                  ),
              ],
            ),
          ],

          if (vehicle.assignedDriverName != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(
                  vehicle.assignedDriverName!,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ],
      ),
      ),
    );
  }

  Color _statusColor(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.active:
        return AppColors.success;
      case VehicleStatus.maintenance:
        return AppColors.warning;
      case VehicleStatus.offline:
        return AppColors.error;
      case VehicleStatus.idle:
        return AppColors.textTertiary;
    }
  }
}

// ─── Vehicle Stat ────────────────────────────────────────────────────────────

class _VehicleStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _VehicleStat({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? kSetupColor;
    return Column(
      children: [
        Icon(icon, size: 16, color: c),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: c,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
        ),
      ],
    );
  }
}

// ─── Maintenance Item ────────────────────────────────────────────────────────

class _MaintenanceItem extends StatelessWidget {
  final MaintenanceRecord record;
  const _MaintenanceItem({required this.record});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (record.isUrgent ? AppColors.error : kSetupColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.build,
              size: 18,
              color: record.isUrgent ? AppColors.error : kSetupColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.serviceType,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Vehicle ${record.vehicleId} · ₵${record.cost.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          Text(
            setupTimeAgo(record.date),
            style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

// ─── Fuel Item ───────────────────────────────────────────────────────────────

class _FuelItem extends StatelessWidget {
  final FuelEntry entry;
  const _FuelItem({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kSetupColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.local_gas_station, size: 18, color: kSetupColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.liters}L · ₵${entry.cost.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Vehicle ${entry.vehicleId} · ${entry.odometer} km',
                  style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          Text(
            setupTimeAgo(entry.date),
            style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
