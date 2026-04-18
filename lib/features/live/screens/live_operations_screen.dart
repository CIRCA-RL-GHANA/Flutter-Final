import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LiveOperationsScreen extends ConsumerStatefulWidget {
  const LiveOperationsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LiveOperationsScreen> createState() =>
      _LiveOperationsScreenState();
}

class _LiveOperationsScreenState extends ConsumerState<LiveOperationsScreen> {
  final liveEvents = [
    {
      'title': 'Flash Sale Live Now!',
      'subtitle': 'Up to 50% off electronics',
      'icon': Icons.flash_on,
      'time': 'Just now',
      'participants': '2.3K viewing',
    },
    {
      'title': 'New Product Launch',
      'subtitle': 'Latest AI-powered tools',
      'icon': Icons.new_releases,
      'time': '5 min ago',
      'participants': '1.2K viewing',
    },
    {
      'title': 'Live Q&A Session',
      'subtitle': 'Ask our team anything',
      'icon': Icons.help,
      'time': '15 min ago',
      'participants': '856 viewing',
    },
    {
      'title': 'Exclusive Webinar',
      'subtitle': 'Expert tips and tricks',
      'icon': Icons.present_to_all,
      'time': '1 hour ago',
      'participants': 'Recording available',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LIVE'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: liveEvents.length,
        itemBuilder: (context, index) {
          final event = liveEvents[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: index % 2 == 0
                      ? [Colors.purple[100]!, Colors.blue[100]!]
                      : [Colors.orange[100]!, Colors.pink[100]!],
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: index % 2 == 0 ? Colors.purple[300] : Colors.orange[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    event['icon'] as IconData,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                title: Text(
                  event['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(event['subtitle'] as String),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          event['time'] as String,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.people, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          event['participants'] as String,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Icon(
                  Icons.play_arrow,
                  color: Colors.blue[700],
                  size: 28,
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening ${event['title'] as String}...')),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Start your own LIVE session')),
          );
        },
        child: const Icon(Icons.videocam),
      ),
    );
  }
}
