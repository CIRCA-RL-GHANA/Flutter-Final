/// ═══════════════════════════════════════════════════════════════════════════
/// LIVE MODULE — Screen 4: Driver Assignment Flow
/// Intelligent driver matching: recommended driver, alternatives,
/// driver map view, assignment settings, confirmation
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

class LiveDriverAssignmentScreen extends StatefulWidget {
  const LiveDriverAssignmentScreen({super.key});

  @override
  State<LiveDriverAssignmentScreen> createState() => _LiveDriverAssignmentScreenState();
}

class _LiveDriverAssignmentScreenState extends State<LiveDriverAssignmentScreen> {
  bool _notifyImmediately = true;
  bool _priorityBonus = false;
  bool _biometricVerification = true;
  bool _liveTracking = true;
  bool _assigned = false;
  String? _selectedDriverId;
  final _messageController = TextEditingController(text: 'This is an electronics order requiring ID check.');

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveProvider>(
      builder: (context, prov, _) {
        final order = prov.selectedOrder ?? prov.orders.first;

        if (_assigned) {
          return _AssignmentConfirmation(
            order: order,
            driver: prov.drivers.firstWhere((d) => d.id == (_selectedDriverId ?? 'D001'), orElse: () => prov.drivers.first),
            messageController: _messageController,
            onDone: () => Navigator.pop(context),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: LiveAppBar(
            title: 'Assign Driver • Order #${order.id}',
            actions: [
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                color: AppColors.textSecondary,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.recommendations.isEmpty) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
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
                            'AI recommends: ${ai.recommendations.first.name}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kLiveColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Text('SELECT OPTIMAL DRIVER', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),

              // Recommended driver
              if (prov.availableDrivers.isNotEmpty)
                LiveDriverCard(
                  driver: prov.availableDrivers.first,
                  isRecommended: true,
                  onSelect: () {
                    HapticFeedback.heavyImpact();
                    setState(() {
                      _selectedDriverId = prov.availableDrivers.first.id;
                      _assigned = true;
                    });
                  },
                  onViewProfile: () {
                    prov.selectDriver(prov.availableDrivers.first.id);
                    Navigator.pushNamed(context, AppRoutes.liveDriverPerformance);
                  },
                ),

              // Alternatives
              if (prov.availableDrivers.length > 1) ...[
                const SizedBox(height: 8),
                const Text('🥈 ALTERNATIVES', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                ...prov.availableDrivers.skip(1).map((d) => LiveDriverCard(
                  driver: d,
                  compact: true,
                  onSelect: () {
                    HapticFeedback.heavyImpact();
                    setState(() {
                      _selectedDriverId = d.id;
                      _assigned = true;
                    });
                  },
                  onViewProfile: () {
                    prov.selectDriver(d.id);
                    Navigator.pushNamed(context, AppRoutes.liveDriverPerformance);
                  },
                )),
              ],

              // Driver Map View
              const SizedBox(height: 16),
              LiveSectionCard(
                title: 'DRIVER MAP VIEW',
                icon: Icons.map,
                iconColor: const Color(0xFF3B82F6),
                child: Column(
                  children: [
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.map, size: 40, color: AppColors.textTertiary),
                            const SizedBox(height: 8),
                            Text('Interactive map showing all available drivers', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _MapLegendDot(color: const Color(0xFF10B981), label: 'Available'),
                        const SizedBox(width: 16),
                        _MapLegendDot(color: const Color(0xFFF59E0B), label: 'Finishing soon'),
                        const SizedBox(width: 16),
                        const _MapLegendDot(color: kLiveColor, label: 'Unavailable'),
                      ],
                    ),
                  ],
                ),
              ),

              // Assignment Settings
              LiveSectionCard(
                title: 'ASSIGNMENT SETTINGS',
                icon: Icons.settings,
                iconColor: AppColors.textSecondary,
                child: Column(
                  children: [
                    _SettingToggle(label: 'Notify driver immediately', value: _notifyImmediately, onChanged: (v) => setState(() => _notifyImmediately = v)),
                    _SettingToggle(label: 'Add priority bonus (+10% earnings)', value: _priorityBonus, onChanged: (v) => setState(() => _priorityBonus = v)),
                    _SettingToggle(label: 'Require biometric verification', value: _biometricVerification, onChanged: (v) => setState(() => _biometricVerification = v)),
                    _SettingToggle(label: 'Enable live tracking for customer', value: _liveTracking, onChanged: (v) => setState(() => _liveTracking = v)),
                  ],
                ),
              ),

              // Bottom actions
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.broadcast_on_personal, size: 16),
                      label: const Text('BROADCAST TO ALL', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(foregroundColor: kLiveColor, padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.schedule, size: 16),
                      label: const Text('SCHEDULE LATER', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.textSecondary, padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _AssignmentConfirmation extends StatelessWidget {
  final LiveOrder order;
  final LiveDriver driver;
  final TextEditingController messageController;
  final VoidCallback onDone;

  const _AssignmentConfirmation({
    required this.order,
    required this.driver,
    required this.messageController,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const LiveAppBar(title: 'Driver Assigned Successfully'),
      body: ListView(
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
                    color: const Color(0xFF10B981).withOpacity(0.1),
                  ),
                  child: const Icon(Icons.check_circle, size: 48, color: Color(0xFF10B981)),
                ),
                const SizedBox(height: 16),
                Text('🎉 ORDER #${order.id} ASSIGNED!', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('To: ${driver.name}', style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text('Estimated pickup: 11:48 AM', style: TextStyle(fontSize: 14, color: AppColors.textTertiary)),
                Text('Estimated delivery: 12:04 PM', style: TextStyle(fontSize: 14, color: AppColors.textTertiary)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          LiveSectionCard(
            title: 'ASSIGNMENT DETAILS',
            icon: Icons.receipt_long,
            iconColor: const Color(0xFF3B82F6),
            child: Column(
              children: [
                _DetailRow(label: 'Order value', value: '₵${order.total.toStringAsFixed(0)}'),
                const _DetailRow(label: 'Driver earnings', value: '₵43.50'),
                const _DetailRow(label: 'Priority bonus', value: '₵4.35'),
                const _DetailRow(label: 'Customer notified', value: 'Yes'),
                const _DetailRow(label: 'Live tracking enabled', value: 'Yes'),
              ],
            ),
          ),

          LiveSectionCard(
            title: 'MESSAGE TO DRIVER (OPTIONAL)',
            icon: Icons.chat,
            iconColor: const Color(0xFF8B5CF6),
            child: TextField(
              controller: messageController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Add a message for the driver...',
                filled: true,
                fillColor: AppColors.backgroundLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.gps_fixed, size: 16), label: const Text('VIEW DRIVER'), style: OutlinedButton.styleFrom(foregroundColor: kLiveColor, padding: const EdgeInsets.symmetric(vertical: 12)))),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.notifications, size: 16), label: const Text('NOTIFY CUSTOMER'), style: OutlinedButton.styleFrom(foregroundColor: AppColors.textSecondary, padding: const EdgeInsets.symmetric(vertical: 12)))),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: onDone,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('• $label', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MapLegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _MapLegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _SettingToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SettingToggle({required this.label, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Switch(value: value, onChanged: onChanged, activeColor: kLiveColor, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
        ],
      ),
    );
  }
}
