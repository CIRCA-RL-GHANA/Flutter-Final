/// qualChat Screen 14 — Onboarding Flow
/// 4-step flow: Welcome & Permissions → Role Config → Profile Setup → Quick Tour

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/qualchat_models.dart';
import '../providers/qualchat_provider.dart';
import '../widgets/qualchat_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class QualChatOnboardingScreen extends StatelessWidget {
  const QualChatOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QualChatProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                Consumer<AIInsightsNotifier>(
                  builder: (context, ai, _) {
                    if (ai.insights.isEmpty) return const SizedBox.shrink();
                    return Container(
                      color: const Color(0xFF06B6D4).withOpacity(0.07),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Row(children: [
                        const Icon(Icons.auto_awesome, size: 14, color: Color(0xFF06B6D4)),
                        const SizedBox(width: 8),
                        Expanded(child: Text('AI: ${ai.insights.first['title'] ?? ''}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF06B6D4)),
                          maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ]),
                    );
                  },
                ),
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
        return _WelcomeStep(key: const ValueKey(0));
      case 1:
        return _RoleConfigStep(key: const ValueKey(1), provider: provider);
      case 2:
        return _ProfileSetupStep(key: const ValueKey(2), provider: provider);
      case 3:
        return _QuickTourStep(key: const ValueKey(3));
      default:
        return const SizedBox.shrink();
    }
  }
}

// ──── Step 0: Welcome & Permissions ────
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
              gradient: LinearGradient(
                colors: [kChatColor.withOpacity(0.1), kChatColorLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble, size: 56, color: kChatColor),
          ),
          const SizedBox(height: 32),
          const Text(
            'Welcome to qualChat! 💬',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Your intelligent communications hub.\nConnect, chat, and build meaningful relationships.',
            style: TextStyle(fontSize: 15, color: Color(0xFF6B7280), height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Permissions
          _PermissionItem(
            icon: Icons.notifications,
            title: 'Notifications',
            description: 'Stay updated with new messages',
            granted: true,
          ),
          const SizedBox(height: 12),
          _PermissionItem(
            icon: Icons.contacts,
            title: 'Contacts',
            description: 'Find friends and connections',
            granted: false,
          ),
          const SizedBox(height: 12),
          _PermissionItem(
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
        color: granted ? const Color(0xFFECFDF5) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: granted ? const Color(0xFF10B981).withOpacity(0.3) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: granted ? const Color(0xFF10B981) : const Color(0xFF6B7280)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                Text(description, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          if (granted)
            const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 24)
          else
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kChatColor),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Grant', style: TextStyle(fontSize: 12, color: kChatColor)),
            ),
        ],
      ),
    );
  }
}

// ──── Step 1: Role Configuration ────
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
          const Text(
            'How will you use qualChat? 🎯',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 8),
          const Text(
            'This helps us personalize your experience',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 32),

          ...ChatUsageType.values.map((type) {
            final isSelected = provider.selectedUsageType == type;
            final configs = {
              ChatUsageType.socialDating: {'emoji': '💖', 'title': 'Social & Dating', 'desc': 'Connect with new people, find matches, build relationships'},
              ChatUsageType.professionalNetworking: {'emoji': '💼', 'title': 'Professional Networking', 'desc': 'Business communication, networking'},
              ChatUsageType.teamCommunications: {'emoji': '👥', 'title': 'Team Communications', 'desc': 'Team collaboration and group messaging'},
              ChatUsageType.driverConnections: {'emoji': '🚗', 'title': 'Driver Connections', 'desc': 'Connect with drivers and coordinate rides'},
              ChatUsageType.monitoring: {'emoji': '📊', 'title': 'Monitoring', 'desc': 'Monitor and manage communications'},
            };
            final config = configs[type]!;

            return GestureDetector(
              onTap: () => provider.setUsageType(type),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected ? kChatColor.withOpacity(0.08) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? kChatColor : const Color(0xFFE5E7EB),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: kChatColor.withOpacity(0.1), blurRadius: 12)]
                      : null,
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
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? kChatColorDark : const Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            config['desc']!,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle, color: kChatColor, size: 28),
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

// ──── Step 2: Profile Setup ────
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
          const Text(
            'Set up your profile ✨',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Make a great first impression',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
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
                    color: kChatColor.withOpacity(0.1),
                    border: Border.all(color: kChatColor, width: 3),
                  ),
                  child: const Icon(Icons.person, size: 48, color: kChatColor),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: kChatColor,
                    ),
                    child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
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
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              prefixIcon: const Icon(Icons.person_outline, color: kChatColor),
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
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              prefixIcon: const Icon(Icons.edit_note, color: kChatColor),
            ),
          ),
          const SizedBox(height: 16),

          // Vibe tags
          const Text(
            'Select your vibes 🎵',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: VibeTag.values.map((tag) {
              final isSelected = provider.selectedVibeTags.contains(tag);
              final tagEmojis = {
                VibeTag.adventurous: '🏔️',
                VibeTag.creative: '🎨',
                VibeTag.nerdy: '🤓',
                VibeTag.foodie: '🍕',
                VibeTag.musical: '🎵',
                VibeTag.pets: '🐾',
                VibeTag.travel: '✈️',
                VibeTag.gaming: '🎮',
                VibeTag.calm: '😌',
              };
              return GestureDetector(
                onTap: () => provider.toggleVibeTag(tag),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? kChatColor : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? kChatColor : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(
                    '${tagEmojis[tag] ?? ''} ${tag.name}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF374151),
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
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kChatColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: kChatColor.withOpacity(0.7)),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Your profile is only visible to people you choose. You can change these settings anytime.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF374151)),
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

// ──── Step 3: Quick Tour ────
class _QuickTourStep extends StatelessWidget {
  const _QuickTourStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Text(
            'You\'re all set! 🎉',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Here\'s what you can do with qualChat',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          _TourFeature(
            icon: Icons.chat_bubble,
            color: kChatColor,
            title: 'Smart Chat',
            description: 'AI-powered messaging with smart replies and nudges',
          ),
          const SizedBox(height: 16),
          _TourFeature(
            icon: Icons.favorite,
            color: const Color(0xFFEC4899),
            title: 'Hey Ya Connections',
            description: 'Find and connect with compatible people',
          ),
          const SizedBox(height: 16),
          _TourFeature(
            icon: Icons.visibility,
            color: const Color(0xFF10B981),
            title: 'Presence Tracking',
            description: 'See who\'s online and available in real-time',
          ),
          const SizedBox(height: 16),
          _TourFeature(
            icon: Icons.auto_awesome,
            color: const Color(0xFF8B5CF6),
            title: 'AI Wingmate',
            description: 'Smart nudges and suggestions to build connections',
          ),
          const SizedBox(height: 16),
          _TourFeature(
            icon: Icons.shield,
            color: const Color(0xFFF59E0B),
            title: 'Privacy First',
            description: 'Full control over your visibility and data',
          ),

          const Spacer(),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kChatColor.withOpacity(0.08), kChatColorLight],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Text('💡', style: TextStyle(fontSize: 24)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tip: Use the mode toggle on your dashboard to switch between Social 💖 and Professional 💼 modes anytime!',
                    style: TextStyle(fontSize: 13, color: Color(0xFF374151)),
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
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              Text(description, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
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
                color: i <= current ? kChatColor : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
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
            OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kChatColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              child: const Text('Back', style: TextStyle(color: kChatColor, fontWeight: FontWeight.w600)),
            ),
          if (onBack != null) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: kChatColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                isLast ? 'Get Started 🚀' : 'Continue',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
