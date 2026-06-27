/// 
/// LIVE MODULE  Screen 17: Ride Execution & Security
/// Full ride flow: passenger pickup, identity verification,
/// live navigation, trip details, fare display, completion
/// 
library;

import 'package:flutter/material.dart';
import '../../../core/utils/app_toast.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/design/ive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../models/live_models.dart';
import '../providers/live_provider.dart';
import '../widgets/live_widgets.dart';

class LiveRideExecutionScreen extends StatefulWidget {
  const LiveRideExecutionScreen({super.key});

  @override
  State<LiveRideExecutionScreen> createState() => _LiveRideExecutionScreenState();
}

class _LiveRideExecutionScreenState extends State<LiveRideExecutionScreen> {
  int _phase = 0; // 0=EnRoute, 1=PickedUp, 2=InTrip, 3=Complete
  bool _identityVerified = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveProvider>(
      builder: (context, prov, _) {
        final ride = prov.activeRide ?? prov.rides.first;

        if (_phase == 3) {
          return _RideCompleteView(ride: ride, onDone: () => Navigator.pop(context));
        }

        return Scaffold(
          backgroundColor: IveTokens.bg,
          appBar: LiveAppBar(
            title: _phase == 0 ? 'En Route to Pickup' : _phase == 1 ? 'Verify Passenger' : 'Trip in Progress',
            actions: [
              IconButton(
                icon: const Icon(Icons.sos, size: 20),
                color: IveTokens.moduleLive,
                onPressed: () => Navigator.pushNamed(context, AppRoutes.liveEmergencySOS),
              ),
            ],
          ),
          body: Column(
            children: [
              // Phase indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: IveTokens.s4, vertical: IveTokens.s2),
                color: IveTokens.surface,
                child: Row(
                  children: [
                    _PhaseDot(label: 'En Route', index: 0, current: _phase),
                    Expanded(child: Container(height: 2, color: _phase > 0 ? IveTokens.success : IveTokens.hairline)),
                    _PhaseDot(label: 'Verify', index: 1, current: _phase),
                    Expanded(child: Container(height: 2, color: _phase > 1 ? IveTokens.success : IveTokens.hairline)),
                    _PhaseDot(label: 'Trip', index: 2, current: _phase),
                  ],
                ),
              ),


              Expanded(
                child: IndexedStack(
                  index: _phase,
                  children: [
                    // Phase 0: En Route
                    _EnRouteView(ride: ride),
                    // Phase 1: Verify
                    _VerifyView(
                      ride: ride,
                      verified: _identityVerified,
                      onVerify: () => setState(() => _identityVerified = true),
                    ),
                    // Phase 2: In Trip
                    _InTripView(ride: ride),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(IveTokens.s4, IveTokens.s2, IveTokens.s4, IveTokens.s6),
            decoration: const BoxDecoration(color: IveTokens.surface),
            child: _phase == 0
                ? IveButton.primary(
                    label: 'ARRIVED AT PICKUP',
                    icon: Icons.location_on,
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      setState(() => _phase = 1);
                    },
                  )
                : _phase == 1
                    ? IveButton.primary(
                        label: 'START TRIP',
                        icon: Icons.play_arrow,
                        onPressed: _identityVerified
                            ? () {
                                HapticFeedback.heavyImpact();
                                setState(() => _phase = 2);
                              }
                            : null,
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: IveButton.secondary(
                              label: 'REPORT',
                              icon: Icons.report_problem,
                              onPressed: () => Navigator.pushNamed(context, AppRoutes.liveIncidentReport),
                            ),
                          ),
                          const SizedBox(width: IveTokens.s3),
                          Expanded(
                            flex: 2,
                            child: IveButton.primary(
                              label: 'END TRIP',
                              icon: Icons.flag,
                              onPressed: () {
                                HapticFeedback.heavyImpact();
                                setState(() => _phase = 3);
                              },
                            ),
                          ),
                        ],
                      ),
          ),
        );
      },
    );
  }
}

