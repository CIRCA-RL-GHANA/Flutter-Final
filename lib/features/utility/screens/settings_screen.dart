/// ═══════════════════════════════════════════════════════════════════════════
/// U1: SETTINGS & PREFERENCES Screen
/// Theme, language, date/time format, haptics, sounds, updates, analytics
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../models/utility_models.dart';
import '../providers/utility_provider.dart';
import '../widgets/shared_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UtilityProvider>(
      builder: (context, prov, _) {
        final prefs = prov.preferences;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FC),
          appBar: const UtilityAppBar(title: 'Settings'),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kUtilityColor.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kUtilityColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI: ${ai.insights.first['title'] ?? ''}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kUtilityColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // ─── Appearance ────────────────────────────────
              const UtilitySectionTitle(
                title: 'Appearance',
                icon: Icons.palette_outlined,
                iconColor: Color(0xFF6366F1),
              ),
              UtilitySectionCard(
                child: Column(
                  children: [
                    // Theme
                    UtilityActionTile(
                      label: 'Theme',
                      subtitle: _themeLabel(prefs.theme),
                      icon: Icons.dark_mode,
                      iconColor: const Color(0xFF6366F1),
                      onTap: () => _showThemePicker(context, prov),
                    ),
                    const Divider(height: 1),
                    // Text Scale
                    _SliderTile(
                      label: 'Text Size',
                      icon: Icons.format_size,
                      iconColor: const Color(0xFF6366F1),
                      value: prefs.textScaleFactor,
                      min: 0.8,
                      max: 1.6,
                      divisions: 8,
                      valueLabel: '${(prefs.textScaleFactor * 100).toInt()}%',
                      onChanged: (v) => prov.updateTextScale(v),
                    ),
                    const Divider(height: 1),
                    UtilityToggleTile(
                      label: 'Compact Mode',
                      subtitle: 'Show more content with less spacing',
                      icon: Icons.view_compact,
                      activeColor: const Color(0xFF6366F1),
                      value: prefs.compactMode,
                      onChanged: (_) => prov.toggleCompactMode(),
                    ),
                    const Divider(height: 1),
                    UtilityToggleTile(
                      label: 'Animations',
                      subtitle: 'Enable UI animations and transitions',
                      icon: Icons.animation,
                      activeColor: const Color(0xFF6366F1),
                      value: prefs.showAnimations,
                      onChanged: (_) => prov.toggleShowAnimations(),
                    ),
                  ],
                ),
              ),

              // ─── Regional ──────────────────────────────────
              const UtilitySectionTitle(
                title: 'Regional',
                icon: Icons.language,
                iconColor: Color(0xFF3B82F6),
              ),
              UtilitySectionCard(
                child: Column(
                  children: [
                    UtilityActionTile(
                      label: 'Language',
                      subtitle: prov.currentLanguageName,
                      icon: Icons.translate,
                      iconColor: const Color(0xFF3B82F6),
                      onTap: () => _showLanguagePicker(context, prov),
                    ),
                    const Divider(height: 1),
                    UtilityActionTile(
                      label: 'Date Format',
                      subtitle: _dateFormatLabel(prefs.dateFormat),
                      icon: Icons.calendar_today,
                      iconColor: const Color(0xFF3B82F6),
                      onTap: () => _showDateFormatPicker(context, prov),
                    ),
                    const Divider(height: 1),
                    UtilityActionTile(
                      label: 'Time Format',
                      subtitle: prefs.timeFormat == TimeFormatPreference.twelve ? '12-hour' : '24-hour',
                      icon: Icons.access_time,
                      iconColor: const Color(0xFF3B82F6),
                      onTap: () => _showTimeFormatPicker(context, prov),
                    ),
                  ],
                ),
              ),

              // ─── Feedback ──────────────────────────────────
              const UtilitySectionTitle(
                title: 'Feedback',
                icon: Icons.vibration,
                iconColor: Color(0xFF10B981),
              ),
              UtilitySectionCard(
                child: Column(
                  children: [
                    UtilityToggleTile(
                      label: 'Haptic Feedback',
                      subtitle: 'Vibrate on interactions',
                      icon: Icons.vibration,
                      activeColor: const Color(0xFF10B981),
                      value: prefs.hapticFeedback,
                      onChanged: (_) => prov.toggleHapticFeedback(),
                    ),
                    const Divider(height: 1),
                    UtilityToggleTile(
                      label: 'Sound Effects',
                      subtitle: 'Play sounds on actions',
                      icon: Icons.volume_up,
                      activeColor: const Color(0xFF10B981),
                      value: prefs.soundEffects,
                      onChanged: (_) => prov.toggleSoundEffects(),
                    ),
                  ],
                ),
              ),

              // ─── Data & Updates ────────────────────────────
              const UtilitySectionTitle(
                title: 'Data & Updates',
                icon: Icons.system_update,
                iconColor: Color(0xFFF59E0B),
              ),
              UtilitySectionCard(
                child: Column(
                  children: [
                    UtilityToggleTile(
                      label: 'Auto-Update',
                      subtitle: 'Automatically install app updates',
                      icon: Icons.system_update,
                      activeColor: const Color(0xFFF59E0B),
                      value: prefs.autoUpdate,
                      onChanged: (_) => prov.toggleAutoUpdate(),
                    ),
                    const Divider(height: 1),
                    UtilityToggleTile(
                      label: 'Analytics',
                      subtitle: 'Help improve the app with usage data',
                      icon: Icons.analytics,
                      activeColor: const Color(0xFFF59E0B),
                      value: prefs.analyticsEnabled,
                      onChanged: (_) => prov.toggleAnalytics(),
                    ),
                    const Divider(height: 1),
                    UtilityToggleTile(
                      label: 'Crash Reporting',
                      subtitle: 'Send crash reports for debugging',
                      icon: Icons.bug_report,
                      activeColor: const Color(0xFFF59E0B),
                      value: prefs.crashReportingEnabled,
                      onChanged: (_) => prov.toggleCrashReporting(),
                    ),
                  ],
                ),
              ),

              // ─── About ────────────────────────────────────
              const UtilitySectionTitle(
                title: 'About',
                icon: Icons.info_outline,
                iconColor: Color(0xFF64748B),
              ),
              UtilitySectionCard(
                child: Column(
                  children: [
                    UtilityActionTile(
                      label: 'App Version',
                      subtitle: 'v2.4.1 (Build 241)',
                      icon: Icons.info_outline,
                      iconColor: const Color(0xFF64748B),
                      showChevron: false,
                      onTap: null,
                    ),
                    const Divider(height: 1),
                    UtilityActionTile(
                      label: 'Terms of Service',
                      icon: Icons.description,
                      iconColor: const Color(0xFF64748B),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    UtilityActionTile(
                      label: 'Open Source Licenses',
                      icon: Icons.code,
                      iconColor: const Color(0xFF64748B),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Pickers ───────────────────────────────────────────────────────────────

  String _themeLabel(ThemePreference t) {
    switch (t) {
      case ThemePreference.light: return 'Light';
      case ThemePreference.dark: return 'Dark';
      case ThemePreference.system: return 'System Default';
    }
  }

  String _dateFormatLabel(DateFormatPreference d) {
    switch (d) {
      case DateFormatPreference.ddMMYYYY: return 'DD/MM/YYYY';
      case DateFormatPreference.mmDDYYYY: return 'MM/DD/YYYY';
      case DateFormatPreference.yyyyMMDD: return 'YYYY-MM-DD';
    }
  }

  void _showThemePicker(BuildContext context, UtilityProvider prov) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _OptionSheet<ThemePreference>(
        title: 'Choose Theme',
        options: ThemePreference.values,
        selected: prov.preferences.theme,
        labelBuilder: _themeLabel,
        iconBuilder: (t) {
          switch (t) {
            case ThemePreference.light: return Icons.light_mode;
            case ThemePreference.dark: return Icons.dark_mode;
            case ThemePreference.system: return Icons.brightness_auto;
          }
        },
        onSelected: (t) {
          prov.updateTheme(t);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, UtilityProvider prov) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(color: AppColors.inputBorder, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Choose Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            ...UtilityProvider.availableLanguages.map((lang) => ListTile(
              leading: const Icon(Icons.translate, size: 20),
              title: Text(lang.name),
              subtitle: Text(lang.nativeName),
              trailing: prov.preferences.languageCode == lang.code
                  ? const Icon(Icons.check_circle, color: AppColors.success, size: 20)
                  : null,
              onTap: () {
                HapticFeedback.selectionClick();
                prov.updateLanguage(lang.code);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showDateFormatPicker(BuildContext context, UtilityProvider prov) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _OptionSheet<DateFormatPreference>(
        title: 'Date Format',
        options: DateFormatPreference.values,
        selected: prov.preferences.dateFormat,
        labelBuilder: _dateFormatLabel,
        iconBuilder: (_) => Icons.calendar_today,
        onSelected: (d) {
          prov.updateDateFormat(d);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showTimeFormatPicker(BuildContext context, UtilityProvider prov) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _OptionSheet<TimeFormatPreference>(
        title: 'Time Format',
        options: TimeFormatPreference.values,
        selected: prov.preferences.timeFormat,
        labelBuilder: (t) => t == TimeFormatPreference.twelve ? '12-hour (AM/PM)' : '24-hour',
        iconBuilder: (_) => Icons.access_time,
        onSelected: (t) {
          prov.updateTimeFormat(t);
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ─── Slider Tile ─────────────────────────────────────────────────────────────

class _SliderTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String valueLabel;
  final ValueChanged<double> onChanged;

  const _SliderTile({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.valueLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                valueLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: iconColor,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: iconColor,
            inactiveColor: iconColor.withOpacity(0.15),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ─── Generic Option Sheet ────────────────────────────────────────────────────

class _OptionSheet<T> extends StatelessWidget {
  final String title;
  final List<T> options;
  final T selected;
  final String Function(T) labelBuilder;
  final IconData Function(T) iconBuilder;
  final ValueChanged<T> onSelected;

  const _OptionSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.labelBuilder,
    required this.iconBuilder,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(color: AppColors.inputBorder, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          ...options.map((opt) => ListTile(
            leading: Icon(iconBuilder(opt), size: 20),
            title: Text(labelBuilder(opt)),
            trailing: selected == opt
                ? const Icon(Icons.check_circle, color: AppColors.success, size: 20)
                : null,
            onTap: () {
              HapticFeedback.selectionClick();
              onSelected(opt);
            },
          )),
        ],
      ),
    );
  }
}
