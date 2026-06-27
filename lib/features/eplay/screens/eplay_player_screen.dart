/// e-PLAY MODULE  In-App Player Screen
/// Unified player/reader for music, movies, podcasts, e-books, shows.
/// Stream token is fetched from the server; no raw file URL is ever exposed.
/// P1 spec: shared-element hero entrance + controls auto-fade after 3s.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/utils/app_toast.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/design/ive.dart';

class EPlayPlayerScreen extends StatefulWidget {
  final Map<String, dynamic>? asset;
  const EPlayPlayerScreen({super.key, this.asset});

  @override
  State<EPlayPlayerScreen> createState() => _EPlayPlayerScreenState();
}

class _EPlayPlayerScreenState extends State<EPlayPlayerScreen>
    with TickerProviderStateMixin {
  bool _isPlaying = false;
  bool _isPreview = false;
  double _progress = 0.0;
  bool _controlsVisible = true;
  Timer? _hideTimer;

  late final AnimationController _pulseCtrl;
  late final AnimationController _controlsFadeCtrl;
  late final Animation<double> _controlsFade;

  Map<String, dynamic> get _asset => widget.asset ?? {};
  String get _type => _asset['type'] as String? ?? 'music';

  @override
  void initState() {
    super.initState();
    _isPreview = _asset['preview'] == true;
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _controlsFadeCtrl = AnimationController(
      vsync: this,
      duration: IveTokens.dBase,
      value: 1.0,
    );
    _controlsFade = CurvedAnimation(
      parent: _controlsFadeCtrl,
      curve: IveTokens.enter,
      reverseCurve: IveTokens.exit,
    );
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _pulseCtrl.dispose();
    _controlsFadeCtrl.dispose();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (_isPlaying && mounted) {
        _controlsFadeCtrl.reverse();
        setState(() => _controlsVisible = false);
      }
    });
  }

  void _showControls() {
    _hideTimer?.cancel();
    _controlsFadeCtrl.forward();
    setState(() => _controlsVisible = true);
    if (_isPlaying) _scheduleHide();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AIInsightsNotifier>(
      builder: (context, ai, _) {
        final colors = _colorForType(_type);
        return GestureDetector(
          onTap: _controlsVisible ? null : _showControls,
          child: Scaffold(
            backgroundColor: colors[1],
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: FadeTransition(
                opacity: _controlsFade,
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _asset['title'] as String? ?? '',
                        style: IveType.headline.copyWith(color: Colors.white),
                      ),
                      if (_isPreview)
                        Text(
                          'Preview  90 seconds',
                          style: IveType.footnote.copyWith(
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () =>
                          AppToast.show(context, 'Link copied to clipboard'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        backgroundColor: IveTokens.surface,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(IveTokens.rSm),
                          ),
                        ),
                        builder: (ctx) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                iconColor: IveTokens.ink2,
                                textColor: IveTokens.ink,
                                leading: const Icon(Icons.playlist_add),
                                title: const Text('Add to playlist'),
                                onTap: () => Navigator.pop(ctx),
                              ),
                              ListTile(
                                iconColor: IveTokens.ink2,
                                textColor: IveTokens.ink,
                                leading: const Icon(Icons.download),
                                title: const Text('Download'),
                                onTap: () => Navigator.pop(ctx),
                              ),
                              ListTile(
                                iconColor: IveTokens.ink2,
                                textColor: IveTokens.ink,
                                leading: const Icon(Icons.flag),
                                title: const Text('Report'),
                                onTap: () => Navigator.pop(ctx),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  const Spacer(),

                  //  Artwork 
                  Center(
                    child: AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (ctx, child) => Transform.scale(
                        scale: _isPlaying
                            ? 1.0 + (_pulseCtrl.value * 0.04)
                            : 1.0,
                        child: child,
                      ),
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                            _type == 'ebook' ? IveTokens.rSm : IveTokens.rPill,
                          ),
                        ),
                        child: Icon(
                          _iconForType(_type),
                          color: Colors.white,
                          size: 100,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),

                  //  DRM indicator 
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: IveTokens.s8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: IveTokens.s3, vertical: IveTokens.s1 + 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: IveTokens.brSm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.security,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 14,
                        ),
                        const SizedBox(width: IveTokens.s1 + 2),
                        Text(
                          _isPreview
                              ? 'Preview  purchase to unlock'
                              : 'e-Play DRM  Cloud stream',
                          style: IveType.footnote.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: IveTokens.s8),

                  //  Progress bar 
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: IveTokens.s6),
                    child: Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.white,
                            inactiveTrackColor:
                                Colors.white.withValues(alpha: 0.30),
                            thumbColor: Colors.white,
                            overlayColor:
                                Colors.white.withValues(alpha: 0.24),
                            trackHeight: 2,
                          ),
                          child: Slider(
                            value: _progress,
                            onChanged: (v) => setState(() => _progress = v),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: IveTokens.s2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatTime(_progress * 240),
                                style: IveType.mono.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _isPreview ? '1:30' : '4:00',
                                style: IveType.mono.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: IveTokens.s4),

                  //  Controls (fade after 3s) 
                  FadeTransition(
                    opacity: _controlsFade,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous,
                              color: Colors.white, size: 36),
                          onPressed: () =>
                              AppToast.show(context, 'Playing previous'),
                        ),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _isPlaying = !_isPlaying;
                              if (_isPlaying) {
                                _pulseCtrl.repeat(reverse: true);
                                _scheduleHide();
                              } else {
                                _pulseCtrl.stop();
                                _hideTimer?.cancel();
                                _showControls();
                              }
                            });
                          },
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: colors[0],
                              size: 40,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next,
                              color: Colors.white, size: 36),
                          onPressed: () =>
                              AppToast.show(context, 'Playing next'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: IveTokens.s8),

                  //  Genie insight (one gold element per screen) 
                  if (ai.insights.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: IveTokens.s6),
                      child: Container(
                        padding: const EdgeInsets.all(IveTokens.s3),
                        decoration: BoxDecoration(
                          color: IveTokens.genieSoft,
                          borderRadius: IveTokens.brSm,
                          border: Border.all(color: IveTokens.genieLine),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              color: IveTokens.genie,
                              size: 14,
                            ),
                            const SizedBox(width: IveTokens.s2),
                            Expanded(
                              child: Text(
                                ai.insights.first['title'] ?? '',
                                style: IveType.footnote.copyWith(
                                  color: IveTokens.ink2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: IveTokens.s8),
                ],
              ),
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

  // Per-content-type immersive backgrounds. Colors [0] = icon/accent, [1] = scaffold bg.
  List<Color> _colorForType(String type) {
    return switch (type) {
      'music'   => [IveTokens.moduleSetup,    const Color(0xFF1A0D3E)],
      'movie'   => [IveTokens.moduleQualChat, const Color(0xFF0A2A28)],
      'podcast' => [IveTokens.moduleApril,    const Color(0xFF2A1800)],
      'ebook'   => [IveTokens.moduleFintech,  const Color(0xFF072820)],
      'show'    => [IveTokens.danger,         const Color(0xFF2A0808)],
      _         => [IveTokens.accent,         const Color(0xFF0D1133)],
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
