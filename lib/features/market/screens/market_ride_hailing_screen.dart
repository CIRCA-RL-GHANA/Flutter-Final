/// MARKET MODULE — Ride Hailing & Execution
/// 6 phases: Request → Matching → Driver Assigned → In-Ride → Arrival → Post-Ride
/// P1 spec: map persists through all phases; only the status overlay text changes.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive.dart';
import '../../../core/routes/app_routes.dart';
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

  int _rideStatusToPhase(RideStatus status) {
    switch (status) {
      case RideStatus.searching:      return 1;
      case RideStatus.driverAssigned: return 2;
      case RideStatus.driverEnRoute:  return 2;
      case RideStatus.arrived:        return 4;
      case RideStatus.inProgress:     return 3;
      case RideStatus.completed:      return 5;
      case RideStatus.cancelled:      return 0;
    }
  }

  String _statusText(RideRequest? ride) {
    switch (_phase) {
      case 0: return 'Select your destination';
      case 1: return 'Finding nearby drivers...';
      case 2: return 'Driver en route · ${ride?.estimatedMinutes ?? '--'} min';
      case 3: return 'In transit · ${ride?.estimatedMinutes ?? '--'} min left';
      case 4: return 'Arrived at destination';
      default: return '';
    }
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
          backgroundColor: IveTokens.voidColor,
          body: Column(
            children: [
              // ── Persistent map — never rebuilds between phases ──────
              Expanded(
                flex: _phase == 5 ? 1 : 2,
                child: _PersistentMap(
                  phase: _phase,
                  statusText: _statusText(activeRide),
                  onBack: () => Navigator.pop(context),
                ),
              ),

              // ── Phase-specific bottom panel ─────────────────────────
              _buildBottomPanel(context, prov, activeRide),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomPanel(BuildContext context, MarketProvider prov, RideRequest? ride) {
    switch (_phase) {
      case 0:  return _RequestPanel(
                 prov: prov,
                 pickupCtrl: _pickupController,
                 dropoffCtrl: _dropoffController,
                 passengers: _passengers,
                 onPassengersChanged: (v) => setState(() => _passengers = v),
                 onRequest: () {
                   HapticFeedback.mediumImpact();
                   prov.requestRide(
                     pickup: _pickupController.text,
                     destination: _dropoffController.text,
                   );
                   setState(() => _phase = 1);
                 },
               );
      case 1:  return _MatchingPanel(
                 onCancel: () {
                   prov.cancelRide();
                   setState(() => _phase = 0);
                 },
                 onSimulateFound: () => setState(() => _phase = 2),
               );
      case 2:  return _DriverPanel(
                 ride: ride!,
                 onCancel: () {
                   prov.cancelRide();
                   setState(() => _phase = 0);
                 },
                 onSimulateStart: () => setState(() => _phase = 3),
               );
      case 3:  return _InRidePanel(
                 ride: ride!,
                 onSimulateArrived: () => setState(() => _phase = 4),
               );
      case 4:  return _ArrivalPanel(
                 ride: ride!,
                 onRate: () => setState(() => _phase = 5),
               );
      default: return _PostRidePanel(onDone: () => Navigator.pop(context));
    }
  }
}

// ── Persistent map placeholder ───────────────────────────────────────────────

class _PersistentMap extends StatelessWidget {
  final int phase;
  final String statusText;
  final VoidCallback onBack;

  const _PersistentMap({required this.phase, required this.statusText, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Map placeholder
        Container(
          color: IveTokens.surfaceColor,
          child: Center(
            child: Icon(
              phase <= 1
                  ? Icons.map_outlined
                  : phase == 3
                      ? Icons.navigation_outlined
                      : Icons.directions_car_outlined,
              size: 56,
              color: IveTokens.faintColor,
            ),
          ),
        ),

        // Status overlay bar (phases 0–4 only)
        if (phase < 5)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            right: 12,
            child: Row(
              children: [
                // Back button
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: IveTokens.raisedColor,
                      borderRadius: BorderRadius.circular(IveTokens.rContainer),
                      border: Border.all(color: IveTokens.hairColor),
                    ),
                    child: const Icon(Icons.arrow_back, size: 20, color: IveTokens.inkColor),
                  ),
                ),
                const SizedBox(width: 8),
                // Status text pill — only changes text, widget stays
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: IveTokens.raisedColor,
                      borderRadius: BorderRadius.circular(IveTokens.rContainer),
                      border: Border.all(color: IveTokens.hairColor),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        statusText,
                        key: ValueKey(statusText),
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: phase == 1 ? kMarketColor : IveTokens.inkColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Phase 0: Request panel ───────────────────────────────────────────────────

class _RequestPanel extends StatelessWidget {
  final MarketProvider prov;
  final TextEditingController pickupCtrl;
  final TextEditingController dropoffCtrl;
  final int passengers;
  final ValueChanged<int> onPassengersChanged;
  final VoidCallback onRequest;

  const _RequestPanel({
    required this.prov,
    required this.pickupCtrl,
    required this.dropoffCtrl,
    required this.passengers,
    required this.onPassengersChanged,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.55),
      decoration: const BoxDecoration(
        color: IveTokens.raisedColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(IveTokens.rContainer)),
        border: Border(top: BorderSide(color: IveTokens.hairColor)),
      ),
      child: Column(
        children: [
          _BottomHandle(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                // Route inputs
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Container(width: 10, height: 10, decoration: const BoxDecoration(color: kMarketColor, shape: BoxShape.circle)),
                        Container(width: 1.5, height: 24, color: IveTokens.hair2Color),
                        Container(width: 10, height: 10, decoration: const BoxDecoration(color: IveTokens.badColor, shape: BoxShape.circle)),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          _DarkTextField(controller: pickupCtrl, hint: 'Pickup location', icon: Icons.my_location),
                          const SizedBox(height: 8),
                          _DarkTextField(controller: dropoffCtrl, hint: 'Where to?', icon: Icons.location_on),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Ride type
                const Text('Ride Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: IveTokens.ink2Color)),
                const SizedBox(height: 8),
                ...RideType.values.map((type) {
                  final isSelected = prov.selectedRideType == type;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      prov.setRideType(type);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? kMarketColor.withValues(alpha: 0.1) : IveTokens.surfaceColor,
                        borderRadius: BorderRadius.circular(IveTokens.rContainer),
                        border: Border.all(
                          color: isSelected ? kMarketColor : IveTokens.hairColor,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(_rideTypeIcon(type), size: 22, color: isSelected ? kMarketColor : IveTokens.ink2Color),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_rideTypeLabel(type),
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                                        color: isSelected ? kMarketColor : IveTokens.inkColor)),
                                Text(_rideTypeDesc(type),
                                    style: const TextStyle(fontSize: 11, color: IveTokens.muteColor)),
                              ],
                            ),
                          ),
                          Text(_rideTypePrice(type),
                              style: GoogleFonts.ibmPlexMono(fontSize: 14, fontWeight: FontWeight.w700,
                                  color: isSelected ? kMarketColor : IveTokens.inkColor,
                                  fontFeatures: const [FontFeature.tabularFigures()])),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                // Passengers
                Row(
                  children: [
                    const Text('Passengers', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: IveTokens.inkColor)),
                    const Spacer(),
                    QuantitySelector(quantity: passengers, min: 1, max: 6, onChanged: onPassengersChanged),
                  ],
                ),
              ],
            ),
          ),
          // CTA
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
            child: IveButton.primary(
              label: 'Request Ride',
              onPressed: dropoffCtrl.text.isNotEmpty ? onRequest : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Phase 1: Matching panel ──────────────────────────────────────────────────

class _MatchingPanel extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSimulateFound;

  const _MatchingPanel({required this.onCancel, required this.onSimulateFound});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
      decoration: const BoxDecoration(
        color: IveTokens.raisedColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(IveTokens.rContainer)),
        border: Border(top: BorderSide(color: IveTokens.hairColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BottomHandle(),
          const SizedBox(height: 12),
          const Row(
            children: [
              SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(color: kMarketColor, strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Finding nearby drivers',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: IveTokens.inkColor)),
            ],
          ),
          const SizedBox(height: 6),
          const Text('This usually takes less than a minute',
              style: TextStyle(fontSize: 13, color: IveTokens.muteColor)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: IveButton.primary(label: 'Cancel', isDestructive: true, onPressed: onCancel)),
              const SizedBox(width: 12),
              Expanded(child: IveButton.secondary(label: 'Simulate: Found', onPressed: onSimulateFound)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Phase 2: Driver assigned panel ──────────────────────────────────────────

class _DriverPanel extends StatelessWidget {
  final RideRequest ride;
  final VoidCallback onCancel;
  final VoidCallback onSimulateStart;

  const _DriverPanel({required this.ride, required this.onCancel, required this.onSimulateStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(
        color: IveTokens.raisedColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(IveTokens.rContainer)),
        border: Border(top: BorderSide(color: IveTokens.hairColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BottomHandle(),
          const SizedBox(height: 8),
          // Driver info row
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: kMarketColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(IveTokens.rContainer),
                ),
                child: const Icon(Icons.person, size: 24, color: kMarketColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ride.driverName ?? 'Your Driver',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: IveTokens.inkColor)),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 13, color: IveTokens.warnColor),
                        const SizedBox(width: 3),
                        Text('${ride.driverRating ?? 4.8}',
                            style: const TextStyle(fontSize: 12, color: IveTokens.ink2Color)),
                        const SizedBox(width: 8),
                        Text(ride.vehiclePlate ?? 'ABC-1234',
                            style: const TextStyle(fontSize: 12, color: IveTokens.muteColor)),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.phone_outlined, color: kMarketColor),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Calling driver...'), behavior: SnackBarBehavior.floating)),
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline, color: kMarketColor),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening chat...'), behavior: SnackBarBehavior.floating)),
              ),
            ],
          ),
          const Divider(height: 20, color: IveTokens.hairColor),
          // Route
          Row(
            children: [
              Column(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: kMarketColor, shape: BoxShape.circle)),
                  Container(width: 1.5, height: 16, color: IveTokens.hair2Color),
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: IveTokens.badColor, shape: BoxShape.circle)),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ride.pickupAddress, style: const TextStyle(fontSize: 12, color: IveTokens.inkColor),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Text(ride.destinationAddress, style: const TextStyle(fontSize: 12, color: IveTokens.inkColor),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: IveButton.primary(label: 'Cancel', isDestructive: true, onPressed: onCancel)),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: IveButton.secondary(label: 'Simulate: Start Ride', onPressed: onSimulateStart)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Phase 3: In-ride panel ───────────────────────────────────────────────────

class _InRidePanel extends StatelessWidget {
  final RideRequest ride;
  final VoidCallback onSimulateArrived;

  const _InRidePanel({required this.ride, required this.onSimulateArrived});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(
        color: IveTokens.raisedColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(IveTokens.rContainer)),
        border: Border(top: BorderSide(color: IveTokens.hairColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BottomHandle(),
          const SizedBox(height: 12),
          // Ride stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatPill(icon: Icons.straighten,
                  value: '${ride.estimatedDistance.toStringAsFixed(1)} km', label: 'Distance'),
              _StatPill(icon: Icons.schedule,
                  value: '${ride.estimatedMinutes} min', label: 'Duration'),
              _StatPill(icon: Icons.attach_money,
                  value: '\$${ride.estimatedFare.toStringAsFixed(2)}', label: 'Fare'),
            ],
          ),
          const SizedBox(height: 16),
          // Quick actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _QuickAction(icon: Icons.share_location, label: 'Share',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Location shared'), behavior: SnackBarBehavior.floating))),
              _QuickAction(icon: Icons.report_outlined, label: 'Report',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Report submitted'), behavior: SnackBarBehavior.floating))),
              _QuickAction(icon: Icons.support_agent_outlined, label: 'Help',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.utilityHelp)),
            ],
          ),
          const SizedBox(height: 16),
          IveButton.secondary(label: 'Simulate: Arrived', onPressed: onSimulateArrived),
        ],
      ),
    );
  }
}

