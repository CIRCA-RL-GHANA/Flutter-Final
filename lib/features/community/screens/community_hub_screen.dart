/// ═══════════════════════════════════════════════════════════════════════════
/// COMMUNITY MODULE — Hub Screen
/// Discover all 7 UGO community archetypes:
/// Library · Playlist · Theater · Fair · Hub · Hangout · Journal
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../providers/community_provider.dart';

const Color kCommunityColor = Color(0xFF0891B2);       // Cyan-700
const Color kCommunityColorDark = Color(0xFF0E7490);

// 7 community archetypes
const kCommunityArchetypes = [
  {'type': 'library',  'label': 'Libraries',  'icon': Icons.local_library,     'desc': 'Curate & discuss e-books and media',        'color': 0xFF0F766E},
  {'type': 'playlist', 'label': 'Playlists',  'icon': Icons.queue_music,        'desc': 'Collaborative audio/video curation',         'color': 0xFF7C3AED},
  {'type': 'theater',  'label': 'Theaters',   'icon': Icons.theaters,           'desc': 'Watch shows & movies together in sync',     'color': 0xFFDC2626},
  {'type': 'fair',     'label': 'Fairs',      'icon': Icons.storefront,         'desc': 'Pop-up marketplace events',                 'color': 0xFFD97706},
  {'type': 'hub',      'label': 'Hubs',       'icon': Icons.hub,                'desc': 'Topical forums & threaded discussions',     'color': 0xFF2563EB},
  {'type': 'hangout',  'label': 'Hangouts',   'icon': Icons.event,              'desc': 'Schedule virtual & physical events',        'color': 0xFF059669},
  {'type': 'journal',  'label': 'Journals',   'icon': Icons.book,               'desc': 'Shared blogs, notes & documentation',      'color': 0xFF6366F1},
];

class CommunityHubScreen extends StatefulWidget {
  const CommunityHubScreen({super.key});

  @override
  State<CommunityHubScreen> createState() => _CommunityHubScreenState();
}

class _CommunityHubScreenState extends State<CommunityHubScreen> {
  String? _filterType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<CommunityProvider>();
      if (p.communities.isEmpty) p.loadDiscovery();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AIInsightsNotifier, CommunityProvider>(
      builder: (context, ai, community, _) {
        final filtered = _filterType == null
            ? community.communities
            : community.communities.where((c) => c['type'] == _filterType).toList();
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: CustomScrollView(
            slivers: [
              // ── SliverAppBar ──────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: kCommunityColorDark,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.my_library_books, color: Colors.white),
                    tooltip: 'My Communities',
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.communityMine),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                    tooltip: 'Create Community',
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.communityCreate),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [Color(0xFF0C4A6E), kCommunityColorDark, kCommunityColor],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 60),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Communities', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            const Text('7 ways to connect, curate, and create together.', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── AI insight ────────────────────────────────────────────
              if (ai.insights.isNotEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kCommunityColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kCommunityColor.withOpacity(0.2)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.auto_awesome, color: kCommunityColor, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(ai.insights.first['title'] ?? '', style: const TextStyle(fontSize: 12))),
                    ]),
                  ),
                ),

              // ── 7 archetypes grid ──────────────────────────────────────
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 18, 16, 8),
                  child: Text('Community Types', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _archetypeCard(kCommunityArchetypes[i]),
                    childCount: kCommunityArchetypes.length,
                  ),
                ),
              ),

              // ── Trending ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Trending', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(onPressed: () => setState(() => _filterType = null), child: const Text('See All')),
                    ],
                  ),
                ),
              ),
              community.isDiscoveryLoading && filtered.isEmpty
                  ? const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())))
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _trendingTile(filtered[i]),
                        childCount: filtered.length,
                      ),
                    ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.communityCreate),
            backgroundColor: kCommunityColor,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('New Community', style: TextStyle(color: Colors.white)),
          ),
        );
      },
    );
  }

  Widget _archetypeCard(Map<String, dynamic> arch) {
    final color = Color(arch['color'] as int);
    return GestureDetector(
      onTap: () {
        setState(() => _filterType = arch['type'] as String);
        Navigator.pushNamed(context, AppRoutes.communityCreate, arguments: {'type': arch['type']});
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [color.withOpacity(0.85), color]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(arch['icon'] as IconData, color: Colors.white, size: 26),
            const Spacer(),
            Text(arch['label'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 2),
            Text(arch['desc'] as String, style: const TextStyle(color: Colors.white70, fontSize: 10), maxLines: 2),
          ],
        ),
      ),
    );
  }

  Widget _trendingTile(Map<String, dynamic> community) {
    final arch = kCommunityArchetypes.firstWhere((a) => a['type'] == community['type'], orElse: () => kCommunityArchetypes.last);
    final color = Color(arch['color'] as int);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))]),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
          child: Icon(arch['icon'] as IconData, color: color)),
        title: Text(community['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text((arch['label'] as String), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(community['members']!, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          const Text('members', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
        ]),
        onTap: () => Navigator.pushNamed(context, AppRoutes.communityDetail, arguments: community),
      ),
    );
  }
}
