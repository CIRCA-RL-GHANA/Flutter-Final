/// ═══════════════════════════════════════════════════════════════════════════
/// SD1.6-DETAIL: SOCIAL POST DETAIL — 4-Tab Deep View
/// Tabs: Overview, Engagement, Audience, Boost
/// RBAC: Admin(full), SO(full), BSO(branch), BM(branch), Monitor(viewOnly)
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../prompt/providers/context_provider.dart';
import '../models/setup_dashboard_models.dart';
import '../providers/setup_dashboard_provider.dart';
import '../widgets/shared_widgets.dart';

class SocialDetailScreen extends StatefulWidget {
  const SocialDetailScreen({super.key});

  @override
  State<SocialDetailScreen> createState() => _SocialDetailScreenState();
}

class _SocialDetailScreenState extends State<SocialDetailScreen> {
  int _tabIndex = 0;
  static const _tabs = ['Overview', 'Engagement', 'Audience', 'Boost'];

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        final post = setupProv.selectedPost;
        if (post == null) {
          return Scaffold(
            appBar: const SetupAppBar(title: 'Post Detail'),
            body: const SetupEmptyState(
              icon: Icons.share,
              title: 'No post selected',
              subtitle: 'Select a post from the social feed',
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FC),
          appBar: const SetupAppBar(title: 'Post Detail'),
          body: Column(
            children: [
              _PostHeader(post: post),
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
                    _OverviewTab(post: post),
                    _EngagementTab(post: post),
                    _AudienceTab(post: post),
                    _BoostTab(post: post),
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

// ─── Header ──────────────────────────────────────────────────────────────────

class _PostHeader extends StatelessWidget {
  final SocialPost post;
  const _PostHeader({required this.post});

  @override
  Widget build(BuildContext context) {
    final statusColor = post.status == PostStatus.published
        ? AppColors.success
        : post.status == PostStatus.scheduled
            ? kSetupColor
            : post.status == PostStatus.draft
                ? AppColors.textTertiary
                : AppColors.warning;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kSetupColor.withOpacity(0.08),
            kSetupColor.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kSetupColor.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: kSetupColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  post.hasMedia ? Icons.image : Icons.text_fields,
                  color: kSetupColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            post.status.name,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ...post.platforms.take(3).map((p) => Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(
                                _platformIcon(p),
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                            )),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (post.publishDate != null)
                      Text(
                        'Published ${setupTimeAgo(post.publishDate!)}',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      )
                    else if (post.scheduledDate != null)
                      Text(
                        'Scheduled: ${post.scheduledDate!.day}/${post.scheduledDate!.month}/${post.scheduledDate!.year}',
                        style: TextStyle(fontSize: 11, color: kSetupColor),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  IconData _platformIcon(SocialPlatform platform) {
    switch (platform) {
      case SocialPlatform.instagram:
        return Icons.camera_alt;
      case SocialPlatform.facebook:
        return Icons.facebook;
      case SocialPlatform.twitter:
        return Icons.alternate_email;
      case SocialPlatform.tikTok:
        return Icons.music_note;
      case SocialPlatform.linkedIn:
        return Icons.work;
    }
  }
}

// ─── Overview Tab ────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final SocialPost post;
  const _OverviewTab({required this.post});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // Quick Stats
        Row(
          children: [
            Expanded(
              child: KPIBadge(
                label: 'Reach',
                value: _formatNumber(post.reach),
                icon: Icons.visibility,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: KPIBadge(
                label: 'Engagement',
                value: '${post.engagementRate.toStringAsFixed(1)}%',
                icon: Icons.touch_app,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: KPIBadge(
                label: 'Shares',
                value: '${post.shares}',
                icon: Icons.share,
                color: kSetupColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Interaction Counts
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SetupSectionTitle(title: 'Interactions', icon: Icons.favorite_border),
              SetupInfoRow(label: 'Likes', value: '${post.likes}'),
              SetupInfoRow(label: 'Comments', value: '${post.comments}'),
              SetupInfoRow(label: 'Shares', value: '${post.shares}'),
              SetupInfoRow(label: 'Total Reach', value: _formatNumber(post.reach)),
            ],
          ),
        ),

        // Content Details
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SetupSectionTitle(title: 'Content', icon: Icons.article),
              Text(
                post.content,
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.5),
              ),
              const SizedBox(height: 12),
              if (post.hasMedia)
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: kSetupColor.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kSetupColor.withOpacity(0.12)),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          post.mediaType == 'video' ? Icons.videocam : Icons.image,
                          size: 32,
                          color: kSetupColor.withOpacity(0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${post.mediaType?.toUpperCase() ?? 'MEDIA'} attached',
                          style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Platforms
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SetupSectionTitle(title: 'Published Platforms', icon: Icons.public),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: post.platforms.map((p) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kSetupColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      p.name[0].toUpperCase() + p.name.substring(1),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: kSetupColor,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

// ─── Engagement Tab ──────────────────────────────────────────────────────────

class _EngagementTab extends StatelessWidget {
  final SocialPost post;
  const _EngagementTab({required this.post});

  @override
  Widget build(BuildContext context) {
    final total = post.likes + post.comments + post.shares;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // Engagement Rate KPI
        KPIBadge(
          label: 'Overall Engagement Rate',
          value: '${post.engagementRate.toStringAsFixed(1)}%',
          icon: Icons.analytics,
          changePercent: 12,
          isPositive: true,
        ),
        const SizedBox(height: 16),

        // Engagement Breakdown
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SetupSectionTitle(title: 'Breakdown', icon: Icons.pie_chart_outline),
              const SizedBox(height: 8),
              if (total > 0) ...[
                _EngagementBar(
                  label: 'Likes',
                  value: post.likes / total,
                  count: post.likes,
                  color: AppColors.error,
                  icon: Icons.favorite,
                ),
                const SizedBox(height: 8),
                _EngagementBar(
                  label: 'Comments',
                  value: post.comments / total,
                  count: post.comments,
                  color: kSetupColor,
                  icon: Icons.comment,
                ),
                const SizedBox(height: 8),
                _EngagementBar(
                  label: 'Shares',
                  value: post.shares / total,
                  count: post.shares,
                  color: AppColors.success,
                  icon: Icons.share,
                ),
              ],
            ],
          ),
        ),

        // Hourly Performance (demo)
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SetupSectionTitle(title: 'Hourly Performance', icon: Icons.schedule),
              ...['9 AM', '12 PM', '3 PM', '6 PM', '9 PM'].asMap().entries.map((e) {
                final vals = [0.25, 0.65, 0.85, 0.50, 0.30];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _HourBar(
                    label: e.value,
                    value: vals[e.key],
                    reach: (vals[e.key] * post.reach * 0.4).toInt(),
                  ),
                );
              }),
            ],
          ),
        ),

        // Top Comments
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SetupSectionTitle(title: 'Top Comments', icon: Icons.chat_bubble_outline),
              const _CommentTile(name: 'Kwame A.', text: 'Great product! Love it 👍', time: '3h ago'),
              const Divider(height: 16),
              const _CommentTile(name: 'Ama B.', text: 'Where can I get this?', time: '5h ago'),
              const Divider(height: 16),
              const _CommentTile(name: 'Kofi D.', text: 'Amazing quality, will order again', time: '7h ago'),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

// ─── Audience Tab ────────────────────────────────────────────────────────────

class _AudienceTab extends StatelessWidget {
  final SocialPost post;
  const _AudienceTab({required this.post});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // Reach KPI
        KPIBadge(
          label: 'Total Reach',
          value: _formatNumber(post.reach),
          icon: Icons.people,
          changePercent: 8,
          isPositive: true,
        ),
        const SizedBox(height: 16),

        // Demographics
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SetupSectionTitle(title: 'Age Distribution', icon: Icons.bar_chart),
              const SizedBox(height: 8),
              const _DemographicBar(label: '18-24', value: 0.22, display: '22%'),
              const SizedBox(height: 6),
              const _DemographicBar(label: '25-34', value: 0.38, display: '38%'),
              const SizedBox(height: 6),
              const _DemographicBar(label: '35-44', value: 0.25, display: '25%'),
              const SizedBox(height: 6),
              const _DemographicBar(label: '45-54', value: 0.10, display: '10%'),
              const SizedBox(height: 6),
              const _DemographicBar(label: '55+', value: 0.05, display: '5%'),
            ],
          ),
        ),

        // Gender
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SetupSectionTitle(title: 'Gender', icon: Icons.people_outline),
              _DemographicBar(label: 'Female', value: 0.52, display: '52%', color: const Color(0xFFE91E63)),
              const SizedBox(height: 6),
              const _DemographicBar(label: 'Male', value: 0.45, display: '45%', color: kSetupColor),
              const SizedBox(height: 6),
              const _DemographicBar(label: 'Other', value: 0.03, display: '3%', color: AppColors.textTertiary),
            ],
          ),
        ),

        // Location
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SetupSectionTitle(title: 'Top Locations', icon: Icons.location_on),
              const SetupInfoRow(label: 'Accra', value: '42%'),
              const SetupInfoRow(label: 'Kumasi', value: '18%'),
              const SetupInfoRow(label: 'Tamale', value: '12%'),
              const SetupInfoRow(label: 'Takoradi', value: '9%'),
              const SetupInfoRow(label: 'Other', value: '19%'),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

