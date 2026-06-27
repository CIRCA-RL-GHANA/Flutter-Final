/// 
/// LIVE MODULE  Shared Widgets
/// Reusable UI components: LiveAppBar, LiveOrderCard, LivePackageCard,
/// LiveReturnCard, LiveDriverCard, LiveMetricBadge, LiveTimeline,
/// LiveVerificationWidget, LiveSectionCard, LiveEmptyState, etc.
/// 
library;

import 'package:flutter/material.dart';
import '../../../core/utils/app_toast.dart';
import 'package:flutter/services.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/design/ive.dart';
import '../models/live_models.dart';

//  LIVE Module Color 

// Module color is IveTokens.moduleLive (#34D399  logistics green).

//  Live App Bar 

class LiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final Color? backgroundColor;

  const LiveAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.backgroundColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? IveTokens.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: showBackButton
          ? Row(
              children: [
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 22),
                  color: IveTokens.ink,
                  onPressed: () => Navigator.pop(context),
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: IveTokens.moduleLive,
                  ),
                ),
              ],
            )
          : leading,
      leadingWidth: showBackButton ? 70 : 56,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: IveTokens.ink,
        ),
      ),
      centerTitle: true,
      actions: actions,
    );
  }
}

//  Live Order Card 

class LiveOrderCard extends StatelessWidget {
  final LiveOrder order;
  final VoidCallback? onTap;
  final VoidCallback? onAssign;
  final VoidCallback? onTrack;
  final bool compact;

