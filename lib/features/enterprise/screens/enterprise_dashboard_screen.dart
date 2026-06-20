/// Enterprise â€º Dashboard Screen
/// Central hub for managing API keys, multi-channel integrations,
/// fulfillment tasks, and concierge sessions.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/design/ive.dart';
import '../../../core/services/enterprise_service.dart';


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

  Future<void> _revokeKey(String keyId, String label) async {
    if (!mounted) return;
    final confirmed = await showVerifySheet(
      context,
      title: 'Revoke $label',
      confirmLabel: 'Revoke $label',
      subtitle: 'This key will stop working immediately.',
      isDestructive: true,
      onConfirm: () async {
        final res = await _svc.revokeApiKey(widget.entityId, keyId);
        return res.success ? null : 'Failed to revoke. Try again.';
      },
    );
    if (confirmed) _loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IveTokens.voidColor,
      appBar: AppBar(
        backgroundColor: IveTokens.voidColor,
        foregroundColor: IveTokens.inkColor,
        title: Text(
          _profile?['legalName'] ?? 'Enterprise Dashboard',
          style: IveType.title3,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: IveTokens.infoColor),
            onPressed: _loadAll,
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: IveTokens.accentColor,
          labelColor: IveTokens.accentColor,
          unselectedLabelColor: IveTokens.muteColor,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'API Keys'),
            Tab(text: 'Channels'),
            Tab(text: 'Fulfillment'),
          ],
        ),
      ),
      body: _loadingProfile
          ? const IveListSkeleton(rows: 6)
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
    final statusColor = status == 'active' ? IveTokens.okColor : IveTokens.warnColor;

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
          Text('Enabled Pathways', style: IveType.callout.copyWith(color: IveTokens.infoColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pathways
                .map((p) => Chip(
                      label: Text('Pathway $p',
                          style: const TextStyle(color: Colors.white, fontSize: 12)),
                      backgroundColor: IveTokens.accentColor.withValues(alpha: 0.2),
                      side: const BorderSide(color: IveTokens.accentColor),
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
        IveButton.primary(
          label: 'Create API key',
          onPressed: _showCreateApiKeyDialog,
        ),
        const SizedBox(height: 16),
        if (_apiKeys.isEmpty)
          Center(child: Text('No API keys yet.', style: IveType.callout.copyWith(color: IveTokens.muteColor))),
        ..._apiKeys.map((k) => _apiKeyCard(k)),
      ],
    );
  }

  Widget _apiKeyCard(Map<String, dynamic> key) {
    final label = key['label'] as String? ?? '—';
    final prefix = key['keyPrefix'] as String? ?? '—';
    final active = key['isActive'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: IveTokens.raisedColor,
        borderRadius: BorderRadius.circular(IveTokens.rContainer),
        border: Border.all(color: IveTokens.hairColor, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.vpn_key_rounded, color: IveTokens.accentColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: IveType.headline),
                const SizedBox(height: 2),
                // Key prefix in mono (spec: display key in mono)
                Text(
                  prefix,
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 12,
                    color: IveTokens.muteColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          // Active indicator — quiet dot
          Container(
            width: 7, height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? IveTokens.okColor : IveTokens.muteColor,
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.block_rounded, size: 18, color: IveTokens.badColor),
            tooltip: 'Revoke',
            onPressed: () => _revokeKey(key['id'] as String, label),
          ),
        ],
      ),
    );
  }

  void _showCreateApiKeyDialog() {
    final labelCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: IveTokens.raisedColor,
        title: Text('New API key', style: IveType.title3),
        content: TextField(
          controller: labelCtrl,
          style: IveType.body.copyWith(color: IveTokens.inkColor),
          decoration: InputDecoration(
            labelText: 'Key label',
            labelStyle: IveType.callout.copyWith(color: IveTokens.muteColor),
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel', style: IveType.callout.copyWith(color: IveTokens.muteColor)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final res = await _svc.createApiKey(
                widget.entityId,
                label: labelCtrl.text.trim(),
                permissions: ['all'],
              );
              if (mounted && res.success) {
                final raw = res.data?['rawKey'] as String?;
                if (raw != null) _showKeyOnce(raw);
                _loadAll();
              }
            },
            child: Text('Create', style: IveType.callout.copyWith(color: IveTokens.accentColor, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showKeyOnce(String rawKey) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(
          IveTokens.s5,
          IveTokens.s4,
          IveTokens.s5,
          IveTokens.s5 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: const BoxDecoration(
          color: IveTokens.raisedColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(IveTokens.rContainer),
          ),
          border: Border(
            top: BorderSide(color: IveTokens.hairColor, width: 1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: IveTokens.s4),
                decoration: BoxDecoration(
                  color: IveTokens.muteColor.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(IveTokens.rChip),
                ),
              ),
            ),
            Text('Your API key', style: IveType.title3),
            const SizedBox(height: IveTokens.s2),
            // "Shown once" — stated clearly, once (spec P1)
            Text(
              'Shown once. Copy it now — you cannot retrieve it again.',
              style: IveType.callout.copyWith(color: IveTokens.warnColor),
            ),
            const SizedBox(height: IveTokens.s4),
            // Key in mono (spec P1)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: rawKey));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(IveTokens.s4),
                decoration: BoxDecoration(
                  color: IveTokens.surfaceColor,
                  borderRadius: BorderRadius.circular(IveTokens.rAtom),
                  border: Border.all(color: IveTokens.hairColor, width: 1),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        rawKey,
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 13,
                          color: IveTokens.inkColor,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: IveTokens.s3),
                    const Icon(Icons.copy_rounded, size: 16, color: IveTokens.muteColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: IveTokens.s6),
            IveButton.primary(
              label: 'Done',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Channels Tab ─────────────────────────────────────────────────────────
  Widget _buildChannels() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        IveButton.primary(
          label: 'Add channel',
          onPressed: _showAddChannelDialog,
        ),
        const SizedBox(height: 16),
        if (_channels.isEmpty)
          Center(child: Text('No channels connected.', style: IveType.callout.copyWith(color: IveTokens.muteColor))),
        ..._channels.map((c) => _channelCard(c)),
      ],
    );
  }

  Widget _channelCard(Map<String, dynamic> ch) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: IveTokens.raisedColor,
          borderRadius: BorderRadius.circular(IveTokens.rContainer),
          border: Border.all(color: IveTokens.hairColor, width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.sync_alt, color: IveTokens.infoColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ch['channelName'] as String? ?? '—', style: IveType.headline),
                  const SizedBox(height: 2),
                  Text(
                    '${(ch['channelType'] as String? ?? '').toUpperCase()} • ${ch['syncStatus'] ?? 'idle'}',
                    style: IveType.caption.copyWith(color: IveTokens.muteColor),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.sync_rounded, color: IveTokens.infoColor, size: 18),
              tooltip: 'Sync now',
              onPressed: () async {
                await _svc.syncChannel(ch['id'] as String);
                _loadAll();
              },
            ),
          ],
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
          backgroundColor: IveTokens.raisedColor,
          title: Text('Add channel', style: IveType.title3),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: IveType.body.copyWith(color: IveTokens.inkColor),
                decoration: InputDecoration(
                    labelText: 'Channel name',
                    labelStyle: IveType.callout.copyWith(color: IveTokens.muteColor)),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                dropdownColor: IveTokens.raisedColor,
                style: IveType.body.copyWith(color: IveTokens.inkColor),
                decoration: InputDecoration(
                    labelText: 'Type',
                    labelStyle: IveType.callout.copyWith(color: IveTokens.muteColor)),
                items: types
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setS(() => selectedType = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: IveType.callout.copyWith(color: IveTokens.muteColor)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _svc.registerChannel(
                  entityId: widget.entityId,
                  channelType: selectedType,
                  channelName: nameCtrl.text.trim(),
                );
                _loadAll();
              },
              child: Text('Connect', style: IveType.callout.copyWith(color: IveTokens.accentColor, fontWeight: FontWeight.w600)),
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
          Center(child: Text('No fulfillment tasks yet.', style: IveType.callout.copyWith(color: IveTokens.muteColor))),
        ..._tasks.map((t) => _taskCard(t)),
      ],
    );
  }

  Widget _taskCard(Map<String, dynamic> task) {
    final status = task['status'] as String? ?? 'pending';
    final statusColor = switch (status) {
      'delivered' => IveTokens.okColor,
      'failed' || 'cancelled' => IveTokens.badColor,
      'dispatched' || 'in_transit' => IveTokens.infoColor,
      _ => IveTokens.warnColor,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: IveTokens.raisedColor,
        borderRadius: BorderRadius.circular(IveTokens.rContainer),
        border: Border.all(color: IveTokens.hairColor, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping_rounded, color: IveTokens.accentColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order ${task['orderId'] ?? '—'}', style: IveType.headline),
                const SizedBox(height: 2),
                Text(
                  '${(task['provider'] as String? ?? '').replaceAll('_', ' ')} • ${task['trackingId'] ?? 'No tracking'}',
                  style: IveType.caption.copyWith(color: IveTokens.muteColor),
                ),
              ],
            ),
          ),
          Chip(
            label: Text(status.replaceAll('_', ' ').toUpperCase(),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            backgroundColor: statusColor.withValues(alpha: 0.12),
            side: BorderSide(color: statusColor),
            labelStyle: TextStyle(color: statusColor),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value,
      {IconData? icon, Color iconColor = IveTokens.accentColor}) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: IveTokens.raisedColor,
          borderRadius: BorderRadius.circular(IveTokens.rContainer),
          border: Border.all(color: IveTokens.hairColor, width: 1),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 16),
            ],
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: IveType.caption.copyWith(color: IveTokens.muteColor)),
              const SizedBox(height: 4),
              Text(value, style: IveType.headline),
            ]),
          ],
        ),
      );
}
