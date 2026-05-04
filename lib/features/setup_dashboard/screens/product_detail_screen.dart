/// ═══════════════════════════════════════════════════════════════════════════
/// SD1.1-DETAIL: PRODUCT DETAIL — 5-Tab Deep View
/// Tabs: Overview, Inventory, Pricing, Media, Analytics
/// RBAC: Owner/Admin(fullAccess), BM(branchScoped), Monitor(viewOnly),
///        Driver(viewOnly), Others(hidden)
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../prompt/providers/context_provider.dart';
import '../models/setup_dashboard_models.dart';
import '../providers/setup_dashboard_provider.dart';
import '../widgets/shared_widgets.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _tabIndex = 0;
  static const _tabs = ['Overview', 'Inventory', 'Pricing', 'Media', 'Analytics'];

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        final product = setupProv.selectedProduct;
        if (product == null) {
          return Scaffold(
            appBar: const SetupAppBar(title: 'Product Detail'),
            body: const SetupEmptyState(
              icon: Icons.inventory_2,
              title: 'No product selected',
              subtitle: 'Select a product from the list',
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FC),
          appBar: SetupAppBar(title: product.name),
          body: Column(
            children: [
              // ─── Product Header ────────────────────────────
              _ProductHeader(product: product),
              const SizedBox(height: 12),              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kSetupColor.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kSetupColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "AI: ${ai.insights.first['title'] ?? ''}",
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kSetupColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),              // ─── Tab Bar ──────────────────────────────────
              SetupDetailTabBar(
                tabs: _tabs,
                selectedIndex: _tabIndex,
                onTabChanged: (i) => setState(() => _tabIndex = i),
              ),
              const SizedBox(height: 12),
              // ─── Tab Content ──────────────────────────────
              Expanded(
                child: IndexedStack(
                  index: _tabIndex,
                  children: [
                    _OverviewTab(product: product),
                    _InventoryTab(product: product),
                    _PricingTab(product: product),
                    _MediaTab(product: product),
                    _AnalyticsTab(product: product),
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

// ─── Product Header ──────────────────────────────────────────────────────────

class _ProductHeader extends StatelessWidget {
  final Product product;
  const _ProductHeader({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product image placeholder
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: kSetupColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.inventory_2, size: 30, color: kSetupColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.category} · ${product.brand}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _StockBadge(product: product),
                    const SizedBox(width: 8),
                    if (product.rating > 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 14, color: AppColors.accent),
                          const SizedBox(width: 2),
                          Text(
                            '${product.rating}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            ' (${product.reviewCount})',
                            style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final Product product;
  const _StockBadge({required this.product});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    switch (product.stockLevel) {
      case StockLevel.inStock:
        color = AppColors.success;
        label = 'In Stock (${product.stock})';
        break;
      case StockLevel.lowStock:
        color = AppColors.warning;
        label = 'Low Stock (${product.stock})';
        break;
      case StockLevel.outOfStock:
        color = AppColors.error;
        label = 'Out of Stock';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

// ─── Overview Tab ────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final Product product;
  const _OverviewTab({required this.product});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        // KPI Row
        Row(
          children: [
            Expanded(child: SetupStatCard(label: 'Price', value: '₵${product.currentPrice.toStringAsFixed(0)}', icon: Icons.attach_money)),
            const SizedBox(width: 10),
            Expanded(child: SetupStatCard(label: 'Stock', value: '${product.stock}', icon: Icons.inventory)),
            const SizedBox(width: 10),
            Expanded(child: SetupStatCard(label: 'Sold Today', value: '${product.soldToday}', icon: Icons.shopping_cart, color: AppColors.success)),
          ],
        ),
        const SizedBox(height: 16),
        // Product Details
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Product Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              SetupInfoRow(label: 'SKU', value: product.sku),
              SetupInfoRow(label: 'Category', value: product.category),
              SetupInfoRow(label: 'Brand', value: product.brand ?? 'N/A'),
              SetupInfoRow(label: 'Rating', value: '${product.rating} / 5.0 (${product.reviewCount} reviews)'),
              if (product.lastSold != null)
                SetupInfoRow(label: 'Last Sold', value: setupTimeAgo(product.lastSold!)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Tags
        if (product.tags.isNotEmpty)
          SetupSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.label_outline, size: 18, color: kSetupColor),
                    const SizedBox(width: 8),
                    const Text('Tags', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: product.tags.map((tag) => Chip(
                    label: Text(tag, style: const TextStyle(fontSize: 11)),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: kSetupColor.withOpacity(0.08),
                    labelStyle: const TextStyle(color: kSetupColor),
                    side: BorderSide.none,
                  )).toList(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── Inventory Tab ───────────────────────────────────────────────────────────

class _InventoryTab extends StatelessWidget {
  final Product product;
  const _InventoryTab({required this.product});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        // Stock Level Indicator
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.analytics_outlined, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Stock Level', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: product.stock / (product.lowStockThreshold * 3).clamp(1, 200),
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    product.isOutOfStock ? AppColors.error :
                    product.isLowStock ? AppColors.warning :
                    AppColors.success,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SetupInfoRow(label: 'Current Stock', value: '${product.stock} units'),
              SetupInfoRow(label: 'Low Stock Threshold', value: '${product.lowStockThreshold} units'),
              SetupInfoRow(
                label: 'Status',
                value: product.stockLevel.name.toUpperCase(),
                valueColor: product.isOutOfStock ? AppColors.error :
                    product.isLowStock ? AppColors.warning : AppColors.success,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Reorder Section
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.refresh, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Reorder Info', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              SetupInfoRow(label: 'Reorder Point', value: '${product.lowStockThreshold} units'),
              const SetupInfoRow(label: 'Lead Time', value: '3-5 days'),
              const SetupInfoRow(label: 'Supplier', value: 'Default Supplier'),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Pricing Tab ─────────────────────────────────────────────────────────────

class _PricingTab extends StatelessWidget {
  final Product product;
  const _PricingTab({required this.product});

  @override
  Widget build(BuildContext context) {
    final discount = product.basePrice > product.currentPrice
        ? ((product.basePrice - product.currentPrice) / product.basePrice * 100)
        : 0.0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.attach_money, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Price Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              SetupInfoRow(label: 'Base Price', value: '₵${product.basePrice.toStringAsFixed(2)}'),
              SetupInfoRow(
                label: 'Current Price',
                value: '₵${product.currentPrice.toStringAsFixed(2)}',
                valueColor: kSetupColor,
              ),
              if (discount > 0)
                SetupInfoRow(
                  label: 'Discount',
                  value: '${discount.toStringAsFixed(1)}% off',
                  valueColor: AppColors.success,
                ),
              const SetupInfoRow(label: 'Margin', value: '35%'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.timeline, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Price History', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              _PriceHistoryRow(date: '1 week ago', price: product.basePrice),
              _PriceHistoryRow(date: '3 days ago', price: product.currentPrice * 1.05),
              _PriceHistoryRow(date: 'Today', price: product.currentPrice, isCurrent: true),
            ],
          ),
        ),
      ],
    );
  }
}

class _PriceHistoryRow extends StatelessWidget {
  final String date;
  final double price;
  final bool isCurrent;

  const _PriceHistoryRow({
    required this.date,
    required this.price,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            isCurrent ? Icons.circle : Icons.circle_outlined,
            size: 10,
            color: isCurrent ? kSetupColor : AppColors.textTertiary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(date, style: TextStyle(
              fontSize: 12,
              color: isCurrent ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
            )),
          ),
          Text(
            '₵${price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isCurrent ? kSetupColor : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Media Tab ───────────────────────────────────────────────────────────────

class _MediaTab extends StatelessWidget {
  final Product product;
  const _MediaTab({required this.product});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.photo_library, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Product Images', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: List.generate(6, (i) => Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: i == 0 ? Border.all(color: kSetupColor, width: 2) : null,
                  ),
                  child: Icon(
                    i == 0 ? Icons.image : Icons.add_photo_alternate_outlined,
                    size: 28,
                    color: i == 0 ? kSetupColor : AppColors.textTertiary,
                  ),
                )),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.videocam, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Product Videos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              const SetupEmptyState(
                icon: Icons.videocam_off,
                title: 'No videos yet',
                subtitle: 'Add product demo videos',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Analytics Tab ───────────────────────────────────────────────────────────

class _AnalyticsTab extends StatelessWidget {
  final Product product;
  const _AnalyticsTab({required this.product});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        // Performance KPIs
        Row(
          children: [
            Expanded(child: SetupStatCard(label: 'Views', value: '2.4K', icon: Icons.visibility, color: kSetupColor)),
            const SizedBox(width: 10),
            Expanded(child: SetupStatCard(label: 'Conversion', value: '12%', icon: Icons.trending_up, color: AppColors.success)),
            const SizedBox(width: 10),
            Expanded(child: SetupStatCard(label: 'Revenue', value: '₵42K', icon: Icons.attach_money, color: const Color(0xFF8B5CF6))),
          ],
        ),
        const SizedBox(height: 16),
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.trending_up, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Sales Trend', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: CustomPaint(
                  size: const Size(double.infinity, 120),
                  painter: _MiniChartPainter(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.people, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Top Buyers', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              const _BuyerRow(name: 'John Smith', purchases: 12, amount: 5400),
              const _BuyerRow(name: 'Sarah Johnson', purchases: 8, amount: 3200),
              const _BuyerRow(name: 'Mike Chen', purchases: 6, amount: 2100),
            ],
          ),
        ),
      ],
    );
  }
}

class _BuyerRow extends StatelessWidget {
  final String name;
  final int purchases;
  final double amount;

  const _BuyerRow({required this.name, required this.purchases, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: kSetupColor.withOpacity(0.1),
            child: Text(name[0], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kSetupColor)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                Text('$purchases purchases', style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
              ],
            ),
          ),
          Text('₵${amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kSetupColor)),
        ],
      ),
    );
  }
}

class _MiniChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kSetupColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [kSetupColor.withOpacity(0.3), kSetupColor.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final points = [0.6, 0.4, 0.7, 0.3, 0.8, 0.5, 0.9, 0.6, 0.75, 0.85];
    final path = Path();
    final fillPath = Path();

    for (var i = 0; i < points.length; i++) {
      final x = i / (points.length - 1) * size.width;
      final y = size.height - (points[i] * size.height);
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
