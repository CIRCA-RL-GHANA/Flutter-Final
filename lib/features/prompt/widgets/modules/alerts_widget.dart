/// ═══════════════════════════════════════════════════════════════════════════
/// ALERTS Widget (Resolution Log)
/// Visible to: ALL roles EXCEPT Owner
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/rbac_models.dart';

class AlertsWidgetContent extends StatelessWidget {
  const AlertsWidgetContent({super.key});

  @override
  Widget build(BuildContext context) {
    final color = RoleColors.forModule(PromptModule.alerts);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.notification_important, size: 18, color: color),
              const SizedBox(width: 6),
              const Text(
                'ALERTS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '12 resolved',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Filter Summary
          Text(
            'Last 7 days • 12 resolved • 2 pending',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textTertiary,
            ),
          ),

          const SizedBox(height: 10),

          // Resolved Alerts List
          const _AlertItem(
            title: 'Payment #TX-2041',
            status: 'Resolved',
            resolver: 'Sarah',
            isResolved: true,
          ),
          const SizedBox(height: 6),
          const _AlertItem(
            title: 'Shipment #SH-1082',
            status: 'Resolved',
            resolver: 'Mike',
            isResolved: true,
          ),
          const SizedBox(height: 6),
          const _AlertItem(
            title: 'Return #RT-0455',
            status: 'Pending',
            resolver: '',
            isResolved: false,
          ),

          const Spacer(),

          // Mini Pie Chart (distribution)
          Row(
            children: [
              _DistributionBar(label: 'Pay', pct: 0.4, color: color),
              const SizedBox(width: 4),
              const _DistributionBar(label: 'Ship', pct: 0.3, color: AppColors.warning),
              const SizedBox(width: 4),
              const _DistributionBar(label: 'Other', pct: 0.3, color: AppColors.info),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  final String title;
  final String status;
  final String resolver;
  final bool isResolved;

  const _AlertItem({
    required this.title,
    required this.status,
    required this.resolver,
    required this.isResolved,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isResolved ? AppColors.success : AppColors.warning,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (isResolved && resolver.isNotEmpty)
            CircleAvatar(
              radius: 10,
              backgroundColor: AppColors.primaryLight.withOpacity(0.15),
              child: Text(
                resolver[0],
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}

class _DistributionBar extends StatelessWidget {
  final String label;
  final double pct;
  final Color color;
  const _DistributionBar({required this.label, required this.pct, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: (pct * 100).toInt(),
      child: Column(
        children: [
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: color.withOpacity(0.7),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 8, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
