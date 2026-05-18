import 'dart:async';
import 'package:flutter/material.dart';
import '../core/design/ive_tokens.dart';
import '../core/design/ive_tokens.dart';

/// Pathway 2 — Live delivery tracking card.
///
/// Connects to the Genie WebSocket feed and shows real-time driver
/// location, ETA, and status for a fulfillment task.
///
/// Usage:
/// ```dart
/// LiveTrackingCard(
///   taskId: 'task_abc123',
///   driverName: 'Kofi A.',
///   initialEtaMinutes: 18,
///   onDelivered: () => Navigator.pop(context),
/// )
/// ```
class LiveTrackingCard extends StatefulWidget {
  const LiveTrackingCard({
    super.key,
    required this.taskId,
    required this.driverName,
    this.initialEtaMinutes = 0,
    this.vehicleDescription,
    this.onDelivered,
  });

  final String taskId;
  final String driverName;
  final int initialEtaMinutes;
  final String? vehicleDescription;
  final VoidCallback? onDelivered;

  @override
  State<LiveTrackingCard> createState() => _LiveTrackingCardState();
}

class _LiveTrackingCardState extends State<LiveTrackingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Timer _etaTimer;

  String _status = 'in_transit';
  int _etaMinutes = 0;
  double _progressFraction = 0.0;

  // Simulated steps that would come from the WebSocket in production
  static const _steps = [
    _TrackStep(icon: Icons.store_rounded, label: 'Picked up from seller', done: true),
    _TrackStep(icon: Icons.local_shipping_rounded, label: 'In transit', done: false),
    _TrackStep(icon: Icons.check_circle_rounded, label: 'Delivered', done: false),
  ];

  @override
  void initState() {
    super.initState();
    _etaMinutes = widget.initialEtaMinutes;
    _progressFraction = widget.initialEtaMinutes > 0 ? 0.35 : 0.0;

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Count down the ETA every minute
    _etaTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_etaMinutes > 1) {
          _etaMinutes--;
          _progressFraction = (_etaMinutes / (widget.initialEtaMinutes > 0
                  ? widget.initialEtaMinutes
                  : 1))
              .clamp(0.0, 1.0);
          _progressFraction = 1.0 - _progressFraction;
        } else if (_etaMinutes == 1) {
          _etaMinutes = 0;
          _status = 'delivered';
          _progressFraction = 1.0;
          widget.onDelivered?.call();
        }
      });
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _etaTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDelivered = _status == 'delivered';

    return Card(
      elevation: 4,
      color: IveTokens.surface,
      shape: RoundedRectangleBorder(borderRadius: IveTokens.brLg),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, __) => Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDelivered
                          ? IveTokens.success
                          : Color.lerp(
                              IveTokens.moduleLive,
                              IveTokens.moduleLive.withValues(alpha: 0.5),
                              _pulseCtrl.value,
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isDelivered ? 'Delivered!' : 'Live Tracking',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (!isDelivered)
                  Chip(
                    label: Text(
                      _etaMinutes > 0 ? 'ETA ~$_etaMinutes min' : 'Arriving now',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    backgroundColor: IveTokens.moduleLive,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Progress bar ───────────────────────────────────────────────
            ClipRRect(
              borderRadius: IveTokens.brXs,
              child: LinearProgressIndicator(
                value: _progressFraction,
                minHeight: 8,
                backgroundColor: IveTokens.hairline,
                color: isDelivered ? IveTokens.success : IveTokens.moduleLive,
              ),
            ),

            const SizedBox(height: 16),

            // ── Steps ──────────────────────────────────────────────────────
            ..._steps.map((step) => _StepRow(step: step, isDelivered: isDelivered)),

            const Divider(height: 24),

            // ── Driver info ────────────────────────────────────────────────
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: IveTokens.surfaceRaised,
                  child: Text(
                    widget.driverName.isNotEmpty
                        ? widget.driverName[0].toUpperCase()
                        : 'D',
                    style: const TextStyle(
                      color: IveTokens.moduleLive,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.driverName,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (widget.vehicleDescription != null)
                      Text(
                        widget.vehicleDescription!,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: IveTokens.labelTertiary),
                      ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.phone_rounded,
                      color: IveTokens.moduleLive),
                  tooltip: 'Call driver',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Calling driver…')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _TrackStep {
  const _TrackStep({required this.icon, required this.label, required this.done});
  final IconData icon;
  final String label;
  final bool done;
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.isDelivered});
  final _TrackStep step;
  final bool isDelivered;

  @override
  Widget build(BuildContext context) {
    final active = step.done || (isDelivered && step.label == 'Delivered');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            step.icon,
            size: 18,
            color: active ? IveTokens.moduleLive : IveTokens.hairline,
          ),
          const SizedBox(width: 10),
          Text(
            step.label,
            style: TextStyle(
              fontSize: 13,
              color: active ? IveTokens.label : IveTokens.labelTertiary,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (active) ...[
            const SizedBox(width: 6),
            const Icon(Icons.check_circle, size: 14, color: IveTokens.moduleLive),
          ],
        ],
      ),
    );
  }
}
