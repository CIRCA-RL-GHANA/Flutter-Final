import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/responsive.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/buttons.dart';

/// Screen 2: Luxurious Welcome Screen
/// Value proposition with role-aware content
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;

  // Content area height factor
  double _contentHeightFactor = 0.45;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onGetStarted() {
    context.read<OnboardingProvider>().completeWelcome();
    Navigator.of(context).pushNamed(AppRoutes.phoneInput);
  }

  void _onLogIn() {
    // Navigate to login / returning user flow
    Navigator.of(context).pushNamed(AppRoutes.welcomeBack);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      body: Stack(
        children: [
          // Hero Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.splashGradient,
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    top: -80,
                    right: -60,
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: screenHeight * 0.5,
                    left: -40,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent.withOpacity(0.08),
                      ),
                    ),
                  ),

                  // App logo in the top area
                  Positioned(
                    top: screenHeight * 0.12,
                    left: 0,
                    right: 0,
                    child: FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _entranceController,
                        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accent.withOpacity(0.15),
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              size: 50,
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'PROMPT',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 3,
                            ),
                          ),
                          Text(
                            'Genie',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.accent.withOpacity(0.8),
                              fontStyle: FontStyle.italic,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Content Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                setState(() {
                  _contentHeightFactor -= details.primaryDelta! / screenHeight;
                  _contentHeightFactor =
                      _contentHeightFactor.clamp(0.38, 0.70);
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: screenHeight * _contentHeightFactor,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                        AppDimensions.bottomSheetCornerRadius),
                    topRight: Radius.circular(
                        AppDimensions.bottomSheetCornerRadius),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 24,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Responsive.constrained(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                    child: Column(
                      children: [
                        // Drag handle
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // App logo mini
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            size: 24,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Tagline with typewriter effect feel
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _entranceController,
                            curve: const Interval(0.3, 0.6,
                                curve: Curves.easeOut),
                          )),
                          child: FadeTransition(
                            opacity: CurvedAnimation(
                              parent: _entranceController,
                              curve: const Interval(0.3, 0.6,
                                  curve: Curves.easeIn),
                            ),
                            child: const Text(
                              AppStrings.welcomeTagline,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Role-Based Benefits Grid
                        _buildBenefitsGrid(isMobile),

                        const SizedBox(height: 32),

                        // Primary CTA: Get Started
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 + 0.02 * _pulseController.value,
                              child: PrimaryButton(
                                text: AppStrings.getStarted,
                                icon: Icons.arrow_forward,
                                onPressed: _onGetStarted,
                                margin: EdgeInsets.zero,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Secondary CTA: Log in
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              AppStrings.alreadyHaveAccount,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            GestureDetector(
                              onTap: _onLogIn,
                              child: const Text(
                                AppStrings.logIn,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryLight,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsGrid(bool isMobile) {
    final benefits = [
      _BenefitItem(
        icon: Icons.shopping_bag_outlined,
        title: AppStrings.buyerTitle,
        subtitle: AppStrings.buyerSubtitle,
        color: AppColors.roleBuyer,
      ),
      _BenefitItem(
        icon: Icons.storefront_outlined,
        title: AppStrings.shopTitle,
        subtitle: AppStrings.shopSubtitle,
        color: AppColors.roleShop,
      ),
      _BenefitItem(
        icon: Icons.local_shipping_outlined,
        title: AppStrings.deliveryTitle,
        subtitle: AppStrings.deliverySubtitle,
        color: AppColors.roleDelivery,
      ),
      _BenefitItem(
        icon: Icons.directions_car_outlined,
        title: AppStrings.transportTitle,
        subtitle: AppStrings.transportSubtitle,
        color: AppColors.roleTransport,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isMobile ? 1.3 : 1.5,
      ),
      itemCount: benefits.length,
      itemBuilder: (context, index) {
        final benefit = benefits[index];
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _entranceController,
            curve: Interval(
              0.4 + index * 0.08,
              0.7 + index * 0.08,
              curve: Curves.easeOut,
            ),
          )),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: _entranceController,
              curve: Interval(
                0.4 + index * 0.08,
                0.6 + index * 0.08,
                curve: Curves.easeIn,
              ),
            ),
            child: _BenefitCard(item: benefit),
          ),
        );
      },
    );
  }
}

class _BenefitItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

class _BenefitCard extends StatelessWidget {
  final _BenefitItem item;
  const _BenefitCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: item.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: item.color.withOpacity(0.15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, size: 32, color: item.color),
          const SizedBox(height: 8),
          Text(
            item.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: item.color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
