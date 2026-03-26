/// GO Screen 11 — Tax & Compliance
/// Transaction categorization, report generator, regulatory dashboard

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../models/go_models.dart';
import '../providers/go_provider.dart';
import '../widgets/go_widgets.dart';

class GoTaxScreen extends StatefulWidget {
  const GoTaxScreen({super.key});
  @override
  State<GoTaxScreen> createState() => _GoTaxScreenState();
}

class _GoTaxScreenState extends State<GoTaxScreen> with SingleTickerProviderStateMixin {
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
        appBar: const GoAppBar(title: 'Tax & Compliance'),
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
                          'AI tax: ${ai.insights.first['title'] ?? ''}',
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
                tabs: const [Tab(text: 'Tax Summary'), Tab(text: 'Compliance'), Tab(text: 'Documents')],
              ),
            ),
            Expanded(
              child: TabBarView(controller: _tabCtrl, children: [
                _buildTaxSummary(provider),
                _buildCompliance(provider),
                _buildDocuments(provider),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxSummary(GoProvider p) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      // Period selector
      GoSectionCard(child: Row(children: [
        const Icon(Icons.calendar_month, size: 18, color: kGoColor),
        const SizedBox(width: 8),
        const Text('Tax Year 2024', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const Spacer(),
        TextButton(onPressed: () {}, child: const Text('Change', style: TextStyle(fontSize: 12, color: kGoColor))),
      ])),
      const SizedBox(height: 14),
      // Summary cards
      Row(children: [
        Expanded(child: _TaxCard(label: 'Total Income', value: '125,000 QP', icon: Icons.arrow_downward, color: kGoPositive)),
        const SizedBox(width: 10),
        Expanded(child: _TaxCard(label: 'Total Expenses', value: '87,500 QP', icon: Icons.arrow_upward, color: kGoNegative)),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _TaxCard(label: 'Tax Liability', value: '5,625 QP', icon: Icons.account_balance, color: kGoWarning)),
        const SizedBox(width: 10),
        Expanded(child: _TaxCard(label: 'Net Profit', value: '37,500 QP', icon: Icons.trending_up, color: kGoInfo)),
      ]),
      const SizedBox(height: 14),
      // Tax entries
      const GoSectionHeader(title: 'Tax Entries', icon: Icons.receipt),
      const SizedBox(height: 8),
      ...p.taxEntries.map((entry) => _TaxEntryRow(entry: entry)),
      const SizedBox(height: 14),
      SizedBox(width: double.infinity, child: OutlinedButton.icon(
        icon: const Icon(Icons.download, size: 18),
        label: const Text('Export Tax Report'),
        onPressed: () {},
        style: OutlinedButton.styleFrom(foregroundColor: kGoColor, side: const BorderSide(color: Color(0xFFE5E7EB)), padding: const EdgeInsets.symmetric(vertical: 12)),
      )),
    ]);
  }

  Widget _buildCompliance(GoProvider p) {
    final checks = p.complianceChecks;
    final passed = checks.where((c) => c.status == ComplianceStatus.compliant).length;
    final failed = checks.where((c) => c.status == ComplianceStatus.nonCompliant).length;

    return ListView(padding: const EdgeInsets.all(16), children: [
      // Compliance score
      GoSectionCard(child: Column(children: [
        const Text('COMPLIANCE SCORE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
        const SizedBox(height: 10),
        SizedBox(
          height: 100, width: 100,
          child: Stack(alignment: Alignment.center, children: [
            SizedBox(height: 100, width: 100, child: CircularProgressIndicator(value: checks.isNotEmpty ? passed / checks.length : 0, strokeWidth: 8, backgroundColor: const Color(0xFFE5E7EB), valueColor: const AlwaysStoppedAnimation(kGoPositive))),
            Text('${checks.isNotEmpty ? (passed / checks.length * 100).toStringAsFixed(0) : 0}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kGoPositive)),
          ]),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _ComplianceBadge(label: '$passed Passed', color: kGoPositive),
          const SizedBox(width: 8),
          _ComplianceBadge(label: '$failed Issues', color: failed > 0 ? kGoNegative : kGoPositive),
        ]),
      ])),
      const SizedBox(height: 14),
      const GoSectionHeader(title: 'Compliance Checks', icon: Icons.verified_user),
      const SizedBox(height: 8),
      ...checks.map((c) => _ComplianceRow(check: c)),
    ]);
  }

  Widget _buildDocuments(GoProvider p) {
    final docs = [
      ('Tax Certificate 2024', 'PDF', '2.3 MB', Icons.picture_as_pdf, kGoNegative),
      ('KYC Verification', 'Verified', '—', Icons.verified, kGoPositive),
      ('AML Report Q4', 'PDF', '1.1 MB', Icons.picture_as_pdf, kGoNegative),
      ('Transaction Summary', 'CSV', '456 KB', Icons.table_chart, kGoInfo),
      ('Compliance Audit', 'PDF', '3.7 MB', Icons.picture_as_pdf, kGoNegative),
    ];

    return ListView(padding: const EdgeInsets.all(16), children: [
      GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const GoSectionHeader(title: 'Generate Report', icon: Icons.auto_awesome),
        const SizedBox(height: 10),
        const Text('Auto-generate tax and compliance reports from your transaction data.', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(
          icon: const Icon(Icons.description, size: 18),
          label: const Text('Generate Report'),
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: kGoColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        )),
      ])),
      const SizedBox(height: 14),
      const GoSectionHeader(title: 'Saved Documents', icon: Icons.folder),
      const SizedBox(height: 8),
      ...docs.map((d) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE5E7EB))),
        child: ListTile(
          leading: Icon(d.$4, color: d.$5, size: 24),
          title: Text(d.$1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          subtitle: Text('${d.$2} • ${d.$3}', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
          trailing: IconButton(icon: const Icon(Icons.download, size: 18, color: kGoColor), onPressed: () {}),
          dense: true,
        ),
      )),
    ]);
  }
}

class _TaxCard extends StatelessWidget {
  final String label; final String value; final IconData icon; final Color color;
  const _TaxCard({required this.label, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 14, color: color),
        const Spacer(),
      ]),
      const SizedBox(height: 6),
      Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
      Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
    ]),
  );
}

class _TaxEntryRow extends StatelessWidget {
  final TaxEntry entry;
  const _TaxEntryRow({required this.entry});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(entry.category.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          Text(entry.description, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${entry.amount.toStringAsFixed(0)} QP', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: entry.isCategorized ? kGoPositive : const Color(0xFF1A1A1A))),
          if (entry.isCategorized) const Text('Deductible', style: TextStyle(fontSize: 9, color: kGoPositive, fontWeight: FontWeight.w600)),
        ]),
      ]),
    );
  }
}

class _ComplianceBadge extends StatelessWidget {
  final String label; final Color color;
  const _ComplianceBadge({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
    child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
  );
}

class _ComplianceRow extends StatelessWidget {
  final ComplianceCheck check;
  const _ComplianceRow({required this.check});
  @override
  Widget build(BuildContext context) {
    Color c; IconData ic;
    switch (check.status) {
      case ComplianceStatus.compliant: c = kGoPositive; ic = Icons.check_circle;
      case ComplianceStatus.nonCompliant: c = kGoNegative; ic = Icons.cancel;
      case ComplianceStatus.actionRequired: c = kGoWarning; ic = Icons.hourglass_bottom;
      case ComplianceStatus.pending: c = const Color(0xFF9CA3AF); ic = Icons.schedule;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Row(children: [
        Icon(ic, size: 20, color: c),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(check.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          Text(check.description, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(check.status.name, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: c))),
      ]),
    );
  }
}
