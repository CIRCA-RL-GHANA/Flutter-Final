/// ═══════════════════════════════════════════════════════════════════════════
/// GO PAGE Widget (Financial Hub)
/// Visible to: Owner, Administrator only
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/rbac_models.dart';

class GoPageWidgetContent extends StatefulWidget {
  const GoPageWidgetContent({super.key});

  @override
  State<GoPageWidgetContent> createState() => _GoPageWidgetContentState();
}

class _GoPageWidgetContentState extends State<GoPageWidgetContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _counterController;
  late Animation<double> _counterAnim;

  @override
  void initState() {
    super.initState();
    _counterController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
    _counterAnim = Tween<double>(begin: 0, end: 14250).animate(
      CurvedAnimation(parent: _counterController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _counterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = RoleColors.forModule(PromptModule.goPage);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.account_balance_wallet, size: 18, color: color),
              const SizedBox(width: 6),
              const Text(
                'GO PAGE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              const _GatewayDot(label: 'PS', isOnline: true),
              const SizedBox(width: 4),
              const _GatewayDot(label: 'FW', isOnline: true),
            ],
          ),

          const SizedBox(height: 12),

          // Balance Display
          AnimatedBuilder(
            animation: _counterAnim,
            builder: (context, child) {
              return Text(
                '${_counterAnim.value.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} QP',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              );
            },
          ),

          const SizedBox(height: 4),

          // Live Rate
          Text(
            '1 QP = 0.085 GHS',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textTertiary,
            ),
          ),

          const SizedBox(height: 12),

          // Quick Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _GoPageAction(icon: Icons.add_circle_outline, label: 'Buy'),
              _GoPageAction(icon: Icons.remove_circle_outline, label: 'Sell'),
              _GoPageAction(icon: Icons.swap_horiz, label: 'Send'),
              _GoPageAction(icon: Icons.receipt_long, label: 'Tabs'),
            ],
          ),

          const Spacer(),

          // Recent Activity
          const _RecentTransaction(
            title: '+500 QP from Bob',
            subtitle: 'Transfer • 1h ago',
            isPositive: true,
          ),
        ],
      ),
    );
  }
}

class _GoPageAction extends StatelessWidget {
  final IconData icon;
  final String label;
  const _GoPageAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: RoleColors.forModule(PromptModule.goPage).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18,
              color: RoleColors.forModule(PromptModule.goPage)),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _GatewayDot extends StatelessWidget {
  final String label;
  final bool isOnline;
  const _GatewayDot({required this.label, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label gateway ${isOnline ? "online" : "offline"}',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 8, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _RecentTransaction extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isPositive;

  const _RecentTransaction({
    required this.title,
    required this.subtitle,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            isPositive ? Icons.arrow_downward : Icons.arrow_upward,
            size: 14,
            color: isPositive ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
