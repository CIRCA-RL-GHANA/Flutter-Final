/// ═══════════════════════════════════════════════════════════════════════════
/// MARKET MODULE — Screen 1.2: Advanced Filters
/// Bottom-sheet style screen with price range, delivery options,
/// dietary preferences, merchant attributes, sort, save filter sets
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../models/market_models.dart';
import '../providers/market_provider.dart';
import '../widgets/market_widgets.dart';

class MarketFiltersScreen extends StatefulWidget {
  const MarketFiltersScreen({super.key});

  @override
  State<MarketFiltersScreen> createState() => _MarketFiltersScreenState();
}

class _MarketFiltersScreenState extends State<MarketFiltersScreen> {
  RangeValues _priceRange = const RangeValues(0, 100);
  FulfillmentMethod? _fulfillment;
  double _maxDeliveryTime = 60;
  final Set<DietaryPreference> _dietary = {};
  bool _verifiedOnly = false;
  bool _familyOwned = false;
  bool _sustainable = false;
  SortOption _sort = SortOption.recommended;
  double _minRating = 0;
  int _resultCount = 42;

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Filters', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _clearAll,
            child: const Text('Clear all', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          // ── Price Range ──
          const _SectionHeader(title: 'Price Range', expanded: true),
          Row(
            children: [
              _PricePreset(label: '\$', active: _priceRange.end <= 10, onTap: () => setState(() => _priceRange = const RangeValues(0, 10))),
              _PricePreset(label: '\$\$', active: _priceRange.end <= 25, onTap: () => setState(() => _priceRange = const RangeValues(0, 25))),
              _PricePreset(label: '\$\$\$', active: _priceRange.end <= 50, onTap: () => setState(() => _priceRange = const RangeValues(0, 50))),
              _PricePreset(label: '\$\$\$\$', active: _priceRange.end > 50, onTap: () => setState(() => _priceRange = const RangeValues(0, 100))),
            ],
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 100,
            divisions: 20,
            activeColor: kMarketColor,
            labels: RangeLabels(
              '\$${_priceRange.start.toInt()}',
              '\$${_priceRange.end.toInt()}',
            ),
            onChanged: (v) => setState(() => _priceRange = v),
          ),
          const SizedBox(height: 8),

          // ── Delivery Options ──
          const _SectionHeader(title: 'Delivery Options'),
          _FilterTile(
            label: 'Delivery only',
            active: _fulfillment == FulfillmentMethod.delivery,
            onTap: () => setState(() => _fulfillment = _fulfillment == FulfillmentMethod.delivery ? null : FulfillmentMethod.delivery),
          ),
          _FilterTile(
            label: 'Pickup only',
            active: _fulfillment == FulfillmentMethod.pickup,
            onTap: () => setState(() => _fulfillment = _fulfillment == FulfillmentMethod.pickup ? null : FulfillmentMethod.pickup),
          ),
          _FilterTile(
            label: 'Both',
            active: _fulfillment == FulfillmentMethod.both,
            onTap: () => setState(() => _fulfillment = _fulfillment == FulfillmentMethod.both ? null : FulfillmentMethod.both),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Max delivery time: ${_maxDeliveryTime.toInt()} min',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
          Slider(
            value: _maxDeliveryTime,
            min: 15,
            max: 90,
            divisions: 5,
            activeColor: kMarketColor,
            label: '${_maxDeliveryTime.toInt()} min',
            onChanged: (v) => setState(() => _maxDeliveryTime = v),
          ),
          const SizedBox(height: 8),

          // ── Dietary & Preferences ──
          const _SectionHeader(title: 'Dietary & Preferences'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: DietaryPreference.values.map((d) {
              final isActive = _dietary.contains(d);
              return GestureDetector(
                onTap: () => setState(() {
                  isActive ? _dietary.remove(d) : _dietary.add(d);
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? kMarketColor.withOpacity(0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isActive ? kMarketColor : AppColors.inputBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _dietaryEmoji(d),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _dietaryLabel(d),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isActive ? kMarketColor : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // ── Merchant Attributes ──
          const _SectionHeader(title: 'Merchant Attributes'),
          SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: kMarketColor,
            title: const Text('Verified only', style: TextStyle(fontSize: 14)),
            value: _verifiedOnly,
            onChanged: (v) => setState(() => _verifiedOnly = v),
          ),
          SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: kMarketColor,
            title: const Text('Family-owned', style: TextStyle(fontSize: 14)),
            value: _familyOwned,
            onChanged: (v) => setState(() => _familyOwned = v),
          ),
          SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: kMarketColor,
            title: const Text('Sustainable', style: TextStyle(fontSize: 14)),
            value: _sustainable,
            onChanged: (v) => setState(() => _sustainable = v),
          ),
          const SizedBox(height: 8),

          // ── Rating ──
          const _SectionHeader(title: 'Minimum Rating'),
          Row(
            children: List.generate(5, (i) {
              final starVal = i + 1.0;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _minRating = starVal),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _minRating >= starVal ? kMarketColor.withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _minRating >= starVal ? kMarketColor : AppColors.inputBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _minRating >= starVal ? Icons.star : Icons.star_border,
                          size: 20,
                          color: _minRating >= starVal ? AppColors.warning : AppColors.textTertiary,
                        ),
                        Text(
                          '${i + 1}+',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _minRating >= starVal ? kMarketColor : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // ── Sort Options ──
          const _SectionHeader(title: 'Sort By'),
          ..._sortOptions.map((opt) {
            final (sort, label, icon) = opt;
            return RadioListTile<SortOption>(
              dense: true,
              contentPadding: EdgeInsets.zero,
              activeColor: kMarketColor,
              title: Row(
                children: [
                  Icon(icon, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(label, style: const TextStyle(fontSize: 14)),
                ],
              ),
              value: sort,
              groupValue: _sort,
              onChanged: (v) => setState(() => _sort = v!),
            );
          }),
          const SizedBox(height: 16),

          // ── Save Filter ──
          OutlinedButton.icon(
            onPressed: _saveFilter,
            icon: const Icon(Icons.bookmark_border, size: 18),
            label: const Text('Save as filter preset'),
            style: OutlinedButton.styleFrom(
              foregroundColor: kMarketColor,
              side: const BorderSide(color: kMarketColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
      // ── Sticky Footer ──
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _clearAll,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.inputBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Clear all'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  // Apply filters to provider
                  final prov = context.read<MarketProvider>();
                  prov.updateFilters(MarketFilters(
                    minPrice: _priceRange.start > 0 ? _priceRange.start : null,
                    maxPrice: _priceRange.end < 100 ? _priceRange.end : null,
                    fulfillmentFilter: _fulfillment,
                    maxDeliveryTime: _maxDeliveryTime < 90 ? _maxDeliveryTime.toInt() : null,
                    dietary: _dietary.toList(),
                    verifiedOnly: _verifiedOnly,
                    familyOwned: _familyOwned,
                    sustainable: _sustainable,
                    sort: _sort,
                    minRating: _minRating > 0 ? _minRating : null,
                  ));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kMarketColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Apply ($_resultCount items)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearAll() {
    setState(() {
      _priceRange = const RangeValues(0, 100);
      _fulfillment = null;
      _maxDeliveryTime = 60;
      _dietary.clear();
      _verifiedOnly = false;
      _familyOwned = false;
      _sustainable = false;
      _sort = SortOption.recommended;
      _minRating = 0;
    });
  }

  void _saveFilter() {
    showDialog(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Save Filter Preset'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'e.g. Quick Lunch',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                // Save filter preset
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Filter saved as "${controller.text}"')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: kMarketColor),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  String _dietaryLabel(DietaryPreference d) {
    switch (d) {
      case DietaryPreference.vegetarian:
        return 'Vegetarian';
      case DietaryPreference.vegan:
        return 'Vegan';
      case DietaryPreference.glutenFree:
        return 'Gluten-free';
      case DietaryPreference.halal:
        return 'Halal';
      case DietaryPreference.kosher:
        return 'Kosher';
      case DietaryPreference.organic:
        return 'Organic';
    }
  }

  String _dietaryEmoji(DietaryPreference d) {
    switch (d) {
      case DietaryPreference.vegetarian:
        return '🥬';
      case DietaryPreference.vegan:
        return '🌱';
      case DietaryPreference.glutenFree:
        return '🌾';
      case DietaryPreference.halal:
        return '☪';
      case DietaryPreference.kosher:
        return '✡';
      case DietaryPreference.organic:
        return '🌿';
    }
  }

  static const _sortOptions = [
    (SortOption.recommended, 'Recommended (AI)', Icons.auto_awesome),
    (SortOption.distance, 'Distance', Icons.near_me),
    (SortOption.rating, 'Rating', Icons.star),
    (SortOption.deliveryTime, 'Delivery time', Icons.timer),
    (SortOption.priceLow, 'Price (low-high)', Icons.arrow_upward),
    (SortOption.priceHigh, 'Price (high-low)', Icons.arrow_downward),
  ];
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool expanded;

  const _SectionHeader({required this.title, this.expanded = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _FilterTile extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterTile({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: active ? kMarketColor.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? kMarketColor : AppColors.inputBorder),
        ),
        child: Row(
          children: [
            Icon(
              active ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              size: 20,
              color: active ? kMarketColor : AppColors.textTertiary,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? kMarketColor : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PricePreset extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _PricePreset({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? kMarketColor.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: active ? kMarketColor : AppColors.inputBorder),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: active ? kMarketColor : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
