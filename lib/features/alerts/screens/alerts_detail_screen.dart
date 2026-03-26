/// Alerts Screen 3 — Alert Detail (Immersive View)
/// Collapsible header, priority strip, metadata grid, description card,
/// assignment panel, activity timeline, resolution zone, sticky bottom actions

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alerts_models.dart';
import '../providers/alerts_provider.dart';
import '../widgets/alerts_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class AlertsDetailScreen extends StatelessWidget {
  final String alertId;
  const AlertsDetailScreen({super.key, required this.alertId});

  @override
  Widget build(BuildContext context) {
    return Consumer<AlertsProvider>(
      builder: (context, provider, _) {
        final alert = provider.getAlertById(alertId);
        if (alert == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Alert')),
            body: const AlertsEmptyState(
              icon: Icons.error_outline,
              title: 'Alert Not Found',
              message: 'This alert may have been removed or archived.',
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          body: CustomScrollView(
            slivers: [
              // ──── COLLAPSIBLE HEADER ────
              SliverAppBar(
                pinned: true,
                expandedHeight: 180,
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1A1A1A),
                elevation: 0,
                actions: [
                  IconButton(
                    icon: Icon(
                      alert.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: alert.isBookmarked ? kAlertsWarning : null,
                    ),
                    onPressed: () => provider.bookmarkAlert(alert.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.lightbulb_outline, size: 22),
                    onPressed: () => Navigator.pushNamed(context, '/alerts/knowledge', arguments: alert.id),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (v) {
                      switch (v) {
                        case 'escalate': provider.escalateAlert(alert.id); break;
                        case 'share': break;
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'escalate', child: Text('Escalate')),
                      PopupMenuItem(value: 'share', child: Text('Share')),
                    ],
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Priority strip
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: _priorityColor(alert.priority).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                alert.priorityLabel,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _priorityColor(alert.priority)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // ID + Status
                          Row(
                            children: [
                              Text(alert.categoryEmoji, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Text('#${alert.id}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _priorityColor(alert.priority))),
                              const SizedBox(width: 8),
                              _StatusChip(status: alert.status),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            alert.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Created ${_timeAgo(alert.createdAt)} by ${alert.createdBy}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ──── AI INSIGHTS ────
              SliverToBoxAdapter(
                child: Consumer<AIInsightsNotifier>(
                  builder: (context, ai, _) {
                    if (ai.insights.isEmpty) return const SizedBox.shrink();
                    return Container(
                      color: kAlertsColor.withOpacity(0.07),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Row(children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kAlertsColor),
                        const SizedBox(width: 8),
                        Expanded(child: Text('AI: ${ai.insights.first['title'] ?? ''}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kAlertsColor),
                          maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ]),
                    );
                  },
                ),
              ),

              // ──── BODY ────
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ──── METADATA GRID ────
                    AlertsSectionCard(
                      title: '📋 Details',
                      child: Column(
                        children: [
                          _MetadataRow(label: 'Category', value: '${alert.categoryEmoji} ${alert.categoryLabel}'),
                          if (alert.subCategory != null)
                            _MetadataRow(label: 'Sub-Type', value: alert.subCategory!),
                          _MetadataRow(label: 'Status', value: alert.statusLabel),
                          _MetadataRow(label: 'Created', value: _formatDate(alert.createdAt)),
                          _MetadataRow(label: 'Updated', value: _formatDate(alert.updatedAt)),
                          if (alert.tags.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: alert.tags.map((t) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('#$t', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                              )).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ──── DESCRIPTION ────
                    AlertsSectionCard(
                      title: '📝 Description',
                      child: Text(alert.description, style: const TextStyle(fontSize: 14, color: Color(0xFF374151), height: 1.5)),
                    ),
                    const SizedBox(height: 12),

                    // ──── SLA INFO ────
                    if (alert.slaInfo != null) ...[
                      AlertsSectionCard(
                        title: '⏱️ SLA Tracking',
                        child: _SlaDetailPanel(sla: alert.slaInfo!),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ──── ASSIGNMENT PANEL ────
                    AlertsSectionCard(
                      title: '👤 Assignment',
                      child: alert.assigneeName != null
                          ? Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: kAlertsInfo.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(child: Text(alert.assigneeName![0], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kAlertsInfo))),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(alert.assigneeName!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                      Text(alert.assigneeRole ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                                    ],
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: kAlertsColor,
                                    side: const BorderSide(color: kAlertsColor),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Reassign', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                const Icon(Icons.person_add, size: 20, color: Color(0xFF9CA3AF)),
                                const SizedBox(width: 8),
                                const Text('Unassigned', style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF), fontStyle: FontStyle.italic)),
                                const Spacer(),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kAlertsColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Assign', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 12),

                    // ──── TECHNICAL DETAILS ────
                    if (alert.technicalDetails != null) ...[
                      AlertsSectionCard(
                        title: '🔧 Technical Details',
                        child: Column(
                          children: [
                            if (alert.technicalDetails!.errorCode != null)
                              _MetadataRow(label: 'Error Code', value: alert.technicalDetails!.errorCode!),
                            if (alert.technicalDetails!.userId != null)
                              _MetadataRow(label: 'User ID', value: alert.technicalDetails!.userId!),
                            if (alert.technicalDetails!.deviceInfo != null)
                              _MetadataRow(label: 'Device', value: alert.technicalDetails!.deviceInfo!),
                            if (alert.technicalDetails!.appVersion != null)
                              _MetadataRow(label: 'App Version', value: alert.technicalDetails!.appVersion!),
                            if (alert.technicalDetails!.transactionIds.isNotEmpty)
                              _MetadataRow(label: 'Transactions', value: alert.technicalDetails!.transactionIds.join(', ')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ──── RESOLUTION ZONE ────
                    if (alert.resolution != null) ...[
                      AlertsSectionCard(
                        title: '✅ Resolution',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: kAlertsResolved.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(child: Text(alert.resolution!.resolverName[0], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kAlertsResolved))),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(alert.resolution!.resolverName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                      Text('Method: ${alert.resolution!.methodLabel}', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                                    ],
                                  ),
                                ),
                                if (alert.resolution!.qualityScore != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: kAlertsResolved.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text('${alert.resolution!.qualityScore}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kAlertsResolved)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(alert.resolution!.summary, style: const TextStyle(fontSize: 13, height: 1.5)),
                            if (alert.resolution!.rootCause != null) ...[
                              const SizedBox(height: 8),
                              _ResolutionField(label: 'Root Cause', value: alert.resolution!.rootCause!),
                            ],
                            if (alert.resolution!.preventionMeasures != null) ...[
                              const SizedBox(height: 8),
                              _ResolutionField(label: 'Prevention', value: alert.resolution!.preventionMeasures!),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ──── ACTIVITY TIMELINE ────
                    AlertsSectionCard(
                      title: '📊 Activity Timeline',
                      trailing: Text('${alert.timeline.length} events', style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                      child: alert.timeline.isEmpty
                          ? const Text('No activity yet', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)))
                          : Column(
                              children: [
                                for (int i = 0; i < alert.timeline.length; i++)
                                  ActivityTimelineEvent(
                                    event: alert.timeline[i],
                                    isLast: i == alert.timeline.length - 1,
                                  ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 80), // space for bottom bar
                  ]),
                ),
              ),
            ],
          ),

          // ──── STICKY BOTTOM ACTIONS ────
          bottomNavigationBar: alert.isPending
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: const Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        if (alert.status == AlertStatus.newAlert || alert.status == AlertStatus.assigned)
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.play_arrow, size: 18),
                              label: const Text('Accept'),
                              onPressed: () => provider.acceptAlert(alert.id),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: kAlertsInfo,
                                side: const BorderSide(color: kAlertsInfo),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        if (alert.status == AlertStatus.newAlert || alert.status == AlertStatus.assigned)
                          const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.check_circle, size: 18),
                            label: const Text('Resolve', style: TextStyle(fontWeight: FontWeight.w600)),
                            onPressed: () => Navigator.pushNamed(context, '/alerts/resolve', arguments: alert.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kAlertsResolved,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  Color _priorityColor(AlertPriority p) {
    switch (p) {
      case AlertPriority.critical: return kAlertsCritical;
      case AlertPriority.high: return kAlertsColor;
      case AlertPriority.medium: return kAlertsWarning;
      case AlertPriority.low: return kAlertsInfo;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ──────────────────────────────────────────────
// Status Chip
// ──────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final AlertStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _color(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _label(status),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Color _color(AlertStatus s) {
    switch (s) {
      case AlertStatus.newAlert: return kAlertsInfo;
      case AlertStatus.assigned: return kAlertsInfo;
      case AlertStatus.inProgress: return kAlertsWarning;
      case AlertStatus.escalated: return kAlertsColor;
      case AlertStatus.resolved: return kAlertsResolved;
      case AlertStatus.verified: return kAlertsResolved;
      case AlertStatus.closed: return const Color(0xFF6B7280);
      case AlertStatus.archived: return const Color(0xFF9CA3AF);
    }
  }

  String _label(AlertStatus s) {
    switch (s) {
      case AlertStatus.newAlert: return 'New';
      case AlertStatus.assigned: return 'Assigned';
      case AlertStatus.inProgress: return 'In Progress';
      case AlertStatus.escalated: return 'Escalated';
      case AlertStatus.resolved: return 'Resolved';
      case AlertStatus.verified: return 'Verified';
      case AlertStatus.closed: return 'Closed';
      case AlertStatus.archived: return 'Archived';
    }
  }
}

// ──────────────────────────────────────────────
// Metadata Row
// ──────────────────────────────────────────────

class _MetadataRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetadataRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// SLA Detail Panel
// ──────────────────────────────────────────────

class _SlaDetailPanel extends StatelessWidget {
  final AlertSlaInfo sla;
  const _SlaDetailPanel({required this.sla});

  @override
  Widget build(BuildContext context) {
    final color = sla.status == SlaStatus.onTrack
        ? kAlertsResolved
        : sla.status == SlaStatus.atRisk
            ? kAlertsWarning
            : kAlertsColor;
    final remaining = sla.remainingTime;
    final label = remaining.isNegative
        ? 'SLA Breached'
        : '${remaining.inHours}h ${remaining.inMinutes % 60}m remaining';
    final statusLabel = sla.status == SlaStatus.onTrack
        ? 'On Track'
        : sla.status == SlaStatus.atRisk
            ? 'At Risk'
            : 'Breached';

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: CircularProgressIndicator(
                      value: sla.progressPercent,
                      strokeWidth: 4,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                  Icon(Icons.schedule, size: 16, color: color),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
                  Text('Target: ${sla.targetTime.inHours}h • Status: $statusLabel', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Resolution Field
// ──────────────────────────────────────────────

class _ResolutionField extends StatelessWidget {
  final String label;
  final String value;
  const _ResolutionField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
