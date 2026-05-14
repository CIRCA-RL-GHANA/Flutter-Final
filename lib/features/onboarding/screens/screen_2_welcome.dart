import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_logo.dart';
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

// ─── Mini brand mark (consistent with splash) ────────────────────────────────
class _MiniHexMark extends StatelessWidget {
  const _MiniHexMark();

  @override
  Widget build(BuildContext context) {
    return const AppLogo.icon(
      size: 36,
      variant: AppLogoVariant.dark,
      semanticsLabel: 'genie help',
    );
  }
}

