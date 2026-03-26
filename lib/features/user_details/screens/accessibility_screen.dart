/// ═══════════════════════════════════════════════════════════════════════════
/// Screen 8: Accessibility Suite
/// Vision, Hearing, Motor, Cognitive sections + Preset management
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../models/user_details_models.dart';
import '../providers/user_details_provider.dart';
import '../widgets/shared_widgets.dart';

class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDetailsProvider>(
      builder: (context, udp, _) {
        final a11y = udp.accessibility;
        final presets = udp.accessibilityPresets;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FC),
          appBar: ModuleHeader(
            title: 'Accessibility',
            contextColor: const Color(0xFF06B6D4),
            actions: [
              TextButton.icon(
                onPressed: () => _showSavePreset(context, udp),
                icon: const Icon(Icons.save_outlined, size: 16),
                label: const Text('Save', style: TextStyle(fontSize: 12)),
              ),
            ],
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
              // ─── Quick Presets ──────────────────────────────
              const Text('Quick Presets', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 10),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: presets.length,
                  itemBuilder: (_, i) {
                    final preset = presets[i];
                    final active = a11y.activePresetName == preset.name;
                    return _PresetCard(
                      preset: preset,
                      active: active,
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        udp.applyPreset(preset);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // ─── Vision ────────────────────────────────────
              SectionCard(
                child: CollapsibleSection(
                  title: 'Vision',
                  icon: Icons.visibility,
                  iconColor: const Color(0xFF3B82F6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text Scale
                      const Text('Text Size', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text('A', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                          Expanded(
                            child: Slider(
                              value: a11y.textScale,
                              min: 0.8,
                              max: 2.0,
                              divisions: 12,
                              activeColor: const Color(0xFF3B82F6),
                              onChanged: (v) => udp.setTextScale(v),
                            ),
                          ),
                          Text('A', style: TextStyle(fontSize: 12 * a11y.textScale, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Center(
                        child: Text(
                          '${(a11y.textScale * 100).toInt()}%',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF3B82F6)),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Preview text
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: a11y.highContrast ? Colors.black : Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'The quick brown fox jumps over the lazy dog.',
                          style: TextStyle(
                            fontSize: 14 * a11y.textScale,
                            color: a11y.highContrast ? Colors.white : AppColors.textPrimary,
                            fontWeight: a11y.highContrast ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      SettingsToggle(
                        icon: Icons.contrast,
                        label: 'High Contrast',
                        subtitle: 'Enhanced colors for readability',
                        value: a11y.highContrast,
                        onChanged: (v) => udp.toggleHighContrast(v),
                        activeColor: const Color(0xFF3B82F6),
                      ),
                      SettingsToggle(
                        icon: Icons.zoom_in,
                        label: 'Screen Magnifier',
                        subtitle: 'Pinch to magnify any area',
                        value: a11y.screenMagnifier,
                        onChanged: (v) => udp.updateAccessibility(a11y.copyWith(screenMagnifier: v)),
                        activeColor: const Color(0xFF3B82F6),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Hearing ───────────────────────────────────
              SectionCard(
                child: CollapsibleSection(
                  title: 'Hearing',
                  icon: Icons.hearing,
                  iconColor: const Color(0xFF10B981),
                  initiallyExpanded: false,
                  child: Column(
                    children: [
                      SettingsToggle(
                        icon: Icons.flash_on,
                        label: 'Visual Alerts',
                        subtitle: 'Flash screen for audio notifications',
                        value: a11y.visualAlerts,
                        onChanged: (v) => udp.updateAccessibility(a11y.copyWith(visualAlerts: v)),
                        activeColor: const Color(0xFF10B981),
                      ),
                      SettingsToggle(
                        icon: Icons.closed_caption,
                        label: 'Captions',
                        subtitle: 'Show captions for audio/video',
                        value: a11y.captionsEnabled,
                        onChanged: (v) => udp.updateAccessibility(a11y.copyWith(captionsEnabled: v)),
                        activeColor: const Color(0xFF10B981),
                      ),
                      SettingsToggle(
                        icon: Icons.headphones,
                        label: 'Mono Audio',
                        subtitle: 'Combine stereo into single channel',
                        value: a11y.monoAudio,
                        onChanged: (v) => udp.updateAccessibility(a11y.copyWith(monoAudio: v)),
                        activeColor: const Color(0xFF10B981),
                      ),

                      // Volume balance
                      const SizedBox(height: 8),
                      const Text('Audio Balance', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      Row(
                        children: [
                          const Text('L', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                          Expanded(
                            child: Slider(
                              value: a11y.volumeBalance,
                              min: 0.0,
                              max: 1.0,
                              activeColor: const Color(0xFF10B981),
                              onChanged: (v) => udp.updateAccessibility(a11y.copyWith(volumeBalance: v)),
                            ),
                          ),
                          const Text('R', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Motor ────────────────────────────────────
              SectionCard(
                child: CollapsibleSection(
                  title: 'Motor',
                  icon: Icons.touch_app,
                  iconColor: const Color(0xFFF59E0B),
                  initiallyExpanded: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Touch sensitivity
                      const Text('Touch Sensitivity', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      Row(
                        children: [
                          const Text('Light', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                          Expanded(
                            child: Slider(
                              value: a11y.touchSensitivity,
                              min: 0.0,
                              max: 1.0,
                              activeColor: const Color(0xFFF59E0B),
                              onChanged: (v) => udp.updateAccessibility(a11y.copyWith(touchSensitivity: v)),
                            ),
                          ),
                          const Text('Firm', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SettingsToggle(
                        icon: Icons.gesture,
                        label: 'Simplified Gestures',
                        subtitle: 'Replace complex gestures with taps',
                        value: a11y.gestureSimplification,
                        onChanged: (v) => udp.updateAccessibility(a11y.copyWith(gestureSimplification: v)),
                        activeColor: const Color(0xFFF59E0B),
                      ),
                      SettingsToggle(
                        icon: Icons.switch_access_shortcut,
                        label: 'Switch Control',
                        subtitle: 'Navigate with external switch',
                        value: a11y.switchControl,
                        onChanged: (v) => udp.updateAccessibility(a11y.copyWith(switchControl: v)),
                        activeColor: const Color(0xFFF59E0B),
                      ),
                      SettingsToggle(
                        icon: Icons.mic,
                        label: 'Voice Control',
                        subtitle: 'Navigate using voice commands',
                        value: a11y.voiceControl,
                        onChanged: (v) => udp.updateAccessibility(a11y.copyWith(voiceControl: v)),
                        activeColor: const Color(0xFFF59E0B),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Cognitive ─────────────────────────────────
              SectionCard(
                child: CollapsibleSection(
                  title: 'Cognitive',
                  icon: Icons.psychology,
                  iconColor: const Color(0xFF8B5CF6),
                  initiallyExpanded: false,
                  child: Column(
                    children: [
                      SettingsToggle(
                        icon: Icons.animation,
                        label: 'Reduced Motion',
                        subtitle: 'Minimize animations and transitions',
                        value: a11y.reducedMotion,
                        onChanged: (v) => udp.toggleReducedMotion(v),
                        activeColor: const Color(0xFF8B5CF6),
                      ),
                      SettingsToggle(
                        icon: Icons.dashboard_customize,
                        label: 'Simplified Layout',
                        subtitle: 'Reduce visual complexity',
                        value: a11y.simplifiedLayout,
                        onChanged: (v) => udp.updateAccessibility(a11y.copyWith(simplifiedLayout: v)),
                        activeColor: const Color(0xFF8B5CF6),
                      ),
                      SettingsToggle(
                        icon: Icons.center_focus_strong,
                        label: 'Focus Assist',
                        subtitle: 'Highlight active elements clearly',
                        value: a11y.focusAssist,
                        onChanged: (v) => udp.updateAccessibility(a11y.copyWith(focusAssist: v)),
                        activeColor: const Color(0xFF8B5CF6),
                      ),
                      SettingsToggle(
                        icon: Icons.auto_stories,
                        label: 'Reading Assistance',
                        subtitle: 'Line highlighting and reading guide',
                        value: a11y.readingAssistance,
                        onChanged: (v) => udp.updateAccessibility(a11y.copyWith(readingAssistance: v)),
                        activeColor: const Color(0xFF8B5CF6),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  void _showSavePreset(BuildContext context, UserDetailsProvider udp) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
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
            const Text('Save as Preset', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Preset name',
                filled: true,
                fillColor: AppColors.inputFill,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    udp.saveCurrentAsPreset(controller.text.trim());
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Preset "${controller.text.trim()}" saved')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06B6D4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Preset', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Preset Card
// ═══════════════════════════════════════════════════════════════════════════

class _PresetCard extends StatelessWidget {
  final AccessibilityPreset preset;
  final bool active;
  final VoidCallback onTap;
  const _PresetCard({required this.preset, required this.active, required this.onTap});

  IconData get _icon {
    switch (preset.name) {
      case 'Large Text': return Icons.text_fields;
      case 'High Contrast': return Icons.contrast;
      case 'Reduced Motion': return Icons.animation;
      default: return Icons.tune;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 88,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF06B6D4).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? const Color(0xFF06B6D4) : Colors.grey.withOpacity(0.15),
            width: active ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_icon, size: 22, color: active ? const Color(0xFF06B6D4) : AppColors.textTertiary),
            const SizedBox(height: 6),
            Text(
              preset.name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? const Color(0xFF06B6D4) : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
