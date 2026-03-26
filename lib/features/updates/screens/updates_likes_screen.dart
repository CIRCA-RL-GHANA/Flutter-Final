/// ═══════════════════════════════════════════════════════════════════════════
/// SCREEN 3 — Likes List
/// Shows who liked an update: search/filter, mutual connections, online
/// indicators, follow buttons, reaction type badges.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../models/updates_models.dart';
import '../providers/updates_provider.dart';
import '../widgets/updates_widgets.dart';

class UpdatesLikesScreen extends StatelessWidget {
  const UpdatesLikesScreen({super.key});

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
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        final likers = prov.likers.where((l) {
          if (_searchQuery.isEmpty) return true;
          return l.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              l.fullName.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        final mutualFirst = [...likers]..sort((a, b) => b.mutualConnections.compareTo(a.mutualConnections));
        final onlineOnly = likers.where((l) => l.isOnline).toList();

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: UpdatesAppBar(
            title: 'Likes',
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: kUpdatesColor.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                    child: Text('${prov.likers.length}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kUpdatesColor)),
                  ),
                ),
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

              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search likers...',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
                    prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textTertiary),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.inputBorder)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.inputBorder)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kUpdatesColor)),
                  ),
                ),
              ),

              // Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: kUpdatesColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  dividerHeight: 0,
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Mutual'),
                    Tab(text: 'Online'),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // Reaction type filter chips
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  children: [
                    const _ReactionChip(emoji: '❤️', label: 'All', isSelected: true),
                    const SizedBox(width: 6),
                    const _ReactionChip(emoji: '👍', label: 'Like', isSelected: false),
                    const SizedBox(width: 6),
                    const _ReactionChip(emoji: '🔥', label: 'Fire', isSelected: false),
                    const SizedBox(width: 6),
                    const _ReactionChip(emoji: '😂', label: 'Laugh', isSelected: false),
                    const SizedBox(width: 6),
                    const _ReactionChip(emoji: '😮', label: 'Wow', isSelected: false),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // List
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _LikersList(likers: likers),
                    _LikersList(likers: mutualFirst),
                    _LikersList(likers: onlineOnly),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LikersList extends StatelessWidget {
  final List<UpdateLiker> likers;
  const _LikersList({required this.likers});

  @override
  Widget build(BuildContext context) {
    if (likers.isEmpty) {
      return const UpdatesEmptyState(
        icon: Icons.favorite_outline,
        title: 'No likers found',
        message: 'No one matching your search.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: likers.length,
      itemBuilder: (context, i) => LikerItem(
        liker: likers[i],
        onFollow: () {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Now following ${likers[i].username}'),
              backgroundColor: kUpdatesColor,
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }
}

class _ReactionChip extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  const _ReactionChip({required this.emoji, required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? kUpdatesColor.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isSelected ? kUpdatesColor : Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isSelected ? kUpdatesColor : AppColors.textSecondary)),
        ],
      ),
    );
  }
}
