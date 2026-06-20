/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
/// SCREEN 1 — Main Updates Feed
/// The primary social feed with filter bar, update cards, compose FAB,
/// notification badge, and infinite-scroll-style list.
/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
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

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    await context.read<UpdatesProvider>().loadUpdates();
    if (mounted) setState(() => _isLoadingMore = false);
  }

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
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: kUpdatesColor,
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
      body: Consumer<UpdatesProvider>(
        builder: (context, prov, _) {
          final updates = prov.filteredUpdates(prov.activeFilter);
          return Column(
            children: [
              // Filter bar
              UpdatesFilterChipBar(
                activeFilter: prov.activeFilter,
                onFilterChanged: prov.setFilter,
              ),
              // Feed list
              Expanded(
                child: updates.isEmpty
                    ? const UpdatesEmptyState(
                        icon: Icons.feed,
                        title: 'No updates yet',
                        message: 'Follow entities or adjust your interests to see updates here.',
                      )
                    : RefreshIndicator(
                        color: kUpdatesColor,
                        onRefresh: () => context.read<UpdatesProvider>().loadUpdates(),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(14, 8, 14, 80),
                          itemCount: updates.length + (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == updates.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(child: CircularProgressIndicator(color: kUpdatesColor, strokeWidth: 2)),
                              );
                            }
                            final update = updates[index];
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
