import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/updates_provider.dart';
import '../widgets/updates_widgets.dart';

class UpdatesSocialFeedScreen extends StatefulWidget {
  const UpdatesSocialFeedScreen({super.key});

  @override
  State<UpdatesSocialFeedScreen> createState() =>
      _UpdatesSocialFeedScreenState();
}

class _UpdatesSocialFeedScreenState extends State<UpdatesSocialFeedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<UpdatesProvider>();
      if (prov.updates.isEmpty) {
        prov.loadUpdates();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdatesProvider>(
      builder: (context, prov, _) {
        final updates = prov.filteredUpdates(prov.activeFilter);

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: const Text('Updates'),
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.updatesSearch),
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => Navigator.pushNamed(
                        context, AppRoutes.updatesNotifications),
                  ),
                  if (prov.unreadNotificationCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: kUpdatesColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${prov.unreadNotificationCount}',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kUpdatesColor.withValues(alpha: 0.07),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome,
                            size: 14, color: kUpdatesColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI: ${ai.insights.first['title'] ?? ''}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: kUpdatesColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              UpdatesFilterChipBar(
                activeFilter: prov.activeFilter,
                onFilterChanged: prov.setFilter,
              ),
              Expanded(
                child: prov.isLoading && updates.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: kUpdatesColor))
                    : updates.isEmpty
                        ? const UpdatesEmptyState(
                            icon: Icons.feed,
                            title: 'No updates yet',
                            message:
                                'Follow people or adjust your interests to see updates here.',
                          )
                        : RefreshIndicator(
                            color: kUpdatesColor,
                            onRefresh: () => prov.loadUpdates(),
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(14, 8, 14, 80),
                              itemCount: updates.length,
                              itemBuilder: (context, index) {
                                final update = updates[index];
                                return UpdateCard(
                                  update: update,
                                  onTap: () {
                                    prov.selectUpdate(update);
                                    Navigator.pushNamed(
                                        context, AppRoutes.updatesDetail);
                                  },
                                  onLike: () {
                                    HapticFeedback.lightImpact();
                                    prov.toggleLike(update.id);
                                  },
                                  onComment: () {
                                    prov.selectUpdate(update);
                                    Navigator.pushNamed(
                                        context, AppRoutes.updatesDetail);
                                  },
                                  onShare: () {
                                    prov.selectUpdate(update);
                                    Navigator.pushNamed(
                                        context, AppRoutes.updatesShares);
                                  },
                                  onSave: () {
                                    HapticFeedback.lightImpact();
                                    prov.toggleSave(update.id);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          update.isSavedByMe
                                              ? 'Removed from saved'
                                              : 'Saved to library',
                                        ),
                                        backgroundColor: kUpdatesColor,
                                        duration:
                                            const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  onOptions: () {
                                    prov.selectUpdate(update);
                                    Navigator.pushNamed(
                                        context, AppRoutes.updatesOptions);
                                  },
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.updatesCreate),
            backgroundColor: kUpdatesColor,
            child: const Icon(Icons.edit, color: Colors.white),
          ),
        );
      },
    );
  }
}
