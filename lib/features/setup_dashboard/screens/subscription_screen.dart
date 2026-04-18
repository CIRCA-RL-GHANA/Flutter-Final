/// ═══════════════════════════════════════════════════════════════════════════
/// SD3.2: SUBSCRIPTION — Plan Management
/// Plan details, usage limits, storage, API calls, renewal
/// RBAC: Owner(personal), Admin(entity), BM(brView)
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../prompt/providers/context_provider.dart';
import '../models/setup_dashboard_models.dart';
import '../providers/setup_dashboard_provider.dart';
import '../widgets/shared_widgets.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        final sub = setupProv.subscription;

        return SetupRbacGate(
          cardId: 'subscription',
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FC),
            appBar: SetupAppBar(
              title: 'Subscription',
              actions: [
                DataScopeIndicator(access: setupProv.getCardAccess('subscription', ctxProv.currentRole)),
                SizedBox(width: 16),
              ],
            ),
          body: CustomScrollView(
            slivers: [
              // ─── Plan Header ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: SetupSectionCard(
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: _planColor(sub.plan).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.diamond, size: 32, color: _planColor(sub.plan)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${sub.plan.name[0].toUpperCase()}${sub.plan.name.substring(1)} Plan',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        // Per-staff pricing
                        if (sub.plan != SubscriptionPlan.free)
                          Text(
                            '${sub.pricePerStaffQPoints.toStringAsFixed(0)} QP × ${sub.staffCount} staff / month',
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        if (sub.plan == SubscriptionPlan.free)
                          const Text(
                            'Free — no charge',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        const SizedBox(height: 12),
                        // Free trial badge
                        if (sub.isInFreeTrial)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '✨ Free Trial — ${sub.daysInFreeTrial} days left',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.info.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Renews in ${sub.daysUntilRenewal} days',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.info),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── Usage Metrics ────────────────────────────
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SetupSectionTitle(title: 'Usage', icon: Icons.data_usage),
                      _UsageBar(
                        label: 'Staff',
                        used: sub.staffUsed.toDouble(),
                        limit: sub.staffLimit.toDouble(),
                        icon: Icons.people,
                      ),
                      const SizedBox(height: 10),
                      _UsageBar(
                        label: 'Storage',
                        used: sub.storageUsedGB,
                        limit: sub.storageGB.toDouble(),
                        unit: 'GB',
                        icon: Icons.cloud,
                      ),
                      const SizedBox(height: 10),
                      _UsageBar(
                        label: 'API Calls',
                        used: sub.apiCallsUsed.toDouble(),
                        limit: sub.apiCallLimit.toDouble(),
                        icon: Icons.api,
                      ),
                      const SizedBox(height: 10),
                      _UsageBar(
                        label: 'Free Transactions',
                        used: sub.monthlyTransactionCount.toDouble(),
                        limit: sub.freeTransactionQuota.toDouble(),
                        icon: Icons.receipt_long,
                        overageNote: sub.monthlyTransactionCount > sub.freeTransactionQuota
                            ? '${sub.monthlyTransactionCount - sub.freeTransactionQuota} × 0.02 QP fee'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Plan Features ────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SetupSectionTitle(title: 'Plan Features', icon: Icons.check_circle),
                      SetupSectionCard(
                        child: Column(
                          children: [
                            _FeatureRow(label: 'Staff Members', value: '${sub.staffLimit}', included: true),
                            _FeatureRow(label: 'Cloud Storage', value: '${sub.storageGB.toStringAsFixed(0)} GB', included: true),
                            _FeatureRow(label: 'API Calls / month', value: '${sub.apiCallLimit}', included: true),
                            _FeatureRow(label: 'Social Features', value: sub.includesSocialFeatures ? 'Included' : 'Not included', included: sub.includesSocialFeatures),
                            _FeatureRow(label: 'Marketing Tools', value: sub.includesMarketingTools ? 'Included' : 'Not included', included: sub.includesMarketingTools),
                            _FeatureRow(label: 'Auto Renewal', value: sub.autoRenew ? 'Enabled' : 'Disabled', included: sub.autoRenew),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Upgrade CTA ──────────────────────────────
              if (sub.plan != SubscriptionPlan.enterprise)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.rocket_launch, size: 24, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Upgrade Your Plan',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                                Text(
                                  'Unlock advanced features and more capacity',
                                  style: TextStyle(fontSize: 11, color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Upgrade',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF8B5CF6)),
                            ),
                          ),
                        ],
                      ),
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

  Color _planColor(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return AppColors.textTertiary;
      case SubscriptionPlan.basic:
        return AppColors.info;
      case SubscriptionPlan.professional:
        return AppColors.accent;
      case SubscriptionPlan.enterprise:
        return const Color(0xFF8B5CF6);
    }
  }
}

class _UsageBar extends StatelessWidget {
  final String label;
  final double used;
  final double limit;
  final String? unit;
  final IconData icon;
  final String? overageNote;

  const _UsageBar({
    required this.label,
    required this.used,
    required this.limit,
    this.unit,
    required this.icon,
    this.overageNote,
  });

  @override
  Widget build(BuildContext context) {
    final pct = limit > 0 ? used / limit : 0.0;
    final color = pct >= 0.9
        ? AppColors.error
        : pct >= 0.7
            ? AppColors.warning
            : AppColors.success;

    return SetupSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: kSetupColor),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const Spacer(),
              Text(
                '${used.toStringAsFixed(unit == 'GB' ? 1 : 0)}${unit != null ? " $unit" : ""} / ${limit.toStringAsFixed(0)}${unit != null ? " $unit" : ""}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              backgroundColor: AppColors.inputBorder,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
          if (overageNote != null) ...[  
            const SizedBox(height: 4),
            Text(overageNote!, style: const TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w500)),
          ],
        ],
      ),
    );
  }
}

// ─── Feature Row ─────────────────────────────────────────────────────────────

class _FeatureRow extends StatelessWidget {
  final String label;
  final String value;
  final bool included;

  const _FeatureRow({required this.label, required this.value, required this.included});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            included ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: included ? AppColors.success : AppColors.textTertiary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: included ? AppColors.textPrimary : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
