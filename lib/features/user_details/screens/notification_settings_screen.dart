/// 
/// Screen 7: Notification Orchestrator
/// Mode presets, per-module matrix, smart rules, quiet hours
/// 
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive.dart';
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
          backgroundColor: IveTokens.bg,
          appBar: const ModuleHeader(
            title: 'Notifications',
            contextColor: IveTokens.moduleUser,
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              //  Master Toggle 
              SectionCard(
                child: SettingsToggle(
                  icon: Icons.notifications,
                  label: 'Push Notifications',
                  subtitle: notif.globalEnabled ? 'All notifications enabled' : 'All notifications paused',
                  value: notif.globalEnabled,
                  onChanged: (v) => udp.toggleGlobalNotifications(v),
                  activeColor: IveTokens.warning,
                ),
              ),

              if (notif.globalEnabled) ...[
                //  Mode Presets 
                const SizedBox(height: 8),
                Text('Notification Mode', style: IveType.bodyEmphasis.copyWith(color: IveTokens.ink2)),
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

                //  Per-Module Matrix 
                const SizedBox(height: 16),
                SectionCard(
                  child: CollapsibleSection(
                    title: 'Per-Module Settings',
                    icon: Icons.grid_view,
                    iconColor: IveTokens.warning,
                    child: Column(
                      children: notif.moduleConfigs.entries.map((entry) => _ModuleNotifRow(
                            moduleName: entry.key,
                            config: entry.value,
                            onToggle: (enabled) => udp.toggleModuleNotification(entry.key, enabled),
                          )).toList(),
                    ),
                  ),
                ),

                //  Quiet Hours 
                SectionCard(
                  child: Column(
                    children: [
                      SettingsToggle(
                        icon: Icons.bedtime,
                        label: 'Quiet Hours',
                        subtitle: '${_formatTime(notif.quietHoursStart)} - ${_formatTime(notif.quietHoursEnd)}',
                        value: notif.quietHoursEnabled,
                        onChanged: (v) => udp.toggleQuietHours(v),
                        activeColor: IveTokens.accent,
                      ),
                      if (notif.quietHoursEnabled) ...[
                        const Divider(height: 1, color: IveTokens.hairline),
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
                                child: Icon(Icons.arrow_forward, size: 16, color: IveTokens.mute),
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

                //  Smart Rules 
                SectionCard(
                  child: CollapsibleSection(
                    title: 'Smart Rules',
                    icon: Icons.auto_awesome,
                    iconColor: IveTokens.moduleUser,
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
                            onPressed: () {
                              final nameCtrl = TextEditingController();
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('New Smart Rule'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: nameCtrl,
                                        decoration: const InputDecoration(
                                          labelText: 'Rule name / condition',
                                          hintText: 'e.g. When battery < 20%',
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel'),
                                    ),
                                    IveButton.primary(
                                      label: 'Save',
                                      expand: false,
                                      compact: true,
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        if (nameCtrl.text.isNotEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Rule "${nameCtrl.text}" saved')),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Rule'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: IveTokens.moduleUser,
                              side: const BorderSide(color: IveTokens.moduleUser),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(IveTokens.rSm)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                //  Preview 
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.preview, size: 18, color: IveTokens.accent),
                          const SizedBox(width: 8),
                          Text('Notification Preview', style: IveType.bodyEmphasis.copyWith(color: IveTokens.ink)),
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
    final udp = context.read<UserDetailsProvider>();
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      final notif = udp.notifications;
      if (isStart) {
        udp.updateNotifications(notif.copyWith(quietHoursStart: picked));
      } else {
        udp.updateNotifications(notif.copyWith(quietHoursEnd: picked));
      }
    }
  }
}

// 
// Mode Card
// 

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
        duration: IveTokens.dFast,
        width: 80,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: active ? IveTokens.warning.withValues(alpha: 0.1) : IveTokens.surface,
          borderRadius: BorderRadius.circular(IveTokens.rSm),
          border: Border.all(
            color: active ? IveTokens.warning : IveTokens.hairline,
            width: active ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              mode.icon,
              size: 24,
              color: active ? IveTokens.warning : IveTokens.mute,
            ),
            const SizedBox(height: 6),
            Text(
              mode.label,
              style: IveType.caption.copyWith(
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? IveTokens.warning : IveTokens.ink2,
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

// 
// Module Notification Row
// 

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
          Icon(_moduleIcon, size: 18, color: config.pushEnabled ? IveTokens.warning : IveTokens.mute),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  moduleName,
                  style: IveType.body.copyWith(
                    fontWeight: FontWeight.w500,
                    color: config.pushEnabled ? IveTokens.ink : IveTokens.mute,
                  ),
                ),
                Row(
                  children: [
                    Text('P${config.priority}', style: IveType.caption.copyWith(color: IveTokens.mute)),
                    if (config.overrideQuietHours) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.notifications_active, size: 10, color: IveTokens.warning),
                      Text(' Override', style: IveType.caption.copyWith(color: IveTokens.warning)),
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
            activeThumbColor: IveTokens.warning,
          ),
        ],
      ),
    );
  }
}

// 
// Smart Rule Card
// 

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
          color: rule.enabled ? IveTokens.moduleUser.withValues(alpha: 0.04) : IveTokens.hairline.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(IveTokens.rSm),
          border: Border.all(
            color: rule.enabled ? IveTokens.moduleUser.withValues(alpha: 0.15) : IveTokens.hairline.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.auto_awesome,
              size: 16,
              color: rule.enabled ? IveTokens.moduleUser : IveTokens.mute,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rule.condition,
                    style: IveType.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: rule.enabled ? IveTokens.ink : IveTokens.mute,
                    ),
                  ),
                  Text(
                    ' ${rule.action}',
                    style: IveType.caption.copyWith(
                      color: rule.enabled ? IveTokens.moduleUser : IveTokens.mute,
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
              activeThumbColor: IveTokens.moduleUser,
            ),
          ],
        ),
      ),
    );
  }
}

// 
// Time Picker Button
// 

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
          color: IveTokens.accent.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(IveTokens.rSm),
          border: Border.all(color: IveTokens.accent.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Text(label, style: IveType.caption.copyWith(color: IveTokens.mute)),
            const SizedBox(height: 2),
            Text('$h:$m $p', style: IveType.bodyEmphasis.copyWith(color: IveTokens.accent)),
          ],
        ),
      ),
    );
  }
}

// 
// Notification Preview
// 

class _NotificationPreview extends StatelessWidget {
  final NotificationMode mode;
  const _NotificationPreview({required this.mode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: IveTokens.surface,
        borderRadius: BorderRadius.circular(IveTokens.rSm),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: IveTokens.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(IveTokens.rSm),
            ),
            child: const Icon(Icons.notifications, size: 18, color: IveTokens.accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'thePG',
                  style: IveType.caption.copyWith(color: IveTokens.ink2, fontWeight: FontWeight.w600),
                ),
                Text(
                  mode == NotificationMode.sleep
                      ? 'Notifications silenced'
                      : 'New message from Wizdom Shop',
                  style: IveType.body.copyWith(color: IveTokens.ink, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Text(
            'now',
            style: IveType.caption.copyWith(color: IveTokens.faint),
          ),
        ],
      ),
    );
  }
}
