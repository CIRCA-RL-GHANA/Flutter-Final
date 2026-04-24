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
import '../providers/eplay_provider.dart';
import 'eplay_hub_screen.dart' show kEPlayColor, kEPlayColorDark;

class EPlayLockerScreen extends StatefulWidget {
  const EPlayLockerScreen({super.key});

  @override
  State<EPlayLockerScreen> createState() => _EPlayLockerScreenState();
}

class _EPlayLockerScreenState extends State<EPlayLockerScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EPlayProvider>().loadLocker();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AIInsightsNotifier, EPlayProvider>(
      builder: (context, ai, eplay, _) {
        final items = eplay.lockerItems;
        final pinned = items.where((i) => i['isPinned'] == true).toList();
        final rentals = items.where((i) {
          final asset = i['asset'] as Map<String, dynamic>?;
          final status = i['status'] as String? ?? '';
          return status == 'active' && asset != null;
        }).toList();
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
                    _lockerStat('${items.length}', 'Total'),
                    _lockerStat('${pinned.length}', 'Pinned'),
                    _lockerStat('${rentals.length}', 'Rentals'),
                    _lockerStat('0 GB', 'Cached'),
                  ],
                ),
              ),

              // ── Tab content ─────────────────────────────────────────────
              Expanded(
                child: eplay.isLockerLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                  controller: _tabs,
                  children: [
                    _buildList(items),
                    _buildList(pinned),
                    _buildList(rentals),
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
    final isPinned = item['isPinned'] as bool? ?? false;
    final asset = item['asset'] as Map<String, dynamic>? ?? item;
    final type = asset['type'] as String? ?? 'music';
    final colors = _colorForType(type);
    final lockerId = item['id'] as String? ?? '';
    final eplay = context.read<EPlayProvider>();

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
        title: Text(asset['title'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(asset['creator'] as String? ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            Row(children: [
              Icon(isPinned ? Icons.wifi_off : Icons.cloud_done, size: 12, color: isPinned ? AppColors.warning : AppColors.success),
              const SizedBox(width: 4),
              Text(item['status'] as String? ?? 'active', style: TextStyle(fontSize: 11, color: isPinned ? AppColors.warning : AppColors.success)),
            ]),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(isPinned ? Icons.push_pin : Icons.push_pin_outlined, color: isPinned ? kEPlayColor : AppColors.textTertiary, size: 20),
              tooltip: isPinned ? 'Unpin offline' : 'Pin for offline',
              onPressed: () => eplay.togglePin(lockerId),
            ),
          ],
        ),
        onTap: () => Navigator.pushNamed(context, AppRoutes.eplayPlayer, arguments: asset),
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
