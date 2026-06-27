/// qualChat Screen 14  Onboarding Flow
/// 4-step flow: Welcome & Permissions  Role Config  Profile Setup  Quick Tour
library;

import 'package:flutter/material.dart';
import '../../../core/design/ive.dart';
import '../../../core/utils/app_toast.dart';
import 'package:provider/provider.dart';
import '../models/qualchat_models.dart';
import '../providers/qualchat_provider.dart';
import '../widgets/qualchat_widgets.dart';

class QualChatOnboardingScreen extends StatelessWidget {
  const QualChatOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QualChatProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: IveTokens.bg,
          body: SafeArea(
            child: Column(
              children: [
                // Step indicator
                _StepIndicator(current: provider.onboardingStep, total: 4),

                // Step content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildStep(context, provider, provider.onboardingStep),
                  ),
                ),

                // Navigation
                _StepNavigation(
                  step: provider.onboardingStep,
                  onBack: provider.onboardingStep > 0
                      ? () => provider.setOnboardingStep(provider.onboardingStep - 1)
                      : null,
                  onNext: () {
                    if (provider.onboardingStep < 3) {
                      provider.setOnboardingStep(provider.onboardingStep + 1);
                    } else {
                      // Complete onboarding
                      Navigator.pushReplacementNamed(context, '/qualchat');
                    }
                  },
                  isLast: provider.onboardingStep == 3,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStep(BuildContext context, QualChatProvider provider, int step) {
    switch (step) {
      case 0:
        return const _WelcomeStep(key: ValueKey(0));
      case 1:
        return _RoleConfigStep(key: const ValueKey(1), provider: provider);
      case 2:
        return _ProfileSetupStep(key: const ValueKey(2), provider: provider);
      case 3:
        return const _QuickTourStep(key: ValueKey(3));
      default:
        return const SizedBox.shrink();
    }
  }
}

//  Step 0: Welcome & Permissions 
class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: IveTokens.moduleQualChat.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble, size: 56, color: IveTokens.moduleQualChat),
          ),
          const SizedBox(height: 32),
          Text(
            'Welcome to qualChat!',
            style: IveType.title2.copyWith(color: IveTokens.ink),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Your intelligent communications hub.\nConnect, chat, and build meaningful relationships.',
            style: IveType.body.copyWith(color: IveTokens.mute, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Permissions
          const _PermissionItem(
            icon: Icons.notifications,
            title: 'Notifications',
            description: 'Stay updated with new messages',
            granted: true,
          ),
          const SizedBox(height: 12),
          const _PermissionItem(
            icon: Icons.contacts,
            title: 'Contacts',
            description: 'Find friends and connections',
            granted: false,
          ),
          const SizedBox(height: 12),
          const _PermissionItem(
            icon: Icons.photo_camera,
            title: 'Camera & Photos',
            description: 'Share photos and media',
            granted: false,
          ),
        ],
      ),
    );
  }
}

class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool granted;
  const _PermissionItem({required this.icon, required this.title, required this.description, required this.granted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: granted ? IveTokens.success.withValues(alpha: 0.08) : IveTokens.surfaceRaised,
        borderRadius: BorderRadius.circular(IveTokens.rSm),
        border: Border.all(
          color: granted ? IveTokens.success.withValues(alpha: 0.3) : IveTokens.hairline,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: granted ? IveTokens.success : IveTokens.mute),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: IveType.bodyEmphasis.copyWith(color: IveTokens.ink)),
                Text(description, style: IveType.caption.copyWith(color: IveTokens.mute)),
              ],
            ),
          ),
          if (granted)
            const Icon(Icons.check_circle, color: IveTokens.success, size: 24)
          else
            OutlinedButton(
              onPressed: () => AppToast.show(context, 'Permission granted'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: IveTokens.moduleQualChat),
                foregroundColor: IveTokens.moduleQualChat,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(IveTokens.rSm)),
              ),
              child: Text('Grant', style: IveType.caption.copyWith(color: IveTokens.moduleQualChat)),
            ),
        ],
      ),
    );
  }
}

