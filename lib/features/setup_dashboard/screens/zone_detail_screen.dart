/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
/// SD2.3-DETAIL: ZONE DETAIL — 4-Tab Deep View
/// Tabs: Overview, Coverage, Vehicles, Analytics
/// RBAC: Admin(fullAccess), BranchManager(branchScoped), Monitor(viewOnly)
/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/design/ive_tokens.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../prompt/providers/context_provider.dart';
import '../models/setup_dashboard_models.dart';
import '../providers/setup_dashboard_provider.dart';
import '../widgets/shared_widgets.dart';

class ZoneDetailScreen extends StatefulWidget {
  const ZoneDetailScreen({super.key});

  @override
  State<ZoneDetailScreen> createState() => _ZoneDetailScreenState();
}

class _ZoneDetailScreenState extends State<ZoneDetailScreen> {
  int _tabIndex = 0;
  static const _tabs = ['Overview', 'Coverage', 'Vehicles', 'Analytics'];

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        final zone = setupProv.selectedZone;
        if (zone == null) {
          return Scaffold(
            appBar: const SetupAppBar(title: 'Zone Detail'),
            body: const SetupEmptyState(
              icon: Icons.map,
              title: 'No zone selected',
              subtitle: 'Select a zone from the list',
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFF08080F),
          appBar: SetupAppBar(title: zone.name),
          body: Column(
            children: [
              _ZoneHeader(zone: zone),
              const SizedBox(height: 12),
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kSetupColor.withValues(alpha: 0.07),
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
                    _OverviewTab(zone: zone),
                    _CoverageTab(zone: zone),
                    _VehiclesTab(zone: zone),
                    _AnalyticsTab(zone: zone),
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

class _ZoneHeader extends StatelessWidget {
  final DeliveryZone zone;
  const _ZoneHeader({required this.zone});

  Color get _statusColor => switch (zone.status) {
    ZoneStatus.active => AppColors.success,
    ZoneStatus.inactive => AppColors.error,
    ZoneStatus.partial => AppColors.warning,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.map, size: 28, color: _statusColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(zone.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                Text('${zone.estimatedTime} delivery', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: _statusColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      zone.status.name.toUpperCase(),
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor),
                    ),
                    const SizedBox(width: 12),
                    Text('â‚µ${zone.fee.toStringAsFixed(2)} fee', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                  ],
                ),
              ],
            ),
          ),
          Text('${zone.vehicleCount} veh.', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final DeliveryZone zone;
  const _OverviewTab({required this.zone});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        Row(
          children: [
            Expanded(child: SetupStatCard(label: 'Vehicles', value: '${zone.vehicleCount}', icon: Icons.local_shipping)),
            const SizedBox(width: 10),
            Expanded(child: SetupStatCard(label: 'Deliveries', value: '${zone.dailyDeliveries}', icon: Icons.delivery_dining, color: AppColors.success)),
            const SizedBox(width: 10),
            Expanded(child: SetupStatCard(label: 'Coverage', value: '${zone.coverageKm2.toStringAsFixed(0)} kmÂ²', icon: Icons.straighten, color: kSetupColor)),
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
                  const Text('Zone Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              SetupInfoRow(label: 'Zone ID', value: zone.id),
              SetupInfoRow(label: 'Name', value: zone.name),
              SetupInfoRow(
                label: 'Status',
                value: zone.status.name,
                valueColor: switch (zone.status) {
                  ZoneStatus.active => AppColors.success,
                  ZoneStatus.inactive => AppColors.error,
                  ZoneStatus.partial => AppColors.warning,
                },
              ),
              SetupInfoRow(label: 'Delivery Fee', value: 'â‚µ${zone.fee.toStringAsFixed(2)}'),
              SetupInfoRow(label: 'Minimum Order', value: 'â‚µ${zone.minimumOrder.toStringAsFixed(2)}'),
              SetupInfoRow(label: 'Est. Time', value: zone.estimatedTime),
              SetupInfoRow(label: 'Population Served', value: '${zone.populationServed}'),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoverageTab extends StatelessWidget {
  final DeliveryZone zone;
  const _CoverageTab({required this.zone});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        _ZoneCoverageCard(zone: zone),
        const SizedBox(height: 16),
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.layers, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Coverage Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              SetupInfoRow(label: 'Coverage Area', value: '${zone.coverageKm2.toStringAsFixed(1)} kmÂ²'),
              SetupInfoRow(label: 'Population', value: '${zone.populationServed}'),
              SetupInfoRow(label: 'Daily Deliveries', value: '${zone.dailyDeliveries}'),
              SetupInfoRow(label: 'Active Vehicles', value: '${zone.vehicleCount}'),
            ],
          ),
        ),
      ],
    );
  }
}

class _VehiclesTab extends StatelessWidget {
  final DeliveryZone zone;
  const _VehiclesTab({required this.zone});

