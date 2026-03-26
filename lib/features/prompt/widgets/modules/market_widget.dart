/// ═══════════════════════════════════════════════════════════════════════════
/// MARKET Widget (Commerce & Logistics)
/// Visible to: Owner, Administrator only
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/rbac_models.dart';

class MarketWidgetContent extends StatelessWidget {
  const MarketWidgetContent({super.key});

  @override
  Widget build(BuildContext context) {
    final color = RoleColors.forModule(PromptModule.market);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.storefront, size: 18, color: color),
              const SizedBox(width: 6),
              const Text(
                'MARKET',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              // Cart badge
              Stack(
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 18,
                      color: AppColors.textSecondary),
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Merchant Carousel (horizontal scroll)
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _MerchantChip(name: 'Fresh Farm', emoji: '🥬'),
                SizedBox(width: 6),
                _MerchantChip(name: 'TechZone', emoji: '📱'),
                SizedBox(width: 6),
                _MerchantChip(name: 'StyleHub', emoji: '👗'),
                SizedBox(width: 6),
                _MerchantChip(name: 'BookNest', emoji: '📚'),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Quick Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MarketAction(icon: Icons.shopping_bag_outlined, label: 'Shop'),
              _MarketAction(icon: Icons.local_shipping_outlined, label: 'Orders'),
              _MarketAction(icon: Icons.local_taxi_outlined, label: 'Ride'),
            ],
          ),

          const Spacer(),

          // Live Deal
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.08), color.withOpacity(0.02)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '10% off Dairy today!',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
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

class _MerchantChip extends StatelessWidget {
  final String name;
  final String emoji;
  const _MerchantChip({required this.name, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(fontSize: 9, color: AppColors.textTertiary),
        ),
      ],
    );
  }
}

class _MarketAction extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MarketAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = RoleColors.forModule(PromptModule.market);
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
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
