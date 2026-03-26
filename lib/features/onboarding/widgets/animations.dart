import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Simple particle system for splash screen effects
class ParticleSystem extends StatefulWidget {
  final int particleCount;
  final double width;
  final double height;
  final List<Color> colors;
  final bool isActive;

  const ParticleSystem({
    super.key,
    this.particleCount = 50,
    required this.width,
    required this.height,
    this.colors = const [
      Colors.white24,
      Colors.white12,
      Color(0x40FFD700),
    ],
    this.isActive = true,
  });

  @override
  State<ParticleSystem> createState() => _ParticleSystemState();
}

class _ParticleSystemState extends State<ParticleSystem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _particles = List.generate(
      widget.particleCount,
      (_) => _createParticle(),
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  _Particle _createParticle() {
    return _Particle(
      x: _random.nextDouble() * widget.width,
      y: _random.nextDouble() * widget.height,
      size: _random.nextDouble() * 3 + 1,
      speed: _random.nextDouble() * 0.5 + 0.1,
      opacity: _random.nextDouble() * 0.6 + 0.1,
      color: widget.colors[_random.nextInt(widget.colors.length)],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _ParticlePainter(
            particles: _particles,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _Particle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;
  Color color;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.color,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final y = (particle.y - progress * particle.speed * 200) % size.height;
      final paint = Paint()
        ..color = particle.color.withOpacity(
          particle.opacity * (0.5 + 0.5 * sin(progress * pi * 2 + particle.x)),
        )
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(particle.x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}

/// Sparkle effect widget
class SparkleEffect extends StatefulWidget {
  final Widget child;
  final bool isActive;

  const SparkleEffect({
    super.key,
    required this.child,
    this.isActive = true,
  });

  @override
  State<SparkleEffect> createState() => _SparkleEffectState();
}

class _SparkleEffectState extends State<SparkleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Colors.white.withOpacity(0.0),
              Colors.white.withOpacity(0.3 * _controller.value),
              Colors.white.withOpacity(0.0),
            ],
            stops: [
              (_controller.value - 0.3).clamp(0.0, 1.0),
              _controller.value,
              (_controller.value + 0.3).clamp(0.0, 1.0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}

/// Glow pulse animation for lamp
class GlowPulse extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double maxBlur;

  const GlowPulse({
    super.key,
    required this.child,
    this.glowColor = AppColors.accent,
    this.maxBlur = 20,
  });

  @override
  State<GlowPulse> createState() => _GlowPulseState();
}

class _GlowPulseState extends State<GlowPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.glowColor
                    .withOpacity(0.3 + 0.3 * _controller.value),
                blurRadius: widget.maxBlur * (0.5 + 0.5 * _controller.value),
                spreadRadius: 2 + 4 * _controller.value,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}
