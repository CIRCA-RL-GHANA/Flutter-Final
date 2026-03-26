/// GO Screen 5 — Tab Detail
/// Tab identity card, financial snapshot, transaction timeline,
/// settlement interface, negotiation tools, documents, audit trail

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../models/go_models.dart';
import '../providers/go_provider.dart';
import '../widgets/go_widgets.dart';

class GoTabDetailScreen extends StatefulWidget {
  final String? tabId;
  const GoTabDetailScreen({super.key, this.tabId});
  @override
  State<GoTabDetailScreen> createState() => _GoTabDetailScreenState();
}

class _GoTabDetailScreenState extends State<GoTabDetailScreen> {
  bool _showSettlement = false;
  final _settleAmountCtrl = TextEditingController();

  @override
  void dispose() { _settleAmountCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final tabId = widget.tabId ?? (ModalRoute.of(context)?.settings.arguments as String? ?? '');
    return Consumer<GoProvider>(
      builder: (context, provider, _) {
        final tab = provider.tabs.firstWhere((t) => t.id == tabId, orElse: () => provider.tabs.first);
        final timeline = provider.getTabTimeline(tab.id);

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: const GoAppBar(title: 'Tab Detail'),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: kGoColor.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, size: 14, color: kGoColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'AI insight: ${ai.insights.first['title'] ?? ''}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kGoColor),
                              maxLines: 2, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // 1 — Identity card
              _buildIdentityCard(tab),
              const SizedBox(height: 14),
              // 2 — Financial snapshot
              _buildFinancialSnapshot(tab),
              const SizedBox(height: 14),
              // 3 — Timeline
              _buildTimeline(timeline),
              const SizedBox(height: 14),
              // 4 — Settlement
              _buildSettlement(tab),
              const SizedBox(height: 14),
              // 5 — Actions
              _buildActions(tab),
              const SizedBox(height: 14),
              // 6 — Audit
              _buildAudit(tab),
              const SizedBox(height: 80),
            ],
          ),
          bottomSheet: tab.status != TabStatus.settled ? Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE5E7EB)))),
            child: Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: () => setState(() => _showSettlement = !_showSettlement),
                style: OutlinedButton.styleFrom(foregroundColor: kGoColor, side: const BorderSide(color: Color(0xFFE5E7EB)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text('Settle'),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: kGoColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text('Send Reminder'),
              )),
            ]),
          ) : null,
        );
      },
    );
  }

  Widget _buildIdentityCard(GoTab tab) {
    return GoSectionCard(
      child: Column(children: [
        Row(children: [
          CircleAvatar(radius: 24, backgroundColor: kGoColorLight, child: Text(tab.entityName.substring(0, 1), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kGoColor))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tab.entityName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text('Tab #${tab.id.substring(0, 8).toUpperCase()}', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
            Text(tab.isOverdue ? 'Overdue' : 'Active', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: tab.isOverdue ? kGoNegative : kGoPositive)),
          ])),
          _StatusBadge(status: tab.status),
        ]),
        if (tab.risk != TabRisk.low) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: _riskColor(tab.risk).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              Icon(Icons.warning_amber, size: 14, color: _riskColor(tab.risk)),
              const SizedBox(width: 6),
              Text('${tab.risk.name.toUpperCase()} RISK', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _riskColor(tab.risk))),
            ]),
          ),
        ],
      ]),
    );
  }

  Color _riskColor(TabRisk r) {
    switch (r) {
      case TabRisk.low: return kGoPositive;
      case TabRisk.medium: return kGoWarning;
      case TabRisk.high: return kGoNegative;
      case TabRisk.critical: return const Color(0xFF991B1B);
    }
  }

  Widget _buildFinancialSnapshot(GoTab tab) {
    final paid = tab.creditLimit - tab.currentBalance;
    final pct = tab.creditLimit > 0 ? (paid / tab.creditLimit * 100) : 0.0;
    return GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const GoSectionHeader(title: 'Financial Snapshot', icon: Icons.account_balance_wallet),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _SnapCard(label: 'Total', value: '${tab.creditLimit.toStringAsFixed(0)} QP', color: const Color(0xFF1A1A1A))),
        const SizedBox(width: 8),
        Expanded(child: _SnapCard(label: 'Paid', value: '${paid.toStringAsFixed(0)} QP', color: kGoPositive)),
        const SizedBox(width: 8),
        Expanded(child: _SnapCard(label: 'Remaining', value: '${tab.currentBalance.toStringAsFixed(0)} QP', color: kGoNegative)),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: pct / 100, minHeight: 8, backgroundColor: const Color(0xFFE5E7EB), valueColor: const AlwaysStoppedAnimation(kGoColor)))),
        const SizedBox(width: 8),
        Text('${pct.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kGoColor)),
      ]),
      ...[
      const SizedBox(height: 8),
      Row(children: [
        const Icon(Icons.calendar_today, size: 12, color: Color(0xFF9CA3AF)),
        const SizedBox(width: 4),
        Text('Due: ${_formatDate(tab.dueDate)}', style: TextStyle(fontSize: 11, color: tab.status == TabStatus.overdue ? kGoNegative : const Color(0xFF9CA3AF))),
        if (tab.status == TabStatus.overdue) ...[
          const SizedBox(width: 6),
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1), decoration: BoxDecoration(color: kGoNegative.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: const Text('OVERDUE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: kGoNegative))),
        ],
      ]),
    ],
    ]));
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  Widget _buildTimeline(List<TabTimelineEvent> events) {
    return GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const GoSectionHeader(title: 'Timeline', icon: Icons.timeline),
      const SizedBox(height: 10),
      if (events.isEmpty)
        const Text('No timeline events.', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)))
      else
        ...events.map((e) => _TimelineItem(event: e)),
    ]));
  }

  Widget _buildSettlement(GoTab tab) {
    if (!_showSettlement) return const SizedBox.shrink();
    return GoSectionCard(borderColor: kGoColor.withOpacity(0.3), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const GoSectionHeader(title: 'Settle Tab', icon: Icons.check_circle_outline),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _SettleOption(label: 'Full', desc: '${tab.currentBalance.toStringAsFixed(0)} QP', selected: true, onTap: () { _settleAmountCtrl.text = tab.currentBalance.toStringAsFixed(0); })),
        const SizedBox(width: 8),
        Expanded(child: _SettleOption(label: 'Partial', desc: 'Custom amount', selected: false, onTap: () {})),
        const SizedBox(width: 8),
        Expanded(child: _SettleOption(label: 'Plan', desc: 'Installments', selected: false, onTap: () {})),
      ]),
      const SizedBox(height: 12),
      TextField(
        controller: _settleAmountCtrl, keyboardType: TextInputType.number,
        decoration: InputDecoration(hintText: 'Amount to settle', suffixText: 'QP', filled: true, fillColor: const Color(0xFFF3F4F6), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
        style: const TextStyle(fontSize: 14),
      ),
      const SizedBox(height: 10),
      SizedBox(width: double.infinity, child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(backgroundColor: kGoColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        child: const Text('Proceed to Settlement', style: TextStyle(fontWeight: FontWeight.w600)),
      )),
    ]));
  }

  Widget _buildActions(GoTab tab) {
    return GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const GoSectionHeader(title: 'Actions', icon: Icons.more_horiz),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [
        _ActionBtn(icon: Icons.message, label: 'Message', onTap: () {}),
        _ActionBtn(icon: Icons.edit, label: 'Edit', onTap: () {}),
        _ActionBtn(icon: Icons.handshake, label: 'Negotiate', onTap: () {}),
        _ActionBtn(icon: Icons.attach_file, label: 'Documents', onTap: () {}),
        _ActionBtn(icon: Icons.share, label: 'Share', onTap: () {}),
        if (tab.status != TabStatus.settled) _ActionBtn(icon: Icons.cancel, label: 'Dispute', onTap: () {}, color: kGoNegative),
      ]),
    ]));
  }

  Widget _buildAudit(GoTab tab) {
    return GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const GoSectionHeader(title: 'Audit Trail', icon: Icons.history),
      const SizedBox(height: 10),
      const _AuditLine(time: 'Today', action: 'Viewed tab details'),
      const _AuditLine(time: '2 days ago', action: 'Payment of 500 QP received'),
      const _AuditLine(time: '1 week ago', action: 'Reminder sent'),
      const _AuditLine(time: '2 weeks ago', action: 'Tab created'),
    ]));
  }
}

