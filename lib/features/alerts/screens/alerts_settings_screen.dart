/// Alerts Screen 10 — Settings & Preferences
/// Notification channels, event notifications, quiet hours,
/// workflow rules, escalation paths, assignment rules

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alerts_models.dart';
import '../providers/alerts_provider.dart';
import '../widgets/alerts_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class AlertsSettingsScreen extends StatelessWidget {
  const AlertsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AlertsProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: const AlertsAppBar(title: 'Alert Settings'),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── AI Insights Strip ──────────────
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: kAlertsColor.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      const Icon(Icons.auto_awesome, size: 14, color: kAlertsColor),
                      const SizedBox(width: 8),
                      Expanded(child: Text('AI: ${ai.insights.first['label'] ?? 'Personalized settings suggested'}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kAlertsColor), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                  );
                },
              ),
              // ── Notification Channels ──────────────
              _SectionHeader(title: 'Notification Channels', icon: Icons.notifications_outlined),
              const SizedBox(height: 8),
              AlertsSectionCard(
                child: Column(
                  children: [
                    _ToggleTile(icon: Icons.phone_android, label: 'Push Notifications', subtitle: 'Receive push alerts on this device', settingKey: 'pushNotifications', provider: provider),
                    const Divider(height: 1),
                    _ToggleTile(icon: Icons.email_outlined, label: 'Email Notifications', subtitle: 'Send alert summaries to your email', settingKey: 'emailNotifications', provider: provider),
                    const Divider(height: 1),
                    _ToggleTile(icon: Icons.sms_outlined, label: 'SMS Notifications', subtitle: 'Critical alerts via text message', settingKey: 'smsNotifications', provider: provider),
                    const Divider(height: 1),
                    _ToggleTile(icon: Icons.dashboard_customize_outlined, label: 'In-App Notifications', subtitle: 'Banner and badge notifications', settingKey: 'inAppNotifications', provider: provider),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Event Notifications ──────────────
              _SectionHeader(title: 'Notify Me When…', icon: Icons.event_note_outlined),
              const SizedBox(height: 8),
              AlertsSectionCard(
                child: Column(
                  children: [
                    _ToggleTile(icon: Icons.person_add_alt_1, label: 'Assigned to Me', subtitle: 'An alert is assigned to you', settingKey: 'notifyOnAssign', provider: provider),
                    const Divider(height: 1),
                    _ToggleTile(icon: Icons.trending_up, label: 'Escalated', subtitle: 'An alert is escalated in your chain', settingKey: 'notifyOnEscalate', provider: provider),
                    const Divider(height: 1),
                    _ToggleTile(icon: Icons.check_circle_outline, label: 'Resolved', subtitle: 'An alert you follow is resolved', settingKey: 'notifyOnResolve', provider: provider),
                    const Divider(height: 1),
                    _ToggleTile(icon: Icons.comment_outlined, label: 'New Comment', subtitle: 'Someone comments on your alert', settingKey: 'notifyOnComment', provider: provider),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Quiet Hours ──────────────
              _SectionHeader(title: 'Quiet Hours', icon: Icons.do_not_disturb_on_outlined),
              const SizedBox(height: 8),
              AlertsSectionCard(
                child: Column(
                  children: [
                    _ToggleTile(icon: Icons.bedtime_outlined, label: 'Enable Quiet Hours', subtitle: 'Suppress non-critical alerts', settingKey: 'quietHours', provider: provider),
                    if (provider.getSettingToggle('quietHours')) ...[
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Expanded(
                              child: _TimePicker(label: 'Start', value: provider.quietHoursStart, onChanged: provider.setQuietHoursStart),
                            ),
                            const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Icon(Icons.arrow_forward, size: 18, color: Color(0xFF9CA3AF))),
                            Expanded(
                              child: _TimePicker(label: 'End', value: provider.quietHoursEnd, onChanged: provider.setQuietHoursEnd),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Sound & Haptics ──────────────
              _SectionHeader(title: 'Sound & Haptics', icon: Icons.volume_up_outlined),
              const SizedBox(height: 8),
              AlertsSectionCard(
                child: Column(
                  children: [
                    _ToggleTile(icon: Icons.music_note, label: 'Sound Alerts', subtitle: 'Play sound for incoming alerts', settingKey: 'soundAlerts', provider: provider),
                    const Divider(height: 1),
                    _ToggleTile(icon: Icons.vibration, label: 'Vibration', subtitle: 'Vibrate for critical alerts', settingKey: 'vibration', provider: provider),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Workflow ──────────────
              _SectionHeader(title: 'Workflow Automation', icon: Icons.auto_fix_high),
              const SizedBox(height: 8),
              AlertsSectionCard(
                child: Column(
                  children: [
                    _ToggleTile(icon: Icons.assignment_ind, label: 'Auto-Assign Alerts', subtitle: 'Route alerts using assignment rules', settingKey: 'autoAssign', provider: provider),
                    if (provider.getSettingToggle('autoAssign')) ...[
                      const Divider(height: 1),
                      ...provider.assignmentRules.map((rule) => _AssignmentRuleTile(rule: rule)),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Escalation Paths ──────────────
              _SectionHeader(title: 'Escalation Paths', icon: Icons.trending_up),
              const SizedBox(height: 8),
              AlertsSectionCard(
                child: Column(
                  children: provider.escalationPaths.asMap().entries.map((entry) {
                    final i = entry.key;
                    final path = entry.value;
                    return Column(
                      children: [
                        if (i > 0) const Divider(height: 1),
                        _EscalationTile(path: path, index: i),
                      ],
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // ── Danger Zone ──────────────
              _SectionHeader(title: 'Data', icon: Icons.storage_outlined),
              const SizedBox(height: 8),
              AlertsSectionCard(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.download, color: kAlertsInfo, size: 22),
                      title: const Text('Export Alerts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      subtitle: const Text('Download as CSV or PDF', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                      trailing: const Icon(Icons.chevron_right, size: 20, color: Color(0xFF9CA3AF)),
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Export started…'), backgroundColor: kAlertsInfo),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.delete_sweep, color: kAlertsColor, size: 22),
                      title: const Text('Clear Resolved Alerts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: kAlertsColor)),
                      subtitle: const Text('Remove all resolved alerts older than 30 days', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                      trailing: const Icon(Icons.chevron_right, size: 20, color: Color(0xFF9CA3AF)),
                      onTap: () => _showClearConfirmation(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Old Alerts?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: const Text('This will permanently delete all resolved alerts older than 30 days. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cleared old alerts'), backgroundColor: kAlertsResolved));
            },
            child: const Text('Clear', style: TextStyle(color: kAlertsColor)),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Section Header
// ──────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: kAlertsColor),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Toggle Tile
// ──────────────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final String settingKey;
  final AlertsProvider provider;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.settingKey,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, size: 20, color: const Color(0xFF6B7280)),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
      value: provider.getSettingToggle(settingKey),
      onChanged: (v) => provider.setSettingToggle(settingKey, v),
      activeColor: kAlertsColor,
    );
  }
}

// ──────────────────────────────────────────────
// Time Picker
// ──────────────────────────────────────────────

class _TimePicker extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const _TimePicker({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final parts = value.split(':');
        final initial = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        final picked = await showTimePicker(context: context, initialTime: initial);
        if (picked != null) {
          onChanged('${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 16, color: Color(0xFF9CA3AF)),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w600)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Assignment Rule Tile
// ──────────────────────────────────────────────

class _AssignmentRuleTile extends StatelessWidget {
  final AssignmentRule rule;
  const _AssignmentRuleTile({required this.rule});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: rule.isActive ? kAlertsResolved : const Color(0xFF9CA3AF),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${rule.category.name.toUpperCase()}${rule.priority != null ? ' (${rule.priority!.name})' : ''} → ${rule.assignToRole}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Icon(Icons.toggle_on, size: 24, color: rule.isActive ? kAlertsResolved : const Color(0xFFE5E7EB)),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Escalation Path Tile
// ──────────────────────────────────────────────

class _EscalationTile extends StatelessWidget {
  final EscalationPath path;
  final int index;
  const _EscalationTile({required this.path, required this.index});

  String _levelLabel(EscalationLevel level) {
    switch (level) {
      case EscalationLevel.team: return '🟢 Team Level';
      case EscalationLevel.branch: return '🟡 Branch Level';
      case EscalationLevel.regional: return '🟠 Regional Level';
      case EscalationLevel.executive: return '🔴 Executive Level';
    }
  }

  String _durationLabel(Duration d) {
    if (d.inHours >= 24) return 'after ${d.inDays}d';
    return 'after ${d.inHours}h';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 14,
        backgroundColor: kAlertsColorLight,
        child: Text('${index + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kAlertsColor)),
      ),
      title: Text(_levelLabel(path.level), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle: Text('Escalate to ${path.targetRole} ${_durationLabel(path.afterDuration)}',
        style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
      ),
      trailing: const Icon(Icons.chevron_right, size: 18, color: Color(0xFF9CA3AF)),
    );
  }
}