// ─── Boost Tab ───────────────────────────────────────────────────────────────

class _BoostTab extends StatelessWidget {
  final SocialPost post;
  const _BoostTab({required this.post});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // Boost Recommendation
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accent.withOpacity(0.12),
                AppColors.accent.withOpacity(0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.accent.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.rocket_launch, color: AppColors.accent, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Boost this post',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Estimated +${(post.reach * 3).toStringAsFixed(0)} additional reach',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Budget Options
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SetupSectionTitle(title: 'Budget Options', icon: Icons.monetization_on),
              const _BoostOption(
                budget: '₵50',
                reach: '2,500 – 5,000',
                duration: '3 days',
                isRecommended: false,
              ),
              const Divider(height: 16),
              const _BoostOption(
                budget: '₵150',
                reach: '7,500 – 15,000',
                duration: '7 days',
                isRecommended: true,
              ),
              const Divider(height: 16),
              const _BoostOption(
                budget: '₵500',
                reach: '25,000 – 50,000',
                duration: '14 days',
                isRecommended: false,
              ),
            ],
          ),
        ),

        // Target Audience
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SetupSectionTitle(title: 'Target Audience', icon: Icons.filter_alt),
              const SetupInfoRow(label: 'Age', value: '18 – 45'),
              const SetupInfoRow(label: 'Location', value: 'Greater Accra, Ashanti'),
              const SetupInfoRow(label: 'Interests', value: 'Shopping, Food & Dining'),
              SetupInfoRow(label: 'Platforms', value: post.platforms.map((p) => p.name).join(', ')),
            ],
          ),
        ),

        // Performance Estimate
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SetupSectionTitle(title: 'Estimated Performance', icon: Icons.trending_up),
              const SetupInfoRow(label: 'Impressions', value: '10,000 – 20,000'),
              const SetupInfoRow(label: 'Clicks', value: '500 – 1,200'),
              const SetupInfoRow(label: 'Engagement Rate', value: '3.5% – 5.2%'),
              const SetupInfoRow(label: 'Cost per Click', value: '₵0.13 – ₵0.30'),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