class _StatusBadge extends StatelessWidget {
  final TabStatus status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    Color c; String t;
    switch (status) {
      case TabStatus.active: c = kGoColor; t = 'Active';
      case TabStatus.overdue: c = kGoNegative; t = 'Overdue';
      case TabStatus.settled: c = kGoPositive; t = 'Settled';
      case TabStatus.disputed: c = kGoWarning; t = 'Disputed';
      case TabStatus.frozen: c = kGoInfo; t = 'Frozen';
      case TabStatus.closed: c = const Color(0xFF9CA3AF); t = 'Closed';
    }
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text(t, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c)));
  }
}

class _SnapCard extends StatelessWidget {
  final String label; final String value; final Color color;
  const _SnapCard({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: color.withOpacity(0.06), borderRadius: BorderRadius.circular(8)),
    child: Column(children: [
      Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: color)),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
    ]),
  );
}

class _TimelineItem extends StatelessWidget {
  final TabTimelineEvent event;
  const _TimelineItem({required this.event});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: _typeColor)),
          Container(width: 2, height: 30, color: const Color(0xFFE5E7EB)),
        ]),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(event.description, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          if (event.amount != null) Text('${event.amount!.toStringAsFixed(0)} QP', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
          Text(_formatDate(event.timestamp), style: const TextStyle(fontSize: 10, color: Color(0xFFD1D5DB))),
        ])),
      ]),
    );
  }
  Color get _typeColor {
    return event.isSystem ? kGoInfo : kGoPositive;
  }
  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

class _SettleOption extends StatelessWidget {
  final String label; final String desc; final bool selected; final VoidCallback onTap;
  const _SettleOption({required this.label, required this.desc, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: selected ? kGoColorLight : Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: selected ? kGoColor : const Color(0xFFE5E7EB))),
      child: Column(children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? kGoColor : const Color(0xFF1A1A1A))),
        Text(desc, style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
      ]),
    ),
  );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap; final Color? color;
  const _ActionBtn({required this.icon, required this.label, required this.onTap, this.color});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: (color ?? kGoColor).withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color ?? kGoColor),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color ?? kGoColor)),
      ]),
    ),
  );
}

class _AuditLine extends StatelessWidget {
  final String time; final String action;
  const _AuditLine({required this.time, required this.action});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      const Icon(Icons.circle, size: 6, color: Color(0xFFD1D5DB)),
      const SizedBox(width: 8),
      Text(time, style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w600)),
      const SizedBox(width: 8),
      Expanded(child: Text(action, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)))),
    ]),
  );
}
