/// ═══════════════════════════════════════════════════════════════════════════
/// MARKET MODULE — Data Models
/// Comprehensive models for unified commerce & logistics:
/// Market Hub, Search, Filters, Merchants, Products, Cart, Orders,
/// Transactions, Self-Pickup, Returns, Delivery Tracking, Ride Hailing
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

// ─── Enums ──────────────────────────────────────────────────────────────────

/// Merchant operational status
enum MerchantStatus { open, closed, busy, temporarilyClosed }

/// Merchant verification tier
enum VerificationTier { none, basic, verified, premium }

/// Product availability
enum ProductAvailability { inStock, lowStock, outOfStock, preOrder }

/// Fulfillment method
enum FulfillmentMethod { delivery, pickup, both, dineIn }

/// Cart item status
enum CartItemStatus { available, priceChanged, outOfStock, lowStock }

/// Order status lifecycle
enum OrderStatus {
  pending,
  confirmed,
  preparing,
  readyForPickup,
  onTheWay,
  delivered,
  pickedUp,
  cancelled,
  refunded,
}

/// Return status
enum ReturnStatus {
  requested,
  evidenceSubmitted,
  underReview,
  approved,
  rejected,
  refundProcessed,
}

/// Return reason
enum ReturnReason {
  damaged,
  wrongItem,
  expired,
  notAsDescribed,
  changedMind,
  other,
}

/// Refund method
enum RefundMethod { originalPayment, storeCredit, qPoints, replacement }

/// Ride status
enum RideStatus {
  searching,
  driverAssigned,
  driverEnRoute,
  arrived,
  inProgress,
  completed,
  cancelled,
}

/// Ride type
enum RideType { standard, premium, xl, eco, assist }

/// Delivery tracker step
enum DeliveryStep { confirmed, preparing, onTheWay, delivered }

/// Payment method type
enum PaymentMethodType { card, qPoints, tabCredit, applePay, googlePay, paypal }

/// Deal / promo type
enum DealType { percentage, fixedAmount, freeDelivery, buyOneGetOne, bundle }

/// Merchant category
enum MerchantCategory { all, food, drinks, pharmacy, services, electronics, fashion, grocery, other }

/// Sort option for products / merchants
enum SortOption { recommended, distance, rating, deliveryTime, priceLow, priceHigh, popularity, newest }

/// Transaction type
enum TransactionType { order, ride, returnRefund }

/// Pickup phase
enum PickupPhase { preparation, arrival, verification, handoff, complete }

/// Diet / preference filter
enum DietaryPreference { vegetarian, vegan, glutenFree, halal, kosher, organic }

// ─── Merchant Models ────────────────────────────────────────────────────────

/// A merchant / vendor in the marketplace
class Merchant {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? bannerUrl;
  final String? videoUrl;
  final MerchantStatus status;
  final VerificationTier verification;
  final MerchantCategory category;
  final List<String> tags;
  final double rating;
  final int ratingCount;
  final double distanceMiles;
  final int deliveryTimeMin;
  final int deliveryTimeMax;
  final double deliveryFee;
  final double minimumOrder;
  final FulfillmentMethod fulfillment;
  final String address;
  final String? phone;
  final String? email;
  final String? website;
  final Map<String, String> hours; // e.g. {'Mon': '8AM-10PM', ...}
  final bool isFavorite;
  final bool isTrending;
  final int activeDeals;
  final List<String> gallery;

  const Merchant({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.bannerUrl,
    this.videoUrl,
    this.status = MerchantStatus.open,
    this.verification = VerificationTier.none,
    this.category = MerchantCategory.food,
    this.tags = const [],
    this.rating = 0.0,
    this.ratingCount = 0,
    this.distanceMiles = 0.0,
    this.deliveryTimeMin = 15,
    this.deliveryTimeMax = 30,
    this.deliveryFee = 0.0,
    this.minimumOrder = 0.0,
    this.fulfillment = FulfillmentMethod.both,
    this.address = '',
    this.phone,
    this.email,
    this.website,
    this.hours = const {},
    this.isFavorite = false,
    this.isTrending = false,
    this.activeDeals = 0,
    this.gallery = const [],
  });

