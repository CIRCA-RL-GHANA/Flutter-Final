/// ═══════════════════════════════════════════════════════════════════════════
/// MARKET MODULE — Shared Widgets
/// Reusable UI components: MarketAppBar, MerchantCard, ProductCard,
/// CartPreview, StatusTimeline, RatingStars, PriceTag, CategoryChip,
/// MarketFilterChipRow, MarketSectionTitle, MarketSearchBar, etc.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../models/market_models.dart';

// ─── Market Module Color ─────────────────────────────────────────────────────

/// The canonical module color for Market (Emerald Green)
const Color kMarketColor = Color(0xFF10B981);
const Color kMarketColorLight = Color(0xFFD1FAE5);
const Color kMarketColorDark = Color(0xFF065F46);

// ─── Market App Bar ──────────────────────────────────────────────────────────

class MarketAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final Color? backgroundColor;

  const MarketAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.backgroundColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: showBackButton
          ? Row(
              children: [
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 22),
                  color: AppColors.textPrimary,
                  onPressed: () => Navigator.pop(context),
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: kMarketColor,
                  ),
                ),
              ],
            )
          : leading,
      leadingWidth: showBackButton ? 70 : 56,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
      actions: actions,
    );
  }
}

// ─── Merchant Card ───────────────────────────────────────────────────────────

class MerchantCard extends StatelessWidget {
  final Merchant merchant;
  final VoidCallback? onTap;
  final VoidCallback? onOrder;
  final bool compact;

