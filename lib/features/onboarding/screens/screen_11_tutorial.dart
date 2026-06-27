import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/responsive.dart';
import '../providers/onboarding_provider.dart';

/// Screen 12 — Tutorial, 4 slides.
class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _page = PageController();
  int _current = 0;
  static const _total = 4;

  static const _slides = [
    _Slide(
      label: 'TUTORIAL · GENIE AI',
      counter: '01 / 04',
      title: 'Meet Genie',
      description:
          'Tap the gold ✦ in any module to ask Genie for insights, payments, or actions in plain language.',
    ),
    _Slide(
      label: 'TUTORIAL · GO WALLET',
      counter: '02 / 04',
      title: 'GO Wallet',
      description:
          'Send, receive and manage money with zero-friction payments across borders. Instant, secure.',
    ),
    _Slide(
      label: 'TUTORIAL · MARKET',
      counter: '03 / 04',
      title: 'Commerce Market',
      description:
          'Browse thousands of products from verified merchants. Buy, track deliveries, and review sellers.',
    ),
    _Slide(
      label: 'TUTORIAL · UPDATES',
      counter: '04 / 04',
      title: 'Live & Updates',
      description:
          'Stay connected with real-time commerce feeds and live events from your network.',
    ),
  ];

  void _skip() {
    context.read<OnboardingProvider>().completeTutorial();
    Navigator.of(context).pushReplacementNamed(AppRoutes.promptScreen);
  }

  void _next() {
    if (_current < _total - 1) {
      _page.nextPage(
          duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
    } else {
      context.read<OnboardingProvider>().completeTutorial();
      Navigator.of(context)
          .pushReplacementNamed(AppRoutes.promptScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_current];

    return Scaffold(
      backgroundColor: IveTokens.bg,
      body: SafeArea(
        child: Responsive.constrained(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Topbar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Quick tour',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: IveTokens.ink,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _skip,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: IveTokens.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Hatched card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(IveTokens.rMd),
                    child: CustomPaint(
                      painter: _HatchPainter(),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: IveTokens.hairline),
                          borderRadius:
                              BorderRadius.circular(IveTokens.rMd),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          slide.label,
                          style: IveType.mono.copyWith(
                            fontSize: 10,
                            color: IveTokens.ink2,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Slide content (not in PageView — we control manually)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _SlideContent(
                      key: ValueKey(_current),
                      slide: slide,
                    ),
                  ),
                ),
              ),

              // Pagination dots
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: List.generate(_total, (i) {
                    final active = i == _current;
                    return AnimatedContainer(
                      duration: IveTokens.dFast,
                      margin: const EdgeInsets.only(right: 6),
                      width: active ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active ? IveTokens.accent : IveTokens.hairline2,
                        borderRadius: BorderRadius.circular(IveTokens.rPill),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 20),

              // NEXT button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: IveButton.primary(
                  label: _current < _total - 1 ? 'NEXT' : 'GET STARTED',
                  onPressed: _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }
}

// ── Data ─────────────────────────────────────────────────────────────────────

class _Slide {
  final String label;
  final String counter;
  final String title;
  final String description;

  const _Slide({
    required this.label,
    required this.counter,
    required this.title,
    required this.description,
  });
}

class _SlideContent extends StatelessWidget {
  final _Slide slide;
  const _SlideContent({super.key, required this.slide});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          slide.counter,
          style: IveType.mono.copyWith(
            fontSize: 11,
            color: IveTokens.mute,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          slide.title,
          style: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: IveTokens.ink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          slide.description,
          style: const TextStyle(
            fontSize: 14,
            color: IveTokens.ink2,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// ── Hatched card painter ──────────────────────────────────────────────────────

class _HatchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const bg = IveTokens.surface;
    final bgPaint = Paint()..color = bg;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final linePaint = Paint()
      ..color = IveTokens.hairline.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    const spacing = 16.0;
    final count = ((size.width + size.height) / spacing).ceil() + 2;
    for (int i = -2; i < count; i++) {
      final x = i * spacing;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
