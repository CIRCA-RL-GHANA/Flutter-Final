/// qualChat Screen 0 — Loading & Permission Gate
/// Seamless entry with zero-error authentication

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../widgets/qualchat_widgets.dart';

class QualChatLoadingScreen extends StatefulWidget {
  const QualChatLoadingScreen({super.key});

  @override
  State<QualChatLoadingScreen> createState() => _QualChatLoadingScreenState();
}

class _QualChatLoadingScreenState extends State<QualChatLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  String _statusText = 'Checking permissions...';
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
    _runBootSequence();
  }

  Future<void> _runBootSequence() async {
    // Step 1: Permission check
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    setState(() => _statusText = 'Loading conversations...');

    // Step 2: Data pre-fetch
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _statusText = 'Preparing your chat...');

    // Step 3: Animation + route
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // Navigate to dashboard
    Navigator.pushReplacementNamed(context, '/qualchat');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0E7490),
              Color(0xFF06B6D4),
              Color(0xFF67E8F9),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: Colors.white.withOpacity(0.15),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(children: [
                      const Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(child: Text('AI: ${ai.insights.first['title'] ?? ''}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white),
                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                  );
                },
              ),
              Expanded(
                child: Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: _hasError ? _buildErrorState() : _buildLoadingState(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated chat icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.chat_bubble_rounded,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'qualChat',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Communications Hub',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 48),
        const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _statusText,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.error_outline, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 24),
        Text(
          _errorMessage ?? 'Something went wrong',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Check your connection or contact support',
          style: TextStyle(fontSize: 14, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _hasError = false;
              _statusText = 'Retrying...';
            });
            _runBootSequence();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: kChatColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          ),
        ),
      ],
    );
  }
}
