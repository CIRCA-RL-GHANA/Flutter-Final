/// ═══════════════════════════════════════════════════════════════════════════
/// LIVE MODULE — Screen 14: Return Pickup Verification
/// Driver verifies return pickup: item inspection, photo evidence,
/// condition assessment, and pickup confirmation
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/live_provider.dart';
import '../widgets/live_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class LiveReturnPickupScreen extends StatefulWidget {
  const LiveReturnPickupScreen({super.key});

  @override
  State<LiveReturnPickupScreen> createState() => _LiveReturnPickupScreenState();
}

class _LiveReturnPickupScreenState extends State<LiveReturnPickupScreen> {
  int _step = 0; // 0=Inspect, 1=Photo, 2=Confirm
  String _condition = 'good';
  bool _allPartsPresent = true;
  bool _originalPackaging = true;
  bool _photoTaken = false;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveProvider>(
      builder: (context, prov, _) {
        final ret = prov.selectedReturn ?? prov.returns.first;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: LiveAppBar(
            title: _step == 0 ? 'Inspect Return Item' : _step == 1 ? 'Capture Evidence' : 'Confirm Pickup',
          ),
          body: Column(
            children: [
              // Progress
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

              Expanded(
                child: IndexedStack(
                  index: _step,
                  children: [
                    // Step 0: Inspection
                    ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Return item info
                        LiveSectionCard(
                          title: 'RETURN ITEM',
                          icon: Icons.assignment_return,
                          iconColor: kLiveColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ret.itemName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text('Customer: ${ret.customerName}', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              Text('Order #${ret.originalOrderId}', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                              Text('Reason: ${ret.reason}', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                            ],
                          ),
                        ),

                        // Condition assessment
                        LiveSectionCard(
                          title: 'CONDITION ASSESSMENT',
                          icon: Icons.assessment,
                          iconColor: const Color(0xFF3B82F6),
                          child: Column(
                            children: [
                              _ConditionOption(label: '✅ Good — Matches description', value: 'good', groupValue: _condition, onChanged: (v) => setState(() => _condition = v!)),
                              _ConditionOption(label: '⚠️ Fair — Minor discrepancies', value: 'fair', groupValue: _condition, onChanged: (v) => setState(() => _condition = v!)),
                              _ConditionOption(label: '❌ Poor — Significant damage', value: 'poor', groupValue: _condition, onChanged: (v) => setState(() => _condition = v!)),
                            ],
                          ),
                        ),

                        // Checklist
                        LiveSectionCard(
                          title: 'CHECKLIST',
                          icon: Icons.checklist,
                          iconColor: const Color(0xFF10B981),
                          child: Column(
                            children: [
                              _CheckItem(label: 'All parts and accessories present', value: _allPartsPresent, onChanged: (v) => setState(() => _allPartsPresent = v)),
                              _CheckItem(label: 'Original packaging included', value: _originalPackaging, onChanged: (v) => setState(() => _originalPackaging = v)),
                            ],
                          ),
                        ),

                        // Notes
                        LiveSectionCard(
                          title: 'DRIVER NOTES',
                          icon: Icons.note,
                          iconColor: AppColors.textSecondary,
                          child: TextField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Add notes about item condition...',
                              filled: true,
                              fillColor: AppColors.backgroundLight,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            ),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),

                    // Step 1: Photo evidence
                    ListView(
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
                                  color: _photoTaken ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFF3B82F6).withOpacity(0.1),
                                ),
                                child: Icon(
                                  _photoTaken ? Icons.check_circle : Icons.camera_alt,
                                  size: 48,
                                  color: _photoTaken ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(_photoTaken ? 'PHOTO CAPTURED ✅' : 'CAPTURE RETURN ITEM PHOTOS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _photoTaken ? const Color(0xFF10B981) : AppColors.textPrimary)),
                              const SizedBox(height: 4),
                              Text('Take clear photos of the return item for evidence', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (!_photoTaken)
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
                            ),
                            child: Center(child: Icon(Icons.camera_alt, size: 48, color: AppColors.textTertiary)),
                          ),
                        if (!_photoTaken) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => setState(() => _photoTaken = true),
                              icon: const Icon(Icons.camera_alt, size: 18),
                              label: const Text('CAPTURE PHOTO', style: TextStyle(fontWeight: FontWeight.w700)),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            ),
                          ),
                        ] else
                          Container(
                            height: 200,
                            decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(14)),
                            child: const Center(child: Icon(Icons.check_circle, size: 64, color: Color(0xFF10B981))),
                          ),
                      ],
                    ),

                    // Step 2: Confirmation
                    ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(shape: BoxShape.circle, color: kLiveColor.withOpacity(0.1)),
                                child: const Icon(Icons.assignment_return, size: 36, color: kLiveColor),
                              ),
                              const SizedBox(height: 12),
                              const Text('CONFIRM RETURN PICKUP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        LiveSectionCard(
                          title: 'PICKUP SUMMARY',
                          icon: Icons.summarize,
                          iconColor: const Color(0xFF3B82F6),
                          child: Column(
                            children: [
                              _SummaryRow(label: 'Item', value: ret.itemName),
                              _SummaryRow(label: 'Customer', value: ret.customerName),
                              _SummaryRow(label: 'Condition', value: _condition.toUpperCase()),
                              _SummaryRow(label: 'All parts present', value: _allPartsPresent ? 'Yes' : 'No'),
                              _SummaryRow(label: 'Original packaging', value: _originalPackaging ? 'Yes' : 'No'),
                              _SummaryRow(label: 'Photo evidence', value: _photoTaken ? 'Captured' : 'Missing'),
                            ],
                          ),
                        ),
                      ],
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
                        HapticFeedback.heavyImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✅ Return pickup confirmed!'), backgroundColor: Color(0xFF10B981)),
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
                      _step == 0 ? 'NEXT: PHOTO EVIDENCE' : _step == 1 ? 'NEXT: CONFIRM' : '✅ CONFIRM PICKUP',
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

class _ConditionOption extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;
  const _ConditionOption({required this.label, required this.value, required this.groupValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: Text(label, style: TextStyle(fontSize: 13, fontWeight: value == groupValue ? FontWeight.w700 : FontWeight.w400)),
      activeColor: kLiveColor,
      dense: true,
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _CheckItem({required this.label, required this.value, required this.onChanged});

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
          Flexible(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
