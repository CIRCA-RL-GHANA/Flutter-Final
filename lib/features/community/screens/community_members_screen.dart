/// ═══════════════════════════════════════════════════════════════════════════
/// COMMUNITY MODULE — Community Members Screen
/// Paginated member list with roles. Admins can ban members.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import 'community_hub_screen.dart' show kCommunityColor, kCommunityColorDark, kCommunityArchetypes;

const _roles = ['owner', 'admin', 'moderator', 'member'];

// Stub member data
final _stubMembers = List.generate(18, (i) => {
  'id': 'user-$i',
  'name': 'Member ${i + 1}',
  'role': i == 0 ? 'owner' : (i < 3 ? 'admin' : (i < 6 ? 'moderator' : 'member')),
  'joinedAt': 'May 2025',
});

class CommunityMembersScreen extends StatefulWidget {
  final Map<String, dynamic>? community;
  const CommunityMembersScreen({super.key, this.community});

  @override
  State<CommunityMembersScreen> createState() => _CommunityMembersScreenState();
}

class _CommunityMembersScreenState extends State<CommunityMembersScreen> {
  String _roleFilter = 'all';
  final _searchCtrl = TextEditingController();

  Map<String, dynamic> get _comm => widget.community ?? {};
  String get _type => _comm['type'] as String? ?? 'hub';

  Map<String, dynamic> get _arch =>
      kCommunityArchetypes.firstWhere((a) => a['type'] == _type, orElse: () => kCommunityArchetypes[4]);

  Color get _color => Color(_arch['color'] as int);

  bool _isAdmin = true; // stub: current user is admin

  List<Map<String, dynamic>> get _filtered {
    return _stubMembers.where((m) {
      if (_roleFilter != 'all' && m['role'] != _roleFilter) return false;
      final q = _searchCtrl.text.trim().toLowerCase();
      if (q.isNotEmpty && !(m['name']! as String).toLowerCase().contains(q)) return false;
      return true;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AIInsightsNotifier>(
      builder: (context, ai, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: kCommunityColorDark,
            foregroundColor: Colors.white,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_comm['name'] as String? ?? 'Community', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                const Text('Members', style: TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
          body: Column(
            children: [
              // ── AI insight ──────────────────────────────────────────
              if (ai.insights.isNotEmpty)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: kCommunityColor.withOpacity(0.07), borderRadius: BorderRadius.circular(10), border: Border.all(color: kCommunityColor.withOpacity(0.2))),
                  child: Row(children: [
                    const Icon(Icons.auto_awesome, color: kCommunityColor, size: 14),
                    const SizedBox(width: 8),
                    Expanded(child: Text(ai.insights.first['title'] ?? '', style: const TextStyle(fontSize: 11))),
                  ]),
                ),

              // ── Search ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search members…',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: AppColors.inputFill,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),

              // ── Role filter chips ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['all', ..._roles].map((r) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(r == 'all' ? 'All' : r.toUpperCase()),
                        selected: _roleFilter == r,
                        selectedColor: _color,
                        labelStyle: TextStyle(
                          color: _roleFilter == r ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                        onSelected: (_) => setState(() => _roleFilter = r),
                      ),
                    )).toList(),
                  ),
                ),
              ),

              // ── Member count ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  Text('${_filtered.length} members', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                ]),
              ),

              const SizedBox(height: 6),

              // ── List ───────────────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _filtered.length,
                  itemBuilder: (ctx, i) => _memberTile(_filtered[i]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _memberTile(Map<String, dynamic> member) {
    final role = member['role'] as String;
    final isOwner = role == 'owner';
    final roleColor = switch (role) {
      'owner'     => const Color(0xFFD97706),
      'admin'     => const Color(0xFFDC2626),
      'moderator' => const Color(0xFF2563EB),
      _           => AppColors.textSecondary,
    };

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _color.withOpacity(0.15),
          child: Text((member['name']! as String)[0], style: TextStyle(color: _color, fontWeight: FontWeight.bold)),
        ),
        title: Text(member['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text('Joined ${member['joinedAt']}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: roleColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
              child: Text(role.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: roleColor)),
            ),
            if (_isAdmin && !isOwner) ...[
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textTertiary),
                onSelected: (action) => _handleMemberAction(action, member),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'promote', child: Text('Promote to Admin')),
                  PopupMenuItem(value: 'ban', child: Text('Ban Member', style: TextStyle(color: Colors.red))),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleMemberAction(String action, Map<String, dynamic> member) {
    if (action == 'ban') {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Ban ${member['name']}?'),
          content: const Text('This will remove them from the community. They will not be able to rejoin unless unbanned.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${member['name']} has been banned.')));
              },
              child: const Text('Ban', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } else if (action == 'promote') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${member['name']} promoted to Admin.')));
    }
  }
}
