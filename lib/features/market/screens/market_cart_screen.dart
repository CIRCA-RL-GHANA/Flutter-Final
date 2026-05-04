/// ═══════════════════════════════════════════════════════════════════════════
/// MARKET MODULE — Screen 5: Cart & Bundling
/// AI bundling suggestions, per-item controls, financial summary, promo
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../models/market_models.dart';
import '../providers/market_provider.dart';
import '../widgets/market_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class MarketCartScreen extends StatelessWidget {
  const MarketCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketProvider>(
      builder: (context, prov, _) {
        final items = prov.cartItems;
        final summary = prov.cartSummary;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: MarketAppBar(
            title: 'My Cart',
            actions: [
              if (items.isNotEmpty)
                TextButton(
                  onPressed: () => _showClearDialog(context, prov),
                  child: const Text('Clear', style: TextStyle(color: AppColors.error, fontSize: 13)),
                ),
            ],
          ),
          body: items.isEmpty
              ? const MarketEmptyState(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Your cart is empty',
                  subtitle: 'Start shopping to add items',
                  actionLabel: 'Browse Market',
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Fulfillment toggle
                    _buildFulfillmentToggle(context, prov),
                    const SizedBox(height: 16),
                    // Cart items
                    ...items.map((item) => _CartItemTile(item: item, prov: prov)),
                    const SizedBox(height: 16),
                    // AI bundling suggestion
                    if (prov.bundleSuggestion != null)
                      _buildBundleSuggestion(context, prov.bundleSuggestion!),
                    // Free delivery progress
                    if (summary.freeDeliveryProgress < 1.0) ...[
                      const SizedBox(height: 16),
                      _buildFreeDeliveryProgress(summary),
                    ],
                    // Promo code
                    const SizedBox(height: 16),
                    _buildPromoSection(context, prov),
                    // AI Recommendations strip
                    const SizedBox(height: 16),
                    Consumer<AIInsightsNotifier>(
                      builder: (context, ai, _) {
                        if (ai.recommendations.isEmpty) return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: kMarketColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: kMarketColor.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.auto_awesome, size: 14, color: kMarketColor),
                                  SizedBox(width: 6),
                                  Text('You might also want', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kMarketColor)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: ai.recommendations.take(4).map((r) => Chip(
                                  label: Text(r['name'] as String? ?? '', style: const TextStyle(fontSize: 11)),
                                  backgroundColor: kMarketColor.withOpacity(0.08),
                                  side: BorderSide.none,
                                  padding: EdgeInsets.zero,
                                )).toList(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    // Financial summary
                    const SizedBox(height: 16),
                    _buildFinancialSummary(summary),
                    const SizedBox(height: 100),
                  ],
                ),
          bottomNavigationBar: items.isNotEmpty ? _buildCheckoutBar(context, prov, summary) : null,
        );
      },
    );
  }

  Widget _buildFulfillmentToggle(BuildContext context, MarketProvider prov) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: FulfillmentMethod.values.where((f) => f != FulfillmentMethod.dineIn).map((f) {
            final isSelected = prov.selectedFulfillment == f;
            return Expanded(
              child: GestureDetector(
                onTap: () => prov.setFulfillment(f),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? kMarketColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        f == FulfillmentMethod.delivery
                            ? Icons.delivery_dining
                            : f == FulfillmentMethod.pickup
                                ? Icons.store
                                : Icons.swap_horiz,
                        size: 18,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        f.name[0].toUpperCase() + f.name.substring(1),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBundleSuggestion(BuildContext context, BundleSuggestion bundle) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Bundle Suggestion',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  bundle.description,
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Save ${bundle.timeSavedMinutes} min',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF6D28D9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: const Text('Add', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildFreeDeliveryProgress(CartSummary summary) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.local_shipping, size: 18, color: kMarketColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Add \$${summary.amountToFreeDelivery.toStringAsFixed(2)} for free delivery!',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: summary.freeDeliveryProgress,
                backgroundColor: kMarketColorLight,
                color: kMarketColor,
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoSection(BuildContext context, MarketProvider prov) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: prov.promoCode != null
            ? Row(
                children: [
                  const Icon(Icons.local_offer, size: 18, color: kMarketColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(prov.promoCode!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        const Text('Promo applied', style: TextStyle(fontSize: 12, color: kMarketColor)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: AppColors.error),
                    onPressed: () => prov.applyPromoCode(''),
                  ),
                ],
              )
            : Row(
                children: [
                  const Icon(Icons.local_offer_outlined, size: 18, color: AppColors.textTertiary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Add promo code', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  ),
                  TextButton(
                    onPressed: () => _showPromoDialog(context, prov),
                    child: const Text('Enter', style: TextStyle(color: kMarketColor, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFinancialSummary(CartSummary? summary) {
    if (summary == null) return const SizedBox.shrink();
    return MarketSectionCard(
      title: 'Order Summary',
      children: [
          _SummaryRow('Subtotal', '\$${summary.subtotal.toStringAsFixed(2)}'),
          _SummaryRow('Delivery fee', '\$${summary.deliveryFee.toStringAsFixed(2)}'),
          _SummaryRow('Service fee', '\$${summary.serviceFee.toStringAsFixed(2)}'),
          if (summary.discount > 0)
            _SummaryRow('Discount', '-\$${summary.discount.toStringAsFixed(2)}', isDiscount: true),
          if (summary.tax > 0)
            _SummaryRow('Tax', '\$${summary.tax.toStringAsFixed(2)}'),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              Text(
                '\$${summary.total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kMarketColorDark),
              ),
            ],
          ),
        ],
    );
  }

  Widget _buildCheckoutBar(BuildContext context, MarketProvider prov, CartSummary? summary) {
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
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\$${summary?.total.toStringAsFixed(2) ?? '0.00'}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kMarketColorDark),
              ),
              Text(
                '${prov.cartItemCount} items',
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.marketCheckout),
              style: ElevatedButton.styleFrom(
                backgroundColor: kMarketColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: const Text('Proceed to Checkout', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context, MarketProvider prov) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear cart?'),
        content: const Text('All items will be removed from your cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              prov.clearCart();
              Navigator.pop(ctx);
            },
            child: const Text('Clear', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showPromoDialog(BuildContext context, MarketProvider prov) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Enter Promo Code'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'e.g., SAVE20',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kMarketColor, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                prov.applyPromoCode(controller.text);
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kMarketColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

// ── Cart Item Tile ─────────────────────────────────────────────────
class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final MarketProvider prov;

  const _CartItemTile({required this.item, required this.prov});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 72,
                height: 72,
                color: kMarketColorLight,
                child: const Icon(Icons.image, size: 28, color: kMarketColor),
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.customizationSummary.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.customizationSummary,
                      style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '\$${item.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: kMarketColorDark,
                        ),
                      ),
                      if (item.quantity > 1) ...[
                        const SizedBox(width: 6),
                        Text(
                          '(\$${item.unitPrice.toStringAsFixed(2)} ea)',
                          style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Quantity & delete
            Column(
              children: [
                QuantitySelector(
                  quantity: item.quantity,
                  min: 1,
                  max: 99,
                  onChanged: (v) => prov.updateCartItemQuantity(item.id, v),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => prov.removeFromCart(item.id),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_outline, size: 14, color: AppColors.error),
                      SizedBox(width: 2),
                      Text('Remove', style: TextStyle(fontSize: 11, color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Summary Row ────────────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDiscount;

  const _SummaryRow(this.label, this.value, {this.isDiscount = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDiscount ? kMarketColor : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
