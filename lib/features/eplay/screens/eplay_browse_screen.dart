/// ═══════════════════════════════════════════════════════════════════════════
/// e-PLAY MODULE — Browse Screen
/// Filterable content catalogue by type (music / movie / podcast / ebook / show)
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/ai_insights_notifier.dart';
import 'eplay_hub_screen.dart' show kEPlayColor, kEPlayColorDark;

const _allTypes = [
  {'label': 'All',      'type': null,      'icon': Icons.apps},
  {'label': 'Music',    'type': 'music',   'icon': Icons.music_note},
  {'label': 'Movies',   'type': 'movie',   'icon': Icons.movie},
  {'label': 'Podcasts', 'type': 'podcast', 'icon': Icons.podcasts},
  {'label': 'E-Books',  'type': 'ebook',   'icon': Icons.menu_book},
  {'label': 'Shows',    'type': 'show',    'icon': Icons.live_tv},
];

// Stub catalogue — replace with API data
final _catalogue = List.generate(24, (i) {
  final types = ['music', 'movie', 'podcast', 'ebook', 'show'];
  final type = types[i % types.length];
  return {
    'id': 'asset-$i',
    'title': 'Title ${i + 1}',
    'creator': 'Creator ${(i % 6) + 1}',
    'type': type,
    'price': i % 4 == 0 ? 'Free' : '₵${(i % 10) + 2}',
    'plays': '${(i * 312) + 100}',
  };
});

class EPlayBrowseScreen extends StatefulWidget {
  final String? initialType;
  const EPlayBrowseScreen({super.key, this.initialType});

  @override
  State<EPlayBrowseScreen> createState() => _EPlayBrowseScreenState();
}

class _EPlayBrowseScreenState extends State<EPlayBrowseScreen> {
  String? _selectedType;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    return _catalogue.where((item) {
      final matchType = _selectedType == null || item['type'] == _selectedType;
      final matchSearch = _searchQuery.isEmpty ||
          (item['title'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (item['creator'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      return matchType && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AIInsightsNotifier>(
      builder: (context, ai, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: kEPlayColorDark,
            foregroundColor: Colors.white,
            title: const Text('Browse e-Play', style: TextStyle(color: Colors.white)),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search titles, creators…',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  ),
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              // ── AI insight ──────────────────────────────────────────────
              if (ai.insights.isNotEmpty)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kEPlayColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kEPlayColor.withOpacity(0.2)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.auto_awesome, color: kEPlayColor, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(ai.insights.first['title'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textPrimary))),
                  ]),
                ),

              // ── Type filter chips ────────────────────────────────────
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _allTypes.length,
                  itemBuilder: (ctx, i) {
                    final tab = _allTypes[i];
                    final isSelected = tab['type'] == _selectedType;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedType = tab['type'] as String?),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? kEPlayColor : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? kEPlayColor : AppColors.inputBorder),
                        ),
                        child: Row(children: [
                          Icon(tab['icon'] as IconData, size: 14, color: isSelected ? Colors.white : AppColors.textSecondary),
                          const SizedBox(width: 5),
                          Text(tab['label'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textPrimary)),
                        ]),
                      ),
                    );
                  },
                ),
              ),

              // ── Grid ────────────────────────────────────────────────
              Expanded(
                child: _filtered.isEmpty
                    ? const Center(child: Text('No content found.', style: TextStyle(color: AppColors.textSecondary)))
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: _filtered.length,
                        itemBuilder: (ctx, i) => _buildAssetCard(_filtered[i]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAssetCard(Map<String, dynamic> item) {
    final colors = _colorForType(item['type'] as String);
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.eplayDetail, arguments: item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail area
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: Center(child: Icon(_iconForType(item['type'] as String), color: Colors.white, size: 40)),
              ),
            ),
            // Info area
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(item['creator']!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 1),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item['price']!, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors[0])),
                        Row(children: [
                          const Icon(Icons.play_arrow, size: 12, color: AppColors.textTertiary),
                          const SizedBox(width: 2),
                          Text(item['plays']!, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
