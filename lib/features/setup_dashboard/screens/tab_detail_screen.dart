/// ═══════════════════════════════════════════════════════════════════════════
/// SD1.3-DETAIL: TAB DETAIL — 4-Tab Deep View
/// Tabs: Overview, Transactions, Payments, Settings
/// RBAC: Owner/Admin(fullAccess), BM(branchScoped), Monitor(viewOnly),
///        RO/BRO(ownOnly)
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../prompt/providers/context_provider.dart';
import '../models/setup_dashboard_models.dart';
import '../providers/setup_dashboard_provider.dart';
import '../widgets/shared_widgets.dart';

class TabDetailScreen extends StatefulWidget {
  const TabDetailScreen({super.key});

  @override
  State<TabDetailScreen> createState() => _TabDetailScreenState();
}

class _TabDetailScreenState extends State<TabDetailScreen> {
  int _tabIndex = 0;
  static const _tabs = ['Overview', 'Transactions', 'Payments', 'Settings'];

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        final tab = setupProv.selectedTab;
        if (tab == null) {
          return Scaffold(
            appBar: const SetupAppBar(title: 'Tab Detail'),
            body: const SetupEmptyState(
              icon: Icons.receipt_long,
              title: 'No tab selected',
              subtitle: 'Select a customer tab from the list',
            ),
          );
        }

