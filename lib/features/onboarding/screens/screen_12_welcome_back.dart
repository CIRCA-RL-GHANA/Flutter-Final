import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/responsive.dart';
import '../providers/onboarding_provider.dart';
import '../providers/phone_auth_provider.dart';
import '../../../core/services/auth_service.dart';

/// Screen 13 — Welcome back (returning user sign-in).
class WelcomeBackScreen extends StatefulWidget {
  const WelcomeBackScreen({super.key});

  @override
  State<WelcomeBackScreen> createState() => _WelcomeBackScreenState();
}

class _WelcomeBackScreenState extends State<WelcomeBackScreen> {
  bool _loading = false;
  String _firstName = '';
  String _lastName  = '';
  bool _fetching    = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    // Try provider state first (set during this session's onboarding flow)
    final ob = context.read<OnboardingProvider>();
    if (ob.firstName.isNotEmpty) {
      setState(() {
        _firstName = ob.firstName;
        _lastName  = ob.lastName;
        _fetching  = false;
      });
      return;
    }

    // Returning user: fetch from backend
    try {
      final res = await AuthService().getMe();
      if (mounted && res.success && res.data != null) {
        final d = res.data!;
        // Backend may return user nested under 'user' key
        final user = (d['user'] as Map<String, dynamic>?) ?? d;
        setState(() {
          _firstName = (user['firstName'] as String?)?.trim() ?? '';
          _lastName  = (user['lastName']  as String?)?.trim() ?? '';
          _fetching  = false;
        });
        return;
      }
    } catch (_) {}

    if (mounted) setState(() => _fetching = false);
  }

  String get _fullName {
    final n = '$_firstName $_lastName'.trim();
    return n.isNotEmpty ? n : 'Commerce OS';
  }

  String get _initials {
    if (_firstName.isEmpty && _lastName.isEmpty) return 'CO';
    final f = _firstName.isNotEmpty ? _firstName[0].toUpperCase() : '';
    final l = _lastName.isNotEmpty  ? _lastName[0].toUpperCase()  : '';
    return '$f$l';
  }

  Future<void> _signIn() async {
    final phone = context.read<PhoneAuthProvider>().formattedNumber;
    if (phone.trim().isEmpty) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.phoneInput);
      return;
    }

    setState(() => _loading = true);
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.genieHome,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IveTokens.bg,
      body: SafeArea(
        child: Responsive.constrained(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 48),

                // Avatar
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: IveTokens.surface,
                    border: Border.all(color: IveTokens.hairline2),
                  ),
                  child: Center(
                    child: _fetching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: IveTokens.mute,
                            ),
                          )
                        : Text(
                            _initials,
                            style: const TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: IveTokens.ink2,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // WELCOME BACK eyebrow
                Text(
                  'WELCOME BACK',
                  style: IveType.mono.copyWith(
                    fontSize: 10,
                    color: IveTokens.mute,
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                // Name
                _fetching
                    ? Container(
                        width: 160,
                        height: 20,
                        decoration: BoxDecoration(
                          color: IveTokens.surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )
                    : Text(
                        _fullName,
                        style: const TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: IveTokens.ink,
                        ),
                      ),

                const SizedBox(height: 28),

                // Sign in with Face ID row
                GestureDetector(
                  onTap: _loading || _fetching ? null : _signIn,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: IveTokens.surface,
                      borderRadius: BorderRadius.circular(IveTokens.rSm),
                      border: Border.all(color: IveTokens.hairline),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: IveTokens.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.remove_red_eye_outlined,
                            size: 20,
                            color: IveTokens.accent,
                          ),
                        ),

                        const SizedBox(width: 14),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sign in with Face ID',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: IveTokens.ink,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Or use your PIN',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: IveTokens.mute,
                                ),
                              ),
                            ],
                          ),
                        ),

                        _loading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: IveTokens.accent,
                                ),
                              )
                            : const Text(
                                '>',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: IveTokens.mute,
                                ),
                              ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // JUMP BACK IN section header
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'JUMP BACK IN',
                    style: IveType.mono.copyWith(
                      fontSize: 10,
                      color: IveTokens.mute,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // 2×2 module grid
                Row(
                  children: [
                    Expanded(
                      child: _ModuleTile(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'GO',
                        onTap: _signIn,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ModuleTile(
                        icon: Icons.grid_view_outlined,
                        label: 'Market',
                        onTap: _signIn,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: _ModuleTile(
                        icon: Icons.diamond_outlined,
                        label: 'Updates',
                        onTap: _signIn,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ModuleTile(
                        icon: Icons.chat_bubble_outline,
                        label: 'Chat',
                        onTap: _signIn,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ModuleTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: IveTokens.surface,
          borderRadius: BorderRadius.circular(IveTokens.rSm),
          border: Border.all(color: IveTokens.hairline),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: IveTokens.accent),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: IveTokens.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
