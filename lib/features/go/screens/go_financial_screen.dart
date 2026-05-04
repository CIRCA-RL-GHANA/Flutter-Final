import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' hide Consumer;
import 'package:thepg/core/providers/service_providers.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/widgets/ai_price_widgets.dart';
import '../../../core/widgets/ai_insight_card.dart';

class GoFinancialScreen extends ConsumerStatefulWidget {
  const GoFinancialScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GoFinancialScreen> createState() => _GoFinancialScreenState();
}

class _GoFinancialScreenState extends ConsumerState<GoFinancialScreen> {
  @override
  Widget build(BuildContext context) {
    final ordersService = ref.watch(ordersServiceProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('GO - Financial'),
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          // Header with balance info
          SliverAppBar(
            pinned: false,
            elevation: 0,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue[700]!, Colors.blue[400]!],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Balance',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '\$2,450.50',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            '+\$250 today',
                            style: TextStyle(
                              color: Colors.green[300],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '-\$120 spent',
                            style: TextStyle(
                              color: Colors.red[300],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Quick actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    icon: Icons.add,
                    label: 'Add Income',
                    onTap: () {},
                  ),
                  _ActionButton(
                    icon: Icons.remove,
                    label: 'Add Expense',
                    onTap: () {},
                  ),
                  _ActionButton(
                    icon: Icons.swap_horiz,
                    label: 'Transfer',
                    onTap: () {},
                  ),
                  _ActionButton(
                    icon: Icons.more_horiz,
                    label: 'More',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          
          // Transactions section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // ─── AI Spending Summary ──────────────────────────
                  Consumer<AIInsightsNotifier>(
                    builder: (ctx, notifier, _) {
                      final spending = notifier.spendingPattern;
                      if (spending == null || spending.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: AISpendingSummaryCard(spendingData: spending),
                      );
                    },
                  ),

                  // ─── AI Insights Row ───────────────────────────────
                  Consumer<AIInsightsNotifier>(
                    builder: (ctx, notifier, _) {
                      final insights = notifier.insights;
                      if (insights.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.auto_awesome, size: 14, color: Color(0xFF8B5CF6)),
                              SizedBox(width: 6),
                              Text(
                                'AI Financial Insights',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...insights.take(3).map(
                            (i) => AIInsightCard(insight: i),
                          ),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Transactions section header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
          ),
          
          // Transactions list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: index % 2 == 0 
                        ? Colors.green[100] 
                        : Colors.red[100],
                    child: Icon(
                      index % 2 == 0 ? Icons.add : Icons.remove,
                      color: index % 2 == 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(
                    index % 2 == 0 ? 'Payment Received' : 'Purchase',
                  ),
                  subtitle: const Text('Today at 2:30 PM'),
                  trailing: Text(
                    index % 2 == 0 ? '+\$250' : '-\$45.99',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: index % 2 == 0 ? Colors.green : Colors.red,
                    ),
                  ),
                );
              },
              childCount: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blue[700]),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
