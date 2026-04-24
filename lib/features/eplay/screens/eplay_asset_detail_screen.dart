/// ═══════════════════════════════════════════════════════════════════════════
/// e-PLAY MODULE — Asset Detail Screen
/// DRM content detail page: purchase → adds to cloud locker.
/// No file is downloaded — access lives in the server-side license.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/ai_insights_notifier.dart';
import 'eplay_hub_screen.dart' show kEPlayColor, kEPlayColorDark;

class EPlayAssetDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? asset;
  const EPlayAssetDetailScreen({super.key, this.asset});

  @override
  State<EPlayAssetDetailScreen> createState() => _EPlayAssetDetailScreenState();
}

class _EPlayAssetDetailScreenState extends State<EPlayAssetDetailScreen> {
  bool _purchasing = false;
  bool _owned = false;

  Map<String, dynamic> get _asset => widget.asset ?? {};

  @override
  Widget build(BuildContext context) {
    return Consumer<AIInsightsNotifier>(
      builder: (context, ai, _) {
        final colors = _colorForType(_asset['type'] as String? ?? 'music');
        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: CustomScrollView(
            slivers: [
              // ── Hero ─────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: colors[1],
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(_iconForType(_asset['type'] as String? ?? 'music'), color: Colors.white, size: 56),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _asset['title'] as String? ?? 'Untitled',
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _asset['creator'] as String? ?? '',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Body ─────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type badge + price
                      Row(
                        children: [
                          _typeBadge(_asset['type'] as String? ?? 'music', colors[0]),
                          const Spacer(),
                          Text(
                            _asset['price'] as String? ?? '',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors[0]),
                          ),
                          const SizedBox(width: 4),
                          const Text(' / Q Points', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Cloud Locker explanation
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: kEPlayColor.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kEPlayColor.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Icon(Icons.cloud_done, color: kEPlayColor, size: 20),
                              const SizedBox(width: 8),
                              const Text('e-Play Cloud Locker', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kEPlayColor)),
                            ]),
                            const SizedBox(height: 6),
                            const Text(
                              'Your purchase grants perpetual cloud access — not a file download. Stream this content anytime from any device. Optionally pin for offline use.',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // AI insight
                      if (ai.insights.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.amber.withOpacity(0.3))),
                          child: Row(children: [
                            const Icon(Icons.auto_awesome, color: Colors.amber, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(ai.insights.first['title'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textPrimary))),
                          ]),
                        ),

                      // About
                      const Text('About this content', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      const Text(
                        'Experience authentic African creativity. This content is protected by e-Play DRM — accessible only within the Genie app for the authenticated license holder.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6),
                      ),
                      const SizedBox(height: 20),

                      // Stats row
                      Row(children: [
                        _stat(Icons.headphones, _asset['plays'] as String? ?? '0', 'Plays'),
                        const SizedBox(width: 16),
                        _stat(Icons.star, '4.7', 'Rating'),
                        const SizedBox(width: 16),
                        _stat(Icons.people, '1.2K', 'Owners'),
                      ]),
                      const SizedBox(height: 24),

                      // Access rights
                      _accessRow(Icons.lock_open, 'Perpetual Cloud Access', 'Stream forever after purchase'),
                      _accessRow(Icons.phone_android, 'Cross-device', 'Access from any Genie login'),
                      _accessRow(Icons.download_done, 'Offline Pin', 'Pin for temporary offline use'),
                      _accessRow(Icons.block, 'No Resale', 'DRM-protected — not transferable'),

                      const SizedBox(height: 32),

                      // CTA
                      SizedBox(
                        width: double.infinity,
                        child: _owned
                            ? ElevatedButton.icon(
                                onPressed: () => Navigator.pushNamed(context, AppRoutes.eplayPlayer, arguments: _asset),
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Play Now'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: _purchasing ? null : _purchase,
                                icon: _purchasing ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.add_shopping_cart),
                                label: Text(_purchasing ? 'Processing…' : 'Add to Cloud Locker'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kEPlayColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),

                      if (!_owned)
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.eplayPlayer, arguments: {..._asset, 'preview': true}),
                          icon: const Icon(Icons.preview, color: kEPlayColor),
                          label: const Text('Preview 90s', style: TextStyle(color: kEPlayColor)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: kEPlayColor),
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _purchase() async {
    setState(() => _purchasing = true);
    await Future.delayed(const Duration(milliseconds: 1500)); // API call stub
    if (mounted) {
      setState(() { _purchasing = false; _owned = true; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Added to your Cloud Locker!'),
          backgroundColor: AppColors.success,
          action: SnackBarAction(label: 'View Locker', textColor: Colors.white, onPressed: () => Navigator.pushNamed(context, AppRoutes.eplayLocker)),
        ),
      );
    }
  }

  Widget _typeBadge(String type, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.3))),
      child: Text(type.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _stat(IconData icon, String value, String label) {
    return Column(children: [
      Icon(icon, color: AppColors.textSecondary, size: 18),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
    ]);
  }

  Widget _accessRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, color: kEPlayColor, size: 18),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
      ]),
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
