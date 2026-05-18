import 'package:flutter/material.dart';
import '../../../core/design/ive.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/helpers.dart';
import '../providers/profile_provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/buttons.dart';
import '../widgets/onboarding_header.dart';
import '../widgets/progress_indicators.dart';


// OS palette ï¿½ mirrors splash / welcome
const Color _kBg        = IveTokens.bg;
const Color _kSurface   = IveTokens.surface;
const Color _kBorder    = IveTokens.hairline;
const Color _kAccent    = IveTokens.accent;
const Color _kAccentDim = IveTokens.accentPressed;
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
          color: IveTokens.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(IveTokens.rLg)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: IveTokens.hairline,
                borderRadius: IveTokens.brXs,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Profile Photo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: IveTokens.label,
              ),
            ),
            const SizedBox(height: 24),
            _PhotoOptionTile(
              icon: Icons.camera_alt_outlined,
              label: AppStrings.takePhoto,
              color: IveTokens.accent,
              onTap: () {
                Navigator.pop(context);
                _pickPhoto('camera');
              },
            ),
            _PhotoOptionTile(
              icon: Icons.photo_library_outlined,
              label: AppStrings.chooseFromGallery,
              color: IveTokens.success,
              onTap: () {
                Navigator.pop(context);
                _pickPhoto('gallery');
              },
            ),
            _PhotoOptionTile(
              icon: Icons.auto_awesome,
              label: AppStrings.generateAiAvatar,
              color: IveTokens.accent,
              onTap: () {
                Navigator.pop(context);
                _generateAiAvatar();
              },
            ),
            _PhotoOptionTile(
              icon: Icons.skip_next_outlined,
              label: AppStrings.skipForNow,
              color: IveTokens.labelTertiary,
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
      backgroundColor: IveTokens.bg,
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
                                        color: IveTokens.surface,
                                        border: Border.all(
                                          color: profile.hasPhoto
                                              ? IveTokens.accent
                                              : IveTokens.hairline,
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
                                              color: IveTokens.labelTertiary,
                                            )
                                          : null,
                                    ),
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: const BoxDecoration(
                                        color: IveTokens.accent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: IveTokens.surface,
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
                                    color: IveTokens.accent,
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
                                color: IveTokens.labelSecondary,
                              ),
                              hintText: 'Choose a username',
                              suffixIcon: _buildUsernameSuffix(profile),
                              border: OutlineInputBorder(
                                borderRadius: IveTokens.brXs,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: IveTokens.brXs,
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
                                  color: IveTokens.labelTertiary,
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
                                          IveTokens.accent.withValues(alpha: 0.1),
                                      borderRadius: IveTokens.brXs,
                                      border: Border.all(
                                        color: IveTokens.accent
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      '@$suggestion',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: IveTokens.accent,
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
                              color: IveTokens.surface,
                              borderRadius: IveTokens.brXs,
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
                                          color: IveTokens.label,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        AppStrings.completeProfile,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: IveTokens.labelTertiary,
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
          child: Icon(Icons.check_circle, color: IveTokens.success, size: 20),
        );
      case UsernameStatus.taken:
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Icon(Icons.cancel, color: IveTokens.danger, size: 20),
        );
      case UsernameStatus.invalid:
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Icon(Icons.warning, color: IveTokens.warning, size: 20),
        );
      default:
        return null;
    }
  }

  Color _getUsernameBorderColor(UsernameStatus status) {
    switch (status) {
      case UsernameStatus.available:
        return IveTokens.success;
      case UsernameStatus.taken:
        return IveTokens.danger;
      case UsernameStatus.invalid:
        return IveTokens.warning;
      default:
        return IveTokens.hairline;
    }
  }

  Color _getUsernameColor(UsernameStatus status) {
    switch (status) {
      case UsernameStatus.available:
        return IveTokens.success;
      case UsernameStatus.taken:
        return IveTokens.danger;
      case UsernameStatus.invalid:
        return IveTokens.warning;
      case UsernameStatus.checking:
        return IveTokens.labelTertiary;
      default:
        return IveTokens.labelTertiary;
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
          color: color.withValues(alpha: 0.1),
          borderRadius: IveTokens.brMd,
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
            color: points > 0 ? IveTokens.success : IveTokens.labelTertiary,
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $points/$maxPoints',
            style: TextStyle(
              fontSize: 11,
              color: points > 0
                  ? IveTokens.labelSecondary
                  : IveTokens.labelTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
