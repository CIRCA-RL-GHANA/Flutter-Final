/// ═══════════════════════════════════════════════════════════════════════════
/// LIVE MODULE — Screen 3: Order Detail Expansion
/// Complete order information: customer, items, delivery, special
/// instructions, driver assignment, timeline, action buttons
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../providers/live_provider.dart';
import '../widgets/live_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class LiveOrderDetailScreen extends StatelessWidget {
  const LiveOrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveProvider>(
      builder: (context, prov, _) {
        final order = prov.selectedOrder ?? prov.orders.first;
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: LiveAppBar(
            title: 'Order #${order.id} • ${order.priority.name.toUpperCase()}',
            actions: [
              IconButton(icon: const Icon(Icons.more_vert, size: 20), color: AppColors.textSecondary, onPressed: () {}),
              IconButton(icon: const Icon(Icons.download, size: 20), color: AppColors.textSecondary, onPressed: () {}),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: kLiveColor.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kLiveColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI: ${ai.insights.first['title'] ?? ''}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kLiveColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Status bar
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: order.priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: order.priorityColor.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: order.priorityColor),
                    const SizedBox(width: 8),
                    Text(
                      'STATUS: ${order.status.name.toUpperCase()}',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: order.priorityColor),
                    ),
                    const Spacer(),
                    Text(
                      'Preparation: ${(order.preparationProgress * 100).toInt()}%',
                      style: TextStyle(fontSize: 12, color: order.priorityColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Customer section
              LiveSectionCard(
                title: 'CUSTOMER',
                icon: Icons.person,
                iconColor: const Color(0xFF3B82F6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(order.customerName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Icon(Icons.star, size: 14, color: const Color(0xFFF59E0B)),
                        Text(' ${order.customerRating}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(width: 8),
                        Text('• ${order.customerOrderCount} orders', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                      ],
                    ),
                    if (order.customerPhone != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(order.customerPhone!, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                    if (order.customerEmail != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.email, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(order.customerEmail!, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                    if (order.customerCompany != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.business, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('${order.customerCompany}${order.deliveryReception != null ? " • Reception: ${order.deliveryReception}" : ""}', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        _ActionChip(label: 'CALL', icon: Icons.phone, onTap: () {}),
                        _ActionChip(label: 'MESSAGE', icon: Icons.message, onTap: () {}),
                        _ActionChip(label: 'VIEW PROFILE', icon: Icons.person, onTap: () {}),
                      ],
                    ),
                  ],
                ),
              ),

              // Order Items
              LiveSectionCard(
                title: 'ORDER ITEMS (${order.items.length})',
                icon: Icons.inventory_2,
                iconColor: const Color(0xFF10B981),
                child: Column(
                  children: [
                    ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.backgroundLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.shopping_bag, size: 20, color: AppColors.textTertiary),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                if (item.serialNumber != null)
                                  Text('Serial: ${item.serialNumber}', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                                if (item.stockLocation != null)
                                  Text('Stock: ${item.stockLocation}', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                              ],
                            ),
                          ),
                          Text('₵${item.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    )),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal: ₵${order.subtotal.toStringAsFixed(0)} • Delivery: ₵${order.deliveryFee.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        Text('TOTAL: ₵${order.total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('Paid: ${order.paymentMethod}', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                    ),
                  ],
                ),
              ),

              // Delivery Details
              LiveSectionCard(
                title: 'DELIVERY DETAILS',
                icon: Icons.location_on,
                iconColor: kLiveColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.deliveryAddress, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    if (order.deliveryFloor != null)
                      Text('Floor: ${order.deliveryFloor}${order.deliveryReception != null ? " • Reception: ${order.deliveryReception}" : ""}', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    if (order.accessCode != null)
                      Text('Access code: ${order.accessCode}', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    if (order.parkingNote != null)
                      Text('Parking: ${order.parkingNote}', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        _ActionChip(label: 'OPEN IN MAPS', icon: Icons.map, onTap: () {}),
                        _ActionChip(label: 'COPY ADDRESS', icon: Icons.copy, onTap: () => HapticFeedback.lightImpact()),
                      ],
                    ),
                  ],
                ),
              ),

              // Special Instructions
              if (order.customerNote != null)
                LiveSectionCard(
                  title: 'SPECIAL INSTRUCTIONS',
                  icon: Icons.note_alt,
                  iconColor: const Color(0xFFF59E0B),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('"${order.customerNote}"', style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _ActionChip(label: 'ADD INSTRUCTION', icon: Icons.add, onTap: () {}),
                          _ActionChip(label: 'EDIT', icon: Icons.edit, onTap: () {}),
                        ],
                      ),
                    ],
                  ),
                ),

              // Delivery Assignment
              LiveSectionCard(
                title: 'DELIVERY ASSIGNMENT',
                icon: Icons.local_shipping,
                iconColor: const Color(0xFF3B82F6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.assignedDriverName != null
                          ? 'Currently: ${order.assignedDriverName}'
                          : 'Currently: Unassigned',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    if (order.assignedDriverName == null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Recommended: ${prov.availableDrivers.isNotEmpty ? "${prov.availableDrivers.first.name} (${prov.availableDrivers.first.distanceMiles}mi, ${(prov.availableDrivers.first.completionRate * 100).toInt()}% rating)" : "None available"}',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        _ActionChip(label: 'ASSIGN DRIVER', icon: Icons.person_add, onTap: () => Navigator.pushNamed(context, AppRoutes.liveDriverAssignment)),
                        _ActionChip(label: 'AUTO-ASSIGN', icon: Icons.auto_fix_high, onTap: () {}),
                        _ActionChip(label: 'SELF-PICKUP', icon: Icons.store, onTap: () {}),
                      ],
                    ),
                  ],
                ),
              ),

              // Timeline
              LiveSectionCard(
                title: 'TIMELINE',
                icon: Icons.timeline,
                iconColor: const Color(0xFF10B981),
                child: LiveTimelineWidget(
                  entries: order.timeline,
                  currentLabel: 'READY FOR ASSIGNMENT',
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('COMPLETE PREP', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFF59E0B),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('HOLD', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kLiveColor,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  const _ActionChip({required this.label, required this.icon, this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(border: Border.all(color: kLiveColor.withOpacity(0.3)), borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: kLiveColor),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kLiveColor)),
          ],
        ),
      ),
    );
  }
}