class _EnRouteView extends StatelessWidget {
  final LiveRide ride;
  const _EnRouteView({required this.ride});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(IveTokens.s4),
      children: [
        // Route card  shows live location context and opens the native maps app.
        _RouteMapCard(
          label: 'Navigating to pickup',
          address: ride.pickupAddress,
          destinationAddress: ride.dropoffAddress,
        ),

        const SizedBox(height: IveTokens.s3),

        LiveSectionCard(
          title: 'PASSENGER',
          icon: Icons.person,
          iconColor: IveTokens.accent,
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: IveTokens.accentSoft,
                child: Text(ride.passengerName.substring(0, 1), style: const TextStyle(fontWeight: FontWeight.w700, color: IveTokens.accent)),
              ),
              const SizedBox(width: IveTokens.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ride.passengerName, style: IveType.callout.copyWith(fontWeight: FontWeight.w700, color: IveTokens.ink)),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: IveTokens.warning),
                        const SizedBox(width: 2),
                        Text('${ride.passengerRating}', style: IveType.footnote),
                        const SizedBox(width: IveTokens.s2),
                        Text('${ride.passengerRideCount} passenger(s)', style: IveType.footnote),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(onPressed: () => AppToast.show(context, 'Calling...'), icon: const Icon(Icons.phone, size: 18, color: IveTokens.success), style: IconButton.styleFrom(backgroundColor: IveTokens.surfaceRaised)),
                  const SizedBox(width: IveTokens.s1),
                  IconButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.qualChatDashboard), icon: const Icon(Icons.chat, size: 18, color: IveTokens.accent), style: IconButton.styleFrom(backgroundColor: IveTokens.surfaceRaised)),
                ],
              ),
            ],
          ),
        ),

        LiveSectionCard(
          title: 'TRIP DETAILS',
          icon: Icons.route,
          iconColor: IveTokens.moduleLive,
          child: Column(
            children: [
              _TripDetailRow(icon: Icons.my_location, label: 'Pickup', value: ride.pickupAddress, color: IveTokens.success),
              _TripDetailRow(icon: Icons.location_on, label: 'Destination', value: ride.dropoffAddress, color: IveTokens.moduleLive),
              _TripDetailRow(icon: Icons.straighten, label: 'Distance', value: '${ride.distanceKm.toStringAsFixed(1)} km', color: IveTokens.mute),
              _TripDetailRow(icon: Icons.timer, label: 'Duration', value: '${ride.etaMinutes} min', color: IveTokens.mute),
              _TripDetailRow(icon: Icons.attach_money, label: 'Fare', value: '${ride.fare.toStringAsFixed(0)}', color: IveTokens.warning),
            ],
          ),
        ),

        if (ride.specialRequest != null && ride.specialRequest!.isNotEmpty)
          LiveSectionCard(
            title: 'SPECIAL REQUIREMENTS',
            icon: Icons.info,
            iconColor: IveTokens.warning,
            child: Wrap(
              spacing: IveTokens.s1 + 2,
              runSpacing: IveTokens.s1 + 2,
              children: [Container(
                padding: const EdgeInsets.symmetric(horizontal: IveTokens.s2 + 2, vertical: IveTokens.s1 + 2),
                decoration: const BoxDecoration(color: IveTokens.surfaceRaised, borderRadius: BorderRadius.all(Radius.circular(IveTokens.rXs))),
                child: Text(ride.specialRequest!, style: IveType.footnote.copyWith(fontWeight: FontWeight.w600, color: IveTokens.warning)),
              )],
            ),
          ),
      ],
    );
  }
}

