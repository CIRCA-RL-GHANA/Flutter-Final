/// Alerts Screen 2 — Comprehensive Filter System
/// Full-screen modal with accordion sections (Time Intelligence,
/// People & Assignment, Issue Taxonomy, Status & Workflow, AI Filters),
/// filter presets, sticky footer

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alerts_models.dart';
import '../providers/alerts_provider.dart';
import '../widgets/alerts_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class AlertsFilterScreen extends StatefulWidget {
  const AlertsFilterScreen({super.key});

  @override
  State<AlertsFilterScreen> createState() => _AlertsFilterScreenState();
}

class _AlertsFilterScreenState extends State<AlertsFilterScreen> {
  // Local filter state (applied on confirm)
  AlertPriority? _priority;
  AlertCategory? _category;
  TimeFilter _time = TimeFilter.last7d;
  bool _assignedToMe = false;
  AlertStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AlertsProvider>(context, listen: false);
    _priority = provider.priorityFilter;
    _category = provider.categoryFilter;
    _time = provider.timeFilter;
    _assignedToMe = provider.assignedToMeOnly;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AlertsProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1A1A1A),
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Row(
              children: [
                const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                if (_activeCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: kAlertsColor, borderRadius: BorderRadius.circular(10)),
                    child: Text('$_activeCount', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: _clearAll,
                child: const Text('Clear All', style: TextStyle(fontSize: 13, color: kAlertsColor)),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<AIInsightsNotifier>(
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
                // ──── FILTER PRESETS ────
                AlertsSectionCard(
                  title: '⚡ Quick Presets',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: provider.filterPresets.map((preset) => GestureDetector(
                      onTap: () => _applyPreset(preset),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (preset.isShared) const Icon(Icons.group, size: 14, color: kAlertsInfo),
                            if (preset.isDefault) const Icon(Icons.star, size: 14, color: kAlertsWarning),
                            if (preset.isShared || preset.isDefault) const SizedBox(width: 4),
                            Text(preset.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // ──── TIME INTELLIGENCE ────
                _FilterAccordion(
                  icon: Icons.schedule,
                  title: 'Time Intelligence',
                  child: Column(
                    children: TimeFilter.values.map((tf) => _RadioTile<TimeFilter>(
                      label: _timeLabel(tf),
                      value: tf,
                      groupValue: _time,
                      onChanged: (v) => setState(() => _time = v!),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 12),

                // ──── PRIORITY LEVEL ────
                _FilterAccordion(
                  icon: Icons.flag,
                  title: 'Priority Level',
                  child: Column(
                    children: [
                      _CheckTile(
                        label: '🚨 Critical',
                        isSelected: _priority == AlertPriority.critical,
                        color: kAlertsCritical,
                        onTap: () => setState(() => _priority = _priority == AlertPriority.critical ? null : AlertPriority.critical),
                      ),
                      _CheckTile(
                        label: '🔥 High',
                        isSelected: _priority == AlertPriority.high,
                        color: kAlertsColor,
                        onTap: () => setState(() => _priority = _priority == AlertPriority.high ? null : AlertPriority.high),
                      ),
                      _CheckTile(
                        label: '⚠️ Medium',
                        isSelected: _priority == AlertPriority.medium,
                        color: kAlertsWarning,
                        onTap: () => setState(() => _priority = _priority == AlertPriority.medium ? null : AlertPriority.medium),
                      ),
                      _CheckTile(
                        label: 'ℹ️ Low',
                        isSelected: _priority == AlertPriority.low,
                        color: kAlertsInfo,
                        onTap: () => setState(() => _priority = _priority == AlertPriority.low ? null : AlertPriority.low),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ──── ISSUE TAXONOMY ────
                _FilterAccordion(
                  icon: Icons.category,
                  title: 'Issue Taxonomy',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AlertCategory.values.map((cat) {
                      final isActive = _category == cat;
                      return GestureDetector(
                        onTap: () => setState(() => _category = isActive ? null : cat),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isActive ? kAlertsColor.withOpacity(0.1) : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isActive ? kAlertsColor : const Color(0xFFE5E7EB)),
                          ),
                          child: Text(
                            '${_catEmoji(cat)} ${_catLabel(cat)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                              color: isActive ? kAlertsColor : const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),

                // ──── STATUS & WORKFLOW ────
                _FilterAccordion(
                  icon: Icons.assignment,
                  title: 'Status & Workflow',
                  child: Column(
                    children: AlertStatus.values.map((st) => _CheckTile(
                      label: _statusLabel(st),
                      isSelected: _statusFilter == st,
                      color: _statusColor(st),
                      onTap: () => setState(() => _statusFilter = _statusFilter == st ? null : st),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 12),

                // ──── PEOPLE & ASSIGNMENT ────
                _FilterAccordion(
                  icon: Icons.people,
                  title: 'People & Assignment',
                  child: Column(
                    children: [
                      _ToggleTile(
                        label: 'Assigned to me only',
                        value: _assignedToMe,
                        onChanged: (v) => setState(() => _assignedToMe = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80), // space for sticky footer
              ],
            ),
          ),

          // ──── STICKY FOOTER ────
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(top: BorderSide(color: Color(0xFFE5E7EB))),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7280),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => _applyFilters(provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAlertsColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Apply Filters${_activeCount > 0 ? ' ($_activeCount)' : ''}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  int get _activeCount {
    int c = 0;
    if (_priority != null) c++;
    if (_category != null) c++;
    if (_time != TimeFilter.last7d) c++;
    if (_assignedToMe) c++;
    if (_statusFilter != null) c++;
    return c;
  }

  void _clearAll() {
    setState(() {
      _priority = null;
      _category = null;
      _time = TimeFilter.last7d;
      _assignedToMe = false;
      _statusFilter = null;
    });
  }

  void _applyFilters(AlertsProvider provider) {
    provider.setPriorityFilter(_priority);
    provider.setCategoryFilter(_category);
    provider.setTimeFilter(_time);
    provider.setAssignedToMeOnly(_assignedToMe);
    Navigator.pop(context);
  }

  void _applyPreset(AlertFilterPreset preset) {
    // Apply preset logic — simplified for demo
    setState(() {
      _priority = null;
      _category = null;
      _assignedToMe = preset.name.contains('My');
    });
  }

  String _timeLabel(TimeFilter t) {
    switch (t) {
      case TimeFilter.last24h: return 'Last 24 hours';
      case TimeFilter.last7d: return 'Last 7 days';
      case TimeFilter.last30d: return 'Last 30 days';
      case TimeFilter.thisMonth: return 'This month';
      case TimeFilter.custom: return 'Custom range';
    }
  }

  String _catEmoji(AlertCategory c) {
    const map = { AlertCategory.payment: '💳', AlertCategory.shipment: '📦', AlertCategory.system: '⚙️', AlertCategory.driverRide: '🚗', AlertCategory.returnRefund: '↩️', AlertCategory.account: '👤', AlertCategory.security: '🔒', AlertCategory.other: '📋' };
    return map[c] ?? '📋';
  }

  String _catLabel(AlertCategory c) {
    const map = { AlertCategory.payment: 'Payment', AlertCategory.shipment: 'Shipment', AlertCategory.system: 'System', AlertCategory.driverRide: 'Driver/Ride', AlertCategory.returnRefund: 'Return/Refund', AlertCategory.account: 'Account', AlertCategory.security: 'Security', AlertCategory.other: 'Other' };
    return map[c] ?? 'Other';
  }

  String _statusLabel(AlertStatus s) {
    switch (s) {
      case AlertStatus.newAlert: return '🆕 New';
      case AlertStatus.assigned: return '👤 Assigned';
      case AlertStatus.inProgress: return '🔄 In Progress';
      case AlertStatus.escalated: return '⚠️ Escalated';
      case AlertStatus.resolved: return '✅ Resolved';
      case AlertStatus.verified: return '🔒 Verified';
      case AlertStatus.closed: return '📁 Closed';
      case AlertStatus.archived: return '🗃️ Archived';
    }
  }

  Color _statusColor(AlertStatus s) {
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
}

// ──────────────────────────────────────────────
// Filter Accordion
// ──────────────────────────────────────────────

class _FilterAccordion extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _FilterAccordion({required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Icon(icon, size: 20, color: kAlertsColor),
          title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          initiallyExpanded: true,
          children: [child],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Radio Tile
// ──────────────────────────────────────────────

class _RadioTile<T> extends StatelessWidget {
  final String label;
  final T value;
  final T groupValue;
  final ValueChanged<T?> onChanged;

  const _RadioTile({required this.label, required this.value, required this.groupValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? kAlertsColor.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 18,
              color: isSelected ? kAlertsColor : const Color(0xFF9CA3AF),
            ),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Check Tile
// ──────────────────────────────────────────────

class _CheckTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _CheckTile({required this.label, required this.isSelected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              size: 18,
              color: isSelected ? color : const Color(0xFF9CA3AF),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400))),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Toggle Tile
// ──────────────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: kAlertsColor,
          ),
        ],
      ),
    );
  }
}
