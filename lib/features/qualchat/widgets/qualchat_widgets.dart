/// qualChat Module  Shared Widgets
/// Reusable UI components for all qualChat screens
/// Module Color: Cyan 0xFF06B6D4
library;

import 'package:flutter/material.dart';
import '../../../core/design/ive.dart';
import '../models/qualchat_models.dart';

// 
//  MODULE COLORS
// 

// IveTokens.moduleQualChat/IveTokens.accentSoft/IveTokens.accent replaced by IveTokens.moduleQualChat / IveTokens.accent
// kChatSocial kept as local const (no system token for hot-pink social accent)
const Color kChatSocial = Color(0xFFEC4899);

// 
//  APP BAR
// 

class QualChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final Widget? leading;

  const QualChatAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: IveTokens.surface,
      foregroundColor: IveTokens.ink,
      elevation: 0,
      leading: leading ??
          (showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => Navigator.pop(context),
                )
              : null),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: IveTokens.moduleQualChat,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: IveTokens.ink,
            ),
          ),
        ],
      ),
      actions: actions,
    );
  }
}

// 
//  PRESENCE DOT
// 

class PresenceDot extends StatelessWidget {
  final PresenceStatus status;
  final double size;

  const PresenceDot({super.key, required this.status, this.size = 10});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _color,
        shape: BoxShape.circle,
        border: Border.all(color: IveTokens.surface, width: 1.5),
      ),
    );
  }

  Color get _color {
    switch (status) {
      case PresenceStatus.online:
        return IveTokens.success;
      case PresenceStatus.idle:
        return IveTokens.warning;
      case PresenceStatus.offline:
        return IveTokens.danger;
    }
  }
}

// 
//  PRESENCE STAT CARD
// 

class PresenceStatCard extends StatelessWidget {
  final int count;
  final String label;
  final PresenceStatus status;
  final double? changePercent;
  final VoidCallback? onTap;

