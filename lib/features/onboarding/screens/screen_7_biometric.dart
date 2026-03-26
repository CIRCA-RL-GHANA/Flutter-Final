import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/helpers.dart';
import '../providers/biometric_provider.dart';
import '../providers/device_check_provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/buttons.dart';
import '../widgets/onboarding_header.dart';

/// Screen 7: Biometric Setup (Adaptive)
/// Security with convenience, not coercion
class BiometricSetupScreen extends StatefulWidget {
  const BiometricSetupScreen({super.key});

  @override
  State<BiometricSetupScreen> createState() => _BiometricSetupScreenState();
}

class _BiometricSetupScreenState extends State<BiometricSetupScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  // PIN setup
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  bool _showPinSetup = false;
  String? _pinError;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Detect biometric type from device check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deviceCheck = context.read<DeviceCheckProvider>();
      final biometric = context.read<BiometricProvider>();

      switch (deviceCheck.biometricCapability) {
        case BiometricCapability.faceId:
          biometric.setBiometricType(BiometricType.faceId);
          break;
        case BiometricCapability.touchId:
          biometric.setBiometricType(BiometricType.touchId);
          break;
        case BiometricCapability.fingerprint:
          biometric.setBiometricType(BiometricType.fingerprint);
          break;
        case BiometricCapability.iris:
          biometric.setBiometricType(BiometricType.iris);
          break;
        case BiometricCapability.none:
          biometric.setBiometricType(BiometricType.none);
          setState(() => _showPinSetup = true);
          break;
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _setupBiometrics() async {
    final biometric = context.read<BiometricProvider>();
    final success = await biometric.setupBiometrics();

    if (!mounted) return;

    if (success) {
      _proceed();
    }
  }

  Future<void> _setupPin() async {
    final pin = _pinController.text;
    final confirmPin = _confirmPinController.text;

    final validation = Validators.validatePin(pin);
    if (validation != null) {
      setState(() => _pinError = validation);
      return;
    }

    if (pin != confirmPin) {
      setState(() => _pinError = 'PINs do not match');
      return;
    }

    setState(() => _pinError = null);

    final biometric = context.read<BiometricProvider>();
    biometric.setPin(pin);
    biometric.skipBiometrics();

    _proceed();
  }

  void _proceed() {
    context.read<OnboardingProvider>().completeBiometric();
    Navigator.of(context).pushNamed(AppRoutes.roleSelection);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Responsive.constrained(
          child: Column(
            children: [
              OnboardingHeader(
                title: _showPinSetup
                    ? AppStrings.setupPin
                    : AppStrings.enableBiometric,
                subtitle: _showPinSetup
                    ? 'Create a secure PIN for your account'
                    : 'Quick and secure access to your account',
                currentStep: 5,
                totalSteps: 8,
                onBack: () => Navigator.pop(context),
              ),

              Expanded(
                child: Consumer<BiometricProvider>(
                  builder: (context, biometric, child) {
                    if (_showPinSetup || !biometric.hasBiometrics) {
                      return _buildPinSetup();
                    }
                    return _buildBiometricSetup(biometric);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricSetup(BiometricProvider biometric) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),

          // Animated biometric illustration
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLight.withOpacity(
                    0.08 + 0.05 * _animController.value,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryLight.withOpacity(
                        0.1 + 0.1 * _animController.value,
                      ),
                      blurRadius: 20 + 10 * _animController.value,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  _getBiometricIcon(biometric.biometricType),
                  size: 60,
                  color: AppColors.primaryLight,
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // Benefits
          _BenefitRow(
            icon: Icons.touch_app,
            text: AppStrings.biometricBenefit1,
          ),
          _BenefitRow(
            icon: Icons.security,
            text: AppStrings.biometricBenefit2,
          ),
          _BenefitRow(
            icon: Icons.vpn_key_off,
            text: AppStrings.biometricBenefit3,
          ),

          const SizedBox(height: 24),

          // Toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Enable ${biometric.biometricName}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Switch.adaptive(
                  value: biometric.biometricEnabled,
                  onChanged: (value) {
                    biometric.setBiometricEnabled(value);
                  },
                  activeColor: AppColors.primaryLight,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Consent
          GestureDetector(
            onTap: () =>
                biometric.setConsent(!biometric.consentGiven),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: biometric.consentGiven
                      ? AppColors.primaryLight
                      : AppColors.inputBorder,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    biometric.consentGiven
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: biometric.consentGiven
                        ? AppColors.primaryLight
                        : AppColors.textTertiary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppStrings.biometricConsent,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Education text
          Text(
            AppStrings.changeAnytime,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),

          const SizedBox(height: 32),

          // Enable button
          PrimaryButton(
            text: biometric.biometricEnabled
                ? 'Enable ${biometric.biometricName}'
                : 'Continue without biometrics',
            icon: Icons.arrow_forward,
            onPressed: (biometric.biometricEnabled &&
                        biometric.consentGiven) ||
                    !biometric.biometricEnabled
                ? () {
                    if (biometric.biometricEnabled) {
                      _setupBiometrics();
                    } else {
                      setState(() => _showPinSetup = true);
                    }
                  }
                : null,
            margin: EdgeInsets.zero,
          ),

          const SizedBox(height: 12),

          // Skip
          SecondaryButton(
            text: AppStrings.skipUsePassword,
            onPressed: () {
              biometric.skipBiometrics();
              _proceed();
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPinSetup() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),

          // PIN icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight.withOpacity(0.1),
            ),
            child: const Icon(
              Icons.pin_outlined,
              size: 48,
              color: AppColors.primaryLight,
            ),
          ),

          const SizedBox(height: 32),

          // PIN input
          TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              letterSpacing: 8,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              labelText: 'Enter PIN (4-6 digits)',
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Confirm PIN
          TextField(
            controller: _confirmPinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              letterSpacing: 8,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              labelText: 'Confirm PIN',
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // Error
          if (_pinError != null) ...[
            const SizedBox(height: 8),
            Text(
              _pinError!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.error,
              ),
            ),
          ],

          const SizedBox(height: 8),
          const Text(
            'Your PIN will be used as a fallback authentication method',
            style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          PrimaryButton(
            text: 'Set PIN & Continue',
            icon: Icons.arrow_forward,
            onPressed: _setupPin,
            margin: EdgeInsets.zero,
          ),

          if (context.read<BiometricProvider>().hasBiometrics) ...[
            const SizedBox(height: 12),
            SecondaryButton(
              text: 'Use biometrics instead',
              onPressed: () => setState(() => _showPinSetup = false),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  IconData _getBiometricIcon(BiometricType type) {
    switch (type) {
      case BiometricType.faceId:
        return Icons.face;
      case BiometricType.touchId:
      case BiometricType.fingerprint:
        return Icons.fingerprint;
      case BiometricType.iris:
        return Icons.remove_red_eye;
      case BiometricType.none:
        return Icons.pin_outlined;
    }
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.success),
          ),
          const SizedBox(width: 16),
          Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