  bool get isOpen => status == MerchantStatus.open;

  String get deliveryTimeDisplay => '$deliveryTimeMin-$deliveryTimeMax min';

  String get deliveryFeeDisplay =>
      deliveryFee == 0 ? 'Free delivery' : '\$${deliveryFee.toStringAsFixed(2)}';

  String get ratingDisplay => rating.toStringAsFixed(1);

  Color get statusColor {
    switch (status) {
      case MerchantStatus.open:
        return const Color(0xFF10B981);
      case MerchantStatus.busy:
        return const Color(0xFFF59E0B);
      case MerchantStatus.closed:
      case MerchantStatus.temporarilyClosed:
        return const Color(0xFFEF4444);
    }
  }
}

/// A deal / discount from a merchant
class MerchantDeal {
  final String id;
  final String merchantId;
  final String title;
  final String? description;
  final DealType type;
  final double value;
  final String? code;
  final DateTime? expiresAt;
  final int? maxRedemptions;
  final int currentRedemptions;
  final List<String> applicableProductIds;
  final double? minimumOrder;
  final bool isPersonalized;

  const MerchantDeal({
    required this.id,
    required this.merchantId,
    required this.title,
    this.description,
    this.type = DealType.percentage,
    this.value = 0.0,
    this.code,
    this.expiresAt,
    this.maxRedemptions,
    this.currentRedemptions = 0,
    this.applicableProductIds = const [],
    this.minimumOrder,
    this.isPersonalized = false,
  });

  String get valueDisplay {
    switch (type) {
      case DealType.percentage:
        return '${value.toInt()}% OFF';
      case DealType.fixedAmount:
        return '\$${value.toStringAsFixed(2)} OFF';
      case DealType.freeDelivery:
        return 'FREE DELIVERY';
      case DealType.buyOneGetOne:
        return 'BOGO';
      case DealType.bundle:
        return 'BUNDLE DEAL';
    }
  }

  double get redemptionProgress =>
      maxRedemptions != null && maxRedemptions! > 0
          ? currentRedemptions / maxRedemptions!
          : 0.0;
}

/// A merchant post / update (for Branch view Updates tab)
class MerchantPost {
  final String id;
  final String merchantId;
  final String content;
  final String? imageUrl;
  final String? videoUrl;
  final String postType; // 'image', 'video', 'announcement', 'event'
  final DateTime createdAt;
  final int views;
  final int likes;
  final int shares;
  final bool isLiked;

  const MerchantPost({
    required this.id,
    required this.merchantId,
    required this.content,
    this.imageUrl,
    this.videoUrl,
    this.postType = 'image',
    required this.createdAt,
    this.views = 0,
    this.likes = 0,
    this.shares = 0,
    this.isLiked = false,
  });
}

// ─── Product Models ─────────────────────────────────────────────────────────

/// A product within a merchant's catalogue
class MarketProduct {
  final String id;
  final String merchantId;
  final String name;
  final String? description;
  final String? imageUrl;
  final List<String> images;
  final double price;
  final double? comparePrice;
  final String? unitPrice;
  final MerchantCategory category;
  final String categoryName;
  final ProductAvailability availability;
  final double rating;
  final int ratingCount;
  final List<String> badges; // 'BESTSELLER', 'NEW', 'LIMITED'
  final List<DietaryPreference> dietary;
  final bool hasCustomization;
  final String? customizationNote;
  final List<ProductVariant> variants;
  final List<ProductAddon> addons;
  final NutritionInfo? nutritionInfo;
  final Map<String, String> specifications;
  final List<String> allergens;

  const MarketProduct({
    required this.id,
    required this.merchantId,
    required this.name,
    this.description,
    this.imageUrl,
    this.images = const [],
    required this.price,
    this.comparePrice,
    this.unitPrice,
    this.category = MerchantCategory.food,
    this.categoryName = 'General',
    this.availability = ProductAvailability.inStock,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.badges = const [],
    this.dietary = const [],
    this.hasCustomization = false,
    this.customizationNote,
    this.variants = const [],
    this.addons = const [],
    this.nutritionInfo,
    this.specifications = const {},
    this.allergens = const [],
  });

