import 'package:flutter/material.dart';
import '../../../core/design/ive_tokens.dart';

// OS palette
const Color _kBorder    = IveTokens.hairline;
const Color _kAccent    = IveTokens.accent;
const Color _kAccentDim = IveTokens.accentSoft;
const Color _kText      = IveTokens.ink;
const Color _kTextDim   = IveTokens.ink2;

/// OS-style progress dots  active = accent pill, completed = accent dim, inactive = border.
class ProgressDots extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ProgressDots({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;
        final isCompleted = index < currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive
                ? _kAccent
                : isCompleted
                    ? _kAccentDim
                    : _kBorder,
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
    );
  }
}

/// Thin OS progress bar with optional label.
class StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String? label;

  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              label!,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _kTextDim,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: currentStep / totalSteps,
            backgroundColor: _kBorder,
            valueColor: const AlwaysStoppedAnimation<Color>(_kAccent),
            minHeight: 2,
          ),
        ),
      ],
    );
  }
}

/// Circular completion indicator  OS accent ring.
class CompletionCircle extends StatelessWidget {
  final int score;
  final int total;
  final double size;

  const CompletionCircle({
    super.key,
    required this.score,
    this.total = 100,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = score / total;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: percentage,
            strokeWidth: 4,
            backgroundColor: _kBorder,
            valueColor: AlwaysStoppedAnimation<Color>(_getColor(percentage)),
          ),
          Text(
            '$score',
            style: TextStyle(
              fontSize: size * 0.25,
              fontWeight: FontWeight.w700,
              color: _kText,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(double percentage) {
    if (percentage >= 0.8) return const Color(0xFF10B981);
    if (percentage >= 0.5) return const Color(0xFFF59E0B);
    return _kAccent;
  }
}
