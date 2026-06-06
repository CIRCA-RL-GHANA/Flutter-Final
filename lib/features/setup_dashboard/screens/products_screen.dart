/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
/// SD1.1: PRODUCTS — Inventory Management
/// Grid/list view, search, filter by category/stock, product detail
/// RBAC: Admin(full), BM(branch), Monitor/BrMon(view), RO/BRO(view)
/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive_empty_state.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../prompt/providers/context_provider.dart';
import '../models/setup_dashboard_models.dart';
import '../providers/setup_dashboard_provider.dart';
import '../widgets/shared_widgets.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        final products = setupProv.filteredProducts;

        return SetupRbacGate(
          cardId: 'products',
          child: Scaffold(
            backgroundColor: const Color(0xFF08080F),
            appBar: SetupAppBar(
              title: 'Products',
              actions: [
                DataScopeIndicator(access: setupProv.getCardAccess('products', ctxProv.currentRole)),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    setupProv.isGridView ? Icons.view_list : Icons.grid_view,
                    size: 22,
                  ),
                  color: AppColors.textSecondary,
                  onPressed: setupProv.toggleProductView,
                ),
              ],
            ),
            floatingActionButton: SetupRbacFAB(
              cardId: 'products',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.setupProductCreate);
              },
              label: 'Add Product',
              icon: Icons.add,
            ),
            body: CustomScrollView(
            slivers: [
              // ─── Summary Cards ────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: KPIBadge(
                          label: 'Total SKUs',
                          value: '${setupProv.products.length}',
                          icon: Icons.inventory_2,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: KPIBadge(
                          label: 'Low Stock',
                          value: '${setupProv.lowStockCount}',
                          icon: Icons.warning_amber,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: KPIBadge(
                          label: 'Out of Stock',
                          value: '${setupProv.outOfStockCount}',
                          icon: Icons.remove_shopping_cart,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Search ───────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        const Icon(Icons.search, size: 20, color: AppColors.textTertiary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Search products by name, SKU, category...',
                              hintStyle: TextStyle(fontSize: 13, color: AppColors.textTertiary),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                            onChanged: setupProv.setProductSearch,
                          ),
                        ),
                        const SizedBox(width: 14),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── Product List ─────────────────────────────
              if (products.isEmpty) ...[
                const SliverFillRemaining(
                  child: SetupEmptyState(
                    icon: Icons.inventory_2,
                    title: 'No products found',
                    subtitle: 'Try a different search or add new products.',
                  ),
                ),
              ] else if (setupProv.isGridView) ...[
              // ─── AI Insights ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Consumer<AIInsightsNotifier>(
                  builder: (context, ai, _) {
                    if (ai.insights.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: kSetupColor.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome, size: 14, color: kSetupColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'AI: ${ai.insights.first['title'] ?? ''}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kSetupColor),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.78,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _ProductGridCard(product: products[i]),
                      childCount: products.length,
                    ),
                  ),
                ),
              ] else ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _ProductListTile(product: products[i]),
                      childCount: products.length,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        );
      },
    );
  }
}

// ─── Product Grid Card ───────────────────────────────────────────────────────

class _ProductGridCard extends StatelessWidget {
  final Product product;
  const _ProductGridCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context.read<SetupDashboardProvider>().selectProduct(product.id);
        Navigator.pushNamed(context, AppRoutes.setupProductDetail);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: product.imageUrls.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: product.imageUrls.first,
                      height: 80,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => IveSkeleton(height: 80, radius: BorderRadius.circular(10)),
                      errorWidget: (_, __, ___) => Container(
                        height: 80,
                        color: kSetupColor.withValues(alpha: 0.06),
                        child: Icon(Icons.inventory_2_outlined, size: 28, color: kSetupColor.withValues(alpha: 0.35)),
                      ),
                    )
                  : Container(
                      height: 80,
                      color: kSetupColor.withValues(alpha: 0.06),
                      child: Icon(Icons.inventory_2_outlined, size: 28, color: kSetupColor.withValues(alpha: 0.35)),
                    ),
            ),
            const SizedBox(height: 8),
            // Name
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Price
            Row(
              children: [
                Text(
                  'â‚µ${product.currentPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: kSetupColor,
                  ),
                ),
                if (product.hasDiscount) ...[
                  const SizedBox(width: 6),
                  Text(
                    'â‚µ${product.basePrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),
            const Spacer(),
            // Stock + Rating
            Row(
              children: [
                _StockBadge(product: product),
                const Spacer(),
                if (product.rating > 0) ...[
                  const Icon(Icons.star, size: 12, color: AppColors.accent),
                  const SizedBox(width: 2),
                  Text(
                    product.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Product List Tile ───────────────────────────────────────────────────────

class _ProductListTile extends StatelessWidget {
  final Product product;
  const _ProductListTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<SetupDashboardProvider>().selectProduct(product.id);
        Navigator.pushNamed(context, AppRoutes.setupProductDetail);
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product thumbnail (list row)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: product.imageUrls.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: product.imageUrls.first,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => IveSkeleton(width: 56, height: 56, radius: BorderRadius.circular(10)),
                    errorWidget: (_, __, ___) => Container(
                      width: 56,
                      height: 56,
                      color: kSetupColor.withValues(alpha: 0.06),
                      child: const Icon(Icons.inventory_2_outlined, size: 24, color: kSetupColor),
                    ),
                  )
                : Container(
                    width: 56,
                    height: 56,
                    color: kSetupColor.withValues(alpha: 0.06),
                    child: const Icon(Icons.inventory_2_outlined, size: 24, color: kSetupColor),
                  ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${product.category} Â· ${product.sku}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'â‚µ${product.currentPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kSetupColor,
                      ),
                    ),
                    const Spacer(),
                    _StockBadge(product: product),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

// ─── Stock Badge ─────────────────────────────────────────────────────────────

class _StockBadge extends StatelessWidget {
  final Product product;
  const _StockBadge({required this.product});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (product.stockLevel) {
      case StockLevel.inStock:
        color = AppColors.success;
        label = '${product.stock}';
        break;
      case StockLevel.lowStock:
        color = AppColors.warning;
        label = '${product.stock} low';
        break;
      case StockLevel.outOfStock:
        color = AppColors.error;
        label = 'Out';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
