/// ═══════════════════════════════════════════════════════════════════════════
/// e-PLAY MODULE — Hub Screen
/// Digital goods marketplace hub for African creators.
/// Entry point: category carousel, featured content, creator spotlight.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/ai_insights_notifier.dart';

// ── Module color
const Color kEPlayColor = Color(0xFF7C3AED);       // Deep violet
const Color kEPlayColorDark = Color(0xFF4C1D95);
const Color kEPlayAccent = Color(0xFFDDD6FE);

const _categories = [
  {'label': 'Music',    'icon': Icons.music_note,     'type': 'music'},
  {'label': 'Movies',   'icon': Icons.movie,           'type': 'movie'},
  {'label': 'Podcasts', 'icon': Icons.podcasts,        'type': 'podcast'},
  {'label': 'E-Books',  'icon': Icons.menu_book,       'type': 'ebook'},
  {'label': 'Shows',    'icon': Icons.live_tv,         'type': 'show'},
];

final _featured = [
  {'title': 'Afrobeats Vol. 3',    'creator': 'KobiBeat',  'type': 'music',  'price': '₵5'},
  {'title': 'Lagos Stories',        'creator': 'NaijaPen',  'type': 'ebook',  'price': '₵8'},
  {'title': 'The River Speaks',     'creator': 'AkosiFilm', 'type': 'movie',  'price': '₵15'},
  {'title': 'Tech Minds Africa',    'creator': 'GeekCast',  'type': 'podcast','price': 'Free'},
  {'title': 'Highlife Classics',    'creator': 'GoldWax',   'type': 'music',  'price': '₵4'},
];

class EPlayHubScreen extends StatefulWidget {
  const EPlayHubScreen({super.key});

  @override
  State<EPlayHubScreen> createState() => _EPlayHubScreenState();
}

