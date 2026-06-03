/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
/// MARKET MODULE — Screen 10: Delivery Tracker & PIN Verification
/// Live map, delivery timeline, driver info, PIN handoff, safety features
/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/design/ive_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../models/market_models.dart';
import '../providers/market_provider.dart';
import '../widgets/market_widgets.dart';

class MarketDeliveryTrackerScreen extends StatelessWidget {
  const MarketDeliveryTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketProvider>(
      builder: (context, prov, _) {
        final tracking = prov.activeDelivery;
        if (tracking == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Delivery Tracker')),
            body: const MarketEmptyState(
              icon: Icons.local_shipping,
              title: 'No active delivery',
              subtitle: 'Track your deliveries here',
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: CustomScrollView(
            slivers: [
              // Map + AppBar
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: kMarketColorDark,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, size: 20, color: AppColors.textPrimary),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.phone, size: 20, color: AppColors.textPrimary),
                    ),
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Calling driver...'), behavior: SnackBarBehavior.floating)),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Route map card with native maps deep-link.
                      _DeliveryMapBanner(
                        driverName: tracking.driverName,
                        destinationLat: tracking.destinationLat,
                        destinationLng: tracking.destinationLng,
                        merchantLat: tracking.merchantLat,
                        merchantLng: tracking.merchantLng,
                        etaMinutes: tracking.etaMinutes,
                      ),
                      // ETA overlay
                      Positioned(
                        top: 100,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8)],
                          ),
                          child: Column(
                            children: [
                              Text(
                              '${tracking.etaMinutes} min',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kMarketColorDark),
                              ),
                              const Text('ETA', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // AI Insights
              SliverToBoxAdapter(
                child: Consumer<AIInsightsNotifier>(
                  builder: (context, ai, _) {
                    if (ai.insights.isEmpty) return const SizedBox.shrink();
                    return Container(
                      color: kMarketColor.withValues(alpha: 0.07),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Row(children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kMarketColor),
                        const SizedBox(width: 8),
                        Expanded(child: Text('AI: ${ai.insights.first['title'] ?? ''}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kMarketColor),
                          maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ]),
                    );
                  },
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Status card
                      _buildStatusCard(tracking),
                      const SizedBox(height: 16),
                      // Driver info
                      _buildDriverCard(context, tracking),
                      const SizedBox(height: 16),
                      // Delivery timeline
                      _buildTimeline(tracking),
                      const SizedBox(height: 16),
                      // PIN verification
                      if (tracking.isDriverApproaching)
                        _buildPINCard(tracking),
                      const SizedBox(height: 16),
                      // Safety features
                      _buildSafetyCard(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(DeliveryTracking tracking) {
    final step = tracking.currentStep;
    final statusText = _stepText(step);
    final statusIcon = _stepIcon(step);
    final statusColor = _stepColor(step);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusIcon, size: 28, color: statusColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${tracking.distanceMiles.toStringAsFixed(1)} mi away • ${tracking.etaMinutes} min ETA',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(BuildContext context, DeliveryTracking tracking) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Driver avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: kMarketColorLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.person, size: 28, color: kMarketColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tracking.driverName,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: AppColors.accent),
                      const SizedBox(width: 3),
                      Text(
                        '${tracking.driverRating}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tracking.vehicleInfo,
                        style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Contact buttons
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kMarketColorLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.chat, size: 18, color: kMarketColor),
              ),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening chat...'), behavior: SnackBarBehavior.floating)),
            ),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kMarketColorLight,
                  borderRadius: BorderRadius.circular(10),
                ),
              child: const Icon(Icons.phone, size: 18, color: kMarketColor),
              ),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Calling driver...'), behavior: SnackBarBehavior.floating)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(DeliveryTracking tracking) {
    return MarketSectionCard(
      title: 'Delivery Timeline',
      children: tracking.timeline.map((event) {
          final isCompleted = event.isCompleted;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted ? kMarketColor : Colors.white,
                        border: Border.all(
                          color: isCompleted ? kMarketColor : AppColors.inputBorder,
                          width: 2,
                        ),
                      ),
                      child: isCompleted
                          ? const Icon(Icons.check, size: 12, color: Colors.white)
                          : null,
                    ),
                    if (tracking.timeline.last != event)
                      Container(
                        width: 2,
                        height: 28,
                        color: isCompleted ? kMarketColor : AppColors.inputBorder,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w400,
                          color: isCompleted ? AppColors.textPrimary : AppColors.textTertiary,
                        ),
                      ),
                      if (event.timestamp != null)
                        Text(
                          '${event.timestamp!.hour}:${event.timestamp!.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
    );
  }

  Widget _buildPINCard(DeliveryTracking tracking) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.pin, size: 32, color: Colors.white),
          const SizedBox(height: 8),
          const Text(
            'Delivery PIN',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            tracking.deliveryPin ?? '',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: 8,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share this PIN with the driver to confirm delivery',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyCard(BuildContext context) {
    return MarketSectionCard(
      title: 'Safety',
      children: [
          _SafetyOption(
            icon: Icons.share_location,
            title: 'Share live location',
            subtitle: 'Share your delivery status with someone',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location shared'), behavior: SnackBarBehavior.floating)),
          ),
          _SafetyOption(
            icon: Icons.report,
            title: 'Report an issue',
            subtitle: 'Problems with your delivery',
            onTap: () => Navigator.pushNamed(context, AppRoutes.utilityHelp),
          ),
          _SafetyOption(
            icon: Icons.support_agent,
            title: 'Contact support',
            subtitle: 'Get help from our team',
            onTap: () => Navigator.pushNamed(context, AppRoutes.utilityHelp),
          ),
        ],
    );
  }

  String _stepText(DeliveryStep step) {
    switch (step) {
      case DeliveryStep.confirmed:
        return 'Order Confirmed';
      case DeliveryStep.preparing:
        return 'Being Prepared';
      case DeliveryStep.onTheWay:
        return 'On the Way';
      case DeliveryStep.delivered:
        return 'Delivered';
    }
  }

  IconData _stepIcon(DeliveryStep step) {
    switch (step) {
      case DeliveryStep.confirmed:
        return Icons.check_circle;
      case DeliveryStep.preparing:
        return Icons.restaurant;
      case DeliveryStep.onTheWay:
        return Icons.delivery_dining;
      case DeliveryStep.delivered:
        return Icons.home;
    }
  }

  Color _stepColor(DeliveryStep step) {
    switch (step) {
      case DeliveryStep.confirmed:
        return AppColors.info;
      case DeliveryStep.preparing:
        return AppColors.warning;
      case DeliveryStep.onTheWay:
        return kMarketColor;
      case DeliveryStep.delivered:
        return kMarketColor;
    }
  }
}

class _SafetyOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SafetyOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: kMarketColor),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

