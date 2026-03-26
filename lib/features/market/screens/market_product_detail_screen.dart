/// ═══════════════════════════════════════════════════════════════════════════
/// MARKET MODULE — Screen 4: Product Detail
/// Media gallery, customization, quantity, fulfillment, nutrition, reviews
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../models/market_models.dart';
import '../providers/market_provider.dart';
import '../widgets/market_widgets.dart';

class MarketProductDetailScreen extends StatefulWidget {
  const MarketProductDetailScreen({super.key});

  @override
  State<MarketProductDetailScreen> createState() => _MarketProductDetailScreenState();
}

class _MarketProductDetailScreenState extends State<MarketProductDetailScreen> {
  int _quantity = 1;
  int _currentImage = 0;
  String? _selectedVariant;
  final Set<String> _selectedAddons = {};
  bool _showNutrition = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketProvider>(
      builder: (context, prov, _) {
        final product = prov.selectedProduct;
        if (product == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Product')),
            body: const MarketEmptyState(
              icon: Icons.shopping_bag,
              title: 'No product selected',
              subtitle: 'Go back and select a product',
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: CustomScrollView(
            slivers: [
              // Image gallery
              _buildImageGallery(context, product),
              // Content
              SliverToBoxAdapter(child: _buildContent(context, product, prov)),
            ],
          ),
          // Bottom bar: Add to cart
          bottomNavigationBar: _buildBottomBar(context, product, prov),
        );
      },
    );
  }