  const LiveOrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onAssign,
    this.onTrack,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: IveTokens.surface,
          borderRadius: BorderRadius.circular(IveTokens.rSm),
          border: Border.all(
            color: order.priority == OrderPriority.urgent
                ? IveTokens.moduleLive.withValues(alpha: 0.3)
                : IveTokens.hairline,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Text(
                    'Order #${order.id}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: IveTokens.ink),
                  ),
                  const SizedBox(width: 8),
                  _PriorityBadge(priority: order.priority),
                  if (order.isOverdue) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: IveTokens.moduleLive.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(IveTokens.rXs),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time, size: 12, color: IveTokens.moduleLive),
                          SizedBox(width: 2),
                          Text(
                            'OVERDUE',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: IveTokens.moduleLive),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    order.timeSinceCreated,
                    style: const TextStyle(fontSize: 12, color: IveTokens.mute),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Customer row
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: IveTokens.ink2),
                  const SizedBox(width: 4),
                  Text(
                    order.customerName,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: IveTokens.ink),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.star, size: 14, color: IveTokens.warning),
                  Text(
                    order.customerRating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 12, color: IveTokens.ink2),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Address row
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: IveTokens.ink2),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.deliveryAddress,
                      style: const TextStyle(fontSize: 13, color: IveTokens.ink2),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Items row
              Row(
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 16, color: IveTokens.ink2),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.items.map((i) => i.name).join(', '),
                      style: const TextStyle(fontSize: 13, color: IveTokens.ink2),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              // Special requirements
              if (order.requiresColdStorage || order.requiresIdVerification || order.isFragile) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [
                    if (order.requiresColdStorage) const _SpecialTag(icon: Icons.ac_unit, label: 'Cold storage'),
                    if (order.requiresIdVerification) const _SpecialTag(icon: Icons.badge, label: 'ID required'),
                    if (order.isFragile) const _SpecialTag(icon: Icons.warning_amber, label: 'Fragile'),
                  ],
                ),
              ],
              // Customer note
              if (order.customerNote != null && !compact) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: IveTokens.surfaceRaised,
                    borderRadius: BorderRadius.circular(IveTokens.rSm),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline, size: 14, color: IveTokens.mute),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '"${order.customerNote}"',
                          style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: IveTokens.ink2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // Driver status panel
              if (order.assignedDriverName != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: IveTokens.success.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(IveTokens.rSm),
                    border: Border.all(color: IveTokens.success.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_shipping, size: 16, color: IveTokens.success),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Driver: ${order.assignedDriverName}${order.driverDistanceMiles != null ? " (${order.driverDistanceMiles}mi away)" : ""}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: IveTokens.success),
                        ),
                      ),
                      if (order.driverEtaMinutes != null)
                        Text(
                          'ETA: ${order.driverEtaMinutes}min',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: IveTokens.success),
                        ),
                    ],
                  ),
                ),
              ] else ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: IveTokens.warning.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(IveTokens.rSm),
                    border: Border.all(color: IveTokens.warning.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_search, size: 16, color: IveTokens.warning),
                      const SizedBox(width: 6),
                      const Text(
                        'Driver: Unassigned',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: IveTokens.warning),
                      ),
                      const Spacer(),
                      if (order.prepTimeMinutes != null)
                        Text(
                          'Prep: ${order.prepTimeMinutes}min',
                          style: const TextStyle(fontSize: 11, color: IveTokens.warning),
                        ),
                    ],
                  ),
                ),
              ],
              // Action buttons
              if (!compact) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (order.assignedDriverName == null) ...[
                      _LiveActionChip(label: 'ASSIGN DRIVER', icon: Icons.person_add, onTap: onAssign),
                      _LiveActionChip(label: 'SELF-PICKUP', icon: Icons.store, onTap: () => AppToast.show(context, 'Self-pickup confirmed')),
                      _LiveActionChip(label: 'CREATE PACKAGE', icon: Icons.inventory, onTap: () => AppToast.show(context, 'Creating package...')),
                    ] else ...[
                      _LiveActionChip(label: 'VIEW DETAILS', icon: Icons.visibility, onTap: onTap),
                      _LiveActionChip(label: 'TRACK DRIVER', icon: Icons.gps_fixed, onTap: onTrack),
                      _LiveActionChip(label: 'MESSAGE', icon: Icons.message, onTap: () => Navigator.pushNamed(context, AppRoutes.qualChatDashboard)),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

//  Live Package Card 

class LivePackageCard extends StatelessWidget {
  final LivePackage package;
  final VoidCallback? onTap;
  final VoidCallback? onTrack;
  final bool compact;

  const LivePackageCard({
    super.key,
    required this.package,
    this.onTap,
    this.onTrack,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: IveTokens.surface,
          borderRadius: BorderRadius.circular(IveTokens.rSm),
          border: Border.all(color: IveTokens.hairline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.inventory_2, size: 18, color: IveTokens.accent),
                  const SizedBox(width: 6),
                  Text(
                    'Package #${package.id}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(label: package.status.name.toUpperCase(), color: _packageStatusColor(package.status)),
                ],
              ),
              const SizedBox(height: 10),
              // Driver info
              if (package.driverName != null)
                Row(
                  children: [
                    const Icon(Icons.local_shipping_outlined, size: 16, color: IveTokens.ink2),
                    const SizedBox(width: 4),
                    Text(
                      'Driver: ${package.driverName}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: IveTokens.ink),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, size: 14, color: IveTokens.warning),
                    Text(
                      package.driverRating?.toStringAsFixed(1) ?? '',
                      style: const TextStyle(fontSize: 12, color: IveTokens.ink2),
                    ),
                  ],
                ),
              const SizedBox(height: 6),
              // Stops & ETA
              Row(
                children: [
                  const Icon(Icons.route, size: 16, color: IveTokens.ink2),
                  const SizedBox(width: 4),
                  Text(
                    'Stops: ${package.progressText}',
                    style: const TextStyle(fontSize: 13, color: IveTokens.ink2),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.timer_outlined, size: 16, color: IveTokens.ink2),
                  const SizedBox(width: 4),
                  Text(
                    'ETA: ${package.estimatedTimeMinutes}min',
                    style: const TextStyle(fontSize: 13, color: IveTokens.ink2),
                  ),
                ],
              ),
              // Contents summary
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.list_alt, size: 16, color: IveTokens.ink2),
                  const SizedBox(width: 4),
                  Text(
                    '${package.stops.where((s) => s.type == StopType.delivery).length} deliveries, '
                    '${package.stops.where((s) => s.type == StopType.returnPickup).length} return pickups',
                    style: const TextStyle(fontSize: 13, color: IveTokens.ink2),
                  ),
                ],
              ),
              // Security
              if (package.biometricRequired || package.pinRequired) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.security, size: 16, color: IveTokens.ink2),
                    const SizedBox(width: 4),
                    Text(
                      'Security: ${[
                        if (package.biometricRequired) 'Biometric',
                        if (package.pinRequired) 'PIN',
                      ].join(' + ')}',
                      style: const TextStyle(fontSize: 12, color: IveTokens.ink2),
                    ),
                  ],
                ),
              ],
              // Current stop
              if (!compact && package.stops.any((s) => s.status == StopStatus.inProgress)) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: IveTokens.accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(IveTokens.rSm),
                    border: Border.all(color: IveTokens.accent.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CURRENT STOP: ${package.stops.firstWhere((s) => s.status == StopStatus.inProgress).sequence}/${package.totalStops}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: IveTokens.accent),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${package.stops.firstWhere((s) => s.status == StopStatus.inProgress).type == StopType.returnPickup ? "Return pickup" : "Delivery"} at ${package.stops.firstWhere((s) => s.status == StopStatus.inProgress).customerName}',
                        style: const TextStyle(fontSize: 13, color: IveTokens.ink2),
                      ),
                    ],
                  ),
                ),
              ],
              // Actions
              if (!compact) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    _LiveActionChip(label: 'TRACK LIVE', icon: Icons.gps_fixed, onTap: onTrack),
                    _LiveActionChip(label: 'MESSAGE', icon: Icons.message_outlined, onTap: () => Navigator.pushNamed(context, AppRoutes.qualChatDashboard)),
                    if (package.driverName != null)
                      _LiveActionChip(label: 'REASSIGN', icon: Icons.swap_horiz, onTap: () => Navigator.pushNamed(context, AppRoutes.liveDriverAssignment)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _packageStatusColor(PackageStatus status) {
    switch (status) {
      case PackageStatus.created:
        return IveTokens.accent;
      case PackageStatus.active:
        return IveTokens.success;
      case PackageStatus.inTransit:
        return IveTokens.warning;
      case PackageStatus.delivered:
        return IveTokens.success;
      case PackageStatus.returned:
        return IveTokens.info;
      case PackageStatus.cancelled:
        return IveTokens.danger;
    }
  }
}

