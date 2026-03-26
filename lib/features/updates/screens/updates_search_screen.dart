/// ═══════════════════════════════════════════════════════════════════════════
/// SCREEN 6 — Search & Explore
/// Five tabs: Top, Latest, Accounts, Hashtags, Nearby.
/// Trending hashtags, suggested accounts, recent searches.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../providers/updates_provider.dart';
import '../widgets/updates_widgets.dart';

class UpdatesSearchScreen extends StatelessWidget {
  const UpdatesSearchScreen({super.key});

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
  final _searchController = TextEditingController();
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdatesProvider>(
      builder: (context, prov, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, size: 22),
              color: AppColors.textPrimary,
              onPressed: () => Navigator.pop(context),
            ),
            title: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => setState(() => _hasSearched = true),
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search updates, people, hashtags...',
                hintStyle: const TextStyle(fontSize: 14, color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.inputFill,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _hasSearched = false);
                        },
                      )
                    : null,
              ),
            ),
            bottom: _hasSearched
                ? TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: kUpdatesColor,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: kUpdatesColor,
                    labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    dividerHeight: 0,
                    tabAlignment: TabAlignment.start,
                    tabs: const [
                      Tab(text: 'Top'),
                      Tab(text: 'Latest'),
                      Tab(text: 'Accounts'),
                      Tab(text: 'Hashtags'),
                      Tab(text: 'Nearby'),
                    ],
                  )
                : null,
          ),
          body: _hasSearched
              ? TabBarView(
                  controller: _tabController,
                  children: [
                    _TopResults(prov: prov),
                    _LatestResults(prov: prov),
                    _AccountsResults(prov: prov),
                    _HashtagsResults(prov: prov),
                    const _NearbyResults(),
                  ],
                )
              : _DiscoverView(prov: prov, onSearch: (q) {
                  _searchController.text = q;
                  setState(() => _hasSearched = true);
                }),
        );
      },
    );
  }
}

// ─── Discover (Pre-Search) ──────────────────────────────────────────────────

class _DiscoverView extends StatelessWidget {
  final UpdatesProvider prov;
  final ValueChanged<String> onSearch;
  const _DiscoverView({required this.prov, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trending Hashtags
          UpdatesSectionCard(
            title: 'TRENDING HASHTAGS',
            icon: Icons.trending_up,
            iconColor: kUpdatesColor,
            child: Column(
              children: prov.trendingHashtags.map((h) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => onSearch('#${h.tag}'),
                  child: Row(
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(color: kUpdatesColor.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.tag, size: 16, color: kUpdatesColor),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('#${h.tag}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            Text('${h.postCount} posts', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                          ],
                        ),
                      ),
                      if (h.growthRate > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: kUpdatesColor.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.trending_up, size: 10, color: kUpdatesColor),
                              const SizedBox(width: 2),
                              Text('+${h.growthRate.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: kUpdatesColor)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              )).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Suggested Accounts
          UpdatesSectionCard(
            title: 'SUGGESTED ACCOUNTS',
            icon: Icons.person_add,
            iconColor: kUpdatesAccent,
            child: Column(
              children: prov.searchAccounts.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: kUpdatesAccent.withOpacity(0.12),
                      child: Text(a.name.substring(0, 1), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kUpdatesAccent)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(a.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              if (a.isVerified) ...[
                                const SizedBox(width: 3),
                                const Icon(Icons.verified, size: 14, color: Color(0xFF3B82F6)),
                              ],
                            ],
                          ),
                          Text('${a.followerCount} followers • ${a.mutualConnections} mutual', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Following ${a.name}'), backgroundColor: kUpdatesColor, duration: const Duration(seconds: 1)),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kUpdatesColor,
                        side: const BorderSide(color: kUpdatesColor),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Follow', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab Results ────────────────────────────────────────────────────────────

class _TopResults extends StatelessWidget {
  final UpdatesProvider prov;
  const _TopResults({required this.prov});

  @override
  Widget build(BuildContext context) {
    return Consumer<AIInsightsNotifier>(
      builder: (ctx, aiNotifier, _) {
        final recIds = aiNotifier.searchResults
            .map((r) => r['id']?.toString() ?? '')
            .toSet();
        final items = prov.updates;
        final sorted = recIds.isEmpty
            ? items
            : [
                ...items.where((u) => recIds.contains(u.id)),
                ...items.where((u) => !recIds.contains(u.id)),
              ];
        return ListView(
          padding: const EdgeInsets.all(14),
          children: [
            if (recIds.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: kUpdatesColor.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kUpdatesColor.withOpacity(0.15)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 14, color: kUpdatesColor),
                    const SizedBox(width: 6),
                    Text(
                      'AI — Semantically ranked results',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: kUpdatesColor,
                      ),
                    ),
                  ],
                ),
              ),
            ...sorted.map((u) => UpdateCard(
              update: u,
              isCompact: true,
              onTap: () {
                prov.selectUpdate(u);
                Navigator.pushNamed(context, AppRoutes.updatesDetail);
              },
            )),
          ],
        );
      },
    );
  }
}

class _LatestResults extends StatelessWidget {
  final UpdatesProvider prov;
  const _LatestResults({required this.prov});

  @override
  Widget build(BuildContext context) {
    final latest = [...prov.updates]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: latest.length,
      itemBuilder: (context, i) => UpdateCard(
        update: latest[i],
        isCompact: true,
        onTap: () {
          prov.selectUpdate(latest[i]);
          Navigator.pushNamed(context, AppRoutes.updatesDetail);
        },
      ),
    );
  }
}

class _AccountsResults extends StatelessWidget {
  final UpdatesProvider prov;
  const _AccountsResults({required this.prov});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: prov.searchAccounts.length,
      itemBuilder: (context, i) {
        final a = prov.searchAccounts[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: kUpdatesColor.withOpacity(0.12),
                child: Text(a.name.substring(0, 1), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kUpdatesColor)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(a.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        if (a.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, size: 14, color: Color(0xFF3B82F6)),
                        ],
                      ],
                    ),
                    Text('${a.followerCount} followers', style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                    if (a.recentActivity != null && a.recentActivity!.isNotEmpty)
                      Text(a.recentActivity!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () => HapticFeedback.lightImpact(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kUpdatesColor,
                  side: const BorderSide(color: kUpdatesColor),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Follow', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HashtagsResults extends StatelessWidget {
  final UpdatesProvider prov;
  const _HashtagsResults({required this.prov});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: prov.trendingHashtags.length,
      itemBuilder: (context, i) {
        final h = prov.trendingHashtags[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: kUpdatesColor.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.tag, size: 20, color: kUpdatesColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('#${h.tag}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    Text('${h.postCount} posts', style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                  ],
                ),
              ),
              if (h.growthRate > 0)
                const Icon(Icons.trending_up, size: 18, color: kUpdatesColor),
            ],
          ),
        );
      },
    );
  }
}

class _NearbyResults extends StatelessWidget {
  const _NearbyResults();

  @override
  Widget build(BuildContext context) {
    return const UpdatesEmptyState(
      icon: Icons.location_on,
      title: 'Nearby Updates',
      message: 'Enable location services to see updates from entities near you.',
      ctaLabel: 'Enable Location',
    );
  }
}