  bool get hasDiscount => comparePrice != null && comparePrice! > price;

  double get discountPercent =>
      hasDiscount ? ((comparePrice! - price) / comparePrice! * 100) : 0;

  String get priceDisplay => '\$${price.toStringAsFixed(2)}';

  String get comparePriceDisplay =>
      comparePrice != null ? '\$${comparePrice!.toStringAsFixed(2)}' : '';

  bool get isAvailable => availability == ProductAvailability.inStock ||
      availability == ProductAvailability.lowStock;
}

/// A product variant (size, color, etc.)
class ProductVariant {
  final String id;
  final String name;
  final String value;
  final double? priceAdjustment;
  final bool isSelected;

  const ProductVariant({
    required this.id,
    required this.name,
    required this.value,
    this.priceAdjustment,
    this.isSelected = false,
  });
}

/// A product add-on (extra cheese, etc.)
class ProductAddon {
  final String id;
  final String name;
  final double price;
  final bool isSelected;
  final int maxSelections;

  const ProductAddon({
    required this.id,
    required this.name,
    required this.price,
    this.isSelected = false,
    this.maxSelections = 1,
  });
}

/// Nutrition information for food products
class NutritionInfo {
  final int calories;
  final double fat;
  final double carbs;
  final double protein;
  final double fiber;
  final double sugar;
  final double sodium;

  const NutritionInfo({
    this.calories = 0,
    this.fat = 0,
    this.carbs = 0,
    this.protein = 0,
    this.fiber = 0,
    this.sugar = 0,
    this.sodium = 0,
  });
}

/// A product category within a merchant
class ProductCategory {
  final String id;
  final String name;
  final IconData icon;
  final int itemCount;
  final String? imageUrl;
  final List<String> topProductIds;

  const ProductCategory({
    required this.id,
    required this.name,
    required this.icon,
    this.itemCount = 0,
    this.imageUrl,
    this.topProductIds = const [],
  });
}

// ─── Cart Models ────────────────────────────────────────────────────────────

/// An item in the shopping cart
class CartItem {
  final String id;
  final MarketProduct product;
  final int quantity;
  final List<ProductVariant> selectedVariants;
  final List<ProductAddon> selectedAddons;
  final String? specialInstructions;
  final CartItemStatus status;

  const CartItem({
    required this.id,
    required this.product,
    this.quantity = 1,
    this.selectedVariants = const [],
    this.selectedAddons = const [],
    this.specialInstructions,
    this.status = CartItemStatus.available,
  });

  double get unitPrice {
    double base = product.price;
    for (final v in selectedVariants) {
      base += v.priceAdjustment ?? 0;
    }
    for (final a in selectedAddons) {
      base += a.price;
    }
    return base;
  }

  double get totalPrice => unitPrice * quantity;

  String get totalDisplay => '\$${totalPrice.toStringAsFixed(2)}';

  String get customizationSummary {
    final parts = <String>[];
    for (final v in selectedVariants) {
      parts.add('${v.name}: ${v.value}');
    }
    for (final a in selectedAddons) {
      parts.add(a.name);
    }
    return parts.join(', ');
  }
}

/// Cart summary / financial breakdown
class CartSummary {
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double tax;
  final double discount;
  final double qPointsApplied;
  final double tabCreditApplied;
  final double promoDiscount;

  const CartSummary({
    this.subtotal = 0,
    this.deliveryFee = 0,
    this.serviceFee = 1.99,
    this.tax = 0,
    this.discount = 0,
    this.qPointsApplied = 0,
    this.tabCreditApplied = 0,
    this.promoDiscount = 0,
  });

  double get total =>
      subtotal + deliveryFee + serviceFee + tax - discount - qPointsApplied - tabCreditApplied - promoDiscount;

  String get totalDisplay => '\$${total.toStringAsFixed(2)}';

  double get freeDeliveryProgress {
    const threshold = 25.0;
    return (subtotal / threshold).clamp(0.0, 1.0);
  }