//  Live Return Card 

class LiveReturnCard extends StatelessWidget {
  final LiveReturn ret;
  final VoidCallback? onTap;
  final VoidCallback? onReview;
  final bool compact;

  const LiveReturnCard({
    super.key,
    required this.ret,
    this.onTap,
    this.onReview,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: IveTokens.surface,
          borderRadius: BorderRadius.circular(IveTokens.rSm),
          border: Border.all(color: IveTokens.hairline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    'Return #${ret.id}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: IveTokens.ink),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(label: _returnStatusLabel(ret.status), color: _returnStatusColor(ret.status)),
                  const Spacer(),
                  Text(ret.timeSinceCreated, style: const TextStyle(fontSize: 12, color: IveTokens.mute)),
                ],
              ),
              const SizedBox(height: 10),
              // Customer
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: IveTokens.ink2),
                  const SizedBox(width: 4),
                  Text(ret.customerName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: IveTokens.ink)),
                  const SizedBox(width: 8),
                  const Icon(Icons.star, size: 14, color: IveTokens.warning),
                  Text(ret.customerRating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, color: IveTokens.ink2)),
                  const SizedBox(width: 8),
                  Text(
                    '${_ordinal(ret.customerReturnCount)} return',
                    style: const TextStyle(fontSize: 12, color: IveTokens.mute),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Item
              Row(
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 16, color: IveTokens.ink2),
                  const SizedBox(width: 4),
                  Text('${ret.itemName}  ${ret.itemPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, color: IveTokens.ink2)),
                ],
              ),
              const SizedBox(height: 4),
              // Reason
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: IveTokens.ink2),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${ret.reason}${ret.reasonDetail != null ? "  \"${ret.reasonDetail}\"" : ""}',
                      style: const TextStyle(fontSize: 13, color: IveTokens.ink2),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              // Evidence indicators
              if (ret.hasVideo || ret.hasVoiceNote) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (ret.hasVideo) ...[
                      const Icon(Icons.videocam, size: 16, color: IveTokens.info),
                      const SizedBox(width: 4),
                      Text(
                        'VIDEO (${_formatDuration(ret.videoEvidence!)})',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: IveTokens.info),
                      ),
                      const SizedBox(width: 10),
                    ],
                    if (ret.hasVoiceNote) ...[
                      const Icon(Icons.mic, size: 16, color: IveTokens.accent),
                      const SizedBox(width: 4),
                      Text(
                        'VOICE NOTE (${_formatDuration(ret.voiceNote!)})',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: IveTokens.accent),
                      ),
                    ],
                  ],
                ),
              ],
              // Reviewer
              if (ret.reviewerName != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: IveTokens.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(IveTokens.rXs),
                  ),
                  child: Text(
                    'Reviewer: ${ret.reviewerName}  Started ${ret.reviewStartedAt != null ? "${DateTime.now().difference(ret.reviewStartedAt!).inMinutes}min ago" : ""}',
                    style: const TextStyle(fontSize: 11, color: IveTokens.warning),
                  ),
                ),
              ],
              // Actions
              if (!compact) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    if (ret.status == LiveReturnStatus.pending)
                      _LiveActionChip(label: 'REVIEW RETURN', icon: Icons.rate_review, onTap: onReview),
                    if (ret.status == LiveReturnStatus.pending)
                      _LiveActionChip(label: 'REQUEST MORE INFO', icon: Icons.help_outline, onTap: () => AppToast.show(context, 'Info request sent to customer')),
                    if (ret.status == LiveReturnStatus.underReview)
                      _LiveActionChip(label: 'VIEW REVIEW', icon: Icons.visibility, onTap: onTap),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _returnStatusLabel(LiveReturnStatus status) {
    switch (status) {
      case LiveReturnStatus.pending: return 'PENDING';
      case LiveReturnStatus.underReview: return 'UNDER REVIEW';
      case LiveReturnStatus.approved: return 'APPROVED';
      case LiveReturnStatus.partiallyApproved: return 'PARTIAL';
      case LiveReturnStatus.rejected: return 'REJECTED';
      case LiveReturnStatus.escalated: return 'ESCALATED';
    }
  }

  Color _returnStatusColor(LiveReturnStatus status) {
    switch (status) {
      case LiveReturnStatus.pending: return IveTokens.moduleLive;
      case LiveReturnStatus.underReview: return IveTokens.warning;
      case LiveReturnStatus.approved: return IveTokens.success;
      case LiveReturnStatus.partiallyApproved: return IveTokens.accent;
      case LiveReturnStatus.rejected: return IveTokens.danger;
      case LiveReturnStatus.escalated: return IveTokens.info;
    }
  }

  String _ordinal(int n) {
    if (n == 1) return '1st';
    if (n == 2) return '2nd';
    if (n == 3) return '3rd';
    return '${n}th';
  }

  String _formatDuration(Duration d) {
    final min = d.inMinutes;
    final sec = d.inSeconds % 60;
    return '$min:${sec.toString().padLeft(2, '0')}';
  }
}

