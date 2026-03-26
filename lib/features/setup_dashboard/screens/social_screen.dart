/// ═══════════════════════════════════════════════════════════════════════════
/// SD1.11: SOCIAL — Social Media & Updates
/// Post feed, scheduled content, engagement metrics
/// RBAC: Owner(personal), Admin(full), BM(branch), SO(full), BSO(branch),
///        Monitor/BrMon(view), RO/BRO(view), Driver(view)
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

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        final posts = setupProv.posts;

        return SetupRbacGate(
          cardId: 'social',
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FC),
            appBar: SetupAppBar(
              title: 'Social & Updates',
              actions: [
                DataScopeIndicator(access: setupProv.getCardAccess('social', ctxProv.currentRole)),
                SizedBox(width: 16),
              ],
            ),
            floatingActionButton: SetupRbacFAB(
              cardId: 'social',
              onPressed: () {},
              label: 'New Post',
              icon: Icons.edit,
            ),
          body: CustomScrollView(
            slivers: [
              // ─── Engagement KPIs ──────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: KPIBadge(
                          label: 'Published',
                          value: '${posts.where((p) => p.status == PostStatus.published).length}',
                          icon: Icons.public,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: KPIBadge(
                          label: 'Scheduled',
                          value: '${posts.where((p) => p.status == PostStatus.scheduled).length}',
                          icon: Icons.schedule,
                          color: AppColors.info,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: KPIBadge(
                          label: 'Avg. Engage',
                          value: (() {
                            final published = posts.where((p) => p.status == PostStatus.published).toList();
                            if (published.isEmpty) return '—';
                            final avg = published.fold<double>(0, (s, p) => s + p.engagementRate) / published.length;
                            return '${avg.toStringAsFixed(1)}%';
                          })(),
                          icon: Icons.trending_up,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Status Filter ────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _ContentTypeChip(label: 'All', count: posts.length, isSelected: true),
                        const SizedBox(width: 6),
                        _ContentTypeChip(label: 'Published', count: posts.where((p) => p.status == PostStatus.published).length, color: AppColors.success),
                        const SizedBox(width: 6),
                        _ContentTypeChip(label: 'Scheduled', count: posts.where((p) => p.status == PostStatus.scheduled).length, color: AppColors.info),
                        const SizedBox(width: 6),
                        _ContentTypeChip(label: 'Draft', count: posts.where((p) => p.status == PostStatus.draft).length, color: AppColors.textTertiary),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── Platform Distribution ────────────────────
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
                        const Text(
                          'Platform Reach',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: SocialPlatform.values.map((p) {
                            final count = posts.where((post) => post.platforms.contains(p)).length;
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: kSetupColor.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_platformIcon(p), size: 14, color: kSetupColor),
                                  const SizedBox(width: 4),
                                  Text('$count', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kSetupColor)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: const SetupSectionTitle(title: 'Posts', icon: Icons.forum),
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
                    (context, i) => _PostCard(post: posts[i]),
                    childCount: posts.length,
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

class _PostCard extends StatelessWidget {
  final SocialPost post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<SetupDashboardProvider>().selectPost(post.id);
        Navigator.pushNamed(context, AppRoutes.setupSocialDetail);
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
              SetupStatusIndicator(
                label: post.status.name,
                color: post.status == PostStatus.published
                    ? AppColors.success
                    : post.status == PostStatus.scheduled
                        ? AppColors.info
                        : AppColors.textTertiary,
              ),
              const Spacer(),
              // Platforms
              ...post.platforms.map((p) => Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(_platformIcon(p), size: 16, color: AppColors.textTertiary),
                  )),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            post.content,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (post.hasMedia) ...[
            const SizedBox(height: 8),
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: kSetupColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      post.mediaType == 'Video' ? Icons.play_circle : Icons.image,
                      size: 28,
                      color: kSetupColor.withOpacity(0.4),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      post.mediaType ?? 'Media',
                      style: TextStyle(fontSize: 13, color: kSetupColor.withOpacity(0.5)),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (post.status == PostStatus.published) ...[
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _PostStat(icon: Icons.favorite, value: '${post.likes}'),
                _PostStat(icon: Icons.comment, value: '${post.comments}'),
                _PostStat(icon: Icons.share, value: '${post.shares}'),
                if (post.engagementRate > 0)
                  _PostStat(icon: Icons.trending_up, value: '${post.engagementRate}%'),
              ],
            ),
          ],
          if (post.status == PostStatus.scheduled && post.scheduledDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(
                  'Scheduled: ${setupTimeAgo(post.scheduledDate!)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
              ],
            ),
          ],
        ],
      ),
    ),
    );
  }

  IconData _platformIcon(SocialPlatform platform) {
    switch (platform) {
      case SocialPlatform.facebook:
        return Icons.facebook;
      case SocialPlatform.instagram:
        return Icons.camera_alt;
      case SocialPlatform.twitter:
        return Icons.tag;
      case SocialPlatform.linkedIn:
        return Icons.work;
      case SocialPlatform.tikTok:
        return Icons.music_note;
    }
  }
}

class _PostStat extends StatelessWidget {
  final IconData icon;
  final String value;
  const _PostStat({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      ],
    );
  }
}

// ─── Content Type Chip ───────────────────────────────────────────────────────

class _ContentTypeChip extends StatelessWidget {
  final String label;
  final int count;
  final Color? color;
  final bool isSelected;

  const _ContentTypeChip({
    required this.label,
    required this.count,
    this.color,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? kSetupColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? c.withOpacity(0.12) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? c.withOpacity(0.4) : AppColors.inputBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? c : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: c.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: c),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _platformIcon(SocialPlatform platform) {
  switch (platform) {
    case SocialPlatform.facebook:
      return Icons.facebook;
    case SocialPlatform.instagram:
      return Icons.camera_alt;
    case SocialPlatform.twitter:
      return Icons.tag;
    case SocialPlatform.linkedIn:
      return Icons.work;
    case SocialPlatform.tikTok:
      return Icons.music_note;
  }
}