  const PresenceStatCard({
    super.key,
    required this.count,
    required this.label,
    required this.status,
    this.changePercent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: IveTokens.surface,
            borderRadius: BorderRadius.circular(IveTokens.rSm),
            border: Border.all(color: IveTokens.hairline2),
          ),
          child: Column(
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: IveTokens.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: IveTokens.mute),
              ),
              const SizedBox(height: 4),
              PresenceDot(status: status),
              if (changePercent != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${changePercent! >= 0 ? '+' : '-'}${changePercent!.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: changePercent! >= 0
                        ? IveTokens.success
                        : IveTokens.danger,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// 
//  CONVERSATION CARD
// 

class ConversationCard extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ConversationCard({
    super.key,
    required this.conversation,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final c = conversation;
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: c.unreadCount > 0 ? IveTokens.moduleQualChat.withValues(alpha: 0.08) : IveTokens.surface,
          border: const Border(
            bottom: BorderSide(color: IveTokens.hairline),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: IveTokens.moduleQualChat.withValues(alpha: 0.1),
                  child: Text(
                    c.title.isNotEmpty ? c.title[0] : '?',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: IveTokens.moduleQualChat,
                    ),
                  ),
                ),
                if (c.type == ChatType.individual &&
                    c.participants.isNotEmpty)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: PresenceDot(
                      status: c.participants.first.presence,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: c.unreadCount > 0
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: IveTokens.ink,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _timeAgo(c.lastMessageTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: c.unreadCount > 0
                              ? IveTokens.moduleQualChat
                              : IveTokens.ink2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (c.typingUser != null) ...[
                        const Icon(Icons.edit, size: 14, color: IveTokens.moduleQualChat),
                        const SizedBox(width: 4),
                        Text(
                          '${c.typingUser} is typing...',
                          style: const TextStyle(
                            fontSize: 13,
                            color: IveTokens.moduleQualChat,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ] else
                        Expanded(
                          child: Text(
                            c.lastMessage,
                            style: TextStyle(
                              fontSize: 13,
                              color: c.unreadCount > 0
                                  ? IveTokens.ink
                                  : IveTokens.mute,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (c.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: IveTokens.moduleQualChat,
                            borderRadius: BorderRadius.circular(IveTokens.rSm),
                          ),
                          child: Text(
                            '${c.unreadCount}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: IveTokens.bg,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (c.type == ChatType.group && c.onlineCount != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${c.onlineCount} online',
                      style: const TextStyle(
                        fontSize: 11,
                        color: IveTokens.success,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (c.isPinned)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.push_pin, size: 14, color: IveTokens.ink2),
              ),
            if (c.isMuted)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.volume_off, size: 14, color: IveTokens.ink2),
              ),
          ],
        ),
      ),
    );
  }
}

// 
//  HEY YA CARD
// 

class HeyYaCard extends StatelessWidget {
  final HeyYaRequest request;
  final VoidCallback? onTap;
  final VoidCallback? onTimeline;
  final VoidCallback? onFollowUp;
  final VoidCallback? onOptions;

  const HeyYaCard({
    super.key,
    required this.request,
    this.onTap,
    this.onTimeline,
    this.onFollowUp,
    this.onOptions,
  });

  @override
  Widget build(BuildContext context) {
    final r = request;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: IveTokens.surface,
          borderRadius: BorderRadius.circular(IveTokens.rSm),
          border: Border.all(color: IveTokens.hairline2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: kChatSocial.withValues(alpha: 0.1),
                  child: Text(
                    r.person.name[0],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: kChatSocial,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.person.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: IveTokens.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ' ${r.person.role}  ${r.person.distanceKm?.toStringAsFixed(0) ?? '?'}km away',
                        style: const TextStyle(
                          fontSize: 12,
                          color: IveTokens.mute,
                        ),
                      ),
                    ],
                  ),
                ),
                // Match badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kChatSocial.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(IveTokens.rSm),
                  ),
                  child: Text(
                    '${r.matchPercentage}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: kChatSocial,
                    ),
                  ),
                ),
              ],
            ),
            // Intent badge
            const SizedBox(height: 8),
            _IntentBadge(intent: r.intent),
            // Message
            if (r.message != null) ...[
              const SizedBox(height: 12),
              Text(
                '${r.message}"',
                style: const TextStyle(
                  fontSize: 13,
                  color: IveTokens.mute,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 8),
            // Status row
            Row(
              children: [
                _StatusBadge(status: r.status),
                const SizedBox(width: 8),
                Text(
                  ' ${r.isSentByMe ? "Sent" : "Received"} ${_timeAgo(r.sentAt)}',
                  style: const TextStyle(fontSize: 11, color: IveTokens.ink2),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Actions
            Row(
              children: [
                _ActionChip(label: 'View Journey', icon: Icons.timeline, onTap: onTimeline),
                const SizedBox(width: 8),
                _ActionChip(label: 'Plan Date "', icon: Icons.event_outlined, onTap: onFollowUp),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: IveTokens.ink2),
                  onPressed: onOptions,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  iconSize: 20,
                ),
              ],
            ),
            // Compatibility breakdown
            if (r.compatibility != null) ...[
              const SizedBox(height: 10),
              _CompatibilityMiniBar(compatibility: r.compatibility!),
            ],
          ],
        ),
      ),
    );
  }
}

// Intent badge showing what kind of date
class _IntentBadge extends StatelessWidget {
  final HeyYaIntent intent;
  const _IntentBadge({required this.intent});

  static const _icons = {
    HeyYaIntent.coffee: ('', 'Coffee'),
    HeyYaIntent.dinner: ('', 'Dinner'),
    HeyYaIntent.walk: ('', 'Walk'),
    HeyYaIntent.movie: ('', 'Movie Night'),
    HeyYaIntent.videoCall: ('', 'Video Date'),
    HeyYaIntent.any: ('', 'Open to Anything'),
  };

