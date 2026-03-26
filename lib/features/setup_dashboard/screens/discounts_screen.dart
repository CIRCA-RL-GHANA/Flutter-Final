/// ═══════════════════════════════════════════════════════════════════════════
/// SD1.4: DISCOUNTS — Tier Management
/// Active discount tiers, create/edit, revenue impact tracking
/// RBAC: Admin(full), BM(branch), SO(full), BSO(branch), Monitor/BrMon(view)
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../prompt/providers/context_provider.dart';
import '../models/setup_dashboard_models.dart';
import '../providers/setup_dashboard_provider.dart';
import '../widgets/shared_widgets.dart';

class DiscountsScreen extends StatelessWidget {
  const DiscountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        final discounts = setupProv.discounts;

        return SetupRbacGate(
          cardId: 'discounts',
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FC),
            appBar: SetupAppBar(
              title: 'Discount Tiers',
              actions: [
                DataScopeIndicator(access: setupProv.getCardAccess('discounts', ctxProv.currentRole)),
                SizedBox(width: 16),
              ],
            ),
            floatingActionButton: SetupRbacFAB(
              cardId: 'discounts',
              onPressed: () {},
              label: 'New Tier',
              icon: Icons.add,
            ),
          body: CustomScrollView(
            slivers: [
              // ─── Summary KPIs ─────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: KPIBadge(
                          label: 'Active Tiers',
                          value: '${setupProv.activeDiscountCount}',
                          icon: Icons.local_offer,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: KPIBadge(
                          label: 'Total',
                          value: '${discounts.length}',
                          icon: Icons.layers,
                          color: AppColors.info,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: KPIBadge(
                          label: 'Revenue Impact',
                          value: '+₵${discounts.fold<double>(0, (s, d) => s + d.revenueImpact).toStringAsFixed(0)}',
                          icon: Icons.trending_up,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Status Filter Chips ──────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _StatusChip(label: 'All', count: discounts.length, isActive: true),
                        _StatusChip(
                          label: 'Active',
                          count: discounts.where((d) => d.status == DiscountStatus.active).length,
                          color: AppColors.success,
                        ),
                        _StatusChip(
                          label: 'Paused',
                          count: discounts.where((d) => d.status == DiscountStatus.paused).length,
                          color: AppColors.warning,
                        ),
                        _StatusChip(
                          label: 'Draft',
                          count: discounts.where((d) => d.status == DiscountStatus.draft).length,
                          color: AppColors.textTertiary,
                        ),
                        _StatusChip(
                          label: 'Scheduled',
                          count: discounts.where((d) => d.status == DiscountStatus.scheduled).length,
                          color: AppColors.info,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── Discount List ────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: const SetupSectionTitle(
                    title: 'All Discount Tiers',
                    icon: Icons.local_offer,
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
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _DiscountCard(discount: discounts[i]),
                    childCount: discounts.length,
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

// ─── Discount Card ───────────────────────────────────────────────────────────

class _DiscountCard extends StatelessWidget {
  final DiscountTier discount;
  const _DiscountCard({required this.discount});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<SetupDashboardProvider>().selectDiscount(discount.id);
        Navigator.pushNamed(context, AppRoutes.setupDiscountDetail);
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                child: const Icon(Icons.local_offer, size: 22, color: kSetupColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      discount.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      discount.code ?? '',
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              SetupStatusIndicator(
                label: discount.status.name,
                color: _statusColor(discount.status),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _DiscountStat(label: 'Type', value: _typeName(discount.type)),
              _DiscountStat(
                label: 'Value',
                value: discount.type == DiscountType.percentage
                    ? '${discount.value.toStringAsFixed(0)}%'
                    : '₵${discount.value.toStringAsFixed(0)}',
              ),
              _DiscountStat(label: 'Customers', value: '${discount.customerCount}'),
              _DiscountStat(
                label: 'Revenue',
                value: discount.revenueImpact > 0
                    ? '+₵${discount.revenueImpact.toStringAsFixed(0)}'
                    : '—',
              ),
            ],
          ),
          if (discount.minimumPurchase != null && discount.minimumPurchase! > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Min. purchase: ₵${discount.minimumPurchase!.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 11, color: kSetupColor, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ],
      ),
    ),
    );
  }

  String _typeName(DiscountType type) {
    switch (type) {
      case DiscountType.percentage:
        return 'Percentage';
      case DiscountType.fixedAmount:
        return 'Fixed';
      case DiscountType.buyXGetY:
        return 'BOGO';
    }
  }

  Color _statusColor(DiscountStatus status) {
    switch (status) {
      case DiscountStatus.active:
        return AppColors.success;
      case DiscountStatus.paused:
        return AppColors.warning;
      case DiscountStatus.scheduled:
        return AppColors.info;
      case DiscountStatus.draft:
        return AppColors.textTertiary;
      case DiscountStatus.ended:
        return AppColors.error;
    }
  }
}

// ─── Discount Stat ───────────────────────────────────────────────────────────

class _DiscountStat extends StatelessWidget {
  final String label;
  final String value;
  const _DiscountStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
        ),
      ],
    );
  }
}

// ─── Status Filter Chip ──────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isActive;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.count,
    this.isActive = false,
    this.color = kSetupColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text('$label ($count)'),
        selected: isActive,
        onSelected: (_) {},
        selectedColor: color.withValues(alpha: 0.15),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          color: isActive ? color : AppColors.textSecondary,
        ),
        side: BorderSide(color: isActive ? color : Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