class _EPlayHubScreenState extends State<EPlayHubScreen> {
  int _selectedCategory = -1; // -1 = All
  final _scrollController = ScrollController();
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final collapsed = _scrollController.offset > 180;
      if (collapsed != _isCollapsed) setState(() => _isCollapsed = collapsed);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AIInsightsNotifier>(
      builder: (context, ai, _) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: AppColors.backgroundLight,
            body: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // ── Hero SliverAppBar ────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  backgroundColor: kEPlayColorDark,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.lock_open, color: Colors.white),
                      tooltip: 'My Cloud Locker',
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.eplayLocker),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.eplayBrowse),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    title: _isCollapsed
                        ? const Text('e-Play', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))
                        : null,
                    background: _buildHeroBackground(),
                  ),
                ),

                // ── AI Insight banner ───────────────────────────────────
                if (ai.insights.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [kEPlayColor.withOpacity(0.12), kEPlayColorDark.withOpacity(0.06)]),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kEPlayColor.withOpacity(0.25)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.auto_awesome, color: kEPlayColor, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ai.insights.first['title'] ?? '',
                            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                          ),
                        ),
                      ]),
                    ),
                  ),

                // ── Category pills ──────────────────────────────────────
                SliverToBoxAdapter(child: _buildCategoryRow()),

                // ── Featured content ────────────────────────────────────
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Text('Featured', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ),
                ),
                SliverToBoxAdapter(child: _buildFeaturedCarousel()),

                // ── Quick actions ────────────────────────────────────────
                SliverToBoxAdapter(child: _buildQuickActions()),

                // ── Creator spotlight ───────────────────────────────────
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Text('Creator Spotlight', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _buildCreatorCard(i),
                    childCount: 4,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.eplayCreatorStudio),
              backgroundColor: kEPlayColor,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Sell Content', style: TextStyle(color: Colors.white)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kEPlayColorDark, Color(0xFF5B21B6), kEPlayColor],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('e-Play', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text(
                'African digital content — music, film, books & more.\nOwn it. Stream it. Carry it everywhere.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const Spacer(),
              Row(children: [
                _heroStat('1.2K', 'Creators'),
                const SizedBox(width: 24),
                _heroStat('8.5K', 'Titles'),
                const SizedBox(width: 24),
                _heroStat('45K', 'Listeners'),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroStat(String value, String label) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
    ],
  );

  Widget _buildCategoryRow() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length + 1,
        itemBuilder: (ctx, i) {
          final isAll = i == 0;
          final isSelected = isAll ? _selectedCategory == -1 : _selectedCategory == i - 1;
          final label = isAll ? 'All' : _categories[i - 1]['label'] as String;
          final icon = isAll ? Icons.apps : _categories[i - 1]['icon'] as IconData;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = isAll ? -1 : i - 1);
              if (!isAll) {
                Navigator.pushNamed(context, AppRoutes.eplayBrowse,
                  arguments: {'type': _categories[i - 1]['type']});
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? kEPlayColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? kEPlayColor : AppColors.inputBorder),
                boxShadow: isSelected ? [BoxShadow(color: kEPlayColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))] : [],
              ),
              child: Row(children: [
                Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textPrimary)),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedCarousel() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _featured.length,
        itemBuilder: (ctx, i) {
          final item = _featured[i];
          final colors = _colorForType(item['type'] as String);
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.eplayDetail, arguments: {'id': 'demo-$i', ...item}),
            child: Container(
              width: 160,
              margin: const EdgeInsets.fromLTRB(4, 4, 4, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: colors[0].withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(_iconForType(item['type'] as String), color: Colors.white, size: 28),
                  const Spacer(),
                  Text(item['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(item['creator']!, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(8)),
                    child: Text(item['price']!, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        _quickAction(Icons.lock_open_rounded, 'My Locker', kEPlayColor, () => Navigator.pushNamed(context, AppRoutes.eplayLocker)),
        const SizedBox(width: 10),
        _quickAction(Icons.play_circle_fill, 'Browse All', Colors.teal, () => Navigator.pushNamed(context, AppRoutes.eplayBrowse)),
        const SizedBox(width: 10),
        _quickAction(Icons.mic, 'Creator Studio', AppColors.accentDark, () => Navigator.pushNamed(context, AppRoutes.eplayCreatorStudio)),
      ]),
    );
  }

  Widget _quickAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.25))),
          child: Column(children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }

  Widget _buildCreatorCard(int i) {
    final creators = [
      {'name': 'KobiBeat', 'genre': 'Afrobeats / Electronic', 'titles': '24'},
      {'name': 'NaijaPen', 'genre': 'Fiction / Non-fiction',  'titles': '12'},
      {'name': 'AkosiFilm', 'genre': 'Short Film / Drama',    'titles': '7'},
      {'name': 'GoldWax',   'genre': 'Highlife / Afro Jazz',   'titles': '18'},
    ];
    final c = creators[i];
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: kEPlayColor.withOpacity(0.15),
        child: Text(c['name']![0], style: const TextStyle(color: kEPlayColor, fontWeight: FontWeight.bold)),
      ),
      title: Text(c['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(c['genre']!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(c['titles']!, style: const TextStyle(fontWeight: FontWeight.bold, color: kEPlayColor)),
          const Text('titles', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
        ],
      ),
      onTap: () {},
    );
  }

  List<Color> _colorForType(String type) {
    return switch (type) {
      'music'   => [const Color(0xFF7C3AED), const Color(0xFF4338CA)],
      'movie'   => [const Color(0xFF0F766E), const Color(0xFF0E7490)],
      'podcast' => [const Color(0xFFD97706), const Color(0xFFB45309)],
      'ebook'   => [const Color(0xFF059669), const Color(0xFF0D9488)],
      'show'    => [const Color(0xFFDC2626), const Color(0xFFB91C1C)],
      _         => [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
    };
  }

  IconData _iconForType(String type) {
    return switch (type) {
      'music'   => Icons.music_note,
      'movie'   => Icons.movie,
      'podcast' => Icons.podcasts,
      'ebook'   => Icons.menu_book,
      'show'    => Icons.live_tv,
      _         => Icons.play_circle,
    };
  }
}