  @override
  Widget build(BuildContext context) {
    final info = _icons[intent] ?? ('', 'Open to Anything');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: kChatSocial.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(IveTokens.rXs),
        border: Border.all(color: kChatSocial.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(info.$1, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Text(
            info.$2,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: kChatSocial,
            ),
          ),
        ],
      ),
    );
  }
}

// Compact compatibility bar row
class _CompatibilityMiniBar extends StatelessWidget {
  final CompatibilityBreakdown compatibility;
  const _CompatibilityMiniBar({required this.compatibility});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Compatibility',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: IveTokens.mute),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _MiniBar(label: 'Interests', value: compatibility.interests),
            const SizedBox(width: 8),
            _MiniBar(label: 'Vibe', value: compatibility.vibe),
            const SizedBox(width: 8),
            _MiniBar(label: 'Lifestyle', value: compatibility.lifestyle),
          ],
        ),
      ],
    );
  }
}

class _MiniBar extends StatelessWidget {
  final String label;
  final int value;
  const _MiniBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 9, color: IveTokens.ink2)),
              Text('$value%', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: IveTokens.mute)),
            ],
          ),
          const SizedBox(height: 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(IveTokens.rXs),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: IveTokens.hairline,
              valueColor: const AlwaysStoppedAnimation<Color>(kChatSocial),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
class _StatusBadge extends StatelessWidget {
  final HeyYaStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;
    switch (status) {
      case HeyYaStatus.pending:
        text = ' Pending';
        color = IveTokens.warning;
      case HeyYaStatus.accepted:
        text = ' Matched';
        color = IveTokens.success;
      case HeyYaStatus.expired:
        text = ' Expired';
        color = IveTokens.danger;
      case HeyYaStatus.rejected:
        text = ' Passed';
        color = IveTokens.danger;
      case HeyYaStatus.withdrawn:
        text = ' Withdrawn';
        color = IveTokens.mute;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(IveTokens.rSm),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  const _ActionChip({required this.label, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(IveTokens.rSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: IveTokens.hairline2),
          borderRadius: BorderRadius.circular(IveTokens.rSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: IveTokens.moduleQualChat),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: IveTokens.mute),
            ),
          ],
        ),
      ),
    );
  }
}

// 
//  SECTION CARD (titled container)
// 

class QualChatSectionCard extends StatelessWidget {
  final String title;
  final String? trailing;
  final Widget child;
  final VoidCallback? onTrailingTap;

