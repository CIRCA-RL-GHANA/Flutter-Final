import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/hex_mark.dart';
import '../providers/onboarding_provider.dart';
import '../../../core/network/api_client.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fade;

  double _loadProgress = 0.0;
  int _bootLineIndex = 0;

  static const List<String> _bootLines = [
    'Initializing commerce layer_',
    'Connecting payment nodes_',
    'Loading AI intelligence_',
    'Syncing merchant data_',
    'System ready.',
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (prefersReducedMotion(context)) {
        _fadeController.value = 1.0;
        setState(() {
          _bootLineIndex = _bootLines.length - 1;
          _loadProgress = 1.0;
        });
      } else {
        _fadeController.forward();
      }
    });

    _runBootSequence();
    _initializeApp();
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
      await Future.delayed(const Duration(seconds: 3));
    } catch (_) {}

    if (!mounted) return;
    context.read<OnboardingProvider>().completeSplash();

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final destination = ApiClient.instance.isAuthenticated
        ? AppRoutes.genieHome
        : AppRoutes.welcome;
    Navigator.of(context).pushReplacementNamed(destination);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IveTokens.bg,
      body: FadeTransition(
        opacity: _fade,
        child: Column(
          children: [
            const Spacer(flex: 3),

            // Hex mark with glow
            const Center(child: HexMark(size: 72, glow: true)),
            const SizedBox(height: 24),

            // App name
            Text(
              'Commerce OS',
              style: IveType.display.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: IveTokens.ink,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 12),

            // Boot lines — last two stack when near end
            SizedBox(
              height: 36,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_bootLineIndex > 0)
                    Text(
                      _bootLines[_bootLineIndex - 1],
                      style: IveType.mono.copyWith(
                        fontSize: 11,
                        color: IveTokens.mute,
                        letterSpacing: 0.2,
                      ),
                    ),
                  Text(
                    _bootLines[_bootLineIndex],
                    style: IveType.mono.copyWith(
                      fontSize: 11,
                      color: IveTokens.mute,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Segmented progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: _SegmentedBar(
                progress: _loadProgress,
                segments: _bootLines.length,
              ),
            ),

            const Spacer(flex: 4),
          ],
        ),
      ),
    );
  }
}

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
            duration: IveTokens.dFast,
            height: 2,
            margin: EdgeInsets.only(right: i < segments - 1 ? 4 : 0),
            decoration: BoxDecoration(
              color: filled ? IveTokens.accent : IveTokens.hairline,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        );
      }),
    );
  }
}
