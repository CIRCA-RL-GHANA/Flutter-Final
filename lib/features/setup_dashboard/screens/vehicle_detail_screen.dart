/// ═══════════════════════════════════════════════════════════════════════════
/// SD1.2-DETAIL: VEHICLE DETAIL — 5-Tab Deep View
/// Tabs: Overview, Maintenance, Fuel, Routes, Driver
/// RBAC: Owner/Admin(fullAccess), BM(branchScoped), Monitor(viewOnly),
///        Driver(ownOnly)
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../prompt/providers/context_provider.dart';
import '../models/setup_dashboard_models.dart';
import '../providers/setup_dashboard_provider.dart';
import '../widgets/shared_widgets.dart';

class VehicleDetailScreen extends StatefulWidget {
  const VehicleDetailScreen({super.key});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  int _tabIndex = 0;
  static const _tabs = ['Overview', 'Maintenance', 'Fuel', 'Routes', 'Driver'];

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        final vehicle = setupProv.selectedVehicle;
        if (vehicle == null) {
          return Scaffold(
            appBar: const SetupAppBar(title: 'Vehicle Detail'),
            body: const SetupEmptyState(
              icon: Icons.local_shipping,
              title: 'No vehicle selected',
              subtitle: 'Select a vehicle from the fleet',
            ),
          );
        }

