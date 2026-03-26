/// ═══════════════════════════════════════════════════════════════════════════
/// LIVE MODULE — Screen 5: Package Creation & Bundling
/// Multi-step wizard: Package config, bundle assistant, route preview,
/// security/verification settings, confirmation
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../models/live_models.dart';
import '../providers/live_provider.dart';
import '../widgets/live_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class LivePackageCreationScreen extends StatefulWidget {
  const LivePackageCreationScreen({super.key});

  @override
  State<LivePackageCreationScreen> createState() => _LivePackageCreationScreenState();
}

class _LivePackageCreationScreenState extends State<LivePackageCreationScreen> {
  int _step = 0;
  PackageType _selectedType = PackageType.standard;
  bool _requireSignature = true;
  bool _requirePhoto = true;
  bool _pinVerification = true;
  bool _biometricVerification = false;
  bool _coldChain = false;
  bool _fragile = false;
  final List<String> _selectedOrderIds = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveProvider>(
      builder: (context, prov, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: LiveAppBar(
            title: _step == 0 ? 'Create New Package' : _step == 1 ? 'Security & Verification' : 'Confirm Package',
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: kLiveColor)),
              ),
            ],
          ),
          body: Column(
            children: [
              // Progress indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Row(
                  children: List.generate(3, (i) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: i <= _step ? kLiveColor : const Color(0xFFE5E7EB),
                      ),
                    ),
                  )),
                ),
              ),

              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kLiveColor.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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

              // Step content
              Expanded(
                child: IndexedStack(
                  index: _step,
                  children: [
                    _PackageConfigStep(
                      selectedType: _selectedType,
                      selectedOrderIds: _selectedOrderIds,
                      orders: prov.orders,
                      onTypeChanged: (t) => setState(() => _selectedType = t),
                      onOrderToggled: (id) => setState(() {
                        if (_selectedOrderIds.contains(id)) {
                          _selectedOrderIds.remove(id);
                        } else {
                          _selectedOrderIds.add(id);
                        }
                      }),
                      coldChain: _coldChain,
                      fragile: _fragile,
                      onColdChainChanged: (v) => setState(() => _coldChain = v),
                      onFragileChanged: (v) => setState(() => _fragile = v),
                    ),
                    _SecurityStep(
                      requireSignature: _requireSignature,
                      requirePhoto: _requirePhoto,
                      pinVerification: _pinVerification,
                      biometricVerification: _biometricVerification,
                      onSignatureChanged: (v) => setState(() => _requireSignature = v),
                      onPhotoChanged: (v) => setState(() => _requirePhoto = v),
                      onPinChanged: (v) => setState(() => _pinVerification = v),
                      onBiometricChanged: (v) => setState(() => _biometricVerification = v),
                    ),
                    _ConfirmationStep(
                      selectedType: _selectedType,
                      selectedOrderIds: _selectedOrderIds,
                      orders: prov.orders,
                    ),
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
            child: Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _step--),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text('BACK'),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      if (_step < 2) {
                        setState(() => _step++);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: const Text('✅ Package created successfully!'), backgroundColor: const Color(0xFF10B981)),
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _step == 2 ? const Color(0xFF10B981) : kLiveColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _step == 0 ? 'CONTINUE TO SECURITY' : _step == 1 ? 'REVIEW PACKAGE' : '✅ CREATE PACKAGE',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
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

// ─── Step 1: Package Configuration ─────────────────────────────────────────────

class _PackageConfigStep extends StatelessWidget {
  final PackageType selectedType;
  final List<String> selectedOrderIds;
  final List<LiveOrder> orders;
  final ValueChanged<PackageType> onTypeChanged;
  final ValueChanged<String> onOrderToggled;
  final bool coldChain;
  final bool fragile;
  final ValueChanged<bool> onColdChainChanged;
  final ValueChanged<bool> onFragileChanged;

  const _PackageConfigStep({
    required this.selectedType,
    required this.selectedOrderIds,
    required this.orders,
    required this.onTypeChanged,
    required this.onOrderToggled,
    required this.coldChain,
    required this.fragile,
    required this.onColdChainChanged,
    required this.onFragileChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Package type selector
        LiveSectionCard(
          title: 'PACKAGE TYPE',
          icon: Icons.category,
          iconColor: const Color(0xFF8B5CF6),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PackageType.values.map((t) {
              final selected = t == selectedType;
              return ChoiceChip(
                selected: selected,
                label: Text(t.name.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.textSecondary)),
                selectedColor: kLiveColor,
                backgroundColor: const Color(0xFFF3F4F6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                onSelected: (_) => onTypeChanged(t),
              );
            }).toList(),
          ),
        ),

        // Bundle Assistant
        LiveSectionCard(
          title: '🧩 BUNDLE ASSISTANT',
          icon: Icons.auto_awesome,
          iconColor: const Color(0xFFF59E0B),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, size: 16, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 8),
                    Expanded(child: Text('AI suggests bundling ${orders.length > 1 ? orders.length - 1 : 0} nearby orders for optimized routing', style: const TextStyle(fontSize: 12, color: Color(0xFF92400E)))),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text('SELECT ORDERS TO BUNDLE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              ...orders.map((o) => _OrderBundleItem(
                order: o,
                selected: selectedOrderIds.contains(o.id),
                onToggle: () => onOrderToggled(o.id),
              )),
            ],
          ),
        ),

        // Special Handling
        LiveSectionCard(
          title: 'SPECIAL HANDLING',
          icon: Icons.warning_amber,
          iconColor: const Color(0xFFF97316),
          child: Column(
            children: [
              _PackageToggle(label: '❄️ Cold chain required', value: coldChain, onChanged: onColdChainChanged),
              _PackageToggle(label: '📦 Fragile — handle with care', value: fragile, onChanged: onFragileChanged),
            ],
          ),
        ),

        // Optimized Route Preview
        LiveSectionCard(
          title: 'OPTIMIZED ROUTE PREVIEW',
          icon: Icons.route,
          iconColor: const Color(0xFF3B82F6),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.route, size: 32, color: AppColors.textTertiary),
                  const SizedBox(height: 4),
                  Text('${selectedOrderIds.length} stop${selectedOrderIds.length == 1 ? '' : 's'} • Est. 45 min', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Step 2: Security & Verification ──────────────────────────────────────────

class _SecurityStep extends StatelessWidget {
  final bool requireSignature;
  final bool requirePhoto;
  final bool pinVerification;
  final bool biometricVerification;
  final ValueChanged<bool> onSignatureChanged;
  final ValueChanged<bool> onPhotoChanged;
  final ValueChanged<bool> onPinChanged;
  final ValueChanged<bool> onBiometricChanged;

  const _SecurityStep({
    required this.requireSignature,
    required this.requirePhoto,
    required this.pinVerification,
    required this.biometricVerification,
    required this.onSignatureChanged,
    required this.onPhotoChanged,
    required this.onPinChanged,
    required this.onBiometricChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        LiveSectionCard(
          title: 'DELIVERY VERIFICATION',
          icon: Icons.verified_user,
          iconColor: const Color(0xFF10B981),
          child: Column(
            children: [
              _PackageToggle(label: '✍️ Require digital signature', value: requireSignature, onChanged: onSignatureChanged),
              _PackageToggle(label: '📸 Require proof-of-delivery photo', value: requirePhoto, onChanged: onPhotoChanged),
              _PackageToggle(label: '🔢 PIN verification', value: pinVerification, onChanged: onPinChanged),
              _PackageToggle(label: '🔐 Biometric verification', value: biometricVerification, onChanged: onBiometricChanged),
            ],
          ),
        ),

        LiveSectionCard(
          title: 'EVIDENCE COLLECTION',
          icon: Icons.collections,
          iconColor: const Color(0xFF8B5CF6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, size: 16, color: Color(0xFF8B5CF6)),
                    SizedBox(width: 8),
                    Expanded(child: Text('Evidence is auto-collected on delivery and stored for 90 days', style: TextStyle(fontSize: 12, color: Color(0xFF6B21A8)))),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _EvidenceItem(icon: Icons.camera_alt, label: 'Package photo at pickup'),
              _EvidenceItem(icon: Icons.camera_alt, label: 'Package photo at delivery'),
              _EvidenceItem(icon: Icons.location_on, label: 'GPS coordinates at each stop'),
              _EvidenceItem(icon: Icons.timer, label: 'Timestamp logging'),
            ],
          ),
        ),

        LiveSectionCard(
          title: 'INSURANCE & VALUE PROTECTION',
          icon: Icons.shield,
          iconColor: const Color(0xFFF59E0B),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.security, size: 14, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 6),
                    Text('Standard coverage up to ₵5,000', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF92400E))),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text('For higher value orders, premium coverage is automatically applied.', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Step 3: Confirmation ────────────────────────────────────────────────────

class _ConfirmationStep extends StatelessWidget {
  final PackageType selectedType;
  final List<String> selectedOrderIds;
  final List<LiveOrder> orders;

  const _ConfirmationStep({
    required this.selectedType,
    required this.selectedOrderIds,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    final bundledOrders = orders.where((o) => selectedOrderIds.contains(o.id)).toList();
    final totalValue = bundledOrders.fold<double>(0, (s, o) => s + o.total);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(shape: BoxShape.circle, color: kLiveColor.withOpacity(0.1)),
                child: const Icon(Icons.inventory_2, size: 36, color: kLiveColor),
              ),
              const SizedBox(height: 12),
              const Text('REVIEW YOUR PACKAGE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        LiveSectionCard(
          title: 'PACKAGE SUMMARY',
          icon: Icons.summarize,
          iconColor: const Color(0xFF3B82F6),
          child: Column(
            children: [
              _SummaryRow(label: 'Package type', value: selectedType.name.toUpperCase()),
              _SummaryRow(label: 'Orders bundled', value: '${bundledOrders.length}'),
              _SummaryRow(label: 'Total stops', value: '${bundledOrders.length + 1}'),
              _SummaryRow(label: 'Total value', value: '₵${totalValue.toStringAsFixed(2)}'),
              const _SummaryRow(label: 'Est. distance', value: '8.3 km'),
              const _SummaryRow(label: 'Est. duration', value: '45 min'),
            ],
          ),
        ),

        if (bundledOrders.isNotEmpty)
          LiveSectionCard(
            title: 'INCLUDED ORDERS',
            icon: Icons.shopping_bag,
            iconColor: kLiveColor,
            child: Column(
              children: bundledOrders.map((o) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: kLiveColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text('#${o.id}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kLiveColor)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(o.customerName, style: const TextStyle(fontSize: 13))),
                    Text('₵${o.total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              )).toList(),
            ),
          ),

        LiveSectionCard(
          title: 'VERIFICATION REQUIREMENTS',
          icon: Icons.verified,
          iconColor: const Color(0xFF10B981),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EvidenceItem(icon: Icons.check_circle, label: 'Digital signature required'),
              _EvidenceItem(icon: Icons.check_circle, label: 'Proof-of-delivery photo'),
              _EvidenceItem(icon: Icons.check_circle, label: 'PIN verification'),
              _EvidenceItem(icon: Icons.check_circle, label: 'GPS tracking enabled'),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Shared Helpers ──────────────────────────────────────────────────────────

class _OrderBundleItem extends StatelessWidget {
  final LiveOrder order;
  final bool selected;
  final VoidCallback onToggle;
  const _OrderBundleItem({required this.order, required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? kLiveColor.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? kLiveColor : const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Icon(selected ? Icons.check_box : Icons.check_box_outline_blank, size: 20, color: selected ? kLiveColor : AppColors.textTertiary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('#${order.id} — ${order.customerName}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text('${order.items.length} items • ₵${order.total.toStringAsFixed(0)}', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                  ],
                ),
              ),
              if (order.priority == OrderPriority.urgent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: kLiveColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: const Text('URGENT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: kLiveColor)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PackageToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _PackageToggle({required this.label, required this.value, required this.onChanged});

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

class _EvidenceItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _EvidenceItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF10B981)),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

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
