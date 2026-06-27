/// 
/// e-PLAY MODULE  Asset Detail Screen
/// DRM content detail page: purchase  adds to cloud locker.
/// No file is downloaded  access lives in the server-side license.
/// 
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive.dart';
import '../../../core/routes/app_routes.dart';
import '../providers/eplay_provider.dart';
import 'eplay_hub_screen.dart' show kEPlayColor;

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
    final type = _asset['type'] as String? ?? 'other';
    final title = _asset['title'] as String? ?? 'Untitled';
    final creator = _asset['creator'] as String? ?? 'Unknown';
    final price = _asset['price'] as num? ?? 0;
    final rating = _asset['rating'] as num? ?? 0;
    final downloads = _asset['downloads'] as num? ?? 0;
    final colors = _colorForType(type);
    final icon = _iconForType(type);

    return Scaffold(
      backgroundColor: IveTokens.bg,
      body: CustomScrollView(
        slivers: [
          //  Hero cover 
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: colors[0],
            foregroundColor: IveTokens.ink,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Icon(icon, size: 80, color: IveTokens.ink.withValues(alpha: 0.9)),
                    const SizedBox(height: 12),
                    _typeBadge(type, IveTokens.ink),
                  ],
                ),
              ),
            ),
          ),

          //  Content 
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: IveTokens.ink)),
                  const SizedBox(height: 4),
                  Text('by $creator', style: const TextStyle(fontSize: 14, color: IveTokens.ink2)),

                  const SizedBox(height: 16),

                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _stat(Icons.star, rating.toStringAsFixed(1), 'Rating'),
                      _stat(Icons.download, '${downloads}K', 'Downloads'),
                      _stat(Icons.lock_open, 'DRM', 'Protected'),
                    ],
                  ),

                  Divider(height: 32, color: IveTokens.hairline),

                  // Access info
                  const Text('What you get', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: IveTokens.ink)),
                  const SizedBox(height: 12),
                  _accessRow(Icons.cloud, 'Cloud Locker Access', 'Stream anytime, anywhere'),
                  _accessRow(Icons.devices, 'Multi-device', 'Up to 3 devices'),
                  _accessRow(Icons.update, 'Lifetime Access', 'No expiry after purchase'),

                  const SizedBox(height: 24),

                  // Price + CTA
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Price', style: TextStyle(fontSize: 11, color: IveTokens.mute)),
                          Text(
                            price == 0 ? 'Free' : '\$${price.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: IveTokens.moduleEplay),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: IveButton.primary(
                          label: _owned ? 'In Locker' : price == 0 ? 'Add to Locker' : 'Purchase',
                          onPressed: _owned || _purchasing ? null : _purchase,
                          isLoading: _purchasing,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _purchase() async {
    final assetId = _asset['id'] as String?;
    setState(() => _purchasing = true);
    if (assetId != null) {
      await context.read<EPlayProvider>().purchaseAsset(assetId);
    } else {
      // Fallback for screens opened with stub data (no id)
      await Future.delayed(const Duration(milliseconds: 800));
    }
    if (mounted) {
      setState(() { _purchasing = false; _owned = true; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Added to your Cloud Locker!'),
          backgroundColor: IveTokens.success,
          action: SnackBarAction(label: 'View Locker', textColor: IveTokens.ink, onPressed: () => Navigator.pushNamed(context, AppRoutes.eplayLocker)),
        ),
      );
    }
  }

  Widget _typeBadge(String type, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(IveTokens.rSm),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(type.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _stat(IconData icon, String value, String label) {
    return Column(children: [
      Icon(icon, color: IveTokens.ink2, size: 18),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: IveTokens.ink)),
      Text(label, style: const TextStyle(fontSize: 10, color: IveTokens.mute)),
    ]);
  }

  Widget _accessRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, color: IveTokens.moduleEplay, size: 18),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: IveTokens.ink)),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: IveTokens.ink2)),
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
      _         => [IveTokens.accent, const Color(0xFF4F46E5)],
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
