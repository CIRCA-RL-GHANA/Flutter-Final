import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/responsive.dart';
import '../providers/role_provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_header.dart';
import '../widgets/onboarding_loading_overlay.dart';

/// Screen 09 — Role selection, step 06/08.
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  Future<void> _onContinue(BuildContext context) async {
    final role = context.read<RoleProvider>();
    final onboarding = context.read<OnboardingProvider>();
    final success = await role.saveRole();
    if (!context.mounted) return;
    if (success) {
      onboarding.setRole(role.selectedRoleLabel, role.selectedSubRoleLabel);
      Navigator.of(context).pushNamed(AppRoutes.permissions);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoleProvider>(
      builder: (context, role, _) => OnboardingLoadingOverlay(
        isLoading: role.isLoading,
        child: Scaffold(
          backgroundColor: IveTokens.bg,
          body: SafeArea(
            child: Responsive.constrained(
              child: Column(
                children: [
                  OnboardingHeader(
                    title: 'Choose your role',
                    subtitle: 'Pick a category, then a sub-role.',
                    currentStep: 6,
                    totalSteps: 8,
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // INDIVIDUAL section
                          _SectionHeader('INDIVIDUAL'),
                          const SizedBox(height: 8),
                          _RoleRow(
                            title: 'Buyer',
                            subtitle: 'Shop, pay, track deliveries',
                            isSelected: role.selectedCategory ==
                                    RoleCategory.individual &&
                                role.individualRole == IndividualRole.buyer,
                            onTap: () {
                              role.selectCategory(RoleCategory.individual);
                              role.selectIndividualRole(IndividualRole.buyer);
                            },
                          ),
                          const SizedBox(height: 8),
                          _RoleRow(
                            title: 'Delivery Partner',
                            subtitle: 'Deliver packages, earn',
                            isSelected: role.selectedCategory ==
                                    RoleCategory.individual &&
                                role.individualRole ==
                                    IndividualRole.deliveryPartner,
                            onTap: () {
                              role.selectCategory(RoleCategory.individual);
                              role.selectIndividualRole(
                                  IndividualRole.deliveryPartner);
                            },
                          ),
                          const SizedBox(height: 8),
                          _RoleRow(
                            title: 'Transport Provider',
                            subtitle: 'Ride-hailing driver',
                            isSelected: role.selectedCategory ==
                                    RoleCategory.individual &&
                                role.individualRole ==
                                    IndividualRole.transportProvider,
                            onTap: () {
                              role.selectCategory(RoleCategory.individual);
                              role.selectIndividualRole(
                                  IndividualRole.transportProvider);
                            },
                          ),

                          const SizedBox(height: 24),

                          // BUSINESS section
                          _SectionHeader('BUSINESS'),
                          const SizedBox(height: 8),
                          _RoleRow(
                            title: 'Administrator',
                            subtitle: 'Full business management',
                            isSelected: role.selectedCategory ==
                                    RoleCategory.business &&
                                role.businessRole == BusinessRole.administrator,
                            onTap: () {
                              role.selectCategory(RoleCategory.business);
                              role.selectBusinessRole(
                                  BusinessRole.administrator);
                            },
                          ),
                          const SizedBox(height: 8),
                          _RoleRow(
                            title: 'Branch Manager',
                            subtitle: 'Run a single branch',
                            isSelected: role.selectedCategory ==
                                    RoleCategory.business &&
                                role.businessRole == BusinessRole.branchManager,
                            onTap: () {
                              role.selectCategory(RoleCategory.business);
                              role.selectBusinessRole(
                                  BusinessRole.branchManager);
                            },
                          ),
                          const SizedBox(height: 8),
                          _RoleRow(
                            title: 'Staff',
                            subtitle: 'Assigned staff role',
                            isSelected: role.selectedCategory ==
                                    RoleCategory.business &&
                                role.businessRole == BusinessRole.staff,
                            onTap: () {
                              role.selectCategory(RoleCategory.business);
                              role.selectBusinessRole(BusinessRole.staff);
                            },
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    child: IveButton.primary(
                      label: 'CONTINUE',
                      isLoading: role.isLoading,
                      onPressed: role.canProceed
                          ? () => _onContinue(context)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: IveType.mono.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: IveTokens.mute,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _RoleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleRow({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: IveTokens.dFast,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: IveTokens.surface,
          borderRadius: BorderRadius.circular(IveTokens.rSm),
          border: Border.all(
            color: isSelected ? IveTokens.accent : IveTokens.hairline,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Labels
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? IveTokens.ink : IveTokens.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: IveTokens.mute,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // SELECT / SELECTED badge
            AnimatedContainer(
              duration: IveTokens.dFast,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? IveTokens.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: isSelected
                    ? null
                    : Border.all(color: IveTokens.hairline2),
              ),
              child: Text(
                isSelected ? 'SELECTED' : 'SELECT',
                style: IveType.mono.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : IveTokens.ink2,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
