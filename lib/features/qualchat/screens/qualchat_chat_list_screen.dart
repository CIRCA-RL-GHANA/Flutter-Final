/// qualChat Screen 8 — Chat List (Enhanced)
/// Smart inbox: tabs, pinned, search, swipe actions, FAB

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/qualchat_models.dart';
import '../providers/qualchat_provider.dart';
import '../widgets/qualchat_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class QualChatChatListScreen extends StatelessWidget {
  const QualChatChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QualChatProvider>(
      builder: (context, provider, _) {
        final pinned = provider.pinnedConversations;
        final unpinned = provider.unpinnedConversations;
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: QualChatAppBar(
            title: 'Messages',
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                onSelected: (_) {},
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'pinned', child: Text('📌 Pinned')),
                  PopupMenuItem(value: 'online', child: Text('🟢 Online')),
                  PopupMenuItem(value: 'unread', child: Text('💬 Unread')),
                  PopupMenuItem(value: 'recent', child: Text('⏰ Recent')),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // Tabs
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: ChatListTab.values.map((tab) {
                    final isSelected = provider.chatTab == tab;
                    final labels = {
                      ChatListTab.all: 'All',
                      ChatListTab.unread: 'Unread 🔵',
                      ChatListTab.priority: 'Priority ⚠️',
                      ChatListTab.groups: 'Groups',
                    };
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => provider.setChatTab(tab),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? kChatColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            labels[tab]!,
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
                  }).toList(),
                ),
              ),

              // AI priority hint
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: kChatColor.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 13, color: kChatColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'AI: ${ai.insights.first['title'] ?? ''}',
                            style: const TextStyle(fontSize: 12, color: kChatColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  onChanged: provider.setChatSearch,
                  decoration: InputDecoration(
                    hintText: 'Search conversations...',
                    hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              // Conversation list
              Expanded(
                child: provider.filteredConversations.isEmpty
                    ? const QualChatEmptyState(
                        icon: Icons.chat_bubble_outline,
                        title: 'No conversations',
                        message: 'Your inbox is empty 💫\nStart your first chat!',
                        ctaLabel: '✨ New Chat',
                      )
                    : RefreshIndicator(
                        color: kChatColor,
                        onRefresh: () async {},
                        child: ListView(
                          children: [
                            // Pinned
                            if (pinned.isNotEmpty) ...[
                              _SectionHeader(title: '📌 PINNED', count: pinned.length),
                              ...pinned.map((c) => _SwipeableConversation(
                                conversation: c,
                                onTap: () {
                                  provider.openConversation(c.id);
                                  Navigator.pushNamed(context, '/qualchat/thread');
                                },
                              )),
                            ],
                            // Recent
                            if (unpinned.isNotEmpty) ...[
                              _SectionHeader(title: '💬 RECENT CONVERSATIONS', count: unpinned.length),
                              ...unpinned.where((c) => c.type == ChatType.individual).map((c) =>
                                _SwipeableConversation(
                                  conversation: c,
                                  onTap: () {
                                    provider.openConversation(c.id);
                                    Navigator.pushNamed(context, '/qualchat/thread');
                                  },
                                ),
                              ),
                            ],
                            // Groups
                            if (unpinned.where((c) => c.type == ChatType.group).isNotEmpty) ...[
                              _SectionHeader(
                                title: '👥 GROUPS',
                                count: unpinned.where((c) => c.type == ChatType.group).length,
                              ),
                              ...unpinned.where((c) => c.type == ChatType.group).map((c) =>
                                _SwipeableConversation(
                                  conversation: c,
                                  onTap: () {
                                    provider.openConversation(c.id);
                                    Navigator.pushNamed(context, '/qualchat/thread');
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.pushNamed(context, '/qualchat/new-chat'),
            backgroundColor: kChatColor,
            child: const Icon(Icons.chat, color: Colors.white),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        '$title ($count)',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6B7280),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SwipeableConversation extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const _SwipeableConversation({required this.conversation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(conversation.id),
      background: Container(
        color: kChatColor,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.archive, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: const Color(0xFFEF4444),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete Chat'),
              content: const Text('Are you sure you want to delete this conversation?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
                ),
              ],
            ),
          );
        }
        return true; // archive
      },
      child: ConversationCard(
        conversation: conversation,
        onTap: onTap,
      ),
    );
  }
}
