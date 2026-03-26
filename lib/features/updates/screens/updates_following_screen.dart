/// ═══════════════════════════════════════════════════════════════════════════
/// SCREEN 11 — Following Management
/// Categories: Entities, People, Topics, Lists. Bulk actions,
/// mute/unmute, priority, following analytics.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../models/updates_models.dart';
import '../providers/updates_provider.dart';
import '../widgets/updates_widgets.dart';

class UpdatesFollowingScreen extends StatelessWidget {
  const UpdatesFollowingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UpdatesProvider(),
      child: const _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();
  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isBulkMode = false;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdatesProvider>(
      builder: (context, prov, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: UpdatesAppBar(
            title: 'Following',
            actions: [
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: kUpdatesColor.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                  child: Text('${prov.followingCount}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kUpdatesColor)),
                ),
              ),
              IconButton(
                icon: Icon(_isBulkMode ? Icons.close : Icons.checklist, size: 20),
                color: _isBulkMode ? kUpdatesColor : AppColors.textSecondary,
                onPressed: () => setState(() { _isBulkMode = !_isBulkMode; _selectedIds.clear(); }),
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
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kUpdatesColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI: ${ai.insights.first['title'] ?? ''}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kUpdatesColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Bulk action bar
              if (_isBulkMode && _selectedIds.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  color: kUpdatesColor.withOpacity(0.06),
                  child: Row(
                    children: [
                      Text('${_selectedIds.length} selected', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kUpdatesColor)),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          for (final id in _selectedIds) {
                            prov.toggleFollow(id);
                          }
                          setState(() { _selectedIds.clear(); _isBulkMode = false; });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Unfollowed selected'), backgroundColor: kUpdatesColor, duration: Duration(seconds: 1)),
                          );
                        },
                        child: const Text('Unfollow', style: TextStyle(fontSize: 12, color: AppColors.error)),
                      ),
                      TextButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Muted selected'), backgroundColor: kUpdatesColor, duration: Duration(seconds: 1)),
                          );
                        },
                        child: const Text('Mute', style: TextStyle(fontSize: 12, color: kUpdatesColor)),
                      ),
                    ],
                  ),
                ),

              // Tabs
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: kUpdatesColor,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: kUpdatesColor,
                  indicatorWeight: 2.5,
                  labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  dividerHeight: 0,
                  tabs: [
                    Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.storefront, size: 16),
                      const SizedBox(width: 4),
                      Text('Entities (${prov.following.where((f) => f.type == FollowingType.entity).length})'),
                    ])),
                    Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.person, size: 16),
                      const SizedBox(width: 4),
                      Text('People (${prov.following.where((f) => f.type == FollowingType.person).length})'),
                    ])),
                    Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.tag, size: 16),
                      const SizedBox(width: 4),
                      Text('Topics (${prov.following.where((f) => f.type == FollowingType.topic).length})'),
                    ])),
                    Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.list, size: 16),
                      const SizedBox(width: 4),
                      Text('Lists (${prov.followingLists.length})'),
                    ])),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _FollowingList(
                      items: prov.following.where((f) => f.type == FollowingType.entity).toList(),
                      isBulkMode: _isBulkMode,
                      selectedIds: _selectedIds,
                      onToggleSelection: _toggleSelection,
                      prov: prov,
                    ),
                    _FollowingList(
                      items: prov.following.where((f) => f.type == FollowingType.person).toList(),
                      isBulkMode: _isBulkMode,
                      selectedIds: _selectedIds,
                      onToggleSelection: _toggleSelection,
                      prov: prov,
                    ),
                    _FollowingList(
                      items: prov.following.where((f) => f.type == FollowingType.topic).toList(),
                      isBulkMode: _isBulkMode,
                      selectedIds: _selectedIds,
                      onToggleSelection: _toggleSelection,
                      prov: prov,
                    ),
                    _ListsView(lists: prov.followingLists),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }
}

// ─── Following List ─────────────────────────────────────────────────────────

class _FollowingList extends StatelessWidget {
  final List<FollowedEntity> items;
  final bool isBulkMode;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggleSelection;
  final UpdatesProvider prov;

