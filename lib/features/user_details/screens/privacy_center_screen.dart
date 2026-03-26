/// ═══════════════════════════════════════════════════════════════════════════
/// Screen 6: Privacy Control Center
/// Data map visualization, control toggles, transparency panel
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../models/user_details_models.dart';
import '../providers/user_details_provider.dart';
import '../widgets/shared_widgets.dart';

class PrivacyCenterScreen extends StatelessWidget {
  const PrivacyCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDetailsProvider>(
      builder: (context, udp, _) {
        final privacy = udp.privacy;
        final categories = udp.dataCategories;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FC),
          appBar: const ModuleHeader(
            title: 'Privacy Center',
            contextColor: Color(0xFF8B5CF6),
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
              // ─── Privacy Score ──────────────────────────────
              _PrivacyScoreCard(score: privacy.privacyScore),

              const SizedBox(height: 16),

              // ─── Data Map ──────────────────────────────────
              SectionCard(
                child: CollapsibleSection(
                  title: 'Your Data Map',
                  icon: Icons.bubble_chart,
                  iconColor: const Color(0xFF8B5CF6),
                  child: _DataMap(categories: categories),
                ),
              ),

              // ─── Profile Visibility ────────────────────────
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Profile Visibility', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 10),
                    ...ProfileVisibility.values.map((v) => _RadioOption<ProfileVisibility>(
                          value: v,
                          groupValue: privacy.profileVisibility,
                          label: v.label,
                          icon: v == ProfileVisibility.everyone
                              ? Icons.public
                              : v == ProfileVisibility.contactsOnly
                                  ? Icons.people
                                  : Icons.lock,
                          onChanged: (val) {
                            if (val != null) udp.setProfileVisibility(val);
                          },
                        )),
                  ],
                ),
              ),

              // ─── Data Sharing ──────────────────────────────
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Data Sharing Level', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 10),
                    ...DataSharingLevel.values.map((v) => _RadioOption<DataSharingLevel>(
                          value: v,
                          groupValue: privacy.dataSharingLevel,
                          label: v.label,
                          icon: Icons.share,
                          onChanged: (val) {
                            if (val != null) udp.setDataSharing(val);
                          },
                        )),
                  ],
                ),
              ),

              // ─── Location Tracking ─────────────────────────
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Location Tracking', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 10),
                    ...LocationTracking.values.map((v) => _RadioOption<LocationTracking>(
                          value: v,
                          groupValue: privacy.locationTracking,
                          label: v.label,
                          icon: v == LocationTracking.always
                              ? Icons.location_on
                              : v == LocationTracking.whileUsingApp
                                  ? Icons.location_searching
                                  : Icons.location_off,
                          onChanged: (val) {
                            if (val != null) udp.setLocationTracking(val);
                          },
                        )),
                  ],
                ),
              ),

              // ─── Toggles ──────────────────────────────────
              SectionCard(
                child: Column(
                  children: [
                    SettingsToggle(
                      icon: Icons.contacts,
                      label: 'Contact Sync',
                      subtitle: 'Sync phone contacts with app',
                      value: privacy.contactSyncEnabled,
                      onChanged: (v) => udp.toggleContactSync(v),
                      activeColor: const Color(0xFF8B5CF6),
                    ),
                    const Divider(height: 1),
                    SettingsToggle(
                      icon: Icons.analytics_outlined,
                      label: 'Usage Analytics',
                      subtitle: 'Help improve the app with anonymized data',
                      value: privacy.usageAnalyticsEnabled,
                      onChanged: (v) => udp.toggleAnalytics(v),
                      activeColor: const Color(0xFF8B5CF6),
                    ),
                  ],
                ),
              ),

              // ─── Data Export ────────────────────────────────
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.download_outlined, size: 18, color: Color(0xFF3B82F6)),
                        const SizedBox(width: 8),
                        const Text('Data Export', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (privacy.lastDataExport != null)
                      Text(
                        'Last export: ${_formatDate(privacy.lastDataExport!)}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                      ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          udp.requestDataExport();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Data export initiated. You\'ll receive it via email.')),
                          );
                        },
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('Request Data Export (GDPR)'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF3B82F6),
                          side: const BorderSide(color: Color(0xFF3B82F6)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Account Deletion ──────────────────────────
              SectionCard(
                borderColor: const Color(0xFFEF4444).withOpacity(0.15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.delete_forever, size: 18, color: Color(0xFFEF4444)),
                        SizedBox(width: 8),
                        Text('Delete Account', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Permanently delete your account and all associated data. This cannot be undone.',
                      style: TextStyle(fontSize: 12, color: AppColors.textTertiary, height: 1.4),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _showDeleteConfirmation(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          side: const BorderSide(color: Color(0xFFEF4444)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Delete My Account'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Account?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
          'This will permanently delete all your data across all contexts. This action cannot be reversed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Privacy Score Card
// ═══════════════════════════════════════════════════════════════════════════

class _PrivacyScoreCard extends StatelessWidget {
  final int score;
  const _PrivacyScoreCard({required this.score});

  @override
  Widget build(BuildContext context) {
    final color = score >= 80
        ? const Color(0xFF10B981)
        : score >= 50
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);

    return SectionCard(
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                Text(
                  '$score',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Privacy Score', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(
                  score >= 80 ? 'Your privacy is well protected' : 'Consider improving your privacy settings',
                  style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Data Map Visualization
// ═══════════════════════════════════════════════════════════════════════════

class _DataMap extends StatelessWidget {
  final List<DataCategory> categories;
  const _DataMap({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: categories.map((cat) => _DataBubble(category: cat)).toList(),
        ),
        const SizedBox(height: 16),
        ...categories.map((cat) => _DataCategoryDetail(category: cat)),
      ],
    );
  }
}

class _DataBubble extends StatelessWidget {
  final DataCategory category;
  const _DataBubble({required this.category});

  @override
  Widget build(BuildContext context) {
    final size = 40 + (category.relativeSize * 14);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _showDataDetail(context, category);
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: category.color.withOpacity(0.15),
          border: Border.all(color: category.color.withOpacity(0.3), width: 1.5),
        ),
        child: Center(
          child: Text(
            category.name.split(' ').map((w) => w[0]).join(),
            style: TextStyle(
              fontSize: size > 70 ? 14 : 10,
              fontWeight: FontWeight.w700,
              color: category.color,
            ),
          ),
        ),
      ),
    );
  }

  void _showDataDetail(BuildContext context, DataCategory cat) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.inputBorder, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            Text(cat.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cat.color)),
            const SizedBox(height: 8),
            DetailRow(icon: Icons.info_outline, label: 'Description', value: cat.description),
            DetailRow(icon: Icons.flag, label: 'Purpose', value: cat.purpose),
            DetailRow(icon: Icons.visibility, label: 'Who can see', value: cat.visibility),
            DetailRow(icon: Icons.timer, label: 'Retention', value: cat.retention),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _DataCategoryDetail extends StatelessWidget {
  final DataCategory category;
  const _DataCategoryDetail({required this.category});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: category.color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(category.name, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ),
          Text(category.retention, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Radio Option
// ═══════════════════════════════════════════════════════════════════════════

class _RadioOption<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final String label;
  final IconData icon;
  final ValueChanged<T?> onChanged;

  const _RadioOption({
    required this.value,
    required this.groupValue,
    required this.label,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(value);
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: selected ? const Color(0xFF8B5CF6) : AppColors.textTertiary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? const Color(0xFF8B5CF6) : AppColors.textPrimary,
                ),
              ),
            ),
            Radio<T>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: const Color(0xFF8B5CF6),
            ),
          ],
        ),
      ),
    );
  }
}
