/// ═══════════════════════════════════════════════════════════════════════════
/// MARKET MODULE — Screen 11: Ride Hailing & Execution
/// 6 Parts: Request → Matching → Active → In-Ride → Arrival → Post-Ride
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../models/market_models.dart';
import '../providers/market_provider.dart';
import '../widgets/market_widgets.dart';

class MarketRideHailingScreen extends StatefulWidget {
  const MarketRideHailingScreen({super.key});

  @override
  State<MarketRideHailingScreen> createState() => _MarketRideHailingScreenState();
}

class _MarketRideHailingScreenState extends State<MarketRideHailingScreen> {
  int _phase = 0; // 0=request, 1=matching, 2=driver assigned, 3=in-ride, 4=arrival, 5=post-ride
  final _pickupController = TextEditingController(text: 'Current Location');
  final _dropoffController = TextEditingController();
  int _passengers = 1;

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketProvider>(
      builder: (context, prov, _) {
        final activeRide = prov.activeRide;
        if (activeRide != null && _phase == 0) {
          _phase = _rideStatusToPhase(activeRide.status);
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: _phase == 0
              ? const MarketAppBar(title: 'Hail a Ride')
              : null,
          body: _phase == 0
              ? _buildRequestPhase(context, prov)
              : _phase == 1
                  ? _buildMatchingPhase(context, prov)
                  : _phase == 2
                      ? _buildDriverAssignedPhase(context, prov, activeRide!)
                      : _phase == 3
                          ? _buildInRidePhase(context, prov, activeRide!)
                          : _phase == 4
                              ? _buildArrivalPhase(context, prov, activeRide!)
                              : _buildPostRidePhase(context, prov),
        );
      },
    );
  }

  int _rideStatusToPhase(RideStatus status) {
    switch (status) {
      case RideStatus.searching:
        return 1;
      case RideStatus.driverAssigned:
        return 2;
      case RideStatus.driverEnRoute:
        return 2;
      case RideStatus.arrived:
        return 4;
      case RideStatus.inProgress:
        return 3;
      case RideStatus.completed:
        return 5;
      case RideStatus.cancelled:
        return 0;
    }
  }

  // ── Phase 0: Request ───────────────────────────────────────────
  Widget _buildRequestPhase(BuildContext context, MarketProvider prov) {
    return Column(
      children: [
        Consumer<AIInsightsNotifier>(
          builder: (context, ai, _) {
            if (ai.insights.isEmpty) return const SizedBox.shrink();
            return Container(
              color: kMarketColor.withOpacity(0.07),
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
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Map
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map, size: 48, color: AppColors.textTertiary),
                      SizedBox(height: 8),
                      Text('Select pickup & dropoff', style: TextStyle(color: AppColors.textTertiary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Route card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(color: kMarketColor, shape: BoxShape.circle),
                              ),
                              Container(width: 2, height: 30, color: AppColors.inputBorder),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              children: [
                                TextField(
                                  controller: _pickupController,
                                  decoration: InputDecoration(
                                    hintText: 'Pickup location',
                                    hintStyle: TextStyle(fontSize: 13, color: AppColors.textTertiary),
                                    prefixIcon: const Icon(Icons.my_location, size: 18, color: kMarketColor),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: kMarketColor, width: 2),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    isDense: true,
                                  ),
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _dropoffController,
                                  decoration: InputDecoration(
                                    hintText: 'Where to?',
                                    hintStyle: TextStyle(fontSize: 13, color: AppColors.textTertiary),
                                    prefixIcon: const Icon(Icons.location_on, size: 18, color: AppColors.error),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: kMarketColor, width: 2),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    isDense: true,
                                  ),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Ride type selector
              const Text('Ride Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ...RideType.values.map((type) {
                final isSelected = prov.selectedRideType == type;
                return GestureDetector(
                  onTap: () => prov.setRideType(type),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? kMarketColor : AppColors.inputBorder,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _rideTypeIcon(type),
                          size: 28,
                          color: isSelected ? kMarketColor : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _rideTypeLabel(type),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: isSelected ? kMarketColorDark : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                _rideTypeDesc(type),
                                style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _rideTypePrice(type),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? kMarketColor : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              // Passengers
              Row(
                children: [
                  const Text('Passengers', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  QuantitySelector(
                    quantity: _passengers,
                    min: 1,
                    max: 6,
                    onChanged: (v) => setState(() => _passengers = v),
                  ),
                ],
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
        // Request button
        Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).padding.bottom + 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _dropoffController.text.isNotEmpty
                  ? () {
                      prov.requestRide(
                        pickup: _pickupController.text,
                        destination: _dropoffController.text,
                      );
                      setState(() => _phase = 1);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: kMarketColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: kMarketColor.withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: const Text(
                'Request Ride',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Phase 1: Matching ──────────────────────────────────────────
  Widget _buildMatchingPhase(BuildContext context, MarketProvider prov) {
    return Scaffold(
      appBar: const MarketAppBar(title: 'Finding a Driver'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated search indicator
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: kMarketColorLight,
                shape: BoxShape.circle,
                border: Border.all(color: kMarketColor, width: 3),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 40, color: kMarketColor),
                  SizedBox(height: 4),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: kMarketColor, strokeWidth: 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Finding nearby drivers...',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'This usually takes less than a minute',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () {
                prov.cancelRide();
                setState(() => _phase = 0);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Cancel'),
            ),
            const SizedBox(height: 16),
            // Simulated driver found
            ElevatedButton(
              onPressed: () => setState(() => _phase = 2),
              style: ElevatedButton.styleFrom(
                backgroundColor: kMarketColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Simulate: Driver Found'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Phase 2: Driver Assigned ───────────────────────────────────
  Widget _buildDriverAssignedPhase(BuildContext context, MarketProvider prov, RideRequest ride) {
    return Scaffold(
      body: Column(
        children: [
          // Map
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  color: const Color(0xFFE8F0FE),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_car, size: 48, color: kMarketColor),
                        SizedBox(height: 8),
                        Text('Driver en route to you', style: TextStyle(color: AppColors.textTertiary)),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                            ),
                            child: const Icon(Icons.arrow_back, size: 20),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                          ),
                          child: Text(
                            'Arriving in ${ride.estimatedMinutes} min',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: kMarketColorDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Driver card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.inputBorder, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
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
                            ride.driverName ?? 'Your Driver',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 14, color: AppColors.accent),
                              const SizedBox(width: 3),
                              Text(
                                '${ride.driverRating ?? 4.8}',
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                ride.vehiclePlate ?? 'ABC-1234',
                                style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: kMarketColorLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.phone, size: 20, color: kMarketColor),
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: kMarketColorLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.chat, size: 20, color: kMarketColor),
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Route info
                Row(
                  children: [
                    Column(
                      children: [
                        Container(width: 10, height: 10, decoration: const BoxDecoration(color: kMarketColor, shape: BoxShape.circle)),
                        Container(width: 2, height: 20, color: AppColors.inputBorder),
                        Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle)),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ride.pickupAddress, style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 10),
                          Text(ride.destinationAddress, style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          prov.cancelRide();
                          setState(() => _phase = 0);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => setState(() => _phase = 3),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kMarketColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: const Text('Simulate: Start Ride'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Phase 3: In Ride ───────────────────────────────────────────
  Widget _buildInRidePhase(BuildContext context, MarketProvider prov, RideRequest ride) {
    return Scaffold(
      body: Column(
        children: [
          // Map
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  color: const Color(0xFFE8F0FE),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.navigation, size: 48, color: kMarketColor),
                        SizedBox(height: 8),
                        Text('In transit...', style: TextStyle(color: AppColors.textTertiary, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: kMarketColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'RIDE IN PROGRESS',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                          ),
                          child: Text(
                            '${ride.estimatedMinutes} min left',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom panel
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.inputBorder, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _RideInfoPill(icon: Icons.straighten, value: '${ride.estimatedDistance.toStringAsFixed(1)} km', label: 'Distance'),
                    _RideInfoPill(icon: Icons.schedule, value: '${ride.estimatedMinutes} min', label: 'Duration'),
                    _RideInfoPill(icon: Icons.attach_money, value: '\$${ride.estimatedFare.toStringAsFixed(2)}', label: 'Fare'),
                  ],
                ),
                const SizedBox(height: 16),
                // Safety options
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _QuickAction(icon: Icons.share_location, label: 'Share', onTap: () {}),
                    _QuickAction(icon: Icons.report, label: 'Report', onTap: () {}),
                    _QuickAction(icon: Icons.support_agent, label: 'Help', onTap: () {}),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => setState(() => _phase = 4),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kMarketColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text('Simulate: Arrived'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Phase 4: Arrival ───────────────────────────────────────────
  Widget _buildArrivalPhase(BuildContext context, MarketProvider prov, RideRequest ride) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: kMarketColorLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_on, size: 50, color: kMarketColor),
              ),
              const SizedBox(height: 24),
              const Text(
                'You\'ve arrived!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                ride.destinationAddress,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              // Fare summary
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Base fare', style: TextStyle(color: AppColors.textSecondary)),
                        Text('\$${(ride.estimatedFare * 0.7).toStringAsFixed(2)}'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Distance', style: TextStyle(color: AppColors.textSecondary)),
                        Text('\$${(ride.estimatedFare * 0.2).toStringAsFixed(2)}'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Service fee', style: TextStyle(color: AppColors.textSecondary)),
                        Text('\$${(ride.estimatedFare * 0.1).toStringAsFixed(2)}'),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        Text(
                          '\$${ride.estimatedFare.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kMarketColorDark),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => setState(() => _phase = 5),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kMarketColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: const Text('Rate Your Ride', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Phase 5: Post Ride ─────────────────────────────────────────
  Widget _buildPostRidePhase(BuildContext context, MarketProvider prov) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              const Text(
                'How was your ride?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 24),
              // Star rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      i < 4 ? Icons.star : Icons.star_border,
                      size: 48,
                      color: i < 4 ? AppColors.accent : AppColors.textTertiary,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              // Quick tags
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  'Great driver',
                  'Clean car',
                  'Smooth ride',
                  'On time',
                  'Friendly',
                ].map((tag) {
                  return FilterChip(
                    label: Text(tag),
                    selected: false,
                    selectedColor: kMarketColorLight,
                    onSelected: (_) {},
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    side: BorderSide(color: AppColors.inputBorder),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // Comment
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Leave a comment (optional)',
                  hintStyle: TextStyle(fontSize: 13, color: AppColors.textTertiary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kMarketColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 16),
              // Tip
              const Text('Add a tip?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _TipButton(label: '\$1'),
                  const SizedBox(width: 12),
                  const _TipButton(label: '\$2'),
                  const SizedBox(width: 12),
                  const _TipButton(label: '\$5'),
                  const SizedBox(width: 12),
                  const _TipButton(label: 'Other'),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kMarketColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: const Text('Submit & Done', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _rideTypeIcon(RideType type) {
    switch (type) {
      case RideType.standard:
        return Icons.directions_car;
      case RideType.premium:
        return Icons.local_taxi;
      case RideType.xl:
        return Icons.airport_shuttle;
      case RideType.eco:
        return Icons.eco;
      case RideType.assist:
        return Icons.accessible;
    }
  }

  String _rideTypeLabel(RideType type) {
    switch (type) {
      case RideType.standard:
        return 'Standard';
      case RideType.premium:
        return 'Premium';
      case RideType.xl:
        return 'XL';
      case RideType.eco:
        return 'Eco';
      case RideType.assist:
        return 'Assist';
    }
  }

  String _rideTypeDesc(RideType type) {
    switch (type) {
      case RideType.standard:
        return 'Affordable, everyday rides';
      case RideType.premium:
        return 'High-end vehicles, top-rated drivers';
      case RideType.xl:
        return 'Spacious vehicles for groups';
      case RideType.eco:
        return 'Electric & hybrid vehicles';
      case RideType.assist:
        return 'Accessibility-equipped vehicles';
    }
  }

  String _rideTypePrice(RideType type) {
    switch (type) {
      case RideType.standard:
        return '\$8-12';
      case RideType.premium:
        return '\$15-20';
      case RideType.xl:
        return '\$18-25';
      case RideType.eco:
        return '\$7-10';
      case RideType.assist:
        return '\$10-15';
    }
  }
}

class _RideInfoPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _RideInfoPill({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: kMarketColor),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kMarketColorLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: kMarketColor),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

class _TipButton extends StatelessWidget {
  final String label;

  const _TipButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: kMarketColor,
        side: const BorderSide(color: kMarketColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(label),
    );
  }
}