  const _FollowingList({
    required this.items,
    required this.isBulkMode,
    required this.selectedIds,
    required this.onToggleSelection,
    required this.prov,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const UpdatesEmptyState(
        icon: Icons.people_outline,
        title: 'Not following anyone',
        message: 'Follow entities, people, or topics to see their updates.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final entity = items[i];
        final isSelected = selectedIds.contains(entity.id);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: kUpdatesColor, width: 2) : null,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)],
          ),
          child: Row(
            children: [
              if (isBulkMode) ...[
                GestureDetector(
                  onTap: () => onToggleSelection(entity.id),
                  child: Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      color: isSelected ? kUpdatesColor : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: isSelected ? kUpdatesColor : Colors.grey.shade300, width: 2),
                    ),
                    child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Stack(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: kUpdatesColor.withOpacity(0.12),
                    child: Icon(
                      _typeIcon(entity.type),
                      size: 18,
                      color: kUpdatesColor,
                    ),
                  ),
                  if (entity.isMuted)
                    Positioned(
                      right: 0, bottom: 0,
                      child: Container(
                        width: 16, height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.volume_off, size: 8, color: Colors.white),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(entity.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        if (entity.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, size: 14, color: Color(0xFF3B82F6)),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        Text('${entity.followerCount} followers', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                        const Text(' • ', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                        Text(entity.updateFrequency, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                      ],
                    ),
                    // Priority indicator
                    Row(
                      children: [
                        ...List.generate(5, (pi) => Icon(
                          Icons.circle,
                          size: 6,
                          color: pi < entity.priority ? kUpdatesColor : Colors.grey.shade200,
                        )),
                        const SizedBox(width: 4),
                        Text('Priority ${entity.priority}/5', style: const TextStyle(fontSize: 9, color: AppColors.textTertiary)),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textTertiary),
                onSelected: (v) {
                  HapticFeedback.lightImpact();
                  switch (v) {
                    case 'unfollow':
                      prov.toggleFollow(entity.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Unfollowed ${entity.name}'), backgroundColor: kUpdatesColor, duration: const Duration(seconds: 1)),
                      );
                    case 'mute':
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(entity.isMuted ? 'Unmuted ${entity.name}' : 'Muted ${entity.name}'), backgroundColor: kUpdatesColor, duration: const Duration(seconds: 1)),
                      );
                    case 'priority':
                      _showPriorityPicker(context, entity);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'priority', child: Row(children: [const Icon(Icons.star, size: 16, color: kUpdatesColor), const SizedBox(width: 8), const Text('Set Priority', style: TextStyle(fontSize: 13))])),
                  PopupMenuItem(value: 'mute', child: Row(children: [Icon(entity.isMuted ? Icons.volume_up : Icons.volume_off, size: 16, color: AppColors.warning), const SizedBox(width: 8), Text(entity.isMuted ? 'Unmute' : 'Mute', style: const TextStyle(fontSize: 13))])),
                  PopupMenuItem(value: 'unfollow', child: Row(children: [const Icon(Icons.person_remove, size: 16, color: AppColors.error), const SizedBox(width: 8), const Text('Unfollow', style: TextStyle(fontSize: 13, color: AppColors.error))])),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _typeIcon(FollowingType t) => switch (t) {
        FollowingType.entity => Icons.storefront,
        FollowingType.person => Icons.person,
        FollowingType.topic => Icons.tag,
        FollowingType.list => Icons.list,
      };

  void _showPriorityPicker(BuildContext context, FollowedEntity entity) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Set priority for ${entity.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Higher priority means more visibility in your feed.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ...List.generate(5, (i) => ListTile(
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (j) => Icon(Icons.circle, size: 8, color: j <= i ? kUpdatesColor : Colors.grey.shade200)),
              ),
              title: Text('Priority ${i + 1}', style: TextStyle(fontWeight: entity.priority == i + 1 ? FontWeight.w600 : FontWeight.w400)),
              trailing: entity.priority == i + 1 ? const Icon(Icons.check, size: 18, color: kUpdatesColor) : null,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Priority set to ${i + 1}'), backgroundColor: kUpdatesColor, duration: const Duration(seconds: 1)),
                );
              },
            )),
          ],
        ),
      ),
    );
  }
}

// ─── Lists View ─────────────────────────────────────────────────────────────

class _ListsView extends StatelessWidget {
  final List<FollowingList> lists;
  const _ListsView({required this.lists});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        // Create new list button
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Create list coming soon'), backgroundColor: kUpdatesColor, duration: Duration(seconds: 1)),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: kUpdatesColor.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kUpdatesColor.withOpacity(0.2), style: BorderStyle.solid),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 18, color: kUpdatesColor),
                SizedBox(width: 6),
                Text('Create New List', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kUpdatesColor)),
              ],
            ),
          ),
        ),

        // Existing lists
        ...lists.map((list) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)],
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: kUpdatesColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.list, size: 20, color: kUpdatesColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(list.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    Text('${list.memberCount} members', style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                    if (list.description?.isNotEmpty ?? false)
                      Text(list.description!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.textTertiary),
            ],
          ),
        )),
      ],
    );
  }
}