  SliverAppBar _buildImageGallery(BuildContext context, MarketProduct product) {
    final images = product.images.isNotEmpty ? product.images : ['placeholder'];
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, size: 20, color: AppColors.textPrimary),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite_border, size: 20, color: AppColors.textPrimary),
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share, size: 20, color: AppColors.textPrimary),
          ),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            PageView.builder(
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _currentImage = i),
              itemBuilder: (context, i) {
                return Container(
                  color: kMarketColorLight,
                  child: const Center(
                    child: Icon(Icons.image, size: 80, color: kMarketColor),
                  ),
                );
              },
            ),
            // Page indicators
            if (images.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (i) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _currentImage ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == _currentImage ? kMarketColor : Colors.grey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ),
            // Discount badge
            if (product.hasDiscount)
              Positioned(
                top: 100,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '-${product.discountPercent.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, MarketProduct product, MarketProvider prov) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name & price
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description ?? '',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PriceTag(
                    price: product.price,
                    comparePrice: product.comparePrice,
                    fontSize: 22,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: product.availability == ProductAvailability.inStock
                          ? kMarketColorLight
                          : product.availability == ProductAvailability.lowStock
                              ? AppColors.warning.withOpacity(0.1)
                              : AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.availability.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: product.availability == ProductAvailability.inStock
                            ? kMarketColorDark
                            : product.availability == ProductAvailability.lowStock
                                ? AppColors.warning
                                : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Rating & reviews
          Row(
            children: [
              RatingStars(rating: product.rating, size: 18),
              const SizedBox(width: 6),
              Text(
                '${product.rating} (${product.ratingCount} reviews)',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Dietary badges
          if (product.dietary.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              children: product.dietary.map((d) {
                return Chip(
                  label: Text(_dietaryLabel(d)),
                  labelStyle: const TextStyle(fontSize: 11),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  side: BorderSide(color: kMarketColor.withOpacity(0.3)),
                  backgroundColor: kMarketColorLight,
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
          const Divider(),
          const SizedBox(height: 12),

          // Variants
          if (product.variants.isNotEmpty) ...[
            const Text('Options', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: product.variants.map((v) {
                final isSelected = _selectedVariant == v.id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedVariant = v.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? kMarketColorLight : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? kMarketColor
                            : AppColors.inputBorder,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          v.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if ((v.priceAdjustment ?? 0) != 0)
                          Text(
                            '${(v.priceAdjustment ?? 0) > 0 ? '+' : ''}\$${(v.priceAdjustment ?? 0).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: kMarketColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Add-ons
          if (product.addons.isNotEmpty) ...[
            const Text('Add-ons', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...product.addons.map((addon) {
              final isSelected = _selectedAddons.contains(addon.id);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected ? kMarketColor : AppColors.inputBorder,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                elevation: 0,
                child: CheckboxListTile(
                  value: isSelected,
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _selectedAddons.add(addon.id);
                      } else {
                        _selectedAddons.remove(addon.id);
                      }
                    });
                  },
                  title: Text(addon.name, style: const TextStyle(fontSize: 14)),
                  subtitle: Text(
                    '+\$${addon.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 12, color: kMarketColor),
                  ),
                  activeColor: kMarketColor,
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          // Quantity
          const Text('Quantity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          QuantitySelector(
            quantity: _quantity,
            min: 1,
            max: 99,
            onChanged: (v) => setState(() => _quantity = v),
          ),
          const SizedBox(height: 16),

          // Nutrition
          if (product.nutritionInfo != null) ...[
            GestureDetector(
              onTap: () => setState(() => _showNutrition = !_showNutrition),
              child: Row(
                children: [
                  const Text('Nutrition Info', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Icon(
                    _showNutrition ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            if (_showNutrition) ...[
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _NutritionRow('Calories', '${product.nutritionInfo!.calories} kcal'),
                      _NutritionRow('Protein', '${product.nutritionInfo!.protein}g'),
                      _NutritionRow('Carbs', '${product.nutritionInfo!.carbs}g'),
                      _NutritionRow('Fat', '${product.nutritionInfo!.fat}g'),
                      _NutritionRow('Fiber', '${product.nutritionInfo!.fiber}g'),
                      _NutritionRow('Sugar', '${product.nutritionInfo!.sugar}g'),
                      _NutritionRow('Sodium', '${product.nutritionInfo!.sodium}mg'),
                      if (product.allergens.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.warning_amber, size: 16, color: AppColors.warning),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Allergens: ${product.allergens.join(", ")}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.warning),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],

          // Merchant info
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kMarketColorLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.store, size: 20, color: kMarketColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prov.selectedMerchant?.name ?? 'Store',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    Text(
                      'Tap to visit store',
                      style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.marketBranch),
              ),
            ],
          ),
          const SizedBox(height: 100),

          // ─── AI Similar Products ───────────────────────────────
          Consumer<AIInsightsNotifier>(
            builder: (ctx, notifier, _) {
              final recs = notifier.recommendations;
              if (recs.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Row(
                      children: const [
                        Icon(Icons.auto_awesome, size: 16, color: Color(0xFF8B5CF6)),
                        SizedBox(width: 6),
                        Text(
                          'AI — You might also like',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: recs.take(6).length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (ctx2, i) {
                        final r = recs[i];
                        final name = r['name']?.toString() ?? r['id']?.toString() ?? 'Product';
                        final score = ((r['score'] as num?)?.toDouble() ?? 0) * 100;
                        return Container(
                          width: 130,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withOpacity(0.06),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF8B5CF6).withOpacity(0.15),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${score.toStringAsFixed(0)}% match',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF8B5CF6),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, MarketProduct product, MarketProvider prov) {
    final addonTotal = product.addons
        .where((a) => _selectedAddons.contains(a.id))
        .fold<double>(0, (sum, a) => sum + a.price);
    final variantMod = _selectedVariant != null
        ? product.variants
            .where((v) => v.id == _selectedVariant)
            .fold<double>(0, (sum, v) => sum + (v.priceAdjustment ?? 0))
        : 0.0;
    final unitPrice = product.price + addonTotal + variantMod;
    final total = unitPrice * _quantity;

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
          // Price summary
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kMarketColorDark),
              ),
              Text(
                '$_quantity × \$${unitPrice.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Add to cart
          Expanded(
            child: ElevatedButton.icon(
              onPressed: product.availability != ProductAvailability.outOfStock
                  ? () {
                      prov.addToCart(product, quantity: _quantity);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} added to cart'),
                          backgroundColor: kMarketColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          action: SnackBarAction(
                            label: 'View Cart',
                            textColor: Colors.white,
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.marketCart),
                          ),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.shopping_cart),
              label: Text(
                product.availability == ProductAvailability.outOfStock
                    ? 'Out of Stock'
                    : 'Add to Cart',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kMarketColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.textTertiary.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _dietaryLabel(DietaryPreference d) {
    switch (d) {
      case DietaryPreference.vegetarian:
        return '🥬 Vegetarian';
      case DietaryPreference.vegan:
        return '🌱 Vegan';
      case DietaryPreference.glutenFree:
        return '🌾 Gluten-free';
      case DietaryPreference.halal:
        return '🕌 Halal';
      case DietaryPreference.kosher:
        return '✡ Kosher';
      case DietaryPreference.organic:
        return '🌿 Organic';
    }
  }
}

class _NutritionRow extends StatelessWidget {
  final String label;
  final String value;

  const _NutritionRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
