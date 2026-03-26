/// GO Screen 4 — My Tabs
/// Credit health dashboard, filter bar, accordion tab cards,
/// bulk operations, analytics panel

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/go_models.dart';
import '../providers/go_provider.dart';
import '../widgets/go_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class GoTabsScreen extends StatefulWidget {
  const GoTabsScreen({super.key});
  @override
  State<GoTabsScreen> createState() => _GoTabsScreenState();
}

class _GoTabsScreenState extends State<GoTabsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  TabStatus? _filter;
  bool _showAnalytics = false;

  @override
  void initState() { super.initState(); _tabCtrl = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoProvider>(
      builder: (context, provider, _) {
        final tabs = _filter == null ? provider.tabs : provider.tabs.where((t) => t.status == _filter).toList();
        final totalOwed = provider.tabs.fold<double>(0, (s, t) => s + t.currentBalance);
        final totalOwe = provider.tabs.fold<double>(0, (s, t) => s + t.minimumDue);

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: const GoAppBar(title: 'My Tabs'),
          body: Column(
            children: [
              // Credit health summary
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(children: [
                  Expanded(child: _SummaryBox(label: 'OWED TO ME', value: '${totalOwed.toStringAsFixed(0)} QP', color: kGoPositive)),
                  const SizedBox(width: 10),
                  Expanded(child: _SummaryBox(label: 'I OWE', value: '${totalOwe.toStringAsFixed(0)} QP', color: kGoNegative)),
                  const SizedBox(width: 10),
                  Expanded(child: _SummaryBox(label: 'NET', value: '${(totalOwed - totalOwe).toStringAsFixed(0)} QP', color: totalOwed >= totalOwe ? kGoPositive : kGoNegative)),
                ]),
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
              // Filter + tabs
              Container(
                color: Colors.white,
                child: Column(children: [
                  TabBar(
                    controller: _tabCtrl,
                    labelColor: kGoColor, unselectedLabelColor: const Color(0xFF9CA3AF),
                    indicatorColor: kGoColor, indicatorSize: TabBarIndicatorSize.label,
                    labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    tabs: [
                      Tab(text: 'All (${provider.tabs.length})'),
                      Tab(text: 'Active (${provider.tabs.where((t) => t.status == TabStatus.active).length})'),
                      Tab(text: 'Overdue (${provider.tabs.where((t) => t.status == TabStatus.overdue).length})'),
                    ],
                  ),
                  // Status filter chips
                  SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      children: [
                        _FilterChip(label: 'All', selected: _filter == null, onTap: () => setState(() => _filter = null)),
                        ...TabStatus.values.map((s) => _FilterChip(label: s.name[0].toUpperCase() + s.name.substring(1), selected: _filter == s, onTap: () => setState(() => _filter = s))),
                      ],
                    ),
                  ),
                ]),
              ),
              // Toggle analytics
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(children: [
                  Text('${tabs.length} tabs', style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _showAnalytics = !_showAnalytics),
                    child: Row(children: [
                      Icon(_showAnalytics ? Icons.bar_chart : Icons.bar_chart_outlined, size: 16, color: kGoColor),
                      const SizedBox(width: 4),
                      Text(_showAnalytics ? 'Hide' : 'Analytics', style: const TextStyle(fontSize: 11, color: kGoColor, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ]),
              ),
              if (_showAnalytics) _buildAnalytics(provider),
              // Tab list
              Expanded(
                child: TabBarView(controller: _tabCtrl, children: [
                  _buildTabList(tabs),
                  _buildTabList(tabs.where((t) => t.status == TabStatus.active).toList()),
                  _buildTabList(tabs.where((t) => t.status == TabStatus.overdue).toList()),
                ]),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {},
            backgroundColor: kGoColor,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('New Tab', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        );
      },
    );
  }

  Widget _buildAnalytics(GoProvider p) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('TAB ANALYTICS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _AnalyticStat(label: 'Active', value: '${p.tabs.where((t) => t.status == TabStatus.active).length}', color: kGoColor)),
          Expanded(child: _AnalyticStat(label: 'Overdue', value: '${p.tabs.where((t) => t.status == TabStatus.overdue).length}', color: kGoNegative)),
          Expanded(child: _AnalyticStat(label: 'Settled', value: '${p.tabs.where((t) => t.status == TabStatus.settled).length}', color: kGoPositive)),
          Expanded(child: const _AnalyticStat(label: 'Avg Days', value: '14', color: kGoInfo)),
        ]),
      ]),
    );
  }

  Widget _buildTabList(List<GoTab> tabs) {
    if (tabs.isEmpty) return const GoEmptyState(icon: Icons.receipt_long, title: 'No tabs found', message: 'Adjust filters or create a new tab.');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tabs.length,
      itemBuilder: (_, i) => GoTabCard(tab: tabs[i], onTap: () => Navigator.pushNamed(context, '/go/tab-detail', arguments: tabs[i].id)),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String label; final String value; final Color color;
  const _SummaryBox({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
    child: Column(children: [
      Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
    ]),
  );
}

class _FilterChip extends StatelessWidget {
  final String label; final bool selected; final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 6),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: selected ? kGoColor : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: selected ? kGoColor : const Color(0xFFE5E7EB))),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: selected ? Colors.white : const Color(0xFF6B7280))),
      ),
    ),
  );
}

class _AnalyticStat extends StatelessWidget {
  final String label; final String value; final Color color;
  const _AnalyticStat({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
    Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
  ]);
}
