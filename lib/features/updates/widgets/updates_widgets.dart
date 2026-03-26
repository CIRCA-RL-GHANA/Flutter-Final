/// ═══════════════════════════════════════════════════════════════════════════
/// MY UPDATES MODULE — Shared Widgets
/// Reusable UI components: UpdatesAppBar, UpdateCard, CommentItem,
/// NotificationItem, InterestCard, FollowedEntityCard, FilterChipBar,
/// EngagementBar, EmptyState, SectionCard, etc.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../models/updates_models.dart';

// ─── Module Colors ──────────────────────────────────────────────────────────

/// The canonical module color for MY UPDATES (Pink — Social)
const Color kUpdatesColor = Color(0xFFEC4899);
const Color kUpdatesColorLight = Color(0xFFFCE7F3);
const Color kUpdatesColorDark = Color(0xFF9D174D);
const Color kUpdatesAccent = Color(0xFF8B5CF6);

// ─── Updates App Bar ────────────────────────────────────────────────────────

class UpdatesAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const UpdatesAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: showBackButton
          ? Row(
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
            )
          : null,
      leadingWidth: showBackButton ? 64 : null,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
      ),
      actions: actions,
    );
  }
}

// ─── Update Card ────────────────────────────────────────────────────────────

class UpdateCard extends StatelessWidget {
  final UpdateEntity update;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onSave;
  final VoidCallback? onOptions;
  final bool isCompact;

