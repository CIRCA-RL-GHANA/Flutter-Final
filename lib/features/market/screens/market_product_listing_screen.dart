/// ═══════════════════════════════════════════════════════════════════════════
/// MARKET MODULE — Screen 3: Product Listing & Selection
/// Full-screen product catalog with grid/list toggle, sort, categories
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/routes/app_routes.dart';
import '../models/market_models.dart';
import '../providers/market_provider.dart';
import '../widgets/market_widgets.dart';

class MarketProductListingScreen extends StatefulWidget {
  const MarketProductListingScreen({super.key});

  @override
  State<MarketProductListingScreen> createState() => _MarketProductListingScreenState();
}

class _MarketProductListingScreenState extends State<MarketProductListingScreen> {
  String _selectedCategoryId = '';
  String _sortLabel = 'Relevance';

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketProvider>(
      builder: (context, prov, _) {
        final merchant = prov.selectedMerchant;
        final allProducts = merchant != null
            ? prov.getProductsForMerchant(merchant.id)
            : prov.products;
        final products = _selectedCategoryId.isEmpty
            ? allProducts
            : allProducts.where((p) => p.category.name == _selectedCategoryId).toList();

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: MarketAppBar(
            title: merchant?.name ?? 'All Products',
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: AppColors.textPrimary),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.marketSearch),
              ),
              CartPreviewBadge(
                itemCount: prov.cartItemCount,
                onTap: () => Navigator.pushNamed(context, AppRoutes.marketCart),
              ),
            ],
          ),
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

              // Category filter
              SizedBox(
                height: 50,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: prov.productCategories.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return ChoiceChip(
                        label: const Text('All'),
                        selected: _selectedCategoryId.isEmpty,
                        selectedColor: kMarketColorLight,
                        onSelected: (_) => setState(() => _selectedCategoryId = ''),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: _selectedCategoryId.isEmpty ? kMarketColorDark : AppColors.textSecondary,
                          fontWeight: _selectedCategoryId.isEmpty ? FontWeight.w600 : FontWeight.w400,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: BorderSide(color: _selectedCategoryId.isEmpty ? kMarketColor : AppColors.inputBorder),
                      );
                    }
                    final cat = prov.productCategories[i - 1];
                    final isSelected = cat.id == _selectedCategoryId;
                    return ChoiceChip(
                      label: Text(cat.name),
                      selected: isSelected,
                      selectedColor: kMarketColorLight,
                      onSelected: (_) => setState(() => _selectedCategoryId = cat.id),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: isSelected ? kMarketColorDark : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: BorderSide(color: isSelected ? kMarketColor : AppColors.inputBorder),
                    );
                  },
                ),
              ),
              // Sort & view controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      '${products.length} items',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    // Sort dropdown
                    GestureDetector(
                      onTap: () => _showSortSheet(context, prov),
                      child: Row(
                        children: [
                          const Icon(Icons.sort, size: 16, color: kMarketColor),
                          const SizedBox(width: 4),
                          Text(
                            _sortLabel,
                            style: const TextStyle(fontSize: 13, color: kMarketColor, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.marketProductFilters),
                      child: Row(
                        children: [
                          const Icon(Icons.tune, size: 16, color: kMarketColor),
                          const SizedBox(width: 4),
                          const Text('Filter', style: TextStyle(fontSize: 13, color: kMarketColor, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => prov.setProductViewMode(prov.productViewMode == 'grid' ? 'list' : 'grid'),
                      child: Icon(
                        prov.productViewMode == 'grid' ? Icons.view_list : Icons.grid_view,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Products
              Expanded(
                child: products.isEmpty
                    ? const MarketEmptyState(
                        icon: Icons.inventory_2,
                        title: 'No products found',
                        subtitle: 'Try a different category or filter',
                      )
                    : prov.productViewMode == 'grid'
                        ? GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.68,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, i) {
                              return MarketProductCard(
                                product: products[i],
                                onTap: () {
                                  prov.selectProduct(products[i].id);
                                  Navigator.pushNamed(context, AppRoutes.marketProductDetail);
                                },
                                onAddToCart: () => prov.addToCart(products[i]),
                              );
                            },
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: products.length,
                            itemBuilder: (context, i) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: MarketProductCard(
                                  product: products[i],
                                  isListView: true,
                                  onTap: () {
                                    prov.selectProduct(products[i].id);
                                    Navigator.pushNamed(context, AppRoutes.marketProductDetail);
                                  },
                                  onAddToCart: () => prov.addToCart(products[i]),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSortSheet(BuildContext context, MarketProvider prov) {
    final options = [
      ('Relevance', SortOption.recommended),
      ('Price: Low to High', SortOption.priceLow),
      ('Price: High to Low', SortOption.priceHigh),
      ('Rating', SortOption.rating),
      ('Delivery Time', SortOption.deliveryTime),
      ('Distance', SortOption.distance),
      ('Popularity', SortOption.popularity),
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.inputBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sort By',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...options.map((opt) => ListTile(
                    title: Text(opt.$1),
                    trailing: prov.productSort == opt.$2
                        ? const Icon(Icons.check, color: kMarketColor)
                        : null,
                    onTap: () {
                      prov.setProductSort(opt.$2);
                      setState(() => _sortLabel = opt.$1);
                      Navigator.pop(ctx);
                    },
                  )),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
