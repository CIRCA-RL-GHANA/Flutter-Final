import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../models/qualchat_models.dart';
import '../providers/qualchat_provider.dart';
import '../widgets/qualchat_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class QualChatDashboardScreen extends StatefulWidget {
  const QualChatDashboardScreen({super.key});

  @override
  State<QualChatDashboardScreen> createState() => _QualChatDashboardScreenState();
}

class _QualChatDashboardScreenState extends State<QualChatDashboardScreen> {
  late TextEditingController _searchController;
  bool _isLoading = false;
  String _error = '';
  List<Conversation> _conversations = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadConversations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final provider = context.read<QualChatProvider>();
      _conversations = await provider.loadConversations();
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  void _handleConversationTap(Conversation conversation) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QualChatThreadScreen(conversation: conversation),
      ),
    );
  }

  void _handleNewChat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const QualChatNewChatScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: QualChatAppBar(
        title: 'QualChat',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF1A1A1A)),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const QualChatSettingsScreen(),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleNewChat,
        backgroundColor: kChatColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _conversations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty && _conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadConversations,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadConversations,
      child: Column(
        children: [
          Consumer<AIInsightsNotifier>(
            builder: (context, ai, _) {
              if (ai.insights.isEmpty) return const SizedBox.shrink();
              return Container(
                color: kChatColor.withOpacity(0.07),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(children: [
                  const Icon(Icons.auto_awesome, size: 14, color: kChatColor),
                  const SizedBox(width: 8),
                  Expanded(child: Text('AI: ${ai.insights.first['title'] ?? ''}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kChatColor),
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
              );
            },
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) async {
                if (value.isEmpty) {
                  await _loadConversations();
                } else {
                  final provider = context.read<QualChatProvider>();
                  final results = await provider.searchConversations(value);
                  setState(() => _conversations = results);
                }
              },
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          _loadConversations();
                        },
                        child: const Icon(Icons.clear, color: Color(0xFF9CA3AF)),
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Conversations list
          Expanded(
            child: _conversations.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No conversations yet'),
                        SizedBox(height: 8),
                        Text(
                          'Start a new chat to begin messaging',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _conversations.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final conversation = _conversations[index];
                      return _ConversationTile(
                        conversation: conversation,
                        onTap: () => _handleConversationTap(conversation),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: kChatColor.withOpacity(0.1),
        child: Text(
          conversation.title[0].toUpperCase(),
          style: const TextStyle(
            color: kChatColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        conversation.title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        conversation.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTime(conversation.lastMessageTime),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (conversation.unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: kChatColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${conversation.unreadCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.month}/${time.day}';
    }
  }
}
