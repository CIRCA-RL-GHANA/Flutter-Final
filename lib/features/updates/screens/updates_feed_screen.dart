/// ═══════════════════════════════════════════════════════════════════════════
/// SCREEN 1 — Main Updates Feed
/// The primary social feed with filter bar, update cards, compose FAB,
/// notification badge, and infinite-scroll-style list.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/ai_insights_notifier.dart';
// ignore: unused_import
import '../models/updates_models.dart';
import '../providers/updates_provider.dart';
import '../widgets/updates_widgets.dart';

class UpdatesFeedScreen extends StatelessWidget {
  const UpdatesFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UpdatesProvider(),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
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
              width: 10, height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kUpdatesColor,
                boxShadow: [BoxShadow(color: kUpdatesColor.withOpacity(0.3), blurRadius: 4)],
              ),
            ),
          ],
        ),
        leadingWidth: 64,
        title: const Text(
          'My Updates',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.3),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 22),
            color: AppColors.textSecondary,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.updatesSearch),
          ),
          Consumer<UpdatesProvider>(
            builder: (context, prov, _) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, size: 22),
                  color: AppColors.textSecondary,
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.updatesNotifications),
                ),
                if (prov.unreadNotificationCount > 0)
                  Positioned(
                    right: 8, top: 8,
                    child: Container(
                      width: 16, height: 16,
                      decoration: const BoxDecoration(color: kUpdatesColor, shape: BoxShape.circle),
                      child: Center(
                        child: Text('${prov.unreadNotificationCount}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Consumer2<UpdatesProvider, AIInsightsNotifier>(
        builder: (context, prov, aiNotifier, _) {
          final updates = prov.filteredUpdates(prov.activeFilter);
          // AI: if recommendations exist, boost recommended IDs to the top
          final recIds = aiNotifier.recommendations
              .map((r) => r['id']?.toString() ?? '')
              .toSet();
          final sorted = recIds.isEmpty
              ? updates
              : [
                  ...updates.where((u) => recIds.contains(u.id)),
                  ...updates.where((u) => !recIds.contains(u.id)),
                ];
          return Column(
            children: [
              // Filter bar
              UpdatesFilterChipBar(
                activeFilter: prov.activeFilter,
                onFilterChanged: prov.setFilter,
              ),
              // AI personalized feed indicator
              if (recIds.isNotEmpty)
                Container(
                  margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: kUpdatesColor.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kUpdatesColor.withOpacity(0.18)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 14, color: kUpdatesColor),
                      const SizedBox(width: 6),
                      Text(
                        'AI — Personalised feed order',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: kUpdatesColor,
                        ),
                      ),
                    ],
                  ),
                ),
              // Feed list
              Expanded(
                child: sorted.isEmpty
                    ? const UpdatesEmptyState(
                        icon: Icons.feed,
                        title: 'No updates yet',
                        message: 'Follow entities or adjust your interests to see updates here.',
                      )
                    : RefreshIndicator(
                        color: kUpdatesColor,
                        onRefresh: () => context.read<UpdatesProvider>().loadUpdates(),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(14, 8, 14, 80),
                          itemCount: sorted.length,
                          itemBuilder: (context, index) {
                            final update = sorted[index];
                            return UpdateCard(
                              update: update,
                              onTap: () {
                                prov.selectUpdate(update);
                                Navigator.pushNamed(context, AppRoutes.updatesDetail);
                              },
                              onLike: () {
                                HapticFeedback.lightImpact();
                                prov.toggleLike(update.id);
                              },
                              onComment: () {
                                prov.selectUpdate(update);
                                Navigator.pushNamed(context, AppRoutes.updatesDetail);
                              },
                              onShare: () {
                                prov.selectUpdate(update);
                                Navigator.pushNamed(context, AppRoutes.updatesShares);
                              },
                              onSave: () {
                                HapticFeedback.lightImpact();
                                prov.toggleSave(update.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(update.isSavedByMe ? 'Removed from saved' : 'Saved to library'),
                                    backgroundColor: kUpdatesColor,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              onOptions: () {
                                prov.selectUpdate(update);
                                Navigator.pushNamed(context, AppRoutes.updatesOptions);
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.updatesCreate),
        backgroundColor: kUpdatesColor,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}
