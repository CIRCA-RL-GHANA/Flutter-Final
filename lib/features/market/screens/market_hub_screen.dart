/// ═══════════════════════════════════════════════════════════════════════════
/// MARKET MODULE — Screen 1: Market Hub (Immersive Discovery)
/// Video background, category navigation, merchant discovery,
/// AI optimization panel, quick actions, deal carousel
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../providers/market_provider.dart';
import '../widgets/market_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class MarketHubScreen extends StatefulWidget {
  const MarketHubScreen({super.key});

  @override
  State<MarketHubScreen> createState() => _MarketHubScreenState();
}

class _MarketHubScreenState extends State<MarketHubScreen> {
  int _featuredIndex = 0;
  final _scrollController = ScrollController();
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final collapsed = _scrollController.offset > 200;
      if (collapsed != _isCollapsed) {
        setState(() => _isCollapsed = collapsed);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketProvider>(
      builder: (context, prov, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // ── Video Background / Hero Section ──
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: kMarketColorDark,
                leading: const SizedBox.shrink(),
                leadingWidth: 0,
                title: _isCollapsed
                    ? const Text(
                        'Market',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      )
                    : null,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.marketSearch),
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune, color: Colors.white),
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.marketFilters),
                  ),
                  IconButton(
                    icon: Badge(
                      label: Text('${prov.cartItemCount}'),
                      isLabelVisible: prov.cartItemCount > 0,
                      child: const Icon(Icons.shopping_cart, color: Colors.white),
                    ),
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.marketCart),
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Video placeholder / gradient background
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF065F46),
                              Color(0xFF064E3B),
                              Color(0xFF022C22),
                            ],
                          ),
                        ),
                      ),
                      // Featured merchant overlay
                      if (prov.featuredMerchants.isNotEmpty)
                        Positioned(
                          bottom: 70,
                          left: 20,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: kMarketColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'FEATURED',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.volume_off, color: Colors.white.withOpacity(0.7), size: 18),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                prov.featuredMerchants[_featuredIndex % prov.featuredMerchants.length].name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                prov.featuredMerchants[_featuredIndex % prov.featuredMerchants.length].description ?? '',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      // Context header
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        left: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Shopping as: Wizdom Shop',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.stars, size: 14, color: AppColors.accent),
                                const SizedBox(width: 4),
                                Text(
                                  '14,250 QP',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.account_balance_wallet, size: 14, color: AppColors.accent),
                                const SizedBox(width: 4),
                                Text(
                                  '\$500 Credit',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
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
              ),

              // ── Category Navigation ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: MarketCategoryChipRow(
                    selected: prov.selectedCategory,
                    onSelected: prov.setCategory,
                  ),
                ),
              ),

              // ── Live Merchant Counter ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kMarketColor,
                          boxShadow: [
                            BoxShadow(
                              color: kMarketColor.withOpacity(0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${prov.activeMerchantCount} vendors active now',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: kMarketColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Quick Actions Grid ──
              SliverToBoxAdapter(
                child: _buildQuickActions(context, prov),
              ),

              // ── AI Optimization Panel ──
              SliverToBoxAdapter(
                child: _buildAIPanel(prov),
              ),

              // ── My Transactions Button ──
              SliverToBoxAdapter(
                child: _buildTransactionButton(context, prov),
              ),

              // ── Deals Carousel ──
              if (prov.merchantDeals.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: MarketSectionTitle(
                    title: 'Hot Deals',
                    icon: Icons.local_fire_department,
                    actionText: 'See all',
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildDealsCarousel(prov),
                ),
              ],

              // ── Merchant Discovery ──
              const SliverToBoxAdapter(
                child: MarketSectionTitle(
                  title: 'Discover Merchants',
                  icon: Icons.explore,
                  actionText: 'Explore all',
                ),
              ),

              // Merchant cards
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.62,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final merchant = prov.filteredMerchants[i];
                      return MerchantCard(
                        merchant: merchant,
                        compact: true,
                        onTap: () {
                          prov.selectMerchant(merchant.id);
                          Navigator.pushNamed(context, AppRoutes.marketBranch);
                        },
                      );
                    },
                    childCount: prov.filteredMerchants.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          // Floating cart preview
          floatingActionButton: prov.cartItemCount > 0
              ? FloatingActionButton.extended(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.marketCart),
                  backgroundColor: kMarketColor,
                  icon: const Icon(Icons.shopping_cart, color: Colors.white),
                  label: Text(
                    '${prov.cartItemCount} items • ${prov.cartSummary.totalDisplay}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context, MarketProvider prov) {
    final actions = [
      ('Shop Now', Icons.storefront, AppRoutes.marketExplore),
      ('My Cart', Icons.shopping_cart, AppRoutes.marketCart),
      ('My Orders', Icons.receipt_long, AppRoutes.marketTransactions),
      ('Hail Ride', Icons.local_taxi, AppRoutes.marketRideHailing),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: actions.map((action) {
          final (label, icon, route) = action;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.pushNamed(context, route);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: kMarketColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, size: 22, color: kMarketColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAIPanel(MarketProvider prov) {
    return Consumer<AIInsightsNotifier>(
      builder: (context, aiNotifier, _) {
        final liveInsights = aiNotifier.insights;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF8B5CF6).withOpacity(0.08),
                kMarketColor.withOpacity(0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, size: 16, color: Color(0xFF8B5CF6)),
                  SizedBox(width: 6),
                  Text(
                    'AI Optimization',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (liveInsights.isNotEmpty)
                ...liveInsights.take(3).map((insight) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb_outline, size: 14, color: Color(0xFF8B5CF6)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              insight.label,
                              style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ))
              else
                ...prov.aiSuggestions.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(s.icon, size: 14, color: s.color),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              s.message,
                              style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionButton(BuildContext context, MarketProvider prov) {
    final summary = prov.transactionSummary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.marketTransactions),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kMarketColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.receipt_long, size: 24, color: kMarketColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Transactions',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (summary.activeOrders > 0)
                          _TransactionBadge(
                            label: '${summary.activeOrders} active',
                            color: AppColors.info,
                          ),
                        if (summary.readyForPickup > 0)
                          _TransactionBadge(
                            label: '${summary.readyForPickup} ready',
                            color: kMarketColor,
                          ),
                        if (summary.pendingReturns > 0)
                          _TransactionBadge(
                            label: '${summary.pendingReturns} returns',
                            color: AppColors.warning,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDealsCarousel(MarketProvider prov) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: prov.merchantDeals.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final deal = prov.merchantDeals[i];
          return Container(
            width: 240,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kMarketColor, kMarketColorDark],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deal.valueDisplay,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  deal.title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  children: [
                    if (deal.code != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          deal.code!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    const Spacer(),
                    if (deal.expiresAt != null)
                      Text(
                        _timeRemaining(deal.expiresAt!),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
                if (deal.maxRedemptions != null) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: deal.redemptionProgress,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                      minHeight: 3,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _timeRemaining(DateTime dt) {
    final diff = dt.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    if (diff.inDays > 0) return '${diff.inDays}d left';
    if (diff.inHours > 0) return '${diff.inHours}h left';
    return '${diff.inMinutes}m left';
  }
}

class _TransactionBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _TransactionBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
