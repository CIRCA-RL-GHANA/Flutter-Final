/// ═══════════════════════════════════════════════════════════════════════════
/// SD1.4-DETAIL: DISCOUNT TIER DETAIL — 4-Tab Deep View
/// Tabs: Overview, Eligible Products, Performance, Settings
/// RBAC: Admin(full), BM(branch), SO(full), BSO(branch), Monitor(viewOnly)
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../prompt/providers/context_provider.dart';
import '../models/setup_dashboard_models.dart';
import '../providers/setup_dashboard_provider.dart';
import '../widgets/shared_widgets.dart';

class DiscountDetailScreen extends StatefulWidget {
  const DiscountDetailScreen({super.key});

  @override
  State<DiscountDetailScreen> createState() => _DiscountDetailScreenState();
}

class _DiscountDetailScreenState extends State<DiscountDetailScreen> {
  int _tabIndex = 0;
  static const _tabs = ['Overview', 'Eligible Products', 'Performance', 'Settings'];

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        final discount = setupProv.selectedDiscount;
        if (discount == null) {
          return Scaffold(
            appBar: const SetupAppBar(title: 'Discount Detail'),
            body: const SetupEmptyState(
              icon: Icons.local_offer,
              title: 'No discount selected',
              subtitle: 'Select a discount tier from the list',
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FC),
          appBar: SetupAppBar(title: discount.name),
          body: Column(
            children: [
              _DiscountHeader(discount: discount),
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
                    _OverviewTab(discount: discount),
                    _EligibleProductsTab(discount: discount),
                    _PerformanceTab(discount: discount),
                    _SettingsTab(discount: discount),
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

// ─── Header ──────────────────────────────────────────────────────────────────

class _DiscountHeader extends StatelessWidget {
  final DiscountTier discount;
  const _DiscountHeader({required this.discount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kSetupColor.withOpacity(0.08),
            kSetupColor.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kSetupColor.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: kSetupColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.local_offer, color: kSetupColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      discount.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(status: discount.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${discount.valueDisplay} · ${discount.productScope} · ${discount.customerCount} customers',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                if (discount.code != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Code: ${discount.code}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: kSetupColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final DiscountStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    switch (status) {
      case DiscountStatus.active:
        color = AppColors.success;
        label = 'Active';
        break;
      case DiscountStatus.paused:
        color = AppColors.warning;
        label = 'Paused';
        break;
      case DiscountStatus.draft:
        color = AppColors.textTertiary;
        label = 'Draft';
        break;
      case DiscountStatus.scheduled:
        color = kSetupColor;
        label = 'Scheduled';
        break;
      case DiscountStatus.ended:
        color = AppColors.error;
        label = 'Ended';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

// ─── Overview Tab ────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final DiscountTier discount;
  const _OverviewTab({required this.discount});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // KPI Row
        Row(
          children: [
            Expanded(
              child: KPIBadge(
                label: 'Discount',
                value: discount.valueDisplay,
                icon: Icons.percent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: KPIBadge(
                label: 'Revenue Impact',
                value: '+₵${discount.revenueImpact.toStringAsFixed(0)}',
                icon: Icons.trending_up,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: KPIBadge(
                label: 'Customers',
                value: '${discount.customerCount}',
                icon: Icons.people,
                color: AppColors.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Discount Details Card
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SetupSectionTitle(title: 'Discount Details', icon: Icons.info_outline),
              SetupInfoRow(label: 'Type', value: discount.type.name.toUpperCase()),
              SetupInfoRow(label: 'Value', value: discount.valueDisplay),
              SetupInfoRow(label: 'Scope', value: discount.productScope),
              if (discount.minimumPurchase != null)
                SetupInfoRow(
                  label: 'Min Purchase',
                  value: '₵${discount.minimumPurchase!.toStringAsFixed(0)}',
                ),
              if (discount.maximumDiscount != null)
                SetupInfoRow(
                  label: 'Max Discount',
                  value: '₵${discount.maximumDiscount!.toStringAsFixed(0)}',
                ),
            ],
          ),
        ),

        // Schedule Card
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SetupSectionTitle(title: 'Schedule', icon: Icons.schedule),
              if (discount.startDate != null)
                SetupInfoRow(
                  label: 'Start',
                  value: '${discount.startDate!.day}/${discount.startDate!.month}/${discount.startDate!.year}',
                ),
              if (discount.endDate != null)
                SetupInfoRow(
                  label: 'End',
                  value: '${discount.endDate!.day}/${discount.endDate!.month}/${discount.endDate!.year}',
                ),
              if (discount.endDate != null)
                SetupInfoRow(
                  label: 'Days Left',
                  value: '${discount.endDate!.difference(DateTime.now()).inDays} days',
                ),
            ],
          ),
        ),

        // Description
        if (discount.description != null)
          SetupSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SetupSectionTitle(title: 'Description', icon: Icons.description),
                Text(
                  discount.description!,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                ),
              ],
            ),
          ),

        const SizedBox(height: 80),
      ],
    );
  }
}

// ─── Eligible Products Tab ───────────────────────────────────────────────────

class _EligibleProductsTab extends StatelessWidget {
  final DiscountTier discount;
  const _EligibleProductsTab({required this.discount});

  @override
  Widget build(BuildContext context) {
    return Consumer<SetupDashboardProvider>(
      builder: (context, prov, _) {
        final products = prov.products;
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kSetupColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2, size: 20, color: kSetupColor),
                  const SizedBox(width: 10),
                  Text(
                    'Scope: ${discount.productScope}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kSetupColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${products.length} products',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...products.take(8).map((p) => SetupSectionCard(
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: kSetupColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.inventory_2, size: 20, color: kSetupColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '₵${p.currentPrice.toStringAsFixed(0)} · Stock: ${p.stock}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        discount.valueDisplay,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 80),
          ],
        );
      },
    );
  }
}

// ─── Performance Tab ─────────────────────────────────────────────────────────

class _PerformanceTab extends StatelessWidget {
  final DiscountTier discount;
  const _PerformanceTab({required this.discount});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // Performance KPIs
        Row(
          children: [
            Expanded(
              child: KPIBadge(
                label: 'Redemptions',
                value: '${discount.customerCount}',
                icon: Icons.redeem,
                changePercent: 18,
                isPositive: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: KPIBadge(
                label: 'Revenue +',
                value: '₵${discount.revenueImpact.toStringAsFixed(0)}',
                icon: Icons.monetization_on,
                color: AppColors.success,
                changePercent: 12,
                isPositive: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Redemption Rate Card
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SetupSectionTitle(title: 'Redemption Rate', icon: Icons.pie_chart),
              const SizedBox(height: 8),
              const _PerformanceBar(label: 'This week', value: 0.24, display: '24%'),
              const SizedBox(height: 8),
              const _PerformanceBar(label: 'Last week', value: 0.18, display: '18%'),
              const SizedBox(height: 8),
              const _PerformanceBar(label: 'This month', value: 0.21, display: '21%'),
            ],
          ),
        ),

        // Customer Insights
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SetupSectionTitle(title: 'Customer Insights', icon: Icons.people),
              const SetupInfoRow(label: 'New Customers', value: '89 (36%)'),
              const SetupInfoRow(label: 'Repeat Customers', value: '156 (64%)'),
              const SetupInfoRow(label: 'Avg Savings/Customer', value: '₵51'),
              const SetupInfoRow(label: 'Avg Order Value', value: '₵508 (+₵45)'),
            ],
          ),
        ),

        // Revenue Impact Timeline
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SetupSectionTitle(title: 'Daily Impact', icon: Icons.show_chart),
              ...['Mon', 'Tue', 'Wed', 'Thu', 'Fri'].asMap().entries.map((e) {
                final vals = [0.45, 0.62, 0.78, 0.55, 0.85];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _PerformanceBar(
                    label: e.value,
                    value: vals[e.key],
                    display: '₵${(vals[e.key] * 2500).toStringAsFixed(0)}',
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

// ─── Settings Tab ────────────────────────────────────────────────────────────

class _SettingsTab extends StatelessWidget {
  final DiscountTier discount;
  const _SettingsTab({required this.discount});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SetupSectionTitle(title: 'Tier Configuration', icon: Icons.tune),
              SetupInfoRow(label: 'Status', value: discount.status.name),
              SetupInfoRow(label: 'Type', value: discount.type.name),
              SetupInfoRow(
                label: 'Auto-apply',
                value: discount.code == null ? 'Yes' : 'Code required',
              ),
            ],
          ),
        ),
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SetupSectionTitle(title: 'Stacking Rules', icon: Icons.layers),
              const SetupInfoRow(label: 'Can stack', value: 'No'),
              const SetupInfoRow(label: 'Priority', value: 'Highest discount wins'),
              const SetupInfoRow(label: 'Exclusions', value: 'None'),
            ],
          ),
        ),
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SetupSectionTitle(title: 'Usage Limits', icon: Icons.speed),
              const SetupInfoRow(label: 'Per customer', value: 'Unlimited'),
              const SetupInfoRow(label: 'Total uses', value: 'Unlimited'),
              const SetupInfoRow(label: 'Budget cap', value: 'None'),
            ],
          ),
        ),

        // Danger Zone
        const SizedBox(height: 16),
        SetupActionGuard(
          cardId: 'discounts',
          requireDelete: true,
          child: SetupSectionCard(
            borderColor: AppColors.error.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SetupSectionTitle(
                  title: 'Danger Zone',
                  icon: Icons.warning_amber,
                  iconColor: AppColors.error,
                ),
                SetupActionTile(
                  icon: Icons.pause_circle_outline,
                  label: 'Pause Discount',
                  subtitle: 'Temporarily disable this discount tier',
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                SetupActionTile(
                  icon: Icons.delete_outline,
                  label: 'Delete Discount',
                  subtitle: 'Permanently remove this discount tier',
                  onTap: () {},
                  iconColor: AppColors.error,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

// ─── Helper Widgets ──────────────────────────────────────────────────────────

class _PerformanceBar extends StatelessWidget {
  final String label;
  final double value;
  final String display;

  const _PerformanceBar({
    required this.label,
    required this.value,
    required this.display,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              backgroundColor: kSetupColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                value > 0.7 ? AppColors.success : kSetupColor,
              ),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          display,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
