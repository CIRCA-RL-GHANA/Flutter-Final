/// 
/// MARKET MODULE  Screen 10: Delivery Tracker & PIN Verification
/// Live map, delivery timeline, driver info, PIN handoff, safety features
/// 
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/design/ive.dart';
import '../../../core/routes/app_routes.dart';
import '../models/market_models.dart';
import '../providers/market_provider.dart';
import '../widgets/market_widgets.dart';

class MarketDeliveryTrackerScreen extends StatefulWidget {
  const MarketDeliveryTrackerScreen({super.key});

  @override
  State<MarketDeliveryTrackerScreen> createState() => _MarketDeliveryTrackerScreenState();
}

class _MarketDeliveryTrackerScreenState extends State<MarketDeliveryTrackerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pinDropCtrl;
  late final Animation<double> _pinScale;
  late final Animation<Offset> _pinSlide;
  bool _pinShown = false;

  @override
  void initState() {
    super.initState();
    _pinDropCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    // Elastic out  drop from above and settle with 1 bounce
    _pinScale = CurvedAnimation(parent: _pinDropCtrl, curve: Curves.elasticOut);
    _pinSlide = Tween<Offset>(
      begin: const Offset(0, -0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _pinDropCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pinDropCtrl.dispose();
    super.dispose();
  }

  void _triggerPinDrop() {
    if (!_pinShown) {
      _pinShown = true;
      _pinDropCtrl.forward();
    }
  }

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

        if (tracking.isDriverApproaching) _triggerPinDrop();

        return Scaffold(
          backgroundColor: IveTokens.voidColor,
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
                    child: const Icon(Icons.arrow_back, size: 20, color: IveTokens.voidColor),
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
                      child: const Icon(Icons.phone, size: 20, color: IveTokens.voidColor),
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
                            color: IveTokens.raisedColor,
                            borderRadius: BorderRadius.circular(IveTokens.rContainer),
                            border: Border.all(color: IveTokens.hairColor, width: 1),
                          ),
                          child: Column(
                            children: [
                              // ETA in mono (spec P1)
                              Text(
                                '${tracking.etaMinutes} min',
                                style: GoogleFonts.ibmPlexMono(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: IveTokens.inkColor,
                                  fontFeatures: [const FontFeature.tabularFigures()],
                                ),
                              ),
                              Text('ETA', style: IveType.caption.copyWith(color: IveTokens.muteColor)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
                      // PIN verification  drops in with elastic-out bounce
                      if (tracking.isDriverApproaching)
                        SlideTransition(
                          position: _pinSlide,
                          child: ScaleTransition(
                            scale: _pinScale,
                            child: _buildPINCard(tracking),
                          ),
                        ),
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
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
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
                  '${tracking.distanceMiles.toStringAsFixed(1)} mi away  ${tracking.etaMinutes} min ETA',
                  style: const TextStyle(fontSize: 13, color: IveTokens.ink2Color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(BuildContext context, DeliveryTracking tracking) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: IveTokens.raisedColor,
        borderRadius: BorderRadius.circular(IveTokens.rContainer),
        border: Border.all(color: IveTokens.hairColor, width: 1),
      ),
      child: Row(
        children: [
          // Driver avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: kMarketColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(IveTokens.rContainer),
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
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: IveTokens.inkColor),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: IveTokens.warnColor),
                    const SizedBox(width: 3),
                    Text(
                      '${tracking.driverRating}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: IveTokens.inkColor),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tracking.vehicleInfo,
                      style: const TextStyle(fontSize: 12, color: IveTokens.muteColor),
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
                  color: kMarketColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(IveTokens.rAtom),
                ),
                child: const Icon(Icons.chat, size: 18, color: kMarketColor),
              ),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening chat...'), behavior: SnackBarBehavior.floating)),
            ),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kMarketColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(IveTokens.rAtom),
                ),
                child: const Icon(Icons.phone, size: 18, color: kMarketColor),
              ),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Calling driver...'), behavior: SnackBarBehavior.floating)),
            ),
          ],
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
                        color: isCompleted ? kMarketColor : IveTokens.raisedColor,
                        border: Border.all(
                          color: isCompleted ? kMarketColor : IveTokens.hairColor,
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
                        color: isCompleted ? kMarketColor : IveTokens.hairColor,
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
                          color: isCompleted ? IveTokens.inkColor : IveTokens.muteColor,
                        ),
                      ),
                      if (event.timestamp != null)
                        Text(
                          '${event.timestamp!.hour}:${event.timestamp!.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 11, color: IveTokens.muteColor),
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
    // PIN in large mono with dark themed card + gold border (spec P1)
    return Container(
      padding: const EdgeInsets.all(IveTokens.s5),
      decoration: BoxDecoration(
        color: IveTokens.raisedColor,
        borderRadius: BorderRadius.circular(IveTokens.rContainer),
        border: Border.all(color: IveTokens.accentColor.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.pin_rounded, size: 16, color: IveTokens.accentColor),
            const SizedBox(width: 6),
            Text('Delivery PIN', style: IveType.caption.copyWith(color: IveTokens.muteColor)),
          ]),
          const SizedBox(height: IveTokens.s3),
          Text(
            tracking.deliveryPin ?? '',
            style: GoogleFonts.ibmPlexMono(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              letterSpacing: 12,
              color: IveTokens.inkColor,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: IveTokens.s2),
          Text(
            'Share with the driver to confirm delivery.',
            textAlign: TextAlign.center,
            style: IveType.caption.copyWith(color: IveTokens.muteColor),
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
        return IveTokens.infoColor;
      case DeliveryStep.preparing:
        return IveTokens.warnColor;
      case DeliveryStep.onTheWay:
        return kMarketColor;
      case DeliveryStep.delivered:
        return IveTokens.okColor;
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
      trailing: const Icon(Icons.chevron_right, color: IveTokens.muteColor),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

//  Delivery Map Banner 

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
                  address: '$driverName  ETA $etaMinutes min',
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
