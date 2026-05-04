/// Enterprise › Dashboard Screen
/// Central hub for managing API keys, multi-channel integrations,
/// fulfillment tasks, and concierge sessions.

import 'package:flutter/material.dart';
import '../../../core/services/enterprise_service.dart';

const _kGold = Color(0xFFD4A017);
const _kCyan = Color(0xFF00BCD4);
const _kBg = Color(0xFF0A0A0F);
const _kCard = Color(0xFF1A1A2E);

class EnterpriseDashboardScreen extends StatefulWidget {
  final String entityId;
  const EnterpriseDashboardScreen({super.key, required this.entityId});

  @override
  State<EnterpriseDashboardScreen> createState() =>
      _EnterpriseDashboardScreenState();
}

class _EnterpriseDashboardScreenState extends State<EnterpriseDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _svc = EnterpriseService();

  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _apiKeys = [];
  List<Map<String, dynamic>> _channels = [];
  List<Map<String, dynamic>> _tasks = [];
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _loadingProfile = true);
    final results = await Future.wait([
      _svc.getProfile(widget.entityId),
      _svc.listApiKeys(widget.entityId),
      _svc.listChannels(widget.entityId),
      _svc.listFulfillmentTasks(widget.entityId),
    ]);
    if (mounted) {
      setState(() {
        _profile = (results[0]).data as Map<String, dynamic>?;
        _apiKeys = ((results[1]).data as List?)?.cast<Map<String, dynamic>>() ?? [];
        _channels = ((results[2]).data as List?)?.cast<Map<String, dynamic>>() ?? [];
        _tasks = ((results[3]).data as List?)?.cast<Map<String, dynamic>>() ?? [];
        _loadingProfile = false;
      });
    }
  }

  Future<void> _revokeKey(String keyId) async {
    await _svc.revokeApiKey(widget.entityId, keyId);
    _loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        foregroundColor: Colors.white,
        title: Text(
          _profile?['legalName'] ?? 'Enterprise Dashboard',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: _kCyan),
            onPressed: _loadAll,
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: _kGold,
          labelColor: _kGold,
          unselectedLabelColor: Colors.white38,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'API Keys'),
            Tab(text: 'Channels'),
            Tab(text: 'Fulfillment'),
          ],
        ),
      ),
      body: _loadingProfile
          ? const Center(child: CircularProgressIndicator(color: _kGold))
          : TabBarView(
              controller: _tabs,
              children: [
                _buildOverview(),
                _buildApiKeys(),
                _buildChannels(),
                _buildFulfillment(),
              ],
            ),
    );
  }

  // ─── Overview Tab ─────────────────────────────────────────────────────────
  Widget _buildOverview() {
    if (_profile == null) {
      return const Center(
          child: Text('No profile found.', style: TextStyle(color: Colors.white60)));
    }
    final status = _profile!['status'] as String? ?? 'unknown';
    final pathways =
        (_profile!['enabledPathways'] as List?)?.cast<int>() ?? [];
    final statusColor = status == 'active' ? Colors.green : Colors.orange;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _statCard('Status', status.toUpperCase(), icon: Icons.verified, iconColor: statusColor),
        const SizedBox(height: 12),
        _statCard('Type', (_profile!['enterpriseType'] as String? ?? '—').replaceAll('_', ' ').toUpperCase(),
            icon: Icons.business),
        const SizedBox(height: 12),
        _statCard('API Keys', '${_apiKeys.length} active', icon: Icons.vpn_key),
        const SizedBox(height: 12),
        _statCard('Channels', '${_channels.length} connected', icon: Icons.sync_alt),
        const SizedBox(height: 12),
        _statCard('Fulfillment Tasks', '${_tasks.length} total', icon: Icons.local_shipping),
        const SizedBox(height: 20),
        if (pathways.isNotEmpty) ...[
          const Text('Enabled Pathways',
              style: TextStyle(color: _kCyan, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pathways
                .map((p) => Chip(
                      label: Text('Pathway $p',
                          style: const TextStyle(color: Colors.black, fontSize: 12)),
                      backgroundColor: _kGold,
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  // ─── API Keys Tab ─────────────────────────────────────────────────────────
  Widget _buildApiKeys() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: _kGold, foregroundColor: Colors.black),
          onPressed: () => _showCreateApiKeyDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Create API Key'),
        ),
        const SizedBox(height: 16),
        if (_apiKeys.isEmpty)
          const Center(
              child: Text('No API keys yet.',
                  style: TextStyle(color: Colors.white38))),
        ..._apiKeys.map((k) => _apiKeyCard(k)),
      ],
    );
  }

  Widget _apiKeyCard(Map<String, dynamic> key) => Card(
        color: _kCard,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: const Icon(Icons.vpn_key, color: _kGold),
          title: Text(key['label'] as String? ?? '—',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(
            'Prefix: ${key['keyPrefix'] ?? '—'} • ${(key['isActive'] == true) ? 'Active' : 'Inactive'}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Revoke key',
            onPressed: () => _revokeKey(key['id'] as String),
          ),
        ),
      );

  void _showCreateApiKeyDialog() {
    final labelCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _kCard,
        title: const Text('New API Key', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: labelCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Key Label',
            labelStyle: TextStyle(color: Colors.white60),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: _kGold, foregroundColor: Colors.black),
            onPressed: () async {
              Navigator.pop(context);
              final res = await _svc.createApiKey(
                widget.entityId,
                label: labelCtrl.text.trim(),
                permissions: ['all'],
              );
              if (mounted && res.success) {
                final raw = res.data?['rawKey'] as String?;
                if (raw != null) {
                  _showKeyOnce(raw);
                }
                _loadAll();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showKeyOnce(String rawKey) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _kCard,
        title: const Text('Save Your Key', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This key will not be shown again. Copy it now.',
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 12),
            SelectableText(rawKey,
                style: const TextStyle(color: _kGold, fontFamily: 'monospace')),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: _kGold, foregroundColor: Colors.black),
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  // ─── Channels Tab ─────────────────────────────────────────────────────────
  Widget _buildChannels() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: _kCyan, foregroundColor: Colors.black),
          onPressed: () => _showAddChannelDialog(),
          icon: const Icon(Icons.add_link),
          label: const Text('Add Channel'),
        ),
        const SizedBox(height: 16),
        if (_channels.isEmpty)
          const Center(
              child: Text('No channels connected.',
                  style: TextStyle(color: Colors.white38))),
        ..._channels.map((c) => _channelCard(c)),
      ],
    );
  }

  Widget _channelCard(Map<String, dynamic> ch) => Card(
        color: _kCard,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: const Icon(Icons.sync_alt, color: _kCyan),
          title: Text(ch['channelName'] as String? ?? '—',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(
            '${(ch['channelType'] as String? ?? '').toUpperCase()} • ${ch['syncStatus'] ?? 'idle'}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.sync, color: _kCyan),
            tooltip: 'Sync now',
            onPressed: () async {
              await _svc.syncChannel(ch['id'] as String);
              _loadAll();
            },
          ),
        ),
      );

  void _showAddChannelDialog() {
    final nameCtrl = TextEditingController();
    String selectedType = 'shopify';
    final types = ['shopify', 'amazon', 'walmart', 'magento', 'woocommerce', 'pos', 'custom'];
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: _kCard,
          title: const Text('Add Channel', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Channel Name',
                    labelStyle: TextStyle(color: Colors.white60)),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedType,
                dropdownColor: _kCard,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Type',
                    labelStyle: TextStyle(color: Colors.white60)),
                items: types
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setS(() => selectedType = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white38)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: _kCyan, foregroundColor: Colors.black),
              onPressed: () async {
                Navigator.pop(context);
                await _svc.registerChannel(
                  entityId: widget.entityId,
                  channelType: selectedType,
                  channelName: nameCtrl.text.trim(),
                );
                _loadAll();
              },
              child: const Text('Connect'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Fulfillment Tab ──────────────────────────────────────────────────────
  Widget _buildFulfillment() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_tasks.isEmpty)
          const Center(
              child: Text('No fulfillment tasks yet.',
                  style: TextStyle(color: Colors.white38))),
        ..._tasks.map((t) => _taskCard(t)),
      ],
    );
  }

  Widget _taskCard(Map<String, dynamic> task) {
    final status = task['status'] as String? ?? 'pending';
    final statusColor = switch (status) {
      'delivered' => Colors.green,
      'failed' || 'cancelled' => Colors.red,
      'dispatched' || 'in_transit' => _kCyan,
      _ => Colors.orange,
    };
    return Card(
      color: _kCard,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.local_shipping, color: _kGold),
        title: Text(
          'Order: ${task['orderId'] ?? '—'}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${(task['provider'] as String? ?? '').replaceAll('_', ' ')} • ${task['trackingId'] ?? 'No tracking'}',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        trailing: Chip(
          label: Text(status.replaceAll('_', ' ').toUpperCase(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          backgroundColor: statusColor.withOpacity(0.15),
          side: BorderSide(color: statusColor),
          labelStyle: TextStyle(color: statusColor),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value,
      {IconData? icon, Color iconColor = _kGold}) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2D2D44)),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 16),
            ],
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ]),
          ],
        ),
      );
}
