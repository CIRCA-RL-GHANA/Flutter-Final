import 'dart:async';
import 'package:flutter/material.dart';

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                          ? Colors.green
                          : Color.lerp(
                              const Color(0xFF6C3CE1),
                              const Color(0xFFB39DDB),
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
                    backgroundColor: const Color(0xFF6C3CE1),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Progress bar ───────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _progressFraction,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                color: isDelivered ? Colors.green : const Color(0xFF6C3CE1),
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
                  backgroundColor: const Color(0xFFEDE7F6),
                  child: Text(
                    widget.driverName.isNotEmpty
                        ? widget.driverName[0].toUpperCase()
                        : 'D',
                    style: const TextStyle(
                      color: Color(0xFF6C3CE1),
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
                            ?.copyWith(color: Colors.grey.shade600),
                      ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.phone_rounded,
                      color: Color(0xFF6C3CE1)),
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
            color: active ? const Color(0xFF6C3CE1) : Colors.grey.shade400,
          ),
          const SizedBox(width: 10),
          Text(
            step.label,
            style: TextStyle(
              fontSize: 13,
              color: active ? Colors.black87 : Colors.grey.shade500,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (active) ...[
            const SizedBox(width: 6),
            const Icon(Icons.check_circle, size: 14, color: Color(0xFF6C3CE1)),
          ],
        ],
      ),
    );
  }
}
