/// qualChat Screen 10 — Chat Thread (Enhanced)
/// Immersive conversation: messages, composer, reactions, attachments, header menu
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/design/ive.dart';
import '../models/qualchat_models.dart';
import '../providers/qualchat_provider.dart';
import '../widgets/qualchat_widgets.dart';

class QualChatThreadScreen extends StatefulWidget {
  const QualChatThreadScreen({super.key});

  @override
  State<QualChatThreadScreen> createState() => _QualChatThreadScreenState();
}

class _QualChatThreadScreenState extends State<QualChatThreadScreen> {
  final TextEditingController _messageCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _showAttachments = false;
  // Fold state: collapses chat bubbles → summary card (spec P1, dpThreadFold = 400ms)
  bool _folded = false;

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QualChatProvider>(
      builder: (context, provider, _) {
        final conversation = provider.activeConversation;
        final messages = provider.messages;

        if (conversation == null) {
          return const Scaffold(
            backgroundColor: IveTokens.voidColor,
            appBar: QualChatAppBar(title: 'Chat'),
            body: QualChatEmptyState(
              icon: Icons.chat_bubble_outline,
              title: 'No conversation',
              message: 'Select a conversation to start chatting',
            ),
          );
        }

        return Scaffold(
          backgroundColor: IveTokens.voidColor,
          // Thread Header
          appBar: AppBar(
            backgroundColor: IveTokens.voidColor,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: IveTokens.inkColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                // Avatar with presence dot
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: kChatColor.withValues(alpha: 0.15),
                      child: Text(
                        conversation.title[0].toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w700, color: kChatColor, fontSize: 16),
                      ),
                    ),
                    if (conversation.type == ChatType.individual)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: IveTokens.okColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: IveTokens.voidColor, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation.title,
                        style: IveType.callout.copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        conversation.type == ChatType.group
                            ? '${conversation.participants.length} members'
                            : conversation.typingUser != null
                                ? 'typing…'
                                : 'Online',
                        style: TextStyle(
                          fontSize: 12,
                          color: conversation.typingUser != null ? kChatColor : IveTokens.okColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              // Fold toggle — collapses bubbles to summary card (spec P1)
              IconButton(
                icon: AnimatedSwitcher(
                  duration: AppAnimations.dpStateChange,
                  child: Icon(
                    _folded ? Icons.unfold_more_rounded : Icons.unfold_less_rounded,
                    key: ValueKey(_folded),
                    color: _folded ? kChatColor : IveTokens.muteColor,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() => _folded = !_folded);
                },
              ),
              IconButton(
                icon: const Icon(Icons.call, color: kChatColor, size: 22),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Calling...')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.videocam, color: kChatColor, size: 22),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Starting video call...')),
                  );
                },
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: IveTokens.inkColor),
                onSelected: (value) {
                  switch (value) {
                    case 'search':
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Searching in chat...')),
                      );
                      break;
                    case 'mute':
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifications muted')),
                      );
                      break;
                    case 'pin':
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Conversation pinned')),
                      );
                      break;
                    case 'archive':
                      Navigator.pop(context);
                      break;
                    case 'report':
                      _showReportDialog(context);
                      break;
                    case 'block':
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User blocked')),
                      );
                      break;
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'search', child: Text('Search in chat')),
                  PopupMenuItem(value: 'mute', child: Text('Mute notifications')),
                  PopupMenuItem(value: 'pin', child: Text('Pin conversation')),
                  PopupMenuItem(value: 'archive', child: Text('Archive chat')),
                  PopupMenuDivider(),
                  PopupMenuItem(value: 'report', child: Text('Report')),
                  PopupMenuItem(value: 'block', child: Text('Block user')),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // Messages with fold animation (spec P1, dpThreadFold = 400ms)
              Expanded(
                child: _folded
                    ? _FoldSummaryCard(
                        messages: messages,
                        onUnfold: () => setState(() => _folded = false),
                      )
                    : AnimatedSwitcher(
                        duration: AppAnimations.dpThreadFold,
                        child: messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 64, color: kChatColor.withValues(alpha: 0.3)),
                            const SizedBox(height: 16),
                            Text('Start a conversation', style: IveType.headline),
                            const SizedBox(height: 4),
                            Text('Send a message to begin', style: IveType.caption.copyWith(color: IveTokens.muteColor)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isMe = msg.senderId == 'me';

                          // Date separator
                          Widget? dateSeparator;
                          if (index == 0 ||
                              messages[index].timestamp.day != messages[index - 1].timestamp.day) {
                            dateSeparator = _DateSeparator(date: msg.timestamp);
                          }

                          return Column(
                            children: [
                              if (dateSeparator != null) dateSeparator,
                              ChatBubble(message: msg, isMine: isMe),
                            ],
                          );
                        },
                      ),
                      ),
              ),

              // Attachment panel
              if (_showAttachments)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: IveTokens.raisedColor,
                    border: Border(top: BorderSide(color: IveTokens.hairColor, width: 1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _AttachmentOption(icon: Icons.photo, label: 'Photo', color: IveTokens.okColor, onTap: () => setState(() => _showAttachments = false)),
                      _AttachmentOption(icon: Icons.camera_alt, label: 'Camera', color: kChatColor, onTap: () => setState(() => _showAttachments = false)),
                      _AttachmentOption(icon: Icons.insert_drive_file, label: 'File', color: IveTokens.infoColor, onTap: () => setState(() => _showAttachments = false)),
                      _AttachmentOption(icon: Icons.location_on, label: 'Location', color: IveTokens.warnColor, onTap: () => setState(() => _showAttachments = false)),
                      _AttachmentOption(icon: Icons.contact_phone, label: 'Contact', color: IveTokens.accentColor, onTap: () => setState(() => _showAttachments = false)),
                      _AttachmentOption(icon: Icons.poll, label: 'Poll', color: const Color(0xFFEC4899), onTap: () => setState(() => _showAttachments = false)),
                    ],
                  ),
                ),

              // Smart Composer
              _SmartComposer(
                controller: _messageCtrl,
                onSend: () {
                  if (_messageCtrl.text.trim().isEmpty) return;
                  provider.sendMessage(provider.activeConversationId ?? '', _messageCtrl.text.trim());
                  _messageCtrl.clear();
                },
                onAttachment: () => setState(() => _showAttachments = !_showAttachments),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Report Conversation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ChatReportReason.values.map((reason) {
            final labels = {
              ChatReportReason.spam: 'ðŸš« Spam',
              ChatReportReason.harassment: 'ðŸ˜  Harassment',
              ChatReportReason.inappropriate: 'âš ï¸ Inappropriate Content',
              ChatReportReason.impersonation: 'ðŸŽ­ Impersonation',
              ChatReportReason.other: 'ðŸ“ Other',
            };
            return ListTile(
              title: Text(labels[reason]!, style: const TextStyle(fontSize: 14)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report submitted. We\'ll review it shortly.')),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _DateSeparator extends StatelessWidget {
  final DateTime date;
  const _DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String label;
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      label = 'Today';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
      label = 'Yesterday';
    } else {
      label = '${date.day}/${date.month}/${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider(color: IveTokens.hairColor)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(label, style: IveType.caption.copyWith(color: IveTokens.muteColor, fontWeight: FontWeight.w500)),
          ),
          const Expanded(child: Divider(color: IveTokens.hairColor)),
        ],
      ),
    );
  }
}

