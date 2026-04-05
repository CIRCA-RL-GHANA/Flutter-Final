import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thepg/core/providers/service_providers.dart';

class PromptDashboardScreen extends ConsumerStatefulWidget {
  const PromptDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PromptDashboardScreen> createState() =>
      _PromptDashboardScreenState();
}

class _PromptDashboardScreenState extends ConsumerState<PromptDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatService = ref.watch(chatServiceProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('PROMPT Genie'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Messages'),
            Tab(text: 'Contacts'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Messages Tab
          FutureBuilder(
            future: chatService.getConversations(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final conversations = snapshot.data ?? [];

              return conversations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.chat, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No conversations yet'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/chat/new');
                            },
                            child: const Text('Start a new conversation'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = conversations[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              (conversation['participantAvatar'] as String?) ?? '',
                            ),
                          ),
                          title: Text((conversation['participantName'] as String?) ?? 'Unknown'),
                          subtitle: Text(
                            (conversation['lastMessage'] as String?) ?? 'No messages yet',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            (conversation['lastMessageTime'] as String?) ?? '',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamed('/chat/${conversation['id']}');
                          },
                        );
                      },
                    );
            },
          ),
          
          // Contacts Tab
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Contacts feature coming soon'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feature in development')),
                    );
                  },
                  child: const Text('View Contacts'),
                ),
              ],
            ),
          ),

          // Settings Tab
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                title: const Text('Notifications'),
                subtitle: const Text('Manage notification settings'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  // Navigate to notifications settings
                },
              ),
              ListTile(
                title: const Text('Privacy'),
                subtitle: const Text('Control your privacy settings'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  // Navigate to privacy settings
                },
              ),
              ListTile(
                title: const Text('About'),
                subtitle: const Text('Learn about PROMPT Genie'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  // Navigate to about page
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
