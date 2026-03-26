/// ═══════════════════════════════════════════════════════════════════════════
/// LIVE MODULE — Screen 8: Return Rejection Flow
/// Structured rejection with required reason, evidence review,
/// customer communication template, and appeal info
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../models/live_models.dart';
import '../providers/live_provider.dart';
import '../widgets/live_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class LiveReturnRejectionScreen extends StatefulWidget {
  const LiveReturnRejectionScreen({super.key});

  @override
  State<LiveReturnRejectionScreen> createState() => _LiveReturnRejectionScreenState();
}

class _LiveReturnRejectionScreenState extends State<LiveReturnRejectionScreen> {
  RejectionReason? _selectedReason;
  bool _sendToCustomer = true;
  bool _offerAlternative = true;
  final _customMessageController = TextEditingController();

  @override
  void dispose() {
    _customMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveProvider>(
      builder: (context, prov, _) {
        final ret = prov.selectedReturn ?? prov.returns.first;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: const LiveAppBar(title: 'Reject Return'),
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
              // Warning banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kLiveColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, size: 20, color: kLiveColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Rejecting return for:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kLiveColor)),
                          Text('${ret.itemName} — ₵${ret.itemPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          Text('Customer: ${ret.customerName}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Rejection Reason (Required)
              LiveSectionCard(
                title: 'REJECTION REASON (REQUIRED)',
                icon: Icons.error_outline,
                iconColor: kLiveColor,
                child: Column(
                  children: RejectionReason.values.map((reason) {
                    final selected = reason == _selectedReason;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: RadioListTile<RejectionReason>(
                        value: reason,
                        groupValue: _selectedReason,
                        onChanged: (v) => setState(() => _selectedReason = v),
                        title: Text(
                          _reasonLabel(reason),
                          style: TextStyle(fontSize: 13, fontWeight: selected ? FontWeight.w700 : FontWeight.w400),
                        ),
                        subtitle: Text(_reasonDescription(reason), style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                        activeColor: kLiveColor,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Customer Communication
              LiveSectionCard(
                title: 'CUSTOMER COMMUNICATION',
                icon: Icons.chat,
                iconColor: const Color(0xFF3B82F6),
                child: Column(
                  children: [
                    _RejectionToggle(label: 'Send rejection notification to customer', value: _sendToCustomer, onChanged: (v) => setState(() => _sendToCustomer = v)),
                    _RejectionToggle(label: 'Offer alternative resolution (store credit)', value: _offerAlternative, onChanged: (v) => setState(() => _offerAlternative = v)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _customMessageController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Add a custom message to the customer...',
                        filled: true,
                        fillColor: AppColors.backgroundLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),

              // Appeal Information
              LiveSectionCard(
                title: 'APPEAL INFORMATION',
                icon: Icons.info,
                iconColor: const Color(0xFF8B5CF6),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Customer Appeal Rights', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6B21A8))),
                      const SizedBox(height: 4),
                      Text('• Customer can appeal within 7 days', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Text('• Appeal goes to senior response officer', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Text('• Customer will be notified of their options', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
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
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('CANCEL'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _selectedReason == null
                        ? null
                        : () {
                            HapticFeedback.heavyImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('❌ Return rejected. Customer notified.'), backgroundColor: kLiveColor),
                            );
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('CONFIRM REJECTION', style: TextStyle(fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedReason == null ? const Color(0xFFE5E7EB) : kLiveColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  String _reasonLabel(RejectionReason reason) {
    switch (reason) {
      case RejectionReason.returnPeriodExpired:
        return 'Outside return window';
      case RejectionReason.damageAfterDelivery:
        return 'Item damaged by customer';
      case RejectionReason.missingPackaging:
        return 'Missing parts or accessories';
      case RejectionReason.signsOfMisuse:
        return 'Item has been used';
      case RejectionReason.itemNotAsDescribed:
        return 'Customer sent wrong item';
      case RejectionReason.nonReturnable:
        return 'Return policy violation';
      case RejectionReason.serialMismatch:
        return 'Serial number mismatch';
      case RejectionReason.insufficientEvidence:
        return 'Insufficient evidence';
      case RejectionReason.customizedProduct:
        return 'Customized product';
      case RejectionReason.other:
        return 'Other reason';
    }
  }

  String _reasonDescription(RejectionReason reason) {
    switch (reason) {
      case RejectionReason.returnPeriodExpired:
        return 'Return requested after the allowed return period';
      case RejectionReason.damageAfterDelivery:
        return 'Evidence shows damage not present at delivery';
      case RejectionReason.missingPackaging:
        return 'Original packaging or accessories not included';
      case RejectionReason.signsOfMisuse:
        return 'Signs of use beyond initial inspection';
      case RejectionReason.itemNotAsDescribed:
        return 'Returned item doesn\'t match the order';
      case RejectionReason.nonReturnable:
        return 'Item category not eligible for returns';
      case RejectionReason.serialMismatch:
        return 'Serial number does not match original product';
      case RejectionReason.insufficientEvidence:
        return 'Not enough evidence to support the return claim';
      case RejectionReason.customizedProduct:
        return 'Customized products cannot be returned';
      case RejectionReason.other:
        return 'Specify in the custom message field';
    }
  }
}

class _RejectionToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _RejectionToggle({required this.label, required this.value, required this.onChanged});

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
