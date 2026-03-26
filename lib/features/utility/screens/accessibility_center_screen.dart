/// ═══════════════════════════════════════════════════════════════════════════
/// U6: ACCESSIBILITY CENTER Screen
/// Text scaling, bold text, high contrast, reduce motion, color blindness,
/// screen reader, touch targets, presets
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../models/utility_models.dart';
import '../providers/utility_provider.dart';
import '../widgets/shared_widgets.dart';

class AccessibilityCenterScreen extends StatelessWidget {
  const AccessibilityCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UtilityProvider>(
      builder: (context, prov, _) {
        final config = prov.accessibilityConfig;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FC),
          appBar: UtilityAppBar(
            title: 'Accessibility',
            actions: [
              IconButton(
                icon: const Icon(Icons.restore, size: 20, color: AppColors.textPrimary),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  prov.updateAccessibility(const AccessibilityConfig());
                },
                tooltip: 'Reset to defaults',
              ),
              const SizedBox(width: 4),
            ],
          ),
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
              // ─── Quick Presets ─────────────────────────────
              const UtilitySectionTitle(
                title: 'Quick Presets',
                icon: Icons.auto_awesome,
                iconColor: Color(0xFF06B6D4),
              ),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: UtilityProvider.presets.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final preset = UtilityProvider.presets[i];
                    return _PresetCard(
                      preset: preset,
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        prov.applyPreset(preset);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // ─── Vision ───────────────────────────────────
              const UtilitySectionTitle(
                title: 'Vision',
                icon: Icons.visibility,
                iconColor: Color(0xFF6366F1),
              ),
              UtilitySectionCard(
                child: Column(
                  children: [
                    // Text Scale slider
                    _AccessibilitySlider(
                      label: 'Text Size',
                      icon: Icons.format_size,
                      value: config.textScale,
                      min: 0.8,
                      max: 2.0,
                      divisions: 12,
                      valueLabel: '${(config.textScale * 100).toInt()}%',
                      onChanged: prov.setTextScale,
                    ),
                    const Divider(height: 1),
                    UtilityToggleTile(
                      label: 'Bold Text',
                      subtitle: 'Make all text bolder for readability',
                      icon: Icons.format_bold,
                      activeColor: const Color(0xFF6366F1),
                      value: config.boldText,
                      onChanged: (_) => prov.toggleBoldText(),
                    ),
                    const Divider(height: 1),
                    UtilityToggleTile(
                      label: 'High Contrast',
                      subtitle: 'Increase contrast for better visibility',
                      icon: Icons.contrast,
                      activeColor: const Color(0xFF6366F1),
                      value: config.highContrast,
                      onChanged: (_) => prov.toggleHighContrast(),
                    ),
                    const Divider(height: 1),
                    UtilityToggleTile(
                      label: 'Reduce Transparency',
                      subtitle: 'Use solid backgrounds instead of blur',
                      icon: Icons.opacity,
                      activeColor: const Color(0xFF6366F1),
                      value: config.reduceTransparency,
                      onChanged: (_) => prov.toggleReduceTransparency(),
                    ),
                    const Divider(height: 1),
                    UtilityActionTile(
                      label: 'Color Blindness Mode',
                      subtitle: _colorBlindLabel(config.colorBlindnessMode),
                      icon: Icons.palette,
                      iconColor: const Color(0xFF6366F1),
                      onTap: () => _showColorBlindPicker(context, prov),
                    ),
                  ],
                ),
              ),

              // ─── Motion ───────────────────────────────────
              const UtilitySectionTitle(
                title: 'Motion',
                icon: Icons.animation,
                iconColor: Color(0xFF10B981),
              ),
              UtilitySectionCard(
                child: Column(
                  children: [
                    UtilityToggleTile(
                      label: 'Reduce Motion',
                      subtitle: 'Minimize animations and transitions',
                      icon: Icons.motion_photos_off,
                      activeColor: const Color(0xFF10B981),
                      value: config.reduceMotion,
                      onChanged: (_) => prov.toggleReduceMotion(),
                    ),
                  ],
                ),
              ),

              // ─── Interaction ──────────────────────────────
              const UtilitySectionTitle(
                title: 'Interaction',
                icon: Icons.touch_app,
                iconColor: Color(0xFFF59E0B),
              ),
              UtilitySectionCard(
                child: Column(
                  children: [
                    _AccessibilitySlider(
                      label: 'Touch Target Size',
                      icon: Icons.touch_app,
                      value: config.touchTargetSize,
                      min: 40.0,
                      max: 64.0,
                      divisions: 6,
                      valueLabel: '${config.touchTargetSize.toInt()}px',
                      onChanged: prov.setTouchTargetSize,
                    ),
                    const Divider(height: 1),
                    UtilityToggleTile(
                      label: 'Haptic Feedback',
                      subtitle: 'Vibrate on interactions',
                      icon: Icons.vibration,
                      activeColor: const Color(0xFFF59E0B),
                      value: config.hapticFeedback,
                      onChanged: (_) => prov.toggleAccessibilityHaptic(),
                    ),
                    const Divider(height: 1),
                    UtilityToggleTile(
                      label: 'Focus Indicators',
                      subtitle: 'Show visible focus outlines',
                      icon: Icons.center_focus_strong,
                      activeColor: const Color(0xFFF59E0B),
                      value: config.showFocusIndicators,
                      onChanged: (_) => prov.toggleFocusIndicators(),
                    ),
                    const Divider(height: 1),
                    UtilityToggleTile(
                      label: 'Large Pointer',
                      subtitle: 'Enlarge the pointer for easier targeting',
                      icon: Icons.mouse,
                      activeColor: const Color(0xFFF59E0B),
                      value: config.largePointer,
                      onChanged: (_) => prov.toggleLargePointer(),
                    ),
                  ],
                ),
              ),

              // ─── Audio ────────────────────────────────────
              const UtilitySectionTitle(
                title: 'Audio & Screen Reader',
                icon: Icons.record_voice_over,
                iconColor: Color(0xFF8B5CF6),
              ),
              UtilitySectionCard(
                child: Column(
                  children: [
                    UtilityToggleTile(
                      label: 'Screen Reader Optimized',
                      subtitle: 'Enhance layout for screen reader navigation',
                      icon: Icons.record_voice_over,
                      activeColor: const Color(0xFF8B5CF6),
                      value: config.screenReaderOptimized,
                      onChanged: (_) => prov.toggleScreenReader(),
                    ),
                    const Divider(height: 1),
                    UtilityToggleTile(
                      label: 'Audio Descriptions',
                      subtitle: 'Read visual content aloud',
                      icon: Icons.hearing,
                      activeColor: const Color(0xFF8B5CF6),
                      value: config.audioDescriptions,
                      onChanged: (_) => prov.toggleAudioDescriptions(),
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

  String _colorBlindLabel(ColorBlindnessMode mode) {
    switch (mode) {
      case ColorBlindnessMode.none: return 'None';
      case ColorBlindnessMode.protanopia: return 'Protanopia (Red)';
      case ColorBlindnessMode.deuteranopia: return 'Deuteranopia (Green)';
      case ColorBlindnessMode.tritanopia: return 'Tritanopia (Blue)';
      case ColorBlindnessMode.achromatopsia: return 'Achromatopsia (Total)';
    }
  }

  void _showColorBlindPicker(BuildContext context, UtilityProvider prov) {
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
            const Text('Color Blindness Mode', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ...ColorBlindnessMode.values.map((mode) => ListTile(
              leading: const Icon(Icons.palette, size: 20),
              title: Text(_colorBlindLabel(mode)),
              trailing: prov.accessibilityConfig.colorBlindnessMode == mode
                  ? const Icon(Icons.check_circle, color: AppColors.success, size: 20)
                  : null,
              onTap: () {
                HapticFeedback.selectionClick();
                prov.setColorBlindnessMode(mode);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }
}

// ─── Preset Card ─────────────────────────────────────────────────────────────

class _PresetCard extends StatelessWidget {
  final AccessibilityPreset preset;
  final VoidCallback onTap;

  const _PresetCard({required this.preset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(preset.icon, size: 24, color: const Color(0xFF06B6D4)),
            const Spacer(),
            Text(
              preset.name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            Text(
              preset.description,
              style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Accessibility Slider ────────────────────────────────────────────────────

class _AccessibilitySlider extends StatelessWidget {
  final String label;
  final IconData icon;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String valueLabel;
  final ValueChanged<double> onChanged;

  const _AccessibilitySlider({
    required this.label,
    required this.icon,
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: const Color(0xFF6366F1)),
              ),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
              const Spacer(),
              Text(valueLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF6366F1))),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: const Color(0xFF6366F1),
            inactiveColor: const Color(0xFF6366F1).withOpacity(0.15),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
