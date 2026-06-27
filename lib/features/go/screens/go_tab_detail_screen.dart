/// GO Screen 5  Tab Detail
/// Tab identity card, financial snapshot, transaction timeline,
/// settlement interface, negotiation tools, documents, audit trail
library;

import 'package:flutter/material.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/design/ive.dart';
import 'package:provider/provider.dart';
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
          backgroundColor: IveTokens.bg,
          appBar: const GoAppBar(title: 'Tab Detail'),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1  Identity card
              _buildIdentityCard(tab),
              const SizedBox(height: 14),
              // 2  Financial snapshot
              _buildFinancialSnapshot(tab),
              const SizedBox(height: 14),
              // 3  Timeline
              _buildTimeline(timeline),
              const SizedBox(height: 14),
              // 4  Settlement
              _buildSettlement(tab),
              const SizedBox(height: 14),
              // 5  Actions
              _buildActions(tab),
              const SizedBox(height: 14),
              // 6  Audit
              _buildAudit(tab),
              const SizedBox(height: 80),
            ],
          ),
          bottomSheet: tab.status != TabStatus.settled ? Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: IveTokens.surface, border: Border(top: BorderSide(color: IveTokens.hairline))),
            child: Row(children: [
              Expanded(child: IveButton.secondary(label: 'Settle', onPressed: () => setState(() => _showSettlement = !_showSettlement))),
              const SizedBox(width: 12),
              Expanded(child: IveButton.primary(label: 'Send Reminder', onPressed: () => AppToast.show(context, 'Reminder sent'))),
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
          CircleAvatar(radius: 24, backgroundColor: IveTokens.surfaceRaised, child: Text(tab.entityName.substring(0, 1), style: IveType.title2.copyWith(color: IveTokens.moduleGo))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tab.entityName, style: IveType.title3.copyWith(color: IveTokens.ink)),
            Text('Tab #${tab.id.substring(0, 8).toUpperCase()}', style: IveType.caption.copyWith(color: IveTokens.ink2)),
            Text(tab.isOverdue ? 'Overdue' : 'Active', style: IveType.caption.copyWith(fontWeight: FontWeight.w600, color: tab.isOverdue ? IveTokens.danger : IveTokens.success)),
          ])),
          _StatusBadge(status: tab.status),
        ]),
        if (tab.risk != TabRisk.low) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: _riskColor(tab.risk).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(IveTokens.rSm)),
            child: Row(children: [
              Icon(Icons.warning_amber, size: 14, color: _riskColor(tab.risk)),
              const SizedBox(width: 6),
              Text('${tab.risk.name.toUpperCase()} RISK', style: IveType.caption.copyWith(fontWeight: FontWeight.w700, color: _riskColor(tab.risk))),
            ]),
          ),
        ],
      ]),
    );
  }

  Color _riskColor(TabRisk r) {
    switch (r) {
      case TabRisk.low: return IveTokens.success;
      case TabRisk.medium: return IveTokens.warning;
      case TabRisk.high: return IveTokens.danger;
      case TabRisk.critical: return IveTokens.danger;
    }
  }

  Widget _buildFinancialSnapshot(GoTab tab) {
    final paid = tab.creditLimit - tab.currentBalance;
    final pct = tab.creditLimit > 0 ? (paid / tab.creditLimit * 100) : 0.0;
    return GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const GoSectionHeader(title: 'Financial Snapshot', icon: Icons.account_balance_wallet),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _SnapCard(label: 'Total', value: '${tab.creditLimit.toStringAsFixed(0)} QP', color: IveTokens.ink)),
        const SizedBox(width: 8),
        Expanded(child: _SnapCard(label: 'Paid', value: '${paid.toStringAsFixed(0)} QP', color: IveTokens.success)),
        const SizedBox(width: 8),
        Expanded(child: _SnapCard(label: 'Remaining', value: '${tab.currentBalance.toStringAsFixed(0)} QP', color: IveTokens.danger)),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(IveTokens.rXs), child: LinearProgressIndicator(value: pct / 100, minHeight: 8, backgroundColor: IveTokens.hairline2, valueColor: const AlwaysStoppedAnimation(IveTokens.moduleGo)))),
        const SizedBox(width: 8),
        Text('${pct.toStringAsFixed(0)}%', style: IveType.caption.copyWith(fontWeight: FontWeight.w700, color: IveTokens.moduleGo)),
      ]),
      ...[
      const SizedBox(height: 8),
      Row(children: [
        const Icon(Icons.calendar_today, size: 12, color: IveTokens.ink2),
        const SizedBox(width: 4),
        Text('Due: ${_formatDate(tab.dueDate)}', style: IveType.caption.copyWith(color: tab.status == TabStatus.overdue ? IveTokens.danger : IveTokens.ink2)),
        if (tab.status == TabStatus.overdue) ...[
          const SizedBox(width: 6),
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1), decoration: BoxDecoration(color: IveTokens.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(IveTokens.rXs)), child: Text('OVERDUE', style: IveType.caption.copyWith(fontWeight: FontWeight.w700, color: IveTokens.danger))),
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
        Text('No timeline events.', style: IveType.caption.copyWith(color: IveTokens.ink2))
      else
        ...events.map((e) => _TimelineItem(event: e)),
    ]));
  }

  Widget _buildSettlement(GoTab tab) {
    if (!_showSettlement) return const SizedBox.shrink();
    return GoSectionCard(borderColor: IveTokens.moduleGo.withValues(alpha: 0.3), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const GoSectionHeader(title: 'Settle Tab', icon: Icons.check_circle_outline),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _SettleOption(label: 'Full', desc: '${tab.currentBalance.toStringAsFixed(0)} QP', selected: true, onTap: () { _settleAmountCtrl.text = tab.currentBalance.toStringAsFixed(0); })),
        const SizedBox(width: 8),
        Expanded(child: _SettleOption(label: 'Partial', desc: 'Custom amount', selected: false, onTap: () => setState(() { _settleAmountCtrl.clear(); }))),
        const SizedBox(width: 8),
        Expanded(child: _SettleOption(label: 'Plan', desc: 'Installments', selected: false, onTap: () => Navigator.pushNamed(context, AppRoutes.fintechLoans))),
      ]),
      const SizedBox(height: 12),
      TextField(
        controller: _settleAmountCtrl, keyboardType: TextInputType.number,
        decoration: InputDecoration(hintText: 'Amount to settle', suffixText: 'QP', filled: true, fillColor: IveTokens.hairline2, border: OutlineInputBorder(borderRadius: BorderRadius.circular(IveTokens.rSm), borderSide: BorderSide.none)),
        style: IveType.body.copyWith(color: IveTokens.ink),
      ),
      const SizedBox(height: 10),
      IveButton.primary(label: 'Proceed to Settlement', onPressed: () => Navigator.pushNamed(context, AppRoutes.goTransfer)),
    ]));
  }

  Widget _buildActions(GoTab tab) {
    return GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const GoSectionHeader(title: 'Actions', icon: Icons.more_horiz),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [
        _ActionBtn(icon: Icons.message, label: 'Message', onTap: () => Navigator.pushNamed(context, AppRoutes.qualChatDashboard)),
        _ActionBtn(icon: Icons.edit, label: 'Edit', onTap: () => _showEditTabSheet(context, tab)),
        _ActionBtn(icon: Icons.handshake, label: 'Negotiate', onTap: () => AppToast.show(context, 'Opening negotiation...')),
        _ActionBtn(icon: Icons.attach_file, label: 'Documents', onTap: () => AppToast.show(context, 'Opening documents...')),
        _ActionBtn(icon: Icons.share, label: 'Share', onTap: () => AppToast.show(context, 'Link copied to clipboard')),
        if (tab.status != TabStatus.settled) _ActionBtn(icon: Icons.cancel, label: 'Dispute', onTap: () => AppToast.show(context, 'Dispute filed'), color: IveTokens.danger),
      ]),
    ]));
  }

  Widget _buildAudit(GoTab tab) {
    return const GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GoSectionHeader(title: 'Audit Trail', icon: Icons.history),
      SizedBox(height: 10),
      _AuditLine(time: 'Today', action: 'Viewed tab details'),
      _AuditLine(time: '2 days ago', action: 'Payment of 500 QP received'),
      _AuditLine(time: '1 week ago', action: 'Reminder sent'),
      _AuditLine(time: '2 weeks ago', action: 'Tab created'),
    ]));
  }

  void _showEditTabSheet(BuildContext context, GoTab tab) {
    final descCtrl = TextEditingController(text: tab.description);
    final noteCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(IveTokens.rSm))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Tab  ${tab.id}', style: IveType.title3.copyWith(color: IveTokens.ink)),
            const SizedBox(height: 16),
            Text('Description', style: IveType.bodyEmphasis.copyWith(color: IveTokens.ink)),
            const SizedBox(height: 6),
            TextField(
              controller: descCtrl,
              decoration: InputDecoration(
                hintText: 'Tab description',
                filled: true, fillColor: IveTokens.hairline2,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(IveTokens.rSm), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            Text('Notes', style: IveType.bodyEmphasis.copyWith(color: IveTokens.ink)),
            const SizedBox(height: 6),
            TextField(
              controller: noteCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add an internal note...',
                filled: true, fillColor: IveTokens.hairline2,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(IveTokens.rSm), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            IveButton.primary(
              label: 'Save Changes',
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tab updated successfully'), backgroundColor: IveTokens.moduleGo),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TabStatus status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    Color c; String t;
    switch (status) {
      case TabStatus.active: c = IveTokens.moduleGo; t = 'Active';
      case TabStatus.overdue: c = IveTokens.danger; t = 'Overdue';
      case TabStatus.settled: c = IveTokens.success; t = 'Settled';
      case TabStatus.disputed: c = IveTokens.warning; t = 'Disputed';
      case TabStatus.frozen: c = IveTokens.info; t = 'Frozen';
      case TabStatus.closed: c = IveTokens.ink2; t = 'Closed';
    }
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(IveTokens.rSm)), child: Text(t, style: IveType.caption.copyWith(fontWeight: FontWeight.w700, color: c)));
  }
}

