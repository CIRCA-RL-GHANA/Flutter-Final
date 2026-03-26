/// APRIL Screen 4 — Wishlist Command Center
/// 4 view modes: grid, list, priority, timeline
/// Item management, collections, savings tracking

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../models/april_models.dart';
import '../providers/april_provider.dart';
import '../widgets/april_widgets.dart';

class AprilWishlistScreen extends StatelessWidget {
  const AprilWishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AprilProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: AprilAppBar(
            title: '🎁 Wishlist',
            actions: [
              if (provider.highPriorityWishlistCount > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${provider.highPriorityWishlistCount} priority',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFEF4444)),
                      ),
                    ),
                  ),
                ),
              PopupMenuButton<WishlistViewMode>(
                icon: const Icon(Icons.view_module, size: 22),
                onSelected: provider.setWishlistView,
                itemBuilder: (_) => WishlistViewMode.values.map((v) => PopupMenuItem(
                  value: v,
                  child: Row(
                    children: [
                      Icon(_viewIcon(v), size: 18, color: provider.wishlistView == v ? kAprilColorDark : const Color(0xFF6B7280)),
                      const SizedBox(width: 8),
                      Text(v.name[0].toUpperCase() + v.name.substring(1),
                        style: TextStyle(fontWeight: provider.wishlistView == v ? FontWeight.w600 : FontWeight.w400)),
                    ],
                  ),
                )).toList(),
              ),
            ],
          ),
          body: Column(
            children: [
              // Stats Bar
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _WishlistStat(label: 'Items', value: '${provider.filteredWishlistItems.length}'),
                    Container(width: 1, height: 30, color: kAprilColorDark.withOpacity(0.2)),
                    _WishlistStat(label: 'Total Value', value: '₵${provider.totalWishlistValue.toStringAsFixed(0)}'),
                    Container(width: 1, height: 30, color: kAprilColorDark.withOpacity(0.2)),
                    _WishlistStat(label: 'Saved', value: '₵${provider.totalWishlistSaved.toStringAsFixed(0)}'),
                  ],
                ),
              ),

              // Search + Filter
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: provider.setWishlistSearch,
                        decoration: InputDecoration(
                          hintText: 'Search wishlist...',
                          hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<WishlistPriority?>(
                      icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: provider.wishlistPriorityFilter != null ? kAprilColor : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Icon(Icons.filter_list, size: 20, color: provider.wishlistPriorityFilter != null ? Colors.black : const Color(0xFF6B7280)),
                      ),
                      onSelected: provider.setWishlistPriorityFilter,
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: null, child: Text('All Priorities')),
                        ...WishlistPriority.values.map((p) => PopupMenuItem(
                          value: p,
                          child: Row(
                            children: [
                              Text(_priorityStars(p)),
                              const SizedBox(width: 8),
                              Text(p.name[0].toUpperCase() + p.name.substring(1)),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ],
                ),
              ),

              // View Mode Chips
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  children: WishlistViewMode.values.map((v) => GestureDetector(
                    onTap: () => provider.setWishlistView(v),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: provider.wishlistView == v ? kAprilColor : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: provider.wishlistView == v ? kAprilColor : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(_viewIcon(v), size: 14, color: provider.wishlistView == v ? Colors.black : const Color(0xFF6B7280)),
                          const SizedBox(width: 4),
                          Text(v.name[0].toUpperCase() + v.name.substring(1),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                              color: provider.wishlistView == v ? Colors.black : const Color(0xFF6B7280))),
                        ],
                      ),
                    ),
                  )).toList(),
                ),
              ),

              // Wishlist Body
              Expanded(
                child: provider.filteredWishlistItems.isEmpty
                    ? const AprilEmptyState(
                        icon: Icons.favorite_border,
                        title: 'Wishlist empty',
                        message: 'Add items you want to save for',
                        ctaLabel: 'Add Item',
                      )
                    : Column(
                        children: [
                          // AI recommendations strip
                          Consumer<AIInsightsNotifier>(
                            builder: (ctx, aiNotifier, _) {
                              final recs = aiNotifier.recommendations;
                              if (recs.isEmpty) return const SizedBox.shrink();
                              return Container(
                                margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: kAprilColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: kAprilColor.withOpacity(0.2)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.auto_awesome, size: 14, color: kAprilColorDark),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'AI — ${recs.length} personalised picks based on your interests',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: kAprilColorDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          Expanded(child: _buildListView(context, provider)),
                        ],
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddItem(context),
            backgroundColor: kAprilColor,
            foregroundColor: Colors.black,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Add Item', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        );
      },
    );
  }

  Widget _buildListView(BuildContext context, AprilProvider provider) {
    final items = provider.filteredWishlistItems;
    switch (provider.wishlistView) {
      case WishlistViewMode.grid:
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) => WishlistItemCard(item: items[i]),
        );
      case WishlistViewMode.list:
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          itemCount: items.length,
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _WishlistListTile(item: items[i]),
          ),
        );
      case WishlistViewMode.priority:
        return _PriorityView(items: items);
      case WishlistViewMode.timeline:
        return _TimelineView(items: items);
    }
  }

  IconData _viewIcon(WishlistViewMode v) {
    switch (v) {
      case WishlistViewMode.grid: return Icons.grid_view;
      case WishlistViewMode.list: return Icons.view_list;
      case WishlistViewMode.priority: return Icons.star;
      case WishlistViewMode.timeline: return Icons.timeline;
    }
  }

  String _priorityStars(WishlistPriority p) {
    switch (p) {
      case WishlistPriority.low: return '⭐';
      case WishlistPriority.medium: return '⭐⭐';
      case WishlistPriority.high: return '⭐⭐⭐';
      case WishlistPriority.veryHigh: return '⭐⭐⭐⭐';
      case WishlistPriority.critical: return '⭐⭐⭐⭐⭐';
    }
  }

  void _showAddItem(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('Add to Wishlist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Add a new item to track', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
            const SizedBox(height: 20),

            // URL Import
            TextField(
              decoration: InputDecoration(
                hintText: 'Paste product URL to auto-fill...',
                hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                prefixIcon: const Icon(Icons.link, color: kAprilColorDark),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),

            // Manual Entry
            TextField(
              decoration: InputDecoration(
                hintText: 'Item name',
                hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                prefixIcon: const Icon(Icons.shopping_bag, color: Color(0xFF9CA3AF)),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Price (₵)',
                hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF9CA3AF)),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAprilColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Add to Wishlist', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// List Tile View
// ═══════════════════════════════════════════
class _WishlistListTile extends StatelessWidget {
  final WishlistItem item;
  const _WishlistListTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          // Image placeholder
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: kAprilColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shopping_bag, color: kAprilColorDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text('₵${item.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kAprilColorDark)),
                    const SizedBox(width: 8),
                    Text('${item.savedPercentage.toStringAsFixed(0)}% saved', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: (item.savedAmount / item.price).clamp(0.0, 1.0),
                    backgroundColor: const Color(0xFFF3F4F6),
                    valueColor: const AlwaysStoppedAnimation(kAprilSuccess),
                    minHeight: 3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _PriorityBadge(priority: item.priority),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// Priority View — Grouped by priority
// ═══════════════════════════════════════════
class _PriorityView extends StatelessWidget {
  final List<WishlistItem> items;
  const _PriorityView({required this.items});

  @override
  Widget build(BuildContext context) {
    final grouped = <WishlistPriority, List<WishlistItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.priority, () => []).add(item);
    }

    final sortedKeys = WishlistPriority.values.reversed.where((p) => grouped.containsKey(p)).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      children: sortedKeys.expand((priority) => [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              _PriorityBadge(priority: priority),
              const SizedBox(width: 8),
              Text('${priority.name[0].toUpperCase()}${priority.name.substring(1)} Priority',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${grouped[priority]!.length} items', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            ],
          ),
        ),
        ...grouped[priority]!.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _WishlistListTile(item: item),
        )),
      ]).toList(),
    );
  }
}

