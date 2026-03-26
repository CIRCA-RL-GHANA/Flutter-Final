import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Onboarding step progress dots
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
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primaryLight
                : isCompleted
                    ? AppColors.primaryLight.withOpacity(0.5)
                    : AppColors.validationEmpty,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

/// Step progress bar with label
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
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: currentStep / totalSteps,
            backgroundColor: AppColors.inputFill,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}

/// Circular completion indicator
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
            strokeWidth: 6,
            backgroundColor: AppColors.inputFill,
            valueColor:
                AlwaysStoppedAnimation<Color>(_getColor(percentage)),
          ),
          Text(
            '$score',
            style: TextStyle(
              fontSize: size * 0.25,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(double percentage) {
    if (percentage >= 0.8) return AppColors.success;
    if (percentage >= 0.5) return AppColors.warning;
    return AppColors.primaryLight;
  }
}
