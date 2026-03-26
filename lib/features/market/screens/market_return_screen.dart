/// ═══════════════════════════════════════════════════════════════════════════
/// MARKET MODULE — Screen 9: Return Request & Evidence
/// 4 Steps: Order Selection → Evidence Collection → Details → Review
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../models/market_models.dart';
import '../providers/market_provider.dart';
import '../widgets/market_widgets.dart';

class MarketReturnScreen extends StatefulWidget {
  const MarketReturnScreen({super.key});

  @override
  State<MarketReturnScreen> createState() => _MarketReturnScreenState();
}

class _MarketReturnScreenState extends State<MarketReturnScreen> {
  int _step = 0;
  final Set<String> _selectedItems = {};
  ReturnReason _reason = ReturnReason.damaged;
  String _description = '';
  final List<String> _evidence = [];
  RefundMethod _refundMethod = RefundMethod.originalPayment;

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketProvider>(
      builder: (context, prov, _) {
        final order = prov.selectedOrder;
        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Return Request')),
            body: const MarketEmptyState(
              icon: Icons.assignment_return,
              title: 'No order selected',
              subtitle: 'Go back and select an order',
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: const MarketAppBar(title: 'Return Request'),
          body: Column(
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kMarketColor.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kMarketColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI: ${ai.insights.first['title'] ?? ''}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kMarketColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              _buildStepIndicator(),
              Expanded(
                child: IndexedStack(
                  index: _step,
                  children: [
                    _buildItemSelection(order),
                    _buildEvidenceCollection(),
                    _buildDetailsStep(),
                    _buildReviewStep(order),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(context, order, prov),
        );
      },
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Items', 'Evidence', 'Details', 'Review'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stepIdx = i ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                color: stepIdx < _step ? kMarketColor : AppColors.inputBorder,
              ),
            );
          }
          final stepIdx = i ~/ 2;
          final isDone = stepIdx < _step;
          final isCurrent = stepIdx == _step;
          return Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? kMarketColor
                      : isCurrent
                          ? kMarketColorLight
                          : Colors.white,
                  border: Border.all(
                    color: isDone || isCurrent ? kMarketColor : AppColors.inputBorder,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Text(
                          '${stepIdx + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isCurrent ? kMarketColorDark : AppColors.textTertiary,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[stepIdx],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                  color: isDone || isCurrent ? kMarketColorDark : AppColors.textTertiary,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ── Step 1: Item Selection ─────────────────────────────────────
  Widget _buildItemSelection(MarketOrder order) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Select items to return',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose which items from this order you want to return',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        ...order.items.map((item) {
          final isSelected = _selectedItems.contains(item.productId);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedItems.remove(item.productId);
                } else {
                  _selectedItems.add(item.productId);
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? kMarketColor : AppColors.inputBorder,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? kMarketColor : Colors.white,
                      border: Border.all(
                        color: isSelected ? kMarketColor : AppColors.inputBorder,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 48,
                      height: 48,
                      color: kMarketColorLight,
                      child: const Icon(Icons.image, size: 20, color: kMarketColor),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        Text(
                          'Qty: ${item.quantity} • \$${item.total.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Step 2: Evidence Collection ────────────────────────────────
  Widget _buildEvidenceCollection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Provide evidence',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Take photos of the items you wish to return',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        // Photo grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            ..._evidence.map((e) {
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: kMarketColorLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(child: Icon(Icons.image, color: kMarketColor)),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => setState(() => _evidence.remove(e)),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            }),
            // Add button
            GestureDetector(
              onTap: () {
                setState(() => _evidence.add('photo_${_evidence.length}'));
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.inputBorder, style: BorderStyle.solid),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, color: kMarketColor, size: 28),
                    SizedBox(height: 4),
                    Text('Add photo', style: TextStyle(fontSize: 11, color: kMarketColor)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Tips
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: AppColors.info),
                  const SizedBox(width: 8),
                  const Text('Photo Tips', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 8),
              const _TipRow('Show the full item clearly'),
              const _TipRow('Include any damage or defects'),
              const _TipRow('Photograph packaging and labels'),
              const _TipRow('Good lighting improves processing'),
            ],
          ),
        ),
      ],
    );
  }

