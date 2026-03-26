/// GO Screen 12 — Reports Hub
/// Standard/custom reports, real-time dashboards, export options

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/go_models.dart';
import '../providers/go_provider.dart';
import '../widgets/go_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/widgets/ai_price_widgets.dart';

class GoReportsScreen extends StatefulWidget {
  const GoReportsScreen({super.key});
  @override
  State<GoReportsScreen> createState() => _GoReportsScreenState();
}

class _GoReportsScreenState extends State<GoReportsScreen> with SingleTickerProviderStateMixin {
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
        appBar: const GoAppBar(title: 'Reports'),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabCtrl,
                labelColor: kGoColor, unselectedLabelColor: const Color(0xFF9CA3AF),
                indicatorColor: kGoColor, indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                tabs: const [Tab(text: 'Standard'), Tab(text: 'Custom'), Tab(text: 'Saved')],
              ),
            ),
            Expanded(
              child: TabBarView(controller: _tabCtrl, children: [
                _buildStandardReports(),
                _buildCustomReports(provider),
                _buildSavedReports(provider),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardReports() {
    final reports = [
      ('Transaction Summary', 'Overview of all transactions for a period', Icons.receipt_long, ReportType.income),
      ('Cash Flow Statement', 'Inflows and outflows analysis', Icons.show_chart, ReportType.cashFlow),
      ('P&L Report', 'Profit and loss breakdown', Icons.bar_chart, ReportType.custom),
      ('Balance Sheet', 'Asset and liability summary', Icons.account_balance, ReportType.balanceSheet),
      ('Tax Report', 'Tax-ready transaction categorization', Icons.description, ReportType.agedDebtors),
      ('Tab Report', 'All active and settled tabs', Icons.receipt, ReportType.custom),
      ('Audit Report', 'Comprehensive audit trail', Icons.security, ReportType.custom),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ─── AI Spending Summary ─────────────────────────────
        Consumer<AIInsightsNotifier>(
          builder: (ctx, notifier, _) {
            if (notifier.spendingPattern == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AISpendingSummaryCard(
                spendingData: notifier.spendingPattern,
                isLoading: notifier.loadingInsights,
              ),
            );
          },
        ),
        // ─── Standard Report Tiles ─────────────────────────────
        ...reports.map((r) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
          child: ListTile(
            leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: kGoColorLight, borderRadius: BorderRadius.circular(8)), child: Icon(r.$3, color: kGoColor, size: 20)),
            title: Text(r.$1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: Text(r.$2, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: const Icon(Icons.visibility, size: 18, color: kGoColor), onPressed: () {}),
              IconButton(icon: const Icon(Icons.download, size: 18, color: Color(0xFF9CA3AF)), onPressed: () {}),
            ]),
          ),
        )),
      ],
    );
  }

  Widget _buildCustomReports(GoProvider p) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const GoSectionHeader(title: 'Build Custom Report', icon: Icons.build),
        const SizedBox(height: 12),
        // Date range
        const Text('DATE RANGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(child: const _DateField(label: 'From')),
          const SizedBox(width: 10),
          Expanded(child: const _DateField(label: 'To')),
        ]),
        const SizedBox(height: 14),
        // Report type
        const Text('REPORT TYPE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: 6, children: ['Transactions', 'Cash Flow', 'Tabs', 'P&L', 'Tax'].map((t) => FilterChip(
          label: Text(t, style: const TextStyle(fontSize: 11)),
          selected: t == 'Transactions',
          onSelected: (_) {},
          selectedColor: kGoColorLight,
          checkmarkColor: kGoColor,
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        )).toList()),
        const SizedBox(height: 14),
        // Filters
        const Text('FILTERS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: 6, children: ['All Types', 'Buy Only', 'Sell Only', 'Transfers', 'Tabs'].map((f) => FilterChip(
          label: Text(f, style: const TextStyle(fontSize: 11)),
          selected: f == 'All Types',
          onSelected: (_) {},
          selectedColor: kGoColorLight,
          checkmarkColor: kGoColor,
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        )).toList()),
        const SizedBox(height: 14),
        // Export format
        const Text('FORMAT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
        const SizedBox(height: 6),
        Row(children: [
          const _FormatChip(label: 'PDF', selected: true),
          const SizedBox(width: 8),
          const _FormatChip(label: 'CSV', selected: false),
          const SizedBox(width: 8),
          const _FormatChip(label: 'Excel', selected: false),
        ]),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(
          icon: const Icon(Icons.auto_awesome, size: 18),
          label: const Text('Generate Report'),
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: kGoColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        )),
      ])),
    ]);
  }

  Widget _buildSavedReports(GoProvider p) {
    final reports = p.reports;
    if (reports.isEmpty) return const GoEmptyState(icon: Icons.description, title: 'No saved reports', message: 'Generate a report to see it here.');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (_, i) {
        final r = reports[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: kGoColorLight, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.description, color: kGoColor, size: 20)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              Text('${r.type.name} • ${r.format} • ${r.generatedAt.day}/${r.generatedAt.month}/${r.generatedAt.year}', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
            ])),
            IconButton(icon: const Icon(Icons.download, size: 18, color: kGoColor), onPressed: () {}),
            IconButton(icon: const Icon(Icons.share, size: 18, color: Color(0xFF9CA3AF)), onPressed: () {}),
          ]),
        );
      },
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  const _DateField({required this.label});
  @override
  Widget build(BuildContext context) => TextField(
    readOnly: true,
    onTap: () {},
    decoration: InputDecoration(
      hintText: label, suffixIcon: const Icon(Icons.calendar_today, size: 16),
      filled: true, fillColor: const Color(0xFFF3F4F6),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    ),
    style: const TextStyle(fontSize: 13),
  );
}

class _FormatChip extends StatelessWidget {
  final String label; final bool selected;
  const _FormatChip({required this.label, required this.selected});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {},
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: selected ? kGoColor : Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: selected ? kGoColor : const Color(0xFFE5E7EB))),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : const Color(0xFF6B7280))),
    ),
  );
}
