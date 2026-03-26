/// ═══════════════════════════════════════════════════════════════════════════
/// LIVE Widget (Real-Time Operations)
/// Visible to: Branch Manager, Branch Response Officer, Driver, Response Officer
/// Role-specific views per spec
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/rbac_models.dart';

class LiveWidgetContent extends StatelessWidget {
  final UserRole role;
  final BranchType? branchType;
  final DriverType? driverType;

  const LiveWidgetContent({
    super.key,
    required this.role,
    this.branchType,
    this.driverType,
  });

  @override
  Widget build(BuildContext context) {
    final color = RoleColors.forModule(PromptModule.live);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with live pulse
          Row(
            children: [
              _LivePulse(color: color),
              const SizedBox(width: 6),
              const Text(
                'LIVE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Role-specific content
          if (role == UserRole.driver)
            _DriverView(driverType: driverType, color: color)
          else
            _ManagerView(color: color),
        ],
      ),
    );
  }
}

// ─── Branch Manager / Response Officer View ─────────────────────────────────

class _ManagerView extends StatelessWidget {
  final Color color;
  const _ManagerView({required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          // Tab-like header
          Row(
            children: [
              _MiniTab(label: 'Orders', isSelected: true, color: color),
              _MiniTab(label: 'Returns', isSelected: false, color: color),
              _MiniTab(label: 'Packages', isSelected: false, color: color),
            ],
          ),

          const SizedBox(height: 8),

          // Incoming Orders
          _LiveItem(
            title: 'Order #ORD-2041',
            subtitle: 'Alice • 3 items',
            trailing: 'ASSIGN',
            color: color,
          ),
          const SizedBox(height: 6),
          const _LiveItem(
            title: 'Order #ORD-2042',
            subtitle: 'Bob • 1 item',
            trailing: 'SELF-PICKUP',
            color: AppColors.success,
          ),

          const Spacer(),

          // Active Packages
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.inventory_2, size: 14, color: color),
                const SizedBox(width: 6),
                const Text(
                  'Package #P-789',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
                const Spacer(),
                Text(
                  '2/4 stops',
                  style: TextStyle(fontSize: 10, color: color,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Driver View ─────────────────────────────────────────────────────────────

class _DriverView extends StatelessWidget {
  final DriverType? driverType;
  final Color color;
  const _DriverView({this.driverType, required this.color});

  @override
  Widget build(BuildContext context) {
    final isTransport = driverType == DriverType.transportDriver;

    return Expanded(
      child: Column(
        children: [
          if (isTransport) ...[
            // Transport driver view
            _LiveItem(
              title: 'Ride #R-901',
              subtitle: '2.3km • ₵12.50',
              trailing: 'ACCEPT',
              color: color,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.navigation, size: 14, color: color),
                  const SizedBox(width: 6),
                  const Text(
                    'Passenger pickup',
                    style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  const Text(
                    'ETA 4 min',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Shop/Logistics driver view
            _LiveItem(
              title: 'Package #P-789',
              subtitle: '2 stops • 8.3 miles',
              trailing: 'START',
              color: color,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.map, size: 14, color: color),
                  const SizedBox(width: 6),
                  const Text(
                    'Stop 1/2',
                    style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  const Text(
                    'Verified ✓',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ],

          const Spacer(),

          // SOS Button (prominent for drivers)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.error.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sos, size: 14, color: AppColors.error),
                const SizedBox(width: 6),
                Text(
                  'Emergency SOS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
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

// ─── Shared Components ──────────────────────────────────────────────────────

class _LivePulse extends StatefulWidget {
  final Color color;
  const _LivePulse({required this.color});

  @override
  State<_LivePulse> createState() => _LivePulseState();
}

class _LivePulseState extends State<_LivePulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(0.15 + 0.1 * _controller.value),
          ),
          child: Center(
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
              ),
              child: const Icon(Icons.live_tv, size: 7, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}

class _MiniTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  const _MiniTab({required this.label, required this.isSelected, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isSelected ? Border.all(color: color.withOpacity(0.3)) : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 9,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? color : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}

class _LiveItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;
  final Color color;
  const _LiveItem({required this.title, required this.subtitle, required this.trailing, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text(subtitle, style: const TextStyle(fontSize: 9, color: AppColors.textTertiary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              trailing,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
