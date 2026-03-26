/// ═══════════════════════════════════════════════════════════════════════════
/// MY UPDATES Widget (Social Feed)
/// Visible to: Owner, Administrator only
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/rbac_models.dart';

class MyUpdatesWidgetContent extends StatelessWidget {
  const MyUpdatesWidgetContent({super.key});

  @override
  Widget build(BuildContext context) {
    final color = RoleColors.forModule(PromptModule.myUpdates);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.feed, size: 18, color: color),
              const SizedBox(width: 6),
              const Text(
                'MY UPDATES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Icon(Icons.add_circle_outline, size: 18,
                  color: AppColors.textTertiary),
            ],
          ),

          const SizedBox(height: 10),

          // Interest Filter Chips
          SizedBox(
            height: 28,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(label: 'For You', isSelected: true, color: color),
                const SizedBox(width: 6),
                _FilterChip(label: 'Latest', isSelected: false, color: color),
                const SizedBox(width: 6),
                _FilterChip(label: 'Following', isSelected: false, color: color),
                const SizedBox(width: 6),
                _FilterChip(label: 'Trending', isSelected: false, color: color),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Feed Preview Card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: color.withOpacity(0.2),
                      child: const Text('W', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Wizdom Shop',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      '2h ago',
                      style: TextStyle(fontSize: 9, color: AppColors.textTertiary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'New arrivals just dropped! 🎉 Check out our latest collection...',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const Spacer(),

          // Engagement Metrics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _EngagementStat(icon: Icons.favorite, count: '42', color: color),
              _EngagementStat(icon: Icons.chat_bubble_outline, count: '8', color: color),
              _EngagementStat(icon: Icons.share, count: '3', color: color),
              _EngagementStat(icon: Icons.bookmark_outline, count: '4', color: color),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  const _FilterChip({required this.label, required this.isSelected, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.12) : AppColors.inputFill,
        borderRadius: BorderRadius.circular(14),
        border: isSelected ? Border.all(color: color.withOpacity(0.3)) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? color : AppColors.textTertiary,
        ),
      ),
    );
  }
}

class _EngagementStat extends StatelessWidget {
  final IconData icon;
  final String count;
  final Color color;
  const _EngagementStat({required this.icon, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color.withOpacity(0.6)),
        const SizedBox(width: 3),
        Text(
          count,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