class _VerifyView extends StatelessWidget {
  final LiveRide ride;
  final bool verified;
  final VoidCallback onVerify;
  const _VerifyView({required this.ride, required this.verified, required this.onVerify});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(IveTokens.s4),
      children: [
        const SizedBox(height: IveTokens.s5),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(IveTokens.s4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: verified ? IveTokens.success.withValues(alpha: 0.1) : IveTokens.accent.withValues(alpha: 0.1),
                ),
                child: Icon(
                  verified ? Icons.check_circle : Icons.person_pin,
                  size: 48,
                  color: verified ? IveTokens.success : IveTokens.accent,
                ),
              ),
              const SizedBox(height: IveTokens.s4),
              Text(
                verified ? 'IDENTITY VERIFIED' : 'VERIFY PASSENGER IDENTITY',
                style: IveType.headline.copyWith(fontWeight: FontWeight.w800, color: verified ? IveTokens.success : IveTokens.ink),
              ),
              const SizedBox(height: IveTokens.s1),
              Text('Confirm the passenger matches the booking', style: IveType.subhead),
            ],
          ),
        ),

        const SizedBox(height: IveTokens.s6),

        LiveSectionCard(
          title: 'BOOKING DETAILS',
          icon: Icons.confirmation_number,
          iconColor: IveTokens.accent,
          child: Column(
            children: [
              _VerifyRow(label: 'Name', value: ride.passengerName),
              _VerifyRow(label: 'Passengers', value: '${ride.passengerRideCount}'),
              _VerifyRow(label: 'Booking ID', value: ride.id),
              _VerifyRow(label: 'Payment', value: ride.paymentMethod),
            ],
          ),
        ),

        if (!verified)
          Padding(
            padding: const EdgeInsets.only(top: IveTokens.s3),
            child: IveButton.primary(
              label: 'CONFIRM IDENTITY',
              icon: Icons.verified_user,
              onPressed: () {
                HapticFeedback.heavyImpact();
                onVerify();
              },
            ),
          ),
      ],
    );
  }
}

class _InTripView extends StatelessWidget {
  final LiveRide ride;
  const _InTripView({required this.ride});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(IveTokens.s4),
      children: [
        // Live map
        Container(
          height: 200,
          decoration: const BoxDecoration(color: IveTokens.surfaceRaised, borderRadius: BorderRadius.all(Radius.circular(IveTokens.rSm))),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.navigation, size: 40, color: IveTokens.mute),
                SizedBox(height: IveTokens.s2),
                Text('Live trip navigation', style: TextStyle(fontSize: 13, color: IveTokens.mute)),
              ],
            ),
          ),
        ),

        const SizedBox(height: IveTokens.s3),

        // Trip progress
        Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: IveTokens.moduleLive,
            borderRadius: BorderRadius.all(Radius.circular(IveTokens.rSm)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _TripStat(label: 'Distance', value: '${ride.distanceKm.toStringAsFixed(1)} km'),
              Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.3)),
              _TripStat(label: 'ETA', value: '${ride.etaMinutes} min'),
              Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.3)),
              _TripStat(label: 'Fare', value: '${ride.fare.toStringAsFixed(0)}'),
            ],
          ),
        ),

        const SizedBox(height: IveTokens.s3),

        LiveSectionCard(
          title: 'DESTINATION',
          icon: Icons.flag,
          iconColor: IveTokens.moduleLive,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ride.dropoffAddress, style: IveType.callout.copyWith(fontWeight: FontWeight.w600, color: IveTokens.ink)),
              const SizedBox(height: IveTokens.s1),
              Text('Passenger: ${ride.passengerName}', style: IveType.footnote),
            ],
          ),
        ),

        // Safety tools
        LiveSectionCard(
          title: 'SAFETY TOOLS',
          icon: Icons.shield,
          iconColor: IveTokens.moduleLive,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => AppToast.show(context, 'Trip link copied'),
                  icon: const Icon(Icons.share_location, size: 16),
                  label: const Text('Share Trip', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(foregroundColor: IveTokens.accent),
                ),
              ),
              const SizedBox(width: IveTokens.s2),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => AppToast.show(context, 'Recording...'),
                  icon: const Icon(Icons.mic, size: 16),
                  label: const Text('Record', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(foregroundColor: IveTokens.accent),
                ),
              ),
              const SizedBox(width: IveTokens.s2),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.liveEmergencySOS),
                  icon: const Icon(Icons.sos, size: 16),
                  label: const Text('SOS', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(foregroundColor: IveTokens.moduleLive),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RideCompleteView extends StatelessWidget {
  final LiveRide ride;
  final VoidCallback onDone;
  const _RideCompleteView({required this.ride, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IveTokens.bg,
      appBar: const LiveAppBar(title: 'Trip Complete'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(IveTokens.s6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(IveTokens.s6),
                decoration: BoxDecoration(shape: BoxShape.circle, color: IveTokens.success.withValues(alpha: 0.1)),
                child: const Icon(Icons.celebration, size: 64, color: IveTokens.success),
              ),
              const SizedBox(height: IveTokens.s5),
              Text('TRIP COMPLETED!', style: IveType.title2.copyWith(fontWeight: FontWeight.w900, color: IveTokens.ink)),
              const SizedBox(height: IveTokens.s2),
              Text(ride.passengerName, style: IveType.subhead),
              const SizedBox(height: IveTokens.s4),
              Container(
                padding: const EdgeInsets.all(IveTokens.s4),
                decoration: const BoxDecoration(color: IveTokens.surface, borderRadius: BorderRadius.all(Radius.circular(IveTokens.rSm))),
              ),
              const SizedBox(height: IveTokens.s6),
              IveButton.primary(label: 'BACK TO HOME', onPressed: onDone),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhaseDot extends StatelessWidget {
  final String label;
  final int index;
  final int current;
  const _PhaseDot({required this.label, required this.index, required this.current});

  @override
  Widget build(BuildContext context) {
    final completed = current > index;
    final active = current == index;
    return Column(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(shape: BoxShape.circle, color: completed ? IveTokens.success : active ? IveTokens.accent : IveTokens.hairline),
          child: Center(child: completed ? const Icon(Icons.check, size: 16, color: IveTokens.ink) : active ? const Icon(Icons.circle, size: 8, color: IveTokens.ink) : null),
        ),
        const SizedBox(height: IveTokens.s1),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: active || completed ? IveTokens.ink : IveTokens.mute)),
      ],
    );
  }
}

class _TripDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _TripDetailRow({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: IveTokens.s1 + 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: IveTokens.s2),
          Text('$label: ', style: IveType.subhead),
          Expanded(child: Text(value, style: IveType.subhead.copyWith(fontWeight: FontWeight.w600, color: IveTokens.ink))),
        ],
      ),
    );
  }
}

