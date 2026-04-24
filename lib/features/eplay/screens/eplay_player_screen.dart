/// ═══════════════════════════════════════════════════════════════════════════
/// e-PLAY MODULE — In-App Player Screen
/// Unified player/reader for music, movies, podcasts, e-books, shows.
/// Stream token is fetched from the server; no raw file URL is ever exposed.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import 'eplay_hub_screen.dart' show kEPlayColor, kEPlayColorDark;

class EPlayPlayerScreen extends StatefulWidget {
  final Map<String, dynamic>? asset;
  const EPlayPlayerScreen({super.key, this.asset});

  @override
  State<EPlayPlayerScreen> createState() => _EPlayPlayerScreenState();
}

class _EPlayPlayerScreenState extends State<EPlayPlayerScreen> with TickerProviderStateMixin {
  bool _isPlaying = false;
  bool _isPreview = false;
  double _progress = 0.0;
  late final AnimationController _pulseCtrl;

  Map<String, dynamic> get _asset => widget.asset ?? {};
  String get _type => _asset['type'] as String? ?? 'music';

  @override
  void initState() {
    super.initState();
    _isPreview = _asset['preview'] == true;
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AIInsightsNotifier>(
      builder: (context, ai, _) {
        final colors = _colorForType(_type);
        return Scaffold(
          backgroundColor: colors[1],
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_asset['title'] as String? ?? '', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                if (_isPreview)
                  const Text('Preview Mode — 90 seconds', style: TextStyle(color: Colors.white60, fontSize: 11)),
              ],
            ),
            actions: [
              IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: () {}),
              IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {}),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                const Spacer(),

                // ── Artwork ────────────────────────────────────────────
                Center(
                  child: AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (ctx, child) {
                      return Transform.scale(
                        scale: _isPlaying ? 1.0 + (_pulseCtrl.value * 0.04) : 1.0,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(_type == 'ebook' ? 12 : 110),
                        boxShadow: [BoxShadow(color: colors[0].withOpacity(0.6), blurRadius: 40, spreadRadius: 10)],
                      ),
                      child: Icon(_iconForType(_type), color: Colors.white, size: 100),
                    ),
                  ),
                ),
                const Spacer(),

                // ── DRM indicator ──────────────────────────────────────
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.security, color: Colors.white70, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        _isPreview ? 'Preview — Purchase to unlock full access' : 'e-Play DRM · Cloud Stream',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── Progress bar ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white30,
                          thumbColor: Colors.white,
                          overlayColor: Colors.white24,
                        ),
                        child: Slider(
                          value: _progress,
                          onChanged: (v) => setState(() => _progress = v),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatTime(_progress * 240), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            Text(_isPreview ? '1:30' : '4:00', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Controls ───────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(icon: const Icon(Icons.skip_previous, color: Colors.white, size: 36), onPressed: () {}),
                    GestureDetector(
                      onTap: () => setState(() {
                        _isPlaying = !_isPlaying;
                        if (_isPlaying) {
                          _pulseCtrl.repeat(reverse: true);
                        } else {
                          _pulseCtrl.stop();
                        }
                      }),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 20)]),
                        child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: colors[0], size: 40),
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.skip_next, color: Colors.white, size: 36), onPressed: () {}),
                  ],
                ),
                const SizedBox(height: 32),

                // ── AI insight ─────────────────────────────────────────
                if (ai.insights.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Row(children: [
                        const Icon(Icons.auto_awesome, color: Colors.white70, size: 14),
                        const SizedBox(width: 8),
                        Expanded(child: Text(ai.insights.first['title'] ?? '', style: const TextStyle(fontSize: 11, color: Colors.white70))),
                      ]),
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(double seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toInt().toString().padLeft(2, '0');
    return '$m:$s';
  }

  List<Color> _colorForType(String type) {
    return switch (type) {
      'music'   => [const Color(0xFF7C3AED), const Color(0xFF4C1D95)],
      'movie'   => [const Color(0xFF0F766E), const Color(0xFF134E4A)],
      'podcast' => [const Color(0xFFD97706), const Color(0xFF92400E)],
      'ebook'   => [const Color(0xFF059669), const Color(0xFF064E3B)],
      'show'    => [const Color(0xFFDC2626), const Color(0xFF7F1D1D)],
      _         => [const Color(0xFF6366F1), const Color(0xFF312E81)],
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
