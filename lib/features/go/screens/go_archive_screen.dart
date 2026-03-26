/// GO Screen 15 — Archive & History
/// Transaction archive, historical analysis, compliance storage

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../models/go_models.dart';
import '../providers/go_provider.dart';
import '../widgets/go_widgets.dart';

class GoArchiveScreen extends StatefulWidget {
  const GoArchiveScreen({super.key});
  @override
  State<GoArchiveScreen> createState() => _GoArchiveScreenState();
}

class _GoArchiveScreenState extends State<GoArchiveScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() { super.initState(); _tabCtrl = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tabCtrl.dispose(); _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoProvider>(
      builder: (context, provider, _) => Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        appBar: const GoAppBar(title: 'Archive & History'),
        body: Column(
          children: [
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search archive...', prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true, fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
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
              color: Colors.transparent,
              child: TabBar(
                controller: _tabCtrl,
                labelColor: kGoColor, unselectedLabelColor: const Color(0xFF9CA3AF),
                indicatorColor: kGoColor, indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                tabs: const [Tab(text: 'Transactions'), Tab(text: 'Analysis'), Tab(text: 'Compliance')],
              ),
            ),
            Expanded(
              child: TabBarView(controller: _tabCtrl, children: [
                _buildTransactionArchive(provider),
                _buildAnalysis(provider),
                _buildComplianceStorage(provider),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionArchive(GoProvider p) {
    var archives = p.archives;
    if (_searchQuery.isNotEmpty) {
      archives = archives.where((a) => a.title.toLowerCase().contains(_searchQuery.toLowerCase()) || a.type.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return Column(
      children: [
        // Filter bar
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            children: ['All', 'Last 30d', 'Last 90d', 'This Year', '2023'].map((f) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: f == 'All' ? kGoColor : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: f == 'All' ? kGoColor : const Color(0xFFE5E7EB))),
                  child: Text(f, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: f == 'All' ? Colors.white : const Color(0xFF6B7280))),
                ),
              ),
            )).toList(),
          ),
        ),
        Expanded(
          child: archives.isEmpty
            ? const GoEmptyState(icon: Icons.archive, title: 'No archived records', message: 'Completed transactions will appear here.')
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: archives.length,
                itemBuilder: (_, i) => _ArchiveCard(record: archives[i]),
              ),
        ),
      ],
    );
  }

  Widget _buildAnalysis(GoProvider p) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      // Spending trends
      GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const GoSectionHeader(title: 'Spending Trends', icon: Icons.trending_down),
        const SizedBox(height: 12),
        const _TrendRow(month: 'January', amount: 12500, maxAmount: 18000),
        const _TrendRow(month: 'February', amount: 15200, maxAmount: 18000),
        const _TrendRow(month: 'March', amount: 18000, maxAmount: 18000),
        const _TrendRow(month: 'April', amount: 11800, maxAmount: 18000),
        const _TrendRow(month: 'May', amount: 14300, maxAmount: 18000),
        const _TrendRow(month: 'June', amount: 16700, maxAmount: 18000),
      ])),
      const SizedBox(height: 14),
      // Top parties
      GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const GoSectionHeader(title: 'Top Transaction Partners', icon: Icons.people),
        const SizedBox(height: 10),
        const _TopPartyRow(rank: 1, name: 'Kofi Electronics', amount: '45,200 QP', txns: 28),
        const _TopPartyRow(rank: 2, name: 'Ama Trading', amount: '32,100 QP', txns: 15),
        const _TopPartyRow(rank: 3, name: 'Kwesi Mensah', amount: '18,500 QP', txns: 42),
        const _TopPartyRow(rank: 4, name: 'TechHub GH', amount: '12,800 QP', txns: 8),
        const _TopPartyRow(rank: 5, name: 'Abena Services', amount: '9,300 QP', txns: 11),
      ])),
      const SizedBox(height: 14),
      // Category breakdown
      GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const GoSectionHeader(title: 'Category Distribution', icon: Icons.pie_chart),
        const SizedBox(height: 10),
        SizedBox(height: 150, child: Center(child: GoDonutChart(
          values: const [42, 28, 18, 12],
          colors: const [kGoColor, kGoInfo, kGoWarning, kGoPurple],
        ))),
      ])),
    ]);
  }

  Widget _buildComplianceStorage(GoProvider p) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      GoSectionCard(borderColor: kGoInfo.withOpacity(0.3), child: const Row(children: [
        Icon(Icons.info_outline, size: 18, color: kGoInfo),
        SizedBox(width: 10),
        Expanded(child: Text('All transaction records are retained for 7 years in compliance with regulatory requirements.', style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF)))),
      ])),
      const SizedBox(height: 14),
      GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const GoSectionHeader(title: 'Data Retention', icon: Icons.storage),
        const SizedBox(height: 10),
        const _RetentionRow(label: 'Transaction Records', period: '7 years', usage: '2.3 GB'),
        const _RetentionRow(label: 'Audit Logs', period: '5 years', usage: '890 MB'),
        const _RetentionRow(label: 'Documents', period: '10 years', usage: '1.1 GB'),
        const _RetentionRow(label: 'Communication Logs', period: '3 years', usage: '340 MB'),
      ])),
      const SizedBox(height: 14),
      GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const GoSectionHeader(title: 'Export Options', icon: Icons.download),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _ExportBtn(icon: Icons.picture_as_pdf, label: 'PDF', onTap: () {})),
          const SizedBox(width: 8),
          Expanded(child: _ExportBtn(icon: Icons.table_chart, label: 'CSV', onTap: () {})),
          const SizedBox(width: 8),
          Expanded(child: _ExportBtn(icon: Icons.grid_on, label: 'Excel', onTap: () {})),
          const SizedBox(width: 8),
          Expanded(child: _ExportBtn(icon: Icons.data_object, label: 'JSON', onTap: () {})),
        ]),
      ])),
      const SizedBox(height: 14),
      SizedBox(width: double.infinity, child: OutlinedButton.icon(
        icon: const Icon(Icons.delete_sweep, size: 18),
        label: const Text('Request Data Deletion'),
        onPressed: () {},
        style: OutlinedButton.styleFrom(foregroundColor: kGoNegative, side: const BorderSide(color: Color(0xFFE5E7EB)), padding: const EdgeInsets.symmetric(vertical: 12)),
      )),
    ]);
  }
}