// ── Phase 4: Arrival panel ───────────────────────────────────────────────────

class _ArrivalPanel extends StatelessWidget {
  final RideRequest ride;
  final VoidCallback onRate;

  const _ArrivalPanel({required this.ride, required this.onRate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(
        color: IveTokens.raisedColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(IveTokens.rContainer)),
        border: Border(top: BorderSide(color: IveTokens.hairColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BottomHandle(),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.location_on_rounded, color: IveTokens.okColor, size: 20),
              SizedBox(width: 8),
              Text("You've arrived",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: IveTokens.inkColor)),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(ride.destinationAddress,
                style: const TextStyle(fontSize: 12, color: IveTokens.muteColor),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(height: 16),
          // Fare breakdown
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: IveTokens.surfaceColor,
              borderRadius: BorderRadius.circular(IveTokens.rContainer),
              border: Border.all(color: IveTokens.hairColor),
            ),
            child: Column(
              children: [
                _FareRow('Base fare', '\$${(ride.estimatedFare * 0.7).toStringAsFixed(2)}'),
                _FareRow('Distance', '\$${(ride.estimatedFare * 0.2).toStringAsFixed(2)}'),
                _FareRow('Service fee', '\$${(ride.estimatedFare * 0.1).toStringAsFixed(2)}'),
                const Divider(height: 16, color: IveTokens.hairColor),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: IveTokens.inkColor)),
                    Text('\$${ride.estimatedFare.toStringAsFixed(2)}',
                        style: GoogleFonts.ibmPlexMono(fontSize: 16, fontWeight: FontWeight.w700,
                            color: kMarketColor, fontFeatures: const [FontFeature.tabularFigures()])),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          IveButton.primary(label: 'Rate Your Ride', onPressed: onRate),
        ],
      ),
    );
  }
}