// ─── Delivery Map Banner ──────────────────────────────────────────────────────

class _DeliveryMapBanner extends StatelessWidget {
  final String driverName;
  final double destinationLat;
  final double destinationLng;
  final double merchantLat;
  final double merchantLng;
  final int etaMinutes;

  const _DeliveryMapBanner({
    required this.driverName,
    required this.destinationLat,
    required this.destinationLng,
    required this.merchantLat,
    required this.merchantLng,
    required this.etaMinutes,
  });

  Future<void> _openDestinationInMaps() async {
    final geo = Uri.parse('geo:$destinationLat,$destinationLng');
    final web = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$destinationLat,$destinationLng',
    );
    if (await canLaunchUrl(geo)) {
      await launchUrl(geo, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(web, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: IveTokens.bg,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.local_shipping_rounded,
                    size: 28, color: IveTokens.accent),
                const SizedBox(height: 8),
                _AddressRow(
                  icon: Icons.trip_origin_rounded,
                  color: IveTokens.success,
                  label: 'Pickup',
                  address:
                      '${merchantLat.toStringAsFixed(5)}, ${merchantLng.toStringAsFixed(5)}',
                ),
                const SizedBox(height: 4),
                _AddressRow(
                  icon: Icons.location_on_rounded,
                  color: IveTokens.danger,
                  label: 'Delivery',
                  address:
                      '${destinationLat.toStringAsFixed(5)}, ${destinationLng.toStringAsFixed(5)}',
                ),
                const SizedBox(height: 4),
                _AddressRow(
                  icon: Icons.person_rounded,
                  color: IveTokens.accent,
                  label: 'Driver',
                  address: '$driverName · ETA $etaMinutes min',
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _openDestinationInMaps,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: IveTokens.accent.withValues(alpha: 0.12),
                      borderRadius: IveTokens.brSm,
                      border: Border.all(
                          color: IveTokens.accent.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.open_in_new_rounded,
                            size: 13, color: IveTokens.accent),
                        SizedBox(width: 5),
                        Text('Open in Maps',
                            style: TextStyle(
                                fontSize: 12,
                                color: IveTokens.accent,
                                fontWeight: FontWeight.w600)),
                      ],
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

class _AddressRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String address;

  const _AddressRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Text('$label  ', style: const TextStyle(fontSize: 11, color: IveTokens.labelTertiary)),
        Expanded(
          child: Text(
            address,
            style: const TextStyle(fontSize: 12, color: IveTokens.label, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = IveTokens.hairline.withValues(alpha: 0.4)
      ..strokeWidth = 0.5;
    const s = 28.0;
    for (double x = 0; x < size.width; x += s) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += s) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
