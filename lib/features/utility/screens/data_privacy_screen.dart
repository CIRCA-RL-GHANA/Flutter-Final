/// ═══════════════════════════════════════════════════════════════════════════
/// U5: DATA & PRIVACY Screen
/// Privacy toggles, data storage breakdown, connected apps, data export,
/// account deletion
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../models/utility_models.dart';
import '../providers/utility_provider.dart';
import '../widgets/shared_widgets.dart';

class DataPrivacyScreen extends StatelessWidget {
  const DataPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UtilityProvider>(
      builder: (context, prov, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FC),
          appBar: const UtilityAppBar(title: 'Data & Privacy'),
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
              // ─── Privacy Score Banner ──────────────────────
              _PrivacyScoreBanner(settings: prov.privacySettings),

              const SizedBox(height: 16),

              // ─── Privacy Controls ─────────────────────────
              const UtilitySectionTitle(
                title: 'Privacy Controls',
                icon: Icons.privacy_tip_outlined,
                iconColor: Color(0xFF8B5CF6),
              ),
              UtilitySectionCard(
                child: Column(
                  children: prov.privacySettings.map((setting) {
                    final isLast = setting == prov.privacySettings.last;
                    return Column(
                      children: [
                        UtilityToggleTile(
                          label: setting.label,
                          subtitle: setting.description,
                          icon: setting.icon,
                          activeColor: const Color(0xFF8B5CF6),
                          value: setting.enabled,
                          onChanged: (_) => prov.togglePrivacySetting(setting.id),
                        ),
                        if (!isLast) const Divider(height: 1),
                      ],
                    );
                  }).toList(),
                ),
              ),

              // ─── Data Usage ───────────────────────────────
              const UtilitySectionTitle(
                title: 'Data Usage',
                icon: Icons.pie_chart_outline,
                iconColor: Color(0xFF3B82F6),
              ),
              UtilitySectionCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        PercentageRing(
                          percentage: prov.totalDataMB / 50.0,
                          color: const Color(0xFF3B82F6),
                          size: 56,
                          label: '${prov.totalDataMB.toStringAsFixed(1)}',
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Data Usage',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              ),
                              Text(
                                '${prov.totalDataMB.toStringAsFixed(1)} MB of 50.0 MB used',
                                style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...prov.dataCategories.map((cat) => _DataCategoryRow(category: cat, total: prov.totalDataMB)),
                  ],
                ),
              ),

              // ─── Connected Apps ───────────────────────────
              const UtilitySectionTitle(
                title: 'Connected Apps',
                icon: Icons.apps,
                iconColor: Color(0xFF10B981),
              ),
              if (prov.connectedApps.isEmpty)
                const UtilitySectionCard(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No connected apps',
                      style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
                    ),
                  ),
                )
              else
                ...prov.connectedApps.map((app) => _ConnectedAppCard(
                  app: app,
                  onRevoke: () => _confirmRevoke(context, prov, app),
                )),

              // ─── Data Export ───────────────────────────────
              const UtilitySectionTitle(
                title: 'Data Export',
                icon: Icons.download,
                iconColor: Color(0xFFF59E0B),
              ),
              UtilitySectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Download a copy of your data in your preferred format.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: DataExportFormat.values.map((fmt) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: fmt != DataExportFormat.values.last ? 8 : 0,
                          ),
                          child: OutlinedButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              prov.requestExport(fmt);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFF59E0B),
                              side: const BorderSide(color: Color(0xFFF59E0B)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(fmt.name.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      )).toList(),
                    ),
                    if (prov.exportRequests.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ...prov.exportRequests.map((req) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(
                              req.status == DataExportStatus.ready ? Icons.check_circle : Icons.hourglass_top,
                              size: 14,
                              color: req.status == DataExportStatus.ready ? AppColors.success : AppColors.warning,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${req.format.name.toUpperCase()} · ${_exportStatusLabel(req.status)}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            if (req.fileSizeMB != null) ...[
                              const Spacer(),
                              Text('${req.fileSizeMB!.toStringAsFixed(1)} MB', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                            ],
                          ],
                        ),
                      )),
                    ],
                  ],
                ),
              ),

              // ─── Danger Zone ──────────────────────────────
              const UtilitySectionTitle(
                title: 'Danger Zone',
                icon: Icons.warning_amber,
                iconColor: Color(0xFFEF4444),
              ),
              UtilitySectionCard(
                borderColor: const Color(0xFFEF4444).withOpacity(0.2),
                child: UtilityActionTile(
                  label: 'Delete Account',
                  subtitle: 'Permanently remove all your data',
                  icon: Icons.delete_forever,
                  iconColor: const Color(0xFFEF4444),
                  onTap: () => _showDeleteConfirmation(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _exportStatusLabel(DataExportStatus s) {
    switch (s) {
      case DataExportStatus.pending: return 'Pending';
      case DataExportStatus.processing: return 'Processing...';
      case DataExportStatus.ready: return 'Ready to download';
      case DataExportStatus.expired: return 'Expired';
      case DataExportStatus.failed: return 'Failed';
    }
  }

  void _confirmRevoke(BuildContext context, UtilityProvider prov, ConnectedApp app) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Revoke ${app.name}?'),
        content: Text('This will disconnect ${app.name} and remove its access to your account.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              prov.revokeApp(app.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text('This action is irreversible. All your data, contexts, and settings will be permanently deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }
}

// ─── Privacy Score Banner ────────────────────────────────────────────────────

class _PrivacyScoreBanner extends StatelessWidget {
  final List<PrivacySetting> settings;
  const _PrivacyScoreBanner({required this.settings});

  @override
  Widget build(BuildContext context) {
    final strictCount = settings.where((s) => !s.enabled || s.level == PrivacyLevel.strict || s.level == PrivacyLevel.maximum).length;
    final score = settings.isNotEmpty ? strictCount / settings.length : 0.0;
    final color = score >= 0.6
        ? const Color(0xFF10B981)
        : score >= 0.3
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.08), color.withOpacity(0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          PercentageRing(percentage: score, color: color, size: 56),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy Score',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color),
                ),
                const SizedBox(height: 2),
                Text(
                  score >= 0.6
                      ? 'Your privacy settings are strong'
                      : 'Consider tightening your privacy controls',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data Category Row ───────────────────────────────────────────────────────

class _DataCategoryRow extends StatelessWidget {
  final DataCategory category;
  final double total;

  const _DataCategoryRow({required this.category, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(category.icon, size: 16, color: category.color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              category.name,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            ),
          ),
          Text(
            '${category.sizeMB.toStringAsFixed(1)} MB',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: total > 0 ? category.sizeMB / total : 0,
                backgroundColor: category.color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation(category.color),
                minHeight: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Connected App Card ──────────────────────────────────────────────────────

class _ConnectedAppCard extends StatelessWidget {
  final ConnectedApp app;
  final VoidCallback onRevoke;

  const _ConnectedAppCard({required this.app, required this.onRevoke});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: UtilitySectionCard(
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(app.icon, size: 22, color: const Color(0xFF10B981)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        app.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      const SizedBox(width: 6),
                      UtilityStatusIndicator(
                        label: app.isActive ? 'Active' : 'Inactive',
                        color: app.isActive ? AppColors.success : AppColors.textTertiary,
                      ),
                    ],
                  ),
                  Text(
                    app.permissions.join(' · '),
                    style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onRevoke,
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Revoke', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