class _SnapCard extends StatelessWidget {
  final String label; final String value; final Color color;
  const _SnapCard({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(IveTokens.rSm)),
    child: Column(children: [
      Text(label, style: IveType.caption.copyWith(fontWeight: FontWeight.w600, color: color)),
      const SizedBox(height: 2),
      Text(value, style: IveType.footnote.copyWith(fontWeight: FontWeight.w700, color: color)),
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
          Container(width: 2, height: 30, color: IveTokens.hairline2),
        ]),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(event.description, style: IveType.caption.copyWith(fontWeight: FontWeight.w600, color: IveTokens.ink)),
          if (event.amount != null) Text('${event.amount!.toStringAsFixed(0)} QP', style: IveType.caption.copyWith(color: IveTokens.ink2)),
          Text(_formatDate(event.timestamp), style: IveType.caption.copyWith(color: IveTokens.faint)),
        ])),
      ]),
    );
  }
  Color get _typeColor {
    return event.isSystem ? IveTokens.info : IveTokens.success;
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
      decoration: BoxDecoration(color: selected ? IveTokens.surfaceRaised : IveTokens.surface, borderRadius: BorderRadius.circular(IveTokens.rSm), border: Border.all(color: selected ? IveTokens.moduleGo : IveTokens.hairline2)),
      child: Column(children: [
        Text(label, style: IveType.caption.copyWith(fontWeight: FontWeight.w600, color: selected ? IveTokens.moduleGo : IveTokens.ink)),
        Text(desc, style: IveType.caption.copyWith(color: IveTokens.ink2)),
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
      decoration: BoxDecoration(color: (color ?? IveTokens.moduleGo).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(IveTokens.rSm)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color ?? IveTokens.moduleGo),
        const SizedBox(width: 4),
        Text(label, style: IveType.caption.copyWith(fontWeight: FontWeight.w600, color: color ?? IveTokens.moduleGo)),
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
      const Icon(Icons.circle, size: 6, color: IveTokens.faint),
      const SizedBox(width: 8),
      Text(time, style: IveType.caption.copyWith(color: IveTokens.ink2, fontWeight: FontWeight.w600)),
      const SizedBox(width: 8),
      Expanded(child: Text(action, style: IveType.caption.copyWith(color: IveTokens.mute))),
    ]),
  );
}