class _ArchiveCard extends StatelessWidget {
  final ArchivedRecord record;
  const _ArchiveCard({required this.record});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: kGoColorLight, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.archive_outlined, color: kGoColor, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(record.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          Text(record.period, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
          Text('${record.archivedAt.day}/${record.archivedAt.month}/${record.archivedAt.year}', style: const TextStyle(fontSize: 10, color: Color(0xFFD1D5DB))),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${record.totalValue.toStringAsFixed(0)} QP', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kGoColor)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(color: const Color(0xFF9CA3AF).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(record.type, style: const TextStyle(fontSize: 9, color: Color(0xFF9CA3AF))),
          ),
        ]),
      ]),
    );
  }
}

class _TrendRow extends StatelessWidget {
  final String month; final double amount; final double maxAmount;
  const _TrendRow({required this.month, required this.amount, required this.maxAmount});
  @override
  Widget build(BuildContext context) {
    final pct = amount / maxAmount;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        SizedBox(width: 60, child: Text(month, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)))),
        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(value: pct, minHeight: 8, backgroundColor: const Color(0xFFE5E7EB), valueColor: const AlwaysStoppedAnimation(kGoColor)))),
        SizedBox(width: 60, child: Text('${(amount / 1000).toStringAsFixed(1)}K', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.end)),
      ]),
    );
  }
}

class _TopPartyRow extends StatelessWidget {
  final int rank; final String name; final String amount; final int txns;
  const _TopPartyRow({required this.rank, required this.name, required this.amount, required this.txns});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Container(
        width: 24, height: 24,
        decoration: BoxDecoration(color: rank <= 3 ? kGoColor.withOpacity(0.1) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(6)),
        alignment: Alignment.center,
        child: Text('$rank', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: rank <= 3 ? kGoColor : const Color(0xFF9CA3AF))),
      ),
      const SizedBox(width: 8),
      Expanded(child: Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(amount, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        Text('$txns txns', style: const TextStyle(fontSize: 9, color: Color(0xFF9CA3AF))),
      ]),
    ]),
  );
}

class _RetentionRow extends StatelessWidget {
  final String label; final String period; final String usage;
  const _RetentionRow({required this.label, required this.period, required this.usage});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)))),
      Text(period, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      const SizedBox(width: 12),
      Text(usage, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
    ]),
  );
}

class _ExportBtn extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _ExportBtn({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: kGoColorLight, borderRadius: BorderRadius.circular(8)),
      child: Column(children: [
        Icon(icon, color: kGoColor, size: 20),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: kGoColor)),
      ]),
    ),
  );
}
