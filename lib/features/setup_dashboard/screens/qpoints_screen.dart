/// 
/// SD3.4: Q-POINTS  Balance, Transactions, Redemption
/// Balance header, transaction history, type-colored entries
/// RBAC: Owner(all), Admin(entity), BM(branch), SO(entity),
///        BSO(branch), Monitor/BrMon(view), RO/BRO(limited), Driver(own)
/// 
library;

import 'package:flutter/material.dart';
import '../../../core/utils/app_toast.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../prompt/providers/context_provider.dart';
import '../models/setup_dashboard_models.dart';
import '../providers/setup_dashboard_provider.dart';
import '../widgets/shared_widgets.dart';

class QPointsScreen extends StatelessWidget {
  const QPointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        final balance = setupProv.qPointsBalance;
        final transactions = setupProv.qPointsTransactions;

        return SetupRbacGate(
          cardId: 'qpoints',
          child: Scaffold(
            backgroundColor: const Color(0xFF08080F),
            appBar: SetupAppBar(
              title: 'Q-Points',
              actions: [
                SetupExportButton(
                  dataType: 'transaction_history',
                  cardId: 'qpoints',
                  onExport: () {},
                  label: 'Export',
                ),
                const SizedBox(width: 8),
                DataScopeIndicator(access: setupProv.getCardAccess('qpoints', ctxProv.currentRole)),
                const SizedBox(width: 16),
              ],
            ),
            floatingActionButton: SetupRbacFAB(
              cardId: 'qpoints',
              onPressed: () => AppToast.show(context, 'Buy QPoints'),
              label: 'Buy QP',
              icon: Icons.add_shopping_cart,
            ),
          body: CustomScrollView(
            slivers: [
              //  Balance Header 
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.diamond, size: 36, color: Colors.white),
                      const SizedBox(height: 8),
                      Text(
                        '${balance.available}',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                      const Text(
                        'Available Points',
                        style: TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _BalanceStat(label: 'Lifetime', value: '${balance.lifetime}'),
                          Container(width: 1, height: 28, color: Colors.white24),
                          _BalanceStat(label: 'Redeemed', value: '${balance.redeemed}'),
                          Container(width: 1, height: 28, color: Colors.white24),
                          _BalanceStat(label: 'Pending', value: '${balance.pending}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              //  Tier Badge 
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.star, size: 18, color: AppColors.accent),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                balance.tier,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Expires ${balance.expiringPoints} pts in ${balance.daysToExpiry} days',
                                style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              //  Quick Actions 
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      Expanded(child: _QuickAction(icon: Icons.send, label: 'Transfer', color: kSetupColor)),
                      SizedBox(width: 10),
                      Expanded(child: _QuickAction(icon: Icons.redeem, label: 'Redeem', color: Color(0xFF8B5CF6))),
                      SizedBox(width: 10),
                      Expanded(child: _QuickAction(icon: Icons.card_giftcard, label: 'Gift', color: AppColors.accent)),
                      SizedBox(width: 10),
                      Expanded(child: _QuickAction(icon: Icons.history, label: 'History', color: AppColors.success)),
                    ],
                  ),
                ),
              ),

              //  Earning Summary 
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Points Breakdown',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: _BreakdownStat(
                              label: 'Earned',
                              value: '${transactions.where((t) => t.type == QPointsTransactionType.earned).fold<int>(0, (s, t) => s + t.points)}',
                              color: AppColors.success,
                            )),
                            const SizedBox(width: 8),
                            Expanded(child: _BreakdownStat(
                              label: 'Bonus',
                              value: '${transactions.where((t) => t.type == QPointsTransactionType.bonus).fold<int>(0, (s, t) => s + t.points)}',
                              color: AppColors.accent,
                            )),
                            const SizedBox(width: 8),
                            Expanded(child: _BreakdownStat(
                              label: 'Expired',
                              value: '${transactions.where((t) => t.type == QPointsTransactionType.expired).fold<int>(0, (s, t) => s + t.points)}',
                              color: AppColors.error,
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              //  Transaction History 
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: SetupSectionTitle(title: 'Transaction History', icon: Icons.history),
                ),
              ),

              //  AI Insights 
              const SliverToBoxAdapter(
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _TransactionCard(tx: transactions[i]),
                    childCount: transactions.length,
                  ),
                ),
              ),
            ],
          ),
        ),
        );
      },
    );
  }
}

class _BalanceStat extends StatelessWidget {
  final String label;
  final String value;
  const _BalanceStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white60)),
      ],
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final QPointsTransaction tx;
  const _TransactionCard({required this.tx});

  Color get _typeColor => switch (tx.type) {
    QPointsTransactionType.earned => AppColors.success,
    QPointsTransactionType.redeemed => const Color(0xFF8B5CF6),
    QPointsTransactionType.expired => AppColors.error,
    QPointsTransactionType.bonus => AppColors.accent,
    QPointsTransactionType.transferred => kSetupColor,
  };

  IconData get _typeIcon => switch (tx.type) {
    QPointsTransactionType.earned => Icons.add_circle,
    QPointsTransactionType.redeemed => Icons.redeem,
    QPointsTransactionType.expired => Icons.timer_off,
    QPointsTransactionType.bonus => Icons.card_giftcard,
    QPointsTransactionType.transferred => Icons.swap_horiz,
  };

  String get _sign => switch (tx.type) {
    QPointsTransactionType.earned || QPointsTransactionType.bonus => '+',
    QPointsTransactionType.redeemed || QPointsTransactionType.expired || QPointsTransactionType.transferred => '-',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_typeIcon, size: 18, color: _typeColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${tx.type.name.toUpperCase()}  ${setupTimeAgo(tx.date)}',
                  style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          Text(
            '$_sign${tx.points}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _typeColor,
            ),
          ),
        ],
      ),
    );
  }
}

//  Quick Action 

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _QuickAction({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

//  Breakdown Stat 

class _BreakdownStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _BreakdownStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}
