/// ═══════════════════════════════════════════════════════════════════════════
/// qualChat Widget (Communications Hub)
/// Visible to: ALL roles (with Owner-only HeyYa section)
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/rbac_models.dart';

class QualChatWidgetContent extends StatelessWidget {
  final UserRole role;

  const QualChatWidgetContent({
    super.key,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final color = RoleColors.forModule(PromptModule.qualChat);
    final showHeyYa = WidgetVisibility.canSeeHeyYa(role);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.chat_bubble, size: 18, color: color),
              const SizedBox(width: 6),
              const Text(
                'qualChat',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              // Quick compose
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.edit, size: 14, color: color),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Presence Dashboard
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const _PresenceStat(label: 'Active', count: 92, color: AppColors.success),
                const _PresenceStat(label: 'Idle', count: 28, color: AppColors.warning),
                const _PresenceStat(label: 'Offline', count: 8, color: AppColors.textTertiary),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Recent Chats
          _ChatPreview(
            name: 'Alice',
            message: 'Payment confirmed ✓',
            time: '2m',
            unread: 2,
            color: color,
          ),
          const SizedBox(height: 4),
          _ChatPreview(
            name: 'Bob',
            message: 'Typing...',
            time: '5m',
            unread: 0,
            color: color,
            isTyping: true,
          ),

          const Spacer(),

          // Owner-Only: HeyYa Section
          if (showHeyYa)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF6B6B).withOpacity(0.08),
                    const Color(0xFFFF8E8E).withOpacity(0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFFF6B6B).withOpacity(0.15),
                ),
              ),
              child: Row(
                children: [
                  const Text('💘', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'HeyYa Vibe Check',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFF6B6B),
                          ),
                        ),
                        const Text(
                          '5 Sparks • 2 Matches',
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PresenceStat extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _PresenceStat({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 3),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ChatPreview extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final int unread;
  final Color color;
  final bool isTyping;

  const _ChatPreview({
    required this.name,
    required this.message,
    required this.time,
    this.unread = 0,
    required this.color,
    this.isTyping = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: color.withOpacity(0.15),
            child: Text(
              name[0],
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 10,
                    color: isTyping ? color : AppColors.textTertiary,
                    fontStyle: isTyping ? FontStyle.italic : FontStyle.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time, style: const TextStyle(fontSize: 9, color: AppColors.textTertiary)),
              if (unread > 0) ...[
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                  child: Text(
                    '$unread',
                    style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
