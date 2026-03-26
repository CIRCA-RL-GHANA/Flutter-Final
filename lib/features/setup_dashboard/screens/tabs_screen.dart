/// ═══════════════════════════════════════════════════════════════════════════
/// SD1.3: CUSTOMER TABS — Credit Account Management
/// Tab list, credit utilization, transaction history, payment tracking
/// RBAC: Admin(full), BM(branch), Monitor/BrMon(view)
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../prompt/providers/context_provider.dart';
import '../models/setup_dashboard_models.dart';
import '../providers/setup_dashboard_provider.dart';
import '../widgets/shared_widgets.dart';

class TabsScreen extends StatelessWidget {
  const TabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        final tabs = setupProv.tabs;

        return SetupRbacGate(
          cardId: 'tabs',
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FC),
            appBar: SetupAppBar(
              title: 'Customer Tabs',
              actions: [
                DataScopeIndicator(access: setupProv.getCardAccess('tabs', ctxProv.currentRole)),
                SizedBox(width: 16),
              ],
            ),
            floatingActionButton: SetupRbacFAB(
              cardId: 'tabs',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.setupTabCreate);
              },
              label: 'Add Tab',
              icon: Icons.add,
            ),
          body: CustomScrollView(
            slivers: [
              // ─── Summary ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: KPIBadge(
                          label: 'Active Tabs',
                          value: '${tabs.length}',
                          icon: Icons.receipt_long,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: KPIBadge(
                          label: 'Total Credit',
                          value: '₵${setupProv.totalCredit.toStringAsFixed(0)}',
                          icon: Icons.account_balance_wallet,
                          color: kSetupColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: KPIBadge(
                          label: 'Overdue',
                          value: '${setupProv.overdueTabCount}',
                          icon: Icons.warning_amber,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Tab List ─────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: const SetupSectionTitle(
                    title: 'Active Accounts',
                    icon: Icons.receipt_long,
                  ),
                ),
              ),

              // ─── AI Insights ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Consumer<AIInsightsNotifier>(
                  builder: (context, ai, _) {
                    if (ai.insights.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: kSetupColor.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome, size: 14, color: kSetupColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'AI: ${ai.insights.first['title'] ?? ''}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kSetupColor),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _TabCard(tab: tabs[i]),
                    childCount: tabs.length,
                  ),
                ),
              ),

              // ─── Recent Transactions ──────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SetupSectionTitle(
                        title: 'Recent Transactions',
                        icon: Icons.swap_horiz,
                      ),
                      SetupSectionCard(
                        child: Column(
                          children: setupProv.tabTransactions.map((txn) {
                            return _TransactionItem(transaction: txn);
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
        );
      },
    );
  }
}

// ─── Tab Card ────────────────────────────────────────────────────────────────

class _TabCard extends StatelessWidget {
  final CustomerTab tab;
  const _TabCard({required this.tab});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<SetupDashboardProvider>().selectTab(tab.id);
        Navigator.pushNamed(context, AppRoutes.setupTabDetail);
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: tab.isOverdue
            ? Border.all(color: AppColors.error.withOpacity(0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kSetupColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    tab.customerName.isNotEmpty ? tab.customerName[0] : '?',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kSetupColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tab.customerName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      tab.tabNumber,
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              SetupStatusIndicator(
                label: _statusLabel(tab.status),
                color: _statusColor(tab.status),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Credit utilization bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₵${tab.amountUsed.toStringAsFixed(0)} / ₵${tab.creditLimit.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${tab.utilizationPercent.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _utilizationColor(tab.utilizationPercent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: (tab.utilizationPercent / 100).clamp(0.0, 1.0),
                  backgroundColor: AppColors.inputBorder,
                  valueColor: AlwaysStoppedAnimation(
                      _utilizationColor(tab.utilizationPercent)),
                  minHeight: 4,
                ),
              ),
            ],
          ),
          if (tab.nextPaymentDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  tab.autoPayEnabled ? Icons.autorenew : Icons.schedule,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  tab.autoPayEnabled ? 'Auto-pay enabled' : 'Next: ₵${tab.nextPaymentAmount.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
              ],
            ),
          ],
        ],
      ),
      ),
    );
  }

  String _statusLabel(TabStatus status) {
    switch (status) {
      case TabStatus.active:
        return 'Active';
      case TabStatus.overdue:
        return 'Overdue';
      case TabStatus.atLimit:
        return 'At Limit';
      case TabStatus.frozen:
        return 'Frozen';
      case TabStatus.closed:
        return 'Closed';
    }
  }

  Color _statusColor(TabStatus status) {
    switch (status) {
      case TabStatus.active:
        return AppColors.success;
      case TabStatus.overdue:
        return AppColors.error;
      case TabStatus.atLimit:
        return AppColors.warning;
      case TabStatus.frozen:
        return AppColors.info;
      case TabStatus.closed:
        return AppColors.textTertiary;
    }
  }

  Color _utilizationColor(double pct) {
    if (pct >= 90) return AppColors.error;
    if (pct >= 70) return AppColors.warning;
    return AppColors.success;
  }
}

// ─── Transaction Item ────────────────────────────────────────────────────────

class _TransactionItem extends StatelessWidget {
  final TabTransaction transaction;
  const _TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (transaction.isPayment ? AppColors.success : kSetupColor)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              transaction.isPayment ? Icons.arrow_downward : Icons.arrow_upward,
              size: 18,
              color: transaction.isPayment ? AppColors.success : kSetupColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  transaction.category,
                  style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction.isPayment ? "+" : "-"}₵${transaction.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: transaction.isPayment ? AppColors.success : AppColors.textPrimary,
                ),
              ),
              Text(
                setupTimeAgo(transaction.date),
                style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