  const QualChatSectionCard({
    super.key,
    required this.title,
    this.trailing,
    required this.child,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IveTokens.surface,
        borderRadius: BorderRadius.circular(IveTokens.rSm),
        border: Border.all(color: IveTokens.hairline2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: IveTokens.ink,
                  ),
                ),
              ),
              if (trailing != null)
                GestureDetector(
                  onTap: onTrailingTap,
                  child: Text(
                    trailing!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: IveTokens.moduleQualChat,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// 
//  EMPTY STATE
// 

class QualChatEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? ctaLabel;
  final VoidCallback? onCta;

  const QualChatEmptyState({
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
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: IveTokens.moduleQualChat.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: IveTokens.ink,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: IveTokens.mute),
              textAlign: TextAlign.center,
            ),
            if (ctaLabel != null) ...[
              const SizedBox(height: 24),
              IveButton.primary(
                label: ctaLabel!,
                onPressed: onCta,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// 
//  CHAT BUBBLE
// 

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;

  const ChatBubble({super.key, required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMine ? IveTokens.accent : IveTokens.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(IveTokens.rSm),
            topRight: const Radius.circular(IveTokens.rSm),
            bottomLeft: Radius.circular(isMine ? 10 : 6),
            bottomRight: Radius.circular(isMine ? 6 : 10),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMine)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  message.senderName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: IveTokens.moduleQualChat,
                  ),
                ),
              ),
            // File attachment
            if (message.type == MessageType.file && message.attachmentName != null)
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: isMine ? IveTokens.accent.withValues(alpha: 0.2) : IveTokens.surfaceRaised,
                  borderRadius: BorderRadius.circular(IveTokens.rSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.attach_file, size: 16,
                        color: isMine ? IveTokens.ink2 : IveTokens.mute),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.attachmentName!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isMine ? IveTokens.ink : IveTokens.ink,
                            ),
                          ),
                          if (message.attachmentSizeMb != null)
                            Text(
                              '${message.attachmentSizeMb} MB',
                              style: TextStyle(
                                fontSize: 11,
                                color: isMine ? IveTokens.ink2 : IveTokens.ink2,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Text(
                message.content,
                style: TextStyle(
                  fontSize: 14,
                  color: isMine ? IveTokens.ink : IveTokens.ink,
                ),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMine ? IveTokens.ink2 : IveTokens.ink2,
                  ),
                ),
                if (isMine) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.status == DeliveryStatus.read
                        ? Icons.done_all
                        : message.status == DeliveryStatus.delivered
                            ? Icons.done_all
                            : Icons.done,
                    size: 14,
                    color: message.status == DeliveryStatus.read
                        ? IveTokens.ink
                        : IveTokens.faint,
                  ),
                ],
                if (message.reactions.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    _reactionEmoji(message.reactions.first),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _reactionEmoji(MessageReaction r) {
    switch (r) {
      case MessageReaction.smile:
        return '';
      case MessageReaction.heart:
        return '';
      case MessageReaction.thumbsUp:
        return '';
      case MessageReaction.fire:
        return '"';
      case MessageReaction.surprised:
        return '';
      case MessageReaction.sad:
        return '';
      case MessageReaction.celebration:
        return '';
    }
  }
}

// 
//  USER LIST ITEM
// 

class UserListItem extends StatelessWidget {
  final ChatUser user;
  final VoidCallback? onTap;
  final Widget? trailing;

  const UserListItem({
    super.key,
    required this.user,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: IveTokens.moduleQualChat.withValues(alpha: 0.1),
            child: Text(
              user.name[0],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: IveTokens.moduleQualChat,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: PresenceDot(status: user.presence, size: 12),
          ),
        ],
      ),
      title: Text(
        user.name,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: IveTokens.ink,
        ),
      ),
      subtitle: Row(
        children: [
          Text(
            user.role,
            style: const TextStyle(fontSize: 12, color: IveTokens.mute),
          ),
          if (user.statusMessage != null) ...[
            const Text('  ', style: TextStyle(fontSize: 12, color: IveTokens.ink2)),
            Flexible(
              child: Text(
                user.statusMessage!,
                style: const TextStyle(fontSize: 12, color: IveTokens.ink2),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
      trailing: trailing,
    );
  }
}

// 
//  MODE TOGGLE
// 

class ModeToggle extends StatelessWidget {
  final ChatMode mode;
  final ValueChanged<ChatMode> onChanged;

  const ModeToggle({super.key, required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: IveTokens.hairline,
        borderRadius: BorderRadius.circular(IveTokens.rSm),
      ),
      child: Row(
        children: [
          _ModeButton(
            label: 'Social',
            isSelected: mode == ChatMode.social,
            color: kChatSocial,
            onTap: () => onChanged(ChatMode.social),
          ),
          _ModeButton(
            label: 'Professional',
            isSelected: mode == ChatMode.professional,
            color: IveTokens.moduleQualChat,
            onTap: () => onChanged(ChatMode.professional),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(IveTokens.rSm),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? IveTokens.ink : IveTokens.mute,
            ),
          ),
        ),
      ),
    );
  }
}

// 
//  HELPERS
// 

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${dt.month}/${dt.day}';
}

String _formatTime(DateTime dt) {
  final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
  final amPm = dt.hour >= 12 ? 'PM' : 'AM';
  return '$hour:${dt.minute.toString().padLeft(2, '0')} $amPm';
}
