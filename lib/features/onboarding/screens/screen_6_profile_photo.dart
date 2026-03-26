import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/helpers.dart';
import '../providers/profile_provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/buttons.dart';
import '../widgets/onboarding_header.dart';
import '../widgets/progress_indicators.dart';

/// Screen 6: Profile Photo and Username
/// Identity creation with social validation
class ProfilePhotoScreen extends StatefulWidget {
  const ProfilePhotoScreen({super.key});

  @override
  State<ProfilePhotoScreen> createState() => _ProfilePhotoScreenState();
}

class _ProfilePhotoScreenState extends State<ProfilePhotoScreen> {
  late TextEditingController _usernameController;
  final Debouncer _debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();

    // Generate suggestions based on registered name
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final onboarding = context.read<OnboardingProvider>();
      if (onboarding.firstName.isNotEmpty) {
        context.read<ProfileProvider>().generateSuggestions(
              onboarding.firstName,
              onboarding.lastName,
            );
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _debouncer.cancel();
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    final profile = context.read<ProfileProvider>();
    final cleaned = value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '');
    profile.setUsername(cleaned);

    _debouncer.run(() {
      profile.checkUsername(cleaned);
    });
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Profile Photo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            _PhotoOptionTile(
              icon: Icons.camera_alt_outlined,
              label: AppStrings.takePhoto,
              color: AppColors.primaryLight,
              onTap: () {
                Navigator.pop(context);
                _pickPhoto('camera');
              },
            ),
            _PhotoOptionTile(
              icon: Icons.photo_library_outlined,
              label: AppStrings.chooseFromGallery,
              color: AppColors.roleShop,
              onTap: () {
                Navigator.pop(context);
                _pickPhoto('gallery');
              },
            ),
            _PhotoOptionTile(
              icon: Icons.auto_awesome,
              label: AppStrings.generateAiAvatar,
              color: AppColors.roleBuyer,
              onTap: () {
                Navigator.pop(context);
                _generateAiAvatar();
              },
            ),
            _PhotoOptionTile(
              icon: Icons.skip_next_outlined,
              label: AppStrings.skipForNow,
              color: AppColors.textTertiary,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _pickPhoto(String source) {
    // In production: Use image_picker + image_cropper
    // Simulate photo selection for demo
    context.read<ProfileProvider>().setPhoto('assets/images/avatar_demo.png');
  }

  void _generateAiAvatar() {
    // In production: Generate AI avatar based on user data
    context.read<ProfileProvider>().setPhoto('assets/images/ai_avatar.png');
  }

  Future<void> _onContinue() async {
    final profile = context.read<ProfileProvider>();
    final onboarding = context.read<OnboardingProvider>();

    final success = await profile.saveProfile();
    if (!mounted) return;

    if (success) {
      onboarding.setProfileData(
        photoPath: profile.photoPath,
        username: profile.username,
      );
      Navigator.of(context).pushNamed(AppRoutes.biometric);
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
                title: 'Create Your Profile',
                subtitle: 'Add a photo and choose your username',
                currentStep: 4,
                totalSteps: 8,
                onBack: () => Navigator.pop(context),
              ),

              Expanded(
                child: Consumer<ProfileProvider>(
                  builder: (context, profile, child) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),

                          // Section 1: Profile Photo
                          GestureDetector(
                            onTap: _showPhotoOptions,
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.inputFill,
                                        border: Border.all(
                                          color: profile.hasPhoto
                                              ? AppColors.primaryLight
                                              : AppColors.inputBorder,
                                          width: 3,
                                        ),
                                        image: profile.hasPhoto
                                            ? const DecorationImage(
                                                image: AssetImage(
                                                    'assets/images/avatar_demo.png'),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: !profile.hasPhoto
                                          ? const Icon(
                                              Icons.person,
                                              size: 48,
                                              color: AppColors.textTertiary,
                                            )
                                          : null,
                                    ),
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryLight,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  profile.hasPhoto
                                      ? 'Change Photo'
                                      : AppStrings.addPhoto,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Section 2: Username
                          Align(
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              AppStrings.username,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _usernameController,
                            onChanged: _onUsernameChanged,
                            decoration: InputDecoration(
                              prefixText: '@ ',
                              prefixStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                              hintText: 'Choose a username',
                              suffixIcon: _buildUsernameSuffix(profile),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: _getUsernameBorderColor(
                                      profile.usernameStatus),
                                ),
                              ),
                            ),
                          ),

                          // Username status text
                          if (profile.usernameStatus != UsernameStatus.idle)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, left: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    _getUsernameIcon(profile.usernameStatus),
                                    size: 14,
                                    color: _getUsernameColor(
                                        profile.usernameStatus),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getUsernameText(profile.usernameStatus),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _getUsernameColor(
                                          profile.usernameStatus),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Username suggestions
                          if (profile.suggestions.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: const Text(
                                'Suggestions:',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: profile.suggestions.map((suggestion) {
                                return GestureDetector(
                                  onTap: () {
                                    _usernameController.text = suggestion;
                                    _onUsernameChanged(suggestion);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.primaryLight.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.primaryLight
                                            .withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      '@$suggestion',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.primaryLight,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],

                          const SizedBox(height: 32),

                          // Section 3: Profile Completeness
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.inputFill,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                CompletionCircle(
                                  score: profile.totalPoints,
                                  total: 100,
                                  size: 60,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${profile.totalPoints}/100 points',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        AppStrings.completeProfile,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textTertiary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      _PointsRow(
                                        label: 'Photo',
                                        points: profile.photoPoints,
                                        maxPoints: 20,
                                      ),
                                      _PointsRow(
                                        label: 'Username',
                                        points: profile.usernamePoints,
                                        maxPoints: 20,
                                      ),
                                    ],
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
              Consumer<ProfileProvider>(
                builder: (context, profile, child) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    child: Column(
                      children: [
                        PrimaryButton(
                          text: AppStrings.continueBtn,
                          icon: Icons.arrow_forward,
                          isLoading: profile.isLoading,
                          onPressed: profile.canProceed ? _onContinue : null,
                          margin: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 8),
                        SecondaryButton(
                          text: AppStrings.skipForNow,
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(AppRoutes.biometric);
                          },
                        ),
                      ],
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

  Widget? _buildUsernameSuffix(ProfileProvider profile) {
    switch (profile.usernameStatus) {
      case UsernameStatus.checking:
        return const Padding(
          padding: EdgeInsets.all(16),
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      case UsernameStatus.available:
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Icon(Icons.check_circle, color: AppColors.success, size: 20),
        );
      case UsernameStatus.taken:
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Icon(Icons.cancel, color: AppColors.error, size: 20),
        );
      case UsernameStatus.invalid:
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Icon(Icons.warning, color: AppColors.warning, size: 20),
        );
      default:
        return null;
    }
  }

  Color _getUsernameBorderColor(UsernameStatus status) {
    switch (status) {
      case UsernameStatus.available:
        return AppColors.success;
      case UsernameStatus.taken:
        return AppColors.error;
      case UsernameStatus.invalid:
        return AppColors.warning;
      default:
        return AppColors.inputBorder;
    }
  }

  Color _getUsernameColor(UsernameStatus status) {
    switch (status) {
      case UsernameStatus.available:
        return AppColors.success;
      case UsernameStatus.taken:
        return AppColors.error;
      case UsernameStatus.invalid:
        return AppColors.warning;
      case UsernameStatus.checking:
        return AppColors.textTertiary;
      default:
        return AppColors.textTertiary;
    }
  }

  IconData _getUsernameIcon(UsernameStatus status) {
    switch (status) {
      case UsernameStatus.available:
        return Icons.check_circle;
      case UsernameStatus.taken:
        return Icons.cancel;
      case UsernameStatus.invalid:
        return Icons.warning;
      case UsernameStatus.checking:
        return Icons.hourglass_top;
      default:
        return Icons.info;
    }
  }

  String _getUsernameText(UsernameStatus status) {
    switch (status) {
      case UsernameStatus.available:
        return AppStrings.usernameAvailable;
      case UsernameStatus.taken:
        return AppStrings.usernameTaken;
      case UsernameStatus.invalid:
        return 'Invalid username format';
      case UsernameStatus.checking:
        return AppStrings.usernameChecking;
      default:
        return '';
    }
  }
}

class _PhotoOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PhotoOptionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _PointsRow extends StatelessWidget {
  final String label;
  final int points;
  final int maxPoints;

  const _PointsRow({
    required this.label,
    required this.points,
    required this.maxPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(
            points > 0 ? Icons.check_circle : Icons.circle_outlined,
            size: 12,
            color: points > 0 ? AppColors.success : AppColors.textTertiary,
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $points/$maxPoints',
            style: TextStyle(
              fontSize: 11,
              color: points > 0
                  ? AppColors.textSecondary
                  : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
