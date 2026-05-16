/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
/// COMMUNITY MODULE â€” Community Members Screen
/// Paginated member list with roles. Admins can ban members.
/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../providers/community_provider.dart';
import 'community_hub_screen.dart' show kCommunityColor, kCommunityColorDark, kCommunityArchetypes;

const _roles = ['owner', 'admin', 'moderator', 'member'];

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
  String? get _communityId => _comm['id'] as String?;

  Map<String, dynamic> get _arch =>
      kCommunityArchetypes.firstWhere((a) => a['type'] == _type, orElse: () => kCommunityArchetypes[4]);

  Color get _color => Color(_arch['color'] as int);

  /// Current user is admin if their role in the community data is owner/admin/moderator.
  bool _isAdminRole(String? myRole) =>
      myRole == 'owner' || myRole == 'admin' || myRole == 'moderator';

  @override
  void initState() {
    super.initState();
    final id = _communityId;
    if (id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<CommunityProvider>().loadMembers(id);
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filtered(List<Map<String, dynamic>> members) {
    return members.where((m) {
      if (_roleFilter != 'all' && m['role'] != _roleFilter) return false;
      final q = _searchCtrl.text.trim().toLowerCase();
      final name = (m['name'] as String? ?? m['displayName'] as String? ?? '').toLowerCase();
      if (q.isNotEmpty && !name.contains(q)) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AIInsightsNotifier, CommunityProvider>(
      builder: (context, ai, communityProvider, _) {
        final id = _communityId;
        final allMembers = id != null ? communityProvider.membersFor(id) : <Map<String, dynamic>>[];
        final filtered = _filtered(allMembers);

        // Determine current user's role from member list
        final myRole = communityProvider.activeCommunity?['myRole'] as String?;
        final canModerate = _isAdminRole(myRole);

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
              // â”€â”€ AI insight â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              if (ai.insights.isNotEmpty)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: kCommunityColor.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(10), border: Border.all(color: kCommunityColor.withValues(alpha: 0.2))),
                  child: Row(children: [
                    const Icon(Icons.auto_awesome, color: kCommunityColor, size: 14),
                    const SizedBox(width: 8),
                    Expanded(child: Text(ai.insights.first['title'] ?? '', style: const TextStyle(fontSize: 11))),
                  ]),
                ),

              // â”€â”€ Search â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search membersâ€¦',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: AppColors.inputFill,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),

              // â”€â”€ Role filter chips â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

              // â”€â”€ Member count / loading â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              if (communityProvider.isMembersLoading && allMembers.isEmpty)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(children: [
                    Text('${filtered.length} member${filtered.length == 1 ? '' : 's'}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                  ]),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('No members found.', style: TextStyle(color: AppColors.textSecondary)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) => _memberTile(filtered[i], canModerate),
                        ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _memberTile(Map<String, dynamic> member, bool canModerate) {
    final role = member['role'] as String? ?? 'member';
    final isOwner = role == 'owner';
    final name = member['name'] as String? ?? member['displayName'] as String? ?? 'Member';
    final joinedAt = member['joinedAt'] as String? ?? member['createdAt'] as String? ?? '';
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
          backgroundColor: _color.withValues(alpha: 0.15),
          child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: TextStyle(color: _color, fontWeight: FontWeight.bold)),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(joinedAt.isNotEmpty ? 'Joined $joinedAt' : '', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: roleColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
              child: Text(role.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: roleColor)),
            ),
            if (canModerate && !isOwner) ...[
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
    final id = _communityId;
    final userId = member['id'] as String? ?? member['userId'] as String?;
    final name = member['name'] as String? ?? member['displayName'] as String? ?? 'Member';

    if (action == 'ban' && id != null && userId != null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Ban $name?'),
          content: const Text('This will remove them from the community. They will not be able to rejoin unless unbanned.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final ok = await context.read<CommunityProvider>().banMember(
                  communityId: id,
                  userId: userId,
                  reason: 'Banned by moderator',
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(ok ? '$name has been banned.' : 'Failed to ban member. Try again.'),
                  ));
                }
              },
              child: const Text('Ban', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } else if (action == 'promote') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name promoted to Admin.')));
    }
  }
}

