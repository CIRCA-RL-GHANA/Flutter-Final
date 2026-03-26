/// ═══════════════════════════════════════════════════════════════════════════
/// MARKET MODULE — Screen 1.5: Explore All Merchants
/// Full-screen immersive grid with map/grid toggle, masonry merchant cards
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/ai_insights_notifier.dart';
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
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
                    SliverToBoxAdapter(
                      child: Consumer<AIInsightsNotifier>(
                        builder: (ctx, notifier, _) {
                          final recs = notifier.recommendations;
                          if (recs.isEmpty) return const SizedBox.shrink();
                          return Container(
                            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withOpacity(0.06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF8B5CF6).withOpacity(0.15),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.auto_awesome, size: 14, color: Color(0xFF8B5CF6)),
                                    SizedBox(width: 6),
                                    Text(
                                      'Recommended for you',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF8B5CF6),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: recs.take(4).map((r) {
                                    final name = r['name']?.toString() ?? r['id']?.toString() ?? '';
                                    return GestureDetector(
                                      onTap: () => Navigator.pushNamed(context, AppRoutes.marketSearch),
                                      child: Chip(
                                        label: Text(name, style: const TextStyle(fontSize: 11)),
                                        backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.1),
                                        side: BorderSide(color: const Color(0xFF8B5CF6).withOpacity(0.2)),
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
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
        // Map placeholder
        Container(
          color: const Color(0xFFE8F0FE),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, size: 80, color: AppColors.textTertiary),
                SizedBox(height: 16),
                Text(
                  'Interactive Map View',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                SizedBox(height: 8),
                Text(
                  'Merchant locations with delivery radius',
                  style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6),
                        ],
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
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
                        ],
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
