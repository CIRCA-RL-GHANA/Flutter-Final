/// ═══════════════════════════════════════════════════════════════════════════
/// LIVE MODULE — Screen 22: Live Module Settings
/// Configuration: auto-assign, bundles, returns, verification defaults,
/// thresholds, driver policies, performance targets
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../models/live_models.dart';
import '../providers/live_provider.dart';
import '../widgets/live_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class LiveSettingsScreen extends StatefulWidget {
  const LiveSettingsScreen({super.key});

  @override
  State<LiveSettingsScreen> createState() => _LiveSettingsScreenState();
}

class _LiveSettingsScreenState extends State<LiveSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LiveProvider>(
      builder: (context, prov, _) {
        final s = prov.settings;
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: const LiveAppBar(title: 'Live Settings'),
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
                      color: kLiveColor.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kLiveColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI: ${ai.insights.first['title'] ?? ''}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kLiveColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Auto-Assign
              LiveSectionCard(
                title: 'ORDER ASSIGNMENT',
                icon: Icons.auto_awesome,
                iconColor: kLiveAccent,
                child: Column(
                  children: [
                    _SettingsToggle(
                      icon: Icons.smart_toy,
                      label: 'Auto-assign orders',
                      subtitle: 'Automatically assign best driver',
                      value: s.autoAssignOrders,
                      onChanged: (v) => prov.updateSettings(s.copyWith(autoAssignOrders: v)),
                    ),
                    if (s.autoAssignOrders) ...[
                      const SizedBox(height: 4),
                      _SliderSetting(
                        label: 'Max assignment distance',
                        value: s.autoAssignMaxDistance,
                        min: 1.0,
                        max: 20.0,
                        suffix: 'km',
                        onChanged: (v) => prov.updateSettings(s.copyWith(autoAssignMaxDistance: v)),
                      ),
                    ],
                    const SizedBox(height: 4),
                    _SliderSetting(
                      label: 'Minimum driver rating',
                      value: s.minimumDriverRating,
                      min: 3.0,
                      max: 5.0,
                      suffix: '★',
                      divisions: 20,
                      onChanged: (v) => prov.updateSettings(s.copyWith(minimumDriverRating: v)),
                    ),
                  ],
                ),
              ),

              // Bundling
              LiveSectionCard(
                title: 'PACKAGE BUNDLING',
                icon: Icons.inventory_2,
                iconColor: const Color(0xFF3B82F6),
                child: Column(
                  children: [
                    _SettingsToggle(
                      icon: Icons.merge_type,
                      label: 'Auto-create bundles',
                      subtitle: 'AI-powered order bundling',
                      value: s.autoCreateBundles,
                      onChanged: (v) => prov.updateSettings(s.copyWith(autoCreateBundles: v)),
                    ),
                    if (s.autoCreateBundles) ...[
                      const SizedBox(height: 4),
                      _SliderSetting(
                        label: 'Bundle radius',
                        value: s.bundleRadius,
                        min: 0.5,
                        max: 10.0,
                        suffix: 'km',
                        onChanged: (v) => prov.updateSettings(s.copyWith(bundleRadius: v)),
                      ),
                      _SliderSetting(
                        label: 'Min savings threshold',
                        value: s.bundleMinSavings * 100,
                        min: 5.0,
                        max: 50.0,
                        suffix: '%',
                        onChanged: (v) => prov.updateSettings(s.copyWith(bundleMinSavings: v / 100)),
                      ),
                    ],
                    _InfoRow(label: 'Max simultaneous packages', value: '${s.maxSimultaneousPackages}'),
                  ],
                ),
              ),

              // Returns
              LiveSectionCard(
                title: 'RETURN POLICIES',
                icon: Icons.assignment_return,
                iconColor: const Color(0xFF8B5CF6),
                child: Column(
                  children: [
                    _SettingsToggle(
                      icon: Icons.check_circle_outline,
                      label: 'Auto-approve low-value returns',
                      subtitle: 'Skip manual review for small returns',
                      value: s.autoApproveLowValueReturns,
                      onChanged: (v) => prov.updateSettings(s.copyWith(autoApproveLowValueReturns: v)),
                    ),
                    if (s.autoApproveLowValueReturns) ...[
                      const SizedBox(height: 4),
                      _SliderSetting(
                        label: 'Max auto-approve value',
                        value: s.autoApproveMaxValue,
                        min: 10.0,
                        max: 200.0,
                        suffix: '\$',
                        onChanged: (v) => prov.updateSettings(s.copyWith(autoApproveMaxValue: v)),
                      ),
                    ],
                    _InfoRow(label: 'Evidence retention', value: '${s.evidenceRetentionDays} days'),
                  ],
                ),
              ),

              // Verification defaults
              LiveSectionCard(
                title: 'DELIVERY VERIFICATION',
                icon: Icons.verified_user,
                iconColor: const Color(0xFF10B981),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Default verification method', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                    const SizedBox(height: 10),
                    ...DefaultVerification.values.map((method) {
                      final info = _verificationInfo(method);
                      final isSelected = s.defaultVerification == method;
                      return GestureDetector(
                        onTap: () => prov.updateSettings(s.copyWith(defaultVerification: method)),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFD1FAE5) : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isSelected ? const Color(0xFF10B981) : Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Text(info.$1, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(info.$2, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? const Color(0xFF059669) : AppColors.textPrimary)),
                                    Text(info.$3, style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                                  ],
                                ),
                              ),
                              if (isSelected) const Icon(Icons.check_circle, size: 18, color: Color(0xFF10B981)),
                              if (!isSelected) Icon(Icons.radio_button_off, size: 18, color: Colors.grey.shade400),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 6),
                    _SliderSetting(
                      label: 'High-value threshold',
                      value: s.highValueThreshold,
                      min: 100.0,
                      max: 5000.0,
                      suffix: '\$',
                      onChanged: (v) => prov.updateSettings(s.copyWith(highValueThreshold: v)),
                    ),
                  ],
                ),
              ),

              // Driver Policies
              LiveSectionCard(
                title: 'DRIVER POLICIES',
                icon: Icons.local_shipping,
                iconColor: const Color(0xFFEC4899),
                child: Column(
                  children: [
                    _InfoRow(label: 'Break enforcement', value: '${s.breakEnforcementMinutes} min every ${s.breakAfterHours}h'),
                    _InfoRow(label: 'Max simultaneous packages', value: '${s.maxSimultaneousPackages}'),
                  ],
                ),
              ),

              // Performance targets
              LiveSectionCard(
                title: 'PERFORMANCE TARGETS',
                icon: Icons.speed,
                iconColor: kLiveColor,
                child: Column(
                  children: [
                    _SliderSetting(
                      label: 'Fulfillment time target',
                      value: s.fulfillmentTimeTarget,
                      min: 10.0,
                      max: 60.0,
                      suffix: 'min',
                      onChanged: (v) => prov.updateSettings(s.copyWith(fulfillmentTimeTarget: v)),
                    ),
                    _SliderSetting(
                      label: 'Customer rating target',
                      value: s.customerRatingTarget,
                      min: 3.0,
                      max: 5.0,
                      suffix: '★',
                      divisions: 20,
                      onChanged: (v) => prov.updateSettings(s.copyWith(customerRatingTarget: v)),
                    ),
                    _SliderSetting(
                      label: 'On-time delivery target',
                      value: s.onTimeDeliveryTarget * 100,
                      min: 80.0,
                      max: 100.0,
                      suffix: '%',
                      onChanged: (v) => prov.updateSettings(s.copyWith(onTimeDeliveryTarget: v / 100)),
                    ),
                  ],
                ),
              ),

              // Danger zone
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kLiveColor.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('⚠️ DANGER ZONE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: kLiveColor)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Settings reset to defaults'), backgroundColor: kLiveColor),
                          );
                          prov.resetSettings();
                        },
                        icon: const Icon(Icons.restore, size: 16),
                        label: const Text('Reset All Settings', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kLiveColor,
                          side: const BorderSide(color: kLiveColor),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  (String, String, String) _verificationInfo(DefaultVerification method) => switch (method) {
        DefaultVerification.biometricOnly => ('🔐', 'Biometric Only', 'Fingerprint or face verification'),
        DefaultVerification.pinOnly => ('🔑', 'PIN Only', 'Customer enters a delivery PIN'),
        DefaultVerification.biometricAndPin => ('🛡️', 'Biometric + PIN', 'Full multi-factor verification'),
        DefaultVerification.photoSignature => ('📸', 'Photo + Signature', 'Photo proof with digital signature'),
      };
}

class _SettingsToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text(subtitle, style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: kLiveColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

class _SliderSetting extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String suffix;
  final int? divisions;
  final ValueChanged<double> onChanged;

  const _SliderSetting({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.suffix,
    this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: kLiveColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text('${value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1)} $suffix', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kLiveColor)),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: kLiveColor,
              inactiveTrackColor: kLiveColor.withOpacity(0.15),
              thumbColor: kLiveColor,
              overlayColor: kLiveColor.withOpacity(0.1),
              trackHeight: 3,
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions ?? ((max - min) * 2).round(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
            child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