  double get amountToFreeDelivery {
    const threshold = 25.0;
    return (threshold - subtotal).clamp(0.0, threshold);
  }
}

// ─── Order Models ───────────────────────────────────────────────────────────

/// A completed or in-progress order
class MarketOrder {
  final String id;
  final String merchantId;
  final String merchantName;
  final String? merchantLogo;
  final OrderStatus status;
  final FulfillmentMethod fulfillment;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double tax;
  final double discount;
  final double total;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  final DateTime? deliveredAt;
  final String? driverName;
  final String? driverPhone;
  final double? driverRating;
  final String? vehicleInfo;
  final String? deliveryAddress;
  final String? deliveryInstructions;
  final String? pickupCode;
  final String? trackingPin;
  final PaymentMethodType paymentMethod;
  final bool isRated;

  const MarketOrder({
    required this.id,
    required this.merchantId,
    required this.merchantName,
    this.merchantLogo,
    this.status = OrderStatus.pending,
    this.fulfillment = FulfillmentMethod.delivery,
    this.items = const [],
    this.subtotal = 0,
    this.deliveryFee = 0,
    this.serviceFee = 0,
    this.tax = 0,
    this.discount = 0,
    this.total = 0,
    required this.createdAt,
    this.estimatedDelivery,
    this.deliveredAt,
    this.driverName,
    this.driverPhone,
    this.driverRating,
    this.vehicleInfo,
    this.deliveryAddress,
    this.deliveryInstructions,
    this.pickupCode,
    this.trackingPin,
    this.paymentMethod = PaymentMethodType.card,
    this.isRated = false,
  });

  bool get isActive =>
      status == OrderStatus.pending ||
      status == OrderStatus.confirmed ||
      status == OrderStatus.preparing ||
      status == OrderStatus.readyForPickup ||
      status == OrderStatus.onTheWay;

  bool get isDelivered => status == OrderStatus.delivered || status == OrderStatus.pickedUp;

  bool get canReturn =>
      isDelivered &&
      DateTime.now().difference(deliveredAt ?? createdAt).inDays <= 7;

  Color get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return const Color(0xFFF59E0B);
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
        return const Color(0xFF3B82F6);
      case OrderStatus.readyForPickup:
        return const Color(0xFF8B5CF6);
      case OrderStatus.onTheWay:
        return const Color(0xFF3B82F6);
      case OrderStatus.delivered:
      case OrderStatus.pickedUp:
        return const Color(0xFF10B981);
      case OrderStatus.cancelled:
        return const Color(0xFFEF4444);
      case OrderStatus.refunded:
        return const Color(0xFF6B7280);
    }
  }

  String get statusLabel {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.readyForPickup:
        return 'Ready for Pickup';
      case OrderStatus.onTheWay:
        return 'On the Way';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.pickedUp:
        return 'Picked Up';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.refunded:
        return 'Refunded';
    }
  }
}

/// An item within an order
class OrderItem {
  final String productId;
  final String name;
  final String? imageUrl;
  final int quantity;
  final double price;
  final String? customization;

  const OrderItem({
    required this.productId,
    required this.name,
    this.imageUrl,
    this.quantity = 1,
    required this.price,
    this.customization,
  });

  double get total => price * quantity;
}

// ─── Return Models ──────────────────────────────────────────────────────────

/// A return request for an order
class ReturnRequest {
  final String id;
  final String orderId;
  final String merchantName;
  final ReturnStatus status;
  final List<ReturnItem> items;
  final ReturnReason reason;
  final String? reasonDetail;
  final RefundMethod preferredRefund;
  final double estimatedRefund;
  final List<String> evidenceVideos;
  final List<String> evidencePhotos;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? resolutionNote;

  const ReturnRequest({
    required this.id,
    required this.orderId,
    required this.merchantName,
    this.status = ReturnStatus.requested,
    this.items = const [],
    this.reason = ReturnReason.damaged,
    this.reasonDetail,
    this.preferredRefund = RefundMethod.originalPayment,
    this.estimatedRefund = 0,
    this.evidenceVideos = const [],
    this.evidencePhotos = const [],
    required this.createdAt,
    this.resolvedAt,
    this.resolutionNote,
  });

