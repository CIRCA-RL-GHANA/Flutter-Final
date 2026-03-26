/// ═══════════════════════════════════════════════════════════════════════════
/// SCREEN 2 — Update Details & Comments
/// Full update view with engagement metrics, comments module (sort, reply,
/// nested threads), and quick-compose input.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../models/updates_models.dart';
import '../providers/updates_provider.dart';
import '../widgets/updates_widgets.dart';

class UpdatesDetailScreen extends StatelessWidget {
  const UpdatesDetailScreen({super.key});

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
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdatesProvider>(
      builder: (context, prov, _) {
        final update = prov.selectedUpdate;
        if (update == null) {
          return Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: const UpdatesAppBar(title: 'Update'),
            body: const UpdatesEmptyState(icon: Icons.article, title: 'Update not found', message: 'This update may have been removed.'),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: UpdatesAppBar(
            title: 'Update',
            actions: [
              IconButton(
                icon: Icon(update.isSavedByMe ? Icons.bookmark : Icons.bookmark_outline, size: 22),
                color: update.isSavedByMe ? kUpdatesAccent : AppColors.textSecondary,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  prov.toggleSave(update.id);
                },
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, size: 22),
                color: AppColors.textSecondary,
                onPressed: () => Navigator.pushNamed(context, AppRoutes.updatesOptions),
              ),
            ],
          ),
          body: Column(
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kUpdatesColor.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kUpdatesColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI: ${ai.insights.first['title'] ?? ''}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kUpdatesColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Update card (full, no compact)
                      UpdateCard(
                        update: update,
                        onLike: () {
                          HapticFeedback.lightImpact();
                          prov.toggleLike(update.id);
                        },
                        onComment: null, // already on detail
                        onShare: () => Navigator.pushNamed(context, AppRoutes.updatesShares),
                        onSave: () {
                          HapticFeedback.lightImpact();
                          prov.toggleSave(update.id);
                        },
                      ),

                      const SizedBox(height: 8),

                      // Engagement summary strip
                      _EngagementStrip(update: update, prov: prov),

                      const SizedBox(height: 12),

                      // Comments section header
                      _CommentsHeader(prov: prov),

                      const SizedBox(height: 8),

                      // Comments list
                      ...prov.comments.map((c) => Column(
                        children: [
                          CommentItem(
                            comment: c,
                            depth: 0,
                            onLike: () => HapticFeedback.lightImpact(),
                            onReply: () => _commentController.text = '@${c.username} ',
                          ),
                          // Nested replies
                          ...c.replies.map((r) => CommentItem(
                            comment: r,
                            depth: 1,
                            onLike: () => HapticFeedback.lightImpact(),
                            onReply: () => _commentController.text = '@${r.username} ',
                          )),
                        ],
                      )),

                      if (prov.comments.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.chat_bubble_outline, size: 32, color: AppColors.textTertiary),
                                SizedBox(height: 8),
                                Text('No comments yet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                                Text('Be the first to comment', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 64), // padding for input
                    ],
                  ),
                ),
              ),

              // Comment input bar
              _CommentInput(controller: _commentController),
            ],
          ),
        );
      },
    );
  }
}

// ─── Engagement Strip ───────────────────────────────────────────────────────

class _EngagementStrip extends StatelessWidget {
  final dynamic update;
  final UpdatesProvider prov;
  const _EngagementStrip({required this.update, required this.prov});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MetricTap(
            icon: Icons.favorite,
            count: update.engagement.likesCount,
            label: 'Likes',
            color: kUpdatesColor,
            onTap: () => Navigator.pushNamed(context, AppRoutes.updatesLikes),
          ),
          _MetricTap(
            icon: Icons.chat_bubble,
            count: update.engagement.commentsCount,
            label: 'Comments',
            color: const Color(0xFF3B82F6),
          ),
          _MetricTap(
            icon: Icons.shortcut,
            count: update.engagement.sharesCount,
            label: 'Shares',
            color: const Color(0xFF10B981),
            onTap: () => Navigator.pushNamed(context, AppRoutes.updatesShares),
          ),
          _MetricTap(
            icon: Icons.visibility,
            count: update.engagement.viewsCount,
            label: 'Views',
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}

class _MetricTap extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _MetricTap({required this.icon, required this.count, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 2),
          Text(_abbreviate(count), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
        ],
      ),
    );
  }

  String _abbreviate(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

// ─── Comments Header ────────────────────────────────────────────────────────

class _CommentsHeader extends StatelessWidget {
  final UpdatesProvider prov;
  const _CommentsHeader({required this.prov});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Comments', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const Spacer(),
        PopupMenuButton<CommentSort>(
          initialValue: prov.commentSort,
          onSelected: prov.setCommentSort,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(prov.commentSort.name, style: const TextStyle(fontSize: 12, color: kUpdatesColor, fontWeight: FontWeight.w600)),
              const Icon(Icons.arrow_drop_down, size: 18, color: kUpdatesColor),
            ],
          ),
          itemBuilder: (_) => CommentSort.values.map((s) => PopupMenuItem(
            value: s,
            child: Text(s.name, style: const TextStyle(fontSize: 13)),
          )).toList(),
        ),
      ],
    );
  }
}

// ─── Comment Input ──────────────────────────────────────────────────────────

class _CommentInput extends StatelessWidget {
  final TextEditingController controller;
  const _CommentInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14, 8, 14, 8 + MediaQuery.of(context).viewPadding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: kUpdatesColor.withOpacity(0.12),
            child: const Text('Y', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kUpdatesColor)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.inputFill,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              if (controller.text.isNotEmpty) {
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Comment posted'), backgroundColor: kUpdatesColor, duration: Duration(seconds: 1)),
                );
                controller.clear();
              }
            },
            child: Container(
              width: 36, height: 36,
              decoration: const BoxDecoration(color: kUpdatesColor, shape: BoxShape.circle),
              child: const Icon(Icons.send, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
