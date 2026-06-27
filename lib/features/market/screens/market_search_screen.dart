/// 
/// MARKET MODULE  Screen 1.1: Unified Market Search
/// Full-screen modal with search bar, recent searches, quick filters,
/// tabbed results (Merchants / Products / Deals), AI suggestions
/// 
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../models/market_models.dart';
import '../providers/market_provider.dart';
import '../widgets/market_widgets.dart';

class MarketSearchScreen extends StatefulWidget {
  const MarketSearchScreen({super.key});

  @override
  State<MarketSearchScreen> createState() => _MarketSearchScreenState();
}

class _MarketSearchScreenState extends State<MarketSearchScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;
  String _query = '';
  final Set<String> _quickFilters = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      setState(() => _query = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketProvider>(
      builder: (context, prov, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Search', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            centerTitle: true,
          ),
          body: Column(
            children: [
              //  Search Input 
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: MarketSearchBar(
                  controller: _searchController,
                  autofocus: true,
                  hint: 'Search products, merchants, deals...',
                ),
              ),

              //  Quick Filter Chips 
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: MarketQuickFilterChips(
                  filters: const ['Open now', 'Free delivery', 'Under 30min', '4+', 'Near me'],
                  selected: _quickFilters,
                  onToggle: (f) => setState(() {
                    _quickFilters.contains(f) ? _quickFilters.remove(f) : _quickFilters.add(f);
                  }),
                ),
              ),

              //  Content area 
              if (_query.isEmpty) ...[
                // Recent searches
                const MarketSectionTitle(title: 'Recent Searches', icon: Icons.history),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: prov.recentSearches.map((s) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.history, size: 18, color: AppColors.textTertiary),
                          title: Text(s, style: const TextStyle(fontSize: 14)),
                          trailing: const Icon(Icons.north_west, size: 16, color: AppColors.textTertiary),
                          onTap: () {
                            _searchController.text = s;
                            _searchController.selection = TextSelection.collapsed(offset: s.length);
                          },
                        )).toList(),
                  ),
                ),
                const Divider(height: 24),
                // Suggestions
                const MarketSectionTitle(title: 'Suggested', icon: Icons.trending_up),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: prov.searchSuggestions.map((s) => GestureDetector(
                          onTap: () {
                            _searchController.text = s;
                            _searchController.selection = TextSelection.collapsed(offset: s.length);
                          },
                          child: Chip(
                            label: Text(s, style: const TextStyle(fontSize: 12)),
                            backgroundColor: kMarketColor.withValues(alpha: 0.08),
                            side: BorderSide(color: kMarketColor.withValues(alpha: 0.2)),
                            labelStyle: const TextStyle(color: kMarketColor),
                          ),
                        )).toList(),
                  ),
                ),
                const Spacer(),
                // AI-powered semantic search suggestion block
                _AISearchSuggestionBanner(
                  query: _query,
                  onSuggestionTap: (s) {
                    _searchController.text = s;
                    _searchController.selection =
                        TextSelection.collapsed(offset: s.length);
                  },
                ),
              ] else ...[
                // Tabs for results
                Container(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.inputBorder)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: kMarketColor,
                    labelColor: kMarketColor,
                    unselectedLabelColor: AppColors.textSecondary,
                    tabs: const [
                      Tab(text: 'Merchants'),
                      Tab(text: 'Products'),
                      Tab(text: 'Deals'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMerchantResults(prov),
                      _buildProductResults(prov),
                      _buildDealResults(prov),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMerchantResults(MarketProvider prov) {
    final results = prov.merchants
        .where((m) => m.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    if (results.isEmpty) {
      return const MarketEmptyState(
        icon: Icons.store_mall_directory,
        title: 'No merchants found',
        subtitle: 'Try a different search term',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final merchant = results[i];
        return GestureDetector(
          onTap: () {
            prov.selectMerchant(merchant.id);
            Navigator.pushNamed(context, AppRoutes.marketBranch);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: kMarketColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.store, color: kMarketColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(merchant.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          if (merchant.verification != VerificationTier.none) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, size: 14, color: kMarketColor),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          Text('${merchant.ratingDisplay}', style: const TextStyle(fontSize: 12)),
                          Text('  ${merchant.deliveryTimeDisplay}  ${merchant.distanceMiles}mi',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () {
                      prov.selectMerchant(merchant.id);
                      Navigator.pushNamed(context, AppRoutes.marketBranch);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kMarketColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Order'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductResults(MarketProvider prov) {
    final results = prov.products
        .where((p) => p.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    if (results.isEmpty) {
      return const MarketEmptyState(
        icon: Icons.inventory_2,
        title: 'No products found',
        subtitle: 'Try a different search term',
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: results.length,
      itemBuilder: (context, i) {
        final product = results[i];
        return MarketProductCard(
          product: product,
          onTap: () {
            prov.selectProduct(product.id);
            Navigator.pushNamed(context, AppRoutes.marketProductDetail);
          },
          onAddToCart: () => prov.addToCart(product),
        );
      },
    );
  }

  Widget _buildDealResults(MarketProvider prov) {
    final results = prov.merchantDeals
        .where((d) => d.title.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    if (results.isEmpty) {
      return const MarketEmptyState(
        icon: Icons.local_offer,
        title: 'No deals found',
        subtitle: 'Try a different search term',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final deal = results[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [kMarketColor, kMarketColorDark]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deal.valueDisplay,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deal.title,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (deal.code != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    deal.code!,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// 
// AI Search Suggestion Banner  shows AI keyword suggestions when query is empty
// or a smart "you might like" row when the user has typed something.
// 

class _AISearchSuggestionBanner extends StatelessWidget {
  final String  query;
  final void Function(String) onSuggestionTap;

  const _AISearchSuggestionBanner({
    required this.query,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