//  Step 1: Role Configuration 
class _RoleConfigStep extends StatelessWidget {
  final QualChatProvider provider;
  const _RoleConfigStep({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How will you use qualChat?',
            style: IveType.title3.copyWith(color: IveTokens.ink),
          ),
          const SizedBox(height: 8),
          Text(
            'This helps us personalize your experience',
            style: IveType.body.copyWith(color: IveTokens.mute),
          ),
          const SizedBox(height: 32),

          ...ChatUsageType.values.map((type) {
            final isSelected = provider.selectedUsageType == type;
            final configs = {
              ChatUsageType.socialDating: {'emoji': '', 'title': 'Social & Dating', 'desc': 'Connect with new people, find matches, build relationships'},
              ChatUsageType.professionalNetworking: {'emoji': '', 'title': 'Professional Networking', 'desc': 'Business communication, networking'},
              ChatUsageType.teamCommunications: {'emoji': '', 'title': 'Team Communications', 'desc': 'Team collaboration and group messaging'},
              ChatUsageType.driverConnections: {'emoji': '', 'title': 'Driver Connections', 'desc': 'Connect with drivers and coordinate rides'},
              ChatUsageType.monitoring: {'emoji': '', 'title': 'Monitoring', 'desc': 'Monitor and manage communications'},
            };
            final config = configs[type]!;

            return GestureDetector(
              onTap: () => provider.setUsageType(type),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected ? IveTokens.moduleQualChat.withValues(alpha: 0.08) : IveTokens.surface,
                  borderRadius: BorderRadius.circular(IveTokens.rSm),
                  border: Border.all(
                    color: isSelected ? IveTokens.moduleQualChat : IveTokens.hairline,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(config['emoji']!, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            config['title']!,
                            style: IveType.bodyEmphasis.copyWith(
                              color: isSelected ? IveTokens.moduleQualChat : IveTokens.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            config['desc']!,
                            style: IveType.caption.copyWith(color: IveTokens.mute),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle, color: IveTokens.moduleQualChat, size: 28),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

//  Step 2: Profile Setup 
class _ProfileSetupStep extends StatelessWidget {
  final QualChatProvider provider;
  const _ProfileSetupStep({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set up your profile',
            style: IveType.title3.copyWith(color: IveTokens.ink),
          ),
          const SizedBox(height: 8),
          Text(
            'Make a great first impression',
            style: IveType.body.copyWith(color: IveTokens.mute),
          ),
          const SizedBox(height: 32),

          // Profile photo
          Center(
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: IveTokens.moduleQualChat.withValues(alpha: 0.1),
                    border: Border.all(color: IveTokens.moduleQualChat, width: 3),
                  ),
                  child: const Icon(Icons.person, size: 48, color: IveTokens.moduleQualChat),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: IveTokens.moduleQualChat,
                    ),
                    child: const Icon(Icons.camera_alt, size: 16, color: IveTokens.ink),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Display name
          TextField(
            decoration: InputDecoration(
              labelText: 'Display Name',
              hintText: 'How should others see you?',
              filled: true,
              fillColor: IveTokens.surfaceRaised,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(IveTokens.rSm), borderSide: BorderSide.none),
              prefixIcon: const Icon(Icons.person_outline, color: IveTokens.moduleQualChat),
            ),
          ),
          const SizedBox(height: 16),

          // Bio
          TextField(
            maxLines: 3,
            maxLength: 160,
            decoration: InputDecoration(
              labelText: 'Bio',
              hintText: 'Tell us about yourself...',
              filled: true,
              fillColor: IveTokens.surfaceRaised,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(IveTokens.rSm), borderSide: BorderSide.none),
              prefixIcon: const Icon(Icons.edit_note, color: IveTokens.moduleQualChat),
            ),
          ),
          const SizedBox(height: 16),

          // Vibe tags
          Text(
            'Select your vibes',
            style: IveType.bodyEmphasis.copyWith(color: IveTokens.ink),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: VibeTag.values.map((tag) {
              final isSelected = provider.selectedVibeTags.contains(tag);
              final tagEmojis = {
                VibeTag.adventurous: '',
                VibeTag.creative: '',
                VibeTag.nerdy: '',
                VibeTag.foodie: '',
                VibeTag.musical: '',
                VibeTag.pets: '',
                VibeTag.travel: '',
                VibeTag.gaming: '',
                VibeTag.calm: '',
              };
              return GestureDetector(
                onTap: () => provider.toggleVibeTag(tag),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? IveTokens.moduleQualChat : IveTokens.surfaceRaised,
                    borderRadius: BorderRadius.circular(IveTokens.rSm),
                    border: Border.all(
                      color: isSelected ? IveTokens.moduleQualChat : IveTokens.hairline,
                    ),
                  ),
                  child: Text(
                    '${tagEmojis[tag] ?? ''} ${tag.name}',
                    style: IveType.caption.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isSelected ? IveTokens.bg : IveTokens.ink2,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Privacy note
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: IveTokens.info.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(IveTokens.rSm),
              border: Border.all(color: IveTokens.moduleQualChat.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: IveTokens.moduleQualChat.withValues(alpha: 0.7)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your profile is only visible to people you choose. You can change these settings anytime.',
                    style: IveType.caption.copyWith(color: IveTokens.ink2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//  Step 3: Quick Tour 
class _QuickTourStep extends StatelessWidget {
  const _QuickTourStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Text(
            "You're all set!",
            style: IveType.title2.copyWith(color: IveTokens.ink),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Here's what you can do with qualChat",
            style: IveType.body.copyWith(color: IveTokens.mute),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          const _TourFeature(
            icon: Icons.chat_bubble,
            color: IveTokens.moduleQualChat,
            title: 'Smart Chat',
            description: 'AI-powered messaging with smart replies and nudges',
          ),
          const SizedBox(height: 16),
          _TourFeature(
            icon: Icons.favorite,
            color: kChatSocial,
            title: 'Hey Ya Connections',
            description: 'Find and connect with compatible people',
          ),
          const SizedBox(height: 16),
          const _TourFeature(
            icon: Icons.visibility,
            color: IveTokens.success,
            title: 'Presence Tracking',
            description: "See who's online and available in real-time",
          ),
          const SizedBox(height: 16),
          const _TourFeature(
            icon: Icons.auto_awesome,
            color: IveTokens.genie,
            title: 'AI Wingmate',
            description: 'Smart nudges and suggestions to build connections',
          ),
          const SizedBox(height: 16),
          const _TourFeature(
            icon: Icons.shield,
            color: IveTokens.warning,
            title: 'Privacy First',
            description: 'Full control over your visibility and data',
          ),

          const Spacer(),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: IveTokens.moduleQualChat.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(IveTokens.rSm),
              border: Border.all(color: IveTokens.moduleQualChat.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Text('', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tip: Use the mode toggle on your dashboard to switch between Social  and Professional  modes anytime!',
                    style: IveType.caption.copyWith(color: IveTokens.ink2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TourFeature extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  const _TourFeature({required this.icon, required this.color, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(IveTokens.rSm),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: IveType.bodyEmphasis.copyWith(color: IveTokens.ink)),
              Text(description, style: IveType.caption.copyWith(color: IveTokens.mute)),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 0),
      child: Row(
        children: List.generate(total, (i) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: i <= current ? IveTokens.moduleQualChat : IveTokens.hairline,
                borderRadius: BorderRadius.circular(IveTokens.rXs),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _StepNavigation extends StatelessWidget {
  final int step;
  final VoidCallback? onBack;
  final VoidCallback onNext;
  final bool isLast;
  const _StepNavigation({required this.step, this.onBack, required this.onNext, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (onBack != null)
            IveButton.secondary(
              label: 'Back',
              onPressed: onBack,
              expand: false,
            ),
          if (onBack != null) const SizedBox(width: 12),
          Expanded(
            child: IveButton.primary(
              label: isLast ? 'Get Started' : 'Continue',
              onPressed: onNext,
            ),
          ),
        ],
      ),
    );
  }
}
