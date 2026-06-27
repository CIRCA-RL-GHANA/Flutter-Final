/// 
/// LIVE MODULE  Screen 3: Order Detail Expansion
/// Complete order information: customer, items, delivery, special
/// instructions, driver assignment, timeline, action buttons
/// 
library;

import 'package:flutter/material.dart';
import '../../../core/utils/app_toast.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive.dart';
import '../../../core/routes/app_routes.dart';
import '../providers/live_provider.dart';
import '../widgets/live_widgets.dart';

class LiveOrderDetailScreen extends StatelessWidget {
  const LiveOrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveProvider>(
      builder: (context, prov, _) {
        final order = prov.selectedOrder ?? prov.orders.first;
        return Scaffold(
          backgroundColor: IveTokens.voidColor,
          appBar: LiveAppBar(
            title: 'Order #${order.id}  ${order.priority.name.toUpperCase()}',
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert, size: 20),
                color: IveTokens.ink2Color,
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
                    builder: (_) => const SizedBox(height: 120),
                  );
                },
              ),
              IconButton(icon: const Icon(Icons.download, size: 20), color: IveTokens.ink2Color, onPressed: () => AppToast.show(context, 'Exporting...')),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Status bar
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: order.priorityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: order.priorityColor.withValues(alpha: 0.2)),
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
                    if (order.driverEtaMinutes != null)
                      Text.rich(TextSpan(children: [
                        TextSpan(text: 'ETA ', style: TextStyle(fontSize: 11, color: order.priorityColor)),
                        TextSpan(
                          text: '${order.driverEtaMinutes} min',
                          style: GoogleFonts.ibmPlexMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: order.priorityColor,
                            fontFeatures: [const FontFeature.tabularFigures()],
                          ),
                        ),
                      ])),
                    if (order.driverEtaMinutes == null)
                      Text(
                        'Prep: ${(order.preparationProgress * 100).toInt()}%',
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
                        const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B)),
                        Text(' ${order.customerRating}', style: const TextStyle(fontSize: 12, color: IveTokens.ink2Color)),
                        const SizedBox(width: 8),
                        Text(' ${order.customerOrderCount} orders', style: const TextStyle(fontSize: 12, color: IveTokens.muteColor)),
                      ],
                    ),
                    if (order.customerPhone != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 14, color: IveTokens.ink2Color),
                          const SizedBox(width: 4),
                          Text(order.customerPhone!, style: const TextStyle(fontSize: 13, color: IveTokens.ink2Color)),
                        ],
                      ),
                    ],
                    if (order.customerEmail != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.email, size: 14, color: IveTokens.ink2Color),
                          const SizedBox(width: 4),
                          Text(order.customerEmail!, style: const TextStyle(fontSize: 13, color: IveTokens.ink2Color)),
                        ],
                      ),
                    ],
                    if (order.customerCompany != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.business, size: 14, color: IveTokens.ink2Color),
                          const SizedBox(width: 4),
                          Text('${order.customerCompany}${order.deliveryReception != null ? "  Reception: ${order.deliveryReception}" : ""}', style: const TextStyle(fontSize: 13, color: IveTokens.ink2Color)),
                        ],
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        _ActionChip(label: 'CALL', icon: Icons.phone, onTap: () => AppToast.show(context, 'Calling...')),
                        _ActionChip(label: 'MESSAGE', icon: Icons.message, onTap: () => Navigator.pushNamed(context, AppRoutes.qualChatDashboard)),
                        _ActionChip(label: 'VIEW PROFILE', icon: Icons.person, onTap: () => AppToast.show(context, 'Loading profile...')),
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
                              color: IveTokens.voidColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.shopping_bag, size: 20, color: IveTokens.muteColor),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                if (item.serialNumber != null)
                                  Text('Serial: ${item.serialNumber}', style: const TextStyle(fontSize: 11, color: IveTokens.muteColor)),
                                if (item.stockLocation != null)
                                  Text('Stock: ${item.stockLocation}', style: const TextStyle(fontSize: 11, color: IveTokens.muteColor)),
                              ],
                            ),
                          ),
                          Text('${item.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    )),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal: ${order.subtotal.toStringAsFixed(0)}  Delivery: ${order.deliveryFee.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: IveTokens.ink2Color)),
                        Text('TOTAL: ${order.total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: IveTokens.inkColor)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('Paid: ${order.paymentMethod}', style: const TextStyle(fontSize: 12, color: IveTokens.muteColor)),
                    ),
                  ],
                ),
              ),

              // Delivery Details
              LiveSectionCard(
                title: 'DELIVERY DETAILS',
                icon: Icons.location_on,
                iconColor: IveTokens.moduleLive,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.deliveryAddress, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    if (order.deliveryFloor != null)
                      Text('Floor: ${order.deliveryFloor}${order.deliveryReception != null ? "  Reception: ${order.deliveryReception}" : ""}', style: const TextStyle(fontSize: 13, color: IveTokens.ink2Color)),
                    if (order.accessCode != null)
                      Text('Access code: ${order.accessCode}', style: const TextStyle(fontSize: 13, color: IveTokens.ink2Color)),
                    if (order.parkingNote != null)
                      Text('Parking: ${order.parkingNote}', style: const TextStyle(fontSize: 13, color: IveTokens.ink2Color)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        _ActionChip(label: 'OPEN IN MAPS', icon: Icons.map, onTap: () => AppToast.show(context, 'Opening maps...')),
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
                          _ActionChip(label: 'ADD INSTRUCTION', icon: Icons.add, onTap: () => AppToast.show(context, 'Add instruction...')),
                          _ActionChip(label: 'EDIT', icon: Icons.edit, onTap: () => AppToast.show(context, 'Edit instructions...')),
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
                    if (order.assignedDriverName == null && prov.availableDrivers.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      // AI-recommended driver  quiet gold mark (spec P1)
                      Row(children: [
                        const Icon(Icons.auto_awesome_rounded, size: 12, color: IveTokens.accentColor),
                        const SizedBox(width: 4),
                        Text(
                          prov.availableDrivers.first.name,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: IveTokens.accentColor),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${prov.availableDrivers.first.distanceMiles}mi  ${(prov.availableDrivers.first.completionRate * 100).toInt()}%',
                          style: const TextStyle(fontSize: 12, color: IveTokens.muteColor),
                        ),
                      ]),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        _ActionChip(label: 'ASSIGN DRIVER', icon: Icons.person_add, onTap: () => Navigator.pushNamed(context, AppRoutes.liveDriverAssignment)),
                        _ActionChip(label: 'AUTO-ASSIGN', icon: Icons.auto_fix_high, onTap: () => AppToast.show(context, 'Auto-assigning...')),
                        _ActionChip(label: 'SELF-PICKUP', icon: Icons.store, onTap: () => AppToast.show(context, 'Marked for self-pickup')),
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
          bottomNavigationBar: Container(
            color: IveTokens.voidColor,
            padding: const EdgeInsets.fromLTRB(
              IveTokens.s4, IveTokens.s2, IveTokens.s4, IveTokens.s4,
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: IveButton.primary(
                      label: 'Complete prep',
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Preparation complete')),
                      ),
                    ),
                  ),
                  const SizedBox(width: IveTokens.s2),
                  Expanded(
                    flex: 2,
                    child: IveButton.secondary(
                      label: 'Hold',
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order on hold')),
                      ),
                    ),
                  ),
                  const SizedBox(width: IveTokens.s2),
                  Expanded(
                    flex: 2,
                    child: IveButton.secondary(
                      label: 'Cancel',
                      onPressed: () => showVerifySheet(
                        context,
                        title: 'Cancel order',
                        confirmLabel: 'Cancel order',
                        subtitle: 'This cannot be undone.',
                        isDestructive: true,
                        onConfirm: () async {
                          Navigator.pop(context);
                          return null;
                        },
                      ),
                    ),
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
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(border: Border.all(color: IveTokens.moduleLive.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: IveTokens.moduleLive),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: IveTokens.moduleLive)),
          ],
        ),
      ),
    );
  }
}
