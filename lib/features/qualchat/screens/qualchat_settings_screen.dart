/// qualChat Screen 13 — Settings
/// Centralized config: notifications, privacy, media, appearance, accessibility, advanced

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/qualchat_provider.dart';
import '../widgets/qualchat_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class QualChatSettingsScreen extends StatelessWidget {
  const QualChatSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QualChatProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: const QualChatAppBar(title: 'Chat Settings'),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: kChatColor.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kChatColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI: ${ai.insights.first['title'] ?? ''}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kChatColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // ──── NOTIFICATIONS ────
              _SettingsSection(
                icon: Icons.notifications,
                title: 'Notifications',
                emoji: '🔔',
                children: [
                  _SettingsToggle(
                    title: 'Message Notifications',
                    subtitle: 'Get notified for new messages',
                    value: provider.settingsToggles['message_notifications'] ?? true,
                    onChanged: (v) => provider.setSettingToggle('message_notifications', v),
                  ),
                  _SettingsToggle(
                    title: 'Group Notifications',
                    subtitle: 'Receive group chat notifications',
                    value: provider.settingsToggles['group_notifications'] ?? true,
                    onChanged: (v) => provider.setSettingToggle('group_notifications', v),
                  ),
                  _SettingsToggle(
                    title: 'Nudge Notifications',
                    subtitle: 'AI wingmate nudge alerts',
                    value: provider.settingsToggles['nudge_notifications'] ?? true,
                    onChanged: (v) => provider.setSettingToggle('nudge_notifications', v),
                  ),
                  _SettingsToggle(
                    title: 'Hey Ya Alerts',
                    subtitle: 'New match and connection alerts',
                    value: provider.settingsToggles['heya_alerts'] ?? true,
                    onChanged: (v) => provider.setSettingToggle('heya_alerts', v),
                  ),
                  _SettingsToggle(
                    title: 'Sound',
                    subtitle: 'Play sound for notifications',
                    value: provider.settingsToggles['sound'] ?? true,
                    onChanged: (v) => provider.setSettingToggle('sound', v),
                  ),
                  _SettingsToggle(
                    title: 'Vibration',
                    subtitle: 'Vibrate on notification',
                    value: provider.settingsToggles['vibration'] ?? true,
                    onChanged: (v) => provider.setSettingToggle('vibration', v),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ──── PRIVACY ────
              _SettingsSection(
                icon: Icons.shield,
                title: 'Privacy',
                emoji: '🔒',
                children: [
                  _SettingsToggle(
                    title: 'Read Receipts',
                    subtitle: 'Show when you\'ve read messages',
                    value: provider.settingsToggles['read_receipts'] ?? true,
                    onChanged: (v) => provider.setSettingToggle('read_receipts', v),
                  ),
                  _SettingsToggle(
                    title: 'Typing Indicator',
                    subtitle: 'Show when you\'re typing',
                    value: provider.settingsToggles['typing_indicator'] ?? true,
                    onChanged: (v) => provider.setSettingToggle('typing_indicator', v),
                  ),
                  _SettingsToggle(
                    title: 'Online Status',
                    subtitle: 'Show your online presence',
                    value: provider.settingsToggles['online_status'] ?? true,
                    onChanged: (v) => provider.setSettingToggle('online_status', v),
                  ),
                  _SettingsToggle(
                    title: 'Last Seen',
                    subtitle: 'Show when you were last active',
                    value: provider.settingsToggles['last_seen'] ?? true,
                    onChanged: (v) => provider.setSettingToggle('last_seen', v),
                  ),
                  _SettingsToggle(
                    title: 'Profile Photo Privacy',
                    subtitle: 'Control who sees your photo',
                    value: provider.settingsToggles['profile_photo_privacy'] ?? false,
                    onChanged: (v) => provider.setSettingToggle('profile_photo_privacy', v),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ──── MEDIA ────
              _SettingsSection(
                icon: Icons.photo_library,
                title: 'Media & Storage',
                emoji: '📸',
                children: [
                  _SettingsToggle(
                    title: 'Auto-download Media',
                    subtitle: 'Automatically download photos and files',
                    value: provider.settingsToggles['auto_download'] ?? true,
                    onChanged: (v) => provider.setSettingToggle('auto_download', v),
                  ),
                  _SettingsToggle(
                    title: 'Save to Gallery',
                    subtitle: 'Auto-save received media to gallery',
                    value: provider.settingsToggles['save_gallery'] ?? false,
                    onChanged: (v) => provider.setSettingToggle('save_gallery', v),
                  ),
                  _SettingsToggle(
                    title: 'Data Saver',
                    subtitle: 'Reduce data usage for media',
                    value: provider.settingsToggles['data_saver'] ?? false,
                    onChanged: (v) => provider.setSettingToggle('data_saver', v),
                  ),
                  _SettingsAction(
                    title: 'Clear Cache',
                    subtitle: 'Free up storage space',
                    icon: Icons.cleaning_services,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cache cleared successfully')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ──── APPEARANCE ────
              _SettingsSection(
                icon: Icons.palette,
                title: 'Appearance',
                emoji: '🎨',
                children: [
                  // Font size
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Font Size', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        SegmentedButton<int>(
                          segments: const [
                            ButtonSegment(value: 0, label: Text('S', style: TextStyle(fontSize: 12))),
                            ButtonSegment(value: 1, label: Text('M', style: TextStyle(fontSize: 14))),
                            ButtonSegment(value: 2, label: Text('L', style: TextStyle(fontSize: 16))),
                          ],
                          selected: {provider.fontSizeIndex},
                          onSelectionChanged: (v) => provider.setFontSizeIndex(v.first),
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.selected)) return kChatColor;
                              return null;
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Chat theme
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Chat Theme', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(4, (i) {
                            final colors = [kChatColor, const Color(0xFF8B5CF6), const Color(0xFFEC4899), const Color(0xFF10B981)];
                            final labels = ['Cyan', 'Purple', 'Pink', 'Green'];
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => provider.setThemeIndex(i),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: colors[i].withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: provider.themeIndex == i
                                        ? Border.all(color: colors[i], width: 2)
                                        : null,
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 24, height: 24,
                                        decoration: BoxDecoration(color: colors[i], shape: BoxShape.circle),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(labels[i], style: TextStyle(fontSize: 10, color: colors[i])),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  // Bubble style
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bubble Style', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        SegmentedButton<int>(
                          segments: const [
                            ButtonSegment(value: 0, label: Text('Modern')),
                            ButtonSegment(value: 1, label: Text('Classic')),
                            ButtonSegment(value: 2, label: Text('Minimal')),
                          ],
                          selected: {provider.bubbleStyleIndex},
                          onSelectionChanged: (v) => provider.setBubbleStyleIndex(v.first),
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.selected)) return kChatColor;
                              return null;
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ──── ACCESSIBILITY ────
              _SettingsSection(
                icon: Icons.accessibility,
                title: 'Accessibility',
                emoji: '♿',
                children: [
                  _SettingsToggle(
                    title: 'High Contrast',
                    subtitle: 'Increase contrast for readability',
                    value: provider.settingsToggles['high_contrast'] ?? false,
                    onChanged: (v) => provider.setSettingToggle('high_contrast', v),
                  ),
                  _SettingsToggle(
                    title: 'Reduce Motion',
                    subtitle: 'Minimize animations',
                    value: provider.settingsToggles['reduce_motion'] ?? false,
                    onChanged: (v) => provider.setSettingToggle('reduce_motion', v),
                  ),
                  _SettingsToggle(
                    title: 'Screen Reader',
                    subtitle: 'Optimize for screen readers',
                    value: provider.settingsToggles['screen_reader'] ?? false,
                    onChanged: (v) => provider.setSettingToggle('screen_reader', v),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ──── ADVANCED ────
              _SettingsSection(
                icon: Icons.settings,
                title: 'Advanced',
                emoji: '⚙️',
                children: [
                  _SettingsAction(
                    title: 'Export Chat History',
                    subtitle: 'Download all your conversations',
                    icon: Icons.download,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Export started...')),
                      );
                    },
                  ),
                  _SettingsAction(
                    title: 'Reset Settings',
                    subtitle: 'Restore all settings to default',
                    icon: Icons.restore,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Reset Settings?'),
                          content: const Text('This will restore all chat settings to their defaults.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Reset', style: TextStyle(color: Color(0xFFEF4444))),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  _SettingsAction(
                    title: 'Delete All Chats',
                    subtitle: 'Permanently delete all conversations',
                    icon: Icons.delete_forever,
                    color: const Color(0xFFEF4444),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete All Chats?'),
                          content: const Text('This action cannot be undone. All conversations will be permanently deleted.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Delete All', style: TextStyle(color: Color(0xFFEF4444))),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String emoji;
  final List<Widget> children;
  const _SettingsSection({required this.icon, required this.title, required this.emoji, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
                ),
              ],
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SettingsToggle({required this.title, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
      value: value,
      onChanged: onChanged,
      activeColor: kChatColor,
    );
  }
}

class _SettingsAction extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;
  const _SettingsAction({required this.title, required this.subtitle, required this.icon, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? kChatColor),
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Color(0xFF9CA3AF)),
      onTap: onTap,
    );
  }
}