//  Live Driver Card 

class LiveDriverCard extends StatelessWidget {
  final LiveDriver driver;
  final VoidCallback? onSelect;
  final VoidCallback? onViewProfile;
  final bool isRecommended;
  final bool compact;

  const LiveDriverCard({
    super.key,
    required this.driver,
    this.onSelect,
    this.onViewProfile,
    this.isRecommended = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: IveTokens.surface,
        borderRadius: BorderRadius.circular(IveTokens.rSm),
        border: Border.all(
          color: isRecommended ? IveTokens.success.withValues(alpha: 0.3) : IveTokens.hairline,
          width: isRecommended ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRecommended)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: IveTokens.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(IveTokens.rSm),
                        border: Border.all(color: IveTokens.success.withValues(alpha: 0.4)),
                      ),
                      child: const Text(
                        ' RECOMMENDED',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: IveTokens.success),
                      ),
                    ),
                  ],
                ),
              ),
            // Driver info row
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: IveTokens.accentSoft,
                  child: Text(
                    driver.name.split(' ').map((n) => n[0]).take(2).join(),
                    style: const TextStyle(fontWeight: FontWeight.w700, color: IveTokens.accent),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.name,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: IveTokens.ink),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: IveTokens.warning),
                          Text(' ${driver.rating} ', style: const TextStyle(fontSize: 12, color: IveTokens.ink2)),
                          Text(' ${driver.distanceMiles}mi away', style: const TextStyle(fontSize: 12, color: IveTokens.ink2)),
                        ],
                      ),
                    ],
                  ),
                ),
                _AvailabilityDot(availability: driver.availability),
              ],
            ),
            if (!compact) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  _DriverStat(label: 'Completion', value: '${(driver.completionRate * 100).toInt()}%'),
                  const SizedBox(width: 16),
                  _DriverStat(label: 'ETA Store', value: '${driver.etaToStoreMinutes}min'),
                  const SizedBox(width: 16),
                  _DriverStat(label: 'ETA Customer', value: '${driver.etaToCustomerMinutes}min'),
                ],
              ),
              if (driver.specialties.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: driver.specialties.map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: IveTokens.surfaceRaised,
                      borderRadius: BorderRadius.circular(IveTokens.rXs),
                    ),
                    child: Text(s, style: const TextStyle(fontSize: 11, color: IveTokens.ink2)),
                  )).toList(),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: IveButton.primary(
                      label: 'SELECT & ASSIGN',
                      onPressed: onSelect,
                      icon: Icons.check_circle,
                      compact: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: onViewProfile,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: IveTokens.ink2,
                      side: const BorderSide(color: IveTokens.hairline2),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(IveTokens.rSm)),
                    ),
                    child: const Text('VIEW PROFILE', style: TextStyle(fontSize: 12, color: IveTokens.ink2)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

//  Live Metric Badge 

class LiveMetricBadge extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;

  const LiveMetricBadge({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color = IveTokens.accent,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(IveTokens.rSm),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
          if (trend != null) ...[
            const SizedBox(height: 2),
            Text(trend!, style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.7))),
          ],
        ],
      ),
    );
  }
}

