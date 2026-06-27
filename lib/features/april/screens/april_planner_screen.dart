/// APRIL Screen 2  Planner Command Center (Financial Dashboard)
/// 4 tabs: Overview, Transactions, Budgets, Analytics
library;

import 'package:flutter/material.dart';
import '../../../core/utils/app_toast.dart';
import 'package:provider/provider.dart';
import '../models/april_models.dart';
import '../providers/april_provider.dart';
import '../widgets/april_widgets.dart';
import '../../../core/design/ive.dart';
import '../../../core/routes/app_routes.dart';

class AprilPlannerScreen extends StatefulWidget {
  const AprilPlannerScreen({super.key});

  @override
  State<AprilPlannerScreen> createState() => _AprilPlannerScreenState();
}

class _AprilPlannerScreenState extends State<AprilPlannerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<AprilProvider>().setPlannerTab(PlannerTab.values[_tabController.index]);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AprilProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: IveTokens.bg,
          appBar: AprilAppBar(
            title: 'Planner',
            actions: [
              IconButton(icon: const Icon(Icons.download, size: 22), onPressed: () => AppToast.show(context, 'Downloading...')),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: IveTokens.genieBright,
              unselectedLabelColor: IveTokens.ink2,
              indicatorColor: IveTokens.genie,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Transactions'),
                Tab(text: 'Budgets'),
                Tab(text: 'Analytics'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _OverviewTab(provider: provider),
              _TransactionsTab(provider: provider),
              _BudgetsTab(provider: provider),
              _AnalyticsTab(provider: provider),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddTransaction(context, provider),
            backgroundColor: IveTokens.genie,
            foregroundColor: IveTokens.bg,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Add', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        );
      },
    );
  }

  void _showAddTransaction(BuildContext context, AprilProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: IveTokens.hairline2, borderRadius: BorderRadius.circular(IveTokens.rXs))),
            ),
            const SizedBox(height: 16),
            const Text('Add Transaction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Quick add a new transaction', style: TextStyle(fontSize: 13, color: IveTokens.mute)),
            const SizedBox(height: 20),

            // Quick Add Presets
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuickAddChip(label: ' Coffee', amount: '15.00', category: TransactionCategory.dining),
                _QuickAddChip(label: ' Ride', amount: '25.00', category: TransactionCategory.transport),
                _QuickAddChip(label: 'Groceries', amount: '120.00', category: TransactionCategory.groceries),
                _QuickAddChip(label: 'Medicine', amount: '45.00', category: TransactionCategory.healthcare),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.edit, color: IveTokens.genieBright),
              title: const Text('Detailed Entry', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Add with full details', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }
}

