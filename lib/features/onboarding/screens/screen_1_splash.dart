import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_logo.dart';
import '../providers/onboarding_provider.dart';

/// Screen 1: OS Boot Splash Screen
/// Communicates scale and authority — genie help as global commerce infrastructure.
/// Aesthetic: dark system boot, geometric logo mark, sequential init messages,
/// segmented progress bar. No consumer sparkles.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// ── OS palette (independent of consumer theme) ───────────────────────────────
const Color _kBg       = Color(0xFF08080F); // near-black with blue tint
const Color _kGrid     = Color(0xFF0E0E1A); // subtle grid lines
const Color _kAccent   = Color(0xFF22BDD8); // electric blue — system authority
const Color _kAccentDim = Color(0xFF1E2A6E);

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bootController;
  late AnimationController _gridController;

  late Animation<double> _logoOpacity;
  late Animation<double> _wordmarkOpacity;
  late Animation<double> _footerOpacity;

  double _loadProgress = 0.0;
  int _bootLineIndex = 0;

  static const List<String> _bootLines = [
    'Initializing commerce layer...',
    'Connecting payment nodes...',
    'Loading AI intelligence...',
    'Syncing merchant data...',
    'System ready.',
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _runBootSequence();
    _initializeApp();
  }

  void _initAnimations() {
    _bootController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _gridController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();

    _logoOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bootController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    _wordmarkOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bootController,
        curve: const Interval(0.3, 0.65, curve: Curves.easeIn),
      ),
    );

    _footerOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bootController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (prefersReducedMotion(context)) {
        _bootController.value = 1.0;
        setState(() {
          _bootLineIndex = _bootLines.length - 1;
          _loadProgress = 1.0;
        });
      } else {
        _bootController.forward();
      }
    });
  }

  Future<void> _runBootSequence() async {
    for (int i = 0; i < _bootLines.length; i++) {
      await Future.delayed(const Duration(milliseconds: 520));
      if (!mounted) return;
      setState(() {
        _bootLineIndex = i;
        _loadProgress = (i + 1) / _bootLines.length;
      });
    }
  }

  Future<void> _initializeApp() async {
    try {
      await Future.wait([
        Future.delayed(const Duration(milliseconds: 500)),
        Future.delayed(const Duration(milliseconds: 400)),
        Future.delayed(const Duration(milliseconds: 600)),
        Future.delayed(const Duration(seconds: 3)),
      ]);
    } catch (e) {
      debugPrint('Init error: $e');
    }

    if (!mounted) return;
    context.read<OnboardingProvider>().completeSplash();

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
  }

  @override
  void dispose() {
    _bootController.dispose();
    _gridController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _kBg,
      body: Semantics(
        label: AppStrings.splashLoading,
        child: Stack(
          children: [
            // ── Background: scrolling topology grid ───────────────────────
            AnimatedBuilder(
              animation: _gridController,
              builder: (_, __) => CustomPaint(
                size: size,
                painter: _GridPainter(progress: _gridController.value),
              ),
            ),

            // ── Main content ──────────────────────────────────────────────
            AnimatedBuilder(
              animation: _bootController,
              builder: (_, __) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),

                    // Logo mark
                    Opacity(
                      opacity: _logoOpacity.value,
                      child: const _OsLogoMark(),
                    ),

                    const SizedBox(height: 28),

                    // Wordmark: "genie" / "help" / badge
                    Opacity(
                      opacity: _wordmarkOpacity.value,
                      child: Column(
                        children: [
                          Text(
                            AppStrings.splashTitle,
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppStrings.splashSubtitle,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w300,
                              color: Colors.white.withOpacity(0.38),
                              letterSpacing: 5,
                            ),
                          ),
                          const SizedBox(height: 14),
                          // System badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: _kAccent.withOpacity(0.35)),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              'COMMERCE OS  ·  v1.0',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: _kAccent.withOpacity(0.65),
                                letterSpacing: 2.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 3),

                    // ── Boot footer ───────────────────────────────────────
                    Opacity(
                      opacity: _footerOpacity.value,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(40, 0, 40, 52),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Current init message
                            SizedBox(
                              height: 16,
                              child: Text(
                                _bootLines[_bootLineIndex],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.30),
                                  letterSpacing: 0.3,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Segmented progress bar
                            _SegmentedBar(
                              progress: _loadProgress,
                              segments: _bootLines.length,
                            ),

                            const SizedBox(height: 5),

                            // Percentage — right aligned
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${(_loadProgress * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _kAccent.withOpacity(0.45),
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── OS Logo Mark — genie help brand mark ────────────────────────────────────
class _OsLogoMark extends StatelessWidget {
  const _OsLogoMark();

  @override
  Widget build(BuildContext context) {
    return const AppLogo.icon(
      size: 84,
      variant: AppLogoVariant.dark,
      semanticsLabel: 'genie help',
    );
  }
}

// ─── Segmented progress bar ──────────────────────────────────────────────────
class _SegmentedBar extends StatelessWidget {
  final double progress;
  final int segments;
  const _SegmentedBar({required this.progress, required this.segments});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(segments, (i) {
        final filled = (i + 1) / segments <= progress + 0.001;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 2,
            margin: EdgeInsets.only(right: i < segments - 1 ? 3 : 0),
            decoration: BoxDecoration(
              color: filled ? _kAccent : _kAccent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Background grid painter ─────────────────────────────────────────────────
// Slow-scrolling topology grid — suggests global infrastructure scale.
class _GridPainter extends CustomPainter {
  final double progress;
  const _GridPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const cell = 38.0;
    final cols = (size.width / cell).ceil() + 1;
    final rows = (size.height / cell).ceil() + 1;
    final offsetY = (progress * cell) % cell;

    final line = Paint()
      ..color = _kGrid
      ..strokeWidth = 0.5;

    for (int x = 0; x <= cols; x++) {
      canvas.drawLine(
        Offset(x * cell, 0),
        Offset(x * cell, size.height),
        line,
      );
    }
    for (int y = 0; y <= rows; y++) {
      canvas.drawLine(
        Offset(0, y * cell - offsetY),
        Offset(size.width, y * cell - offsetY),
        line,
      );
    }

    // Sparse accent nodes at grid intersections
    final node = Paint()..color = _kAccent.withOpacity(0.10);
    for (int x = 0; x <= cols; x++) {
      for (int y = 0; y <= rows; y++) {
        if ((x + y) % 5 == 0) {
          canvas.drawCircle(
            Offset(x * cell, y * cell - offsetY),
            1.4,
            node,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) =>
      old.progress != progress;
}
