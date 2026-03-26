/// ═══════════════════════════════════════════════════════════════════════════
/// SD1.6: PLACES — Location Management
/// Place list, types, visibility, staff/product counts
/// RBAC: Owner(full), Admin(full), BM(branch), Monitor/BrMon(view),
///        RO/BRO(view), Driver(view)
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

class PlacesScreen extends StatelessWidget {
  const PlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        final places = setupProv.places;

        return SetupRbacGate(
          cardId: 'places',
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FC),
            appBar: SetupAppBar(
              title: 'Places',
              actions: [
                DataScopeIndicator(access: setupProv.getCardAccess('places', ctxProv.currentRole)),
                SizedBox(width: 16),
              ],
            ),
            floatingActionButton: SetupRbacFAB(
              cardId: 'places',
              onPressed: () {
                context.read<SetupDashboardProvider>().selectPlace(null);
                Navigator.pushNamed(context, AppRoutes.setupPlaceDetail);
              },
              label: 'Add Place',
              icon: Icons.add,
            ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: KPIBadge(
                    label: 'Total Places',
                    value: '${places.length}',
                    icon: Icons.place,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: const SetupSectionTitle(
                    title: 'All Places',
                    icon: Icons.place,
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
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _PlaceCard(place: places[i]),
                    childCount: places.length,
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

class _PlaceCard extends StatelessWidget {
  final Place place;
  const _PlaceCard({required this.place});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<SetupDashboardProvider>().selectPlace(place.id);
        Navigator.pushNamed(context, AppRoutes.setupPlaceDetail);
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
                child: Icon(_typeIcon(place.type), size: 22, color: kSetupColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${place.type.name} · ${place.area ?? place.address}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              if (place.visibility == PlaceVisibility.private)
                const SetupStatusIndicator(label: 'Private', color: AppColors.warning),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (place.staffCount > 0)
                _PlaceStat(icon: Icons.people, value: '${place.staffCount} staff'),
              if (place.productCount > 0)
                _PlaceStat(icon: Icons.inventory_2, value: '${place.productCount} products'),
              if (place.rating > 0) ...[
                const Spacer(),
                const Icon(Icons.star, size: 14, color: AppColors.accent),
                const SizedBox(width: 2),
                Text(
                  '${place.rating} (${place.reviewCount})',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
        ],
      ),
      ),
    );
  }

  IconData _typeIcon(PlaceType type) {
    switch (type) {
      case PlaceType.retail:
        return Icons.storefront;
      case PlaceType.warehouse:
        return Icons.warehouse;
      case PlaceType.office:
        return Icons.business;
      case PlaceType.home:
        return Icons.home;
      case PlaceType.custom:
        return Icons.place;
    }
  }
}

class _PlaceStat extends StatelessWidget {
  final IconData icon;
  final String value;
  const _PlaceStat({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textTertiary),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
