/// ═══════════════════════════════════════════════════════════════════════════
/// MARKET MODULE — Screen 6: Order Summary & Payment
/// Progress indicator, payment method selection, order review, terms
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../models/market_models.dart';
import '../providers/market_provider.dart';
import '../widgets/market_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class MarketCheckoutScreen extends StatefulWidget {
  const MarketCheckoutScreen({super.key});

  @override
  State<MarketCheckoutScreen> createState() => _MarketCheckoutScreenState();
}

class _MarketCheckoutScreenState extends State<MarketCheckoutScreen> {
  int _currentStep = 0;
  bool _agreedToTerms = false;
  String? _selectedPaymentId;
  String _deliveryNote = '';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketProvider>(
      builder: (context, prov, _) {
        final summary = prov.cartSummary;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: const MarketAppBar(title: 'Checkout'),
          body: Column(
            children: [
              // Progress steps
              _buildProgressBar(),
              // Step content
              Expanded(
                child: IndexedStack(
                  index: _currentStep,
                  children: [
                    _buildReviewStep(prov, summary),
                    _buildPaymentStep(prov),
                    _buildConfirmStep(prov, summary),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(context, prov, summary),
        );
      },
    );
  }

  Widget _buildProgressBar() {
    final steps = ['Review', 'Payment', 'Confirm'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector
            final stepIndex = i ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                color: stepIndex < _currentStep ? kMarketColor : AppColors.inputBorder,
              ),
            );
          }
          final stepIndex = i ~/ 2;
          final isActive = stepIndex <= _currentStep;
          final isCurrent = stepIndex == _currentStep;
          return Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? kMarketColor : Colors.white,
                  border: Border.all(
                    color: isActive ? kMarketColor : AppColors.inputBorder,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: stepIndex < _currentStep
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Text(
                          '${stepIndex + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isCurrent ? Colors.white : AppColors.textTertiary,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[stepIndex],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                  color: isActive ? kMarketColorDark : AppColors.textTertiary,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ── Step 1: Review ───────────────────────────────────────────────
  Widget _buildReviewStep(MarketProvider prov, CartSummary? summary) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Delivery info
        MarketSectionCard(
          title: 'Delivery Details',
          children: [
              MarketInfoRow(
                icon: Icons.local_shipping,
                label: 'Method',
                value: prov.selectedFulfillment.name,
              ),
              MarketInfoRow(
                icon: Icons.location_on,
                label: 'Address',
                value: 'The PG Campus, Block A',
              ),
              MarketInfoRow(
                icon: Icons.access_time,
                label: 'Estimated',
                value: '25-35 min',
              ),
            ],
        ),
        const SizedBox(height: 12),
        // Items
        MarketSectionCard(
          title: 'Items (${prov.cartItemCount})',
          children: prov.cartItems.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: kMarketColorLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.image, size: 18, color: kMarketColor),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'x${item.quantity}',
                            style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${item.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }).toList(),
        ),
        const SizedBox(height: 12),
        // Delivery note
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Delivery Note', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  maxLines: 2,
                  onChanged: (v) => _deliveryNote = v,
                  decoration: InputDecoration(
                    hintText: 'Special instructions for delivery...',
                    hintStyle: TextStyle(fontSize: 13, color: AppColors.textTertiary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: kMarketColor, width: 2),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  // ── Step 2: Payment ──────────────────────────────────────────────
  Widget _buildPaymentStep(MarketProvider prov) {
    _selectedPaymentId ??= prov.defaultPaymentMethod.id;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // AI security notice
        Consumer<AIInsightsNotifier>(
          builder: (context, ai, _) {
            if (ai.insights.isEmpty) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_outlined, size: 16, color: Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'AI fraud protection active — your payment is being monitored',
                      style: TextStyle(fontSize: 12, color: Color(0xFF10B981), fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const Text(
          'Select Payment Method',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        ...prov.paymentMethods.map((method) {
          final isSelected = _selectedPaymentId == method.id;
          return GestureDetector(
            onTap: () => setState(() => _selectedPaymentId = method.id),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
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
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected ? kMarketColorLight : AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(method.icon, color: isSelected ? kMarketColor : AppColors.textSecondary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method.label,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        Text(
                          method.type == PaymentMethodType.qPoints
                              ? '${method.balance?.toStringAsFixed(0) ?? "0"} QP available'
                              : method.type == PaymentMethodType.tabCredit
                                  ? '\$${method.balance?.toStringAsFixed(2) ?? "0.00"} available'
                                  : method.last4 ?? '',
                          style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: kMarketColor)
                  else
                    Icon(Icons.radio_button_unchecked, color: AppColors.inputBorder),
                  if (method.isDefault) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: kMarketColorLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'DEFAULT',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: kMarketColorDark),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        // Add new payment
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Payment Method'),
          style: OutlinedButton.styleFrom(
            foregroundColor: kMarketColor,
            side: const BorderSide(color: kMarketColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  // ── Step 3: Confirm ──────────────────────────────────────────────
  Widget _buildConfirmStep(MarketProvider prov, CartSummary? summary) {
    final selectedPayment = prov.paymentMethods
        .where((m) => m.id == _selectedPaymentId)
        .firstOrNull;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary
        MarketSectionCard(
          title: 'Order Summary',
          children: [
              MarketInfoRow(
                icon: Icons.shopping_bag,
                label: 'Items',
                value: '${prov.cartItemCount} items',
              ),
              MarketInfoRow(
                icon: Icons.local_shipping,
                label: 'Delivery',
                value: prov.selectedFulfillment.name,
              ),
              MarketInfoRow(
                icon: Icons.payment,
                label: 'Payment',
                value: selectedPayment?.label ?? 'Not selected',
              ),
              if (_deliveryNote.isNotEmpty)
                MarketInfoRow(
                  icon: Icons.note,
                  label: 'Note',
                  value: _deliveryNote,
                ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  Text(
                    '\$${summary?.total.toStringAsFixed(2) ?? "0.00"}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kMarketColorDark),
                  ),
                ],
              ),
            ],
        ),
        const SizedBox(height: 16),
        // Terms
        CheckboxListTile(
          value: _agreedToTerms,
          onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: kMarketColor,
          title: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms of Service',
                  style: TextStyle(color: kMarketColor, fontWeight: FontWeight.w600),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Refund Policy',
                  style: TextStyle(color: kMarketColor, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, MarketProvider prov, CartSummary? summary) {
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
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kMarketColor,
                  side: const BorderSide(color: kMarketColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _canProceed()
                  ? () {
                      if (_currentStep < 2) {
                        setState(() => _currentStep++);
                      } else {
                        _placeOrder(context, prov);
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: kMarketColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: kMarketColor.withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      _currentStep == 2 ? 'Place Order' : 'Continue',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    if (_isProcessing) return false;
    if (_currentStep == 1 && _selectedPaymentId == null) return false;
    if (_currentStep == 2 && !_agreedToTerms) return false;
    return true;
  }

  Future<void> _placeOrder(BuildContext context, MarketProvider prov) async {
    setState(() => _isProcessing = true);
    // Simulate processing
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isProcessing = false);

    if (!context.mounted) return;

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
              decoration: const BoxDecoration(
                color: kMarketColorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 40, color: kMarketColor),
            ),
            const SizedBox(height: 16),
            const Text(
              'Order Placed!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Your order has been placed successfully.\nYou can track it in My Transactions.',
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
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.marketTransactions,
                  (route) => route.settings.name == AppRoutes.marketHub,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kMarketColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Track Order'),
            ),
          ),
        ],
      ),
    );
  }
}