class _FareRow extends StatelessWidget {
  final String label;
  final String value;
  const _FareRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: IveTokens.muteColor)),
          Text(value, style: GoogleFonts.ibmPlexMono(fontSize: 12, color: IveTokens.ink2Color,
              fontFeatures: const [FontFeature.tabularFigures()])),
        ],
      ),
    );
  }
}

// ── Phase 5: Post-ride panel ─────────────────────────────────────────────────

class _PostRidePanel extends StatelessWidget {
  final VoidCallback onDone;
  const _PostRidePanel({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: IveTokens.raisedColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(IveTokens.rContainer)),
          border: Border(top: BorderSide(color: IveTokens.hairColor)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _BottomHandle(),
                const SizedBox(height: 16),
                const Text('How was your ride?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: IveTokens.inkColor)),
                const SizedBox(height: 20),
                // Star rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(i < 4 ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 40, color: i < 4 ? IveTokens.warnColor : IveTokens.faintColor),
                  )),
                ),
                const SizedBox(height: 20),
                // Quick tags
                Wrap(
                  spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
                  children: ['Great driver', 'Clean car', 'Smooth ride', 'On time', 'Friendly'].map((tag) {
                    return OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: IveTokens.ink2Color,
                        side: const BorderSide(color: IveTokens.hairColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(IveTokens.rContainer)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(tag, style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                // Comment field
                TextField(
                  maxLines: 2,
                  style: const TextStyle(fontSize: 13, color: IveTokens.inkColor),
                  decoration: InputDecoration(
                    hintText: 'Leave a comment (optional)',
                    hintStyle: const TextStyle(fontSize: 13, color: IveTokens.muteColor),
                    filled: true,
                    fillColor: IveTokens.surfaceColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(IveTokens.rContainer),
                        borderSide: const BorderSide(color: IveTokens.hairColor)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(IveTokens.rContainer),
                        borderSide: const BorderSide(color: IveTokens.hairColor)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(IveTokens.rContainer),
                        borderSide: const BorderSide(color: kMarketColor, width: 1.5)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const Spacer(),
                IveButton.primary(label: 'Submit & Done', onPressed: onDone),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared small widgets ─────────────────────────────────────────────────────

class _BottomHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          width: 36, height: 4,
          decoration: BoxDecoration(color: IveTokens.hair2Color, borderRadius: BorderRadius.circular(2)),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatPill({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: kMarketColor),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.ibmPlexMono(fontSize: 13, fontWeight: FontWeight.w700,
            color: IveTokens.inkColor, fontFeatures: const [FontFeature.tabularFigures()])),
        Text(label, style: const TextStyle(fontSize: 10, color: IveTokens.muteColor)),
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
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kMarketColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(IveTokens.rContainer),
            ),
            child: Icon(icon, color: kMarketColor, size: 20),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: IveTokens.ink2Color)),
        ],
      ),
    );
  }
}

