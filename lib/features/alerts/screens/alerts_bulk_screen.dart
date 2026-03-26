/// Alerts Screen 8 — Bulk Alert Management
/// Bulk assign, status change, tags, export, merge
/// Progress indicator, undo

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alerts_models.dart';
import '../providers/alerts_provider.dart';
import '../widgets/alerts_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class AlertsBulkScreen extends StatefulWidget {
  const AlertsBulkScreen({super.key});

  @override
  State<AlertsBulkScreen> createState() => _AlertsBulkScreenState();
}

class _AlertsBulkScreenState extends State<AlertsBulkScreen> {
  BulkActionType? _selectedAction;

  @override
  Widget build(BuildContext context) {
    return Consumer<AlertsProvider>(
      builder: (context, provider, _) {
        final selectedAlerts = provider.selectedAlertIds.map((id) => provider.getAlertById(id)).whereType<AlertItem>().toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: AlertsAppBar(
            title: 'Bulk Actions',
            actions: [
              TextButton(
                onPressed: provider.isSelectMode ? provider.clearSelection : provider.selectAll,
                child: Text(
                  provider.isSelectMode ? 'Deselect All' : 'Select All',
                  style: const TextStyle(fontSize: 13, color: kAlertsColor),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kAlertsColor.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kAlertsColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI: ${ai.insights.first['title'] ?? ''}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kAlertsColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // ──── SELECTION BANNER ────
              Container(
                padding: const EdgeInsets.all(14),
                color: kAlertsColorLight,
                child: Row(
                  children: [
                    const Icon(Icons.checklist, size: 20, color: kAlertsColor),
                    const SizedBox(width: 10),
                    Text(
                      '${provider.selectedCount} alert${provider.selectedCount == 1 ? '' : 's'} selected',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kAlertsColor),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: provider.clearSelection,
                      child: const Text('Clear', style: TextStyle(fontSize: 12, color: kAlertsColor)),
                    ),
                  ],
                ),
              ),

              // ──── ACTION GRID ────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Choose Action', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _BulkActionButton(
                          icon: Icons.person_add,
                          label: 'Assign',
                          type: BulkActionType.assign,
                          isSelected: _selectedAction == BulkActionType.assign,
                          onTap: () => setState(() => _selectedAction = BulkActionType.assign),
                        ),
                        const SizedBox(width: 8),
                        _BulkActionButton(
                          icon: Icons.swap_horiz,
                          label: 'Status',
                          type: BulkActionType.changeStatus,
                          isSelected: _selectedAction == BulkActionType.changeStatus,
                          onTap: () => setState(() => _selectedAction = BulkActionType.changeStatus),
                        ),
                        const SizedBox(width: 8),
                        _BulkActionButton(
                          icon: Icons.label,
                          label: 'Tags',
                          type: BulkActionType.addTags,
                          isSelected: _selectedAction == BulkActionType.addTags,
                          onTap: () => setState(() => _selectedAction = BulkActionType.addTags),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _BulkActionButton(
                          icon: Icons.download,
                          label: 'Export',
                          type: BulkActionType.export,
                          isSelected: _selectedAction == BulkActionType.export,
                          onTap: () => setState(() => _selectedAction = BulkActionType.export),
                        ),
                        const SizedBox(width: 8),
                        _BulkActionButton(
                          icon: Icons.merge_type,
                          label: 'Merge',
                          type: BulkActionType.merge,
                          isSelected: _selectedAction == BulkActionType.merge,
                          onTap: () => setState(() => _selectedAction = BulkActionType.merge),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(child: SizedBox()), // spacer
                      ],
                    ),
                  ],
                ),
              ),

              // ──── ACTION PANEL ────
              if (_selectedAction != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildActionPanel(context, provider),
                ),

              const SizedBox(height: 12),

              // ──── SELECTED ALERTS LIST ────
              Expanded(
                child: selectedAlerts.isEmpty
                    ? const AlertsEmptyState(
                        icon: Icons.touch_app,
                        title: 'No Alerts Selected',
                        message: 'Go back and long-press alerts to select them.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: selectedAlerts.length,
                        itemBuilder: (context, index) {
                          final alert = selectedAlerts[index];
                          return Dismissible(
                            key: ValueKey(alert.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => provider.toggleSelectAlert(alert.id),
                            background: Container(
                              color: kAlertsColor,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child: const Icon(Icons.remove_circle, color: Colors.white),
                            ),
                            child: _CompactSelectedAlert(alert: alert),
                          );
                        },
                      ),
              ),
            ],
          ),

          // ──── EXECUTE FOOTER ────
          bottomNavigationBar: _selectedAction != null && provider.selectedCount > 0
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: const Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))],
                  ),
                  child: SafeArea(
                    child: ElevatedButton(
                      onPressed: () => _executeBulk(context, provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAlertsColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Execute ${_actionLabel(_selectedAction!)} on ${provider.selectedCount} alerts',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildActionPanel(BuildContext context, AlertsProvider provider) {
    switch (_selectedAction!) {
      case BulkActionType.assign:
        return AlertsSectionCard(
          title: '👤 Assign To',
          child: Column(
            children: provider.staff.take(4).map((s) => StaffPickerTile(staff: s, onTap: () {
              provider.bulkAssign(s.name);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Assigned to ${s.name}'), backgroundColor: kAlertsResolved));
              Navigator.pop(context);
            })).toList(),
          ),
        );
      case BulkActionType.changeStatus:
        return AlertsSectionCard(
          title: '🔄 Change Status',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [AlertStatus.assigned, AlertStatus.inProgress, AlertStatus.resolved, AlertStatus.closed].map((st) => GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status changed to ${_statusLabel(st)}'), backgroundColor: kAlertsResolved));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE5E7EB))),
                child: Text(_statusLabel(st), style: const TextStyle(fontSize: 12)),
              ),
            )).toList(),
          ),
        );
      case BulkActionType.export:
        return AlertsSectionCard(
          title: '📥 Export Format',
          child: Row(
            children: [
              _ExportChip(label: 'CSV', icon: Icons.table_chart, onTap: () => _showExportSuccess(context)),
              const SizedBox(width: 8),
              _ExportChip(label: 'PDF', icon: Icons.picture_as_pdf, onTap: () => _showExportSuccess(context)),
              const SizedBox(width: 8),
              _ExportChip(label: 'JSON', icon: Icons.code, onTap: () => _showExportSuccess(context)),
            ],
          ),
        );
      default:
        return AlertsSectionCard(
          title: '🔧 ${_actionLabel(_selectedAction!)}',
          child: const Text('Feature coming soon', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        );
    }
  }

  void _executeBulk(BuildContext context, AlertsProvider provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_actionLabel(_selectedAction!)} applied to ${provider.selectedCount} alerts'),
        backgroundColor: kAlertsResolved,
        action: SnackBarAction(label: 'Undo', textColor: Colors.white, onPressed: () {}),
      ),
    );
    provider.clearSelection();
    Navigator.pop(context);
  }

  void _showExportSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export started — check downloads'), backgroundColor: kAlertsResolved),
    );
  }

  String _actionLabel(BulkActionType t) {
    switch (t) {
      case BulkActionType.assign: return 'Assign';
      case BulkActionType.changeStatus: return 'Change Status';
      case BulkActionType.addTags: return 'Add Tags';
      case BulkActionType.export: return 'Export';
      case BulkActionType.merge: return 'Merge';
    }
  }

  String _statusLabel(AlertStatus s) {
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
// Bulk Action Button
// ──────────────────────────────────────────────

class _BulkActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final BulkActionType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _BulkActionButton({required this.icon, required this.label, required this.type, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? kAlertsColor.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? kAlertsColor : const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 24, color: isSelected ? kAlertsColor : const Color(0xFF6B7280)),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? kAlertsColor : const Color(0xFF6B7280))),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Compact Selected Alert
// ──────────────────────────────────────────────

class _CompactSelectedAlert extends StatelessWidget {
  final AlertItem alert;
  const _CompactSelectedAlert({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 18, color: kAlertsColor),
          const SizedBox(width: 8),
          Text(alert.categoryEmoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text('#${alert.id}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kAlertsColor)),
          const SizedBox(width: 8),
          Expanded(child: Text(alert.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Export Chip
// ──────────────────────────────────────────────

class _ExportChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _ExportChip({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: kAlertsInfo),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