//  Live Timeline Widget 

class LiveTimelineWidget extends StatelessWidget {
  final List<OrderTimelineEntry> entries;
  final String? currentLabel;

  const LiveTimelineWidget({
    super.key,
    required this.entries,
    this.currentLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < entries.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: entries[i].isCompleted ? IveTokens.success : IveTokens.faint,
                    ),
                    child: entries[i].isCompleted
                        ? const Icon(Icons.check, size: 8, color: IveTokens.ink)
                        : null,
                  ),
                  if (i < entries.length - 1 || currentLabel != null)
                    Container(
                      width: 2,
                      height: 28,
                      color: entries[i].isCompleted ? IveTokens.success.withValues(alpha: 0.3) : IveTokens.hairline,
                    ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_formatTime(entries[i].timestamp)} - ${entries[i].title}',
                      style: TextStyle(
                        fontSize: 13,
                        color: entries[i].isCompleted ? IveTokens.ink : IveTokens.ink2,
                      ),
                    ),
                    if (entries[i].description != null)
                      Text(
                        entries[i].description!,
                        style: const TextStyle(fontSize: 11, color: IveTokens.mute),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
        if (currentLabel != null) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: IveTokens.moduleLive,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'NOW - $currentLabel',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: IveTokens.moduleLive),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:${dt.minute.toString().padLeft(2, '0')} $ampm';
  }
}

//  Live Section Card 

class LiveSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final Widget child;
  final VoidCallback? onMore;

  const LiveSectionCard({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
    required this.child,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: IveTokens.surface,
        borderRadius: BorderRadius.circular(IveTokens.rSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 8),
            child: Row(
              children: [
                Icon(icon, size: 18, color: iconColor ?? IveTokens.moduleLive),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: IveTokens.ink),
                ),
                const Spacer(),
                if (onMore != null)
                  GestureDetector(
                    onTap: onMore,
                    child: const Icon(Icons.chevron_right, size: 20, color: IveTokens.mute),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: child,
          ),
        ],
      ),
    );
  }
}

//  Live Empty State 

class LiveEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String>? suggestions;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? tip;

  const LiveEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.suggestions,
    this.actionLabel,
    this.onAction,
    this.tip,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: IveTokens.mute),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: IveTokens.ink),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: IveTokens.ink2),
              textAlign: TextAlign.center,
            ),
            if (suggestions != null && suggestions!.isNotEmpty) ...[
              const SizedBox(height: 20),
              ...suggestions!.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 16, color: IveTokens.success),
                    const SizedBox(width: 6),
                    Text(s, style: const TextStyle(fontSize: 13, color: IveTokens.ink2)),
                  ],
                ),
              )),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: 20),
              IveButton.primary(
                label: actionLabel!,
                onPressed: onAction,
                expand: false,
              ),
            ],
            if (tip != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: IveTokens.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(IveTokens.rSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 18, color: IveTokens.warning),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        tip!,
                        style: const TextStyle(fontSize: 12, color: IveTokens.warning),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

//  Verification PIN Display 

class PinDisplayWidget extends StatelessWidget {
  final String pin;
  final String label;

  const PinDisplayWidget({
    super.key,
    required this.pin,
    this.label = 'Verification PIN',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IveTokens.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(IveTokens.rSm),
        border: Border.all(color: IveTokens.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: IveTokens.ink2)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: pin.split('').map((d) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 36,
              height: 44,
              decoration: BoxDecoration(
                color: IveTokens.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(IveTokens.rSm),
              ),
              child: Center(
                child: Text(
                  d,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: IveTokens.ink),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                },
                icon: const Icon(Icons.refresh, size: 16, color: IveTokens.ink2),
                label: const Text('REGENERATE', style: TextStyle(fontSize: 11, color: IveTokens.ink2)),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                },
                icon: const Icon(Icons.copy, size: 16, color: IveTokens.ink2),
                label: const Text('COPY', style: TextStyle(fontSize: 11, color: IveTokens.ink2)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//  Private Helpers 

class _PriorityBadge extends StatelessWidget {
  final OrderPriority priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(IveTokens.rXs),
      ),
      child: Text(
        priority.name.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  Color _colorFor(OrderPriority p) {
    switch (p) {
      case OrderPriority.urgent: return IveTokens.danger;
      case OrderPriority.normal: return IveTokens.warning;
      case OrderPriority.flexible: return IveTokens.success;
      case OrderPriority.scheduled: return IveTokens.accent;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(IveTokens.rXs),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class _SpecialTag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SpecialTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: IveTokens.surfaceRaised,
        borderRadius: BorderRadius.circular(IveTokens.rXs),
        border: Border.all(color: IveTokens.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: IveTokens.ink2),
          const SizedBox(width: 3),
          Text(label, style: const TextStyle(fontSize: 10, color: IveTokens.ink2)),
        ],
      ),
    );
  }
}

class _LiveActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _LiveActionChip({required this.label, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      borderRadius: BorderRadius.circular(IveTokens.rSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: IveTokens.moduleLive.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(IveTokens.rSm),
        ),
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

class _AvailabilityDot extends StatelessWidget {
  final DriverAvailability availability;

  const _AvailabilityDot({required this.availability});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(availability);
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Color _colorFor(DriverAvailability a) {
    switch (a) {
      case DriverAvailability.online: return IveTokens.success;
      case DriverAvailability.offline: return IveTokens.faint;
      case DriverAvailability.onBreak: return IveTokens.warning;
    }
  }
}

class _DriverStat extends StatelessWidget {
  final String label;
  final String value;

  const _DriverStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: IveTokens.mute)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: IveTokens.ink)),
      ],
    );
  }
}