  Color get statusColor {
    switch (status) {
      case ReturnStatus.requested:
      case ReturnStatus.evidenceSubmitted:
        return const Color(0xFFF59E0B);
      case ReturnStatus.underReview:
        return const Color(0xFF3B82F6);
      case ReturnStatus.approved:
      case ReturnStatus.refundProcessed:
        return const Color(0xFF10B981);
      case ReturnStatus.rejected:
        return const Color(0xFFEF4444);
    }
  }

  String get statusLabel {
    switch (status) {
      case ReturnStatus.requested:
        return 'Requested';
      case ReturnStatus.evidenceSubmitted:
        return 'Evidence Submitted';
      case ReturnStatus.underReview:
        return 'Under Review';
      case ReturnStatus.approved:
        return 'Approved';
      case ReturnStatus.rejected:
        return 'Rejected';
      case ReturnStatus.refundProcessed:
        return 'Refund Processed';
    }
  }
}

/// An item being returned
class ReturnItem {
  final String productId;
  final String name;
  final String? imageUrl;
  final int quantity;
  final double price;
  final ReturnReason reason;

  const ReturnItem({
    required this.productId,
    required this.name,
    this.imageUrl,
    this.quantity = 1,
    required this.price,
    this.reason = ReturnReason.damaged,
  });
}

/// A rejected-return video entry (for Branch view Tab 5)
class RejectedReturnVideo {
  final String id;
  final String returnId;
  final String title;
  final String? thumbnailUrl;
  final String? videoUrl;
  final int durationSeconds;
  final ReturnReason reason;
  final DateTime createdAt;
  final String resolutionStatus; // 'pending', 'resolved', 'escalated'

  const RejectedReturnVideo({
    required this.id,
    required this.returnId,
    required this.title,
    this.thumbnailUrl,
    this.videoUrl,
    this.durationSeconds = 0,
    this.reason = ReturnReason.damaged,
    required this.createdAt,
    this.resolutionStatus = 'pending',
  });

