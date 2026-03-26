import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive.dart';
import '../providers/permission_provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/buttons.dart';

/// Screen 9: Permissions Onboarding
/// Just-in-time, benefit-focused permission requests
class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _onAllow(AppPermission permission) async {
    final permProvider = context.read<PermissionProvider>();
    await permProvider.requestPermission(permission);
    _moveToNext(permProvider);
  }

  void _onSkip(AppPermission permission) {
    final permProvider = context.read<PermissionProvider>();
    permProvider.skipPermission(permission);
    _moveToNext(permProvider);
  }

  void _moveToNext(PermissionProvider permProvider) {
    permProvider.moveToNext();

    if (permProvider.allGroupsProcessed) {
      context.read<OnboardingProvider>().completePermissions();
      Navigator.of(context).pushReplacementNamed(AppRoutes.success);
    } else {
      // Re-animate for next permission
      _animController.reset();
      _animController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Responsive.constrained(
          child: Consumer<PermissionProvider>(
            builder: (context, permProvider, child) {
              final currentPerm = permProvider.currentPermission;

              if (currentPerm == null || permProvider.allGroupsProcessed) {
                // All done, navigate
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<OnboardingProvider>().completePermissions();
                  Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.success);
                });
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryLight,
                  ),
                );
              }

              return Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.inputFill,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 18,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              'Step 7 of 8',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textTertiary,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Skip all remaining permissions
                                context
                                    .read<OnboardingProvider>()
                                    .completePermissions();
                                Navigator.of(context)
                                    .pushReplacementNamed(AppRoutes.success);
                              },
                              child: const Text(
                                'Skip All',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: permProvider.progress,
                            backgroundColor: AppColors.inputFill,
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryLight),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main content
                  Expanded(
                    child: FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _animController,
                        curve: Curves.easeIn,
                      ),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.2, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _animController,
                          curve: Curves.easeOut,
                        )),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Permission group badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getGroupColor(
                                          permProvider.currentGroup)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _getGroupLabel(permProvider.currentGroup),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _getGroupColor(
                                        permProvider.currentGroup),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Permission icon
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryLight
                                      .withOpacity(0.08),
                                ),
                                child: Icon(
                                  _getPermissionIconData(currentPerm),
                                  size: 56,
                                  color: AppColors.primaryLight,
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Permission name
                              Text(
                                permProvider
                                    .getPermissionLabel(currentPerm),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Benefit text
                              Text(
                                permProvider
                                    .getBenefitText(currentPerm),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 16),

                              // Visual preview placeholder
                              Container(
                                width: double.infinity,
                                height: 160,
                                decoration: BoxDecoration(
                                  color: AppColors.inputFill,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _getPermissionIconData(currentPerm),
                                      size: 40,
                                      color:
                                          AppColors.textTertiary.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Feature Preview',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    child: Column(
                      children: [
                        PrimaryButton(
                          text: AppStrings.allow,
                          icon: Icons.check,
                          isLoading: permProvider.isLoading,
                          onPressed: () => _onAllow(currentPerm),
                          margin: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 12),
                        OutlinedActionButton(
                          text: AppStrings.notNow,
                          onPressed: () => _onSkip(currentPerm),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.enableLater,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  IconData _getPermissionIconData(AppPermission permission) {
    switch (permission) {
      case AppPermission.notifications:
        return Icons.notifications_outlined;
      case AppPermission.locationCoarse:
      case AppPermission.locationPrecise:
        return Icons.location_on_outlined;
      case AppPermission.contacts:
        return Icons.contacts_outlined;
      case AppPermission.camera:
        return Icons.camera_alt_outlined;
      case AppPermission.microphone:
        return Icons.mic_outlined;
      case AppPermission.files:
        return Icons.folder_outlined;
      case AppPermission.calendar:
        return Icons.calendar_today_outlined;
    }
  }

  Color _getGroupColor(PermissionGroup group) {
    switch (group) {
      case PermissionGroup.essential:
        return AppColors.primaryLight;
      case PermissionGroup.enhanced:
        return AppColors.success;
      case PermissionGroup.premium:
        return AppColors.accent;
    }
  }

  String _getGroupLabel(PermissionGroup group) {
    switch (group) {
      case PermissionGroup.essential:
        return 'Essential';
      case PermissionGroup.enhanced:
        return 'Enhanced';
      case PermissionGroup.premium:
        return 'Premium';
    }
  }
}
