import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive.dart';
import '../providers/onboarding_provider.dart';

/// Screen 2: OS Welcome Screen
/// Communicates genie help as infrastructure, not an app.
/// Aesthetic: system dark, module manifest grid, typed descriptor,
/// no white card / consumer sparkle / decorative gradients.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

// ── OS palette (mirrors splash) ───────────────────────────────────────────────
const Color _kBg        = Color(0xFF08080F);
const Color _kSurface   = Color(0xFF0E0E1A);
const Color _kBorder    = Color(0xFF1C1C2E);
const Color _kAccent    = Color(0xFF4361EE);
const Color _kAccentDim = Color(0xFF1E2A6E);
const Color _kText      = Color(0xFFE8E8F0);
const Color _kTextDim   = Color(0xFF6B6B88);
const Color _kTextMuted = Color(0xFF3A3A52);

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..forward();

    _fadeIn = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeIn,
    );

    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  void _onGetStarted() {
    context.read<OnboardingProvider>().completeWelcome();
    Navigator.of(context).pushNamed(AppRoutes.phoneInput);
  }

  void _onLogIn() {
    Navigator.of(context).pushNamed(AppRoutes.welcomeBack);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: FadeTransition(
        opacity: _fadeIn,
        child: SlideTransition(
          position: _slideUp,
          child: SafeArea(
            child: Responsive.constrained(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── System header ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hex logo mark (small, same as splash)
                        const _MiniHexMark(),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  AppStrings.splashTitle,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: _kText,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  AppStrings.splashSubtitle,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w300,
                                    color: _kText.withOpacity(0.30),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: _kAccent.withOpacity(0.30)),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                'COMMERCE OS  ·  v1.0',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  color: _kAccent.withOpacity(0.55),
                                  letterSpacing: 2.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Divider ────────────────────────────────────────────
                  Container(height: 1, color: _kBorder),

                  const SizedBox(height: 28),

                  // ── Descriptor ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.welcomeTagline,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: _kText,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Payments · Logistics · Commerce · Finance · AI',
                          style: TextStyle(
                            fontSize: 12,
                            color: _kTextDim,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Module manifest grid ───────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _ModuleGrid(controller: _entranceController),
                    ),
                  ),

                  // ── Actions ───────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: _OsButton(
                      label: AppStrings.getStarted,
                      onTap: _onGetStarted,
                    ),
                  ),

                  // Return link
                  GestureDetector(
                    onTap: _onLogIn,
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppStrings.alreadyHaveAccount,
                              style: TextStyle(
                                fontSize: 13,
                                color: _kTextDim,
                              ),
                            ),
                            Text(
                              AppStrings.logIn,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _kAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Module manifest grid ─────────────────────────────────────────────────────
// Shows the installed modules of the OS — commerce, payments, logistics, etc.

class _Module {
  final String code;
  final String label;
  final String desc;
  final IconData icon;

  const _Module({
    required this.code,
    required this.label,
    required this.desc,
    required this.icon,
  });
}

const _kModules = [
  _Module(code: 'GO',   label: 'GO Wallet',   desc: 'Send · Pay · Top up',    icon: Icons.account_balance_wallet_outlined),
  _Module(code: 'MKT',  label: 'Market',       desc: 'Buy · Sell · Deliver',   icon: Icons.storefront_outlined),
  _Module(code: 'LIV',  label: 'Live',         desc: 'Ride · Track · Deliver', icon: Icons.near_me_outlined),
  _Module(code: 'QC',   label: 'QualChat',     desc: 'Comm · Signal · Relay',  icon: Icons.chat_bubble_outline),
  _Module(code: 'APR',  label: 'APRIL',        desc: 'Plan · Budget · Earn',   icon: Icons.event_note_outlined),
  _Module(code: 'UPD',  label: 'Updates',      desc: 'Follow · Post · React',  icon: Icons.dynamic_feed_outlined),
  _Module(code: 'ENT',  label: 'Enterprise',   desc: 'API · Webhooks · RBAC',  icon: Icons.hub_outlined),
  _Module(code: 'FIN',  label: 'Fintech',      desc: 'Loans · Insurance · FI', icon: Icons.account_balance_outlined),
];

class _ModuleGrid extends StatelessWidget {
  final AnimationController controller;
  const _ModuleGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.3,
      ),
      itemCount: _kModules.length,
      itemBuilder: (context, i) {
        final m = _kModules[i];
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: controller,
            curve: Interval(0.3 + i * 0.06, 0.7 + i * 0.04,
                curve: Curves.easeIn),
          ),
          child: _ModuleCard(module: m),
        );
      },
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final _Module module;
  const _ModuleCard({required this.module});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _kSurface,
        border: Border.all(color: _kBorder),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(module.icon, size: 18, color: _kAccent.withOpacity(0.70)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  module.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  module.desc,
                  style: TextStyle(
                    fontSize: 10,
                    color: _kTextDim,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          // Status dot — online
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.70),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── OS primary button ────────────────────────────────────────────────────────
class _OsButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OsButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Material(
        color: _kAccent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Mini hex mark (consistent with splash) ───────────────────────────────────
class _MiniHexMark extends StatelessWidget {
  const _MiniHexMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: CustomPaint(painter: _MiniHexPainter()),
    );
  }
}

class _MiniHexPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width / 2 - 1;

    Path hexPath(double radius) {
      final path = Path();
      for (int i = 0; i < 6; i++) {
        final a = (pi / 3) * i - pi / 6;
        final xa = cx + radius * cos(a);
        final ya = cy + radius * sin(a);
        if (i == 0) path.moveTo(xa, ya); else path.lineTo(xa, ya);
      }
      return path..close();
    }

    canvas.drawPath(
      hexPath(r),
      Paint()
        ..color = _kAccent.withOpacity(0.50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    canvas.drawPath(
      hexPath(r * 0.52),
      Paint()
        ..color = _kAccentDim.withOpacity(0.45)
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      Offset(cx, cy),
      2.5,
      Paint()..color = _kAccent,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

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
                            AppStrings.splashTitle,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            AppStrings.splashSubtitle,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.accent.withOpacity(0.9),
                              letterSpacing: 1,
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
