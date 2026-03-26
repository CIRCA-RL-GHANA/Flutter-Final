/// ═══════════════════════════════════════════════════════════════════════════
/// U7: ADVANCED DATA TOOLS Screen
/// Storage analytics, backup management, cache control, sync status
/// RBAC: Owner, Administrator, BranchManager only
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../models/utility_models.dart';
import '../providers/utility_provider.dart';
import '../widgets/shared_widgets.dart';

class AdvancedDataScreen extends StatelessWidget {
  const AdvancedDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UtilityProvider>(
      builder: (context, prov, _) {
        final storage = prov.storageAnalytics;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FC),
          appBar: const UtilityAppBar(title: 'Advanced Data'),
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
              // ─── Storage Overview ─────────────────────────
              const UtilitySectionTitle(
                title: 'Storage Overview',
                icon: Icons.sd_storage,
                iconColor: Color(0xFF8B5CF6),
              ),
              UtilitySectionCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        PercentageRing(
                          percentage: storage.usedPercentage,
                          color: storage.usedPercentage > 0.8
                              ? AppColors.error
                              : storage.usedPercentage > 0.6
                                  ? AppColors.warning
                                  : const Color(0xFF8B5CF6),
                          size: 64,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${storage.usedMB.toStringAsFixed(1)} MB used',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              ),
                              Text(
                                'of ${storage.totalMB.toStringAsFixed(0)} MB total · ${(storage.freePercentage * 100).toStringAsFixed(0)}% free',
                                style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Breakdown
                    ...storage.breakdown.map((cat) => _StorageBreakdownRow(
                      category: cat,
                      total: storage.usedMB,
                    )),
                  ],
                ),
              ),

              // ─── Backup Management ────────────────────────
              const UtilitySectionTitle(
                title: 'Backups',
                icon: Icons.backup,
                iconColor: Color(0xFF10B981),
              ),
              UtilitySectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Create a backup of all your data',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            prov.createBackup();
                          },
                          icon: const Icon(Icons.backup, size: 16),
                          label: const Text('Backup Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                    if (prov.backups.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      ...prov.backups.map((backup) => _BackupRow(backup: backup)),
                    ],
                  ],
                ),
              ),

              // ─── Cache Management ─────────────────────────
              const UtilitySectionTitle(
                title: 'Cache',
                icon: Icons.cached,
                iconColor: Color(0xFFF59E0B),
              ),
              UtilitySectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${prov.totalCacheMB.toStringAsFixed(1)} MB cached',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              ),
                              Text(
                                '${prov.cacheInfo.fold<int>(0, (sum, c) => sum + c.itemCount)} items total',
                                style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            prov.clearCache();
                          },
                          icon: const Icon(Icons.delete_sweep, size: 16),
                          label: const Text('Clear All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFF59E0B),
                            side: const BorderSide(color: Color(0xFFF59E0B)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...prov.cacheInfo.map((cache) => _CacheRow(cache: cache)),
                  ],
                ),
              ),

              // ─── Sync Status ──────────────────────────────
              const UtilitySectionTitle(
                title: 'Sync Status',
                icon: Icons.sync,
                iconColor: Color(0xFF3B82F6),
              ),
              UtilitySectionCard(
                child: Column(
                  children: prov.syncStatuses.map((sync) {
                    final isLast = sync == prov.syncStatuses.last;
                    return Column(
                      children: [
                        _SyncRow(sync: sync),
                        if (!isLast) const Divider(height: 1),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Storage Breakdown Row ───────────────────────────────────────────────────

class _StorageBreakdownRow extends StatelessWidget {
  final DataCategory category;
  final double total;

  const _StorageBreakdownRow({required this.category, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(category.icon, size: 14, color: category.color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                Text('${category.itemCount} items', style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
              ],
            ),
          ),
          Text(
            '${category.sizeMB.toStringAsFixed(1)} MB',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
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

// ─── Backup Row ──────────────────────────────────────────────────────────────

class _BackupRow extends StatelessWidget {
  final DataBackup backup;
  const _BackupRow({required this.backup});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            backup.status == BackupStatus.completed
                ? Icons.check_circle
                : backup.status == BackupStatus.inProgress
                    ? Icons.hourglass_top
                    : Icons.error,
            size: 18,
            color: backup.status == BackupStatus.completed
                ? AppColors.success
                : backup.status == BackupStatus.inProgress
                    ? AppColors.warning
                    : AppColors.error,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  backup.description ?? '${backup.type.name} backup',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                ),
                Text(
                  _formatDate(backup.createdAt),
                  style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          Text(
            '${backup.sizeMB.toStringAsFixed(1)} MB',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ─── Cache Row ───────────────────────────────────────────────────────────────

class _CacheRow extends StatelessWidget {
  final CacheInfo cache;
  const _CacheRow({required this.cache});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(cache.icon, size: 16, color: const Color(0xFFF59E0B)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(cache.category, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          ),
          Text(
            '${cache.sizeMB.toStringAsFixed(1)} MB · ${cache.itemCount} items',
            style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

// ─── Sync Row ────────────────────────────────────────────────────────────────

class _SyncRow extends StatelessWidget {
  final SyncStatus sync;
  const _SyncRow({required this.sync});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _syncColor(sync.state).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(sync.icon, size: 16, color: _syncColor(sync.state)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sync.module, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                Text(
                  sync.pendingItems > 0 ? '${sync.pendingItems} pending' : 'Up to date',
                  style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          UtilityStatusIndicator(
            label: _syncLabel(sync.state),
            color: _syncColor(sync.state),
          ),
        ],
      ),
    );
  }

  String _syncLabel(SyncState s) {
    switch (s) {
      case SyncState.synced: return 'Synced';
      case SyncState.syncing: return 'Syncing';
      case SyncState.error: return 'Error';
      case SyncState.offline: return 'Offline';
      case SyncState.pending: return 'Pending';
    }
  }

  Color _syncColor(SyncState s) {
    switch (s) {
      case SyncState.synced: return const Color(0xFF10B981);
      case SyncState.syncing: return const Color(0xFF3B82F6);
      case SyncState.error: return const Color(0xFFEF4444);
      case SyncState.offline: return const Color(0xFF64748B);
      case SyncState.pending: return const Color(0xFFF59E0B);
    }
  }
}
