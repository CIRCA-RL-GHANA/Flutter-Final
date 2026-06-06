import 'package:flutter/material.dart';
import '../../../core/design/ive.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive.dart';
import '../providers/role_provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/buttons.dart';
import '../widgets/onboarding_header.dart';


// OS palette — mirrors splash / welcome
/// Screen 8: Role Selection (Multi-Tenant)
/// Context-aware role assignment with future flexibility
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: IveTokens.dSlow,
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    final role = context.read<RoleProvider>();
    final onboarding = context.read<OnboardingProvider>();

    final success = await role.saveRole();
    if (!mounted) return;

    if (success) {
      onboarding.setRole(role.selectedRoleLabel, role.selectedSubRoleLabel);
      Navigator.of(context).pushNamed(AppRoutes.permissions);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: IveTokens.bg,
      body: SafeArea(
        child: Responsive.constrained(
          child: Column(
            children: [
              OnboardingHeader(
                title: AppStrings.selectRole,
                subtitle: 'How will you use genie help?',
                currentStep: 6,
                totalSteps: 8,
                onBack: () => Navigator.pop(context),
              ),

              Expanded(
                child: Consumer<RoleProvider>(
                  builder: (context, role, child) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),

                          // Role category cards
                          Row(
                            children: [
                              Expanded(
                                child: _RoleCategoryCard(
                                  title: AppStrings.individual,
                                  icon: Icons.person_outline,
                                  color: IveTokens.accent,
                                  features: role.getCategoryFeatures(
                                      RoleCategory.individual),
                                  isSelected: role.selectedCategory ==
                                      RoleCategory.individual,
                                  onTap: () => role.selectCategory(
                                      RoleCategory.individual),
                                  animation: _animController,
                                  delay: 0.0,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _RoleCategoryCard(
                                  title: AppStrings.business,
                                  icon: Icons.business_outlined,
                                  color: IveTokens.accentPressed,
                                  features: role.getCategoryFeatures(
                                      RoleCategory.business),
                                  isSelected: role.selectedCategory ==
                                      RoleCategory.business,
                                  onTap: () => role.selectCategory(
                                      RoleCategory.business),
                                  animation: _animController,
                                  delay: 0.1,
                                ),
                              ),
                            ],
                          ),

                          // Sub-role selection
                          if (role.selectedCategory != null) ...[
                            const SizedBox(height: 24),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Select your specific role:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: IveTokens.label,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            if (role.selectedCategory ==
                                RoleCategory.individual)
                              _buildIndividualSubRoles(role),

                            if (role.selectedCategory ==
                                RoleCategory.business)
                              _buildBusinessSubRoles(role),
                          ],

                          const SizedBox(height: 16),

                          // Info text
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: IveTokens.accent.withValues(alpha: 0.08),
                              borderRadius: IveTokens.brMd,
                              border: Border.all(
                                color: IveTokens.accent.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  size: 18,
                                  color: IveTokens.accent,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    role.selectedCategory == RoleCategory.individual
                                        ? 'Your individual account gives you Owner access — shop, socialise, and manage your personal finances.'
                                        : role.selectedCategory == RoleCategory.business
                                            ? 'Select the staff role you have been invited to join this business entity as.'
                                            : 'You can change your role anytime in settings.',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: IveTokens.accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom action
              Consumer<RoleProvider>(
                builder: (context, role, child) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    child: PrimaryButton(
                      text: AppStrings.continueBtn,
                      icon: Icons.arrow_forward,
                      isLoading: role.isLoading,
                      onPressed: role.canProceed ? _onContinue : null,
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

  Widget _buildIndividualSubRoles(RoleProvider role) {
    final subRoles = [
      const _SubRoleData(
        IndividualRole.buyer,
        'Buyer',
        'Primary shopping & social',
        Icons.shopping_bag_outlined,
        IveTokens.accent,
      ),
      const _SubRoleData(
        IndividualRole.deliveryPartner,
        'Delivery Partner',
        'Earn through deliveries',
        Icons.local_shipping_outlined,
        IveTokens.warning,
      ),
      const _SubRoleData(
        IndividualRole.transportProvider,
        'Transport Provider',
        'Offer rides',
        Icons.directions_car_outlined,
        IveTokens.accent,
      ),
    ];

    return Column(
      children: subRoles
          .map((sr) => _SubRoleCard(
                data: sr,
                isSelected: role.individualRole == sr.role,
                onTap: () =>
                    role.selectIndividualRole(sr.role as IndividualRole),
              ))
          .toList(),
    );
  }

  Widget _buildBusinessSubRoles(RoleProvider role) {
    // Owner is NOT listed here - Owner is the individual who created the entity,
    // not an assignable staff role. Business sub-roles are staff positions only.
    final subRoles = [
      const _SubRoleData(
        BusinessRole.administrator,
        'Administrator',
        'Day-to-day management',
        Icons.manage_accounts_outlined,
        IveTokens.success,
      ),
      const _SubRoleData(
        BusinessRole.branchManager,
        'Branch Manager',
        'Location-specific',
        Icons.store_outlined,
        IveTokens.warning,
      ),
      const _SubRoleData(
        BusinessRole.staff,
        'Staff',
        'Limited permissions',
        Icons.badge_outlined,
        IveTokens.labelSecondary,
      ),
    ];

    return Column(
      children: subRoles
          .map((sr) => _SubRoleCard(
                data: sr,
                isSelected: role.businessRole == sr.role,
                onTap: () => role.selectBusinessRole(sr.role as BusinessRole),
              ))
          .toList(),
    );
  }
}

class _RoleCategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> features;
  final bool isSelected;
  final VoidCallback onTap;
  final AnimationController animation;
  final double delay;

  const _RoleCategoryCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.features,
    required this.isSelected,
    required this.onTap,
    required this.animation,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Interval(delay, delay + 0.5, curve: Curves.easeOut),
      )),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: IveTokens.dFast,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.08) : IveTokens.surface,
            borderRadius: IveTokens.brXs,
            border: Border.all(
              color: isSelected ? color : IveTokens.hairline,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : IveTokens.label,
                ),
              ),
              const SizedBox(height: 8),
              ...features.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check,
                        size: 14,
                        color: isSelected ? color : IveTokens.labelTertiary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          f,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? IveTokens.label
                                : IveTokens.labelSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? color : IveTokens.surface,
                  borderRadius: IveTokens.brXs,
                ),
                child: Text(
                  isSelected ? 'Selected' : 'Select',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : IveTokens.labelSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubRoleData {
  final dynamic role;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _SubRoleData(
    this.role,
    this.title,
    this.description,
    this.icon,
    this.color,
  );
}

class _SubRoleCard extends StatelessWidget {
  final _SubRoleData data;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubRoleCard({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: IveTokens.dFast,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? data.color.withValues(alpha: 0.06)
                : IveTokens.surface,
            borderRadius: IveTokens.brMd,
            border: Border.all(
              color: isSelected ? data.color : IveTokens.hairline,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, size: 22, color: data.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? data.color
                            : IveTokens.label,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: IveTokens.labelTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected ? data.color : IveTokens.labelTertiary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
