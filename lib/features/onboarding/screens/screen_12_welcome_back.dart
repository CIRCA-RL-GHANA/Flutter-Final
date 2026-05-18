import 'package:flutter/material.dart';
import '../../../core/design/ive.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/buttons.dart';


// OS palette ï¿½ mirrors splash / welcome
const Color _kBg        = IveTokens.bg;
const Color _kSurface   = IveTokens.surface;
const Color _kBorder    = IveTokens.hairline;
const Color _kAccent    = IveTokens.accent;
const Color _kAccentDim = IveTokens.accentPressed;
const Color _kText      = IveTokens.label;
const Color _kTextDim   = IveTokens.labelSecondary;
const Color _kTextMuted = IveTokens.labelTertiary;
/// Screen 12: Existing User Welcome Back
/// Warm re-engagement with context awareness
class WelcomeBackScreen extends StatefulWidget {
  const WelcomeBackScreen({super.key});

  @override
  State<WelcomeBackScreen> createState() => _WelcomeBackScreenState();
}

class _WelcomeBackScreenState extends State<WelcomeBackScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// Determine personalized welcome message based on last login
  _WelcomeContext _getWelcomeContext(OnboardingProvider onboarding) {
    final lastLogin = onboarding.lastLoginDate;
    if (lastLogin == null) {
      return const _WelcomeContext(
        greeting: AppStrings.welcomeBack,
        emoji: 'ðŸ‘‹',
        showWhatsNew: false,
        daysSince: 0,
      );
    }

    final daysSince = DateTime.now().difference(lastLogin).inDays;

    if (daysSince < 7) {
      return _WelcomeContext(
        greeting: AppStrings.welcomeBack,
        emoji: 'ðŸ‘‹',
        showWhatsNew: false,
        daysSince: daysSince,
      );
    } else if (daysSince < 30) {
      return _WelcomeContext(
        greeting: AppStrings.missedYou,
        emoji: 'ðŸ’™',
        showWhatsNew: false,
        daysSince: daysSince,
      );
    } else if (daysSince < 90) {
      return _WelcomeContext(
        greeting: AppStrings.whatsNew,
        emoji: 'ðŸŽ‰',
        showWhatsNew: true,
        daysSince: daysSince,
      );
    } else {
      return _WelcomeContext(
        greeting: AppStrings.refreshAccount,
        emoji: 'ðŸ”„',
        showWhatsNew: true,
        daysSince: daysSince,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingProvider>();
    final welcomeCtx = _getWelcomeContext(onboarding);
    final name = onboarding.firstName.isNotEmpty
        ? onboarding.firstName
        : 'User';

    return Scaffold(
      body: Container(
        color: _kBg,
        child: SafeArea(
          child: Responsive.constrained(
            child: Column(
              children: [
                // Back button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _kSurface,
                          borderRadius: IveTokens.brMd,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: _kText,
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),

                        // Welcome emoji
                        FadeTransition(
                          opacity: CurvedAnimation(
                            parent: _animController,
                            curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
                          ),
                          child: Text(
                            welcomeCtx.emoji,
                            style: const TextStyle(fontSize: 72),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Greeting
                        FadeTransition(
                          opacity: CurvedAnimation(
                            parent: _animController,
                            curve: const Interval(0.2, 0.6, curve: Curves.easeIn),
                          ),
                          child: Text(
                            welcomeCtx.greeting,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: _kText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 8),

                        FadeTransition(
                          opacity: CurvedAnimation(
                            parent: _animController,
                            curve: const Interval(0.3, 0.7, curve: Curves.easeIn),
                          ),
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 20,
                              color: _kAccent.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        // What's New Section
                        if (welcomeCtx.showWhatsNew) ...[
                          const SizedBox(height: 32),
                          FadeTransition(
                            opacity: CurvedAnimation(
                              parent: _animController,
                              curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: _kSurface,
                                borderRadius: IveTokens.brXs,
                                border: Border.all(color: _kBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "What's New",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: _kText,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _NewFeatureItem(
                                    icon: Icons.auto_awesome,
                                    text: 'AI-powered recommendations',
                                  ),
                                  _NewFeatureItem(
                                    icon: Icons.speed,
                                    text: 'Faster checkout experience',
                                  ),
                                  _NewFeatureItem(
                                    icon: Icons.security,
                                    text: 'Enhanced security features',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        // Data snapshot
                        const SizedBox(height: 24),
                        FadeTransition(
                          opacity: CurvedAnimation(
                            parent: _animController,
                            curve: const Interval(0.5, 0.9, curve: Curves.easeIn),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: _kSurface,
                              borderRadius: IveTokens.brXs,
                              border: Border.all(color: _kBorder),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Your Account',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _kText,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _StatItem(
                                      value: '${onboarding.profileCompleteness}%',
                                      label: 'Profile',
                                    ),
                                    _StatItem(
                                      value: welcomeCtx.daysSince.toString(),
                                      label: 'Days away',
                                    ),
                                    const _StatItem(
                                      value: '0',
                                      label: 'Notifications',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // Quick Actions
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _animController,
                    curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: Column(
                      children: [
                        PrimaryButton(
                          text: AppStrings.continueWhereLeftOff,
                          icon: Icons.auto_awesome,
                          onPressed: () {
                            Navigator.of(context)
                                .pushReplacementNamed(AppRoutes.genieHome);
                          },
                          margin: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _QuickActionBtn(
                                icon: Icons.person_outline,
                                label: 'Update\nProfile',
                                onTap: () {
                                  Navigator.of(context)
                                      .pushNamed(AppRoutes.profilePhoto);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _QuickActionBtn(
                                icon: Icons.explore_outlined,
                                label: 'Explore\nNew',
                                onTap: () {
                                  Navigator.of(context)
                                      .pushNamed(AppRoutes.tutorial);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeContext {
  final String greeting;
  final String emoji;
  final bool showWhatsNew;
  final int daysSince;

  const _WelcomeContext({
    required this.greeting,
    required this.emoji,
    required this.showWhatsNew,
    required this.daysSince,
  });
}

class _NewFeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _NewFeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _kAccent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: _kAccent),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: _kTextDim,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _kAccent,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: _kTextMuted,
          ),
        ),
      ],
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: IveTokens.brXs,
          border: Border.all(color: _kBorder),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: _kTextDim),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: _kTextDim,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
