/// GO Screen 10 — Financial Planner
/// Cash flow forecast, budget manager, goal setting

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/go_models.dart';
import '../providers/go_provider.dart';
import '../widgets/go_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class GoPlannerScreen extends StatefulWidget {
  const GoPlannerScreen({super.key});
  @override
  State<GoPlannerScreen> createState() => _GoPlannerScreenState();
}

class _GoPlannerScreenState extends State<GoPlannerScreen> with SingleTickerProviderStateMixin {
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
        appBar: const GoAppBar(title: 'Financial Planner'),
        body: Column(
          children: [
            Consumer<AIInsightsNotifier>(
              builder: (context, ai, _) {
                if (ai.insights.isEmpty) return const SizedBox.shrink();
                return Container(
                  color: kGoColor.withOpacity(0.07),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 14, color: kGoColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'AI: ${ai.insights.first['title'] ?? ''}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: kGoColor),
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
                tabs: const [Tab(text: 'Cash Flow'), Tab(text: 'Budget'), Tab(text: 'Goals')],
              ),
            ),
            Expanded(
              child: TabBarView(controller: _tabCtrl, children: [
                _buildCashFlow(provider),
                _buildBudget(provider),
                _buildGoals(provider),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashFlow(GoProvider p) {
    final forecast = p.cashFlowForecast;
    return ListView(padding: const EdgeInsets.all(16), children: [
      // Summary cards
      Row(children: [
        Expanded(child: _SummaryCard(label: 'Inflow (30d)', value: '${forecast.fold<double>(0, (s, c) => s + c.income).toStringAsFixed(0)} QP', color: kGoPositive)),
        const SizedBox(width: 10),
        Expanded(child: _SummaryCard(label: 'Outflow (30d)', value: '${forecast.fold<double>(0, (s, c) => s + c.expense).toStringAsFixed(0)} QP', color: kGoNegative)),
      ]),
      const SizedBox(height: 14),
      // Cash flow chart (simplified bars)
      GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const GoSectionHeader(title: '30-Day Cash Flow Forecast', icon: Icons.show_chart),
        const SizedBox(height: 12),
        ...forecast.map((point) {
          final net = point.income - point.expense;
          final maxVal = forecast.map((p) => p.income > p.expense ? p.income : p.expense).reduce((a, b) => a > b ? a : b);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              SizedBox(width: 60, child: Text(point.label, style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)))),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(flex: (point.income / maxVal * 100).round().clamp(1, 100).toInt(), child: Container(height: 6, decoration: BoxDecoration(color: kGoPositive, borderRadius: BorderRadius.circular(3)))),
                  Expanded(flex: (100 - (point.income / maxVal * 100).round()).clamp(1, 100).toInt(), child: const SizedBox()),
                ]),
                const SizedBox(height: 2),
                Row(children: [
                  Expanded(flex: (point.expense / maxVal * 100).round().clamp(1, 100).toInt(), child: Container(height: 6, decoration: BoxDecoration(color: kGoNegative.withOpacity(0.6), borderRadius: BorderRadius.circular(3)))),
                  Expanded(flex: (100 - (point.expense / maxVal * 100).round()).clamp(1, 100).toInt(), child: const SizedBox()),
                ]),
              ])),
              SizedBox(width: 60, child: Text('${net >= 0 ? '+' : ''}${net.toStringAsFixed(0)}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: net >= 0 ? kGoPositive : kGoNegative), textAlign: TextAlign.end)),
            ]),
          );
        }),
        const SizedBox(height: 8),
        Row(children: [
          const _LegendDot(color: kGoPositive, label: 'Inflow'),
          const SizedBox(width: 16),
          _LegendDot(color: kGoNegative.withOpacity(0.6), label: 'Outflow'),
        ]),
      ])),
      const SizedBox(height: 14),
      // AI Prediction
      GoSectionCard(borderColor: kGoInfo.withOpacity(0.3), child: const Row(children: [
        Icon(Icons.auto_awesome, size: 18, color: kGoInfo),
        SizedBox(width: 10),
        Expanded(child: Text('AI Prediction: Your net cash flow is expected to be positive for the next 30 days. Consider allocating surplus to savings goals.', style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF)))),
      ])),
    ]);
  }

  Widget _buildBudget(GoProvider p) {
    final cats = p.budgets;
    final totalBudget = cats.fold<double>(0, (s, c) => s + c.allocated);
    final totalSpent = cats.fold<double>(0, (s, c) => s + c.spent);
    final utilization = totalBudget > 0 ? totalSpent / totalBudget : 0.0;

    return ListView(padding: const EdgeInsets.all(16), children: [
      // Overall utilization
      GoSectionCard(child: Column(children: [
        const Text('BUDGET UTILIZATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
        const SizedBox(height: 10),
        SizedBox(
          height: 120, width: 120,
          child: Stack(alignment: Alignment.center, children: [
            SizedBox(height: 120, width: 120, child: CircularProgressIndicator(value: utilization, strokeWidth: 10, backgroundColor: const Color(0xFFE5E7EB), valueColor: AlwaysStoppedAnimation(utilization > 0.9 ? kGoNegative : utilization > 0.7 ? kGoWarning : kGoColor))),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text('${(utilization * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const Text('used', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
            ]),
          ]),
        ),
        const SizedBox(height: 10),
        Text('${totalSpent.toStringAsFixed(0)} / ${totalBudget.toStringAsFixed(0)} QP', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
      ])),
      const SizedBox(height: 14),
      const GoSectionHeader(title: 'Categories', icon: Icons.category),
      const SizedBox(height: 8),
      ...cats.map((c) => _BudgetCatRow(cat: c)),
      const SizedBox(height: 14),
      SizedBox(width: double.infinity, child: OutlinedButton.icon(
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add Category'),
        onPressed: () {},
        style: OutlinedButton.styleFrom(foregroundColor: kGoColor, side: const BorderSide(color: Color(0xFFE5E7EB)), padding: const EdgeInsets.symmetric(vertical: 12)),
      )),
    ]);
  }

  Widget _buildGoals(GoProvider p) {
    final goals = p.goals;
    return ListView(padding: const EdgeInsets.all(16), children: [
      ...goals.map((g) => _GoalCard(goal: g)),
      const SizedBox(height: 14),
      SizedBox(width: double.infinity, child: ElevatedButton.icon(
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Set New Goal'),
        onPressed: () {},
        style: ElevatedButton.styleFrom(backgroundColor: kGoColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      )),
    ]);
  }
}

class _SummaryCard extends StatelessWidget {
  final String label; final String value; final Color color;
  const _SummaryCard({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
    ]),
  );
}

