/// ═══════════════════════════════════════════════════════════════════════════
/// SD2.1: AUDIT LOG — Activity & Compliance Tracking
/// Filterable audit trail, action types, outcomes, user tracking
/// RBAC: Owner(personal), Admin(full), BM(branch), Monitor/BrMon(view),
///        RO/BRO(view)
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../prompt/providers/context_provider.dart';
import '../models/setup_dashboard_models.dart';
import '../providers/setup_dashboard_provider.dart';
import '../widgets/shared_widgets.dart';

class AuditScreen extends StatelessWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        final entries = setupProv.filteredAuditEntries;

        return SetupRbacGate(
          cardId: 'audit',
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FC),
            appBar: SetupAppBar(
              title: 'Activity Log',
              actions: [
                DataScopeIndicator(access: setupProv.getCardAccess('audit', ctxProv.currentRole)),
                SizedBox(width: 16),
              ],
            ),
          body: CustomScrollView(
            slivers: [
              // ─── KPI Summary ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: KPIBadge(
                          label: "Today's Actions",
                          value: '${setupProv.filteredAuditEntries.where((e) => e.timestamp.day == DateTime.now().day && e.timestamp.month == DateTime.now().month).length}',
                          icon: Icons.bolt,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: KPIBadge(
                          label: 'Success Rate',
                          value: entries.isEmpty
                              ? '—'
                              : '${(entries.where((e) => e.outcome == AuditOutcome.success).length * 100 / entries.length).round()}%',
                          icon: Icons.check_circle,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: KPIBadge(
                          label: 'Suspicious',
                          value: '${entries.where((e) => e.outcome == AuditOutcome.suspicious).length}',
                          icon: Icons.warning_amber,
                          color: entries.where((e) => e.outcome == AuditOutcome.suspicious).isNotEmpty
                              ? AppColors.warning
                              : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Filter Chips ─────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SetupFilterChipRow(
                    labels: const ['All', 'Success', 'Failure', 'Suspicious'],
                    selectedIndex: _filterIndex(setupProv.auditFilter),
                    onSelected: (i) {
                      final filters = ['all', 'success', 'failure', 'suspicious'];
                      setupProv.setAuditFilter(filters[i]);
                    },
                  ),
                ),
              ),

              // ─── Action Type Filter ───────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _ActionTypeChip(label: 'All', icon: Icons.apps, isSelected: true),
                        const SizedBox(width: 6),
                        _ActionTypeChip(label: 'Create', icon: Icons.add_circle, color: AppColors.success),
                        const SizedBox(width: 6),
                        _ActionTypeChip(label: 'Update', icon: Icons.edit, color: kSetupColor),
                        const SizedBox(width: 6),
                        _ActionTypeChip(label: 'Delete', icon: Icons.delete, color: AppColors.error),
                        const SizedBox(width: 6),
                        _ActionTypeChip(label: 'Login', icon: Icons.login, color: const Color(0xFF8B5CF6)),
                        const SizedBox(width: 6),
                        _ActionTypeChip(label: 'Export', icon: Icons.download, color: const Color(0xFF6366F1)),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── Anomaly Alert ────────────────────────────
              if (entries.where((e) => e.outcome == AuditOutcome.suspicious).isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.shield, size: 18, color: AppColors.warning),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Anomaly Detected',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.warning),
                                ),
                                Text(
                                  '${entries.where((e) => e.outcome == AuditOutcome.suspicious).length} suspicious activities flagged — review recommended',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 18, color: AppColors.warning),
                        ],
                      ),
                    ),
                  ),
                ),

              // ─── Audit List ───────────────────────────────
              if (entries.isEmpty)
                const SliverFillRemaining(
                  child: SetupEmptyState(
                    icon: Icons.history,
                    title: 'No audit entries',
                    subtitle: 'No entries match the selected filter.',
                  ),
                )
              else
              // ─── AI Insights ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Consumer<AIInsightsNotifier>(
                  builder: (context, ai, _) {
                    if (ai.insights.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: kSetupColor.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome, size: 14, color: kSetupColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'AI: ${ai.insights.first['title'] ?? ''}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kSetupColor),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _AuditEntryCard(entry: entries[i]),
                      childCount: entries.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
        );
      },
    );
  }

  int _filterIndex(String filter) {
    switch (filter) {
      case 'success':
        return 1;
      case 'failure':
        return 2;
      case 'suspicious':
        return 3;
      default:
        return 0;
    }
  }
}

// ─── Audit Entry Card ────────────────────────────────────────────────────────

class _AuditEntryCard extends StatelessWidget {
  final AuditEntry entry;
  const _AuditEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: entry.outcome == AuditOutcome.suspicious
            ? Border.all(color: AppColors.warning.withOpacity(0.3))
            : entry.outcome == AuditOutcome.failure
                ? Border.all(color: AppColors.error.withOpacity(0.3))
                : null,
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
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _actionColor(entry.action).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _actionIcon(entry.action),
                  size: 18,
                  color: _actionColor(entry.action),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.description,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${entry.userName} · ${entry.userRole}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              SetupStatusIndicator(
                label: entry.outcome.name,
                color: _outcomeColor(entry.outcome),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 12, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(
                setupTimeAgo(entry.timestamp),
                style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
              ),
              if (entry.ipAddress != null) ...[
                const SizedBox(width: 12),
                const Icon(Icons.location_on, size: 12, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(
                  entry.ipAddress!,
                  style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                ),
              ],
              if (entry.deviceInfo != null) ...[
                const SizedBox(width: 12),
                const Icon(Icons.devices, size: 12, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    entry.deviceInfo!,
                    style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  IconData _actionIcon(AuditAction action) {
    switch (action) {
      case AuditAction.create:
        return Icons.add_circle;
      case AuditAction.read:
        return Icons.visibility;
      case AuditAction.update:
        return Icons.edit;
      case AuditAction.delete:
        return Icons.delete;
      case AuditAction.login:
        return Icons.login;
      case AuditAction.export:
        return Icons.download;
      case AuditAction.import_:
        return Icons.upload;
    }
  }

  Color _actionColor(AuditAction action) {
    switch (action) {
      case AuditAction.create:
        return AppColors.success;
      case AuditAction.read:
        return AppColors.info;
      case AuditAction.update:
        return kSetupColor;
      case AuditAction.delete:
        return AppColors.error;
      case AuditAction.login:
        return const Color(0xFF8B5CF6);
      case AuditAction.export:
        return const Color(0xFF6366F1);
      case AuditAction.import_:
        return const Color(0xFF6366F1);
    }
  }

  Color _outcomeColor(AuditOutcome outcome) {
    switch (outcome) {
      case AuditOutcome.success:
        return AppColors.success;
      case AuditOutcome.failure:
        return AppColors.error;
      case AuditOutcome.suspicious:
        return AppColors.warning;
    }
  }
}

// ─── Action Type Chip ────────────────────────────────────────────────────────

class _ActionTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;
  final bool isSelected;

  const _ActionTypeChip({
    required this.label,
    required this.icon,
    this.color,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.textTertiary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? chipColor.withOpacity(0.12) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? chipColor.withOpacity(0.4) : AppColors.inputBorder,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isSelected ? chipColor : AppColors.textTertiary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? chipColor : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
