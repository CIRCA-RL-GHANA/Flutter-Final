/// ═══════════════════════════════════════════════════════════════════════════
/// LIVE MODULE — Screen 12: Package Acceptance Flow
/// Driver accepts/declines assigned packages, reviews details,
/// confirms pickup readiness, and starts navigation
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../models/live_models.dart';
import '../providers/live_provider.dart';
import '../widgets/live_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class LivePackageAcceptanceScreen extends StatefulWidget {
  const LivePackageAcceptanceScreen({super.key});

  @override
  State<LivePackageAcceptanceScreen> createState() => _LivePackageAcceptanceScreenState();
}

class _LivePackageAcceptanceScreenState extends State<LivePackageAcceptanceScreen> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveProvider>(
      builder: (context, prov, _) {
        final pkg = prov.selectedPackage ?? prov.packages.first;

        if (_accepted) {
          return _AcceptedView(package: pkg, onStartNavigation: () => Navigator.pop(context));
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: const LiveAppBar(title: 'New Package Assignment'),
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
              // Countdown timer banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [const Color(0xFFF59E0B), const Color(0xFFEF4444)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('RESPOND WITHIN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70)),
                          const Text('0:48', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                      child: Text('₵${(pkg.driverEarnings * 0.08).toStringAsFixed(0)} earnings', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Package Summary
              LiveSectionCard(
                title: 'PACKAGE DETAILS',
                icon: Icons.inventory_2,
                iconColor: kLiveColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Package ${pkg.id}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: kLiveColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                          child: Text(pkg.type.name.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: kLiveColor)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(icon: Icons.route, label: '${pkg.stops.length} stops'),
                    _InfoRow(icon: Icons.attach_money, label: 'Value: ₵${pkg.driverEarnings.toStringAsFixed(0)}'),
                    _InfoRow(icon: Icons.timer, label: 'Est. duration: 45 min'),
                    _InfoRow(icon: Icons.straighten, label: 'Est. distance: 8.3 km'),
                  ],
                ),
              ),

              // Route Preview
              LiveSectionCard(
                title: 'ROUTE STOPS',
                icon: Icons.route,
                iconColor: const Color(0xFF3B82F6),
                child: Column(
                  children: pkg.stops.asMap().entries.map((entry) {
                    final i = entry.key;
                    final stop = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 24, height: 24,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: i == 0 ? const Color(0xFF10B981) : const Color(0xFFE5E7EB)),
                            child: Center(child: Text('${i + 1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: i == 0 ? Colors.white : AppColors.textTertiary))),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(stop.type.name.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
                                    const SizedBox(width: 6),
                                    Text(stop.customerName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                Text(stop.address, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Security Requirements
              LiveSectionCard(
                title: 'VERIFICATION REQUIRED',
                icon: Icons.security,
                iconColor: const Color(0xFF10B981),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (pkg.pinRequired) const _VerifyChip(label: '🔢 PIN', active: true),
                    if (pkg.signatureRequired) const _VerifyChip(label: '✍️ Signature', active: true),
                    if (pkg.photoRequired) const _VerifyChip(label: '📸 Photo', active: true),
                    if (pkg.biometricRequired) const _VerifyChip(label: '🔐 Biometric', active: true),
                  ],
                ),
              ),

              // Special Instructions
              LiveSectionCard(
                title: 'SPECIAL INSTRUCTIONS',
                icon: Icons.notes,
                iconColor: const Color(0xFFF59E0B),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
                  child: const Text('Handle with care. Customer requested call before delivery. Leave at reception if unavailable.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF92400E)),
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
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(foregroundColor: kLiveColor, padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('DECLINE', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      setState(() => _accepted = true);
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('ACCEPT PACKAGE', style: TextStyle(fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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

class _AcceptedView extends StatelessWidget {
  final LivePackage package;
  final VoidCallback onStartNavigation;
  const _AcceptedView({required this.package, required this.onStartNavigation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const LiveAppBar(title: 'Package Accepted'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF10B981).withOpacity(0.1)),
                child: const Icon(Icons.check_circle, size: 64, color: Color(0xFF10B981)),
              ),
              const SizedBox(height: 20),
              Text('Package ${package.id} Accepted!', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('Head to the pickup location to collect the package.', style: TextStyle(fontSize: 14, color: AppColors.textSecondary), textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text('First stop: ${package.stops.first.address}', style: TextStyle(fontSize: 13, color: AppColors.textTertiary), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onStartNavigation,
                  icon: const Icon(Icons.navigation, size: 18),
                  label: const Text('START NAVIGATION', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onStartNavigation,
                child: const Text('I\'ll navigate later', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textTertiary),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _VerifyChip extends StatelessWidget {
  final String label;
  final bool active;
  const _VerifyChip({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFD1FAE5) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? const Color(0xFF059669) : AppColors.textTertiary)),
    );
  }
}
