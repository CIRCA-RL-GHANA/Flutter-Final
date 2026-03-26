import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/helpers.dart';
import '../providers/registration_provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/buttons.dart';
import '../widgets/onboarding_header.dart';

/// Screen 5: User Registration (Comprehensive)
/// Progressive profiling with privacy-first approach
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final reg = context.read<RegistrationProvider>();
    _firstNameController = TextEditingController(text: reg.firstName);
    _lastNameController = TextEditingController(text: reg.lastName);
    _emailController = TextEditingController(text: reg.email);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSaveAndContinue() async {
    if (!_formKey.currentState!.validate()) return;

    final reg = context.read<RegistrationProvider>();
    final onboarding = context.read<OnboardingProvider>();

    final success = await reg.saveRegistration(
      phoneNumber: onboarding.phoneNumber,
      socialUsername: onboarding.username,
      wireId: '',
      password: '',
    );
    if (!mounted) return;

    if (success) {
      onboarding.setRegistrationData(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        dateOfBirth: reg.dateOfBirth,
      );

      Navigator.of(context).pushNamed(AppRoutes.profilePhoto);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(reg.error ?? AppStrings.couldntSave),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showDatePicker() async {
    final reg = context.read<RegistrationProvider>();
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: reg.dateOfBirth ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(now.year - 120),
      lastDate: DateTime(now.year - 13, now.month, now.day),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryLight,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      reg.setDateOfBirth(picked);
    }
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
                title: AppStrings.basicInfo,
                subtitle: 'Tell us a bit about yourself',
                currentStep: 3,
                totalSteps: 8,
                onBack: () => Navigator.pop(context),
                trailing: TextButton(
                  onPressed: () {
                    // Skip and complete later
                    Navigator.of(context).pushNamed(AppRoutes.profilePhoto);
                  },
                  child: const Text(
                    AppStrings.completeLater,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Consumer<RegistrationProvider>(
                  builder: (context, reg, child) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Field 1: Full Name
                            const _SectionLabel(
                              label: AppStrings.legalFullName,
                              hint: AppStrings.nameHint,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _firstNameController,
                              onChanged: reg.setFirstName,
                              validator: Validators.validateName,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                labelText: AppStrings.firstName,
                                prefixIcon: const Icon(Icons.person_outline, size: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _lastNameController,
                              onChanged: reg.setLastName,
                              validator: Validators.validateName,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                labelText: AppStrings.lastName,
                                prefixIcon: const Icon(Icons.person_outline, size: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppStrings.forIdentityVerification,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Field 2: Email (Optional)
                            const _SectionLabel(
                              label: AppStrings.emailOptional,
                              hint: AppStrings.emailSubtitle,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              onChanged: reg.setEmail,
                              validator: Validators.validateEmail,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email address',
                                prefixIcon: const Icon(Icons.email_outlined, size: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Email incentive
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: AppColors.accent.withOpacity(0.8),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    AppStrings.emailIncentive,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Field 3: Date of Birth
                            const _SectionLabel(
                              label: AppStrings.dateOfBirth,
                              hint: AppStrings.dobPrivacy,
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _showDatePicker,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.inputFill,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.inputBorder,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 20,
                                      color: AppColors.textTertiary,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      reg.dateOfBirth != null
                                          ? '${reg.dateOfBirth!.month}/${reg.dateOfBirth!.day}/${reg.dateOfBirth!.year}'
                                          : 'Select date of birth',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: reg.dateOfBirth != null
                                            ? AppColors.textPrimary
                                            : AppColors.textTertiary,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.keyboard_arrow_down,
                                      color: AppColors.textTertiary,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Privacy Dashboard
                            _PrivacyDashboard(
                              marketingEmails: reg.marketingEmails,
                              dataSharing: reg.dataSharing,
                              personalizedAds: reg.personalizedAds,
                              onMarketingChanged: reg.setMarketingEmails,
                              onDataSharingChanged: reg.setDataSharing,
                              onAdsChanged: reg.setPersonalizedAds,
                            ),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom action
              Consumer<RegistrationProvider>(
                builder: (context, reg, child) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    child: PrimaryButton(
                      text: AppStrings.saveAndContinue,
                      icon: Icons.arrow_forward,
                      isLoading: reg.isLoading,
                      onPressed: reg.canProceed ? _onSaveAndContinue : null,
                      margin: EdgeInsets.zero,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final String hint;

  const _SectionLabel({required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          hint,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _PrivacyDashboard extends StatelessWidget {
  final bool marketingEmails;
  final bool dataSharing;
  final bool personalizedAds;
  final ValueChanged<bool> onMarketingChanged;
  final ValueChanged<bool> onDataSharingChanged;
  final ValueChanged<bool> onAdsChanged;

  const _PrivacyDashboard({
    required this.marketingEmails,
    required this.dataSharing,
    required this.personalizedAds,
    required this.onMarketingChanged,
    required this.onDataSharingChanged,
    required this.onAdsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, size: 20, color: AppColors.primaryLight),
              const SizedBox(width: 8),
              const Text(
                'Privacy Preferences',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _PrivacyToggle(
            label: AppStrings.marketingEmails,
            value: marketingEmails,
            onChanged: onMarketingChanged,
          ),
          _PrivacyToggle(
            label: AppStrings.dataSharing,
            value: dataSharing,
            onChanged: onDataSharingChanged,
          ),
          _PrivacyToggle(
            label: AppStrings.personalizedAds,
            value: personalizedAds,
            onChanged: onAdsChanged,
          ),

          const Divider(height: 24),

          // Legal links
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              const _LegalLink(label: AppStrings.termsOfService),
              const _LegalLink(label: AppStrings.privacyPolicy),
              const _LegalLink(label: AppStrings.dataProcessing),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrivacyToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PrivacyToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryLight,
          ),
        ],
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  final String label;

  const _LegalLink({required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Open legal document
      },
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.primaryLight,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
