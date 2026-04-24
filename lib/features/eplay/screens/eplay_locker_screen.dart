/// ═══════════════════════════════════════════════════════════════════════════
/// e-PLAY MODULE — Cloud Locker Screen
/// The user's personal library of purchased / licensed digital content.
/// Content is never on-device unless pinned for temporary offline cache.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/ai_insights_notifier.dart';
import 'eplay_hub_screen.dart' show kEPlayColor, kEPlayColorDark;

// Stub locker items — replace with API
final _lockerItems = [
  {'id': 'l1', 'title': 'Afrobeats Vol. 3', 'creator': 'KobiBeat',  'type': 'music',   'pinned': true,  'access': 'Perpetual'},
  {'id': 'l2', 'title': 'Lagos Stories',     'creator': 'NaijaPen',  'type': 'ebook',   'pinned': false, 'access': 'Perpetual'},
  {'id': 'l3', 'title': 'The River Speaks',  'creator': 'AkosiFilm', 'type': 'movie',   'pinned': false, 'access': 'Rental – 14d left'},
  {'id': 'l4', 'title': 'Tech Minds Africa', 'creator': 'GeekCast',  'type': 'podcast', 'pinned': true,  'access': 'Perpetual'},
];

class EPlayLockerScreen extends StatefulWidget {
  const EPlayLockerScreen({super.key});

  @override
  State<EPlayLockerScreen> createState() => _EPlayLockerScreenState();
}

class _EPlayLockerScreenState extends State<EPlayLockerScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _items = List<Map<String, dynamic>>.from(_lockerItems);

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _pinned => _items.where((i) => i['pinned'] == true).toList();
  List<Map<String, dynamic>> get _rentals => _items.where((i) => (i['access'] as String).startsWith('Rental')).toList();

  @override
  Widget build(BuildContext context) {
    return Consumer<AIInsightsNotifier>(
      builder: (context, ai, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: kEPlayColorDark,
            foregroundColor: Colors.white,
            title: const Text('My Cloud Locker', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                tooltip: 'Browse more content',
                onPressed: () => Navigator.pushNamed(context, AppRoutes.eplayBrowse),
              ),
            ],
            bottom: TabBar(
              controller: _tabs,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorColor: AppColors.accent,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Pinned'),
                Tab(text: 'Rentals'),
              ],
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
                    Expanded(child: Text(ai.insights.first['title'] ?? '', style: const TextStyle(fontSize: 12))),
                  ]),
                ),

              // ── Stats bar ───────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [kEPlayColor.withOpacity(0.12), kEPlayColorDark.withOpacity(0.07)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _lockerStat('${_items.length}', 'Total'),
                    _lockerStat('${_pinned.length}', 'Pinned'),
                    _lockerStat('${_rentals.length}', 'Rentals'),
                    _lockerStat('0 GB', 'Cached'),
                  ],
                ),
              ),

              // ── Tab content ─────────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _buildList(_items),
                    _buildList(_pinned),
                    _buildList(_rentals),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _lockerStat(String value, String label) => Column(children: [
    Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kEPlayColor)),
    Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
  ]);

  Widget _buildList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 56, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            const Text('Nothing here yet', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.eplayBrowse),
              child: const Text('Browse e-Play', style: TextStyle(color: kEPlayColor)),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (ctx, i) => _buildLockerTile(items[i]),
    );
  }

  Widget _buildLockerTile(Map<String, dynamic> item) {
    final isPinned = item['pinned'] as bool;
    final type = item['type'] as String;
    final colors = _colorForType(type);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_iconForType(type), color: Colors.white, size: 26),
        ),
        title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['creator']!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            Row(children: [
              Icon(isPinned ? Icons.wifi_off : Icons.cloud_done, size: 12, color: isPinned ? AppColors.warning : AppColors.success),
              const SizedBox(width: 4),
              Text(item['access']!, style: TextStyle(fontSize: 11, color: isPinned ? AppColors.warning : AppColors.success)),
            ]),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(isPinned ? Icons.push_pin : Icons.push_pin_outlined, color: isPinned ? kEPlayColor : AppColors.textTertiary, size: 20),
              tooltip: isPinned ? 'Unpin offline' : 'Pin for offline',
              onPressed: () => setState(() => item['pinned'] = !isPinned),
            ),
          ],
        ),
        onTap: () => Navigator.pushNamed(context, AppRoutes.eplayPlayer, arguments: item),
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
