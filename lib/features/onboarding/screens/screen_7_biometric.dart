import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/user_service.dart';
import '../providers/biometric_provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_header.dart';

/// Screen 08 — Biometric setup, step 05/08.
class BiometricSetupScreen extends StatefulWidget {
  const BiometricSetupScreen({super.key});

  @override
  State<BiometricSetupScreen> createState() => _BiometricSetupScreenState();
}

class _BiometricSetupScreenState extends State<BiometricSetupScreen> {
  bool _faceId      = false;
  bool _fingerprint = false;
  bool _pinFallback = true;
  bool _loading     = false;

  Future<void> _resolveAndMarkBiometric() async {
    String userId = '';
    try {
      final me = await AuthService().getMe();
      if (me.success && me.data != null) {
        userId = (me.data!['id'] as String?) ?? '';
      }
    } catch (_) {}

    if (userId.isNotEmpty) {
      await UserService().verifyBiometric(
        userId: userId,
        biometricStatus: true,
      );
    }
  }

  Future<void> _onEnable() async {
    setState(() => _loading = true);
    await _resolveAndMarkBiometric();

    // Attempt device biometric enrolment if hardware toggles are on
    if (mounted && (_faceId || _fingerprint)) {
      final bio = context.read<BiometricProvider>();
      await bio.setupBiometrics();
    }

    if (!mounted) return;
    setState(() => _loading = false);
    context.read<OnboardingProvider>().completeBiometric();
    Navigator.of(context).pushNamed(AppRoutes.roleSelection);
  }

  Future<void> _onSkip() async {
    setState(() => _loading = true);
    await _resolveAndMarkBiometric();

    if (!mounted) return;
    setState(() => _loading = false);
    context.read<OnboardingProvider>().completeBiometric();
    Navigator.of(context).pushNamed(AppRoutes.roleSelection);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IveTokens.bg,
      body: SafeArea(
        child: Responsive.constrained(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OnboardingHeader(
                title: 'Secure your account',
                subtitle: 'Enable biometric sign-in for faster, safer access.',
                currentStep: 5,
                totalSteps: 8,
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        decoration: BoxDecoration(
                          color: IveTokens.surface,
                          borderRadius: BorderRadius.circular(IveTokens.rMd),
                          border: Border.all(color: IveTokens.hairline),
                        ),
                        child: Center(
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: IveTokens.bg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: IveTokens.accent.withValues(alpha: 0.4)),
                            ),
                            child: const Icon(
                              Icons.remove_red_eye_outlined,
                              size: 26,
                              color: IveTokens.accent,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Toggle rows
                      Container(
                        decoration: BoxDecoration(
                          color: IveTokens.surface,
                          borderRadius: BorderRadius.circular(IveTokens.rSm),
                          border: Border.all(color: IveTokens.hairline),
                        ),
                        child: Column(
                          children: [
                            _ToggleRow(
                              label: 'Face ID',
                              value: _faceId,
                              onChanged: (v) => setState(() => _faceId = v),
                            ),
                            Divider(
                                height: 1,
                                thickness: 1,
                                color: IveTokens.hairline,
                                indent: 16,
                                endIndent: 0),
                            _ToggleRow(
                              label: 'Fingerprint',
                              value: _fingerprint,
                              onChanged: (v) => setState(() => _fingerprint = v),
                            ),
                            Divider(
                                height: 1,
                                thickness: 1,
                                color: IveTokens.hairline,
                                indent: 16,
                                endIndent: 0),
                            _ToggleRow(
                              label: 'PIN fallback',
                              value: _pinFallback,
                              onChanged: (v) => setState(() => _pinFallback = v),
                              accentWhenOn: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ENABLE & CONTINUE + SKIP FOR NOW
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  children: [
                    IveButton.primary(
                      label: 'ENABLE & CONTINUE',
                      isLoading: _loading,
                      onPressed: _onEnable,
                    ),
                    const SizedBox(height: 12),
                    IveButton.secondary(
                      label: 'SKIP FOR NOW',
                      onPressed: _loading ? null : _onSkip,
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

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool accentWhenOn;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.accentWhenOn = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: IveTokens.ink,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: accentWhenOn ? IveTokens.accent : IveTokens.success,
            activeTrackColor:
                (accentWhenOn ? IveTokens.accent : IveTokens.success)
                    .withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
