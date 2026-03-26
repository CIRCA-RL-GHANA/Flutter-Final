/// ═══════════════════════════════════════════════════════════════════════════
/// LIVE MODULE — Screen 17: Ride Execution & Security
/// Full ride flow: passenger pickup, identity verification,
/// live navigation, trip details, fare display, completion
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../models/live_models.dart';
import '../providers/live_provider.dart';
import '../widgets/live_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

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
          backgroundColor: AppColors.backgroundLight,
          appBar: LiveAppBar(
            title: _phase == 0 ? 'En Route to Pickup' : _phase == 1 ? 'Verify Passenger' : 'Trip in Progress',
            actions: [
              IconButton(
                icon: const Icon(Icons.sos, size: 20),
                color: kLiveColor,
                onPressed: () => Navigator.pushNamed(context, AppRoutes.liveEmergencySOS),
              ),
            ],
          ),
          body: Column(
            children: [
              // Phase indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Row(
                  children: [
                    _PhaseDot(label: 'En Route', index: 0, current: _phase),
                    Expanded(child: Container(height: 2, color: _phase > 0 ? const Color(0xFF10B981) : const Color(0xFFE5E7EB))),
                    _PhaseDot(label: 'Verify', index: 1, current: _phase),
                    Expanded(child: Container(height: 2, color: _phase > 1 ? const Color(0xFF10B981) : const Color(0xFFE5E7EB))),
                    _PhaseDot(label: 'Trip', index: 2, current: _phase),
                  ],
                ),
              ),

              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: Colors.green.shade50,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        Icon(Icons.security, size: 14, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI ride safety: ${ai.insights.first['title'] ?? ''}',
                            style: TextStyle(fontSize: 11, color: Colors.green.shade700),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))],
            ),
            child: _phase == 0
                ? SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        setState(() => _phase = 1);
                      },
                      icon: const Icon(Icons.location_on, size: 18),
                      label: const Text('ARRIVED AT PICKUP', style: TextStyle(fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    ),
                  )
                : _phase == 1
                    ? SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _identityVerified
                              ? () {
                                  HapticFeedback.heavyImpact();
                                  setState(() => _phase = 2);
                                }
                              : null,
                          icon: const Icon(Icons.play_arrow, size: 18),
                          label: const Text('START TRIP', style: TextStyle(fontWeight: FontWeight.w700)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _identityVerified ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pushNamed(context, AppRoutes.liveIncidentReport),
                              icon: const Icon(Icons.report_problem, size: 16),
                              label: const Text('REPORT', style: TextStyle(fontSize: 12)),
                              style: OutlinedButton.styleFrom(foregroundColor: kLiveColor, padding: const EdgeInsets.symmetric(vertical: 14)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                HapticFeedback.heavyImpact();
                                setState(() => _phase = 3);
                              },
                              icon: const Icon(Icons.flag, size: 18),
                              label: const Text('END TRIP', style: TextStyle(fontWeight: FontWeight.w700)),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
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
      padding: const EdgeInsets.all(16),
      children: [
        // Map placeholder
        Container(
          height: 180,
          decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(14)),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.navigation, size: 40, color: AppColors.textTertiary),
                const SizedBox(height: 8),
                Text('Navigating to pickup location', style: TextStyle(fontSize: 13, color: AppColors.textTertiary)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        LiveSectionCard(
          title: 'PASSENGER',
          icon: Icons.person,
          iconColor: const Color(0xFF3B82F6),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF3B82F6).withOpacity(0.1),
                child: Text(ride.passengerName.substring(0, 1), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF3B82F6))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ride.passengerName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 2),
                        Text('${ride.passengerRating}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(width: 8),
                        Text('${ride.passengerRideCount} passenger(s)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.phone, size: 18, color: Color(0xFF10B981)), style: IconButton.styleFrom(backgroundColor: const Color(0xFFD1FAE5))),
                  const SizedBox(width: 4),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.chat, size: 18, color: Color(0xFF3B82F6)), style: IconButton.styleFrom(backgroundColor: const Color(0xFFDBEAFE))),
                ],
              ),
            ],
          ),
        ),

        LiveSectionCard(
          title: 'TRIP DETAILS',
          icon: Icons.route,
          iconColor: kLiveColor,
          child: Column(
            children: [
              _TripDetailRow(icon: Icons.my_location, label: 'Pickup', value: ride.pickupAddress, color: const Color(0xFF10B981)),
              _TripDetailRow(icon: Icons.location_on, label: 'Destination', value: ride.dropoffAddress, color: kLiveColor),
              _TripDetailRow(icon: Icons.straighten, label: 'Distance', value: '${ride.distanceKm.toStringAsFixed(1)} km', color: AppColors.textSecondary),
              _TripDetailRow(icon: Icons.timer, label: 'Duration', value: '${ride.etaMinutes} min', color: AppColors.textSecondary),
              _TripDetailRow(icon: Icons.attach_money, label: 'Fare', value: '₵${ride.fare.toStringAsFixed(0)}', color: const Color(0xFFF59E0B)),
            ],
          ),
        ),

        if (ride.specialRequest != null && ride.specialRequest!.isNotEmpty)
          LiveSectionCard(
            title: 'SPECIAL REQUIREMENTS',
            icon: Icons.info,
            iconColor: const Color(0xFFF59E0B),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
                child: Text(ride.specialRequest!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF92400E))),
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
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: verified ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFF8B5CF6).withOpacity(0.1),
                ),
                child: Icon(
                  verified ? Icons.check_circle : Icons.person_pin,
                  size: 48,
                  color: verified ? const Color(0xFF10B981) : const Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                verified ? 'IDENTITY VERIFIED ✅' : 'VERIFY PASSENGER IDENTITY',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: verified ? const Color(0xFF10B981) : AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text('Confirm the passenger matches the booking', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
        ),

        const SizedBox(height: 24),

        LiveSectionCard(
          title: 'BOOKING DETAILS',
          icon: Icons.confirmation_number,
          iconColor: const Color(0xFF3B82F6),
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
            padding: const EdgeInsets.only(top: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  onVerify();
                },
                icon: const Icon(Icons.verified_user, size: 18),
                label: const Text('CONFIRM IDENTITY', style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
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
      padding: const EdgeInsets.all(16),
      children: [
        // Live map
        Container(
          height: 200,
          decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(14)),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.navigation, size: 40, color: AppColors.textTertiary),
                const SizedBox(height: 8),
                Text('Live trip navigation', style: TextStyle(fontSize: 13, color: AppColors.textTertiary)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Trip progress
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [const Color(0xFF10B981), const Color(0xFF059669)]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _TripStat(label: 'Distance', value: '${ride.distanceKm.toStringAsFixed(1)} km'),
              Container(width: 1, height: 30, color: Colors.white.withOpacity(0.3)),
              _TripStat(label: 'ETA', value: '${ride.etaMinutes} min'),
              Container(width: 1, height: 30, color: Colors.white.withOpacity(0.3)),
              _TripStat(label: 'Fare', value: '₵${ride.fare.toStringAsFixed(0)}'),
            ],
          ),
        ),

        const SizedBox(height: 12),

        LiveSectionCard(
          title: 'DESTINATION',
          icon: Icons.flag,
          iconColor: kLiveColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ride.dropoffAddress, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('Passenger: ${ride.passengerName}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),

        // Safety tools
        LiveSectionCard(
          title: 'SAFETY TOOLS',
          icon: Icons.shield,
          iconColor: kLiveColor,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share_location, size: 16),
                  label: const Text('Share Trip', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF3B82F6)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.mic, size: 16),
                  label: const Text('Record', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF8B5CF6)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.liveEmergencySOS),
                  icon: const Icon(Icons.sos, size: 16),
                  label: const Text('SOS', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(foregroundColor: kLiveColor),
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
      backgroundColor: AppColors.backgroundLight,
      appBar: const LiveAppBar(title: 'Trip Complete'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF10B981).withOpacity(0.1)),
                child: const Icon(Icons.celebration, size: 64, color: Color(0xFF10B981)),
              ),
              const SizedBox(height: 20),
              const Text('🎉 TRIP COMPLETED!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(ride.passengerName, style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
                child: Column(
                  children: [
                    const Text('EARNINGS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
                    const SizedBox(height: 4),
                    Text('₵${ride.fare.toStringAsFixed(0)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF10B981))),
                    const SizedBox(height: 8),
                    _CompletionRow(label: 'Distance', value: '${ride.distanceKm.toStringAsFixed(1)} km'),
                    _CompletionRow(label: 'Duration', value: '${ride.etaMinutes} min'),
                    _CompletionRow(label: 'Payment', value: ride.paymentMethod),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onDone,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: const Text('BACK TO HOME', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
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
          decoration: BoxDecoration(shape: BoxShape.circle, color: completed ? const Color(0xFF10B981) : active ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB)),
          child: Center(child: completed ? const Icon(Icons.check, size: 16, color: Colors.white) : active ? const Icon(Icons.circle, size: 8, color: Colors.white) : null),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: active || completed ? AppColors.textPrimary : AppColors.textTertiary)),
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
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
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
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.7))),
      ],
    );
  }
}

class _CompletionRow extends StatelessWidget {
  final String label;
  final String value;
  const _CompletionRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
