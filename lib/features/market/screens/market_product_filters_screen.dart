/// ═══════════════════════════════════════════════════════════════════════════
/// MARKET MODULE — Screen 3.1: Product Filters
/// Advanced product filtering: price, dietary, availability, category
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../models/market_models.dart';
import '../providers/market_provider.dart';
import '../widgets/market_widgets.dart';

class MarketProductFiltersScreen extends StatefulWidget {
  const MarketProductFiltersScreen({super.key});

  @override
  State<MarketProductFiltersScreen> createState() => _MarketProductFiltersScreenState();
}

class _MarketProductFiltersScreenState extends State<MarketProductFiltersScreen> {
  RangeValues _priceRange = const RangeValues(0, 100);
  final Set<DietaryPreference> _dietary = {};
  final Set<ProductAvailability> _availability = {ProductAvailability.inStock};
  double _minRating = 0;
  bool _discountedOnly = false;
  bool _organicOnly = false;
  bool _localOnly = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketProvider>(
      builder: (context, prov, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: MarketAppBar(
            title: 'Product Filters',
            actions: [
              TextButton(
                onPressed: _resetAll,
                child: const Text('Reset', style: TextStyle(color: kMarketColor)),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
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
              // Price range
              _SectionHeader(title: 'Price Range', icon: Icons.attach_money),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${_priceRange.start.toInt()}',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: kMarketColor),
                          ),
                          Text(
                            '\$${_priceRange.end.toInt()}',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: kMarketColor),
                          ),
                        ],
                      ),
                      RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: 200,
                        divisions: 20,
                        activeColor: kMarketColor,
                        inactiveColor: kMarketColorLight,
                        onChanged: (v) => setState(() => _priceRange = v),
                      ),
                      // Presets
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _PricePreset(label: 'Under \$10', onTap: () => setState(() => _priceRange = const RangeValues(0, 10))),
                          _PricePreset(label: '\$10–\$25', onTap: () => setState(() => _priceRange = const RangeValues(10, 25))),
                          _PricePreset(label: '\$25–\$50', onTap: () => setState(() => _priceRange = const RangeValues(25, 50))),
                          _PricePreset(label: '\$50+', onTap: () => setState(() => _priceRange = const RangeValues(50, 200))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Dietary preferences
              _SectionHeader(title: 'Dietary Preferences', icon: Icons.eco),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: DietaryPreference.values.map((d) {
                      final label = _dietaryLabel(d);
                      final isSelected = _dietary.contains(d);
                      return FilterChip(
                        label: Text(label),
                        selected: isSelected,
                        selectedColor: kMarketColorLight,
                        checkmarkColor: kMarketColorDark,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: isSelected ? kMarketColorDark : AppColors.textSecondary,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: BorderSide(color: isSelected ? kMarketColor : AppColors.inputBorder),
                        onSelected: (sel) {
                          setState(() {
                            if (sel) {
                              _dietary.add(d);
                            } else {
                              _dietary.remove(d);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Availability
              _SectionHeader(title: 'Availability', icon: Icons.inventory),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                color: Colors.white,
                child: Column(
                  children: ProductAvailability.values.map((a) {
                    return CheckboxListTile(
                      value: _availability.contains(a),
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            _availability.add(a);
                          } else {
                            _availability.remove(a);
                          }
                        });
                      },
                      title: Text(_availabilityLabel(a), style: const TextStyle(fontSize: 14)),
                      activeColor: kMarketColor,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Rating
              _SectionHeader(title: 'Minimum Rating', icon: Icons.star),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final star = i + 1;
                      return GestureDetector(
                        onTap: () => setState(() => _minRating = star.toDouble()),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            star <= _minRating ? Icons.star : Icons.star_border,
                            size: 36,
                            color: star <= _minRating ? AppColors.accent : AppColors.textTertiary,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Toggles
              _SectionHeader(title: 'More Options', icon: Icons.settings),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                color: Colors.white,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Discounted only', style: TextStyle(fontSize: 14)),
                      subtitle: const Text('Show only items on sale', style: TextStyle(fontSize: 12)),
                      value: _discountedOnly,
                      activeColor: kMarketColor,
                      onChanged: (v) => setState(() => _discountedOnly = v),
                    ),
                    const Divider(height: 0, indent: 16, endIndent: 16),
                    SwitchListTile(
                      title: const Text('Organic only', style: TextStyle(fontSize: 14)),
                      subtitle: const Text('Certified organic products', style: TextStyle(fontSize: 12)),
                      value: _organicOnly,
                      activeColor: kMarketColor,
                      onChanged: (v) => setState(() => _organicOnly = v),
                    ),
                    const Divider(height: 0, indent: 16, endIndent: 16),
                    SwitchListTile(
                      title: const Text('Locally sourced', style: TextStyle(fontSize: 14)),
                      subtitle: const Text('Products from local producers', style: TextStyle(fontSize: 12)),
                      value: _localOnly,
                      activeColor: kMarketColor,
                      onChanged: (v) => setState(() => _localOnly = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
          // Sticky footer
          bottomNavigationBar: Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetAll,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kMarketColor,
                      side: const BorderSide(color: kMarketColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Clear All'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kMarketColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: Text('Apply Filters (${_activeCount})'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int get _activeCount {
    int c = 0;
    if (_priceRange.start > 0 || _priceRange.end < 200) c++;
    c += _dietary.length;
    if (_availability.length != 1 || !_availability.contains(ProductAvailability.inStock)) c++;
    if (_minRating > 0) c++;
    if (_discountedOnly) c++;
    if (_organicOnly) c++;
    if (_localOnly) c++;
    return c;
  }

  void _resetAll() {
    setState(() {
      _priceRange = const RangeValues(0, 100);
      _dietary.clear();
      _availability
        ..clear()
        ..add(ProductAvailability.inStock);
      _minRating = 0;
      _discountedOnly = false;
      _organicOnly = false;
      _localOnly = false;
    });
  }

  String _dietaryLabel(DietaryPreference d) {
    switch (d) {
      case DietaryPreference.vegetarian:
        return '🥬 Vegetarian';
      case DietaryPreference.vegan:
        return '🌱 Vegan';
      case DietaryPreference.glutenFree:
        return '🌾 Gluten-free';
      case DietaryPreference.halal:
        return '🕌 Halal';
      case DietaryPreference.kosher:
        return '✡ Kosher';
      case DietaryPreference.organic:
        return '🌿 Organic';
    }
  }

  String _availabilityLabel(ProductAvailability a) {
    switch (a) {
      case ProductAvailability.inStock:
        return 'In stock';
      case ProductAvailability.lowStock:
        return 'Low stock';
      case ProductAvailability.outOfStock:
        return 'Out of stock';
      case ProductAvailability.preOrder:
        return 'Pre-order';
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: kMarketColor),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _PricePreset extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PricePreset({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.inputBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ),
    );
  }
}