  @override
  Widget build(BuildContext context) {
    if (zone.vehicleCount == 0) {
      return const SetupEmptyState(
        icon: Icons.local_shipping_outlined,
        title: 'No vehicles assigned',
        subtitle: 'Assign vehicles to this zone',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: zone.vehicleCount.clamp(0, 5),
      itemBuilder: (context, i) {
        final statuses = ['Active', 'En Route', 'Idle', 'Maintenance', 'Active'];
        final colors = [AppColors.success, kSetupColor, AppColors.warning, AppColors.error, AppColors.success];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors[i % colors.length].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.local_shipping, size: 20, color: colors[i % colors.length]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Vehicle ${i + 1}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text('Assigned to ${zone.name}', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors[i % colors.length].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statuses[i % statuses.length],
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: colors[i % colors.length]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  final DeliveryZone zone;
  const _AnalyticsTab({required this.zone});

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
                  Icon(Icons.analytics, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Zone Performance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              const _MetricRow(label: 'Delivery Rate', value: 0.94, color: AppColors.success),
              const _MetricRow(label: 'Coverage Score', value: 0.87, color: kSetupColor),
              _MetricRow(label: 'Vehicle Utilization', value: 0.72, color: const Color(0xFF8B5CF6)),
              const _MetricRow(label: 'On-Time %', value: 0.91, color: AppColors.warning),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.timeline, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Activity Summary', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              SetupInfoRow(label: 'Deliveries Today', value: '${zone.dailyDeliveries}'),
              SetupInfoRow(label: 'Active Vehicles', value: '${zone.vehicleCount}'),
              SetupInfoRow(label: 'Avg. Trip Time', value: zone.estimatedTime),
              SetupInfoRow(label: 'Population Served', value: '${zone.populationServed}'),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _MetricRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text('${(value * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Zone Coverage Card ───────────────────────────────────────────────────────

class _ZoneCoverageCard extends StatelessWidget {
  final DeliveryZone zone;
  const _ZoneCoverageCard({required this.zone});

  Future<void> _openInMaps() async {
    final query = Uri.encodeComponent(zone.name);
    final geo = Uri.parse('geo:0,0?q=$query');
    final web = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(geo)) {
      await launchUrl(geo, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(web, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: IveTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: IveTokens.cardBorder,
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _ZoneGridPainter())),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.layers_rounded, size: 18, color: IveTokens.accent),
                    const SizedBox(width: 6),
                    Text(
                      'Zone Coverage — ${zone.name}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: IveTokens.label),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _ZoneInfoRow(icon: Icons.crop_square_rounded, label: 'Area', value: '${zone.coverageKm2.toStringAsFixed(1)} km²'),
                const SizedBox(height: 4),
                _ZoneInfoRow(icon: Icons.people_rounded, label: 'Population served', value: '${zone.populationServed}'),
                const SizedBox(height: 4),
                _ZoneInfoRow(icon: Icons.local_shipping_rounded, label: 'Daily deliveries', value: '${zone.dailyDeliveries}'),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton.icon(
                    onPressed: _openInMaps,
                    icon: const Icon(Icons.open_in_new_rounded, size: 14, color: IveTokens.accent),
                    label: const Text('Open in Maps', style: TextStyle(fontSize: 12, color: IveTokens.accent)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoneInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ZoneInfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: IveTokens.labelTertiary),
        const SizedBox(width: 5),
        Text('$label  ', style: const TextStyle(fontSize: 11, color: IveTokens.labelTertiary)),
        Text(value, style: const TextStyle(fontSize: 12, color: IveTokens.label, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _ZoneGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = IveTokens.hairline.withValues(alpha: 0.35)
      ..strokeWidth = 0.5;
    const s = 30.0;
    for (double x = 0; x < size.width; x += s) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += s) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
