/// ═══════════════════════════════════════════════════════════════════════════
/// Screen 9: Activity & Audit Log
/// Timeline, filter matrix, export, anomaly highlighting
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../models/user_details_models.dart';
import '../providers/user_details_provider.dart';
import '../widgets/shared_widgets.dart';

class AuditLogScreen extends StatelessWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDetailsProvider>(
      builder: (context, udp, _) {
        final entries = udp.filteredAuditLog;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FC),
          appBar: ModuleHeader(
            title: 'Activity Log',
            contextColor: const Color(0xFF3B82F6),
            actions: [
              IconButton(
                icon: const Icon(Icons.file_download_outlined, size: 20),
                color: AppColors.textPrimary,
                onPressed: () => _showExportOptions(context),
              ),
            ],
          ),
          body: Column(
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

              // ─── Time Filter ─────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: AuditTimeFilter.values
                        .where((f) => f != AuditTimeFilter.custom)
                        .map((f) {
                      final selected = udp.auditTimeFilter == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            f.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                          selected: selected,
                          onSelected: (_) {
                            HapticFeedback.selectionClick();
                            udp.setAuditTimeFilter(f);
                          },
                          selectedColor: const Color(0xFF3B82F6),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          visualDensity: VisualDensity.compact,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // ─── Action Filters ──────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: AuditAction.values.map((action) {
                      final selected = udp.auditActionFilter.contains(action);
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          label: Text(
                            action.label,
                            style: TextStyle(
                              fontSize: 10,
                              color: selected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                          selected: selected,
                          onSelected: (_) {
                            HapticFeedback.selectionClick();
                            udp.toggleAuditActionFilter(action);
                          },
                          selectedColor: const Color(0xFF3B82F6),
                          backgroundColor: Colors.white,
                          checkmarkColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // ─── Module Filter ───────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Row(
                  children: [
                    const Icon(Icons.filter_list, size: 16, color: AppColors.textTertiary),
                    const SizedBox(width: 6),
                    const Text('Module: ', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                    Expanded(
                      child: SizedBox(
                        height: 28,
                        child: DropdownButtonFormField<String?>(
                          value: udp.auditModuleFilter,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                          hint: const Text('All', style: TextStyle(fontSize: 12)),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All Modules')),
                            ...['USER DETAILS', 'GO PAGE', 'MARKET', 'ALERTS', 'LIVE', 'qualChat', 'SETUP DASHBOARD']
                                .map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 12)))),
                          ],
                          onChanged: (v) => udp.setAuditModuleFilter(v),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Results Count ───────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                child: Row(
                  children: [
                    Text(
                      '${entries.length} ${entries.length == 1 ? "entry" : "entries"}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    if (udp.auditActionFilter.isNotEmpty || udp.auditModuleFilter != null)
                      GestureDetector(
                        onTap: () {
                          // Clear all filters
                          for (final a in udp.auditActionFilter.toList()) {
                            udp.toggleAuditActionFilter(a);
                          }
                          udp.setAuditModuleFilter(null);
                        },
                        child: const Text(
                          'Clear Filters',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF3B82F6)),
                        ),
                      ),
                  ],
                ),
              ),

              // ─── Timeline ────────────────────────────────
              Expanded(
                child: entries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.history, size: 48, color: AppColors.textTertiary.withOpacity(0.4)),
                            const SizedBox(height: 12),
                            const Text('No activity found', style: TextStyle(color: AppColors.textTertiary)),
                            const Text('Try adjusting filters', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                        itemCount: entries.length,
                        itemBuilder: (_, i) {
                          final entry = entries[i];
                          final isFirst = i == 0;
                          final isLast = i == entries.length - 1;

                          // Group by day
                          final showDayHeader = isFirst ||
                              !_sameDay(entry.timestamp, entries[i - 1].timestamp);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (showDayHeader)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                                  child: Text(
                                    _formatDayHeader(entry.timestamp),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              _TimelineEntry(entry: entry, isLast: isLast),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDayHeader(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);

    if (date == today) return 'Today';
    if (date == today.subtract(const Duration(days: 1))) return 'Yesterday';

    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  void _showExportOptions(BuildContext context) {
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
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(color: AppColors.inputBorder, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Export Activity Log', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            ...AuditExportFormat.values.map((fmt) => _ExportOption(
                  format: fmt,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Exporting as ${fmt.name.toUpperCase()}...')),
                    );
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Timeline Entry
// ═══════════════════════════════════════════════════════════════════════════

class _TimelineEntry extends StatelessWidget {
  final AuditLogEntry entry;
  final bool isLast;
  const _TimelineEntry({required this.entry, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final hasAnomaly = entry.anomaly != null;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline rail
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: entry.actionColor.withOpacity(0.15),
                    border: hasAnomaly
                        ? Border.all(color: entry.actionColor, width: 2)
                        : null,
                  ),
                  child: Icon(entry.actionIcon, size: 12, color: entry.actionColor),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: Colors.grey.withOpacity(0.15),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasAnomaly ? entry.actionColor.withOpacity(0.04) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: hasAnomaly
                    ? Border.all(color: entry.actionColor.withOpacity(0.2))
                    : null,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 1)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.description,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: hasAnomaly ? entry.actionColor : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (hasAnomaly)
                        Icon(
                          entry.anomaly == AuditAnomaly.securityConcern
                              ? Icons.error
                              : Icons.warning_amber,
                          size: 16,
                          color: entry.actionColor,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _MetaTag(
                        icon: Icons.access_time,
                        label: _formatTime(entry.timestamp),
                      ),
                      if (entry.contextName != null)
                        _MetaTag(icon: Icons.swap_horiz, label: entry.contextName!),
                      if (entry.moduleName != null)
                        _MetaTag(icon: Icons.apps, label: entry.moduleName!),
                      if (entry.deviceName != null)
                        _MetaTag(icon: Icons.devices, label: entry.deviceName!),
                      if (entry.location != null)
                        _MetaTag(icon: Icons.location_on, label: entry.location!),
                    ],
                  ),
                  if (hasAnomaly) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: entry.actionColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        entry.anomaly == AuditAnomaly.securityConcern
                            ? '⚠ Security Concern'
                            : '⚡ Unusual Activity',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: entry.actionColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final p = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $p';
  }
}

class _MetaTag extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: AppColors.textTertiary),
        const SizedBox(width: 3),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Export Option
// ═══════════════════════════════════════════════════════════════════════════

class _ExportOption extends StatelessWidget {
  final AuditExportFormat format;
  final VoidCallback onTap;
  const _ExportOption({required this.format, required this.onTap});

  IconData get _icon {
    switch (format) {
      case AuditExportFormat.pdf: return Icons.picture_as_pdf;
      case AuditExportFormat.csv: return Icons.table_chart;
      case AuditExportFormat.json: return Icons.code;
      case AuditExportFormat.print: return Icons.print;
    }
  }

  String get _label {
    switch (format) {
      case AuditExportFormat.pdf: return 'PDF Document';
      case AuditExportFormat.csv: return 'CSV Spreadsheet';
      case AuditExportFormat.json: return 'JSON Data';
      case AuditExportFormat.print: return 'Print';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(_icon, size: 20, color: const Color(0xFF3B82F6)),
            const SizedBox(width: 12),
            Text(_label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            const Spacer(),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
