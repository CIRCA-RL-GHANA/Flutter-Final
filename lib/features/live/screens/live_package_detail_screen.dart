/// ═══════════════════════════════════════════════════════════════════════════
/// LIVE MODULE — Screen 10: Package Detail & Management
/// Full package detail: multi-stop progress, driver info,
/// security settings, timeline, live tracking
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../models/live_models.dart';
import '../providers/live_provider.dart';
import '../widgets/live_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class LivePackageDetailScreen extends StatelessWidget {
  const LivePackageDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveProvider>(
      builder: (context, prov, _) {
        final pkg = prov.selectedPackage ?? prov.packages.first;
        final driver = prov.drivers.where((d) => d.id == pkg.driverId).firstOrNull;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: LiveAppBar(
            title: 'Package ${pkg.id}',
            actions: [
              IconButton(icon: const Icon(Icons.share, size: 20), color: AppColors.textSecondary, onPressed: () {}),
              IconButton(icon: const Icon(Icons.more_vert, size: 20), color: AppColors.textSecondary, onPressed: () {}),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
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
              // Status Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [kLiveColor, kLiveAccent]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.2)),
                      child: const Icon(Icons.inventory_2, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pkg.status.name.toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                          Text('${pkg.type.name} • ${pkg.stops.length} stops', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                      child: Text('₵${pkg.driverEarnings.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Driver Section
              if (driver != null)
                LiveSectionCard(
                  title: 'ASSIGNED DRIVER',
                  icon: Icons.delivery_dining,
                  iconColor: const Color(0xFF3B82F6),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: kLiveColor.withOpacity(0.1),
                        child: Text(driver.name.substring(0, 1), style: const TextStyle(fontWeight: FontWeight.w700, color: kLiveColor)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(driver.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
                                const SizedBox(width: 2),
                                Text('${driver.rating}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                const SizedBox(width: 8),
                                Text('${driver.todayDeliveries} deliveries today', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.phone, size: 18, color: Color(0xFF10B981)),
                        style: IconButton.styleFrom(backgroundColor: const Color(0xFFD1FAE5)),
                      ),
                    ],
                  ),
                ),

              // Multi-Stop Progress
              LiveSectionCard(
                title: 'ROUTE PROGRESS',
                icon: Icons.route,
                iconColor: const Color(0xFF8B5CF6),
                child: Column(
                  children: pkg.stops.asMap().entries.map((entry) {
                    final i = entry.key;
                    final stop = entry.value;
                    final isLast = i == pkg.stops.length - 1;
                    final completed = stop.status == StopStatus.completed;
                    final current = stop.status == StopStatus.inProgress;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: completed ? const Color(0xFF10B981) : current ? kLiveColor : const Color(0xFFE5E7EB),
                              ),
                              child: Center(
                                child: completed
                                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                                    : current
                                        ? const Icon(Icons.circle, size: 10, color: Colors.white)
                                        : Text('${i + 1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
                              ),
                            ),
                            if (!isLast)
                              Container(width: 2, height: 32, color: completed ? const Color(0xFF10B981) : const Color(0xFFE5E7EB)),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      stop.type == StopType.returnPickup ? Icons.store : stop.type == StopType.delivery ? Icons.location_on : Icons.swap_horiz,
                                      size: 14,
                                      color: current ? kLiveColor : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(stop.type.name.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: current ? kLiveColor : AppColors.textTertiary)),
                                  ],
                                ),
                                Text(stop.address, style: TextStyle(fontSize: 13, fontWeight: current ? FontWeight.w600 : FontWeight.w400)),
                                Text(stop.customerName, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                Text('${stop.etaMinutes} min', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),

              // Security & Verification
              LiveSectionCard(
                title: 'SECURITY SETTINGS',
                icon: Icons.security,
                iconColor: const Color(0xFF10B981),
                child: Column(
                  children: [
                    _SecurityRow(icon: Icons.fingerprint, label: 'Biometric verification', enabled: pkg.biometricRequired),
                    _SecurityRow(icon: Icons.dialpad, label: 'PIN verification', enabled: pkg.pinRequired),
                    _SecurityRow(icon: Icons.edit, label: 'Digital signature', enabled: pkg.signatureRequired),
                    _SecurityRow(icon: Icons.camera_alt, label: 'Proof of delivery photo', enabled: pkg.photoRequired),
                  ],
                ),
              ),

              // Package Contents
              LiveSectionCard(
                title: 'PACKAGE CONTENTS',
                icon: Icons.shopping_bag,
                iconColor: kLiveColor,
                child: Column(
                  children: pkg.stops.map((s) => s.orderId).whereType<String>().toList().asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: kLiveColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                            child: Text('#${entry.value}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kLiveColor)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Order #${entry.value}', style: const TextStyle(fontSize: 13))),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Live Tracking
              LiveSectionCard(
                title: 'LIVE TRACKING',
                icon: Icons.gps_fixed,
                iconColor: const Color(0xFF3B82F6),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(12)),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map, size: 32, color: AppColors.textTertiary),
                        const SizedBox(height: 4),
                        Text('Real-time driver location', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: const Text('REASSIGN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(foregroundColor: kLiveColor, padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.chat, size: 16),
                    label: const Text('MESSAGE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF3B82F6), padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.gps_fixed, size: 16),
                    label: const Text('TRACK', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
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

class _SecurityRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  const _SecurityRow({required this.icon, required this.label, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: enabled ? const Color(0xFF10B981) : AppColors.textTertiary),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: enabled ? AppColors.textPrimary : AppColors.textTertiary))),
          Icon(enabled ? Icons.check_circle : Icons.cancel, size: 16, color: enabled ? const Color(0xFF10B981) : AppColors.textTertiary),
        ],
      ),
    );
  }
}