        final maintenance = setupProv.getMaintenanceForVehicle(vehicle.id);
        final fuel = setupProv.getFuelForVehicle(vehicle.id);

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FC),
          appBar: SetupAppBar(title: '${vehicle.make} ${vehicle.model}'),
          body: Column(
            children: [
              // ─── Vehicle Header ────────────────────────────
              _VehicleHeader(vehicle: vehicle),
              const SizedBox(height: 12),
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kSetupColor.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kSetupColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "AI: ${ai.insights.first['title'] ?? ''}",
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kSetupColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SetupDetailTabBar(
                tabs: _tabs,
                selectedIndex: _tabIndex,
                onTabChanged: (i) => setState(() => _tabIndex = i),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: IndexedStack(
                  index: _tabIndex,
                  children: [
                    _OverviewTab(vehicle: vehicle),
                    _MaintenanceTab(records: maintenance),
                    _FuelTab(entries: fuel),
                    _RoutesTab(vehicle: vehicle),
                    _DriverTab(vehicle: vehicle),
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

// ─── Vehicle Header ──────────────────────────────────────────────────────────

class _VehicleHeader extends StatelessWidget {
  final Vehicle vehicle;
  const _VehicleHeader({required this.vehicle});

  Color get _statusColor => switch (vehicle.status) {
    VehicleStatus.active => AppColors.success,
    VehicleStatus.maintenance => AppColors.warning,
    VehicleStatus.offline => AppColors.error,
    VehicleStatus.idle => AppColors.textTertiary,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.local_shipping, size: 28, color: _statusColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vehicle.make} ${vehicle.model} (${vehicle.year})',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  vehicle.plateNumber,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    vehicle.status.name.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _statusColor),
                  ),
                ),
              ],
            ),
          ),
          // Fuel gauge
          SizedBox(
            width: 48,
            height: 48,
            child: SetupPercentageRing(
              percentage: vehicle.fuelLevel.toDouble(),
              size: 48,
              color: vehicle.fuelLevel > 50 ? AppColors.success :
                     vehicle.fuelLevel > 20 ? AppColors.warning : AppColors.error,
              label: '${vehicle.fuelLevel}%',
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Overview Tab ────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final Vehicle vehicle;
  const _OverviewTab({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        Row(
          children: [
            Expanded(child: SetupStatCard(label: 'Distance', value: '${vehicle.distanceToday} km', icon: Icons.route)),
            const SizedBox(width: 10),
            Expanded(child: SetupStatCard(label: 'Deliveries', value: '${vehicle.deliveriesToday}/${vehicle.deliveriesTarget}', icon: Icons.local_shipping, color: AppColors.success)),
            const SizedBox(width: 10),
            Expanded(child: SetupStatCard(label: 'On-Time', value: '${vehicle.onTimeRate}%', icon: Icons.timer, color: const Color(0xFF8B5CF6))),
          ],
        ),
        const SizedBox(height: 16),
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Vehicle Info', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              SetupInfoRow(label: 'Vehicle ID', value: vehicle.id),
              SetupInfoRow(label: 'Plate Number', value: vehicle.plateNumber),
              SetupInfoRow(label: 'Make / Model', value: '${vehicle.make} ${vehicle.model}'),
              SetupInfoRow(label: 'Year', value: '${vehicle.year}'),
              SetupInfoRow(label: 'Zone', value: vehicle.zone ?? 'N/A'),
              SetupInfoRow(label: 'Capacity', value: '${vehicle.capacityKg} kg'),
              SetupInfoRow(label: 'Fuel Level', value: '${vehicle.fuelLevel}%'),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Maintenance Tab ─────────────────────────────────────────────────────────

class _MaintenanceTab extends StatelessWidget {
  final List<MaintenanceRecord> records;
  const _MaintenanceTab({required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const SetupEmptyState(
        icon: Icons.build_outlined,
        title: 'No maintenance records',
        subtitle: 'This vehicle has no maintenance history',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: records.length,
      itemBuilder: (context, i) => _MaintenanceCard(record: records[i]),
    );
  }
}

class _MaintenanceCard extends StatelessWidget {
  final MaintenanceRecord record;
  const _MaintenanceCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: record.isUrgent
            ? Border.all(color: AppColors.error.withOpacity(0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        record.serviceType,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (record.isUrgent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'URGENT',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.error),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '₵${record.cost.toStringAsFixed(0)} · ${setupTimeAgo(record.date)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Fuel Tab ────────────────────────────────────────────────────────────────

class _FuelTab extends StatelessWidget {
  final List<FuelEntry> entries;
  const _FuelTab({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SetupEmptyState(
        icon: Icons.local_gas_station,
        title: 'No fuel entries',
        subtitle: 'No fuel records for this vehicle',
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        // Fuel summary
        Row(
          children: [
            Expanded(child: SetupStatCard(
              label: 'Total Liters',
              value: '${entries.fold(0.0, (sum, e) => sum + e.liters).toStringAsFixed(0)} L',
              icon: Icons.local_gas_station,
            )),
            const SizedBox(width: 10),
            Expanded(child: SetupStatCard(
              label: 'Total Cost',
              value: '₵${entries.fold(0.0, (sum, e) => sum + e.cost).toStringAsFixed(0)}',
              icon: Icons.attach_money,
              color: AppColors.warning,
            )),
          ],
        ),
        const SizedBox(height: 16),
        // Fuel entries
        ...entries.map((e) => _FuelEntryCard(entry: e)),
      ],
    );
  }
}

class _FuelEntryCard extends StatelessWidget {
  final FuelEntry entry;
  const _FuelEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.local_gas_station, size: 18, color: AppColors.warning),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.liters.toStringAsFixed(1)} liters',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Odometer: ${entry.odometer} km · ${setupTimeAgo(entry.date)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          Text(
            '₵${entry.cost.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.warning),
          ),
        ],
      ),
    );
  }
}

// ─── Routes Tab ──────────────────────────────────────────────────────────────

class _RoutesTab extends StatelessWidget {
  final Vehicle vehicle;
  const _RoutesTab({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.route, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Today\'s Route', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              SetupInfoRow(label: 'Zone', value: vehicle.zone ?? 'N/A'),
              SetupInfoRow(label: 'Distance', value: '${vehicle.distanceToday} km'),
              SetupInfoRow(label: 'Deliveries', value: '${vehicle.deliveriesToday} / ${vehicle.deliveriesTarget}'),
              SetupInfoRow(label: 'On-Time Rate', value: '${vehicle.onTimeRate}%'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Route map placeholder
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, size: 40, color: AppColors.textTertiary),
                SizedBox(height: 8),
                Text(
                  'Route Map',
                  style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
                ),
                Text(
                  'Map integration coming soon',
                  style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Driver Tab ──────────────────────────────────────────────────────────────

class _DriverTab extends StatelessWidget {
  final Vehicle vehicle;
  const _DriverTab({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    if (vehicle.assignedDriverName == null) {
      return const SetupEmptyState(
        icon: Icons.person_off,
        title: 'No driver assigned',
        subtitle: 'Assign a driver to this vehicle',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Assigned Driver', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: kSetupColor.withOpacity(0.1),
                    child: Text(
                      vehicle.assignedDriverName![0],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kSetupColor),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.assignedDriverName!,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Driver ID: ${vehicle.assignedDriverId ?? "N/A"}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 20),
              SetupInfoRow(label: 'Zone', value: vehicle.zone ?? 'N/A'),
              const SetupInfoRow(label: 'Status', value: 'Active', valueColor: AppColors.success),
            ],
          ),
        ),
      ],
    );
  }
}
