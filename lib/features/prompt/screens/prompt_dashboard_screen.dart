import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thepg/core/providers/service_providers.dart';
import 'package:thepg/core/routes/app_routes.dart';

class PromptDashboardScreen extends ConsumerStatefulWidget {
  const PromptDashboardScreen({super.key});

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
        title: const Text('genie help'),
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

              // getConversations() returns ApiResponse — unwrap .data for the list.
              final conversations = snapshot.data?.data ?? [];

              return conversations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No conversations yet'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.qualChatNewChat),
                            child: const Text('Start a new conversation'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = conversations[index];
                        final avatarUrl = (conversation['participantAvatar'] as String?) ?? '';
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                            child: avatarUrl.isEmpty
                                ? const Icon(Icons.person, color: Colors.grey)
                                : null,
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
                          onTap: () => Navigator.pushNamed(context, AppRoutes.qualChatDashboard),
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
                Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text(
                  'Contacts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your contacts will appear here once\nthe feature becomes available.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
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
                onTap: () => Navigator.pushNamed(context, AppRoutes.utilityNotifications),
              ),
              ListTile(
                title: const Text('Privacy'),
                subtitle: const Text('Control your privacy settings'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () => Navigator.pushNamed(context, AppRoutes.utilityPrivacy),
              ),
              ListTile(
                title: const Text('About'),
                subtitle: const Text('Learn about genie help'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'genie help',
                  applicationVersion: '1.0',
                  applicationLegalese: '© 2026 CIRCA-RL. All rights reserved.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