        final transactions = setupProv.getTransactionsForTab(tab.id);

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FC),
          appBar: SetupAppBar(title: 'Tab ${tab.tabNumber}'),
          body: Column(
            children: [
              _TabHeader(tab: tab),
              const SizedBox(height: 12),
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kSetupColor.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kSetupColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "AI: ${ai.insights.first['title'] ?? ''}",
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kSetupColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SetupDetailTabBar(
                tabs: _tabs,
                selectedIndex: _tabIndex,
                onTabChanged: (i) => setState(() => _tabIndex = i),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: IndexedStack(
                  index: _tabIndex,
                  children: [
                    _OverviewTab(tab: tab),
                    _TransactionsTab(transactions: transactions),
                    _PaymentsTab(tab: tab),
                    _SettingsTab(tab: tab),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Tab Header ──────────────────────────────────────────────────────────────

class _TabHeader extends StatelessWidget {
  final CustomerTab tab;
  const _TabHeader({required this.tab});

  Color get _statusColor => switch (tab.status) {
    TabStatus.active => AppColors.success,
    TabStatus.overdue => AppColors.error,
    TabStatus.atLimit => AppColors.warning,
    TabStatus.frozen => const Color(0xFF8B5CF6),
    TabStatus.closed => AppColors.textTertiary,
  };

  @override
  Widget build(BuildContext context) {
    final utilization = tab.creditLimit > 0 ? tab.amountUsed / tab.creditLimit : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: _statusColor.withOpacity(0.1),
                child: Text(
                  tab.customerName[0],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _statusColor),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tab.customerName,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    Text(
                      tab.tabNumber,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tab.status.name.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Utilization bar
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₵${tab.amountUsed.toStringAsFixed(0)} / ₵${tab.creditLimit.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${(utilization * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: utilization > 0.9 ? AppColors.error :
                             utilization > 0.7 ? AppColors.warning : kSetupColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: utilization.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    utilization > 0.9 ? AppColors.error :
                    utilization > 0.7 ? AppColors.warning : kSetupColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Overview Tab ────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final CustomerTab tab;
  const _OverviewTab({required this.tab});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        Row(
          children: [
            Expanded(child: SetupStatCard(label: 'Credit Limit', value: '₵${tab.creditLimit.toStringAsFixed(0)}', icon: Icons.credit_card)),
            const SizedBox(width: 10),
            Expanded(child: SetupStatCard(label: 'Used', value: '₵${tab.amountUsed.toStringAsFixed(0)}', icon: Icons.shopping_cart, color: AppColors.warning)),
            const SizedBox(width: 10),
            Expanded(child: SetupStatCard(
              label: 'Available',
              value: '₵${(tab.creditLimit - tab.amountUsed).clamp(0, tab.creditLimit).toStringAsFixed(0)}',
              icon: Icons.account_balance_wallet,
              color: AppColors.success,
            )),
          ],
        ),
        const SizedBox(height: 16),
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Tab Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              SetupInfoRow(label: 'Customer', value: tab.customerName),
              SetupInfoRow(label: 'Tab Number', value: tab.tabNumber),
              SetupInfoRow(label: 'Status', value: tab.status.name.toUpperCase(), valueColor: kSetupColor),
              if (tab.customerRating > 0)
                SetupInfoRow(label: 'Customer Rating', value: '${tab.customerRating} ⭐'),
              SetupInfoRow(label: 'Created', value: setupTimeAgo(tab.createdAt)),
              if (tab.autoPayEnabled)
                const SetupInfoRow(label: 'Auto-Pay', value: 'Enabled', valueColor: AppColors.success),
            ],
          ),
        ),
        if (tab.nextPaymentDate != null) ...[
          const SizedBox(height: 12),
          SetupSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.payment, size: 18, color: kSetupColor),
                    const SizedBox(width: 8),
                    const Text('Next Payment', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 12),
                SetupInfoRow(label: 'Amount', value: '₵${tab.nextPaymentAmount.toStringAsFixed(0)}'),
                SetupInfoRow(
                  label: 'Due',
                  value: setupTimeAgo(tab.nextPaymentDate!),
                  valueColor: tab.isOverdue ? AppColors.error : null,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Transactions Tab ────────────────────────────────────────────────────────

class _TransactionsTab extends StatelessWidget {
  final List<TabTransaction> transactions;
  const _TransactionsTab({required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const SetupEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No transactions',
        subtitle: 'No transaction history for this tab',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: transactions.length,
      itemBuilder: (context, i) => _TransactionCard(tx: transactions[i]),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TabTransaction tx;
  const _TransactionCard({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isPayment = tx.isPayment;
    final color = isPayment ? AppColors.success : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPayment ? Icons.arrow_downward : Icons.arrow_upward,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${tx.category} · ${setupTimeAgo(tx.date)}',
                  style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          Text(
            '${isPayment ? "+" : "-"}₵${tx.amount.toStringAsFixed(0)}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

// ─── Payments Tab ────────────────────────────────────────────────────────────

class _PaymentsTab extends StatelessWidget {
  final CustomerTab tab;
  const _PaymentsTab({required this.tab});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Payment Schedule', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              if (tab.nextPaymentDate != null) ...[
                SetupInfoRow(label: 'Next Payment', value: '₵${tab.nextPaymentAmount.toStringAsFixed(0)}'),
                SetupInfoRow(
                  label: 'Due Date',
                  value: setupTimeAgo(tab.nextPaymentDate!),
                  valueColor: tab.isOverdue ? AppColors.error : AppColors.textPrimary,
                ),
              ],
              SetupInfoRow(
                label: 'Auto-Pay',
                value: tab.autoPayEnabled ? 'Enabled' : 'Disabled',
                valueColor: tab.autoPayEnabled ? AppColors.success : AppColors.textTertiary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.history, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Payment History', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              const _PaymentHistoryRow(amount: 500, date: '3 days ago', method: 'Credit Card'),
              const _PaymentHistoryRow(amount: 350, date: '1 week ago', method: 'Mobile Money'),
              const _PaymentHistoryRow(amount: 200, date: '2 weeks ago', method: 'Cash'),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentHistoryRow extends StatelessWidget {
  final double amount;
  final String date;
  final String method;

  const _PaymentHistoryRow({
    required this.amount,
    required this.date,
    required this.method,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.check, size: 14, color: AppColors.success),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('₵${amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text('$method · $date', style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Settings Tab ────────────────────────────────────────────────────────────

class _SettingsTab extends StatelessWidget {
  final CustomerTab tab;
  const _SettingsTab({required this.tab});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.settings, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Tab Configuration', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              SetupInfoRow(label: 'Credit Limit', value: '₵${tab.creditLimit.toStringAsFixed(0)}'),
              SetupInfoRow(
                label: 'Auto-Pay',
                value: tab.autoPayEnabled ? 'Enabled' : 'Disabled',
              ),
              SetupInfoRow(label: 'Status', value: tab.status.name.toUpperCase()),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.notifications_outlined, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Notifications', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              const _SettingToggle(label: 'Payment reminders', value: true),
              const _SettingToggle(label: 'Limit warnings', value: true),
              const _SettingToggle(label: 'Transaction alerts', value: false),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Danger zone
        SetupActionGuard(
          cardId: 'tabs',
          requireDelete: true,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.error.withOpacity(0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Danger Zone',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.error),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.pause, size: 16),
                        label: const Text('Freeze', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.warning,
                          side: const BorderSide(color: AppColors.warning),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Close Tab', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingToggle extends StatelessWidget {
  final String label;
  final bool value;

  const _SettingToggle({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Switch(
            value: value,
            onChanged: (_) {},
            activeColor: kSetupColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}
