/// qualChat Screen 4  My Preferences (Owner Only)
/// Intelligent Preference System: Vibe settings, discovery, privacy
library;

import 'package:flutter/material.dart';
import '../../../core/design/ive.dart';
import '../../../core/utils/app_toast.dart';
import 'package:provider/provider.dart';
import '../models/qualchat_models.dart';
import '../providers/qualchat_provider.dart';
import '../widgets/qualchat_widgets.dart';
import '../../../core/routes/app_routes.dart';

class QualChatPreferencesScreen extends StatelessWidget {
  const QualChatPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QualChatProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: QualChatAppBar(
            title: 'My Vibe Settings ',
            actions: [
              TextButton(
                onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(
                  title: const Text('Reset Vibe Settings?'),
                  content: const Text('This will reset all your vibe preferences to defaults.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    ElevatedButton(onPressed: () { Navigator.pop(context); AppToast.show(context, 'Settings reset to defaults'); }, child: const Text('Reset')),
                  ],
                )),
                child: const Text('Reset', style: TextStyle(color: Color(0xFFEF4444))),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Core Status
                QualChatSectionCard(
                  title: 'Core Status',
                  child: Column(
                    children: [
                      _ToggleRow(
                        emoji: '',
                        label: 'Open to new connections',
                        subtitle: provider.isOpenToConnections ? 'Active - Sparkling!' : 'Paused',
                        value: provider.isOpenToConnections,
                        onChanged: (_) => provider.toggleOpenToConnections(),
                      ),
                      const Divider(height: 24),
                      _ToggleRow(
                        emoji: '',
                        label: 'Incognito Mode',
                        subtitle: provider.incognitoMode ? 'Your profile is hidden' : 'Your profile is visible',
                        value: provider.incognitoMode,
                        onChanged: (_) => provider.toggleIncognito(),
                      ),
                    ],
                  ),
                ),

                // Discovery Settings
                QualChatSectionCard(
                  title: 'Discovery Settings',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Age Range
                      Row(
                        children: [
                          const Text('Age: ', style: TextStyle(fontSize: 14, color: Color(0xFF1A1A1A))),
                          Text(
                            '${provider.ageRange.start.toInt()} - ${provider.ageRange.end.toInt()}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: IveTokens.moduleQualChat),
                          ),
                        ],
                      ),
                      RangeSlider(
                        values: provider.ageRange,
                        min: 18,
                        max: 60,
                        divisions: 42,
                        activeColor: kChatSocial,
                        onChanged: provider.setAgeRange,
                      ),
                      const SizedBox(height: 8),

                      // Distance
                      Row(
                        children: [
                          const Text('Distance: ', style: TextStyle(fontSize: 14, color: Color(0xFF1A1A1A))),
                          Text(
                            '${provider.distanceKm.toInt()}km',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: IveTokens.moduleQualChat),
                          ),
                        ],
                      ),
                      Slider(
                        value: provider.distanceKm,
                        min: 1,
                        max: 100,
                        divisions: 99,
                        activeColor: kChatSocial,
                        onChanged: provider.setDistanceKm,
                      ),
                      const SizedBox(height: 8),
                      const Text('Gender: All',
                          style: TextStyle(fontSize: 14, color: Color(0xFF1A1A1A))),
                    ],
                  ),
                ),

                // Vibe Tags
                QualChatSectionCard(
                  title: 'Vibe Tags (Select up to 5)',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: VibeTag.values.map((tag) {
                      final isSelected = provider.selectedVibeTags.contains(tag);
                      return GestureDetector(
                        onTap: () => provider.toggleVibeTag(tag),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? kChatSocial : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(10),
                            border: isSelected ? null : Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Text(
                            '${_tagEmoji(tag)} ${tag.name[0].toUpperCase()}${tag.name.substring(1)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Compatibility Weighting
                QualChatSectionCard(
                  title: 'Compatibility Weighting',
                  child: Column(
                    children: QualChatProvider.compatibilityWeights.map((w) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(w.label, style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A))),
                                Text('${w.percent.toInt()}%',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: IveTokens.moduleQualChat)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: w.percent / 100,
                                backgroundColor: const Color(0xFFE5E7EB),
                                color: kChatSocial,
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Privacy Shield
                QualChatSectionCard(
                  title: 'Privacy Shield',
                  child: Column(
                    children: provider.privacyToggles.entries.map((e) {
                      return _ToggleRow(
                        emoji: '',
                        label: e.key,
                        value: e.value,
                        onChanged: (v) => provider.setPrivacyToggle(e.key, v),
                      );
                    }).toList(),
                  ),
                ),

                // Data Controls
                QualChatSectionCard(
                  title: 'Data Controls',
                  child: Row(
                    children: [
                      _DataButton(label: 'Clear History', icon: Icons.delete_outline, onTap: () => showDialog(context: context, builder: (_) => AlertDialog(
                        title: const Text('Clear Chat History?'),
                        content: const Text('This will permanently delete your QualChat history.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          ElevatedButton(onPressed: () { Navigator.pop(context); AppToast.show(context, 'History cleared'); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)), child: const Text('Clear')),
                        ],
                      ))),
                      const SizedBox(width: 8),
                      _DataButton(label: 'Export Data', icon: Icons.download, onTap: () => AppToast.show(context, 'Exporting your data...')),
                      const SizedBox(width: 8),
                      _DataButton(label: 'Delete Account', icon: Icons.warning_amber, onTap: () => showDialog(context: context, builder: (_) => AlertDialog(
                        title: const Text('Delete Account?'),
                        content: const Text('This will permanently delete your QualChat account and all data. This cannot be undone.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          ElevatedButton(onPressed: () { Navigator.pop(context); AppToast.show(context, 'Account deletion requested'); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)), child: const Text('Delete')),
                        ],
                      )), isDestructive: true),
                    ],
                  ),
                ),

                // AI Recommendations
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [IveTokens.moduleQualChat.withValues(alpha: 0.1), kChatSocial.withValues(alpha: 0.1)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: IveTokens.moduleQualChat.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Based on your activity, we recommend:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                      ),
                      const SizedBox(height: 8),
                      const _RecommendationItem(text: 'Add "Travel" tag (you often discuss locations)'),
                      const _RecommendationItem(text: 'Increase age range to 40 (higher response rate)'),
                      const _RecommendationItem(text: 'Try incognito mode during work hours'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => AppToast.show(context, 'AI suggestions applied'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: IveTokens.moduleQualChat,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Apply Suggestions'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.utilityHelp),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: IveTokens.moduleQualChat,
                              side: const BorderSide(color: IveTokens.moduleQualChat),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Learn More'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  String _tagEmoji(VibeTag tag) {
    switch (tag) {
      case VibeTag.adventurous: return '';
      case VibeTag.creative: return '';
      case VibeTag.nerdy: return '"';
      case VibeTag.foodie: return '';
      case VibeTag.musical: return '';
      case VibeTag.pets: return '';
      case VibeTag.travel: return '';
      case VibeTag.gaming: return '';
      case VibeTag.calm: return '';
    }
  }
}

class _ToggleRow extends StatelessWidget {
  final String emoji;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.emoji,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          if (emoji.isNotEmpty) ...[
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A))),
                if (subtitle != null)
                  Text(subtitle!, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: IveTokens.moduleQualChat,
          ),
        ],
      ),
    );
  }
}

class _DataButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DataButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 14),
        label: Text(label, style: const TextStyle(fontSize: 11)),
        style: OutlinedButton.styleFrom(
          foregroundColor: isDestructive ? const Color(0xFFEF4444) : const Color(0xFF6B7280),
          side: BorderSide(
            color: isDestructive ? const Color(0xFFEF4444).withValues(alpha: 0.3) : const Color(0xFFE5E7EB),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        ),
      ),
    );
  }
}

class _RecommendationItem extends StatelessWidget {
  final String text;
  const _RecommendationItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Text('  ', style: TextStyle(color: IveTokens.moduleQualChat)),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          ),
        ],
      ),
    );
  }
}
