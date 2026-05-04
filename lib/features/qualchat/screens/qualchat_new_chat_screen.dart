/// qualChat Screen 7 — New Chat (Enhanced)
/// Intelligent recipient selection: individual + group creation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/qualchat_models.dart';
import '../providers/qualchat_provider.dart';
import '../widgets/qualchat_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class QualChatNewChatScreen extends StatelessWidget {
  const QualChatNewChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QualChatProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: QualChatAppBar(
            title: 'New Chat',
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.recommendations.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kChatColor.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kChatColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI suggests: ${ai.recommendations.first['name'] ?? ''}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kChatColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Chat type toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _TypeChip(
                      label: '👤 Individual',
                      isSelected: provider.newChatType == ChatType.individual,
                      onTap: () => provider.setNewChatType(ChatType.individual),
                    ),
                    const SizedBox(width: 8),
                    _TypeChip(
                      label: '👥 Group',
                      isSelected: provider.newChatType == ChatType.group,
                      onTap: () => provider.setNewChatType(ChatType.group),
                    ),
                  ],
                ),
              ),

              if (provider.newChatType == ChatType.individual)
                _buildIndividualView(context, provider)
              else
                _buildGroupView(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIndividualView(BuildContext context, QualChatProvider provider) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'WHO TO CHAT WITH?',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6B7280), letterSpacing: 0.5),
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search name, role, or department...',
                hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Quick filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: RecipientFilter.values.map((f) {
                final labels = {
                  RecipientFilter.online: '👤 Online',
                  RecipientFilter.favorites: '🌟 Favorites',
                  RecipientFilter.recent: '👥 Recent',
                  RecipientFilter.department: '🏢 Department',
                  RecipientFilter.nearby: '📍 Nearby',
                  RecipientFilter.recommended: '🎯 Recommended',
                };
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => provider.setRecipientFilter(f),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: provider.recipientFilter == f ? kChatColor.withOpacity(0.1) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(16),
                        border: provider.recipientFilter == f ? Border.all(color: kChatColor) : null,
                      ),
                      child: Text(
                        labels[f]!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: provider.recipientFilter == f ? kChatColor : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Selected recipient detail
          if (provider.selectedRecipient != null) ...[
            _SelectedRecipientCard(user: provider.selectedRecipient!),
          ],

          // Recommended connections
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'RECOMMENDED CONNECTIONS',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF6B7280), letterSpacing: 0.5),
            ),
          ),
          Expanded(
            child: ListView(
              children: QualChatProvider.allUsers.map((u) {
                return UserListItem(
                  user: u,
                  onTap: () {
                    provider.selectRecipient(u);
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (u.presence == PresenceStatus.online)
                        const Text('💬', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        _timeAgo(u.lastSeen),
                        style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupView(BuildContext context, QualChatProvider provider) {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Group Chat',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 16),

            // Group name
            TextField(
              decoration: InputDecoration(
                labelText: 'Group Name',
                hintText: 'Project Alpha Sync',
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),

            // Members
            Text(
              'Members (${provider.groupMembers.length}):',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 8),
            if (provider.groupMembers.isEmpty)
              const Text('No members added yet', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)))
            else
              ...provider.groupMembers.map((m) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: kChatColor.withOpacity(0.1),
                    child: Text(m.name[0], style: const TextStyle(color: kChatColor, fontWeight: FontWeight.w700)),
                  ),
                  title: Text(m.name, style: const TextStyle(fontSize: 14)),
                  trailing: TextButton(
                    onPressed: () => provider.removeGroupMember(m.id),
                    child: const Text('Remove', style: TextStyle(fontSize: 12, color: Color(0xFFEF4444))),
                  ),
                );
              }),
            const SizedBox(height: 12),

            // Add members
            const Text('Add more:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...QualChatProvider.allUsers.where((u) =>
                !provider.groupMembers.any((m) => m.id == u.id)).take(4).map((u) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Stack(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: kChatColor.withOpacity(0.1),
                      child: Text(u.name[0], style: const TextStyle(color: kChatColor, fontWeight: FontWeight.w700)),
                    ),
                    Positioned(right: 0, bottom: 0, child: PresenceDot(status: u.presence, size: 10)),
                  ],
                ),
                title: Text(u.name, style: const TextStyle(fontSize: 14)),
                subtitle: Text(u.role, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                trailing: IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: kChatColor),
                  onPressed: () => provider.addGroupMember(u),
                ),
              );
            }),
            const SizedBox(height: 16),

            // Group settings
            const Text('Group Settings:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const _GroupToggle(label: 'Show typing indicators', value: true),
            const _GroupToggle(label: 'Allow media', value: true),
            const _GroupToggle(label: 'Admin-only posting', value: false),
            const _GroupToggle(label: 'Add to favorites', value: true),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kChatColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Create Group'),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6B7280),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _TypeChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? kChatColor : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedRecipientCard extends StatelessWidget {
  final ChatUser user;
  const _SelectedRecipientCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kChatColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kChatColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SELECTED: ${user.name}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kChatColor, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              PresenceDot(status: user.presence),
              const SizedBox(width: 6),
              Text(
                '${user.presence.name[0].toUpperCase()}${user.presence.name.substring(1)} • ${user.role}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Average response: ${user.avgResponseMinutes} minutes',
            style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/qualchat/thread'),
                  icon: const Icon(Icons.chat, size: 16),
                  label: const Text('Start Chat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kChatColor, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.call, size: 16),
                label: const Text('Call'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kChatColor,
                  side: const BorderSide(color: kChatColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GroupToggle extends StatelessWidget {
  final String label;
  final bool value;
  const _GroupToggle({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_box : Icons.check_box_outline_blank,
            size: 20,
            color: value ? kChatColor : const Color(0xFF9CA3AF),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A))),
        ],
      ),
    );
  }
}
