/// GO Screen 9 — Batch Operations
/// Batch transfer creator, payment run manager, bulk approval interface

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../models/go_models.dart';
import '../providers/go_provider.dart';
import '../widgets/go_widgets.dart';

class GoBatchScreen extends StatefulWidget {
  const GoBatchScreen({super.key});
  @override
  State<GoBatchScreen> createState() => _GoBatchScreenState();
}

class _GoBatchScreenState extends State<GoBatchScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() { super.initState(); _tabCtrl = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoProvider>(
      builder: (context, provider, _) => Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        appBar: const GoAppBar(title: 'Batch Operations'),
        body: Column(
          children: [
            Consumer<AIInsightsNotifier>(
              builder: (context, ai, _) {
                if (ai.insights.isEmpty) return const SizedBox.shrink();
                return Container(
                  color: kGoColor.withOpacity(0.07),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 14, color: kGoColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'AI: ${ai.insights.first['title'] ?? ''}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kGoColor),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabCtrl,
                labelColor: kGoColor, unselectedLabelColor: const Color(0xFF9CA3AF),
                indicatorColor: kGoColor, indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                tabs: const [Tab(text: 'Batch Transfer'), Tab(text: 'Payment Runs'), Tab(text: 'Bulk Approve')],
              ),
            ),
            Expanded(
              child: TabBarView(controller: _tabCtrl, children: [
                _buildBatchTransfer(provider),
                _buildPaymentRuns(provider),
                _buildBulkApprove(provider),
              ]),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: kGoColor,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('New Batch', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildBatchTransfer(GoProvider p) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      // Summary
      GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const GoSectionHeader(title: 'Create Batch Transfer', icon: Icons.group),
        const SizedBox(height: 10),
        const Text('Send QPoints to multiple recipients at once. Upload a CSV or add recipients manually.', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            icon: const Icon(Icons.upload_file, size: 18),
            label: const Text('Upload CSV'),
            onPressed: () {},
            style: OutlinedButton.styleFrom(foregroundColor: kGoColor, side: const BorderSide(color: Color(0xFFE5E7EB)), padding: const EdgeInsets.symmetric(vertical: 12)),
          )),
          const SizedBox(width: 10),
          Expanded(child: OutlinedButton.icon(
            icon: const Icon(Icons.person_add, size: 18),
            label: const Text('Add Manual'),
            onPressed: () {},
            style: OutlinedButton.styleFrom(foregroundColor: kGoColor, side: const BorderSide(color: Color(0xFFE5E7EB)), padding: const EdgeInsets.symmetric(vertical: 12)),
          )),
        ]),
      ])),
      const SizedBox(height: 14),
      // Active batches
      const GoSectionHeader(title: 'Active Batches', icon: Icons.pending_actions),
      const SizedBox(height: 8),
      ...p.batchOperations.where((b) => b.type == BatchActionType.transfer).map((b) => _BatchCard(batch: b)),
      if (p.batchOperations.where((b) => b.type == BatchActionType.transfer).isEmpty)
        const GoEmptyState(icon: Icons.inbox, title: 'No batch transfers', message: 'Create one to get started.'),
    ]);
  }

  Widget _buildPaymentRuns(GoProvider p) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const GoSectionHeader(title: 'Payment Run Manager', icon: Icons.playlist_play),
        const SizedBox(height: 10),
        const Text('Schedule and manage recurring payment runs for payroll, vendor payments, and more.', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        const SizedBox(height: 14),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Create Payment Run'),
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: kGoColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        )),
      ])),
      const SizedBox(height: 14),
      ...p.batchOperations.where((b) => b.type == BatchActionType.tabSettlement).map((b) => _BatchCard(batch: b)),
      if (p.batchOperations.where((b) => b.type == BatchActionType.tabSettlement).isEmpty) ...[
        const SizedBox(height: 20),
        const GoEmptyState(icon: Icons.schedule, title: 'No payment runs', message: 'Set up automated payments.'),
      ],
    ]);
  }

  Widget _buildBulkApprove(GoProvider p) {
    final pending = p.batchOperations.where((b) => b.status == TransactionStatus.pending).toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      if (pending.isNotEmpty) ...[
        GoSectionCard(borderColor: kGoWarning.withOpacity(0.3), child: Row(children: [
          const Icon(Icons.warning_amber, color: kGoWarning, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text('${pending.length} operations pending approval', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF92400E)))),
        ])),
        const SizedBox(height: 14),
        // Approve all / Reject all
        Row(children: [
          Expanded(child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(foregroundColor: kGoNegative, side: const BorderSide(color: Color(0xFFE5E7EB)), padding: const EdgeInsets.symmetric(vertical: 12)),
            child: const Text('Reject All'),
          )),
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: kGoPositive, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Approve All'),
          )),
        ]),
        const SizedBox(height: 14),
      ],
      ...p.batchOperations.map((b) => _BatchCard(batch: b, showApproveReject: b.status == TransactionStatus.pending)),
      if (p.batchOperations.isEmpty)
        const GoEmptyState(icon: Icons.check_circle_outline, title: 'All clear', message: 'No operations needing approval.'),
    ]);
  }
}

class _BatchCard extends StatelessWidget {
  final BatchOperation batch;
  final bool showApproveReject;
  const _BatchCard({required this.batch, this.showApproveReject = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: kGoColorLight, borderRadius: BorderRadius.circular(8)),
            child: Icon(_typeIcon, color: kGoColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(batch.label ?? batch.typeLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Text('${batch.itemCount} items • ${batch.totalAmount.toStringAsFixed(0)} QP', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
          ])),
          _StatusChip(status: batch.status.name),
        ]),
        if (batch.progress > 0 && batch.progress < 1) ...[
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(value: batch.progress, minHeight: 4, backgroundColor: const Color(0xFFE5E7EB), valueColor: const AlwaysStoppedAnimation(kGoColor)))),
            const SizedBox(width: 8),
            Text('${(batch.progress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: kGoColor)),
          ]),
        ],
        if (showApproveReject) ...[
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(foregroundColor: kGoNegative, side: const BorderSide(color: Color(0xFFE5E7EB)), padding: const EdgeInsets.symmetric(vertical: 8)), child: const Text('Reject', style: TextStyle(fontSize: 12)))),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: kGoPositive, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Approve', style: TextStyle(fontSize: 12)))),
          ]),
        ],
      ]),
    );
  }

  IconData get _typeIcon {
    switch (batch.type) {
      case BatchActionType.transfer: return Icons.swap_horiz;
      case BatchActionType.tabSettlement: return Icons.playlist_play;
      case BatchActionType.close: return Icons.check_circle;
      case BatchActionType.reminder: return Icons.notifications;
      case BatchActionType.creditAdjust: return Icons.tune;
      case BatchActionType.export: return Icons.download;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});
  @override
  Widget build(BuildContext context) {
    Color c;
    switch (status) {
      case 'completed': c = kGoPositive;
      case 'processing': c = kGoInfo;
      case 'pending': c = kGoWarning;
      case 'failed': c = kGoNegative;
      default: c = const Color(0xFF9CA3AF);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: c)),
    );
  }
}
