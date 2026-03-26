import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive.dart';
import '../providers/onboarding_provider.dart';

/// Screen 1: Luxurious Splash Screen
/// Brand immersion with functional loading
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _glowController;
  late AnimationController _particleController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _titleOpacity;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _taglineOpacity;

  bool _isLoading = true;
  final List<_SplashParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initParticles();
    _initAnimations();
    _initializeApp();
  }

  void _initParticles() {
    for (int i = 0; i < 50; i++) {
      _particles.add(_SplashParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 3 + 1,
        speed: _random.nextDouble() * 0.3 + 0.1,
        opacity: _random.nextDouble() * 0.5 + 0.1,
      ));
    }
  }

  void _initAnimations() {
    // Main entrance controller
    _mainController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Glow pulse controller
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    // Particle controller
    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Logo scale: 0 → 1.1 → 1.0
    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.5),
    ));

    _logoOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _titleOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.5, curve: Curves.easeIn),
      ),
    );

    _subtitleOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.5, 0.7, curve: Curves.easeIn),
      ),
    );

    _taglineOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    // Check for reduced motion preference
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (prefersReducedMotion(context)) {
        _mainController.value = 1.0;
      } else {
        _mainController.forward();
      }
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Run parallel initialization tasks
      await Future.wait([
        _loadCountryCodes(),
        _cacheEssentialAssets(),
        _initializeLocalDB(),
        Future.delayed(const Duration(seconds: 3)), // Minimum splash time
      ]);
    } catch (e) {
      debugPrint('Init error: $e');
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Complete splash
    context.read<OnboardingProvider>().completeSplash();

    // Navigate after brief delay
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
  }

  Future<void> _loadCountryCodes() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In production: Fetch country codes from API/cache
  }

  Future<void> _cacheEssentialAssets() async {
    await Future.delayed(const Duration(milliseconds: 400));
    // In production: Pre-cache images, animations
  }

  Future<void> _initializeLocalDB() async {
    await Future.delayed(const Duration(milliseconds: 600));
    // In production: Initialize Hive boxes
  }

  @override
  void dispose() {
    _mainController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Semantics(
        label: AppStrings.splashLoading,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColors.splashGradient,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Particle system
              AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  return CustomPaint(
                    size: size,
                    painter: _SplashParticlePainter(
                      particles: _particles,
                      progress: _particleController.value,
                    ),
                  );
                },
              ),

              // Main content
              AnimatedBuilder(
                animation: _mainController,
                builder: (context, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Magic Lamp Logo with Glow
                      AnimatedBuilder(
                        animation: _glowController,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withOpacity(
                                    0.2 + 0.2 * _glowController.value,
                                  ),
                                  blurRadius:
                                      20 + 15 * _glowController.value,
                                  spreadRadius:
                                      2 + 4 * _glowController.value,
                                ),
                              ],
                            ),
                            child: Opacity(
                              opacity: _logoOpacity.value,
                              child: Transform.scale(
                                scale: _logoScale.value,
                                child: Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        AppColors.accent.withOpacity(0.3),
                                        AppColors.accent.withOpacity(0.1),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome,
                                    size: 80,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // "PROMPT" title
                      Opacity(
                        opacity: _titleOpacity.value,
                        child: const Text(
                          AppStrings.splashTitle,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      // "Genie" subtitle
                      Opacity(
                        opacity: _subtitleOpacity.value,
                        child: Text(
                          AppStrings.splashSubtitle,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                            color: AppColors.accent.withOpacity(0.9),
                            fontStyle: FontStyle.italic,
                            letterSpacing: 2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Loading indicator
                      Opacity(
                        opacity: _taglineOpacity.value,
                        child: Column(
                          children: [
                            SizedBox(
                              width: 120,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  backgroundColor: Colors.white12,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          AppColors.accent),
                                  minHeight: 2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isLoading
                                  ? 'Loading your experience...'
                                  : 'Ready!',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white54,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashParticle {
  double x, y, size, speed, opacity;
  _SplashParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class _SplashParticlePainter extends CustomPainter {
  final List<_SplashParticle> particles;
  final double progress;

  _SplashParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final x = p.x * size.width;
      final y = ((p.y - progress * p.speed) % 1.0) * size.height;
      final alpha = p.opacity * (0.5 + 0.5 * sin(progress * pi * 2 + p.x * 10));

      final paint = Paint()
        ..color = Colors.white.withOpacity(alpha.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
