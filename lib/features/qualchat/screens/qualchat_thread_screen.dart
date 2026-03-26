/// qualChat Screen 10 — Chat Thread (Enhanced)
/// Immersive conversation: messages, composer, reactions, attachments, header menu

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/qualchat_models.dart';
import '../providers/qualchat_provider.dart';
import '../widgets/qualchat_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class QualChatThreadScreen extends StatefulWidget {
  const QualChatThreadScreen({super.key});

  @override
  State<QualChatThreadScreen> createState() => _QualChatThreadScreenState();
}

class _QualChatThreadScreenState extends State<QualChatThreadScreen> {
  final TextEditingController _messageCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _showAttachments = false;

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
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FE),
            appBar: const QualChatAppBar(title: 'Chat'),
            body: const QualChatEmptyState(
              icon: Icons.chat_bubble_outline,
              title: 'No conversation',
              message: 'Select a conversation to start chatting',
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF1F5F9),
          // Thread Header
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                // Avatar with presence
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: kChatColor.withOpacity(0.15),
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
                            color: const Color(0xFF10B981),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
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
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        conversation.type == ChatType.group
                            ? '${conversation.participants.length} members'
                            : conversation.typingUser != null
                                ? 'typing...'
                                : 'Online',
                        style: TextStyle(
                          fontSize: 12,
                          color: conversation.typingUser != null ? kChatColor : const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.call, color: kChatColor, size: 22),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.videocam, color: kChatColor, size: 22),
                onPressed: () {},
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Color(0xFF1A1A1A)),
                onSelected: (value) {
                  switch (value) {
                    case 'search':
                      break;
                    case 'mute':
                      break;
                    case 'pin':
                      break;
                    case 'archive':
                      Navigator.pop(context);
                      break;
                    case 'report':
                      _showReportDialog(context);
                      break;
                    case 'block':
                      break;
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'search', child: Text('🔍 Search in Chat')),
                  PopupMenuItem(value: 'mute', child: Text('🔇 Mute Notifications')),
                  PopupMenuItem(value: 'pin', child: Text('📌 Pin Conversation')),
                  PopupMenuItem(value: 'archive', child: Text('📦 Archive Chat')),
                  PopupMenuDivider(),
                  PopupMenuItem(value: 'report', child: Text('🚩 Report')),
                  PopupMenuItem(value: 'block', child: Text('🚫 Block User')),
                ],
              ),
            ],
          ),
          body: Consumer<AIInsightsNotifier>(
            builder: (context, aiNotifier, _) => Column(
            children: [
              // AI Conversation Sentiment Banner
              if (aiNotifier.insights.isNotEmpty)
                _AISentimentBanner(insight: aiNotifier.insights.first),
              // Messages
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 64, color: kChatColor.withOpacity(0.3)),
                            const SizedBox(height: 16),
                            const Text(
                              'Start a conversation! 💬',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Send a message to begin',
                              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                            ),
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

              // Attachment panel
              if (_showAttachments)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _AttachmentOption(icon: Icons.photo, label: 'Photo', color: const Color(0xFF10B981), onTap: () => setState(() => _showAttachments = false)),
                      _AttachmentOption(icon: Icons.camera_alt, label: 'Camera', color: kChatColor, onTap: () => setState(() => _showAttachments = false)),
                      _AttachmentOption(icon: Icons.insert_drive_file, label: 'File', color: const Color(0xFF3B82F6), onTap: () => setState(() => _showAttachments = false)),
                      _AttachmentOption(icon: Icons.location_on, label: 'Location', color: const Color(0xFFF59E0B), onTap: () => setState(() => _showAttachments = false)),
                      _AttachmentOption(icon: Icons.contact_phone, label: 'Contact', color: const Color(0xFF8B5CF6), onTap: () => setState(() => _showAttachments = false)),
                      _AttachmentOption(icon: Icons.poll, label: 'Poll', color: const Color(0xFFEC4899), onTap: () => setState(() => _showAttachments = false)),
                    ],
                  ),
                ),

              // AI Smart Reply Strip
              if (aiNotifier.recommendations.isNotEmpty)
                _AISmartReplyStrip(
                  suggestions: aiNotifier.recommendations
                      .take(3)
                      .map((r) => r.name)
                      .toList(),
                  onTap: (text) {
                    _messageCtrl.text = text;
                    _messageCtrl.selection = TextSelection.fromPosition(
                      TextPosition(offset: text.length),
                    );
                  },
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
              ChatReportReason.spam: '🚫 Spam',
              ChatReportReason.harassment: '😠 Harassment',
              ChatReportReason.inappropriate: '⚠️ Inappropriate Content',
              ChatReportReason.impersonation: '🎭 Impersonation',
              ChatReportReason.other: '📝 Other',
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

class _AISentimentBanner extends StatelessWidget {
  final dynamic insight;
  const _AISentimentBanner({required this.insight});

  @override
  Widget build(BuildContext context) {
    final label = insight?.label as String? ?? '';
    final type = insight?.type as String? ?? '';
    final emoji = type == 'positive' ? '😊' : type == 'negative' ? '😟' : '🤝';
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      color: kChatColor.withOpacity(0.06),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'AI: $label',
              style: const TextStyle(fontSize: 12, color: kChatColor, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _AISmartReplyStrip extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onTap;
  const _AISmartReplyStrip({required this.suggestions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => onTap(suggestions[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: kChatColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kChatColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, size: 12, color: kChatColor),
                const SizedBox(width: 4),
                Text(
                  suggestions[i],
                  style: const TextStyle(fontSize: 12, color: kChatColor, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
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
          Expanded(child: Divider(color: Colors.grey.shade300)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade500),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
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
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, -2))],
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
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: controller,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            // Emoji
            IconButton(
              icon: const Icon(Icons.emoji_emotions_outlined, color: Color(0xFF6B7280)),
              onPressed: () {},
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
                      color: hasText ? kChatColor : const Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasText ? Icons.send : Icons.mic,
                      size: 20,
                      color: hasText ? Colors.white : const Color(0xFF6B7280),
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
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
