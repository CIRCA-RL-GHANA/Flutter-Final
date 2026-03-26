/// ═══════════════════════════════════════════════════════════════════════════
/// MARKET MODULE — Screen 2: Branch Main View
/// Merchant profile with 5 tabs: Updates · Deals · Shop · Info · Returns
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/routes/app_routes.dart';
import '../models/market_models.dart';
import '../providers/market_provider.dart';
import '../widgets/market_widgets.dart';

class MarketBranchScreen extends StatefulWidget {
  const MarketBranchScreen({super.key});

  @override
  State<MarketBranchScreen> createState() => _MarketBranchScreenState();
}

class _MarketBranchScreenState extends State<MarketBranchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
        final merchant = prov.selectedMerchant;
        if (merchant == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Branch')),
            body: const MarketEmptyState(
              icon: Icons.storefront,
              title: 'No merchant selected',
              subtitle: 'Go back and select a merchant',
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: Column(
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kMarketColor.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(children: [
                      const Icon(Icons.auto_awesome, size: 14, color: kMarketColor),
                      const SizedBox(width: 8),
                      Expanded(child: Text('AI: ${ai.insights.first['title'] ?? ''}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kMarketColor),
                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                  );
                },
              ),
              Expanded(
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    _buildSliverHeader(context, merchant, prov),
                  ],
                  body: TabBarView(
              controller: _tabController,
              children: [
                _UpdatesTab(prov: prov, merchant: merchant),
                _DealsTab(prov: prov, merchant: merchant),
                _ShopTab(prov: prov, merchant: merchant),
                _InfoTab(merchant: merchant),
                _ReturnsTab(prov: prov),
              ],
            ),
          ),
              ),
            ],
          ),
        );
      },
    );
  }

  SliverAppBar _buildSliverHeader(BuildContext context, Merchant merchant, MarketProvider prov) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: kMarketColorDark,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border, color: Colors.white),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Banner
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [kMarketColorDark, kMarketColor.withOpacity(0.8)],
                ),
              ),
              child: const Icon(Icons.storefront, size: 60, color: Colors.white24),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                ),
              ),
            ),
            // Merchant info
            Positioned(
              left: 16,
              right: 16,
              bottom: 56,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Avatar
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)],
                        ),
                        child: const Icon(Icons.store, size: 28, color: kMarketColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    merchant.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (merchant.verification != VerificationTier.none) ...[
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.verified,
                                    size: 18,
                                    color: merchant.verification == VerificationTier.premium
                                        ? AppColors.accent
                                        : Colors.white70,
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              merchant.category.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 0.8,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Stats row
                  Row(
                    children: [
                      _StatPill(
                        icon: Icons.star,
                        label: '${merchant.rating}',
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 8),
                      _StatPill(
                        icon: Icons.access_time,
                        label: merchant.deliveryTimeDisplay,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 8),
                      _StatPill(
                        icon: Icons.delivery_dining,
                        label: merchant.deliveryFeeDisplay,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: merchant.statusColor.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          merchant.status.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: merchant.statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        indicatorColor: AppColors.accent,
        indicatorWeight: 3,
        tabAlignment: TabAlignment.start,
        tabs: const [
          Tab(text: 'Updates'),
          Tab(text: 'Deals'),
          Tab(text: 'Shop'),
          Tab(text: 'Info'),
          Tab(text: 'Returns'),
        ],
      ),
    );
  }
}

// ── Stat pill ──────────────────────────────────────────────────────
class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatPill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ── Tab 1: Updates ─────────────────────────────────────────────────
class _UpdatesTab extends StatelessWidget {
  final MarketProvider prov;
  final Merchant merchant;

  const _UpdatesTab({required this.prov, required this.merchant});

  @override
  Widget build(BuildContext context) {
    final posts = prov.merchantPosts
        .where((p) => p.merchantId == merchant.id)
        .toList();

    if (posts.isEmpty) {
      return const MarketEmptyState(
        icon: Icons.campaign,
        title: 'No updates yet',
        subtitle: 'This merchant hasn\'t posted any updates',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      itemBuilder: (context, i) {
        final post = posts[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: kMarketColorLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.store, size: 18, color: kMarketColor),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            merchant.name,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          Text(
                            _timeAgo(post.createdAt),
                            style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  post.content,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
                if (post.imageUrl != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 160,
                      width: double.infinity,
                      color: kMarketColorLight,
                      child: const Icon(Icons.image, size: 40, color: kMarketColor),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    _PostAction(icon: Icons.thumb_up_outlined, label: '${post.likes}'),
                    const SizedBox(width: 20),
                    _PostAction(icon: Icons.visibility_outlined, label: '${post.views}'),
                    const SizedBox(width: 20),
                    const _PostAction(icon: Icons.share_outlined, label: 'Share'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _PostAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PostAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
      ],
    );
  }
}

// ── Tab 2: Deals ───────────────────────────────────────────────────
class _DealsTab extends StatelessWidget {
  final MarketProvider prov;
  final Merchant merchant;

  const _DealsTab({required this.prov, required this.merchant});

  @override
  Widget build(BuildContext context) {
    final deals = prov.getDealsForMerchant(merchant.id);

    if (deals.isEmpty) {
      return const MarketEmptyState(
        icon: Icons.local_offer,
        title: 'No deals available',
        subtitle: 'Check back later for exclusive offers',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: deals.length,
      itemBuilder: (context, i) {
        final deal = deals[i];
        final isActive = deal.expiresAt == null || deal.expiresAt!.isAfter(DateTime.now());
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [kMarketColor, kMarketColorDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        deal.type == DealType.freeDelivery
                            ? Icons.delivery_dining
                            : deal.type == DealType.buyOneGetOne
                                ? Icons.card_giftcard
                                : Icons.percent,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deal.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            deal.description ?? '',
                            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Value display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    deal.valueDisplay,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Conditions
                if (deal.minimumOrder != null && deal.minimumOrder! > 0)
                  Text(
                    'Min order: \$${deal.minimumOrder!.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7)),
                  ),
                Row(
                  children: [
                    if (deal.expiresAt != null) ...[
                      Icon(Icons.schedule, size: 13, color: Colors.white.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Text(
                        'Expires in ${_remainingTime(deal.expiresAt!)}',
                        style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7)),
                      ),
                    ],
                    const Spacer(),
                    // Redemption progress
                    if (deal.maxRedemptions != null && deal.maxRedemptions! > 0) ...[
                      Text(
                        '${deal.currentRedemptions}/${deal.maxRedemptions!} used',
                        style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                // Apply button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isActive ? () {} : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: kMarketColorDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(isActive ? 'Apply Deal' : 'Expired'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _remainingTime(DateTime expiry) {
    final diff = expiry.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    if (diff.inDays > 0) return '${diff.inDays}d ${diff.inHours % 24}h';
    if (diff.inHours > 0) return '${diff.inHours}h ${diff.inMinutes % 60}m';
    return '${diff.inMinutes}m';
  }
}

// ── Tab 3: Shop ────────────────────────────────────────────────────
class _ShopTab extends StatelessWidget {
  final MarketProvider prov;
  final Merchant merchant;

  const _ShopTab({required this.prov, required this.merchant});

  @override
  Widget build(BuildContext context) {
    final products = prov.getProductsForMerchant(merchant.id);
    final categories = prov.productCategories;

    if (products.isEmpty) {
      return const MarketEmptyState(
        icon: Icons.shopping_bag,
        title: 'No products listed',
        subtitle: 'This merchant hasn\'t added products yet',
      );
    }

    return Column(
      children: [
        // Category chips
        SizedBox(
          height: 50,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              return ChoiceChip(
                label: Text(categories[i].name),
                selected: i == 0,
                selectedColor: kMarketColorLight,
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: i == 0 ? kMarketColorDark : AppColors.textSecondary,
                  fontWeight: i == 0 ? FontWeight.w600 : FontWeight.w400,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                side: BorderSide(color: i == 0 ? kMarketColor : AppColors.inputBorder),
                onSelected: (_) {},
              );
            },
          ),
        ),
        // Product grid/list toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text(
                '${products.length} products',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.marketProductFilters),
                child: const Row(
                  children: [
                    Icon(Icons.tune, size: 16, color: kMarketColor),
                    SizedBox(width: 4),
                    Text('Filter', style: TextStyle(fontSize: 13, color: kMarketColor, fontWeight: FontWeight.w600)),
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
        // Product list
        Expanded(
          child: prov.productViewMode == 'grid'
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
    );
  }
}

// ── Tab 4: Info ────────────────────────────────────────────────────
class _InfoTab extends StatelessWidget {
  final Merchant merchant;

  const _InfoTab({required this.merchant});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Profile card
        MarketSectionCard(
          title: 'Profile',
          children: [
              MarketInfoRow(
                icon: Icons.store,
                label: 'Name',
                value: merchant.name,
              ),
              MarketInfoRow(
                icon: Icons.category,
                label: 'Category',
                value: merchant.category.name,
              ),
              MarketInfoRow(
                icon: Icons.verified,
                label: 'Verification',
                value: merchant.verification.name,
              ),
              MarketInfoRow(
                icon: Icons.star,
                label: 'Rating',
                value: '${merchant.rating} (${merchant.ratingCount} reviews)',
              ),
            ],
        ),
        const SizedBox(height: 12),
        // Description
        if (merchant.description?.isNotEmpty ?? false)
          MarketSectionCard(
            title: 'About',
            children: [
              Text(
                merchant.description!,
                style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textSecondary),
              ),
            ],
          ),
        const SizedBox(height: 12),
        // Business hours
        MarketSectionCard(
          title: 'Business Hours',
          children: merchant.hours.entries.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        e.key,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                    Text(e.value, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              );
            }).toList(),
        ),
        const SizedBox(height: 12),
        // Delivery & fulfillment
        MarketSectionCard(
          title: 'Delivery & Fulfillment',
          children: [
              MarketInfoRow(
                icon: Icons.access_time,
                label: 'Delivery Time',
                value: merchant.deliveryTimeDisplay,
              ),
              MarketInfoRow(
                icon: Icons.delivery_dining,
                label: 'Delivery Fee',
                value: merchant.deliveryFeeDisplay,
              ),
              MarketInfoRow(
                icon: Icons.shopping_bag,
                label: 'Min Order',
                value: '\$${merchant.minimumOrder.toStringAsFixed(2)}',
              ),
              MarketInfoRow(
                icon: Icons.local_shipping,
                label: 'Fulfillment',
                value: merchant.fulfillment.name,
              ),
            ],
        ),
        const SizedBox(height: 12),
        // Contact
        MarketSectionCard(
          title: 'Contact',
          children: [
              MarketInfoRow(
                icon: Icons.location_on,
                label: 'Address',
                value: merchant.address,
              ),
              MarketInfoRow(
                icon: Icons.phone,
                label: 'Phone',
                value: merchant.phone ?? 'N/A',
              ),
            ],
        ),
        const SizedBox(height: 12),
        // Tags
        if (merchant.tags.isNotEmpty)
          MarketSectionCard(
            title: 'Tags',
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: merchant.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: kMarketColorLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#$tag',
                      style: const TextStyle(fontSize: 12, color: kMarketColorDark, fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Tab 5: Rejected Returns ────────────────────────────────────────
class _ReturnsTab extends StatelessWidget {
  final MarketProvider prov;

  const _ReturnsTab({required this.prov});

  @override
  Widget build(BuildContext context) {
    final videos = prov.rejectedReturnVideos;

    if (videos.isEmpty) {
      return const MarketEmptyState(
        icon: Icons.videocam_off,
        title: 'No rejected returns',
        subtitle: 'Video evidence of rejected returns will appear here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: videos.length,
      itemBuilder: (context, i) {
        final video = videos[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Video thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    color: const Color(0xFF1A1A2E),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.play_circle_fill, size: 48, color: Colors.white.withOpacity(0.8)),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              video.durationDisplay,
                              style: const TextStyle(fontSize: 11, color: Colors.white),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'REJECTED',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Return #${video.returnId.substring(0, 8).toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  video.reason.name,
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 13, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      '${video.createdAt.day}/${video.createdAt.month}/${video.createdAt.year}',
                      style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text('Watch', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(foregroundColor: kMarketColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