// ─── Helper Widgets ──────────────────────────────────────────────────────────

String _formatNumber(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return '$n';
}

class _EngagementBar extends StatelessWidget {
  final String label;
  final double value;
  final int count;
  final Color color;
  final IconData icon;

  const _EngagementBar({
    required this.label,
    required this.value,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        SizedBox(
          width: 70,
          child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            '$count',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

class _HourBar extends StatelessWidget {
  final String label;
  final double value;
  final int reach;

  const _HourBar({required this.label, required this.value, required this.reach});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              backgroundColor: kSetupColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(kSetupColor),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            _formatNumber(reach),
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  final String name;
  final String text;
  final String time;

  const _CommentTile({required this.name, required this.text, required this.time});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: kSetupColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              name[0],
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kSetupColor),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(width: 6),
                  Text(time, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                ],
              ),
              const SizedBox(height: 2),
              Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}

class _DemographicBar extends StatelessWidget {
  final String label;
  final double value;
  final String display;
  final Color? color;

  const _DemographicBar({
    required this.label,
    required this.value,
    required this.display,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? kSetupColor;
    return Row(
      children: [
        SizedBox(
          width: 42,
          child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              backgroundColor: c.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(c),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          display,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

class _BoostOption extends StatelessWidget {
  final String budget;
  final String reach;
  final String duration;
  final bool isRecommended;

  const _BoostOption({
    required this.budget,
    required this.reach,
    required this.duration,
    required this.isRecommended,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: isRecommended
          ? BoxDecoration(
              color: kSetupColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kSetupColor.withOpacity(0.2)),
            )
          : null,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    budget,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  if (isRecommended) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: kSetupColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'BEST VALUE',
                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '$duration · $reach reach',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
