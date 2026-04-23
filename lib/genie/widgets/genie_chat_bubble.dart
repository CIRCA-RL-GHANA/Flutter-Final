/// ═══════════════════════════════════════════════════════════════════════════
/// GenieChatBubble – Individual Message Bubble in the Conversation Thread
/// Handles user bubbles (right-aligned) and Genie bubbles (left-aligned).
/// Supports swipe-to-dismiss and swipe-to-act gestures.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../genie_intent.dart';
import '../genie_tactile_actions.dart';
import 'genie_inline_card.dart';

class GenieChatBubble extends StatefulWidget {
  final GenieMessage message;
  final VoidCallback? onDismiss;
  final VoidCallback? onPrimaryAction;

  const GenieChatBubble({
    super.key,
    required this.message,
    this.onDismiss,
    this.onPrimaryAction,
  });

  @override
  State<GenieChatBubble> createState() => _GenieChatBubbleState();
}

class _GenieChatBubbleState extends State<GenieChatBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fadeAnim = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: widget.message.isUser
          ? const Offset(0.08, 0)
          : const Offset(-0.08, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic));

    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Dismissible(
          key: ValueKey(widget.message.id),
          direction: widget.message.isUser
              ? DismissDirection.none
              : DismissDirection.horizontal,
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              await GenieTactileActions.onTap();
              widget.onDismiss?.call();
              return false; // Don't remove from list; parent handles it
            }
            if (direction == DismissDirection.startToEnd) {
              await GenieTactileActions.onSuccess();
              widget.onPrimaryAction?.call();
              return false;
            }
            return false;
          },
          background: _SwipeBackground(
            color: AppColors.success.withOpacity(0.15),
            icon: Icons.check,
            alignment: Alignment.centerLeft,
          ),
          secondaryBackground: _SwipeBackground(
            color: AppColors.textTertiary.withOpacity(0.15),
            icon: Icons.close,
            alignment: Alignment.centerRight,
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: widget.message.isUser ? 52 : 8,
              right: widget.message.isUser ? 8 : 52,
              bottom: 8,
            ),
            child: Row(
              mainAxisAlignment: widget.message.isUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!widget.message.isUser) ...[
                  _GenieAvatar(),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: widget.message.cardType == GenieCardType.text ||
                          widget.message.cardType == GenieCardType.greeting
                      ? _TextBubble(message: widget.message)
                      : _CardBubble(message: widget.message),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Text Bubble ─────────────────────────────────────────────────────────────
class _TextBubble extends StatelessWidget {
  final GenieMessage message;
  const _TextBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isUser ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isUser ? 18 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: isUser
            ? null
            : Border.all(color: AppColors.inputBorder, width: 0.5),
      ),
      child: Text(
        message.text ?? '',
        style: TextStyle(
          fontSize: 14,
          height: 1.45,
          color: isUser ? Colors.white : AppColors.textPrimary,
        ),
      ),
    );
  }
}

// ─── Card Bubble (wraps inline card) ─────────────────────────────────────────
class _CardBubble extends StatelessWidget {
  final GenieMessage message;
  const _CardBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.text != null && message.text!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 4),
            child: Text(
              message.text!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        GenieInlineCard(message: message),
      ],
    );
  }
}

// ─── Genie Avatar ─────────────────────────────────────────────────────────────
class _GenieAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.accent, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
    );
  }
}

// ─── Swipe Background ─────────────────────────────────────────────────────────
class _SwipeBackground extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Alignment alignment;

  const _SwipeBackground({
    required this.color,
    required this.icon,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(icon, color: AppColors.textSecondary),
    );
  }
}
