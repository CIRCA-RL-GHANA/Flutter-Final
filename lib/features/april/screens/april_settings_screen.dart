/// APRIL Screen 6 — APRIL Settings
/// 7 sections: General, Voice, Plugins, Notifications, Privacy, Advanced, Help

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/april_provider.dart';
import '../widgets/april_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class AprilSettingsScreen extends StatelessWidget {
  const AprilSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AprilProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: const AprilAppBar(title: '⚙️ APRIL Settings'),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ──── AI SETTINGS SUGGESTION ────
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007AFF).withOpacity(0.07),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      const Icon(Icons.auto_awesome, size: 14, color: Color(0xFF007AFF)),
                      const SizedBox(width: 8),
                      Expanded(child: Text('AI: ${ai.insights.first['label'] ?? 'Personalized settings suggested'}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF007AFF)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                  );
                },
              ),
              // ──── GENERAL ────
              _SettingsSection(
                title: '🏠 General',
                children: [
                  _SettingsToggle(
                    label: 'Dark Mode',
                    subtitle: 'Switch to dark theme',
                    icon: Icons.dark_mode,
                    value: provider.getSettingToggle('darkMode'),
                    onChanged: (v) => provider.setSettingToggle('darkMode', v),
                  ),
                  _ThemeSelector(
                    themeIndex: provider.themeIndex,
                    onChanged: provider.setThemeIndex,
                  ),
                  _SettingsToggle(
                    label: 'Compact Mode',
                    subtitle: 'Reduce spacing and element sizes',
                    icon: Icons.view_compact,
                    value: provider.getSettingToggle('compactMode'),
                    onChanged: (v) => provider.setSettingToggle('compactMode', v),
                  ),
                  _SettingsTile(
                    label: 'Language',
                    subtitle: 'English (Default)',
                    icon: Icons.language,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ──── VOICE ────
              _SettingsSection(
                title: '🎤 Voice',
                children: [
                  _SettingsToggle(
                    label: 'Voice Activation',
                    subtitle: 'Enable "Hey APRIL" wake word',
                    icon: Icons.mic,
                    value: provider.getSettingToggle('voiceActivation'),
                    onChanged: (v) => provider.setSettingToggle('voiceActivation', v),
                  ),
                  _SettingsToggle(
                    label: 'Voice Feedback',
                    subtitle: 'Haptic & audio confirmation',
                    icon: Icons.vibration,
                    value: provider.getSettingToggle('voiceFeedback'),
                    onChanged: (v) => provider.setSettingToggle('voiceFeedback', v),
                  ),
                  _SettingsToggle(
                    label: 'Continuous Listening',
                    subtitle: 'Keep mic active after command',
                    icon: Icons.hearing,
                    value: provider.getSettingToggle('continuousListening'),
                    onChanged: (v) => provider.setSettingToggle('continuousListening', v),
                  ),
                  _SettingsTile(
                    label: 'Voice Training',
                    subtitle: 'Improve recognition accuracy',
                    icon: Icons.record_voice_over,
                    onTap: () {},
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('New', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF3B82F6))),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ──── PLUGINS ────
              _SettingsSection(
                title: '📦 Plugins',
                children: [
                  _SettingsToggle(
                    label: 'Planner Plugin',
                    subtitle: 'Financial tracking & budgets',
                    icon: Icons.account_balance_wallet,
                    value: provider.getSettingToggle('plannerPlugin'),
                    onChanged: (v) => provider.setSettingToggle('plannerPlugin', v),
                  ),
                  _SettingsToggle(
                    label: 'Calendar Plugin',
                    subtitle: 'Event scheduling & reminders',
                    icon: Icons.calendar_month,
                    value: provider.getSettingToggle('calendarPlugin'),
                    onChanged: (v) => provider.setSettingToggle('calendarPlugin', v),
                  ),
                  _SettingsToggle(
                    label: 'Wishlist Plugin',
                    subtitle: 'Item tracking & savings',
                    icon: Icons.favorite,
                    value: provider.getSettingToggle('wishlistPlugin'),
                    onChanged: (v) => provider.setSettingToggle('wishlistPlugin', v),
                  ),
                  _SettingsToggle(
                    label: 'Statement Plugin',
                    subtitle: 'Personal documentation',
                    icon: Icons.description,
                    value: provider.getSettingToggle('statementPlugin'),
                    onChanged: (v) => provider.setSettingToggle('statementPlugin', v),
                  ),
                  _SettingsTile(
                    label: 'Sync All Plugins',
                    subtitle: 'Force sync all plugin data',
                    icon: Icons.sync,
                    onTap: provider.refreshSync,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ──── NOTIFICATIONS ────
              _SettingsSection(
                title: '🔔 Notifications',
                children: [
                  _SettingsToggle(
                    label: 'Push Notifications',
                    subtitle: 'Receive alerts and reminders',
                    icon: Icons.notifications,
                    value: provider.getSettingToggle('pushNotifications'),
                    onChanged: (v) => provider.setSettingToggle('pushNotifications', v),
                  ),
                  _SettingsToggle(
                    label: 'Financial Alerts',
                    subtitle: 'Budget warnings & bill reminders',
                    icon: Icons.account_balance,
                    value: provider.getSettingToggle('financialAlerts'),
                    onChanged: (v) => provider.setSettingToggle('financialAlerts', v),
                  ),
                  _SettingsToggle(
                    label: 'Calendar Reminders',
                    subtitle: 'Event notifications',
                    icon: Icons.event,
                    value: provider.getSettingToggle('calendarReminders'),
                    onChanged: (v) => provider.setSettingToggle('calendarReminders', v),
                  ),
                  _SettingsToggle(
                    label: 'Wishlist Price Drops',
                    subtitle: 'Alert when prices change',
                    icon: Icons.price_change,
                    value: provider.getSettingToggle('wishlistPriceDrops'),
                    onChanged: (v) => provider.setSettingToggle('wishlistPriceDrops', v),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ──── PRIVACY ────
              _SettingsSection(
                title: '🔒 Privacy & Security',
                children: [
                  _SettingsToggle(
                    label: 'Biometric Lock',
                    subtitle: 'Require fingerprint/face to open',
                    icon: Icons.fingerprint,
                    value: provider.getSettingToggle('biometricLock'),
                    onChanged: (v) => provider.setSettingToggle('biometricLock', v),
                  ),
                  _SettingsTile(
                    label: 'Auto-Lock',
                    subtitle: 'After ${provider.autoLockMinutes} minutes',
                    icon: Icons.lock_clock,
                    onTap: () => _showAutoLockPicker(context, provider),
                  ),
                  _SettingsToggle(
                    label: 'Two-Factor Auth',
                    subtitle: 'Extra security layer',
                    icon: Icons.security,
                    value: provider.getSettingToggle('twoFactorAuth'),
                    onChanged: (v) => provider.setSettingToggle('twoFactorAuth', v),
                  ),
                  _SettingsTile(
                    label: 'Data Encryption',
                    subtitle: 'AES-256 enabled',
                    icon: Icons.enhanced_encryption,
                    onTap: () {},
                    trailing: const Icon(Icons.check_circle, size: 18, color: Color(0xFF10B981)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ──── ADVANCED ────
              _SettingsSection(
                title: '🔧 Advanced',
                children: [
                  _SettingsTile(
                    label: 'Backup Frequency',
                    subtitle: provider.backupFrequency,
                    icon: Icons.backup,
                    onTap: () => _showBackupPicker(context, provider),
                  ),
                  _SettingsTile(
                    label: 'Export Data',
                    subtitle: 'Download all your data',
                    icon: Icons.download,
                    onTap: () {},
                  ),
                  _SettingsTile(
                    label: 'Clear Cache',
                    subtitle: 'Free up storage space',
                    icon: Icons.cleaning_services,
                    onTap: () {},
                  ),
                  _SettingsTile(
                    label: 'Reset APRIL',
                    subtitle: 'Reset to factory defaults',
                    icon: Icons.restart_alt,
                    onTap: () {},
                    isDestructive: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ──── HELP ────
              _SettingsSection(
                title: '❓ Help & Support',
                children: [
                  _SettingsTile(label: 'Getting Started', subtitle: 'Learn how to use APRIL', icon: Icons.school, onTap: () {}),
                  _SettingsTile(label: 'FAQs', subtitle: 'Common questions answered', icon: Icons.quiz, onTap: () {}),
                  _SettingsTile(label: 'Contact Support', subtitle: 'Get help from our team', icon: Icons.support_agent, onTap: () {}),
                  _SettingsTile(label: 'Report Bug', subtitle: 'Help us improve', icon: Icons.bug_report, onTap: () {}),
                ],
              ),
              const SizedBox(height: 16),

              // Version Info
              Center(
                child: Column(
                  children: [
                    const Text('APRIL v2.1.0', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
                    const SizedBox(height: 2),
                    Text('Build 2024.01.15', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  void _showAutoLockPicker(BuildContext context, AprilProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('Auto-Lock Timer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...[1, 5, 10, 15, 30].map((m) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('$m minute${m > 1 ? 's' : ''}'),
              trailing: provider.autoLockMinutes == m ? const Icon(Icons.check, color: kAprilColorDark) : null,
              onTap: () {
                provider.setAutoLockMinutes(m);
                Navigator.pop(ctx);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showBackupPicker(BuildContext context, AprilProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('Backup Frequency', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...['Daily', 'Weekly', 'Monthly', 'Manual'].map((f) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(f),
              trailing: provider.backupFrequency == f ? const Icon(Icons.check, color: kAprilColorDark) : null,
              onTap: () {
                provider.setBackupFrequency(f);
                Navigator.pop(ctx);
              },
            )),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// SHARED SETTINGS WIDGETS
// ═══════════════════════════════════════════

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              final isLast = entry.key == children.length - 1;
              return Column(
                children: [
                  entry.value,
                  if (!isLast) const Divider(height: 1, indent: 56),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  final String label, subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SettingsToggle({required this.label, required this.subtitle, required this.icon, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: kAprilColorDark, size: 22),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: kAprilColor,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String label, subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool isDestructive;
  const _SettingsTile({required this.label, required this.subtitle, required this.icon, required this.onTap, this.trailing, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? const Color(0xFFEF4444) : kAprilColorDark, size: 22),
      title: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDestructive ? const Color(0xFFEF4444) : null)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
      onTap: onTap,
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final int themeIndex;
  final ValueChanged<int> onChanged;
  const _ThemeSelector({required this.themeIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final themes = [
      {'name': 'Gold', 'color': kAprilColor},
      {'name': 'Blue', 'color': const Color(0xFF3B82F6)},
      {'name': 'Purple', 'color': const Color(0xFF7C3AED)},
      {'name': 'Green', 'color': const Color(0xFF10B981)},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.palette, color: kAprilColorDark, size: 22),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Theme Color', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                Text('Choose accent color', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          Row(
            children: themes.asMap().entries.map((entry) {
              final i = entry.key;
              final theme = entry.value;
              return GestureDetector(
                onTap: () => onChanged(i),
                child: Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(left: 6),
                  decoration: BoxDecoration(
                    color: theme['color'] as Color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: themeIndex == i ? Colors.black : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: themeIndex == i
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
