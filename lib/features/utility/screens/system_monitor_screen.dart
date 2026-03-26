/// ═══════════════════════════════════════════════════════════════════════════
/// U8: SYSTEM MONITOR Screen
/// Performance metrics, device info, active sessions, system logs
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

class SystemMonitorScreen extends StatelessWidget {
  const SystemMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UtilityProvider>(
      builder: (context, prov, _) {
        final metrics = prov.systemMetrics;
        final device = prov.deviceInfo;
        final logs = prov.filteredLogs;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FC),
          appBar: UtilityAppBar(
            title: 'System Monitor',
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, size: 20, color: AppColors.textPrimary),
                onPressed: () => HapticFeedback.mediumImpact(),
                tooltip: 'Refresh',
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
              // ─── Performance Metrics Grid ──────────────────
              const UtilitySectionTitle(
                title: 'Performance',
                icon: Icons.speed,
                iconColor: Color(0xFF3B82F6),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.3,
                ),
                itemCount: metrics.length,
                itemBuilder: (context, i) {
                  final m = metrics[i];
                  return MetricCard(
                    label: m.label,
                    value: m.value,
                    icon: m.icon,
                    color: m.color,
                    percentage: m.percentage,
                    trailing: _TrendIcon(trend: m.trend),
                  );
                },
              ),

              const SizedBox(height: 16),

              // ─── Device Info ───────────────────────────────
              const UtilitySectionTitle(
                title: 'Device Information',
                icon: Icons.phone_android,
                iconColor: Color(0xFF6366F1),
              ),
              UtilitySectionCard(
                child: Column(
                  children: [
                    _InfoRow(label: 'Device', value: device.deviceName),
                    _InfoRow(label: 'OS', value: device.osVersion),
                    _InfoRow(label: 'App Version', value: '${device.appVersion} (${device.buildNumber})'),
                    _InfoRow(label: 'Device ID', value: device.deviceId),
                    _InfoRow(label: 'Screen', value: device.screenResolution),
                    _InfoRow(label: 'Locale', value: device.locale),
                    _InfoRow(label: 'Timezone', value: device.timezone),
                    _InfoRow(label: 'Storage', value: '${device.freeStorageMB.toStringAsFixed(1)} MB free / ${device.totalStorageMB.toStringAsFixed(0)} MB'),
                    _InfoRow(label: 'Memory', value: '${device.totalMemoryMB.toStringAsFixed(0)} MB', isLast: true),
                  ],
                ),
              ),

              // ─── Active Sessions ──────────────────────────
              const UtilitySectionTitle(
                title: 'Active Sessions',
                icon: Icons.devices,
                iconColor: Color(0xFF10B981),
              ),
              ...prov.activeSessions.map((session) => _SessionCard(
                session: session,
                onTerminate: session.isCurrent
                    ? null
                    : () => _confirmTerminate(context, prov, session),
              )),

              const SizedBox(height: 16),

              // ─── System Logs ──────────────────────────────
              const UtilitySectionTitle(
                title: 'System Logs',
                icon: Icons.terminal,
                iconColor: Color(0xFF64748B),
              ),

              // Log level filters
              SizedBox(
                height: 32,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _LogFilterChip(
                      label: 'All',
                      isSelected: prov.logFilter == null,
                      onTap: () => prov.setLogFilter(null),
                    ),
                    ...LogLevel.values.map((level) => Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: _LogFilterChip(
                        label: level.name.toUpperCase(),
                        isSelected: prov.logFilter == level,
                        color: _logLevelColor(level),
                        onTap: () => prov.setLogFilter(level),
                      ),
                    )),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              if (logs.isEmpty)
                const UtilityEmptyState(
                  icon: Icons.terminal,
                  title: 'No Logs',
                  subtitle: 'No system logs match the selected filter.',
                )
              else
                UtilitySectionCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: logs.map((log) {
                      final isLast = log == logs.last;
                      return Column(
                        children: [
                          _LogRow(entry: log),
                          if (!isLast) Divider(height: 1, color: AppColors.inputBorder.withOpacity(0.5)),
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

  Color _logLevelColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug: return const Color(0xFF9CA3AF);
      case LogLevel.info: return const Color(0xFF3B82F6);
      case LogLevel.warning: return const Color(0xFFF59E0B);
      case LogLevel.error: return const Color(0xFFEF4444);
      case LogLevel.critical: return const Color(0xFF7C3AED);
    }
  }

  void _confirmTerminate(BuildContext context, UtilityProvider prov, ActiveSession session) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('End Session?'),
        content: Text('This will sign out "${session.deviceName}" at ${session.location}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              prov.terminateSession(session.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }
}

// ─── Trend Icon ──────────────────────────────────────────────────────────────

class _TrendIcon extends StatelessWidget {
  final MetricTrend trend;
  const _TrendIcon({required this.trend});

  @override
  Widget build(BuildContext context) {
    switch (trend) {
      case MetricTrend.up:
        return const Icon(Icons.trending_up, size: 14, color: Color(0xFFEF4444));
      case MetricTrend.down:
        return const Icon(Icons.trending_down, size: 14, color: Color(0xFF10B981));
      case MetricTrend.stable:
        return const Icon(Icons.trending_flat, size: 14, color: AppColors.textTertiary);
    }
  }
}

// ─── Info Row ────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textTertiary)),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: AppColors.inputBorder.withOpacity(0.5)),
      ],
    );
  }
}

// ─── Session Card ────────────────────────────────────────────────────────────

class _SessionCard extends StatelessWidget {
  final ActiveSession session;
  final VoidCallback? onTerminate;

  const _SessionCard({required this.session, this.onTerminate});

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
                color: (session.isCurrent ? const Color(0xFF10B981) : const Color(0xFF3B82F6)).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                session.deviceName.contains('Chrome') ? Icons.computer : Icons.phone_android,
                size: 20,
                color: session.isCurrent ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        session.deviceName,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      if (session.isCurrent) ...[
                        const SizedBox(width: 6),
                        const UtilityStatusIndicator(label: 'Current', color: Color(0xFF10B981)),
                      ],
                    ],
                  ),
                  Text(
                    '${session.location} · ${session.ipAddress}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
            if (onTerminate != null)
              TextButton(
                onPressed: onTerminate,
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('End', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Log Filter Chip ─────────────────────────────────────────────────────────

class _LogFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _LogFilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? kUtilityColor;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? chipColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? chipColor : AppColors.inputBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? chipColor : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}

// ─── Log Row ─────────────────────────────────────────────────────────────────

class _LogRow extends StatelessWidget {
  final SystemLogEntry entry;
  const _LogRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: entry.levelColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.message,
                  style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                ),
                Text(
                  '${entry.source} · ${_formatTime(entry.timestamp)}',
                  style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          Text(
            entry.level.name.toUpperCase(),
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: entry.levelColor),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}
