/// ═══════════════════════════════════════════════════════════════════════════
/// Screen 7: Notification Orchestrator
/// Mode presets, per-module matrix, smart rules, quiet hours
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../models/user_details_models.dart';
import '../providers/user_details_provider.dart';
import '../widgets/shared_widgets.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDetailsProvider>(
      builder: (context, udp, _) {
        final notif = udp.notifications;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FC),
          appBar: const ModuleHeader(
            title: 'Notifications',
            contextColor: Color(0xFFF59E0B),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: AppColors.primary.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI: ${ai.insights.first['title'] ?? ''}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.primary),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // ─── Master Toggle ─────────────────────────────
              SectionCard(
                child: SettingsToggle(
                  icon: Icons.notifications,
                  label: 'Push Notifications',
                  subtitle: notif.globalEnabled ? 'All notifications enabled' : 'All notifications paused',
                  value: notif.globalEnabled,
                  onChanged: (v) => udp.toggleGlobalNotifications(v),
                  activeColor: const Color(0xFFF59E0B),
                ),
              ),

              if (notif.globalEnabled) ...[
                // ─── Mode Presets ──────────────────────────────
                const SizedBox(height: 8),
                const Text('Notification Mode', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 88,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: NotificationMode.values.map((mode) {
                      final active = notif.activeMode == mode;
                      return _ModeCard(
                        mode: mode,
                        active: active,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          udp.setNotificationMode(mode);
                        },
                      );
                    }).toList(),
                  ),
                ),

                // ─── Per-Module Matrix ─────────────────────────
                const SizedBox(height: 16),
                SectionCard(
                  child: CollapsibleSection(
                    title: 'Per-Module Settings',
                    icon: Icons.grid_view,
                    iconColor: const Color(0xFFF59E0B),
                    child: Column(
                      children: notif.moduleConfigs.entries.map((entry) => _ModuleNotifRow(
                            moduleName: entry.key,
                            config: entry.value,
                            onToggle: (enabled) => udp.toggleModuleNotification(entry.key, enabled),
                          )).toList(),
                    ),
                  ),
                ),

                // ─── Quiet Hours ───────────────────────────────
                SectionCard(
                  child: Column(
                    children: [
                      SettingsToggle(
                        icon: Icons.bedtime,
                        label: 'Quiet Hours',
                        subtitle: '${_formatTime(notif.quietHoursStart)} - ${_formatTime(notif.quietHoursEnd)}',
                        value: notif.quietHoursEnabled,
                        onChanged: (v) => udp.toggleQuietHours(v),
                        activeColor: const Color(0xFF8B5CF6),
                      ),
                      if (notif.quietHoursEnabled) ...[
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: _TimePickerButton(
                                  label: 'Start',
                                  time: notif.quietHoursStart,
                                  onTap: () => _pickTime(context, notif.quietHoursStart, true),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(Icons.arrow_forward, size: 16, color: AppColors.textTertiary),
                              ),
                              Expanded(
                                child: _TimePickerButton(
                                  label: 'End',
                                  time: notif.quietHoursEnd,
                                  onTap: () => _pickTime(context, notif.quietHoursEnd, false),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ─── Smart Rules ───────────────────────────────
                SectionCard(
                  child: CollapsibleSection(
                    title: 'Smart Rules',
                    icon: Icons.auto_awesome,
                    iconColor: const Color(0xFF06B6D4),
                    initiallyExpanded: false,
                    child: Column(
                      children: [
                        ...notif.smartRules.map((rule) => _SmartRuleCard(
                              rule: rule,
                              onToggle: (enabled) => udp.toggleSmartRule(rule.id, enabled),
                            )),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Rule'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF06B6D4),
                              side: const BorderSide(color: Color(0xFF06B6D4)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Preview ───────────────────────────────────
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.preview, size: 18, color: Color(0xFF3B82F6)),
                          SizedBox(width: 8),
                          Text('Notification Preview', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _NotificationPreview(mode: notif.activeMode),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  void _pickTime(BuildContext context, TimeOfDay initial, bool isStart) async {
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      // Would update via provider
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Mode Card
// ═══════════════════════════════════════════════════════════════════════════

class _ModeCard extends StatelessWidget {
  final NotificationMode mode;
  final bool active;
  final VoidCallback onTap;
  const _ModeCard({required this.mode, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFF59E0B).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? const Color(0xFFF59E0B) : Colors.grey.withOpacity(0.15),
            width: active ? 2 : 1,
          ),
          boxShadow: active
              ? [BoxShadow(color: const Color(0xFFF59E0B).withOpacity(0.15), blurRadius: 8)]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              mode.icon,
              size: 24,
              color: active ? const Color(0xFFF59E0B) : AppColors.textTertiary,
            ),
            const SizedBox(height: 6),
            Text(
              mode.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? const Color(0xFFF59E0B) : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Module Notification Row
// ═══════════════════════════════════════════════════════════════════════════

class _ModuleNotifRow extends StatelessWidget {
  final String moduleName;
  final ModuleNotificationConfig config;
  final ValueChanged<bool> onToggle;
  const _ModuleNotifRow({required this.moduleName, required this.config, required this.onToggle});

  IconData get _moduleIcon {
    switch (moduleName) {
      case 'GO PAGE': return Icons.dashboard;
      case 'MARKET': return Icons.store;
      case 'MY UPDATES': return Icons.update;
      case 'SETUP DASHBOARD': return Icons.settings;
      case 'ALERTS': return Icons.warning_amber;
      case 'LIVE': return Icons.live_tv;
      case 'qualChat': return Icons.chat;
      case 'APRIL': return Icons.smart_toy;
      case 'USER DETAILS': return Icons.person;
      case 'UTILITY': return Icons.build;
      default: return Icons.apps;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(_moduleIcon, size: 18, color: config.pushEnabled ? const Color(0xFFF59E0B) : AppColors.textTertiary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  moduleName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: config.pushEnabled ? AppColors.textPrimary : AppColors.textTertiary,
                  ),
                ),
                Row(
                  children: [
                    Text('P${config.priority}', style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                    if (config.overrideQuietHours) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.notifications_active, size: 10, color: Color(0xFFF59E0B)),
                      const Text(' Override', style: TextStyle(fontSize: 9, color: Color(0xFFF59E0B))),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: config.pushEnabled,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onToggle(v);
            },
            activeColor: const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Smart Rule Card
// ═══════════════════════════════════════════════════════════════════════════

class _SmartRuleCard extends StatelessWidget {
  final SmartNotificationRule rule;
  final ValueChanged<bool> onToggle;
  const _SmartRuleCard({required this.rule, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: rule.enabled ? const Color(0xFF06B6D4).withOpacity(0.04) : Colors.grey.withOpacity(0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: rule.enabled ? const Color(0xFF06B6D4).withOpacity(0.15) : Colors.grey.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.auto_awesome,
              size: 16,
              color: rule.enabled ? const Color(0xFF06B6D4) : AppColors.textTertiary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rule.condition,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: rule.enabled ? AppColors.textPrimary : AppColors.textTertiary,
                    ),
                  ),
                  Text(
                    '→ ${rule.action}',
                    style: TextStyle(
                      fontSize: 11,
                      color: rule.enabled ? const Color(0xFF06B6D4) : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: rule.enabled,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                onToggle(v);
              },
              activeColor: const Color(0xFF06B6D4),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Time Picker Button
// ═══════════════════════════════════════════════════════════════════════════

class _TimePickerButton extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;
  const _TimePickerButton({required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final h = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final m = time.minute.toString().padLeft(2, '0');
    final p = time.period == DayPeriod.am ? 'AM' : 'PM';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF8B5CF6).withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
            const SizedBox(height: 2),
            Text('$h:$m $p', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF8B5CF6))),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Notification Preview
// ═══════════════════════════════════════════════════════════════════════════

class _NotificationPreview extends StatelessWidget {
  final NotificationMode mode;
  const _NotificationPreview({required this.mode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.notifications, size: 18, color: Color(0xFF6366F1)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'thePG',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70),
                ),
                Text(
                  mode == NotificationMode.sleep
                      ? 'Notifications silenced'
                      : 'New message from Wizdom Shop',
                  style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Text(
            'now',
            style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
}
