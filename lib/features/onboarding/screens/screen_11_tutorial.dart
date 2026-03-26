import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/buttons.dart';
import '../widgets/progress_indicators.dart';

/// Screen 11: Interactive Tutorial (Optional)
/// Learn by doing, not by reading
class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 5;

  final List<_TutorialStep> _steps = [
    _TutorialStep(
      title: 'Your PROMPT Screen',
      description: 'This is your personalized dashboard. Tap any widget to interact with it.',
      icon: Icons.dashboard_customize_outlined,
      color: AppColors.primaryLight,
      instruction: 'Tap to explore widgets',
    ),
    _TutorialStep(
      title: 'Widget Interactions',
      description: 'Swipe left/right to navigate. Long-press to customize. Tap to open.',
      icon: Icons.touch_app_outlined,
      color: AppColors.roleShop,
      instruction: 'Try swiping, tapping, and long-pressing',
    ),
    _TutorialStep(
      title: 'Your Role Features',
      description: 'Based on your selected role, you have unique features and widgets.',
      icon: Icons.person_outline,
      color: AppColors.roleBuyer,
      instruction: 'Explore your role-specific tools',
    ),
    _TutorialStep(
      title: 'Quick Actions',
      description: 'The most common tasks are just one tap away from your home screen.',
      icon: Icons.flash_on_outlined,
      color: AppColors.roleDelivery,
      instruction: 'Try the quick action buttons',
    ),
    _TutorialStep(
      title: 'Get Help Anytime',
      description: 'Tap the help icon anywhere in the app to get instant assistance.',
      icon: Icons.help_outline,
      color: AppColors.info,
      instruction: 'Look for the help icon',
    ),
  ];

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeTutorial();
    }
  }

  void _completeTutorial() {
    context.read<OnboardingProvider>().completeTutorial();
    Navigator.of(context).pushReplacementNamed(AppRoutes.promptScreen);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Responsive.constrained(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.tutorialTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: _completeTutorial,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Progress
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: StepProgressBar(
                  currentStep: _currentStep + 1,
                  totalSteps: _totalSteps,
                ),
              ),

              // Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _currentStep = index),
                  itemCount: _totalSteps,
                  itemBuilder: (context, index) {
                    final step = _steps[index];
                    return _TutorialStepView(step: step);
                  },
                ),
              ),

              // Navigation
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Row(
                  children: [
                    // Step counter
                    Text(
                      '${_currentStep + 1} / $_totalSteps',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const Spacer(),

                    // Next / Complete button
                    SizedBox(
                      width: 160,
                      child: PrimaryButton(
                        text: _currentStep == _totalSteps - 1
                            ? 'Complete'
                            : 'Next',
                        icon: _currentStep == _totalSteps - 1
                            ? Icons.check
                            : Icons.arrow_forward,
                        onPressed: _nextStep,
                        margin: EdgeInsets.zero,
                        height: 48,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TutorialStep {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String instruction;

  const _TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.instruction,
  });
}

class _TutorialStepView extends StatelessWidget {
  final _TutorialStep step;

  const _TutorialStepView({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration area
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: step.color.withOpacity(0.08),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: step.color.withOpacity(0.15),
                      width: 2,
                    ),
                  ),
                ),
                // Icon
                Icon(
                  step.icon,
                  size: 72,
                  color: step.color,
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Title
          Text(
            step.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Description
          Text(
            step.description,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Interactive instruction
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: step.color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: step.color.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.touch_app, size: 18, color: step.color),
                const SizedBox(width: 8),
                Text(
                  step.instruction,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: step.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
