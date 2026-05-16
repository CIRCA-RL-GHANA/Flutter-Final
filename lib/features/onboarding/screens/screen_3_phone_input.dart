import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/responsive.dart';
import '../providers/phone_auth_provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/buttons.dart';
import '../widgets/onboarding_header.dart';


// OS palette ï¿½ mirrors splash / welcome
const Color _kBg        = Color(0xFF08080F);
const Color _kSurface   = Color(0xFF0E0E1A);
const Color _kBorder    = Color(0xFF1C1C2E);
const Color _kAccent    = Color(0xFF22BDD8);
const Color _kAccentDim = Color(0xFF1E2A6E);
const Color _kText      = Color(0xFFE8E8F0);
const Color _kTextDim   = Color(0xFF9A9AB2);
const Color _kTextMuted = Color(0xFF7A7A95);
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
    const _CountryData('US', 'United States', '+1', 'ðŸ‡ºðŸ‡¸'),
    const _CountryData('GB', 'United Kingdom', '+44', 'ðŸ‡¬ðŸ‡§'),
    const _CountryData('GH', 'Ghana', '+233', 'ðŸ‡¬ðŸ‡­'),
    const _CountryData('NG', 'Nigeria', '+234', 'ðŸ‡³ðŸ‡¬'),
    const _CountryData('CA', 'Canada', '+1', 'ðŸ‡¨ðŸ‡¦'),
    const _CountryData('DE', 'Germany', '+49', 'ðŸ‡©ðŸ‡ª'),
    const _CountryData('FR', 'France', '+33', 'ðŸ‡«ðŸ‡·'),
    const _CountryData('IN', 'India', '+91', 'ðŸ‡®ðŸ‡³'),
    const _CountryData('KE', 'Kenya', '+254', 'ðŸ‡°ðŸ‡ª'),
    const _CountryData('ZA', 'South Africa', '+27', 'ðŸ‡¿ðŸ‡¦'),
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
      // Existing user â†’ welcome back flow
      onboarding.setReturningUser(true);
      Navigator.of(context).pushNamed(AppRoutes.welcomeBack);
    } else if (result == NumberCheckResult.newUser ||
        result == NumberCheckResult.valid) {
      // New user â†’ send OTP
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
        backgroundColor: const Color(0xFFEF4444),
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
      backgroundColor: const Color(0xFF08080F),
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
                            color: const Color(0xFF0E0E1A),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF1C1C2E)),
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
                                    color: const Color(0xFFE8E8F0),
                                  ),
                                ),
                              ),
                              Text(
                                _selectedCountry.dialCode,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF9A9AB2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: const Color(0xFF7A7A95),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Phone input field
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
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
                                color: const Color(0xFF0E0E1A),
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
                                  color: const Color(0xFFE8E8F0),
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
                              color: const Color(0xFFEF4444),
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
                                      ? const Color(0xFF10B981).withValues(alpha: 0.1)
                                      : const Color(0xFF22BDD8)
                                          .withValues(alpha: 0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.phone_android,
                                  size: 80,
                                  color: _validationState ==
                                          _ValidationState.valid
                                      ? const Color(0xFF10B981).withValues(alpha: 0.5)
                                      : const Color(0xFF22BDD8)
                                          .withValues(alpha: 0.2),
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
        return const Color(0xFF1C1C2E);
      case _ValidationState.typing:
        return const Color(0xFF22BDD8);
      case _ValidationState.valid:
        return const Color(0xFF10B981);
      case _ValidationState.invalid:
        return const Color(0xFFEF4444);
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
            color: const Color(0xFF22BDD8),
          ),
        );
      case _ValidationState.valid:
        return const Icon(
          Icons.check_circle,
          size: 20,
          color: const Color(0xFF10B981),
        );
      case _ValidationState.invalid:
        return const Icon(
          Icons.error,
          size: 20,
          color: const Color(0xFFEF4444),
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
          color: const Color(0xFF0E0E1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
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
                  color: const Color(0xFFE8E8F0),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter your email address',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
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
        color: const Color(0xFF0E0E1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
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
                    color: const Color(0xFF1C1C2E),
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
                          ? const Color(0xFF22BDD8)
                          : const Color(0xFF9A9AB2),
                    ),
                  ),
                  selected: isSelected,
                  selectedTileColor: const Color(0xFF22BDD8).withValues(alpha: 0.05),
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