  // ── Step 3: Details ────────────────────────────────────────────
  Widget _buildDetailsStep() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Return details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        // Reason
        const Text('Reason for return', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        ...ReturnReason.values.map((reason) {
          return RadioListTile<ReturnReason>(
            value: reason,
            groupValue: _reason,
            onChanged: (v) => setState(() => _reason = v!),
            title: Text(_reasonLabel(reason), style: const TextStyle(fontSize: 14)),
            activeColor: kMarketColor,
            contentPadding: EdgeInsets.zero,
          );
        }),
        const SizedBox(height: 16),
        // Description
        const Text('Additional details', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          maxLines: 4,
          onChanged: (v) => _description = v,
          decoration: InputDecoration(
            hintText: 'Describe the issue in detail...',
            hintStyle: TextStyle(fontSize: 13, color: AppColors.textTertiary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kMarketColor, width: 2),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
        const SizedBox(height: 20),
        // Refund method
        const Text('Preferred refund method', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        ...RefundMethod.values.map((method) {
          return RadioListTile<RefundMethod>(
            value: method,
            groupValue: _refundMethod,
            onChanged: (v) => setState(() => _refundMethod = v!),
            title: Text(_refundLabel(method), style: const TextStyle(fontSize: 14)),
            activeColor: kMarketColor,
            contentPadding: EdgeInsets.zero,
          );
        }),
      ],
    );
  }

  // ── Step 4: Review ─────────────────────────────────────────────
  Widget _buildReviewStep(MarketOrder order) {
    final selectedItemsList = order.items
        .where((i) => _selectedItems.contains(i.productId))
        .toList();
    final refundAmount = selectedItemsList.fold<double>(0, (s, i) => s + i.total);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Review your return request',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        MarketSectionCard(
          title: 'Items to Return',
          children: selectedItemsList.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text('${item.quantity}x', style: const TextStyle(fontWeight: FontWeight.w600, color: kMarketColor)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item.name)),
                    Text('\$${item.total.toStringAsFixed(2)}'),
                  ],
                ),
              );
            }).toList(),
        ),
        const SizedBox(height: 12),
        MarketSectionCard(
          title: 'Return Details',
          children: [
              MarketInfoRow(icon: Icons.help_outline, label: 'Reason', value: _reasonLabel(_reason)),
              if (_description.isNotEmpty)
                MarketInfoRow(icon: Icons.description, label: 'Details', value: _description),
              MarketInfoRow(icon: Icons.photo_library, label: 'Evidence', value: '${_evidence.length} photo(s)'),
              MarketInfoRow(icon: Icons.account_balance_wallet, label: 'Refund to', value: _refundLabel(_refundMethod)),
            ],
        ),
        const SizedBox(height: 12),
        // Refund estimate
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kMarketColorLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.payment, color: kMarketColorDark),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Estimated Refund',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              Text(
                '\$${refundAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: kMarketColorDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Policy note
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: 16, color: AppColors.warning),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Returns are reviewed within 24-48 hours. If approved, refund will be processed within 3-5 business days.',
                  style: TextStyle(fontSize: 12, color: AppColors.warning.withOpacity(0.8)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, MarketOrder order, MarketProvider prov) {
    final canProceed = _step == 0
        ? _selectedItems.isNotEmpty
        : _step == 1
            ? _evidence.isNotEmpty
            : true;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          if (_step > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _step--),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kMarketColor,
                  side: const BorderSide(color: kMarketColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Back'),
              ),
            ),
          if (_step > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canProceed
                  ? () {
                      if (_step < 3) {
                        setState(() => _step++);
                      } else {
                        _submitReturn(context, prov);
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _step == 3 ? AppColors.warning : kMarketColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: kMarketColor.withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: Text(
                _step == 3 ? 'Submit Return' : 'Continue',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitReturn(BuildContext context, MarketProvider prov) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.assignment_return, size: 40, color: AppColors.warning),
            ),
            const SizedBox(height: 16),
            const Text(
              'Return Submitted!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Your return request has been submitted.\nWe\'ll review it within 24-48 hours.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kMarketColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  String _reasonLabel(ReturnReason reason) {
    switch (reason) {
      case ReturnReason.damaged:
        return 'Item damaged';
      case ReturnReason.wrongItem:
        return 'Wrong item received';
      case ReturnReason.expired:
        return 'Item expired';
      case ReturnReason.notAsDescribed:
        return 'Not as described';
      case ReturnReason.changedMind:
        return 'Changed my mind';
      case ReturnReason.other:
        return 'Other';
    }
  }

  String _refundLabel(RefundMethod method) {
    switch (method) {
      case RefundMethod.originalPayment:
        return 'Original payment';
      case RefundMethod.storeCredit:
        return 'Store Credit';
      case RefundMethod.qPoints:
        return 'QP Points';
      case RefundMethod.replacement:
        return 'Replacement';
    }
  }
}

class _TipRow extends StatelessWidget {
  final String text;

  const _TipRow(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 14, color: AppColors.info),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
