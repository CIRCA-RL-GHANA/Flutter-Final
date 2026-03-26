/// qualChat Module — Shared Widgets
/// Reusable UI components for all qualChat screens
/// Module Color: Cyan 0xFF06B6D4

import 'package:flutter/material.dart';
import '../models/qualchat_models.dart';

// ──────────────────────────────────────────────
//  MODULE COLORS
// ──────────────────────────────────────────────

const Color kChatColor = Color(0xFF06B6D4);
const Color kChatColorLight = Color(0xFFCFFAFE);
const Color kChatColorDark = Color(0xFF0E7490);
const Color kChatAccent = Color(0xFFEC4899);
const Color kChatSocial = Color(0xFFEC4899);

// ──────────────────────────────────────────────
//  APP BAR
// ──────────────────────────────────────────────

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
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1A1A1A),
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
              color: kChatColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
      actions: actions,
    );
  }
}

// ──────────────────────────────────────────────
//  PRESENCE DOT
// ──────────────────────────────────────────────

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
        border: Border.all(color: Colors.white, width: 1.5),
      ),
    );
  }

  Color get _color {
    switch (status) {
      case PresenceStatus.online:
        return const Color(0xFF10B981);
      case PresenceStatus.idle:
        return const Color(0xFFF59E0B);
      case PresenceStatus.offline:
        return const Color(0xFFEF4444);
    }
  }
}

// ──────────────────────────────────────────────
//  PRESENCE STAT CARD
// ──────────────────────────────────────────────

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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 4),
              PresenceDot(status: status),
              if (changePercent != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${changePercent! >= 0 ? '+' : ''}${changePercent!.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: changePercent! >= 0
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
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

// ──────────────────────────────────────────────
//  CONVERSATION CARD
// ──────────────────────────────────────────────

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
          color: c.unreadCount > 0 ? kChatColorLight.withOpacity(0.3) : Colors.white,
          border: const Border(
            bottom: BorderSide(color: Color(0xFFF3F4F6)),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: kChatColor.withOpacity(0.1),
                  child: Text(
                    c.title.isNotEmpty ? c.title[0] : '?',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: kChatColor,
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
                            color: const Color(0xFF1A1A1A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _timeAgo(c.lastMessageTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: c.unreadCount > 0
                              ? kChatColor
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (c.typingUser != null) ...[
                        Icon(Icons.edit, size: 14, color: kChatColor),
                        const SizedBox(width: 4),
                        Text(
                          '${c.typingUser} is typing...',
                          style: const TextStyle(
                            fontSize: 13,
                            color: kChatColor,
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
                                  ? const Color(0xFF1A1A1A)
                                  : const Color(0xFF6B7280),
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
                            color: kChatColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${c.unreadCount}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
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
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (c.isPinned)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.push_pin, size: 14, color: Color(0xFF9CA3AF)),
              ),
            if (c.isMuted)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.volume_off, size: 14, color: Color(0xFF9CA3AF)),
              ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  HEY YA CARD
// ──────────────────────────────────────────────

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: kChatSocial.withOpacity(0.1),
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
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '🏙️ ${r.person.role} • ${r.person.distanceKm?.toStringAsFixed(0) ?? '?'}km away',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                // Match badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kChatSocial.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '💘 ${r.matchPercentage}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: kChatSocial,
                    ),
                  ),
                ),
              ],
            ),
            // Message
            if (r.message != null) ...[
              const SizedBox(height: 12),
              Text(
                '💬 "${r.message}"',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
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
                  '⏰ ${r.isSentByMe ? "Sent" : "Received"} ${_timeAgo(r.sentAt)}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Actions
            Row(
              children: [
                _ActionChip(label: 'View Timeline', icon: Icons.timeline, onTap: onTimeline),
                const SizedBox(width: 8),
                _ActionChip(label: 'Follow Up', icon: Icons.send, onTap: onFollowUp),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: Color(0xFF9CA3AF)),
                  onPressed: onOptions,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  iconSize: 20,
                ),
              ],
            ),
          ],
        ),
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
        text = '🟡 Pending';
        color = const Color(0xFFF59E0B);
      case HeyYaStatus.accepted:
        text = '💚 Accepted';
        color = const Color(0xFF10B981);
      case HeyYaStatus.expired:
        text = '🔴 Expired';
        color = const Color(0xFFEF4444);
      case HeyYaStatus.rejected:
        text = '❌ Rejected';
        color = const Color(0xFFEF4444);
      case HeyYaStatus.withdrawn:
        text = '↩️ Withdrawn';
        color = const Color(0xFF6B7280);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: kChatColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  SECTION CARD (titled container)
// ──────────────────────────────────────────────

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
                    color: Color(0xFF1A1A1A),
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
                      color: kChatColor,
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

// ──────────────────────────────────────────────
//  EMPTY STATE
// ──────────────────────────────────────────────

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
            Icon(icon, size: 64, color: kChatColor.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
            if (ctaLabel != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onCta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kChatColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
                child: Text(ctaLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  CHAT BUBBLE
// ──────────────────────────────────────────────

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
          color: isMine ? kChatColor : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
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
                    color: kChatColorDark,
                  ),
                ),
              ),
            // File attachment
            if (message.type == MessageType.file && message.attachmentName != null)
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: isMine ? Colors.white.withOpacity(0.2) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.attach_file, size: 16,
                        color: isMine ? Colors.white70 : const Color(0xFF6B7280)),
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
                              color: isMine ? Colors.white : const Color(0xFF1A1A1A),
                            ),
                          ),
                          if (message.attachmentSizeMb != null)
                            Text(
                              '${message.attachmentSizeMb} MB',
                              style: TextStyle(
                                fontSize: 11,
                                color: isMine ? Colors.white60 : const Color(0xFF9CA3AF),
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
                  color: isMine ? Colors.white : const Color(0xFF1A1A1A),
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
                    color: isMine ? Colors.white60 : const Color(0xFF9CA3AF),
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
                        ? Colors.white
                        : Colors.white60,
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
        return '😊';
      case MessageReaction.heart:
        return '❤️';
      case MessageReaction.thumbsUp:
        return '👍';
      case MessageReaction.fire:
        return '🔥';
      case MessageReaction.surprised:
        return '😮';
      case MessageReaction.sad:
        return '😢';
      case MessageReaction.celebration:
        return '🎉';
    }
  }
}

// ──────────────────────────────────────────────
//  USER LIST ITEM
// ──────────────────────────────────────────────

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
            backgroundColor: kChatColor.withOpacity(0.1),
            child: Text(
              user.name[0],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: kChatColor,
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
          color: Color(0xFF1A1A1A),
        ),
      ),
      subtitle: Row(
        children: [
          Text(
            user.role,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          if (user.statusMessage != null) ...[
            const Text(' • ', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
            Flexible(
              child: Text(
                user.statusMessage!,
                style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
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

// ──────────────────────────────────────────────
//  MODE TOGGLE
// ──────────────────────────────────────────────

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
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _ModeButton(
            label: 'Social 💖',
            isSelected: mode == ChatMode.social,
            color: kChatSocial,
            onTap: () => onChanged(ChatMode.social),
          ),
          _ModeButton(
            label: 'Professional 💼',
            isSelected: mode == ChatMode.professional,
            color: kChatColor,
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
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  HELPERS
// ──────────────────────────────────────────────

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