class _LegendDot extends StatelessWidget {
  final Color color; final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
  ]);
}

class _BudgetCatRow extends StatelessWidget {
  final BudgetCategory cat;
  const _BudgetCatRow({required this.cat});
  @override
  Widget build(BuildContext context) {
    final pct = cat.allocated > 0 ? cat.spent / cat.allocated : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(cat.icon, size: 16, color: cat.color),
          const SizedBox(width: 8),
          Expanded(child: Text(cat.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          Text('${cat.spent.toStringAsFixed(0)} / ${cat.allocated.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
        ]),
        const SizedBox(height: 6),
        ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(
          value: pct.clamp(0, 1),
          minHeight: 5,
          backgroundColor: const Color(0xFFE5E7EB),
          valueColor: AlwaysStoppedAnimation(pct > 0.9 ? kGoNegative : pct > 0.7 ? kGoWarning : cat.color),
        )),
      ]),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final FinancialGoal goal;
  const _GoalCard({required this.goal});
  @override
  Widget build(BuildContext context) {
    final pct = goal.targetAmount > 0 ? goal.currentAmount / goal.targetAmount : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: kGoColorLight, borderRadius: BorderRadius.circular(8)), child: Icon(_goalIcon, color: kGoColor, size: 20)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(goal.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            Text(goal.type.name, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${(pct * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kGoColor)),
            Text('of ${goal.targetAmount.toStringAsFixed(0)} QP', style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
          ]),
        ]),
        const SizedBox(height: 10),
        ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: pct.clamp(0, 1), minHeight: 8, backgroundColor: const Color(0xFFE5E7EB), valueColor: const AlwaysStoppedAnimation(kGoColor))),
        const SizedBox(height: 6),
        Row(children: [
          Text('${goal.currentAmount.toStringAsFixed(0)} QP saved', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
          const Spacer(),
          Text('Due: ${goal.targetDate.day}/${goal.targetDate.month}/${goal.targetDate.year}', style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
        ]),
      ]),
    );
  }

  IconData get _goalIcon {
    switch (goal.type) {
      case GoalType.savings: return Icons.savings;
      case GoalType.investment: return Icons.trending_up;
      case GoalType.debtReduction: return Icons.money_off;
      case GoalType.revenue: return Icons.shield;
      case GoalType.custom: return Icons.flag;
    }
  }
}
