import 'package:flutter/material.dart';

class Alert {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime timestamp;
  final bool isRead;

  Alert({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.isRead,
  });
}

class AlertsDashboard extends StatefulWidget {
  const AlertsDashboard({Key? key}) : super(key: key);

  @override
  State<AlertsDashboard> createState() => _AlertsDashboardState();
}

class _AlertsDashboardState extends State<AlertsDashboard> {
  final alerts = [
    Alert(
      id: '1',
      title: 'Order Shipped',
      message: 'Your order #ORD001 has been shipped',
      type: 'order',
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
      isRead: false,
    ),
    Alert(
      id: '2',
      title: 'Payment Received',
      message: 'Payment of \$329.97 confirmed',
      type: 'payment',
      timestamp: DateTime.now().subtract(Duration(hours: 5)),
      isRead: false,
    ),
    Alert(
      id: '3',
      title: 'Security Alert',
      message: 'New login from Chrome on Windows',
      type: 'security',
      timestamp: DateTime.now().subtract(Duration(days: 1)),
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alerts'), elevation: 0),
      body: ListView.builder(
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: alert.type == 'order'
                  ? Colors.blue
                  : alert.type == 'payment'
                      ? Colors.green
                      : Colors.orange,
              child: Icon(
                alert.type == 'order' ? Icons.local_shipping : Icons.payment,
                color: Colors.white,
              ),
            ),
            title: Text(alert.title, style: TextStyle(fontWeight: alert.isRead ? FontWeight.normal : FontWeight.bold)),
            subtitle: Text(alert.message),
            trailing: Text(_formatTime(alert.timestamp), style: const TextStyle(fontSize: 12)),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class LiveDashboard extends StatelessWidget {
  const LiveDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final liveStreams = [
      {'title': 'Product Launch Event', 'host': 'John Doe', 'viewers': 1250},
      {'title': 'Customer Q&A Session', 'host': 'Sarah Smith', 'viewers': 342},
      {'title': 'Behind the Scenes', 'host': 'Mike Johnson', 'viewers': 89},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('LIVE Streams'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Now Live', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...liveStreams.map((stream) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Stack(
                children: [
                  Container(height: 200, color: Colors.grey.shade200),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Chip(
                      label: const Text('LIVE'),
                      backgroundColor: Colors.red,
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stream['title'] as String,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'by ${stream['host']}',
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.visibility, color: Colors.white, size: 16),
                                  Text(
                                    ' ${stream['viewers']}',
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class UserProfile extends StatelessWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile'), elevation: 0),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.blue.shade50,
            child: Column(
              children: [
                CircleAvatar(radius: 50, backgroundColor: Colors.blue, child: const Text('JD', style: TextStyle(color: Colors.white, fontSize: 24))),
                const SizedBox(height: 16),
                const Text('John Doe', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Text('john.doe@example.com', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: () {}, child: const Text('Edit Profile')),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Orders'),
            subtitle: const Text('5 orders'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Wishlist'),
            subtitle: const Text('12 items'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.stars),
            title: const Text('Loyalty Points'),
            subtitle: const Text('2,450 points'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Payment Methods'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Addresses'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Security'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged out'))),
          ),
        ],
      ),
    );
  }
}

class AppSettings extends StatefulWidget {
  const AppSettings({Key? key}) : super(key: key);

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  bool pushNotifications = true;
  bool emailNotifications = true;
  bool smsNotifications = false;
  String theme = 'Light';
  String language = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), elevation: 0),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: const Text('Notifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive push notifications'),
            value: pushNotifications,
            onChanged: (val) => setState(() => pushNotifications = val),
          ),
          SwitchListTile(
            title: const Text('Email Notifications'),
            subtitle: const Text('Receive email updates'),
            value: emailNotifications,
            onChanged: (val) => setState(() => emailNotifications = val),
          ),
          SwitchListTile(
            title: const Text('SMS Notifications'),
            subtitle: const Text('Receive SMS alerts'),
            value: smsNotifications,
            onChanged: (val) => setState(() => smsNotifications = val),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: const Text('App Preferences', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(theme),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeDialog(),
          ),
          ListTile(
            title: const Text('Language'),
            subtitle: Text(language),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageDialog(),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: const Text('About', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Theme'),
        children: ['Light', 'Dark', 'Auto'].map((t) {
          return SimpleDialogOption(
            onPressed: () {
              setState(() => theme = t);
              Navigator.pop(context);
            },
            child: Text(t),
          );
        }).toList(),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Language'),
        children: ['English', 'Spanish', 'French', 'German'].map((l) {
          return SimpleDialogOption(
            onPressed: () {
              setState(() => language = l);
              Navigator.pop(context);
            },
            child: Text(l),
          );
        }).toList(),
      ),
    );
  }
}
