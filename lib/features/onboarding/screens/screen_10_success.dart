import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/buttons.dart';

/// Screen 10: Sign Up Success (Celebration)
/// Achievement recognition with clear next steps
class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late AnimationController _contentController;
  late AnimationController _confettiController;

  late Animation<double> _checkmarkScale;
  late Animation<double> _titleOpacity;
  late Animation<double> _cardsOpacity;

  final PageController _carouselController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  // Simple confetti particles
  late List<_ConfettiParticle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Generate confetti particles
    _particles = List.generate(100, (_) => _ConfettiParticle(
      x: _random.nextDouble(),
      y: _random.nextDouble() * -1.0,
      size: _random.nextDouble() * 8 + 4,
      speed: _random.nextDouble() * 2 + 1,
      color: AppColors.confettiColors[_random.nextInt(AppColors.confettiColors.length)],
      rotation: _random.nextDouble() * 2 * pi,
    ));

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Checkmark scale: 0 → 1.2 → 1.0
    _checkmarkScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_celebrationController);

    _titleOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _cardsOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start animations
    _celebrationController.forward().then((_) {
      _contentController.forward();
    });
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _contentController.dispose();
    _confettiController.dispose();
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingProvider>();
    final name = onboarding.firstName.isNotEmpty
        ? onboarding.firstName
        : 'there';

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A237E),
                  Color(0xFF0F0F23),
                ],
              ),
            ),
          ),

          // Confetti
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _ConfettiPainter(
                  particles: _particles,
                  progress: _confettiController.value,
                ),
              );
            },
          ),

          // Content
          SafeArea(
            child: Responsive.constrained(
              child: Column(
                children: [
                  const SizedBox(height: 48),

                  // Animated checkmark
                  AnimatedBuilder(
                    animation: _checkmarkScale,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _checkmarkScale.value,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.success,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.success.withOpacity(0.4),
                                blurRadius: 24,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Title
                  AnimatedBuilder(
                    animation: _titleOpacity,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _titleOpacity.value,
                        child: Column(
                          children: [
                            Text(
                              '${AppStrings.welcomeTo} $name!',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppStrings.accountReady,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Feature Introduction Carousel
                  AnimatedBuilder(
                    animation: _cardsOpacity,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _cardsOpacity.value,
                        child: child,
                      );
                    },
                    child: SizedBox(
                      height: 160,
                      child: PageView(
                        controller: _carouselController,
                        onPageChanged: (index) =>
                            setState(() => _currentPage = index),
                        children: const [
                          _FeatureCard(
                            emoji: '🎯',
                            title: 'Your PROMPT Screen',
                            subtitle: 'Everything you need, personalized',
                          ),
                          _FeatureCard(
                            emoji: '💸',
                            title: 'GO PAGE Financial Hub',
                            subtitle: 'Manage QPoints and transactions',
                          ),
                          _FeatureCard(
                            emoji: '🛍️',
                            title: 'MARKET Shopping',
                            subtitle: 'Shop from local businesses',
                          ),
                          _FeatureCard(
                            emoji: '💬',
                            title: 'qualChat Connect',
                            subtitle: 'Message anyone in the ecosystem',
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Page indicator
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _currentPage == index ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.accent
                              : Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  const Spacer(),

                  // Action buttons
                  FadeTransition(
                    opacity: _cardsOpacity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // Primary: Explore Genie
                          PrimaryButton(
                            text: AppStrings.explorePrompt,
                            icon: Icons.auto_awesome,
                            onPressed: () {
                              // Navigate to Genie home (replaces PROMPT screen)
                              Navigator.of(context)
                                  .pushReplacementNamed(AppRoutes.genieHome);
                            },
                            margin: EdgeInsets.zero,
                          ),

                          const SizedBox(height: 12),

                          // Secondary: Take Tour
                          OutlinedActionButton(
                            text: AppStrings.takeTour,
                            icon: Icons.explore_outlined,
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(AppRoutes.tutorial);
                            },
                          ),

                          const SizedBox(height: 8),

                          // Tertiary: Skip to Dashboard
                          SecondaryButton(
                            text: AppStrings.skipToDashboard,
                            color: Colors.white60,
                            onPressed: () {
                              Navigator.of(context)
                                  .pushReplacementNamed(AppRoutes.genieHome);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Support link
                  FadeTransition(
                    opacity: _cardsOpacity,
                    child: Text(
                      AppStrings.needHelp,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const _FeatureCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ConfettiParticle {
  double x, y, size, speed, rotation;
  Color color;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
    required this.rotation,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final x = p.x * size.width;
      final y = ((p.y + progress * p.speed) % 1.5) * size.height;
      final opacity = (1.0 - (y / size.height)).clamp(0.0, 0.8);

      if (opacity > 0) {
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(p.rotation + progress * 2);

        final paint = Paint()
          ..color = p.color.withOpacity(opacity)
          ..style = PaintingStyle.fill;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
            const Radius.circular(2),
          ),
          paint,
        );

        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
