/// GO Screen  Financial Overview
/// Real-time balance, 24h change, quick actions, and transaction feed
/// wired to GoProvider (Consumer pattern).
library;

import 'package:flutter/material.dart';
import '../../../core/design/ive.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../providers/go_provider.dart';
import '../widgets/go_widgets.dart';

class GoFinancialScreen extends StatefulWidget {
  const GoFinancialScreen({super.key});

  @override
  State<GoFinancialScreen> createState() => _GoFinancialScreenState();
}

class _GoFinancialScreenState extends State<GoFinancialScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<GoProvider>();
      if (p.transactions.isEmpty || p.isTransactionsLoading == false) {
        p.loadTransactions();
      }
      if (p.isBalanceLoading == false) {
        p.loadBalance();
      }
    });
  }

  Future<void> _refresh() async {
    final p = context.read<GoProvider>();
    await Future.wait([
      p.loadTransactions(),
      p.loadBalance(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: AppBar(
            title: const Text('GO  Financial'),
            backgroundColor: IveTokens.moduleGo,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refresh,
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refresh,
            color: IveTokens.moduleGo,
            child: CustomScrollView(
              slivers: [
                //  Balance Header 
                SliverToBoxAdapter(
                  child: _buildBalanceHeader(provider),
                ),

                //  Quick Actions 
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ActionButton(
                          icon: Icons.add_circle_outline,
                          label: 'Buy QP',
                          color: IveTokens.success,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.goBuy),
                        ),
                        _ActionButton(
                          icon: Icons.remove_circle_outline,
                          label: 'Sell QP',
                          color: IveTokens.danger,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.goSell),
                        ),
                        _ActionButton(
                          icon: Icons.swap_horiz,
                          label: 'Transfer',
                          color: IveTokens.moduleGo,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.goTransfer),
                        ),
                        _ActionButton(
                          icon: Icons.dashboard_outlined,
                          label: 'Hub',
                          color: IveTokens.accent,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.goHub),
                        ),
                      ],
                    ),
                  ),
                ),

                //  AI Widgets 
                const SliverToBoxAdapter(
                ),

                //  Transactions Header 
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 8, 6),
                    child: Row(
                      children: [
                        const Icon(Icons.receipt_long,
                            size: 16, color: IveTokens.moduleGo),
                        const SizedBox(width: 6),
                        const Text(
                          'Recent Transactions',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.goArchive),
                          style: TextButton.styleFrom(
                              foregroundColor: IveTokens.moduleGo,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8)),
                          child: const Text('View All',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ),

                //  Loading / Error / Empty / Data 
                if (provider.isTransactionsLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: IveTokens.moduleGo),
                    ),
                  )
                else if (provider.error != null &&
                    provider.transactions.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: IveTokens.danger),
                          const SizedBox(height: 12),
                          Text(
                            provider.error!,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF6B7280)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refresh,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: IveTokens.moduleGo,
                                foregroundColor: Colors.white),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (provider.transactions.isEmpty)
                  const SliverFillRemaining(
                    child: GoEmptyState(
                      icon: Icons.receipt_long,
                      title: 'No transactions yet',
                      message:
                          'Buy, sell or transfer QPoints to see activity here.',
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final tx = provider.transactions[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GoTransactionRow(transaction: tx),
                        );
                      },
                      childCount: provider.transactions.length,
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBalanceHeader(GoProvider provider) {
    final change = provider.change24h;
    final isPositive = change >= 0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [IveTokens.moduleGo, IveTokens.ink],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: provider.isBalanceLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total QP Balance',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  '${provider.totalNetWorth.toStringAsFixed(0)} QP',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      isPositive
                          ? Icons.trending_up
                          : Icons.trending_down,
                      size: 16,
                      color:
                          isPositive ? Colors.greenAccent : Colors.redAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${isPositive ? '+' : ''}${change.toStringAsFixed(1)}% today',
                      style: TextStyle(
                        color: isPositive
                            ? Colors.greenAccent
                            : Colors.redAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Liquid: ${provider.liquidity.available.toStringAsFixed(0)} QP',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