class _VerifyRow extends StatelessWidget {
  final String label;
  final String value;
  const _VerifyRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: IveTokens.s1 + 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: IveType.subhead),
          Text(value, style: IveType.subhead.copyWith(fontWeight: FontWeight.w600, color: IveTokens.ink)),
        ],
      ),
    );
  }
}

class _TripStat extends StatelessWidget {
  final String label;
  final String value;
  const _TripStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: IveType.headline.copyWith(fontWeight: FontWeight.w800, color: IveTokens.ink)),
        Text(label, style: IveType.caption.copyWith(color: IveTokens.ink.withValues(alpha: 0.7))),
      ],
    );
  }
}

//  Route Map Card 
/// Shows pickup  drop-off route with an "Open in Maps" deep-link.
/// Replaces a native map tile when google_maps_flutter is not in use.
class _RouteMapCard extends StatelessWidget {
  final String label;
  final String? address;
  final String? destinationAddress;

  const _RouteMapCard({
    required this.label,
    this.address,
    this.destinationAddress,
  });

  Future<void> _openMaps() async {
    final query = Uri.encodeComponent(
      destinationAddress ?? address ?? label,
    );
    final uri = Uri.parse('geo:0,0?q=$query');
    // Fallback to Google Maps web URL for environments that don't handle geo: URIs.
    final fallback = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(fallback, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: IveTokens.surface,
        borderRadius: BorderRadius.circular(10),
        border: IveTokens.cardBorder,
      ),
      child: Stack(
        children: [
          // Subtle grid pattern to suggest a map surface.
          Positioned.fill(
            child: CustomPaint(painter: _MapGridPainter()),
          ),
          // Route info overlay.
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.navigation_rounded,
                        size: 18, color: IveTokens.accent),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: IveTokens.label,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (address != null)
                  _RouteStop(
                    icon: Icons.trip_origin_rounded,
                    color: IveTokens.success,
                    text: address!,
                  ),
                if (address != null && destinationAddress != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(width: 2, height: 20, color: IveTokens.hairline),
                  ),
                if (destinationAddress != null)
                  _RouteStop(
                    icon: Icons.location_on_rounded,
                    color: IveTokens.danger,
                    text: destinationAddress!,
                  ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton.icon(
                    onPressed: _openMaps,
                    icon: const Icon(Icons.open_in_new_rounded,
                        size: 14, color: IveTokens.accent),
                    label: const Text(
                      'Open in Maps',
                      style: TextStyle(fontSize: 12, color: IveTokens.accent),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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

class _RouteStop extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _RouteStop({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: IveTokens.labelSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = IveTokens.hairline.withValues(alpha: 0.5)
      ..strokeWidth = 0.5;
    const spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