  String get durationDisplay {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

// ─── Delivery / Tracking Models ─────────────────────────────────────────────

/// Live delivery tracking data
class DeliveryTracking {
  final String orderId;
  final DeliveryStep currentStep;
  final double driverLat;
  final double driverLng;
  final double destinationLat;
  final double destinationLng;
  final double merchantLat;
  final double merchantLng;
  final String driverName;
  final String? driverPhotoUrl;
  final double driverRating;
  final int driverDeliveries;
  final String vehicleInfo;
  final String vehiclePlate;
  final int etaMinutes;
  final double distanceMiles;
  final String? deliveryPin;
  final DateTime? lastUpdated;
  final List<TrackingEvent> timeline;

  const DeliveryTracking({
    required this.orderId,
    this.currentStep = DeliveryStep.confirmed,
    this.driverLat = 0,
    this.driverLng = 0,
    this.destinationLat = 0,
    this.destinationLng = 0,
    this.merchantLat = 0,
    this.merchantLng = 0,
    this.driverName = '',
    this.driverPhotoUrl,
    this.driverRating = 0,
    this.driverDeliveries = 0,
    this.vehicleInfo = '',
    this.vehiclePlate = '',
    this.etaMinutes = 0,
    this.distanceMiles = 0,
    this.deliveryPin,
    this.lastUpdated,
    this.timeline = const [],
  });

  bool get isDriverApproaching => distanceMiles < 0.1;
}

/// A tracking event in the timeline
class TrackingEvent {
  final DeliveryStep step;
  final String label;
  final String? detail;
  final DateTime? timestamp;
  final bool isCompleted;
  final bool isCurrent;

  const TrackingEvent({
    required this.step,
    required this.label,
    this.detail,
    this.timestamp,
    this.isCompleted = false,
    this.isCurrent = false,
  });
}

// ─── Ride Hailing Models ────────────────────────────────────────────────────

/// A ride request / active ride
class RideRequest {
  final String id;
  final RideStatus status;
  final RideType type;
  final String pickupAddress;
  final String destinationAddress;
  final double pickupLat;
  final double pickupLng;
  final double destLat;
  final double destLng;
  final double estimatedFare;
  final double? finalFare;
  final double baseFare;
  final double perMileRate;
  final double perMinuteRate;
  final double serviceFee;
  final double? tip;
  final int estimatedMinutes;
  final double estimatedDistance;
  final String? driverName;
  final String? driverPhotoUrl;
  final double? driverRating;
  final int? driverTotalRides;
  final String? vehicleModel;
  final String? vehiclePlate;
  final String? vehicleColor;
  final int? etaMinutes;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool isRated;
  final PaymentMethodType paymentMethod;

  const RideRequest({
    required this.id,
    this.status = RideStatus.searching,
    this.type = RideType.standard,
    required this.pickupAddress,
    required this.destinationAddress,
    this.pickupLat = 0,
    this.pickupLng = 0,
    this.destLat = 0,
    this.destLng = 0,
    this.estimatedFare = 0,
    this.finalFare,
    this.baseFare = 3.50,
    this.perMileRate = 2.15,
    this.perMinuteRate = 0.35,
    this.serviceFee = 1.50,
    this.tip,
    this.estimatedMinutes = 0,
    this.estimatedDistance = 0,
    this.driverName,
    this.driverPhotoUrl,
    this.driverRating,
    this.driverTotalRides,
    this.vehicleModel,
    this.vehiclePlate,
    this.vehicleColor,
    this.etaMinutes,
    required this.createdAt,
    this.completedAt,
    this.isRated = false,
    this.paymentMethod = PaymentMethodType.card,
  });

  bool get isActive =>
      status == RideStatus.searching ||
      status == RideStatus.driverAssigned ||
      status == RideStatus.driverEnRoute ||
      status == RideStatus.arrived ||
      status == RideStatus.inProgress;

  String get typeLabel {
    switch (type) {
      case RideType.standard:
        return 'Standard';
      case RideType.premium:
        return 'Premium';
      case RideType.xl:
        return 'XL';
      case RideType.eco:
        return 'Eco';
      case RideType.assist:
        return 'Assist';
    }
  }

  Color get statusColor {
    switch (status) {
      case RideStatus.searching:
        return const Color(0xFFF59E0B);
      case RideStatus.driverAssigned:
      case RideStatus.driverEnRoute:
        return const Color(0xFF3B82F6);
      case RideStatus.arrived:
        return const Color(0xFF8B5CF6);
      case RideStatus.inProgress:
        return const Color(0xFF10B981);
      case RideStatus.completed:
        return const Color(0xFF10B981);
      case RideStatus.cancelled:
        return const Color(0xFFEF4444);
    }
  }
}

// ─── Payment Models ─────────────────────────────────────────────────────────

/// A saved payment method
class SavedPaymentMethod {
  final String id;
  final PaymentMethodType type;
  final String label;
  final String? last4;
  final String? brand; // 'Visa', 'Mastercard', etc.
  final bool isDefault;
  final double? balance; // For QPoints / Tab credit

  const SavedPaymentMethod({
    required this.id,
    required this.type,
    required this.label,
    this.last4,
    this.brand,
    this.isDefault = false,
    this.balance,
  });

  IconData get icon {
    switch (type) {
      case PaymentMethodType.card:
        return Icons.credit_card;
      case PaymentMethodType.qPoints:
        return Icons.stars;
      case PaymentMethodType.tabCredit:
        return Icons.account_balance_wallet;
      case PaymentMethodType.applePay:
        return Icons.apple;
      case PaymentMethodType.googlePay:
        return Icons.g_mobiledata;
      case PaymentMethodType.paypal:
        return Icons.payment;
    }
  }
}

// ─── Filter / Search Models ─────────────────────────────────────────────────

/// Active filters state
class MarketFilters {
  final double? minPrice;
  final double? maxPrice;
  final FulfillmentMethod? fulfillmentFilter;
  final int? maxDeliveryTime;
  final List<DietaryPreference> dietary;
  final bool verifiedOnly;
  final bool familyOwned;
  final bool sustainable;
  final SortOption sort;
  final double? minRating;
  final String? savedFilterName;

  const MarketFilters({
    this.minPrice,
    this.maxPrice,
    this.fulfillmentFilter,
    this.maxDeliveryTime,
    this.dietary = const [],
    this.verifiedOnly = false,
    this.familyOwned = false,
    this.sustainable = false,
    this.sort = SortOption.recommended,
    this.minRating,
    this.savedFilterName,
  });

  bool get hasActiveFilters =>
      minPrice != null ||
      maxPrice != null ||
      fulfillmentFilter != null ||
      maxDeliveryTime != null ||
      dietary.isNotEmpty ||
      verifiedOnly ||
      familyOwned ||
      sustainable ||
      minRating != null;

  int get activeFilterCount {
    int count = 0;
    if (minPrice != null || maxPrice != null) count++;
    if (fulfillmentFilter != null) count++;
    if (maxDeliveryTime != null) count++;
    if (dietary.isNotEmpty) count++;
    if (verifiedOnly) count++;
    if (familyOwned) count++;
    if (sustainable) count++;
    if (minRating != null) count++;
    return count;
  }
}

/// A saved filter preset
class SavedFilter {
  final String id;
  final String name;
  final MarketFilters filters;
  final DateTime createdAt;

  const SavedFilter({
    required this.id,
    required this.name,
    required this.filters,
    required this.createdAt,
  });
}

// ─── Transaction Summary Models ─────────────────────────────────────────────

/// Summary stats for the transaction dashboard
class TransactionSummary {
  final double totalSpent;
  final int orderCount;
  final double averageOrder;
  final double savedViaDiscounts;
  final int activeOrders;
  final int readyForPickup;
  final int pendingReturns;

  const TransactionSummary({
    this.totalSpent = 0,
    this.orderCount = 0,
    this.averageOrder = 0,
    this.savedViaDiscounts = 0,
    this.activeOrders = 0,
    this.readyForPickup = 0,
    this.pendingReturns = 0,
  });
}

// ─── AI / Bundling Models ───────────────────────────────────────────────────

/// AI bundling suggestion for cart optimization
class BundleSuggestion {
  final String id;
  final String title;
  final String description;
  final int timeSavedMinutes;
  final double co2Saved;
  final int bundledOrders;
  final int estimatedTimeMin;
  final int estimatedTimeMax;
  final int originalTimeMin;
  final int originalTimeMax;

  const BundleSuggestion({
    required this.id,
    required this.title,
    required this.description,
    this.timeSavedMinutes = 0,
    this.co2Saved = 0,
    this.bundledOrders = 0,
    this.estimatedTimeMin = 0,
    this.estimatedTimeMax = 0,
    this.originalTimeMin = 0,
    this.originalTimeMax = 0,
  });
}

/// AI suggestion on the hub
class MarketAISuggestion {
  final String id;
  final String message;
  final String? actionLabel;
  final String? actionRoute;
  final IconData icon;
  final Color color;

  const MarketAISuggestion({
    required this.id,
    required this.message,
    this.actionLabel,
    this.actionRoute,
    this.icon = Icons.auto_awesome,
    this.color = const Color(0xFF8B5CF6),
  });
}

// ─── Self-Pickup Models ─────────────────────────────────────────────────────

/// Self-pickup session state
class PickupSession {
  final String orderId;
  final String merchantName;
  final String merchantAddress;
  final PickupPhase phase;
  final String? qrCode;
  final String? pickupCode;
  final String? staffName;
  final DateTime? readyAt;
  final int etaMinutes;
  final double distanceMiles;
  final bool isOnTheWay;

  const PickupSession({
    required this.orderId,
    required this.merchantName,
    required this.merchantAddress,
    this.phase = PickupPhase.preparation,
    this.qrCode,
    this.pickupCode,
    this.staffName,
    this.readyAt,
    this.etaMinutes = 0,
    this.distanceMiles = 0,
    this.isOnTheWay = false,
  });
}