// 
// Tab 1: OVERVIEW
// 
class _OverviewTab extends StatelessWidget {
  final AprilProvider provider;
  const _OverviewTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final summary = provider.monthlySummary;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Balance Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [IveTokens.surfaceRaised, IveTokens.surface],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(IveTokens.rSm),
            border: Border.all(color: IveTokens.hairline2, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Current Balance', style: TextStyle(color: IveTokens.ink2, fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                '${summary.currentBalance.toStringAsFixed(2)}',
                style: IveType.title1.copyWith(color: IveTokens.ink),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _BalanceStat(label: 'Income', value: '${summary.totalIncome.toStringAsFixed(0)}', icon: Icons.arrow_upward, color: IveTokens.success),
                  const SizedBox(width: 20),
                  _BalanceStat(label: 'Expenses', value: '${summary.totalExpenses.toStringAsFixed(0)}', icon: Icons.arrow_downward, color: IveTokens.danger),
                  const SizedBox(width: 20),
                  _BalanceStat(label: 'Savings', value: '${summary.savingsRate.toStringAsFixed(0)}%', icon: Icons.savings, color: IveTokens.genie),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // AI Spending Insights

        // Monthly Summary Row
        Row(
          children: [
            Expanded(child: _SummaryMini(emoji: '', title: 'Transactions', value: '${provider.transactions.length}')),
            const SizedBox(width: 12),
            Expanded(child: _SummaryMini(emoji: '', title: 'Bills Due', value: '${provider.upcomingBills.length}')),
            const SizedBox(width: 12),
            Expanded(child: _SummaryMini(emoji: '', title: 'Budgets', value: '${provider.budgetCategories.length}')),
          ],
        ),
        const SizedBox(height: 16),

        // Upcoming Bills
        AprilSectionCard(
          title: ' Upcoming Bills',
          trailing: TextButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.aprilStatement),
            child: const Text('See all', style: TextStyle(fontSize: 12, color: IveTokens.genieBright)),
          ),
          child: Column(
            children: provider.upcomingBills.map((bill) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: bill.isOverdue
                          ? IveTokens.danger.withValues(alpha: 0.1)
                          : IveTokens.genie.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(IveTokens.rSm),
                    ),
                    child: Icon(
                      Icons.receipt_long,
                      size: 18,
                      color: bill.isOverdue ? IveTokens.danger : IveTokens.genieBright,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(bill.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        Text(
                          bill.isOverdue
                              ? 'Overdue!'
                              : 'Due in ${bill.dueDate.difference(DateTime.now()).inDays} days',
                          style: TextStyle(
                            fontSize: 11,
                            color: bill.isOverdue ? IveTokens.danger : IveTokens.mute,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${bill.amount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Recent Transactions
        AprilSectionCard(
          title: ' Recent Transactions',
          trailing: TextButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.aprilStatement),
            child: const Text('View all', style: TextStyle(fontSize: 12, color: IveTokens.genieBright)),
          ),
          child: Column(
            children: provider.transactions.take(5).map((t) => TransactionCard(transaction: t)).toList(),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

// 
// Tab 2: TRANSACTIONS
// 
class _TransactionsTab extends StatelessWidget {
  final AprilProvider provider;
  const _TransactionsTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final filtered = provider.filteredTransactions;
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            onChanged: provider.setTransactionSearch,
            decoration: InputDecoration(
              hintText: 'Search transactions...',
              hintStyle: const TextStyle(fontSize: 14, color: IveTokens.ink2),
              prefixIcon: const Icon(Icons.search, color: IveTokens.ink2),
              filled: true,
              fillColor: IveTokens.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(IveTokens.rSm),
                borderSide: const BorderSide(color: IveTokens.hairline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(IveTokens.rSm),
                borderSide: const BorderSide(color: IveTokens.hairline),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),

        // Category Filters
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _FilterChip(
                label: 'All',
                selected: provider.categoryFilter == null,
                onTap: () => provider.setCategoryFilter(null),
              ),
              ...TransactionCategory.values.take(8).map((c) => _FilterChip(
                label: _categoryLabel(c),
                selected: provider.categoryFilter == c,
                onTap: () => provider.setCategoryFilter(c),
              )),
            ],
          ),
        ),

        // Transaction List
        Expanded(
          child: filtered.isEmpty
              ? const AprilEmptyState(
                  icon: Icons.receipt_long,
                  title: 'No transactions found',
                  message: 'Try a different search or filter',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => TransactionCard(transaction: filtered[i]),
                ),
        ),
      ],
    );
  }

  String _categoryLabel(TransactionCategory c) {
    switch (c) {
      case TransactionCategory.dining: return ' Dining';
      case TransactionCategory.groceries: return 'Groceries';
      case TransactionCategory.transport: return ' Transport';
      case TransactionCategory.healthcare: return 'Health';
      case TransactionCategory.entertainment: return ' Fun';
      case TransactionCategory.shopping: return ' Shop';
      case TransactionCategory.utilities: return ' Bills';
      case TransactionCategory.education: return ' Edu';
      default: return c.name;
    }
  }
}

// 
// Tab 3: BUDGETS
// 
class _BudgetsTab extends StatelessWidget {
  final AprilProvider provider;
  const _BudgetsTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Budget Summary Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: IveTokens.surface,
            borderRadius: BorderRadius.circular(IveTokens.rSm),
            border: Border.all(color: IveTokens.hairline),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Budget', style: TextStyle(fontSize: 13, color: IveTokens.mute)),
                  Text(
                    '${provider.budgetCategories.fold<double>(0, (sum, b) => sum + b.limit).toStringAsFixed(0)}',
                    style: IveType.monoEmphasis.copyWith(fontSize: 16, color: IveTokens.ink),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Spent', style: TextStyle(fontSize: 13, color: IveTokens.mute)),
                  Text(
                    '${provider.budgetCategories.fold<double>(0, (sum, b) => sum + b.spent).toStringAsFixed(0)}',
                    style: IveType.monoEmphasis.copyWith(fontSize: 16, color: IveTokens.danger),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(IveTokens.rXs),
                child: LinearProgressIndicator(
                  value: (provider.budgetCategories.fold<double>(0, (s, b) => s + b.spent) /
                      provider.budgetCategories.fold<double>(0, (s, b) => s + b.limit))
                      .clamp(0.0, 1.0),
                  backgroundColor: IveTokens.hairline,
                  valueColor: const AlwaysStoppedAnimation(IveTokens.genie),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Budget Categories
        ...provider.budgetCategories.map((b) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: BudgetProgressBar(budget: b),
        )),

        const SizedBox(height: 16),

        // AI Suggestion
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: IveTokens.accentSoft,
            borderRadius: BorderRadius.circular(IveTokens.rSm),
            border: Border.all(color: IveTokens.accent.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Text('', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Budget Insight', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: IveTokens.ink)),
                    const SizedBox(height: 2),
                    Text(
                      'Your dining spend is ${provider.budgetCategories.isNotEmpty ? '34%' : '0%'} higher than last month. Consider setting a weekly limit.',
                      style: const TextStyle(fontSize: 12, color: IveTokens.mute),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

// 
// Tab 4: ANALYTICS
// 
class _AnalyticsTab extends StatelessWidget {
  final AprilProvider provider;
  const _AnalyticsTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final fh = provider.financialHealth;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Financial Health Score
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: IveTokens.surface,
            borderRadius: BorderRadius.circular(IveTokens.rSm),
            border: Border.all(color: IveTokens.hairline),
          ),
          child: Column(
            children: [
              const Text('Financial Health Score', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: IveTokens.ink)),
              const SizedBox(height: 16),
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: fh.score / 100,
                        strokeWidth: 10,
                        backgroundColor: IveTokens.hairline,
                        valueColor: AlwaysStoppedAnimation(_scoreColor(fh.score)),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${fh.score}', style: IveType.monoEmphasis.copyWith(fontSize: 32, color: _scoreColor(fh.score))),
                        Text(fh.grade, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: IveTokens.mute)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(fh.summary, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: IveTokens.mute)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Spending Trend
        AprilSectionCard(
          title: ' Spending Trend',
          child: SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: provider.spendingData.map((dp) {
                final maxVal = provider.spendingData.map((d) => d.amount).reduce((a, b) => a > b ? a : b);
                final height = maxVal > 0 ? (dp.amount / maxVal) * 120 : 0.0;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${(dp.amount / 1000).toStringAsFixed(1)}k',
                        style: IveType.monoSmall.copyWith(fontSize: 9),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 28,
                        height: height,
                        decoration: BoxDecoration(
                          color: dp.label == provider.spendingData.last.label
                              ? IveTokens.genie
                              : IveTokens.genie.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(IveTokens.rXs),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(dp.label, style: const TextStyle(fontSize: 10, color: IveTokens.mute)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Improvement Tips
        AprilSectionCard(
          title: ' Improvement Tips',
          child: Column(
            children: fh.tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('', style: TextStyle(fontSize: 16, color: IveTokens.genieBright)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(tip, style: const TextStyle(fontSize: 13, color: IveTokens.mute))),
                ],
              ),
            )).toList(),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Color _scoreColor(int score) {
    if (score >= 80) return IveTokens.success;
    if (score >= 60) return IveTokens.genie;
    return IveTokens.danger;
  }
}

// 
// SHARED MINI WIDGETS
// 

class _BalanceStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _BalanceStat({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: IveTokens.ink2, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 2),
        Text(value, style: IveType.monoEmphasis.copyWith(fontSize: 14, color: IveTokens.ink)),
      ],
    );
  }
}

class _SummaryMini extends StatelessWidget {
  final String emoji, title, value;
  const _SummaryMini({required this.emoji, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: IveTokens.surface,
        borderRadius: BorderRadius.circular(IveTokens.rSm),
        border: Border.all(color: IveTokens.hairline),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(value, style: IveType.monoEmphasis.copyWith(fontSize: 18, color: IveTokens.ink)),
          Text(title, style: const TextStyle(fontSize: 11, color: IveTokens.mute)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? IveTokens.genie : IveTokens.surface,
          borderRadius: BorderRadius.circular(IveTokens.rSm),
          border: Border.all(color: selected ? IveTokens.genie : IveTokens.hairline),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected ? IveTokens.bg : IveTokens.mute,
          ),
        ),
      ),
    );
  }
}

class _QuickAddChip extends StatelessWidget {
  final String label, amount;
  final TransactionCategory category;
  const _QuickAddChip({required this.label, required this.amount, required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: IveTokens.genie.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(IveTokens.rSm),
          border: Border.all(color: IveTokens.genie.withValues(alpha: 0.3)),
        ),
        child: Text('$label $amount', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: IveTokens.ink)),
      ),
    );
  }
}
