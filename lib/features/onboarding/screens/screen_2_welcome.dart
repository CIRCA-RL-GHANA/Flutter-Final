import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/hex_mark.dart';
import '../providers/onboarding_provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: IveTokens.dBase, vsync: this)
      ..forward();
    _fade = CurvedAnimation(parent: _ctrl, curve: IveTokens.enter);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onGetStarted() {
    context.read<OnboardingProvider>().completeWelcome();
    Navigator.of(context).pushNamed(AppRoutes.phoneInput);
  }

  void _onLogIn() {
    Navigator.of(context).pushNamed(
      AppRoutes.phoneInput,
      arguments: {'mode': 'login'},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IveTokens.bg,
      body: FadeTransition(
        opacity: _fade,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Topbar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const HexMark(size: 32),
                    const SizedBox(width: 10),
                    Text(
                      'COMMERCE OS',
                      style: IveType.mono.copyWith(
                        fontSize: 11,
                        color: IveTokens.ink,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Headline
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'The global operating\nsystem for commerce.',
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: IveTokens.ink,
                    height: 1.2,
                    letterSpacing: -0.3,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Subtitle
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Finance, market, logistics and social\n— one operating layer.',
                  style: TextStyle(
                    fontSize: 13,
                    color: IveTokens.ink2,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Module grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _ModuleGrid(controller: _ctrl),
                ),
              ),

              // GET STARTED
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: IveButton.primary(
                  label: 'Get started',
                  onPressed: _onGetStarted,
                ),
              ),

              // Log in
              GestureDetector(
                onTap: _onLogIn,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(
                          fontSize: 13,
                          color: IveTokens.ink2,
                        ),
                      ),
                      const Text(
                        'Log in',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: IveTokens.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}

const _kModules = [
  'GO Wallet',
  'Market',
  'Live',
  'QualChat',
  'APRIL',
  'Updates',
  'Enterprise',
  'Fintech',
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
        childAspectRatio: 2.8,
      ),
      itemCount: _kModules.length,
      itemBuilder: (context, i) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: controller,
            curve: Interval(0.2 + i * 0.06, 0.7 + i * 0.04,
                curve: Curves.easeIn),
          ),
          child: _ModuleCard(name: _kModules[i]),
        );
      },
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String name;
  const _ModuleCard({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: IveTokens.surface,
        border: Border.all(color: IveTokens.hairline),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: IveTokens.ink,
              ),
            ),
          ),
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: IveTokens.success, shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
