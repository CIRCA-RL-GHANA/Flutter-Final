import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive.dart';
import '../../../core/routes/app_routes.dart';
import '../models/market_models.dart';
import '../providers/market_provider.dart';
import '../widgets/market_widgets.dart';

class MarketCommerceScreen extends StatefulWidget {
  const MarketCommerceScreen({super.key});

  @override
  State<MarketCommerceScreen> createState() => _MarketCommerceScreenState();
}

class _MarketCommerceScreenState extends State<MarketCommerceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<MarketProvider>();
      if (prov.products.isEmpty) {
        prov.loadProducts();
      }
      if (prov.orders.isEmpty) {
        prov.loadOrders();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketProvider>(
      builder: (context, prov, _) {
        return Scaffold(
          backgroundColor: IveTokens.bg,
          appBar: AppBar(
            title: const Text('Market'),
            elevation: 0,
            backgroundColor: IveTokens.surface,
            foregroundColor: IveTokens.ink,
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.marketCart),
                  ),
                  if (prov.cartItemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: kMarketColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${prov.cartItemCount}',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: kMarketColor,
              unselectedLabelColor: const Color(0xFF6B7280),
              indicatorColor: kMarketColor,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.store_outlined, size: 16),
                      SizedBox(width: 4),
                      Text('Shop'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shopping_cart_outlined, size: 16),
                      const SizedBox(width: 4),
                      const Text('Cart'),
                      if (prov.cartItemCount > 0) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: kMarketColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${prov.cartItemCount}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.receipt_outlined, size: 16),
                      SizedBox(width: 4),
                      Text('Orders'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _ShopTab(prov: prov),
                    _CartTab(prov: prov),
                    _OrdersTab(prov: prov),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

//  Shop Tab 

class _ShopTab extends StatefulWidget {
  final MarketProvider prov;
  const _ShopTab({required this.prov});

  @override
  State<_ShopTab> createState() => _ShopTabState();
}

class _ShopTabState extends State<_ShopTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  MerchantCategory _selectedCategory = MerchantCategory.all;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = widget.prov;
    final query = _searchCtrl.text.toLowerCase();
    final allProducts = _selectedCategory == MerchantCategory.all
        ? prov.products
        : prov.products
            .where((p) => p.category == _selectedCategory)
            .toList();
    final filtered = query.isEmpty
        ? allProducts
        : allProducts
            .where((p) => p.name.toLowerCase().contains(query))
            .toList();

    return prov.productsLoading && prov.products.isEmpty
        ? const Center(
            child: CircularProgressIndicator(color: kMarketColor))
        : RefreshIndicator(
            color: kMarketColor,
            onRefresh: () => prov.loadProducts(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        prefixIcon:
                            const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: MarketCategoryChipRow(
                    selected: _selectedCategory,
                    onSelected: (cat) =>
                        setState(() => _selectedCategory = cat),
                  ),
                ),
                if (filtered.isEmpty)
                  const SliverFillRemaining(
                    child: MarketEmptyState(
                      icon: Icons.shopping_bag_outlined,
                      title: 'No products found',
                      subtitle: 'Try a different search or category.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = filtered[index];
                          return MarketProductCard(
                            product: product,
                            onTap: () {
                              prov.selectProduct(product.id);
                              Navigator.pushNamed(
                                  context, AppRoutes.marketProductDetail);
                            },
                            onAddToCart: () {
                              HapticFeedback.lightImpact();
                              prov.addToCart(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('${product.name} added to cart'),
                                  backgroundColor: kMarketColor,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          );
                        },
                        childCount: filtered.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
  }
}

//  Cart Tab 

class _CartTab extends StatelessWidget {
  final MarketProvider prov;
  const _CartTab({required this.prov});

  @override
  Widget build(BuildContext context) {
    final items = prov.cartItems;
    if (items.isEmpty) {
      return const MarketEmptyState(
        icon: Icons.shopping_cart_outlined,
        title: 'Your cart is empty',
        subtitle: 'Add products from the Shop tab to get started.',
      );
    }

    final summary = prov.cartSummary;
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: kMarketColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: item.product.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  item.product.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                      Icons.image_outlined,
                                      color: kMarketColor),
                                ),
                              )
                            : const Icon(Icons.image_outlined,
                                color: kMarketColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.product.priceDisplay,
                              style: const TextStyle(
                                  color: kMarketColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      QuantitySelector(
                        quantity: item.quantity,
                        onChanged: (qty) {
                          prov.updateCartItemQuantity(item.id, qty);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal',
                      style:
                          TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                  Text('\$${summary.subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Delivery',
                      style:
                          TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                  Text(
                      summary.deliveryFee == 0
                          ? 'FREE'
                          : '\$${summary.deliveryFee.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: summary.deliveryFee == 0
                            ? kMarketColor
                            : const Color(0xFF1A1A1A),
                      )),
                ],
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  Text('\$${summary.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: kMarketColor)),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.marketCheckout),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kMarketColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Checkout',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

//  Orders Tab 

class _OrdersTab extends StatelessWidget {
  final MarketProvider prov;
  const _OrdersTab({required this.prov});

  @override
  Widget build(BuildContext context) {
    if (prov.ordersLoading && prov.orders.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: kMarketColor));
    }

    if (prov.orders.isEmpty) {
      return const MarketEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No orders yet',
        subtitle: 'Your order history will appear here.',
      );
    }

    return RefreshIndicator(
      color: kMarketColor,
      onRefresh: () => prov.loadOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: prov.orders.length,
        itemBuilder: (context, index) {
          final order = prov.orders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: MarketOrderCard(
              order: order,
              onTap: () {
                prov.selectOrder(order.id);
                Navigator.pushNamed(context, AppRoutes.marketTransactions);
              },
            ),
          );
        },
      ),
    );
  }
}
