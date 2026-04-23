/// ═══════════════════════════════════════════════════════════════════════════
/// SD2.2-DETAIL: PLACE DETAIL — 4-Tab Deep View
/// Tabs: Overview, Staff, Products, Settings
/// RBAC: Admin(fullAccess), BranchManager(branchScoped), Monitor(viewOnly)
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../prompt/providers/context_provider.dart';
import '../models/setup_dashboard_models.dart';
import '../providers/setup_dashboard_provider.dart';
import '../widgets/shared_widgets.dart';

class PlaceDetailScreen extends StatefulWidget {
  const PlaceDetailScreen({super.key});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  int _tabIndex = 0;
  static const _tabs = ['Overview', 'Staff', 'Products', 'Settings'];

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        final place = setupProv.selectedPlace;
        if (place == null) {
          return Scaffold(
            appBar: const SetupAppBar(title: 'Place Detail'),
            body: const SetupEmptyState(
              icon: Icons.place,
              title: 'No place selected',
              subtitle: 'Select a place from the list',
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FC),
          appBar: SetupAppBar(title: place.name),
          body: Column(
            children: [
              _PlaceHeader(place: place),
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
                            'AI: ${ai.insights.first['title'] ?? ''}'',
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
                    _OverviewTab(place: place),
                    _StaffTab(place: place),
                    _ProductsTab(place: place),
                    _SettingsTab(place: place),
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

class _PlaceHeader extends StatelessWidget {
  final Place place;
  const _PlaceHeader({required this.place});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: kSetupColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(place.typeIcon, size: 28, color: kSetupColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(place.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                if (place.address != null)
                  Text(place.address!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: kSetupColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        place.type.name.toUpperCase(),
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: kSetupColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        place.visibility.name,
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.success),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (place.rating > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 14, color: AppColors.accent),
                    Text(' ${place.rating.toStringAsFixed(1)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
                Text('${place.reviewCount} reviews', style: const TextStyle(fontSize: 9, color: AppColors.textTertiary)),
              ],
            ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final Place place;
  const _OverviewTab({required this.place});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        Row(
          children: [
            Expanded(child: SetupStatCard(label: 'Products', value: '${place.productCount}', icon: Icons.inventory_2)),
            const SizedBox(width: 10),
            Expanded(child: SetupStatCard(label: 'Staff', value: '${place.staffCount}', icon: Icons.people, color: AppColors.success)),
            const SizedBox(width: 10),
            Expanded(child: SetupStatCard(label: 'Reviews', value: '${place.reviewCount}', icon: Icons.rate_review, color: kSetupColor)),
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
                  const Text('Place Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              SetupInfoRow(label: 'Place ID', value: place.id),
              SetupInfoRow(label: 'Name', value: place.name),
              SetupInfoRow(label: 'Type', value: place.type.name),
              SetupInfoRow(label: 'Visibility', value: place.visibility.name),
              if (place.address != null)
                SetupInfoRow(label: 'Address', value: place.address!),
              if (place.area != null)
                SetupInfoRow(label: 'Area', value: place.area!),
              if (place.hoursDisplay != null)
                SetupInfoRow(label: 'Operating Hours', value: place.hoursDisplay!),
              SetupInfoRow(label: 'Rating', value: '${place.rating.toStringAsFixed(1)} (${place.reviewCount} reviews)'),
            ],
          ),
        ),
      ],
    );
  }
}

class _StaffTab extends StatelessWidget {
  final Place place;
  const _StaffTab({required this.place});

  @override
  Widget build(BuildContext context) {
    if (place.staffCount == 0) {
      return const SetupEmptyState(
        icon: Icons.people_outline,
        title: 'No staff assigned',
        subtitle: 'Assign staff to this place',
      );
    }

    final roles = ['Manager', 'Supervisor', 'Attendant', 'Security', 'Cleaner'];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: place.staffCount.clamp(0, 5),
      itemBuilder: (context, i) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: kSetupColor.withOpacity(0.1),
                child: Text('${i + 1}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kSetupColor)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Staff ${i + 1}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(roles[i % roles.length], style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                  ],
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProductsTab extends StatelessWidget {
  final Place place;
  const _ProductsTab({required this.place});

  @override
  Widget build(BuildContext context) {
    if (place.productCount == 0) {
      return const SetupEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'No products available',
        subtitle: 'Add products to this place',
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
                  Icon(Icons.inventory_2, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Product Inventory', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              SetupInfoRow(label: 'Total Products', value: '${place.productCount}'),
              SetupInfoRow(label: 'In Stock', value: '${(place.productCount * 0.8).round()}', valueColor: AppColors.success),
              SetupInfoRow(label: 'Low Stock', value: '${(place.productCount * 0.15).round()}', valueColor: AppColors.warning),
              SetupInfoRow(label: 'Out of Stock', value: '${(place.productCount * 0.05).round()}', valueColor: AppColors.error),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsTab extends StatelessWidget {
  final Place place;
  const _SettingsTab({required this.place});

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
                  Icon(Icons.settings, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Place Settings', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              _SettingSwitch(label: 'Public Visibility', value: place.visibility == PlaceVisibility.public),
              const _SettingSwitch(label: 'Notifications', value: true),
              const _SettingSwitch(label: 'Auto-restock', value: false),
              const _SettingSwitch(label: 'Delivery Enabled', value: true),
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
                  const Icon(Icons.warning, size: 18, color: AppColors.error),
                  const SizedBox(width: 8),
                  const Text('Danger Zone', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              SetupActionGuard(
                cardId: 'places',
                requireDelete: true,
                child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.error.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Deactivate Place', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.error)),
                  const SizedBox(height: 4),
                  const Text('This will hide the place from all operations', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 30,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text('Deactivate', style: TextStyle(fontSize: 11)),
                    ),
                  ),
                ],
              ),
            ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingSwitch extends StatelessWidget {
  final String label;
  final bool value;
  const _SettingSwitch({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Switch(
            value: value,
            onChanged: (_) {},
            activeColor: kSetupColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}