  const UpdateCard({
    super.key,
    required this.update,
    this.onTap,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onSave,
    this.onOptions,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: update.isAnnouncement
              ? const Border(left: BorderSide(color: Color(0xFF3B82F6), width: 3))
              : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(
                children: [
                  // Entity avatar
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: isCompact ? 16 : 20,
                        backgroundColor: kUpdatesColor.withOpacity(0.15),
                        child: Text(
                          update.entityAvatar.isNotEmpty ? update.entityAvatar : update.entityName.substring(0, 1),
                          style: TextStyle(fontSize: isCompact ? 12 : 14, fontWeight: FontWeight.w700, color: kUpdatesColor),
                        ),
                      ),
                      if (update.isVerified)
                        Positioned(
                          right: 0, bottom: 0,
                          child: Container(
                            width: 14, height: 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: const Icon(Icons.check, size: 8, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                update.entityName,
                                style: TextStyle(fontSize: isCompact ? 13 : 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (update.isAnnouncement) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(4)),
                                child: const Text('Official', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
                              ),
                            ],
                          ],
                        ),
                        Row(
                          children: [
                            Text(update.authorRole, style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                            const Text(' • ', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                            Text(_timeAgo(update.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                            if (update.isEdited) ...[
                              const Text(' • ', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                              const Text('edited', style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: AppColors.textTertiary)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (onOptions != null)
                    IconButton(
                      icon: const Icon(Icons.more_horiz, size: 20),
                      color: AppColors.textTertiary,
                      onPressed: onOptions,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
            ),

            // Media preview (if applicable)
            if (update.mediaUrls.isNotEmpty && !isCompact) ...[
              const SizedBox(height: 10),
              _MediaPreview(update: update),
            ],

            // Poll (if applicable)
            if (update.poll != null && !isCompact) ...[
              const SizedBox(height: 10),
              _PollPreview(poll: update.poll!),
            ],

            // Caption
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Text(
                update.caption,
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
                maxLines: isCompact ? 2 : 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Location
            if (update.locationName != null && !isCompact)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 12, color: AppColors.textTertiary),
                    const SizedBox(width: 2),
                    Text(update.locationName!, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                  ],
                ),
              ),

            // Engagement bar
            if (!isCompact) ...[
              const SizedBox(height: 8),
              _EngagementBar(
                update: update,
                onLike: onLike,
                onComment: onComment,
                onShare: onShare,
                onSave: onSave,
              ),
            ],

            // Metrics display
            if (!isCompact && update.engagement.likesCount > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
                child: Text(
                  update.engagement.likedByPreview.isNotEmpty
                      ? 'Liked by ${update.engagement.likedByPreview.first} and ${_abbreviate(update.engagement.likesCount - 1)} others'
                      : '${_abbreviate(update.engagement.likesCount)} likes',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ),

            if (isCompact) const SizedBox(height: 8),
            if (!isCompact) const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

// ─── Media Preview ──────────────────────────────────────────────────────────

class _MediaPreview extends StatelessWidget {
  final UpdateEntity update;
  const _MediaPreview({required this.update});

  @override
  Widget build(BuildContext context) {
    final icon = switch (update.contentType) {
      UpdateContentType.video => Icons.play_circle_fill,
      UpdateContentType.audio => Icons.graphic_eq,
      _ => null,
    };

    return Container(
      height: 200,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: kUpdatesColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon ?? Icons.image,
                  size: 40,
                  color: kUpdatesColor.withOpacity(0.3),
                ),
                const SizedBox(height: 4),
                Text(
                  update.contentType.name.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: kUpdatesColor.withOpacity(0.4)),
                ),
              ],
            ),
          ),
          if (update.mediaUrls.length > 1)
            Positioned(
              top: 8, right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '1/${update.mediaUrls.length}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          if (update.contentType == UpdateContentType.audio)
            Positioned(
              bottom: 12, left: 12, right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.play_arrow, size: 20, color: kUpdatesColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(height: 3, decoration: BoxDecoration(color: kUpdatesColor.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
                    ),
                    const SizedBox(width: 6),
                    const Text('2:30', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Poll Preview ───────────────────────────────────────────────────────────

class _PollPreview extends StatelessWidget {
  final UpdatePoll poll;
  const _PollPreview({required this.poll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...poll.options.map((opt) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: opt.id == poll.selectedOptionId ? kUpdatesColor.withOpacity(0.1) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: opt.id == poll.selectedOptionId ? kUpdatesColor : Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(opt.text, style: TextStyle(fontSize: 13, fontWeight: opt.id == poll.selectedOptionId ? FontWeight.w600 : FontWeight.w400))),
                      Text('${opt.percentage.toStringAsFixed(0)}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: opt.id == poll.selectedOptionId ? kUpdatesColor : AppColors.textSecondary)),
                    ],
                  ),
                ),
                if (poll.hasVoted)
                  Positioned(
                    left: 0, top: 0, bottom: 0,
                    child: Container(
                      width: (opt.percentage / 100) * 200,
                      decoration: BoxDecoration(
                        color: kUpdatesColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
              ],
            ),
          )),
          Text(
            '${poll.totalVotes} votes • ${_timeLeft(poll.endsAt)}',
            style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  String _timeLeft(DateTime end) {
    final diff = end.difference(DateTime.now());
    if (diff.isNegative) return 'Ended';
    if (diff.inDays > 0) return '${diff.inDays}d left';
    if (diff.inHours > 0) return '${diff.inHours}h left';
    return '${diff.inMinutes}m left';
  }
}

// ─── Engagement Bar ─────────────────────────────────────────────────────────

class _EngagementBar extends StatelessWidget {
  final UpdateEntity update;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onSave;

  const _EngagementBar({
    required this.update,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          _EngagementButton(
            icon: update.isLikedByMe ? Icons.favorite : Icons.favorite_outline,
            count: update.engagement.likesCount,
            color: update.isLikedByMe ? kUpdatesColor : AppColors.textTertiary,
            onTap: onLike,
          ),
          _EngagementButton(
            icon: Icons.chat_bubble_outline,
            count: update.engagement.commentsCount,
            onTap: onComment,
          ),
          _EngagementButton(
            icon: Icons.shortcut,
            count: update.engagement.sharesCount,
            onTap: onShare,
          ),
          const Spacer(),
          _EngagementButton(
            icon: update.isSavedByMe ? Icons.bookmark : Icons.bookmark_outline,
            count: null,
            color: update.isSavedByMe ? kUpdatesAccent : AppColors.textTertiary,
            onTap: onSave,
          ),
        ],
      ),
    );
  }
}

class _EngagementButton extends StatelessWidget {
  final IconData icon;
  final int? count;
  final Color? color;
  final VoidCallback? onTap;

  const _EngagementButton({
    required this.icon,
    this.count,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color ?? AppColors.textTertiary),
            if (count != null && count! > 0) ...[
              const SizedBox(width: 4),
              Text(_abbreviate(count!), style: TextStyle(fontSize: 12, color: color ?? AppColors.textSecondary)),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Comment Item ───────────────────────────────────────────────────────────

class CommentItem extends StatelessWidget {
  final UpdateComment comment;
  final int depth;
  final VoidCallback? onLike;
  final VoidCallback? onReply;

  const CommentItem({
    super.key,
    required this.comment,
    this.depth = 0,
    this.onLike,
    this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: depth * 24.0, bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: depth == 0 ? 18 : 14,
            backgroundColor: kUpdatesColor.withOpacity(0.12),
            child: Text(
              comment.userAvatar.isNotEmpty ? comment.userAvatar : comment.username.substring(0, 1),
              style: TextStyle(fontSize: depth == 0 ? 12 : 10, fontWeight: FontWeight.w700, color: kUpdatesColor),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comment.username, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    if (comment.isVerified) ...[
                      const SizedBox(width: 3),
                      const Icon(Icons.verified, size: 12, color: Color(0xFF3B82F6)),
                    ],
                    const SizedBox(width: 6),
                    Text(_timeAgo(comment.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                    if (comment.isEdited) const Text(' (edited)', style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: AppColors.textTertiary)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(comment.text, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.3)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onLike,
                      child: Row(
                        children: [
                          Icon(
                            comment.isLikedByMe ? Icons.favorite : Icons.favorite_outline,
                            size: 14,
                            color: comment.isLikedByMe ? kUpdatesColor : AppColors.textTertiary,
                          ),
                          if (comment.likesCount > 0) ...[
                            const SizedBox(width: 2),
                            Text('${comment.likesCount}', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: onReply,
                      child: const Text('Reply', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTertiary)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Notification Item ──────────────────────────────────────────────────────

class NotificationItem extends StatelessWidget {
  final UpdateNotification notification;
  final VoidCallback? onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final info = _notifInfo(notification.type);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: notification.isRead ? Colors.transparent : kUpdatesColor.withOpacity(0.03),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: info.$2.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(info.$1, size: 18, color: info.$2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title, style: TextStyle(fontSize: 13, fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700, color: AppColors.textPrimary)),
                  Text(notification.body, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_timeAgo(notification.createdAt), style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                if (!notification.isRead) ...[
                  const SizedBox(height: 4),
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: kUpdatesColor, shape: BoxShape.circle)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  (IconData, Color) _notifInfo(UpdateNotificationType type) => switch (type) {
        UpdateNotificationType.like => (Icons.favorite, kUpdatesColor),
        UpdateNotificationType.comment => (Icons.chat_bubble, const Color(0xFF3B82F6)),
        UpdateNotificationType.mention => (Icons.alternate_email, kUpdatesAccent),
        UpdateNotificationType.share => (Icons.shortcut, const Color(0xFF10B981)),
        UpdateNotificationType.follow => (Icons.person_add, const Color(0xFFF59E0B)),
        UpdateNotificationType.system => (Icons.info, AppColors.textTertiary),
      };
}

// ─── Filter Chip Bar ────────────────────────────────────────────────────────

class UpdatesFilterChipBar extends StatelessWidget {
  final FeedFilter activeFilter;
  final ValueChanged<FeedFilter> onFilterChanged;

  const UpdatesFilterChipBar({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      (FeedFilter.forYou, 'For You', Icons.auto_awesome),
      (FeedFilter.latest, 'Latest', Icons.access_time),
      (FeedFilter.following, 'Following', Icons.people),
      (FeedFilter.trending, 'Trending', Icons.trending_up),
      (FeedFilter.announcements, 'Announcements', Icons.campaign),
    ];

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final (filter, label, icon) = filters[index];
          final isActive = activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => onFilterChanged(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? kUpdatesColor : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isActive ? kUpdatesColor : Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isActive) ...[
                      const Icon(Icons.check, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                    ],
                    Icon(icon, size: 14, color: isActive ? Colors.white : AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Section Card ───────────────────────────────────────────────────────────

class UpdatesSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  final Widget? trailing;

  const UpdatesSectionCard({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor = kUpdatesColor,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26, height: 26,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: 0.5)),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// ─── Empty State ────────────────────────────────────────────────────────────

class UpdatesEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? ctaLabel;
  final VoidCallback? onCta;

  const UpdatesEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.ctaLabel,
    this.onCta,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: kUpdatesColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: kUpdatesColor.withOpacity(0.4)),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(message, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary), textAlign: TextAlign.center),
            if (ctaLabel != null && onCta != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onCta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kUpdatesColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(ctaLabel!, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Liker Item ─────────────────────────────────────────────────────────────

class LikerItem extends StatelessWidget {
  final UpdateLiker liker;
  final VoidCallback? onFollow;

  const LikerItem({super.key, required this.liker, this.onFollow});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: kUpdatesColor.withOpacity(0.12),
                child: Text(liker.username.substring(0, 1), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kUpdatesColor)),
              ),
              if (liker.isOnline)
                Positioned(
                  right: 0, bottom: 0,
                  child: Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(liker.username, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    if (liker.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, size: 14, color: Color(0xFF3B82F6)),
                    ],
                  ],
                ),
                Text(liker.fullName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                if (liker.mutualConnections > 0)
                  Text('${liker.mutualConnections} mutual connections', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              ],
            ),
          ),
          if (!liker.isFollowing)
            OutlinedButton(
              onPressed: onFollow,
              style: OutlinedButton.styleFrom(
                foregroundColor: kUpdatesColor,
                side: const BorderSide(color: kUpdatesColor),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Follow', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: kUpdatesColor.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
              child: const Text('Following', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kUpdatesColor)),
            ),
        ],
      ),
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────────

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  return '${(diff.inDays / 7).floor()}w';
}

String _abbreviate(int count) {
  if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
  if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
  return count.toString();
}