class _DarkTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  const _DarkTextField({required this.controller, required this.hint, required this.icon});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 13, color: IveTokens.inkColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: IveTokens.muteColor),
        prefixIcon: Icon(icon, size: 16, color: IveTokens.ink2Color),
        prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        filled: true,
        fillColor: IveTokens.surfaceColor,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(IveTokens.rContainer),
            borderSide: const BorderSide(color: IveTokens.hairColor)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(IveTokens.rContainer),
            borderSide: const BorderSide(color: IveTokens.hairColor)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(IveTokens.rContainer),
            borderSide: const BorderSide(color: kMarketColor, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        isDense: true,
      ),
    );
  }
}

// ── Ride type helpers ────────────────────────────────────────────────────────

IconData _rideTypeIcon(RideType type) {
  switch (type) {
    case RideType.standard: return Icons.directions_car;
    case RideType.premium:  return Icons.local_taxi;
    case RideType.xl:       return Icons.airport_shuttle;
    case RideType.eco:      return Icons.eco;
    case RideType.assist:   return Icons.accessible;
  }
}

String _rideTypeLabel(RideType type) {
  switch (type) {
    case RideType.standard: return 'Standard';
    case RideType.premium:  return 'Premium';
    case RideType.xl:       return 'XL';
    case RideType.eco:      return 'Eco';
    case RideType.assist:   return 'Assist';
  }
}

String _rideTypeDesc(RideType type) {
  switch (type) {
    case RideType.standard: return 'Affordable, everyday rides';
    case RideType.premium:  return 'High-end vehicles, top-rated drivers';
    case RideType.xl:       return 'Spacious vehicles for groups';
    case RideType.eco:      return 'Electric & hybrid vehicles';
    case RideType.assist:   return 'Accessibility-equipped vehicles';
  }
}

String _rideTypePrice(RideType type) {
  switch (type) {
    case RideType.standard: return '\$8–12';
    case RideType.premium:  return '\$15–20';
    case RideType.xl:       return '\$18–25';
    case RideType.eco:      return '\$7–10';
    case RideType.assist:   return '\$10–15';
  }
}
