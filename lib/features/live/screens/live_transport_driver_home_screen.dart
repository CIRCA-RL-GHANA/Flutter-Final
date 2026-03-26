/// ═══════════════════════════════════════════════════════════════════════════
/// LIVE MODULE — Screen 16: Driver Home (Transport)
/// Transport driver dashboard: active ride, earnings, availability,
/// ride queue, vehicle info, and quick actions
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

class LiveTransportDriverHomeScreen extends StatelessWidget {
  const LiveTransportDriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveProvider>(
      builder: (context, prov, _) {
        // Transport driver (Alex Brown)
        final driver = prov.drivers.firstWhere((d) => d.driverType == LiveDriverType.transport, orElse: () => prov.drivers.first);
        final activeRide = prov.rides.where((r) => r.status == LiveRideStatus.inProgress).firstOrNull;
        final pendingRides = prov.rides.where((r) => r.status == LiveRideStatus.available).toList();
        final earnings = prov.transportEarnings;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 12, 16, 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF1E3A5F), Color(0xFF3B82F6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Text(driver.name.substring(0, 1), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Hey, ${driver.name.split(' ').first}! 🚗', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                                Text('Transport Driver', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))),
                              ],
                            ),
                          ),
                          // Online status
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.3), borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF10B981))),
                                const SizedBox(width: 4),
                                Text('ONLINE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.9))),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Earnings card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _EarningsStat(label: 'Today', value: '₵${earnings.totalEarnings.toStringAsFixed(0)}'),
                            Container(width: 1, height: 30, color: Colors.white.withOpacity(0.3)),
                            _EarningsStat(label: 'This Week', value: '₵0'),
                            Container(width: 1, height: 30, color: Colors.white.withOpacity(0.3)),
                            _EarningsStat(label: 'Rides', value: '${earnings.ridesCompleted}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Consumer<AIInsightsNotifier>(
                  builder: (context, ai, _) {
                    if (ai.insights.isEmpty) return const SizedBox.shrink();
                    return Container(
                      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
              ),

              // Active ride
              if (activeRide != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🚗 ACTIVE RIDE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        _ActiveRideCard(
                          ride: activeRide,
                          onTap: () {
                            prov.selectRide(activeRide.id);
                            Navigator.pushNamed(context, AppRoutes.liveRideExecution);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

              // Quick Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('⚡ QUICK ACTIONS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _QuickAction(icon: Icons.navigation, label: 'Navigate', color: const Color(0xFF3B82F6), onTap: () {})),
                          const SizedBox(width: 8),
                          Expanded(child: _QuickAction(icon: Icons.sos, label: 'Emergency', color: kLiveColor, onTap: () => Navigator.pushNamed(context, AppRoutes.liveEmergencySOS))),
                          const SizedBox(width: 8),
                          Expanded(child: _QuickAction(icon: Icons.report_problem, label: 'Report', color: const Color(0xFFF59E0B), onTap: () => Navigator.pushNamed(context, AppRoutes.liveIncidentReport))),
                          const SizedBox(width: 8),
                          Expanded(child: _QuickAction(icon: Icons.settings, label: 'Settings', color: AppColors.textSecondary, onTap: () => Navigator.pushNamed(context, AppRoutes.liveSettings))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Ride Queue
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text('📋 RIDE QUEUE (${pendingRides.length})', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ),
              ),

              if (pendingRides.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: LiveEmptyState(
                      icon: Icons.directions_car,
                      title: 'No rides in queue',
                      subtitle: 'Stay online — new ride requests will appear here.',
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, i == pendingRides.length - 1 ? 24 : 0),
                      child: _RideRequestCard(
                        ride: pendingRides[i],
                        onAccept: () {
                          HapticFeedback.heavyImpact();
                          prov.selectRide(pendingRides[i].id);
                          Navigator.pushNamed(context, AppRoutes.liveRideExecution);
                        },
                      ),
                    ),
                    childCount: pendingRides.length,
                  ),
                ),

              // Vehicle Info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: LiveSectionCard(
                    title: 'VEHICLE INFO',
                    icon: Icons.directions_car,
                    iconColor: const Color(0xFF3B82F6),
                    child: Column(
                      children: [
                        _InfoRow(label: 'Vehicle', value: 'Not set'),
                        _InfoRow(label: 'License', value: 'Not set'),
                        _InfoRow(label: 'Rating', value: '${driver.rating} ⭐'),
                        _InfoRow(label: 'Total rides', value: '${driver.totalDeliveries}'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EarningsStat extends StatelessWidget {
  final String label;
  final String value;
  const _EarningsStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.7))),
      ],
    );
  }
}

class _ActiveRideCard extends StatelessWidget {
  final LiveRide ride;
  final VoidCallback onTap;
  const _ActiveRideCard({required this.ride, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [kLiveColor, kLiveAccent]),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.directions_car, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Ride #${ride.id}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                  child: Text(ride.status.name.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${ride.passengerName} • ${ride.passengerRideCount} passenger(s)', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9))),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.white.withOpacity(0.7)),
                const SizedBox(width: 4),
                Expanded(child: Text('${ride.pickupAddress} → ${ride.dropoffAddress}', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)), overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('₵${ride.fare.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                const Spacer(),
                const Text('TAP TO CONTINUE →', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RideRequestCard extends StatelessWidget {
  final LiveRide ride;
  final VoidCallback onAccept;
  const _RideRequestCard({required this.ride, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(ride.passengerName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('₵${ride.fare.toStringAsFixed(0)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: kLiveColor)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.my_location, size: 14, color: const Color(0xFF10B981)),
              const SizedBox(width: 4),
              Expanded(child: Text(ride.pickupAddress, style: TextStyle(fontSize: 12, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.location_on, size: 14, color: kLiveColor),
              const SizedBox(width: 4),
              Expanded(child: Text(ride.dropoffAddress, style: TextStyle(fontSize: 12, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('${ride.distanceKm.toStringAsFixed(1)} km • ${ride.etaMinutes} min', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              const Spacer(),
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: const Text('ACCEPT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))]),
        child: Column(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

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
