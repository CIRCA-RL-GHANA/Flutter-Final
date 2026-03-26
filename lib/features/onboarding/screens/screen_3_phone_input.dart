import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/responsive.dart';
import '../providers/phone_auth_provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/buttons.dart';
import '../widgets/onboarding_header.dart';

/// Screen 3: Phone Number Input (Intelligent)
/// Frictionless number entry with predictive intelligence
class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _phoneController;
  late AnimationController _waveController;
  final Debouncer _debouncer = Debouncer(milliseconds: 300);
  Timer? _emailSuggestionTimer;
  bool _showEmailSuggestion = false;

  // Country data
  final List<_CountryData> _countries = [
    const _CountryData('US', 'United States', '+1', '🇺🇸'),
    const _CountryData('GB', 'United Kingdom', '+44', '🇬🇧'),
    const _CountryData('GH', 'Ghana', '+233', '🇬🇭'),
    const _CountryData('NG', 'Nigeria', '+234', '🇳🇬'),
    const _CountryData('CA', 'Canada', '+1', '🇨🇦'),
    const _CountryData('DE', 'Germany', '+49', '🇩🇪'),
    const _CountryData('FR', 'France', '+33', '🇫🇷'),
    const _CountryData('IN', 'India', '+91', '🇮🇳'),
    const _CountryData('KE', 'Kenya', '+254', '🇰🇪'),
    const _CountryData('ZA', 'South Africa', '+27', '🇿🇦'),
  ];

  late _CountryData _selectedCountry;

  // Validation states
  _ValidationState _validationState = _ValidationState.empty;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _selectedCountry = _countries.first;

    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Show email suggestion after 10s of inactivity
    _emailSuggestionTimer = Timer(
      const Duration(seconds: 10),
      () {
        if (mounted && _phoneController.text.isEmpty) {
          setState(() => _showEmailSuggestion = true);
        }
      },
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _waveController.dispose();
    _debouncer.cancel();
    _emailSuggestionTimer?.cancel();
    super.dispose();
  }

  void _onPhoneChanged(String value) {
    // Reset email suggestion timer
    _emailSuggestionTimer?.cancel();
    _showEmailSuggestion = false;
    _emailSuggestionTimer = Timer(
      const Duration(seconds: 10),
      () {
        if (mounted && _phoneController.text.isEmpty) {
          setState(() => _showEmailSuggestion = true);
        }
      },
    );

    if (value.isEmpty) {
      setState(() => _validationState = _ValidationState.empty);
      return;
    }

    setState(() => _validationState = _ValidationState.typing);

    _debouncer.run(() {
      final isValid = PhoneFormatter.isValid(value, _selectedCountry.iso);
      setState(() {
        _validationState =
            isValid ? _ValidationState.valid : _ValidationState.invalid;
      });
    });
  }

  Future<void> _onContinue() async {
    final phoneAuth = context.read<PhoneAuthProvider>();
    final onboarding = context.read<OnboardingProvider>();

    phoneAuth.setPhoneNumber(_phoneController.text);
    phoneAuth.setCountry(_selectedCountry.dialCode, _selectedCountry.iso);

    // Check number existence
    final result = await phoneAuth.checkNumber();

    if (!mounted) return;

    if (result == NumberCheckResult.existingUser) {
      // Existing user → welcome back flow
      onboarding.setReturningUser(true);
      Navigator.of(context).pushNamed(AppRoutes.welcomeBack);
    } else if (result == NumberCheckResult.newUser ||
        result == NumberCheckResult.valid) {
      // New user → send OTP
      await phoneAuth.sendOtp();
      if (!mounted) return;

      onboarding.setPhoneData(
        _phoneController.text,
        _selectedCountry.dialCode,
      );

      Navigator.of(context).pushNamed(
        AppRoutes.otpVerification,
        arguments: {
          'phoneNumber': _phoneController.text,
          'countryCode': _selectedCountry.dialCode,
        },
      );
    } else {
      // Error
      _showError(phoneAuth.error ?? AppStrings.networkErrorNumber);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CountryPickerSheet(
        countries: _countries,
        selectedCountry: _selectedCountry,
        onSelect: (country) {
          setState(() {
            _selectedCountry = country;
            _phoneController.clear();
            _validationState = _ValidationState.empty;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<PhoneAuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Responsive.constrained(
          child: Column(
            children: [
              OnboardingHeader(
                title: AppStrings.enterPhoneTitle,
                subtitle: AppStrings.enterPhoneSubtitle,
                currentStep: 1,
                totalSteps: 8,
                onBack: () => Navigator.pop(context),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Country selector
                      GestureDetector(
                        onTap: _showCountryPicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.inputFill,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.inputBorder),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _selectedCountry.flag,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedCountry.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                _selectedCountry.dialCode,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.textTertiary,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Phone input field
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getBorderColor(),
                            width: _validationState == _ValidationState.empty
                                ? 1
                                : 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Dial code
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.inputFill,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  bottomLeft: Radius.circular(16),
                                ),
                              ),
                              child: Text(
                                _selectedCountry.dialCode,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),

                            // Phone number input
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(
                                    PhoneFormatter.maxLength(
                                        _selectedCountry.iso),
                                  ),
                                ],
                                onChanged: _onPhoneChanged,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Phone number',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 18,
                                  ),
                                ),
                              ),
                            ),

                            // Validation icon
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: _buildValidationIcon(),
                            ),
                          ],
                        ),
                      ),

                      // Validation message
                      if (_validationState == _ValidationState.invalid)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 4),
                          child: Text(
                            AppStrings.invalidNumber,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.error,
                            ),
                          ),
                        ),

                      const SizedBox(height: 32),

                      // Wave illustration area (placeholder)
                      if (Responsive.isDesktop(context))
                        Center(
                          child: AnimatedBuilder(
                            animation: _waveController,
                            builder: (context, child) {
                              return Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: _validationState ==
                                          _ValidationState.valid
                                      ? AppColors.success.withOpacity(0.1)
                                      : AppColors.primaryLight
                                          .withOpacity(0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.phone_android,
                                  size: 80,
                                  color: _validationState ==
                                          _ValidationState.valid
                                      ? AppColors.success.withOpacity(0.5)
                                      : AppColors.primaryLight
                                          .withOpacity(0.2),
                                ),
                              );
                            },
                          ),
                        ),

                      // Email suggestion
                      if (_showEmailSuggestion)
                        AnimatedOpacity(
                          opacity: _showEmailSuggestion ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: SecondaryButton(
                              text: AppStrings.useEmailInstead,
                              onPressed: () {
                                // Show email input modal
                                _showEmailInputModal();
                              },
                              underline: true,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Bottom action button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: PrimaryButton(
                  text: AppStrings.continueBtn,
                  icon: Icons.arrow_forward,
                  isLoading: isLoading,
                  onPressed: _validationState == _ValidationState.valid
                      ? _onContinue
                      : null,
                  margin: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBorderColor() {
    switch (_validationState) {
      case _ValidationState.empty:
        return AppColors.validationEmpty;
      case _ValidationState.typing:
        return AppColors.validationTyping;
      case _ValidationState.valid:
        return AppColors.validationValid;
      case _ValidationState.invalid:
        return AppColors.validationInvalid;
    }
  }

  Widget _buildValidationIcon() {
    switch (_validationState) {
      case _ValidationState.empty:
        return const SizedBox(width: 20);
      case _ValidationState.typing:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.validationTyping,
          ),
        );
      case _ValidationState.valid:
        return const Icon(
          Icons.check_circle,
          size: 20,
          color: AppColors.validationValid,
        );
      case _ValidationState.invalid:
        return const Icon(
          Icons.error,
          size: 20,
          color: AppColors.validationInvalid,
        );
    }
  }

  void _showEmailInputModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Use email instead',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter your email address',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                text: 'Continue with Email',
                onPressed: () {
                  Navigator.pop(context);
                  // Handle email flow
                },
                margin: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

enum _ValidationState { empty, typing, valid, invalid }

class _CountryData {
  final String iso;
  final String name;
  final String dialCode;
  final String flag;

  const _CountryData(this.iso, this.name, this.dialCode, this.flag);
}

class _CountryPickerSheet extends StatefulWidget {
  final List<_CountryData> countries;
  final _CountryData selectedCountry;
  final ValueChanged<_CountryData> onSelect;

  const _CountryPickerSheet({
    required this.countries,
    required this.selectedCountry,
    required this.onSelect,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  late TextEditingController _searchController;
  late List<_CountryData> _filtered;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filtered = widget.countries;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _filtered = widget.countries
          .where((c) =>
              c.name.toLowerCase().contains(query.toLowerCase()) ||
              c.dialCode.contains(query) ||
              c.iso.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: _onSearch,
                  decoration: InputDecoration(
                    hintText: 'Search country or code',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Country list
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final country = _filtered[index];
                final isSelected = country.iso == widget.selectedCountry.iso;
                return ListTile(
                  leading: Text(
                    country.flag,
                    style: const TextStyle(fontSize: 28),
                  ),
                  title: Text(
                    country.name,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  trailing: Text(
                    country.dialCode,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primaryLight
                          : AppColors.textSecondary,
                    ),
                  ),
                  selected: isSelected,
                  selectedTileColor: AppColors.primaryLight.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () => widget.onSelect(country),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
