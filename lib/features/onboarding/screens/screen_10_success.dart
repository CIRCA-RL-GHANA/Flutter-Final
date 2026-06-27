import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/responsive.dart';
import '../providers/onboarding_provider.dart';

/// Screen 11 — Success / account created.
class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  void _enter(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.genieHome,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ob = context.watch<OnboardingProvider>();
    final firstName = ob.firstName.isNotEmpty ? ob.firstName : 'there';

    return Scaffold(
      backgroundColor: IveTokens.bg,
      body: SafeArea(
        child: Responsive.constrained(
          child: Column(
            children: [
              const Spacer(),

              // Green tick circle
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: IveTokens.success.withValues(alpha: 0.08),
                  border: Border.all(
                    color: IveTokens.success.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.check,
                  size: 44,
                  color: IveTokens.success,
                ),
              ),

              const SizedBox(height: 28),

              // Heading
              const Text(
                "You're all set.",
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: IveTokens.ink,
                ),
              ),

              const SizedBox(height: 10),

              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Your Commerce OS account is ready. Welcome aboard, $firstName.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: IveTokens.ink2,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // 5 colored dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _Dot(IveTokens.accent),
                  SizedBox(width: 6),
                  _Dot(IveTokens.accent),
                  SizedBox(width: 6),
                  _Dot(IveTokens.accent),
                  SizedBox(width: 6),
                  _Dot(IveTokens.accent),
                  SizedBox(width: 6),
                  _Dot(IveTokens.genie),
                ],
              ),

              const Spacer(),

              // ENTER COMMERCE OS
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: IveButton.primary(
                  label: 'ENTER COMMERCE OS',
                  onPressed: () => _enter(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
