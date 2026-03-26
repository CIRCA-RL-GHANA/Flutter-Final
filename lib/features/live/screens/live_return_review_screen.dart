/// ═══════════════════════════════════════════════════════════════════════════
/// LIVE MODULE — Screen 7: Return Review Interface
/// Detailed return review with evidence gallery, customer history,
/// adjudication options, and resolution workflow
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

class LiveReturnReviewScreen extends StatefulWidget {
  const LiveReturnReviewScreen({super.key});

  @override
  State<LiveReturnReviewScreen> createState() => _LiveReturnReviewScreenState();
}

class _LiveReturnReviewScreenState extends State<LiveReturnReviewScreen> {
  AdjudicationOption _selectedOption = AdjudicationOption.approve;
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
            title: 'Return Review #${ret.id}',
            actions: [
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
              // Return status banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ret.status == LiveReturnStatus.approved
                      ? const Color(0xFFD1FAE5)
                      : ret.status == LiveReturnStatus.rejected
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      ret.status == LiveReturnStatus.approved ? Icons.check_circle : ret.status == LiveReturnStatus.rejected ? Icons.cancel : Icons.pending,
                      size: 20,
                      color: ret.status == LiveReturnStatus.approved ? const Color(0xFF059669) : ret.status == LiveReturnStatus.rejected ? kLiveColor : const Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 8),
                    Text(ret.status.name.toUpperCase(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ret.status == LiveReturnStatus.approved ? const Color(0xFF059669) : ret.status == LiveReturnStatus.rejected ? kLiveColor : const Color(0xFFF59E0B))),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Customer Information
              LiveSectionCard(
                title: 'CUSTOMER',
                icon: Icons.person,
                iconColor: const Color(0xFF3B82F6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ret.customerName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 4),
                        Text('${ret.customerRating} rating', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(width: 12),
                        Text('${ret.customerTotalOrders} orders', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(width: 12),
                        Text('${ret.customerReturnCount} returns (${(ret.customerReturnCount / ret.customerTotalOrders * 100).toStringAsFixed(0)}%)', style: TextStyle(fontSize: 12, color: (ret.customerReturnCount / ret.customerTotalOrders * 100) > 15 ? kLiveColor : AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),

              // Item Details
              LiveSectionCard(
                title: 'RETURN ITEM',
                icon: Icons.inventory_2,
                iconColor: kLiveColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ret.itemName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('Order #${ret.originalOrderId}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(width: 12),
                        Text('₵${ret.itemPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kLiveColor)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('REASON', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
                          const SizedBox(height: 2),
                          Text(ret.reason, style: const TextStyle(fontSize: 13)),
                          if ((ret.reasonDetail ?? '').isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text('CUSTOMER NOTES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
                            const SizedBox(height: 2),
                            Text('"${ret.reasonDetail ?? ''}"', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Evidence Gallery
              LiveSectionCard(
                title: 'EVIDENCE (${<String>[].length} items)',
                icon: Icons.photo_library,
                iconColor: const Color(0xFF8B5CF6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (ret.hasVideo)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(6)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.videocam, size: 14, color: Color(0xFF8B5CF6)),
                            SizedBox(width: 4),
                            Text('Video evidence included', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF8B5CF6))),
                          ],
                        ),
                      ),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: <String>[].length,
                        itemBuilder: (context, i) => Container(
                          width: 80,
                          margin: EdgeInsets.only(right: i < <String>[].length - 1 ? 8 : 0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(child: Icon(Icons.image, color: AppColors.textTertiary)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // AI Analysis
              LiveSectionCard(
                title: '🤖 AI ANALYSIS',
                icon: Icons.psychology,
                iconColor: const Color(0xFF10B981),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('AI Recommendation: APPROVE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF059669))),
                          const SizedBox(height: 4),
                          Text('Confidence: 87% • Evidence quality: Good • Customer history: Low risk', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Adjudication Options
              LiveSectionCard(
                title: 'RESOLUTION',
                icon: Icons.gavel,
                iconColor: const Color(0xFFF59E0B),
                child: Column(
                  children: AdjudicationOption.values.map((opt) {
                    final selected = opt == _selectedOption;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: RadioListTile<AdjudicationOption>(
                        value: opt,
                        groupValue: _selectedOption,
                        onChanged: (v) => setState(() => _selectedOption = v!),
                        title: Text(
                          opt == AdjudicationOption.approve ? 'Full Refund' : opt == AdjudicationOption.partialApprove ? 'Partial Refund' : opt == AdjudicationOption.offerStoreCredit ? 'Store Credit' : opt == AdjudicationOption.offerReplacement ? 'Replacement' : opt == AdjudicationOption.reject ? 'Reject' : opt.name,
                          style: TextStyle(fontSize: 13, fontWeight: selected ? FontWeight.w700 : FontWeight.w400),
                        ),
                        activeColor: kLiveColor,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Internal Notes
              LiveSectionCard(
                title: 'INTERNAL NOTES',
                icon: Icons.note,
                iconColor: AppColors.textSecondary,
                child: TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Add notes for this review...',
                    filled: true,
                    fillColor: AppColors.backgroundLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                  style: const TextStyle(fontSize: 14),
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
                      Navigator.pushNamed(context, AppRoutes.liveReturnRejection);
                    },
                    style: OutlinedButton.styleFrom(foregroundColor: kLiveColor, padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('REJECT', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.textSecondary, padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('ESCALATE', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Return approved!'), backgroundColor: Color(0xFF10B981)),
                      );
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('APPROVE', style: TextStyle(fontWeight: FontWeight.w700)),
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
