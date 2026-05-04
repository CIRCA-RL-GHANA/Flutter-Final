import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../widgets/updates_widgets.dart';

class UpdatesSocialFeedScreen extends StatefulWidget {
  const UpdatesSocialFeedScreen({Key? key}) : super(key: key);

  @override
  State<UpdatesSocialFeedScreen> createState() =>
      _UpdatesSocialFeedScreenState();
}

class _UpdatesSocialFeedScreenState extends State<UpdatesSocialFeedScreen> {
  final updates = [
    {
      'author': 'Tech Daily',
      'avatar': 'TD',
      'content': 'Just launched our new AI features! Check them out and let us know what you think.',
      'image': null,
      'likes': 1284,
      'comments': 342,
      'shares': 156,
      'time': '2 hours ago',
    },
    {
      'author': 'Jane Developer',
      'avatar': 'JD',
      'content': 'Finally shipped the new dashboard redesign. Took 3 months but it was worth it!',
      'image': null,
      'likes': 892,
      'comments': 234,
      'shares': 89,
      'time': '4 hours ago',
    },
    {
      'author': 'Community Team',
      'avatar': 'CT',
      'content': 'Thank you all for 50K members! We\'re so grateful for this amazing community.',
      'image': null,
      'likes': 3456,
      'comments': 567,
      'shares': 892,
      'time': '6 hours ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Updates'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Consumer<AIInsightsNotifier>(
            builder: (context, ai, _) {
              if (ai.insights.isEmpty) return const SizedBox.shrink();
              return Container(
                color: kUpdatesColor.withOpacity(0.07),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(children: [
                  const Icon(Icons.auto_awesome, size: 14, color: kUpdatesColor),
                  const SizedBox(width: 8),
                  Expanded(child: Text('AI: ${ai.insights.first['title'] ?? ''}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kUpdatesColor),
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
              );
            },
          ),
          Expanded(child: ListView.separated(
            itemCount: updates.length + 1,
        separatorBuilder: (context, index) => const Divider(height: 0),
        itemBuilder: (context, index) {
          if (index == 0) {
            // Compose section at top
            return Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[50],
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue[300],
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Share an update...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final update = updates[index - 1];
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author info
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue[300],
                      child: Text(
                        update['avatar'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          update['author'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          update['time'] as String,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.more_horiz),
                      onPressed: () {},
                      iconSize: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Content
                Text(update['content'] as String),
                const SizedBox(height: 12),
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ActionButton(
                      icon: Icons.favorite_border,
                      label: '${update['likes']}',
                    ),
                    _ActionButton(
                      icon: Icons.comment_outlined,
                      label: '${update['comments']}',
                    ),
                    _ActionButton(
                      icon: Icons.share_outlined,
                      label: '${update['shares']}',
                    ),
                  ],
                ),
              ],
            ),
          );
        },
          )),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionButton({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }
}