  const MerchantCard({
    super.key,
    required this.merchant,
    this.onTap,
    this.onOrder,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner / Image
            Stack(
              children: [
                Container(
                  height: compact ? 100 : 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: kMarketColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Center(
                    child: Icon(
                      _categoryIcon(merchant.category),
                      size: compact ? 32 : 48,
                      color: kMarketColor.withOpacity(0.4),
                    ),
                  ),
                ),
                // Favorite
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      merchant.isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: merchant.isFavorite ? AppColors.error : AppColors.textSecondary,
                    ),
                  ),
                ),
                // Trending badge
                if (merchant.isTrending)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'TRENDING',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                // Status badge
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: merchant.statusColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      merchant.isOpen ? 'OPEN' : 'CLOSED',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          merchant.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (merchant.verification != VerificationTier.none)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.verified,
                            size: 16,
                            color: merchant.verification == VerificationTier.premium
                                ? AppColors.accent
                                : kMarketColor,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Tags
                  if (merchant.tags.isNotEmpty)
                    Text(
                      merchant.tags.join(' • '),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  // Rating, distance, time
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: AppColors.warning),
                      const SizedBox(width: 2),
                      Text(
                        '${merchant.ratingDisplay}★',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${merchant.distanceMiles}mi',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        merchant.deliveryTimeDisplay,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  if (!compact) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          merchant.deliveryFeeDisplay,
                          style: TextStyle(
                            fontSize: 12,
                            color: merchant.deliveryFee == 0 ? kMarketColor : AppColors.textSecondary,
                            fontWeight: merchant.deliveryFee == 0 ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        if (merchant.minimumOrder > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            'Min \$${merchant.minimumOrder.toStringAsFixed(0)}',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 36,
                            child: ElevatedButton(
                              onPressed: onOrder ?? onTap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kMarketColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              child: const Text('Order'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 36,
                          child: OutlinedButton(
                            onPressed: onTap,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: kMarketColor,
                              side: const BorderSide(color: kMarketColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            child: const Text('View'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(MerchantCategory cat) {
    switch (cat) {
      case MerchantCategory.food:
        return Icons.restaurant;
      case MerchantCategory.drinks:
        return Icons.local_cafe;
      case MerchantCategory.pharmacy:
        return Icons.local_pharmacy;
      case MerchantCategory.services:
        return Icons.miscellaneous_services;
      case MerchantCategory.electronics:
        return Icons.devices;
      case MerchantCategory.fashion:
        return Icons.checkroom;
      case MerchantCategory.grocery:
        return Icons.shopping_basket;
      default:
        return Icons.store;
    }
  }
}

// ─── Product Card ────────────────────────────────────────────────────────────

class MarketProductCard extends StatelessWidget {
  final MarketProduct product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool isListView;

  const MarketProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.isListView = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isListView) return _buildListView(context);
    return _buildGridView(context);
  }

  Widget _buildGridView(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: kMarketColor.withOpacity(0.08),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Icon(Icons.image, size: 40, color: kMarketColor.withOpacity(0.3)),
                ),
                if (product.badges.isNotEmpty)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: product.badges.first == 'NEW'
                            ? AppColors.info
                            : product.badges.first == 'LIMITED'
                                ? AppColors.error
                                : AppColors.warning,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.badges.first,
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (product.rating > 0)
                    Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: AppColors.warning),
                        const SizedBox(width: 2),
                        Text(
                          '${product.rating.toStringAsFixed(1)} (${product.ratingCount})',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.priceDisplay,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kMarketColor),
                          ),
                          if (product.hasDiscount)
                            Text(
                              product.comparePriceDisplay,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          onAddToCart?.call();
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: kMarketColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 20),
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
    );
  }

  Widget _buildListView(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            // Image
            Stack(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: kMarketColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.image, size: 32, color: kMarketColor.withOpacity(0.3)),
                ),
                if (product.badges.isNotEmpty)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.badges.first,
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (product.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      product.description!,
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: AppColors.warning),
                      const SizedBox(width: 2),
                      Text(
                        '${product.rating.toStringAsFixed(1)} (${product.ratingCount})',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  if (product.hasCustomization) ...[
                    const SizedBox(height: 2),
                    Text(
                      product.customizationNote ?? 'Customizable',
                      style: TextStyle(fontSize: 11, color: kMarketColor),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Price + Add
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  product.priceDisplay,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                if (product.hasDiscount)
                  Text(
                    product.comparePriceDisplay,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onAddToCart?.call();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: kMarketColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Rating Stars ────────────────────────────────────────────────────────────

class RatingStars extends StatelessWidget {
  final double rating;
  final int count;
  final double size;
  final bool showCount;

  const RatingStars({
    super.key,
    required this.rating,
    this.count = 0,
    this.size = 16,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          if (i < rating.floor()) {
            return Icon(Icons.star, size: size, color: AppColors.warning);
          } else if (i < rating) {
            return Icon(Icons.star_half, size: size, color: AppColors.warning);
          }
          return Icon(Icons.star_border, size: size, color: AppColors.textTertiary);
        }),
        if (showCount && count > 0) ...[
          const SizedBox(width: 4),
          Text(
            '($count)',
            style: TextStyle(fontSize: size * 0.75, color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }
}

// ─── Price Tag ───────────────────────────────────────────────────────────────

class PriceTag extends StatelessWidget {
  final double price;
  final double? comparePrice;
  final double fontSize;

  const PriceTag({
    super.key,
    required this.price,
    this.comparePrice,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '\$${price.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: kMarketColor,
          ),
        ),
        if (comparePrice != null && comparePrice! > price) ...[
          const SizedBox(width: 6),
          Text(
            '\$${comparePrice!.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: fontSize * 0.72,
              color: AppColors.textTertiary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Category Chip Row ───────────────────────────────────────────────────────

class MarketCategoryChipRow extends StatelessWidget {
  final MerchantCategory selected;
  final ValueChanged<MerchantCategory> onSelected;

  const MarketCategoryChipRow({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cats = [
      (MerchantCategory.all, 'All', Icons.apps),
      (MerchantCategory.food, 'Food', Icons.restaurant),
      (MerchantCategory.drinks, 'Drinks', Icons.local_cafe),
      (MerchantCategory.pharmacy, 'Pharmacy', Icons.local_pharmacy),
      (MerchantCategory.services, 'Services', Icons.miscellaneous_services),
      (MerchantCategory.electronics, 'Electronics', Icons.devices),
      (MerchantCategory.fashion, 'Fashion', Icons.checkroom),
      (MerchantCategory.grocery, 'Grocery', Icons.shopping_basket),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (cat, label, icon) = cats[i];
          final isActive = cat == selected;
          return GestureDetector(
            onTap: () => onSelected(cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? kMarketColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: isActive ? null : Border.all(color: AppColors.inputBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: isActive ? Colors.white : AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Quick Filter Chips ──────────────────────────────────────────────────────

class MarketQuickFilterChips extends StatelessWidget {
  final List<String> filters;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const MarketQuickFilterChips({
    super.key,
    required this.filters,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final filter = filters[i];
          final isActive = selected.contains(filter);
          return GestureDetector(
            onTap: () => onToggle(filter),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? kMarketColor.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isActive ? kMarketColor : AppColors.inputBorder,
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isActive ? kMarketColor : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Section Title ───────────────────────────────────────────────────────────

class MarketSectionTitle extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;
  final IconData? icon;

  const MarketSectionTitle({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: kMarketColor),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (actionText != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionText!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kMarketColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Search Bar ──────────────────────────────────────────────────────────────

class MarketSearchBar extends StatelessWidget {
  final String hint;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool autofocus;

  const MarketSearchBar({
    super.key,
    this.hint = 'Search products, merchants...',
    this.onTap,
    this.onChanged,
    this.controller,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: AppColors.textTertiary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: onTap != null
                  ? Text(
                      hint,
                      style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
                    )
                  : TextField(
                      controller: controller,
                      autofocus: autofocus,
                      onChanged: onChanged,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: hint,
                        hintStyle: TextStyle(fontSize: 14, color: AppColors.textTertiary),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
            ),
            Icon(Icons.mic, color: AppColors.textTertiary, size: 22),
          ],
        ),
      ),
    );
  }
}

// ─── Order Status Timeline ───────────────────────────────────────────────────

class OrderStatusTimeline extends StatelessWidget {
  final List<TrackingEvent> events;

  const OrderStatusTimeline({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(events.length, (i) {
        final event = events[i];
        final isLast = i == events.length - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: event.isCompleted
                        ? kMarketColor
                        : event.isCurrent
                            ? AppColors.info
                            : AppColors.inputFill,
                    border: event.isCurrent
                        ? Border.all(color: AppColors.info, width: 2)
                        : null,
                  ),
                  child: event.isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : event.isCurrent
                          ? Container(
                              margin: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.info,
                              ),
                            )
                          : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: event.isCompleted ? kMarketColor : AppColors.inputBorder,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: event.isCurrent ? FontWeight.w700 : FontWeight.w500,
                        color: event.isCompleted || event.isCurrent
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                      ),
                    ),
                    if (event.detail != null)
                      Text(
                        event.detail!,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    if (event.timestamp != null)
                      Text(
                        _formatTime(event.timestamp!),
                        style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${h == 0 ? 12 : h}:${dt.minute.toString().padLeft(2, '0')} $amPm';
  }
}

// ─── Cart Preview Badge ──────────────────────────────────────────────────────

class CartPreviewBadge extends StatelessWidget {
  final int itemCount;
  final VoidCallback? onTap;

  const CartPreviewBadge({
    super.key,
    required this.itemCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) return const SizedBox.shrink();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: kMarketColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: kMarketColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.shopping_cart, color: Colors.white, size: 24),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$itemCount',
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Order Card ──────────────────────────────────────────────────────────────

class MarketOrderCard extends StatelessWidget {
  final MarketOrder order;
  final VoidCallback? onTap;
  final VoidCallback? onTrack;
  final VoidCallback? onReorder;

  const MarketOrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onTrack,
    this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: order.isActive
              ? Border.all(color: order.statusColor.withOpacity(0.3), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Merchant icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kMarketColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.store, size: 20, color: kMarketColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.merchantName,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${order.id} • ${_timeAgo(order.createdAt)}',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: order.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    order.statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: order.statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Items preview
            ...order.items.take(2).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: kMarketColor.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(Icons.fastfood, size: 16, color: kMarketColor.withOpacity(0.4)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${item.quantity}× ${item.name}',
                          style: const TextStyle(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '\$${item.total.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )),
            if (order.items.length > 2)
              Text(
                '+${order.items.length - 2} more items',
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
              ),
            const Divider(height: 20),
            Row(
              children: [
                Text(
                  'Total: \$${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                if (order.isActive && onTrack != null)
                  _ActionButton(label: 'Track', color: kMarketColor, onTap: onTrack!),
                if (order.isDelivered && onReorder != null) ...[
                  _ActionButton(label: 'Reorder', color: kMarketColor, onTap: onReorder!),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ─── Market Info Row ─────────────────────────────────────────────────────────

class MarketInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const MarketInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Market Section Card ─────────────────────────────────────────────────────

class MarketSectionCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final List<Widget> children;
  final Color? borderColor;

  const MarketSectionCard({
    super.key,
    required this.title,
    this.icon,
    required this.children,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: kMarketColor),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

// ─── KPI Badge ───────────────────────────────────────────────────────────────

class MarketKPIBadge extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const MarketKPIBadge({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? kMarketColor;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: c),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: c,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────

class MarketEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const MarketEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kMarketColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Quantity Selector ───────────────────────────────────────────────────────

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.min = 1,
    this.max = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyButton(
            icon: Icons.remove,
            enabled: quantity > min,
            onTap: () => onChanged(quantity - 1),
          ),
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          _QtyButton(
            icon: Icons.add,
            enabled: quantity < max,
            onTap: () => onChanged(quantity + 1),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: enabled ? kMarketColor : AppColors.textTertiary,
        ),
      ),
    );
  }
}
