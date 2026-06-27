/// qualChat Screen 7  New Chat (Enhanced)
/// Intelligent recipient selection: individual + group creation
library;

import 'package:flutter/material.dart';
import '../../../core/design/ive.dart';
import '../../../core/utils/app_toast.dart';
import 'package:provider/provider.dart';
import '../models/qualchat_models.dart';
import '../providers/qualchat_provider.dart';
import '../widgets/qualchat_widgets.dart';

class QualChatNewChatScreen extends StatelessWidget {
  const QualChatNewChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QualChatProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: IveTokens.bg,
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
              // Chat type toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _TypeChip(
                      label: ' Individual',
                      isSelected: provider.newChatType == ChatType.individual,
                      onTap: () => provider.setNewChatType(ChatType.individual),
                    ),
                    const SizedBox(width: 8),
                    _TypeChip(
                      label: ' Group',
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'WHO TO CHAT WITH?',
              style: IveType.caption.copyWith(color: IveTokens.mute, letterSpacing: 0.5),
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search name, role, or department...',
                hintStyle: IveType.body.copyWith(color: IveTokens.ink2),
                prefixIcon: const Icon(Icons.search, color: IveTokens.ink2),
                filled: true,
                fillColor: IveTokens.surfaceRaised,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(IveTokens.rSm), borderSide: BorderSide.none),
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
                  RecipientFilter.online: ' Online',
                  RecipientFilter.favorites: ' Favorites',
                  RecipientFilter.recent: ' Recent',
                  RecipientFilter.department: ' Department',
                  RecipientFilter.nearby: ' Nearby',
                  RecipientFilter.recommended: ' Recommended',
                };
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => provider.setRecipientFilter(f),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: provider.recipientFilter == f ? IveTokens.moduleQualChat.withValues(alpha: 0.12) : IveTokens.surfaceRaised,
                        borderRadius: BorderRadius.circular(IveTokens.rSm),
                        border: provider.recipientFilter == f ? Border.all(color: IveTokens.moduleQualChat) : null,
                      ),
                      child: Text(
                        labels[f]!,
                        style: IveType.subhead.copyWith(
                          color: provider.recipientFilter == f ? IveTokens.moduleQualChat : IveTokens.mute,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'RECOMMENDED CONNECTIONS',
              style: IveType.caption.copyWith(color: IveTokens.mute, letterSpacing: 0.5),
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
                        const Text('', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        _timeAgo(u.lastSeen),
                        style: IveType.footnote.copyWith(color: IveTokens.ink2),
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
            Text(
              'Create Group Chat',
              style: IveType.bodyEmphasis.copyWith(color: IveTokens.ink),
            ),
            const SizedBox(height: 16),

            // Group name
            TextField(
              decoration: InputDecoration(
                labelText: 'Group Name',
                hintText: 'Project Alpha Sync',
                filled: true,
                fillColor: IveTokens.surfaceRaised,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(IveTokens.rSm), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),

            // Members
            Text(
              'Members (${provider.groupMembers.length}):',
              style: IveType.bodyEmphasis.copyWith(color: IveTokens.ink),
            ),
            const SizedBox(height: 8),
            if (provider.groupMembers.isEmpty)
              Text('No members added yet', style: IveType.body.copyWith(color: IveTokens.ink2))
            else
              ...provider.groupMembers.map((m) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: IveTokens.moduleQualChat.withValues(alpha: 0.1),
                    child: Text(m.name[0], style: IveType.bodyEmphasis.copyWith(color: IveTokens.moduleQualChat)),
                  ),
                  title: Text(m.name, style: IveType.body.copyWith(color: IveTokens.ink)),
                  trailing: TextButton(
                    onPressed: () => provider.removeGroupMember(m.id),
                    child: Text('Remove', style: IveType.caption.copyWith(color: IveTokens.danger)),
                  ),
                );
              }),
            const SizedBox(height: 12),

            // Add members
            Text('Add more:', style: IveType.subhead.copyWith(color: IveTokens.ink)),
            const SizedBox(height: 8),
            ...QualChatProvider.allUsers.where((u) =>
                !provider.groupMembers.any((m) => m.id == u.id)).take(4).map((u) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Stack(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: IveTokens.moduleQualChat.withValues(alpha: 0.1),
                      child: Text(u.name[0], style: IveType.bodyEmphasis.copyWith(color: IveTokens.moduleQualChat)),
                    ),
                    Positioned(right: 0, bottom: 0, child: PresenceDot(status: u.presence, size: 10)),
                  ],
                ),
                title: Text(u.name, style: IveType.body.copyWith(color: IveTokens.ink)),
                subtitle: Text(u.role, style: IveType.caption.copyWith(color: IveTokens.ink2)),
                trailing: IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: IveTokens.moduleQualChat),
                  onPressed: () => provider.addGroupMember(u),
                ),
              );
            }),
            const SizedBox(height: 16),

            // Group settings
            Text('Group Settings:', style: IveType.bodyEmphasis.copyWith(color: IveTokens.ink)),
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
                  child: IveButton.primary(
                    label: 'Create Group',
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Group created successfully!'),
                          backgroundColor: IveTokens.moduleQualChat,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                IveButton.secondary(
                  label: 'Cancel',
                  onPressed: () => Navigator.pop(context),
                  expand: false,
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
            color: isSelected ? IveTokens.moduleQualChat : IveTokens.surfaceRaised,
            borderRadius: BorderRadius.circular(IveTokens.rSm),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: IveType.subhead.copyWith(
              color: isSelected ? IveTokens.bg : IveTokens.mute,
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
        color: IveTokens.moduleQualChat.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(IveTokens.rSm),
        border: Border.all(color: IveTokens.moduleQualChat.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SELECTED: ${user.name}',
            style: IveType.caption.copyWith(color: IveTokens.moduleQualChat, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              PresenceDot(status: user.presence),
              const SizedBox(width: 6),
              Text(
                '${user.presence.name[0].toUpperCase()}${user.presence.name.substring(1)}  ${user.role}',
                style: IveType.caption.copyWith(color: IveTokens.mute),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Average response: ${user.avgResponseMinutes} minutes',
            style: IveType.footnote.copyWith(color: IveTokens.ink2),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: IveButton.primary(
                  label: 'Start Chat',
                  icon: Icons.chat,
                  onPressed: () => Navigator.pushNamed(context, '/qualchat/thread'),
                ),
              ),
              const SizedBox(width: 8),
              IveButton.secondary(
                label: 'Call',
                icon: Icons.call,
                onPressed: () => AppToast.show(context, 'Calling...'),
                expand: false,
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
            color: value ? IveTokens.moduleQualChat : IveTokens.ink2,
          ),
          const SizedBox(width: 8),
          Text(label, style: IveType.body.copyWith(color: IveTokens.ink)),
        ],
      ),
    );
  }
}
