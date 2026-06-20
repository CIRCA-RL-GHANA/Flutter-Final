/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
/// MARKET MODULE — Screen 1.5: Explore All Merchants
/// Full-screen immersive grid with map/grid toggle, masonry merchant cards
/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../providers/market_provider.dart';
import '../widgets/market_widgets.dart';

class MarketExploreScreen extends StatefulWidget {
  const MarketExploreScreen({super.key});

  @override
  State<MarketExploreScreen> createState() => _MarketExploreScreenState();
}

class _MarketExploreScreenState extends State<MarketExploreScreen> {
  bool _isMapView = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketProvider>(
      builder: (context, prov, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: MarketAppBar(
            title: 'Explore All',
            actions: [
              IconButton(
                icon: Icon(
                  _isMapView ? Icons.grid_view : Icons.map,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => setState(() => _isMapView = !_isMapView),
              ),
              IconButton(
                icon: const Icon(Icons.search, color: AppColors.textPrimary),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.marketSearch),
              ),
            ],
          ),
          body: _isMapView ? _buildMapView(prov) : _buildGridView(context, prov),
        );
      },
    );
  }

  Widget _buildGridView(BuildContext context, MarketProvider prov) {
    return Column(
      children: [
        // Category chips
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: MarketCategoryChipRow(
            selected: prov.selectedCategory,
            onSelected: prov.setCategory,
          ),
        ),
        // Filter info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text(
                '${prov.filteredMerchants.length} merchants',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.marketFilters),
                child: Row(
                  children: [
                    const Icon(Icons.tune, size: 16, color: kMarketColor),
                    const SizedBox(width: 4),
                    const Text('Filter', style: TextStyle(fontSize: 13, color: kMarketColor, fontWeight: FontWeight.w600)),
                    if (prov.filters.hasActiveFilters) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: kMarketColor, shape: BoxShape.circle),
                        child: Text(
                          '${prov.filters.activeFilterCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        // Grid
        Expanded(
          child: prov.filteredMerchants.isEmpty
              ? const MarketEmptyState(
                  icon: Icons.store_mall_directory,
                  title: 'No merchants found',
                  subtitle: 'Try adjusting your filters',
                )
              : CustomScrollView(
                  slivers: [
                    // ─── AI Personalized Recommendations Banner ────
                    const SliverToBoxAdapter(
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final merchant = prov.filteredMerchants[i];
                            return MerchantCard(
                              merchant: merchant,
                              onTap: () {
                                prov.selectMerchant(merchant.id);
                                Navigator.pushNamed(context, AppRoutes.marketBranch);
                              },
                            );
                          },
                          childCount: prov.filteredMerchants.length,
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.58,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildMapView(MarketProvider prov) {
    return Stack(
      children: [
        // Map surface — grid texture with merchant count indicator.
        Positioned.fill(
          child: Container(
            color: const Color(0xFF0D0F1A),
            child: Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: _ExploreGridPainter())),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.store_rounded, size: 36, color: IveTokens.accent.withValues(alpha: 0.5)),
                      const SizedBox(height: 8),
                      Text(
                        '${prov.filteredMerchants.length} merchants nearby',
                        style: const TextStyle(fontSize: 13, color: IveTokens.labelSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Merchant pins
        ...List.generate(
          prov.filteredMerchants.length.clamp(0, 5),
          (i) {
            final merchant = prov.filteredMerchants[i];
            final top = 100.0 + (i * 80);
            final left = 40.0 + (i * 60);
            return Positioned(
              top: top,
              left: left,
              child: GestureDetector(
                onTap: () {
                  prov.selectMerchant(merchant.id);
                  Navigator.pushNamed(context, AppRoutes.marketBranch);
                },
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.store,
                        size: 20,
                        color: merchant.isOpen ? kMarketColor : AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        merchant.name,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        // List nearby button
        Positioned(
          bottom: 24,
          left: 16,
          right: 16,
          child: ElevatedButton.icon(
            onPressed: () => setState(() => _isMapView = false),
            icon: const Icon(Icons.list),
            label: const Text('List nearby'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: kMarketColor,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _ExploreGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = IveTokens.hairline.withValues(alpha: 0.35)
      ..strokeWidth = 0.5;
    const s = 32.0;
    for (double x = 0; x < size.width; x += s) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += s) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