/// Fold summary card shown when user collapses the thread (spec P1).
/// Bubbles → summary card with sentiment as one quiet word.
class _FoldSummaryCard extends StatelessWidget {
  final List<dynamic> messages;
  final VoidCallback onUnfold;
  const _FoldSummaryCard({required this.messages, required this.onUnfold});

  String _sentiment() {
    final n = messages.length;
    if (n == 0) return 'quiet';
    if (n >= 30) return 'lively';
    if (n >= 15) return 'active';
    if (n >= 6) return 'warm';
    if (n >= 2) return 'light';
    return 'quiet';
  }

  @override
  Widget build(BuildContext context) {
    final recent = messages.reversed.take(3).toList().reversed.toList();
    return GestureDetector(
      onTap: onUnfold,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: IveTokens.raisedColor,
          borderRadius: BorderRadius.circular(IveTokens.rContainer),
          border: Border.all(color: kChatColor.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.unfold_more_rounded, size: 14, color: kChatColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${messages.length} messages',
                    style: IveType.caption.copyWith(fontWeight: FontWeight.w600, color: kChatColor),
                  ),
                ),
                // Sentiment — one quiet word (spec P1)
                Text(_sentiment(), style: IveType.caption.copyWith(color: IveTokens.muteColor)),
              ],
            ),
            const SizedBox(height: 10),
            ...recent.map((msg) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                msg.content ?? '',
                style: IveType.caption.copyWith(color: IveTokens.ink2Color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )),
            const SizedBox(height: 4),
            Text('Expand', style: IveType.caption.copyWith(color: IveTokens.muteColor)),
          ],
        ),
      ),
    );
  }
}

class _SmartComposer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttachment;
  const _SmartComposer({required this.controller, required this.onSend, required this.onAttachment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      decoration: const BoxDecoration(
        color: IveTokens.raisedColor,
        border: Border(top: BorderSide(color: IveTokens.hairColor, width: 1)),
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Attachment button
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: kChatColor, size: 26),
              onPressed: onAttachment,
            ),
            // Text field
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: IveTokens.surfaceColor,
                  borderRadius: BorderRadius.circular(IveTokens.rChip),
                  border: Border.all(color: IveTokens.hairColor, width: 1),
                ),
                child: TextField(
                  controller: controller,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: IveType.body,
                  cursorColor: kChatColor,
                  decoration: InputDecoration(
                    hintText: 'Message',
                    hintStyle: IveType.body.copyWith(color: IveTokens.muteColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            // Emoji
            IconButton(
              icon: const Icon(Icons.emoji_emotions_outlined, color: IveTokens.muteColor),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reaction added')),
                );
              },
            ),
            // Send / Voice
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (_, value, __) {
                final hasText = value.text.trim().isNotEmpty;
                return GestureDetector(
                  onTap: hasText ? onSend : null,
                  onLongPress: hasText ? null : () {/* voice recording */},
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: hasText ? kChatColor : IveTokens.surfaceColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasText ? Icons.send_rounded : Icons.mic_none_rounded,
                      size: 20,
                      color: hasText ? IveTokens.inkColor : IveTokens.muteColor,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _AttachmentOption({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 6),
          Text(label, style: IveType.caption.copyWith(color: IveTokens.muteColor)),
        ],
      ),
    );
  }
}
