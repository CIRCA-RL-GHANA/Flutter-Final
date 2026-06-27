/// 
/// Screen 8: Accessibility Suite
/// Vision, Hearing, Motor, Cognitive sections + Preset management
/// 
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive.dart';
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
          backgroundColor: IveTokens.bg,
          appBar: ModuleHeader(
            title: 'Accessibility',
            contextColor: IveTokens.moduleUser,
            actions: [
              TextButton.icon(
                onPressed: () => _showSavePreset(context, udp),
                icon: const Icon(Icons.save_outlined, size: 16),
                label: Text('Save', style: IveType.caption),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              //  Quick Presets 
              Text('Quick Presets', style: IveType.bodyEmphasis.copyWith(color: IveTokens.ink2)),
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

              //  Vision 
              SectionCard(
                child: CollapsibleSection(
                  title: 'Vision',
                  icon: Icons.visibility,
                  iconColor: IveTokens.accent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text Scale
                      Text('Text Size', style: IveType.bodyEmphasis.copyWith(color: IveTokens.ink2)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('A', style: IveType.caption.copyWith(color: IveTokens.mute)),
                          Expanded(
                            child: Slider(
                              value: a11y.textScale,
                              min: 0.8,
                              max: 2.0,
                              divisions: 12,
                              activeColor: IveTokens.accent,
                              onChanged: (v) => udp.setTextScale(v),
                            ),
                          ),
                          Text('A', style: IveType.caption.copyWith(fontSize: 12 * a11y.textScale, color: IveTokens.ink, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Center(
                        child: Text(
                          '${(a11y.textScale * 100).toInt()}%',
                          style: IveType.caption.copyWith(fontWeight: FontWeight.w600, color: IveTokens.accent),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Preview text
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: a11y.highContrast ? IveTokens.bg : IveTokens.hairline.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(IveTokens.rSm),
                        ),
                        child: Text(
                          'The quick brown fox jumps over the lazy dog.',
                          style: TextStyle(
                            fontSize: 14 * a11y.textScale,
                            color: a11y.highContrast ? IveTokens.ink : IveTokens.ink,
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
                        activeColor: IveTokens.accent,
                      ),
                      SettingsToggle(
                        icon: Icons.zoom_in,
                        label: 'Screen Magnifier',
                        subtitle: 'Pinch to magnify any area',
                        value: a11y.screenMagnifier,
                        onChanged: (v) => udp.updateAccessibility(a11y.copyWith(screenMagnifier: v)),
                        activeColor: IveTokens.accent,
                      ),
                    ],
                  ),
                ),
              ),

              //  Hearing 
              SectionCard(
                child: CollapsibleSection(
                  title: 'Hearing',
                  icon: Icons.hearing,
                  iconColor: IveTokens.success,
                  initiallyExpanded: false,
                  child: Column(
                    children: [
                      SettingsToggle(
                        icon: Icons.flash_on,
                        label: 'Visual Alerts',
                        subtitle: 'Flash screen for audio notifications',
                        value: a11y.visualAlerts,
                        onChanged: (v) => udp.updateAccessibility(a11y.copyWith(visualAlerts: v)),
                        activeColor: IveTokens.success,
                      ),
                      SettingsToggle(
                        icon: Icons.closed_caption,
                        label: 'Captions',
                        subtitle: 'Show captions for audio/video',
                        value: a11y.captionsEnabled,
                        onChanged: (v) => udp.updateAccessibility(a11y.copyWith(captionsEnabled: v)),
                        activeColor: IveTokens.success,
                      ),
                      SettingsToggle(
                        icon: Icons.headphones,
                        label: 'Mono Audio',
                        subtitle: 'Combine stereo into single channel',
                        value: a11y.monoAudio,
                        onChanged: (v) => udp.updateAccessibility(a11y.copyWith(monoAudio: v)),
                        activeColor: IveTokens.success,
                      ),

                      // Volume balance
                      const SizedBox(height: 8),
                      Text('Audio Balance', style: IveType.bodyEmphasis.copyWith(color: IveTokens.ink2)),
                      Row(
                        children: [
                          Text('L', style: IveType.caption.copyWith(color: IveTokens.mute)),
                          Expanded(
                            child: Slider(
                              value: a11y.volumeBalance,
                              min: 0.0,
                              max: 1.0,
                              activeColor: IveTokens.success,
                              onChanged: (v) => udp.updateAccessibility(a11y.copyWith(volumeBalance: v)),
                            ),
                          ),
                          Text('R', style: IveType.caption.copyWith(color: IveTokens.mute)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              //  Motor 
              SectionCard(
                child: CollapsibleSection(
                  title: 'Motor',
                  icon: Icons.touch_app,
                  iconColor: IveTokens.warning,
                  initiallyExpanded: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Touch sensitivity
                      Text('Touch Sensitivity', style: IveType.bodyEmphasis.copyWith(color: IveTokens.ink2)),
                      Row(
                        children: [
                          Text('Light', style: IveType.caption.copyWith(color: IveTokens.mute)),
                          Expanded(
                            child: Slider(
                              value: a11y.touchSensitivity,
                              min: 0.0,
                              max: 1.0,
                              activeColor: IveTokens.warning,
                              onChanged: (v) => udp.updateAccessibility(a11y.copyWith(touchSensitivity: v)),
                            ),
                          ),
                          Text('Firm', style: IveType.caption.copyWith(color: IveTokens.mute)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SettingsToggle(
                        icon: Icons.gesture,
                        label: 'Simplified Gestures',
                        subtitle: 'Replace complex gestures with taps',
                        value: a11y.gestureSimplification,
                        onChanged: (v) => udp.updateAccessibility(a11y.copyWith(gestureSimplification: v)),
                        activeColor: IveTokens.warning,
                      ),
                      SettingsToggle(
                        icon: Icons.switch_access_shortcut,
                        label: 'Switch Control',
                        subtitle: 'Navigate with external switch',
                        value: a11y.switchControl,
                        onChanged: (v) => udp.updateAccessibility(a11y.copyWith(switchControl: v)),
                        activeColor: IveTokens.warning,
                      ),
                      SettingsToggle(
                        icon: Icons.mic,
                        label: 'Voice Control',
                        subtitle: 'Navigate using voice commands',
                        value: a11y.voiceControl,
                        onChanged: (v) => udp.updateAccessibility(a11y.copyWith(voiceControl: v)),
                        activeColor: IveTokens.warning,
                      ),
                    ],
                  ),
                ),
              ),

              //  Cognitive 
              SectionCard(
                child: CollapsibleSection(
                  title: 'Cognitive',
                  icon: Icons.psychology,
                  iconColor: IveTokens.accent,
                  initiallyExpanded: false,
                  child: Column(
                    children: [
                      SettingsToggle(
                        icon: Icons.animation,
                        label: 'Reduced Motion',
                        subtitle: 'Minimize animations and transitions',
                        value: a11y.reducedMotion,
                        onChanged: (v) => udp.toggleReducedMotion(v),
                        activeColor: IveTokens.accent,
                      ),
                      SettingsToggle(
                        icon: Icons.dashboard_customize,
                        label: 'Simplified Layout',
                        subtitle: 'Reduce visual complexity',
                        value: a11y.simplifiedLayout,
                        onChanged: (v) => udp.updateAccessibility(a11y.copyWith(simplifiedLayout: v)),
                        activeColor: IveTokens.accent,
                      ),
                      SettingsToggle(
                        icon: Icons.center_focus_strong,
                        label: 'Focus Assist',
                        subtitle: 'Highlight active elements clearly',
                        value: a11y.focusAssist,
                        onChanged: (v) => udp.updateAccessibility(a11y.copyWith(focusAssist: v)),
                        activeColor: IveTokens.accent,
                      ),
                      SettingsToggle(
                        icon: Icons.auto_stories,
                        label: 'Reading Assistance',
                        subtitle: 'Line highlighting and reading guide',
                        value: a11y.readingAssistance,
                        onChanged: (v) => udp.updateAccessibility(a11y.copyWith(readingAssistance: v)),
                        activeColor: IveTokens.accent,
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(IveTokens.rSm))),
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
                decoration: BoxDecoration(color: IveTokens.hairline2, borderRadius: BorderRadius.circular(IveTokens.rXs)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Save as Preset', style: IveType.title3.copyWith(color: IveTokens.ink)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Preset name',
                filled: true,
                fillColor: IveTokens.hairline2,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(IveTokens.rSm), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            IveButton.primary(
              label: 'Save Preset',
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  udp.saveCurrentAsPreset(controller.text.trim());
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Preset "${controller.text.trim()}" saved')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// 
// Preset Card
// 

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
        duration: IveTokens.dFast,
        width: 88,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: active ? IveTokens.moduleUser.withValues(alpha: 0.1) : IveTokens.surface,
          borderRadius: BorderRadius.circular(IveTokens.rSm),
          border: Border.all(
            color: active ? IveTokens.moduleUser : IveTokens.hairline,
            width: active ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_icon, size: 22, color: active ? IveTokens.moduleUser : IveTokens.mute),
            const SizedBox(height: 6),
            Text(
              preset.name,
              style: IveType.caption.copyWith(
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? IveTokens.moduleUser : IveTokens.ink2,
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