// ═══════════════════════════════════════════
// Timeline View — Items by added date
// ═══════════════════════════════════════════
class _TimelineView extends StatelessWidget {
  final List<WishlistItem> items;
  const _TimelineView({required this.items});

  @override
  Widget build(BuildContext context) {
    final sorted = List<WishlistItem>.from(items)..sort((a, b) => b.addedAt.compareTo(a.addedAt));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      itemCount: sorted.length,
      itemBuilder: (_, i) {
        final item = sorted[i];
        return IntrinsicHeight(
          child: Row(
            children: [
              // Timeline line
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    Container(width: 2, height: 12, color: i == 0 ? Colors.transparent : const Color(0xFFE5E7EB)),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: kAprilColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: kAprilColorDark, width: 2),
                      ),
                    ),
                    Expanded(child: Container(width: 2, color: i == sorted.length - 1 ? Colors.transparent : const Color(0xFFE5E7EB))),
                  ],
                ),
              ),
              // Card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _WishlistListTile(item: item),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════
// SHARED MINI WIDGETS
// ═══════════════════════════════════════════

class _WishlistStat extends StatelessWidget {
  final String label, value;
  const _WishlistStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kAprilColorDark)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
      ],
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final WishlistPriority priority;
  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final colors = {
      WishlistPriority.low: const Color(0xFF9CA3AF),
      WishlistPriority.medium: const Color(0xFF3B82F6),
      WishlistPriority.high: const Color(0xFFF59E0B),
      WishlistPriority.veryHigh: const Color(0xFFEF4444),
      WishlistPriority.critical: const Color(0xFF7C3AED),
    };
    final stars = {
      WishlistPriority.low: 1,
      WishlistPriority.medium: 2,
      WishlistPriority.high: 3,
      WishlistPriority.veryHigh: 4,
      WishlistPriority.critical: 5,
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        stars[priority]!,
        (_) => Icon(Icons.star, size: 12, color: colors[priority]),
      ),
    );
  }
}
