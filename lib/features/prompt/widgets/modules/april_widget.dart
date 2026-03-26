/// ═══════════════════════════════════════════════════════════════════════════
/// APRIL Widget (Personal Assistant)
/// Visible to: Owner ONLY (completely hidden for other roles)
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/rbac_models.dart';

class AprilWidgetContent extends StatelessWidget {
  final String userName;

  const AprilWidgetContent({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final color = RoleColors.forModule(PromptModule.april);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.05),
            Colors.white,
          ],
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.assistant, size: 16, color: color),
              ),
              const SizedBox(width: 6),
              const Text(
                'APRIL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              // Voice Command Button
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.mic, size: 16, color: Colors.white),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Greeting
          Text(
            _getGreeting(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 4),

          // Action Summary
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              '3 actions pending',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.warning,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Quick Commands
          _QuickCommand(icon: Icons.analytics, label: 'Review budget', color: color),
          const SizedBox(height: 4),
          _QuickCommand(icon: Icons.add, label: 'Add expense', color: color),

          const Spacer(),

          // Notification Panel
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.info.withOpacity(0.12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt, size: 14, color: AppColors.info),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Bill due tomorrow: ₵150',
                    style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  ),
                ),
                Icon(Icons.snooze, size: 14, color: AppColors.textTertiary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    final emoji = hour < 12
        ? '🌤️'
        : hour < 18
            ? '☀️'
            : '🌙';
    final period = hour < 12
        ? 'morning'
        : hour < 18
            ? 'afternoon'
            : 'evening';
    return 'Good $period, $userName $emoji';
  }
}

class _QuickCommand extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _QuickCommand({required this.icon, required this.label, required this.color});

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
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const Spacer(),
          Icon(Icons.chevron_right, size: 14, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}
