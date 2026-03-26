/// ═══════════════════════════════════════════════════════════════════════════
/// MARKET MODULE — Provider (State Management)
/// Cart management, order tracking, merchant discovery, ride hailing,
/// returns, self-pickup, delivery tracking, AI bundling
///
/// Migrated from hardcoded demo data to real API calls with fallback.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../models/market_models.dart';
import '../../../core/services/services.dart';

class MarketProvider extends ChangeNotifier {
  // ═══════════════════════════════════════════════════════════════════════════
  // SERVICES
  // ═══════════════════════════════════════════════════════════════════════════

  final ProductService _productService = ProductService();
  final OrderService _orderService = OrderService();
  final RideService _rideService = RideService();

  // ═══════════════════════════════════════════════════════════════════════════
  // LOADING / ERROR STATE
  // ═══════════════════════════════════════════════════════════════════════════

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _merchantsLoading = false;
  bool get merchantsLoading => _merchantsLoading;

  bool _productsLoading = false;
  bool get productsLoading => _productsLoading;

  bool _ordersLoading = false;
  bool get ordersLoading => _ordersLoading;

  bool _returnsLoading = false;
  bool get returnsLoading => _returnsLoading;

  bool _ridesLoading = false;
  bool get ridesLoading => _ridesLoading;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INIT — Load everything on startup
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      loadMerchants(),
      loadProducts(),
      loadOrders(),
      loadReturns(),
      loadRides(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 1: MERCHANTS
  // ═══════════════════════════════════════════════════════════════════════════

  List<Merchant> _merchants = [];

  MerchantCategory _selectedCategory = MerchantCategory.all;
  MerchantCategory get selectedCategory => _selectedCategory;

  void setCategory(MerchantCategory cat) {
    _selectedCategory = cat;
    notifyListeners();
  }

  Merchant? _selectedMerchant;
  Merchant? get selectedMerchant => _selectedMerchant;

  void selectMerchant(String id) {
    _selectedMerchant = _merchants.firstWhere(
      (m) => m.id == id,
      orElse: () => _merchants.first,
    );
    notifyListeners();
  }

  void toggleFavorite(String merchantId) {
    // In production, persist to backend
    notifyListeners();
  }

  List<Merchant> get merchants => _merchants;

  List<Merchant> get filteredMerchants {
    if (_selectedCategory == MerchantCategory.all) return _merchants;
    return _merchants.where((m) => m.category == _selectedCategory).toList();
  }

  List<Merchant> get featuredMerchants =>
      _merchants.where((m) => m.isTrending || m.verification == VerificationTier.premium).toList();

  int get activeMerchantCount =>
      _merchants.where((m) => m.isOpen).length;

  /// Load merchants from API. Falls back to demo data on error.
  Future<void> loadMerchants() async {
    _merchantsLoading = true;
    notifyListeners();

    try {
      // Merchants are currently inferred from the products endpoint.
      // When a dedicated merchants endpoint exists, switch to that.
      final response = await _productService.getProducts(limit: 100);
      if (response.success && response.data != null && response.data!.isNotEmpty) {
        final merchantMap = <String, Merchant>{};
        for (final json in response.data!) {
          final merchantId = json['merchantId']?.toString() ?? json['entityId']?.toString() ?? '';
          if (merchantId.isNotEmpty && !merchantMap.containsKey(merchantId)) {
            merchantMap[merchantId] = _merchantFromProductJson(json);
          }
        }
        if (merchantMap.isNotEmpty) {
          _merchants = merchantMap.values.toList();
        } else {
          _merchants = _fallbackMerchants;
        }
      } else {
        _merchants = _fallbackMerchants;
      }
    } catch (e) {
      debugPrint('MarketProvider.loadMerchants error: $e');
      _merchants = _fallbackMerchants;
    }

    _merchantsLoading = false;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 2: PRODUCTS
  // ═══════════════════════════════════════════════════════════════════════════

  List<MarketProduct> _products = [];

  MarketProduct? _selectedProduct;
  MarketProduct? get selectedProduct => _selectedProduct;

  void selectProduct(String id) {
    _selectedProduct = _products.firstWhere(
      (p) => p.id == id,
      orElse: () => _products.first,
    );
    notifyListeners();
  }

  List<MarketProduct> get products => _products;

  List<MarketProduct> getProductsForMerchant(String merchantId) =>
      _products.where((p) => p.merchantId == merchantId).toList();

  List<ProductCategory> _productCategories = _fallbackCategories;
  List<ProductCategory> get productCategories => _productCategories;

  String _productViewMode = 'grid'; // 'grid', 'list', 'large'
  String get productViewMode => _productViewMode;

  void setProductViewMode(String mode) {
    _productViewMode = mode;
    notifyListeners();
  }

  SortOption _productSort = SortOption.recommended;
  SortOption get productSort => _productSort;

  void setProductSort(SortOption sort) {
    _productSort = sort;
    notifyListeners();
  }

  /// Load products from API. Falls back to demo data on error.
  Future<void> loadProducts({String? merchantId, String? category}) async {
    _productsLoading = true;
    notifyListeners();

    try {
      final response = await _productService.getProducts(
        limit: 50,
        entityId: merchantId,
        category: category,
      );

      if (response.success && response.data != null && response.data!.isNotEmpty) {
        _products = response.data!.map(_productFromJson).toList();
        _productCategories = _deriveCategoriesFromProducts(_products);
      } else {
        _products = _fallbackProducts;
        _productCategories = _fallbackCategories;
      }
    } catch (e) {
      debugPrint('MarketProvider.loadProducts error: $e');
      _products = _fallbackProducts;
      _productCategories = _fallbackCategories;
    }

    _productsLoading = false;
    notifyListeners();
  }

  /// Search products via API.
  Future<List<MarketProduct>> searchProducts(String query) async {
    if (query.trim().isEmpty) return _products;

    try {
      final response = await _productService.searchProducts(query);
      if (response.success && response.data != null) {
        return response.data!.map(_productFromJson).toList();
      }
    } catch (e) {
      debugPrint('MarketProvider.searchProducts error: $e');
    }

    // Fallback: filter local products by name
    final lowerQuery = query.toLowerCase();
    return _products.where((p) => p.name.toLowerCase().contains(lowerQuery)).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 3: CART (Client-side — no API changes)
  // ═══════════════════════════════════════════════════════════════════════════

  final List<CartItem> _cartItems = [];
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  int get cartItemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  bool _bundlingEnabled = false;
  bool get bundlingEnabled => _bundlingEnabled;

  void toggleBundling() {
    _bundlingEnabled = !_bundlingEnabled;
    notifyListeners();
  }

  String? _promoCode;
  String? get promoCode => _promoCode;

  void applyPromoCode(String code) {
    _promoCode = code;
    notifyListeners();
  }

  void removePromoCode() {
    _promoCode = null;
    notifyListeners();
  }

  void addToCart(MarketProduct product, {int quantity = 1, List<ProductVariant>? variants, List<ProductAddon>? addons, String? instructions}) {
    final existing = _cartItems.indexWhere((item) => item.product.id == product.id);
    if (existing >= 0) {
      final old = _cartItems[existing];
      _cartItems[existing] = CartItem(
        id: old.id,
        product: old.product,
        quantity: old.quantity + quantity,
        selectedVariants: variants ?? old.selectedVariants,
        selectedAddons: addons ?? old.selectedAddons,
        specialInstructions: instructions ?? old.specialInstructions,
      );
    } else {
      _cartItems.add(CartItem(
        id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
        product: product,
        quantity: quantity,
        selectedVariants: variants ?? [],
        selectedAddons: addons ?? [],
        specialInstructions: instructions,
      ));
    }
    notifyListeners();
  }

  void removeFromCart(String cartItemId) {
    _cartItems.removeWhere((item) => item.id == cartItemId);
    notifyListeners();
  }

  void updateCartItemQuantity(String cartItemId, int quantity) {
    final idx = _cartItems.indexWhere((item) => item.id == cartItemId);
    if (idx >= 0) {
      if (quantity <= 0) {
        _cartItems.removeAt(idx);
      } else {
        final old = _cartItems[idx];
        _cartItems[idx] = CartItem(
          id: old.id,
          product: old.product,
          quantity: quantity,
          selectedVariants: old.selectedVariants,
          selectedAddons: old.selectedAddons,
          specialInstructions: old.specialInstructions,
        );
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  CartSummary get cartSummary {
    final subtotal = _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    final deliveryFee = subtotal >= 25 ? 0.0 : 2.99;
    final tax = subtotal * 0.07;
    return CartSummary(
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      serviceFee: 1.99,
      tax: tax,
      promoDiscount: _promoCode != null ? 5.0 : 0.0,
    );
  }

  BundleSuggestion? get bundleSuggestion => _bundlingEnabled
      ? const BundleSuggestion(
          id: 'bundle_1',
          title: 'Bundle with nearby orders',
          description: 'Save time by bundling with 2 nearby orders',
          timeSavedMinutes: 22,
          co2Saved: 2.1,
          bundledOrders: 3,
          estimatedTimeMin: 25,
          estimatedTimeMax: 35,
          originalTimeMin: 45,
          originalTimeMax: 60,
        )
      : null;

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 4: ORDERS
  // ═══════════════════════════════════════════════════════════════════════════

  List<MarketOrder> _orders = [];

  MarketOrder? _selectedOrder;
  MarketOrder? get selectedOrder => _selectedOrder;

  void selectOrder(String id) {
    _selectedOrder = _orders.firstWhere(
      (o) => o.id == id,
      orElse: () => _orders.first,
    );
    notifyListeners();
  }

  List<MarketOrder> get orders => _orders;

  List<MarketOrder> get activeOrders =>
      _orders.where((o) => o.isActive).toList();

  List<MarketOrder> get readyForPickupOrders =>
      _orders.where((o) => o.status == OrderStatus.readyForPickup).toList();

  List<MarketOrder> get completedOrders =>
      _orders.where((o) => o.isDelivered).toList();

  List<MarketOrder> get cancelledOrders =>
      _orders.where((o) => o.status == OrderStatus.cancelled || o.status == OrderStatus.refunded).toList();

  TransactionSummary get transactionSummary => TransactionSummary(
        totalSpent: _orders.fold(0.0, (sum, o) => sum + o.total),
        orderCount: _orders.length,
        averageOrder: _orders.isEmpty ? 0 : _orders.fold(0.0, (sum, o) => sum + o.total) / _orders.length,
        savedViaDiscounts: 89.50,
        activeOrders: activeOrders.length,
        readyForPickup: readyForPickupOrders.length,
        pendingReturns: _returns.where((r) => r.status != ReturnStatus.refundProcessed && r.status != ReturnStatus.rejected).length,
      );

  /// Load orders from API. Falls back to demo data on error.
  Future<void> loadOrders({String? userId}) async {
    _ordersLoading = true;
    notifyListeners();

    try {
      final uid = userId ?? 'current';
      final response = await _orderService.getUserOrders(userId: uid);

      if (response.success && response.data != null && response.data!.isNotEmpty) {
        _orders = response.data!.map(_orderFromJson).toList();
      } else {
        _orders = _fallbackOrders;
      }
    } catch (e) {
      debugPrint('MarketProvider.loadOrders error: $e');
      _orders = _fallbackOrders;
    }

    _ordersLoading = false;
    notifyListeners();
  }

  /// Place an order from the current cart via API.
  Future<MarketOrder?> placeOrder({Map<String, dynamic>? deliveryAddress}) async {
    if (_cartItems.isEmpty) return null;

    _isLoading = true;
    notifyListeners();

    try {
      final items = _cartItems.map((item) => {
        'productId': item.product.id,
        'name': item.product.name,
        'quantity': item.quantity,
        'price': item.unitPrice,
        'customization': item.customizationSummary,
      }).toList();

      final response = await _orderService.createOrder(
        items: items,
        deliveryAddress: deliveryAddress ?? {'address': '123 Main St'},
      );

      if (response.success && response.data != null) {
        final newOrder = _orderFromJson(response.data!);
        _orders.insert(0, newOrder);
        _cartItems.clear();
        _isLoading = false;
        notifyListeners();
        return newOrder;
      } else {
        _error = response.message ?? 'Failed to place order';
      }
    } catch (e) {
      debugPrint('MarketProvider.placeOrder error: $e');
      _error = 'Failed to place order: $e';
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 5: RETURNS
  // ═══════════════════════════════════════════════════════════════════════════

  List<ReturnRequest> _returns = [];

  ReturnRequest? _selectedReturn;
  ReturnRequest? get selectedReturn => _selectedReturn;

  void selectReturn(String id) {
    _selectedReturn = _returns.firstWhere(
      (r) => r.id == id,
      orElse: () => _returns.first,
    );
    notifyListeners();
  }

  List<ReturnRequest> get returns => _returns;

  List<ReturnRequest> get activeReturns =>
      _returns.where((r) => r.status != ReturnStatus.refundProcessed && r.status != ReturnStatus.rejected).toList();

  /// Load return requests from API. Falls back to demo data on error.
  Future<void> loadReturns({String? userId}) async {
    _returnsLoading = true;
    notifyListeners();

    try {
      final uid = userId ?? 'current';
      final response = await _orderService.getReturnRequests(uid);

      if (response.success && response.data != null && response.data!.isNotEmpty) {
        _returns = response.data!.map(_returnFromJson).toList();
      } else {
        _returns = _fallbackReturns;
      }
    } catch (e) {
      debugPrint('MarketProvider.loadReturns error: $e');
      _returns = _fallbackReturns;
    }

    _returnsLoading = false;
    notifyListeners();
  }

  /// Submit a return request via API.
  Future<ReturnRequest?> submitReturn({
    required String orderId,
    required ReturnReason reason,
    String? reasonDetail,
    List<Map<String, dynamic>>? items,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _orderService.createReturnRequest(
        orderId: orderId,
        reason: reason.name,
        items: items ?? [],
      );

      if (response.success && response.data != null) {
        final newReturn = _returnFromJson(response.data!);
        _returns.insert(0, newReturn);
        _isLoading = false;
        notifyListeners();
        return newReturn;
      } else {
        _error = response.message ?? 'Failed to submit return';
      }
    } catch (e) {
      debugPrint('MarketProvider.submitReturn error: $e');
      _error = 'Failed to submit return: $e';
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 6: DELIVERY TRACKING (Client-side for now — WebSocket later)
  // ═══════════════════════════════════════════════════════════════════════════

  DeliveryTracking? _activeDeliveryTracking;

  DeliveryTracking? get activeDelivery => _activeDeliveryTracking ?? _fallbackDeliveryTracking;

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 7: RIDE HAILING
  // ═══════════════════════════════════════════════════════════════════════════

  List<RideRequest> _rides = [];

  RideRequest? _activeRide;
  RideRequest? get activeRide => _activeRide;

  List<RideRequest> get rideHistory => _rides;

  RideType _selectedRideType = RideType.standard;
  RideType get selectedRideType => _selectedRideType;

  void setRideType(RideType type) {
    _selectedRideType = type;
    notifyListeners();
  }

  /// Request a ride via API. Falls back to local creation on error.
  Future<void> requestRide({required String pickup, required String destination}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _rideService.createRide(
        pickupLocation: {'address': pickup},
        dropoffLocation: {'address': destination},
        vehicleType: _selectedRideType.name,
      );

      if (response.success && response.data != null) {
        _activeRide = _rideFromJson(response.data!);
        _isLoading = false;
        notifyListeners();
        return;
      }
    } catch (e) {
      debugPrint('MarketProvider.requestRide error: $e');
    }

    // Fallback: create a local ride request
    _activeRide = RideRequest(
      id: 'ride_${DateTime.now().millisecondsSinceEpoch}',
      status: RideStatus.searching,
      type: _selectedRideType,
      pickupAddress: pickup,
      destinationAddress: destination,
      estimatedFare: 15.50,
      estimatedMinutes: 18,
      estimatedDistance: 4.2,
      createdAt: DateTime.now(),
    );

    _isLoading = false;
    notifyListeners();
  }

  void cancelRide() {
    _activeRide = null;
    notifyListeners();
  }

  /// Load ride history from API. Falls back to demo data on error.
  Future<void> loadRides({String? userId}) async {
    _ridesLoading = true;
    notifyListeners();

    try {
      final uid = userId ?? 'current';
      final response = await _rideService.getUserRides(userId: uid);

      if (response.success && response.data != null && response.data!.isNotEmpty) {
        _rides = response.data!.map(_rideFromJson).toList();
      } else {
        _rides = _fallbackRides;
      }
    } catch (e) {
      debugPrint('MarketProvider.loadRides error: $e');
      _rides = _fallbackRides;
    }

    _ridesLoading = false;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 8: FILTERS & SEARCH (Client-side)
  // ═══════════════════════════════════════════════════════════════════════════

  MarketFilters _filters = const MarketFilters();
  MarketFilters get filters => _filters;

  void updateFilters(MarketFilters newFilters) {
    _filters = newFilters;
    notifyListeners();
  }

  void clearFilters() {
    _filters = const MarketFilters();
    notifyListeners();
  }

  List<String> get recentSearches => ['Pizza', 'Sushi Palace', 'Pharmacy', 'Coffee', 'Burger'];

  List<String> get searchSuggestions => ['Pizza', 'Pharmacy', '24/7', 'Free delivery'];

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 9: PAYMENT METHODS (Client-side for now)
  // ═══════════════════════════════════════════════════════════════════════════

  List<SavedPaymentMethod> get paymentMethods => _fallbackPaymentMethods;

  SavedPaymentMethod get defaultPaymentMethod =>
      _fallbackPaymentMethods.firstWhere((p) => p.isDefault, orElse: () => _fallbackPaymentMethods.first);

  FulfillmentMethod _selectedFulfillment = FulfillmentMethod.delivery;
  FulfillmentMethod get selectedFulfillment => _selectedFulfillment;

  void setFulfillment(FulfillmentMethod method) {
    _selectedFulfillment = method;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 10: AI SUGGESTIONS (Client-side — different backend system)
  // ═══════════════════════════════════════════════════════════════════════════

  List<MarketAISuggestion> get aiSuggestions => const [
        MarketAISuggestion(
          id: 'ai_1',
          message: 'Save 15 mins by bundling 2 orders',
          actionLabel: 'Bundle now',
          icon: Icons.timer,
          color: Color(0xFF10B981),
        ),
        MarketAISuggestion(
          id: 'ai_2',
          message: '3 vendors matching your preferences',
          actionLabel: 'View list',
          icon: Icons.store,
          color: Color(0xFF3B82F6),
        ),
        MarketAISuggestion(
          id: 'ai_3',
          message: 'Delivery zone status: All clear',
          icon: Icons.local_shipping,
          color: Color(0xFF10B981),
        ),
      ];

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 11: MERCHANT POSTS & DEALS (Client-side fallback for now)
  // ═══════════════════════════════════════════════════════════════════════════

  List<MerchantPost> get merchantPosts => _fallbackMerchantPosts;

  List<MerchantDeal> get merchantDeals => _fallbackDeals;

  List<MerchantDeal> getDealsForMerchant(String merchantId) =>
      _fallbackDeals.where((d) => d.merchantId == merchantId).toList();

  List<RejectedReturnVideo> get rejectedReturnVideos => _fallbackRejectedVideos;

  // ═══════════════════════════════════════════════════════════════════════════
  // JSON → MODEL HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Build a Merchant from product-level JSON (inferred from products endpoint).
  Merchant _merchantFromProductJson(Map<String, dynamic> json) {
    try {
      return Merchant(
        id: json['merchantId']?.toString() ?? json['entityId']?.toString() ?? '',
        name: json['merchantName']?.toString() ?? json['entityName']?.toString() ?? 'Unknown',
        description: json['merchantDescription']?.toString(),
        status: _parseMerchantStatus(json['merchantStatus']?.toString()),
        verification: _parseVerificationTier(json['verification']?.toString()),
        category: _parseMerchantCategory(json['category']?.toString()),
        tags: _toStringList(json['tags']),
        rating: _toDouble(json['rating']),
        ratingCount: _toInt(json['ratingCount']),
        distanceMiles: _toDouble(json['distanceMiles']),
        deliveryTimeMin: _toInt(json['deliveryTimeMin'], fallback: 15),
        deliveryTimeMax: _toInt(json['deliveryTimeMax'], fallback: 30),
        deliveryFee: _toDouble(json['deliveryFee']),
        minimumOrder: _toDouble(json['minimumOrder']),
        fulfillment: _parseFulfillmentMethod(json['fulfillment']?.toString()),
        address: json['address']?.toString() ?? '',
        phone: json['phone']?.toString(),
        email: json['email']?.toString(),
        website: json['website']?.toString(),
        hours: _toStringMap(json['hours']),
        isFavorite: json['isFavorite'] == true,
        isTrending: json['isTrending'] == true,
        activeDeals: _toInt(json['activeDeals']),
      );
    } catch (e) {
      debugPrint('_merchantFromProductJson error: $e');
      return Merchant(
        id: json['merchantId']?.toString() ?? json['entityId']?.toString() ?? 'unknown',
        name: json['merchantName']?.toString() ?? 'Unknown Merchant',
      );
    }
  }

  MarketProduct _productFromJson(Map<String, dynamic> json) {
    try {
      return MarketProduct(
        id: json['id']?.toString() ?? '',
        merchantId: json['merchantId']?.toString() ?? json['entityId']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Unnamed Product',
        description: json['description']?.toString(),
        imageUrl: json['imageUrl']?.toString(),
        images: _toStringList(json['images']),
        price: _toDouble(json['price']),
        comparePrice: json['comparePrice'] != null ? _toDouble(json['comparePrice']) : null,
        unitPrice: json['unitPrice']?.toString(),
        category: _parseMerchantCategory(json['category']?.toString()),
        categoryName: json['categoryName']?.toString() ?? 'General',
        availability: _parseAvailability(json['availability']?.toString()),
        rating: _toDouble(json['rating']),
        ratingCount: _toInt(json['ratingCount']),
        badges: _toStringList(json['badges']),
        dietary: _parseDietaryList(json['dietary']),
        hasCustomization: json['hasCustomization'] == true,
        customizationNote: json['customizationNote']?.toString(),
        variants: _parseVariants(json['variants']),
        addons: _parseAddons(json['addons']),
        specifications: _toStringMap(json['specifications']),
        allergens: _toStringList(json['allergens']),
      );
    } catch (e) {
      debugPrint('_productFromJson error: $e');
      return MarketProduct(
        id: json['id']?.toString() ?? 'unknown',
        merchantId: json['merchantId']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Unknown Product',
        price: _toDouble(json['price']),
      );
    }
  }

  MarketOrder _orderFromJson(Map<String, dynamic> json) {
    try {
      return MarketOrder(
        id: json['id']?.toString() ?? '',
        merchantId: json['merchantId']?.toString() ?? '',
        merchantName: json['merchantName']?.toString() ?? 'Unknown',
        merchantLogo: json['merchantLogo']?.toString(),
        status: _parseOrderStatus(json['status']?.toString()),
        fulfillment: _parseFulfillmentMethod(json['fulfillment']?.toString()),
        items: _parseOrderItems(json['items']),
        subtotal: _toDouble(json['subtotal']),
        deliveryFee: _toDouble(json['deliveryFee']),
        serviceFee: _toDouble(json['serviceFee']),
        tax: _toDouble(json['tax']),
        discount: _toDouble(json['discount']),
        total: _toDouble(json['total']),
        createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
        estimatedDelivery: _parseDateTime(json['estimatedDelivery']),
        deliveredAt: _parseDateTime(json['deliveredAt']),
        driverName: json['driverName']?.toString(),
        driverPhone: json['driverPhone']?.toString(),
        driverRating: json['driverRating'] != null ? _toDouble(json['driverRating']) : null,
        vehicleInfo: json['vehicleInfo']?.toString(),
        deliveryAddress: json['deliveryAddress']?.toString(),
        deliveryInstructions: json['deliveryInstructions']?.toString(),
        pickupCode: json['pickupCode']?.toString(),
        trackingPin: json['trackingPin']?.toString(),
        paymentMethod: _parsePaymentMethod(json['paymentMethod']?.toString()),
        isRated: json['isRated'] == true,
      );
    } catch (e) {
      debugPrint('_orderFromJson error: $e');
      return MarketOrder(
        id: json['id']?.toString() ?? 'unknown',
        merchantId: json['merchantId']?.toString() ?? '',
        merchantName: json['merchantName']?.toString() ?? 'Unknown',
        createdAt: DateTime.now(),
      );
    }
  }

  ReturnRequest _returnFromJson(Map<String, dynamic> json) {
    try {
      return ReturnRequest(
        id: json['id']?.toString() ?? '',
        orderId: json['orderId']?.toString() ?? '',
        merchantName: json['merchantName']?.toString() ?? 'Unknown',
        status: _parseReturnStatus(json['status']?.toString()),
        items: _parseReturnItems(json['items']),
        reason: _parseReturnReason(json['reason']?.toString()),
        reasonDetail: json['reasonDetail']?.toString(),
        preferredRefund: _parseRefundMethod(json['preferredRefund']?.toString()),
        estimatedRefund: _toDouble(json['estimatedRefund']),
        evidencePhotos: _toStringList(json['evidencePhotos']),
        evidenceVideos: _toStringList(json['evidenceVideos']),
        createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
        resolvedAt: _parseDateTime(json['resolvedAt']),
        resolutionNote: json['resolutionNote']?.toString(),
      );
    } catch (e) {
      debugPrint('_returnFromJson error: $e');
      return ReturnRequest(
        id: json['id']?.toString() ?? 'unknown',
        orderId: json['orderId']?.toString() ?? '',
        merchantName: json['merchantName']?.toString() ?? 'Unknown',
        createdAt: DateTime.now(),
      );
    }
  }

  RideRequest _rideFromJson(Map<String, dynamic> json) {
    try {
      return RideRequest(
        id: json['id']?.toString() ?? '',
        status: _parseRideStatus(json['status']?.toString()),
        type: _parseRideType(json['type']?.toString() ?? json['vehicleType']?.toString()),
        pickupAddress: json['pickupAddress']?.toString() ?? json['pickupLocation']?['address']?.toString() ?? '',
        destinationAddress: json['destinationAddress']?.toString() ?? json['dropoffLocation']?['address']?.toString() ?? '',
        pickupLat: _toDouble(json['pickupLat'] ?? json['pickupLocation']?['lat']),
        pickupLng: _toDouble(json['pickupLng'] ?? json['pickupLocation']?['lng']),
        destLat: _toDouble(json['destLat'] ?? json['dropoffLocation']?['lat']),
        destLng: _toDouble(json['destLng'] ?? json['dropoffLocation']?['lng']),
        estimatedFare: _toDouble(json['estimatedFare']),
        finalFare: json['finalFare'] != null ? _toDouble(json['finalFare']) : null,
        baseFare: _toDouble(json['baseFare'], fallback: 3.50),
        perMileRate: _toDouble(json['perMileRate'], fallback: 2.15),
        perMinuteRate: _toDouble(json['perMinuteRate'], fallback: 0.35),
        serviceFee: _toDouble(json['serviceFee'], fallback: 1.50),
        tip: json['tip'] != null ? _toDouble(json['tip']) : null,
        estimatedMinutes: _toInt(json['estimatedMinutes']),
        estimatedDistance: _toDouble(json['estimatedDistance']),
        driverName: json['driverName']?.toString(),
        driverPhotoUrl: json['driverPhotoUrl']?.toString(),
        driverRating: json['driverRating'] != null ? _toDouble(json['driverRating']) : null,
        driverTotalRides: json['driverTotalRides'] != null ? _toInt(json['driverTotalRides']) : null,
        vehicleModel: json['vehicleModel']?.toString(),
        vehiclePlate: json['vehiclePlate']?.toString(),
        vehicleColor: json['vehicleColor']?.toString(),
        etaMinutes: json['etaMinutes'] != null ? _toInt(json['etaMinutes']) : null,
        createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
        completedAt: _parseDateTime(json['completedAt']),
        isRated: json['isRated'] == true,
        paymentMethod: _parsePaymentMethod(json['paymentMethod']?.toString()),
      );
    } catch (e) {
      debugPrint('_rideFromJson error: $e');
      return RideRequest(
        id: json['id']?.toString() ?? 'unknown',
        pickupAddress: json['pickupAddress']?.toString() ?? '',
        destinationAddress: json['destinationAddress']?.toString() ?? '',
        createdAt: DateTime.now(),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PARSING UTILITIES
  // ═══════════════════════════════════════════════════════════════════════════

  double _toDouble(dynamic value, {double fallback = 0.0}) {
    if (value == null) return fallback;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  List<String> _toStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  Map<String, String> _toStringMap(dynamic value) {
    if (value == null) return {};
    if (value is Map) return value.map((k, v) => MapEntry(k.toString(), v.toString()));
    return {};
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  MerchantStatus _parseMerchantStatus(String? value) {
    switch (value) {
      case 'open': return MerchantStatus.open;
      case 'closed': return MerchantStatus.closed;
      case 'busy': return MerchantStatus.busy;
      case 'temporarilyClosed': return MerchantStatus.temporarilyClosed;
      default: return MerchantStatus.open;
    }
  }

  VerificationTier _parseVerificationTier(String? value) {
    switch (value) {
      case 'basic': return VerificationTier.basic;
      case 'verified': return VerificationTier.verified;
      case 'premium': return VerificationTier.premium;
      default: return VerificationTier.none;
    }
  }

  MerchantCategory _parseMerchantCategory(String? value) {
    switch (value) {
      case 'food': return MerchantCategory.food;
      case 'drinks': return MerchantCategory.drinks;
      case 'pharmacy': return MerchantCategory.pharmacy;
      case 'services': return MerchantCategory.services;
      case 'electronics': return MerchantCategory.electronics;
      case 'fashion': return MerchantCategory.fashion;
      case 'grocery': return MerchantCategory.grocery;
      case 'other': return MerchantCategory.other;
      default: return MerchantCategory.food;
    }
  }

  FulfillmentMethod _parseFulfillmentMethod(String? value) {
    switch (value) {
      case 'delivery': return FulfillmentMethod.delivery;
      case 'pickup': return FulfillmentMethod.pickup;
      case 'both': return FulfillmentMethod.both;
      case 'dineIn': return FulfillmentMethod.dineIn;
      default: return FulfillmentMethod.both;
    }
  }

  ProductAvailability _parseAvailability(String? value) {
    switch (value) {
      case 'inStock': return ProductAvailability.inStock;
      case 'lowStock': return ProductAvailability.lowStock;
      case 'outOfStock': return ProductAvailability.outOfStock;
      case 'preOrder': return ProductAvailability.preOrder;
      default: return ProductAvailability.inStock;
    }
  }

  OrderStatus _parseOrderStatus(String? value) {
    switch (value) {
      case 'pending': return OrderStatus.pending;
      case 'confirmed': return OrderStatus.confirmed;
      case 'preparing': return OrderStatus.preparing;
      case 'readyForPickup': return OrderStatus.readyForPickup;
      case 'onTheWay': return OrderStatus.onTheWay;
      case 'delivered': return OrderStatus.delivered;
      case 'pickedUp': return OrderStatus.pickedUp;
      case 'cancelled': return OrderStatus.cancelled;
      case 'refunded': return OrderStatus.refunded;
      default: return OrderStatus.pending;
    }
  }

  ReturnStatus _parseReturnStatus(String? value) {
    switch (value) {
      case 'requested': return ReturnStatus.requested;
      case 'evidenceSubmitted': return ReturnStatus.evidenceSubmitted;
      case 'underReview': return ReturnStatus.underReview;
      case 'approved': return ReturnStatus.approved;
      case 'rejected': return ReturnStatus.rejected;
      case 'refundProcessed': return ReturnStatus.refundProcessed;
      default: return ReturnStatus.requested;
    }
  }

  ReturnReason _parseReturnReason(String? value) {
    switch (value) {
      case 'damaged': return ReturnReason.damaged;
      case 'wrongItem': return ReturnReason.wrongItem;
      case 'expired': return ReturnReason.expired;
      case 'notAsDescribed': return ReturnReason.notAsDescribed;
      case 'changedMind': return ReturnReason.changedMind;
      case 'other': return ReturnReason.other;
      default: return ReturnReason.other;
    }
  }

  RefundMethod _parseRefundMethod(String? value) {
    switch (value) {
      case 'originalPayment': return RefundMethod.originalPayment;
      case 'storeCredit': return RefundMethod.storeCredit;
      case 'qPoints': return RefundMethod.qPoints;
      case 'replacement': return RefundMethod.replacement;
      default: return RefundMethod.originalPayment;
    }
  }

  RideStatus _parseRideStatus(String? value) {
    switch (value) {
      case 'searching': return RideStatus.searching;
      case 'driverAssigned': return RideStatus.driverAssigned;
      case 'driverEnRoute': return RideStatus.driverEnRoute;
      case 'arrived': return RideStatus.arrived;
      case 'inProgress': return RideStatus.inProgress;
      case 'completed': return RideStatus.completed;
      case 'cancelled': return RideStatus.cancelled;
      default: return RideStatus.searching;
    }
  }

  RideType _parseRideType(String? value) {
    switch (value) {
      case 'standard': return RideType.standard;
      case 'premium': return RideType.premium;
      case 'xl': return RideType.xl;
      case 'eco': return RideType.eco;
      case 'assist': return RideType.assist;
      default: return RideType.standard;
    }
  }

  PaymentMethodType _parsePaymentMethod(String? value) {
    switch (value) {
      case 'card': return PaymentMethodType.card;
      case 'qPoints': return PaymentMethodType.qPoints;
      case 'tabCredit': return PaymentMethodType.tabCredit;
      case 'applePay': return PaymentMethodType.applePay;
      case 'googlePay': return PaymentMethodType.googlePay;
      case 'paypal': return PaymentMethodType.paypal;
      default: return PaymentMethodType.card;
    }
  }

  List<DietaryPreference> _parseDietaryList(dynamic value) {
    if (value == null || value is! List) return [];
    return value.map((e) {
      switch (e.toString()) {
        case 'vegetarian': return DietaryPreference.vegetarian;
        case 'vegan': return DietaryPreference.vegan;
        case 'glutenFree': return DietaryPreference.glutenFree;
        case 'halal': return DietaryPreference.halal;
        case 'kosher': return DietaryPreference.kosher;
        case 'organic': return DietaryPreference.organic;
        default: return DietaryPreference.vegetarian;
      }
    }).toList();
  }

  List<ProductVariant> _parseVariants(dynamic value) {
    if (value == null || value is! List) return [];
    return value.map<ProductVariant>((v) {
      final json = v as Map<String, dynamic>;
      return ProductVariant(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        value: json['value']?.toString() ?? '',
        priceAdjustment: json['priceAdjustment'] != null ? _toDouble(json['priceAdjustment']) : null,
        isSelected: json['isSelected'] == true,
      );
    }).toList();
  }

  List<ProductAddon> _parseAddons(dynamic value) {
    if (value == null || value is! List) return [];
    return value.map<ProductAddon>((a) {
      final json = a as Map<String, dynamic>;
      return ProductAddon(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        price: _toDouble(json['price']),
        isSelected: json['isSelected'] == true,
        maxSelections: _toInt(json['maxSelections'], fallback: 1),
      );
    }).toList();
  }

  List<OrderItem> _parseOrderItems(dynamic value) {
    if (value == null || value is! List) return [];
    return value.map<OrderItem>((item) {
      final json = item as Map<String, dynamic>;
      return OrderItem(
        productId: json['productId']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        imageUrl: json['imageUrl']?.toString(),
        quantity: _toInt(json['quantity'], fallback: 1),
        price: _toDouble(json['price']),
        customization: json['customization']?.toString(),
      );
    }).toList();
  }

  List<ReturnItem> _parseReturnItems(dynamic value) {
    if (value == null || value is! List) return [];
    return value.map<ReturnItem>((item) {
      final json = item as Map<String, dynamic>;
      return ReturnItem(
        productId: json['productId']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        imageUrl: json['imageUrl']?.toString(),
        quantity: _toInt(json['quantity'], fallback: 1),
        price: _toDouble(json['price']),
        reason: _parseReturnReason(json['reason']?.toString()),
      );
    }).toList();
  }

  List<ProductCategory> _deriveCategoriesFromProducts(List<MarketProduct> products) {
    final catMap = <String, int>{};
    for (final p in products) {
      catMap[p.categoryName] = (catMap[p.categoryName] ?? 0) + 1;
    }
    if (catMap.isEmpty) return _fallbackCategories;

    final icons = <String, IconData>{
      'Signature Rolls': Icons.set_meal,
      'Sashimi': Icons.restaurant,
      'Soups': Icons.soup_kitchen,
      'Burgers': Icons.lunch_dining,
      'Sides': Icons.fastfood,
      'Pizza': Icons.local_pizza,
      'Drinks': Icons.local_cafe,
      'Coffee': Icons.local_cafe,
      'Desserts': Icons.cake,
      'Vitamins': Icons.medical_services,
      'Audio': Icons.headphones,
      'Fruits': Icons.eco,
    };

    int idx = 0;
    return catMap.entries.map((entry) {
      idx++;
      return ProductCategory(
        id: 'cat_$idx',
        name: entry.key,
        icon: icons[entry.key] ?? Icons.category,
        itemCount: entry.value,
      );
    }).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FALLBACK DEMO DATA — Used when API calls fail
  // ═══════════════════════════════════════════════════════════════════════════

  static final List<Merchant> _fallbackMerchants = [
    const Merchant(
      id: 'merch_1',
      name: 'Sushi Palace',
      description: 'Premium Japanese cuisine with fresh daily imports. Enjoy our signature omakase experience.',
      status: MerchantStatus.open,
      verification: VerificationTier.premium,
      category: MerchantCategory.food,
      tags: ['Japanese', 'Sushi', '\$\$\$'],
      rating: 4.8,
      ratingCount: 342,
      distanceMiles: 1.2,
      deliveryTimeMin: 25,
      deliveryTimeMax: 35,
      deliveryFee: 2.99,
      minimumOrder: 15.0,
      fulfillment: FulfillmentMethod.both,
      address: '123 Main St, Downtown',
      phone: '(555) 123-4567',
      email: 'info@sushipalace.com',
      website: 'https://sushipalace.com',
      hours: {'Mon-Fri': '11AM-10PM', 'Sat-Sun': '12PM-11PM'},
      isFavorite: true,
      isTrending: true,
      activeDeals: 2,
    ),
    const Merchant(
      id: 'merch_2',
      name: 'Burger Kingdom',
      description: 'Gourmet burgers made with locally sourced ingredients. Our special sauce is legendary.',
      status: MerchantStatus.open,
      verification: VerificationTier.verified,
      category: MerchantCategory.food,
      tags: ['American', 'Burgers', '\$\$'],
      rating: 4.5,
      ratingCount: 567,
      distanceMiles: 0.8,
      deliveryTimeMin: 15,
      deliveryTimeMax: 25,
      deliveryFee: 1.99,
      minimumOrder: 10.0,
      address: '456 Oak Ave, Midtown',
      phone: '(555) 234-5678',
      hours: {'Mon-Sun': '10AM-12AM'},
      isTrending: true,
      activeDeals: 1,
    ),
    const Merchant(
      id: 'merch_3',
      name: 'Green Pharmacy',
      description: 'Your trusted neighborhood pharmacy with 24/7 delivery service.',
      status: MerchantStatus.open,
      verification: VerificationTier.verified,
      category: MerchantCategory.pharmacy,
      tags: ['Pharmacy', 'Health', '24/7'],
      rating: 4.9,
      ratingCount: 891,
      distanceMiles: 2.1,
      deliveryTimeMin: 20,
      deliveryTimeMax: 30,
      deliveryFee: 0.0,
      minimumOrder: 0.0,
      address: '789 Health Blvd',
      phone: '(555) 345-6789',
      hours: {'Mon-Sun': 'Open 24 Hours'},
      activeDeals: 3,
    ),
    const Merchant(
      id: 'merch_4',
      name: 'TechZone Electronics',
      description: 'Latest gadgets, accessories, and tech repairs. Authorized dealer for major brands.',
      status: MerchantStatus.open,
      verification: VerificationTier.premium,
      category: MerchantCategory.electronics,
      tags: ['Electronics', 'Gadgets', '\$\$\$'],
      rating: 4.6,
      ratingCount: 234,
      distanceMiles: 3.5,
      deliveryTimeMin: 30,
      deliveryTimeMax: 45,
      deliveryFee: 4.99,
      minimumOrder: 25.0,
      fulfillment: FulfillmentMethod.both,
      address: '321 Tech Park',
      phone: '(555) 456-7890',
      hours: {'Mon-Sat': '9AM-9PM', 'Sun': '10AM-6PM'},
      activeDeals: 1,
    ),
    const Merchant(
      id: 'merch_5',
      name: 'Fresh & Brew Coffee',
      description: 'Artisan coffee roasted in-house. Organic pastries and light bites.',
      status: MerchantStatus.open,
      verification: VerificationTier.basic,
      category: MerchantCategory.drinks,
      tags: ['Coffee', 'Pastries', '\$'],
      rating: 4.7,
      ratingCount: 1024,
      distanceMiles: 0.5,
      deliveryTimeMin: 10,
      deliveryTimeMax: 20,
      deliveryFee: 1.49,
      minimumOrder: 5.0,
      address: '55 Brew Lane',
      isFavorite: true,
      hours: {'Mon-Fri': '6AM-8PM', 'Sat-Sun': '7AM-6PM'},
    ),
    const Merchant(
      id: 'merch_6',
      name: 'Bella Fashion',
      description: 'Trendy fashion for all seasons. New arrivals every week.',
      status: MerchantStatus.closed,
      verification: VerificationTier.verified,
      category: MerchantCategory.fashion,
      tags: ['Fashion', 'Clothing', '\$\$'],
      rating: 4.3,
      ratingCount: 156,
      distanceMiles: 4.2,
      deliveryTimeMin: 60,
      deliveryTimeMax: 90,
      deliveryFee: 5.99,
      minimumOrder: 30.0,
      fulfillment: FulfillmentMethod.delivery,
      address: '88 Fashion Ave',
      hours: {'Mon-Sat': '10AM-8PM', 'Sun': 'Closed'},
    ),
    const Merchant(
      id: 'merch_7',
      name: 'Mario\'s Italian',
      description: 'Authentic Italian food made with love. Family recipes since 1985.',
      status: MerchantStatus.busy,
      verification: VerificationTier.verified,
      category: MerchantCategory.food,
      tags: ['Italian', 'Pizza', 'Pasta', '\$\$'],
      rating: 4.7,
      ratingCount: 789,
      distanceMiles: 1.8,
      deliveryTimeMin: 30,
      deliveryTimeMax: 45,
      deliveryFee: 2.49,
      minimumOrder: 12.0,
      address: '42 Italia St',
      hours: {'Mon-Sun': '11AM-11PM'},
      isTrending: true,
    ),
    const Merchant(
      id: 'merch_8',
      name: 'QuickMart Grocery',
      description: 'Your daily essentials delivered in under 30 minutes.',
      status: MerchantStatus.open,
      verification: VerificationTier.verified,
      category: MerchantCategory.grocery,
      tags: ['Grocery', 'Essentials', '\$'],
      rating: 4.4,
      ratingCount: 432,
      distanceMiles: 1.0,
      deliveryTimeMin: 15,
      deliveryTimeMax: 25,
      deliveryFee: 0.0,
      minimumOrder: 10.0,
      address: '99 Quick Blvd',
      hours: {'Mon-Sun': '7AM-11PM'},
      activeDeals: 4,
    ),
  ];

  static final List<MarketProduct> _fallbackProducts = [
    const MarketProduct(
      id: 'prod_1',
      merchantId: 'merch_1',
      name: 'Dragon Roll',
      description: 'Shrimp tempura, avocado, eel, tobiko. Our signature roll with a spicy kick.',
      price: 18.99,
      comparePrice: 24.99,
      unitPrice: '\$1.90/piece',
      category: MerchantCategory.food,
      categoryName: 'Signature Rolls',
      rating: 4.9,
      ratingCount: 124,
      badges: ['BESTSELLER'],
      hasCustomization: true,
      customizationNote: 'Choose spice level',
      specifications: {'Pieces': '10', 'Allergens': 'Shellfish, Soy'},
    ),
    const MarketProduct(
      id: 'prod_2',
      merchantId: 'merch_1',
      name: 'Salmon Sashimi',
      description: 'Fresh Norwegian salmon, thinly sliced. Served with wasabi and ginger.',
      price: 14.99,
      category: MerchantCategory.food,
      categoryName: 'Sashimi',
      rating: 4.8,
      ratingCount: 89,
      badges: ['NEW'],
      dietary: [DietaryPreference.glutenFree],
    ),
    const MarketProduct(
      id: 'prod_3',
      merchantId: 'merch_1',
      name: 'Miso Soup',
      description: 'Traditional miso with tofu, wakame, and green onion.',
      price: 4.99,
      category: MerchantCategory.food,
      categoryName: 'Soups',
      rating: 4.6,
      ratingCount: 201,
      dietary: [DietaryPreference.vegetarian, DietaryPreference.glutenFree],
    ),
    const MarketProduct(
      id: 'prod_4',
      merchantId: 'merch_2',
      name: 'Classic Smash Burger',
      description: 'Double patty, American cheese, pickles, special sauce on a brioche bun.',
      price: 12.99,
      comparePrice: 15.99,
      category: MerchantCategory.food,
      categoryName: 'Burgers',
      rating: 4.7,
      ratingCount: 345,
      badges: ['BESTSELLER'],
      hasCustomization: true,
      customizationNote: 'Choose bread type',
      addons: [
        ProductAddon(id: 'addon_1', name: 'Extra Cheese', price: 1.50),
        ProductAddon(id: 'addon_2', name: 'Bacon', price: 2.00),
        ProductAddon(id: 'addon_3', name: 'Avocado', price: 1.75),
      ],
    ),
    const MarketProduct(
      id: 'prod_5',
      merchantId: 'merch_2',
      name: 'Truffle Fries',
      description: 'Crispy fries with truffle oil, parmesan, and fresh herbs.',
      price: 8.99,
      category: MerchantCategory.food,
      categoryName: 'Sides',
      rating: 4.5,
      ratingCount: 178,
      dietary: [DietaryPreference.vegetarian],
    ),
    const MarketProduct(
      id: 'prod_6',
      merchantId: 'merch_3',
      name: 'Vitamin C Complex',
      description: '1000mg Vitamin C with zinc. 90 tablets.',
      price: 15.99,
      category: MerchantCategory.pharmacy,
      categoryName: 'Vitamins',
      rating: 4.8,
      ratingCount: 432,
      specifications: {'Dosage': '1000mg', 'Count': '90 tablets', 'Brand': 'HealthPlus'},
    ),
    const MarketProduct(
      id: 'prod_7',
      merchantId: 'merch_4',
      name: 'Wireless Earbuds Pro',
      description: 'Active noise cancellation, 24h battery, IPX5 waterproof.',
      price: 79.99,
      comparePrice: 99.99,
      category: MerchantCategory.electronics,
      categoryName: 'Audio',
      rating: 4.6,
      ratingCount: 89,
      badges: ['LIMITED'],
      specifications: {'Battery': '24 hours', 'Connectivity': 'Bluetooth 5.3', 'Weight': '5.2g per bud'},
    ),
    const MarketProduct(
      id: 'prod_8',
      merchantId: 'merch_5',
      name: 'Signature Latte',
      description: 'Double shot espresso with steamed oat milk and vanilla.',
      price: 5.99,
      category: MerchantCategory.drinks,
      categoryName: 'Coffee',
      rating: 4.9,
      ratingCount: 567,
      badges: ['BESTSELLER'],
      hasCustomization: true,
      customizationNote: 'Choose milk type',
      dietary: [DietaryPreference.vegan],
      variants: [
        ProductVariant(id: 'var_1', name: 'Size', value: 'Small', priceAdjustment: -1.00),
        ProductVariant(id: 'var_2', name: 'Size', value: 'Medium'),
        ProductVariant(id: 'var_3', name: 'Size', value: 'Large', priceAdjustment: 1.50),
      ],
    ),
    const MarketProduct(
      id: 'prod_9',
      merchantId: 'merch_7',
      name: 'Margherita Pizza',
      description: 'San Marzano tomatoes, fresh mozzarella, basil, extra virgin olive oil.',
      price: 16.99,
      category: MerchantCategory.food,
      categoryName: 'Pizza',
      rating: 4.8,
      ratingCount: 456,
      badges: ['BESTSELLER'],
      dietary: [DietaryPreference.vegetarian],
      variants: [
        ProductVariant(id: 'var_4', name: 'Size', value: 'Personal (8")', priceAdjustment: -4.00),
        ProductVariant(id: 'var_5', name: 'Size', value: 'Medium (12")'),
        ProductVariant(id: 'var_6', name: 'Size', value: 'Large (16")', priceAdjustment: 4.00),
      ],
    ),
    const MarketProduct(
      id: 'prod_10',
      merchantId: 'merch_8',
      name: 'Organic Bananas',
      description: 'Fresh organic bananas, bunch of 6.',
      price: 2.49,
      category: MerchantCategory.grocery,
      categoryName: 'Fruits',
      rating: 4.5,
      ratingCount: 312,
      dietary: [DietaryPreference.vegan, DietaryPreference.organic, DietaryPreference.glutenFree],
    ),
  ];

  static const List<ProductCategory> _fallbackCategories = [
    ProductCategory(id: 'cat_1', name: 'Signature Rolls', icon: Icons.set_meal, itemCount: 12),
    ProductCategory(id: 'cat_2', name: 'Sashimi', icon: Icons.restaurant, itemCount: 8),
    ProductCategory(id: 'cat_3', name: 'Soups', icon: Icons.soup_kitchen, itemCount: 5),
    ProductCategory(id: 'cat_4', name: 'Burgers', icon: Icons.lunch_dining, itemCount: 15),
    ProductCategory(id: 'cat_5', name: 'Sides', icon: Icons.fastfood, itemCount: 10),
    ProductCategory(id: 'cat_6', name: 'Pizza', icon: Icons.local_pizza, itemCount: 9),
    ProductCategory(id: 'cat_7', name: 'Drinks', icon: Icons.local_cafe, itemCount: 18),
    ProductCategory(id: 'cat_8', name: 'Desserts', icon: Icons.cake, itemCount: 7),
  ];

  static final List<MarketOrder> _fallbackOrders = [
    MarketOrder(
      id: 'ORD-789012',
      merchantId: 'merch_1',
      merchantName: 'Sushi Palace',
      status: OrderStatus.onTheWay,
      fulfillment: FulfillmentMethod.delivery,
      items: const [
        OrderItem(productId: 'prod_1', name: 'Dragon Roll', quantity: 2, price: 18.99),
        OrderItem(productId: 'prod_2', name: 'Salmon Sashimi', quantity: 1, price: 14.99),
      ],
      subtotal: 52.97,
      deliveryFee: 0.0,
      serviceFee: 1.99,
      tax: 3.71,
      total: 58.67,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      estimatedDelivery: DateTime.now().add(const Duration(minutes: 18)),
      driverName: 'Alex M.',
      vehicleInfo: 'Honda Civic (White)',
      deliveryAddress: '123 Main St, Apt 4B',
      deliveryInstructions: 'Leave at door',
      trackingPin: '4829',
      paymentMethod: PaymentMethodType.card,
    ),
    MarketOrder(
      id: 'ORD-789013',
      merchantId: 'merch_2',
      merchantName: 'Burger Kingdom',
      status: OrderStatus.readyForPickup,
      fulfillment: FulfillmentMethod.pickup,
      items: const [
        OrderItem(productId: 'prod_4', name: 'Classic Smash Burger', quantity: 1, price: 12.99),
        OrderItem(productId: 'prod_5', name: 'Truffle Fries', quantity: 1, price: 8.99),
      ],
      subtotal: 21.98,
      serviceFee: 0.99,
      tax: 1.54,
      total: 24.51,
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      pickupCode: 'A1B2C3',
      paymentMethod: PaymentMethodType.qPoints,
    ),
    MarketOrder(
      id: 'ORD-789010',
      merchantId: 'merch_5',
      merchantName: 'Fresh & Brew Coffee',
      status: OrderStatus.delivered,
      fulfillment: FulfillmentMethod.delivery,
      items: const [
        OrderItem(productId: 'prod_8', name: 'Signature Latte', quantity: 2, price: 5.99),
      ],
      subtotal: 11.98,
      deliveryFee: 1.49,
      serviceFee: 0.99,
      tax: 0.84,
      total: 15.30,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      deliveredAt: DateTime.now().subtract(const Duration(days: 2, hours: -1)),
      isRated: true,
    ),
    MarketOrder(
      id: 'ORD-789008',
      merchantId: 'merch_7',
      merchantName: 'Mario\'s Italian',
      status: OrderStatus.delivered,
      fulfillment: FulfillmentMethod.delivery,
      items: const [
        OrderItem(productId: 'prod_9', name: 'Margherita Pizza', quantity: 1, price: 16.99),
      ],
      subtotal: 16.99,
      deliveryFee: 2.49,
      serviceFee: 1.49,
      tax: 1.19,
      total: 22.16,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      deliveredAt: DateTime.now().subtract(const Duration(days: 5, hours: -1)),
    ),
    MarketOrder(
      id: 'ORD-789005',
      merchantId: 'merch_4',
      merchantName: 'TechZone Electronics',
      status: OrderStatus.cancelled,
      items: const [
        OrderItem(productId: 'prod_7', name: 'Wireless Earbuds Pro', quantity: 1, price: 79.99),
      ],
      subtotal: 79.99,
      deliveryFee: 4.99,
      serviceFee: 1.99,
      tax: 5.60,
      total: 92.57,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    MarketOrder(
      id: 'ORD-789014',
      merchantId: 'merch_1',
      merchantName: 'Sushi Palace',
      status: OrderStatus.preparing,
      fulfillment: FulfillmentMethod.delivery,
      items: const [
        OrderItem(productId: 'prod_3', name: 'Miso Soup', quantity: 2, price: 4.99),
        OrderItem(productId: 'prod_1', name: 'Dragon Roll', quantity: 1, price: 18.99),
      ],
      subtotal: 28.97,
      deliveryFee: 0.0,
      serviceFee: 1.99,
      tax: 2.03,
      total: 32.99,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      estimatedDelivery: DateTime.now().add(const Duration(minutes: 35)),
    ),
  ];

  static final List<ReturnRequest> _fallbackReturns = [
    ReturnRequest(
      id: 'RET-789012',
      orderId: 'ORD-789010',
      merchantName: 'Fresh & Brew Coffee',
      status: ReturnStatus.underReview,
      items: const [
        ReturnItem(productId: 'prod_8', name: 'Signature Latte', quantity: 1, price: 5.99, reason: ReturnReason.damaged),
      ],
      reason: ReturnReason.damaged,
      reasonDetail: 'Cup was cracked and half the drink spilled during delivery.',
      preferredRefund: RefundMethod.qPoints,
      estimatedRefund: 5.99,
      evidencePhotos: ['photo_1.jpg', 'photo_2.jpg', 'photo_3.jpg'],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ReturnRequest(
      id: 'RET-789013',
      orderId: 'ORD-789008',
      merchantName: 'Mario\'s Italian',
      status: ReturnStatus.refundProcessed,
      items: const [
        ReturnItem(productId: 'prod_9', name: 'Margherita Pizza', quantity: 1, price: 16.99, reason: ReturnReason.wrongItem),
      ],
      reason: ReturnReason.wrongItem,
      reasonDetail: 'Received pepperoni pizza instead of margherita.',
      preferredRefund: RefundMethod.originalPayment,
      estimatedRefund: 16.99,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      resolvedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  static final DeliveryTracking _fallbackDeliveryTracking = DeliveryTracking(
    orderId: 'ORD-789012',
    currentStep: DeliveryStep.onTheWay,
    driverLat: 40.7580,
    driverLng: -73.9855,
    destinationLat: 40.7614,
    destinationLng: -73.9776,
    merchantLat: 40.7484,
    merchantLng: -73.9857,
    driverName: 'Alex M.',
    driverRating: 4.9,
    driverDeliveries: 124,
    vehicleInfo: 'Honda Civic (White)',
    vehiclePlate: 'ABC-123',
    etaMinutes: 12,
    distanceMiles: 3.2,
    deliveryPin: '4829',
    lastUpdated: DateTime.now().subtract(const Duration(seconds: 30)),
    timeline: [
      TrackingEvent(
        step: DeliveryStep.confirmed,
        label: 'Order confirmed',
        detail: 'Your order has been confirmed by Sushi Palace',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isCompleted: true,
      ),
      TrackingEvent(
        step: DeliveryStep.preparing,
        label: 'Preparing',
        detail: 'Sushi Palace is preparing your order',
        timestamp: DateTime.now().subtract(const Duration(minutes: 32)),
        isCompleted: true,
      ),
      TrackingEvent(
        step: DeliveryStep.onTheWay,
        label: 'On the way',
        detail: 'Alex M. has your order',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        isCurrent: true,
      ),
      const TrackingEvent(
        step: DeliveryStep.delivered,
        label: 'Delivered',
      ),
    ],
  );

  static final List<RideRequest> _fallbackRides = [
    RideRequest(
      id: 'ride_001',
      status: RideStatus.completed,
      type: RideType.standard,
      pickupAddress: '123 Main St',
      destinationAddress: '456 Oak Ave',
      estimatedFare: 15.50,
      finalFare: 16.33,
      baseFare: 3.50,
      perMileRate: 2.15,
      perMinuteRate: 0.35,
      serviceFee: 1.50,
      tip: 3.00,
      estimatedMinutes: 18,
      estimatedDistance: 4.2,
      driverName: 'Michael T.',
      driverRating: 4.9,
      driverTotalRides: 1245,
      vehicleModel: '2020 Toyota Camry',
      vehiclePlate: 'XYZ-789',
      vehicleColor: 'White',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      completedAt: DateTime.now().subtract(const Duration(days: 3, hours: -1)),
      isRated: true,
      paymentMethod: PaymentMethodType.qPoints,
    ),
    RideRequest(
      id: 'ride_002',
      status: RideStatus.completed,
      type: RideType.premium,
      pickupAddress: '789 Health Blvd',
      destinationAddress: '321 Tech Park',
      estimatedFare: 22.75,
      finalFare: 24.10,
      baseFare: 5.00,
      perMileRate: 3.25,
      perMinuteRate: 0.50,
      serviceFee: 2.00,
      estimatedMinutes: 25,
      estimatedDistance: 6.1,
      driverName: 'Sarah K.',
      driverRating: 4.8,
      driverTotalRides: 890,
      vehicleModel: '2022 BMW 3 Series',
      vehiclePlate: 'LUX-456',
      vehicleColor: 'Black',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      completedAt: DateTime.now().subtract(const Duration(days: 7, hours: -1)),
      isRated: true,
    ),
  ];

  static const List<SavedPaymentMethod> _fallbackPaymentMethods = [
    SavedPaymentMethod(
      id: 'pay_1',
      type: PaymentMethodType.card,
      label: 'Visa ending in 1234',
      last4: '1234',
      brand: 'Visa',
      isDefault: true,
    ),
    SavedPaymentMethod(
      id: 'pay_2',
      type: PaymentMethodType.card,
      label: 'Mastercard ending in 5678',
      last4: '5678',
      brand: 'Mastercard',
    ),
    SavedPaymentMethod(
      id: 'pay_3',
      type: PaymentMethodType.qPoints,
      label: 'QPoints Balance',
      balance: 14250,
    ),
    SavedPaymentMethod(
      id: 'pay_4',
      type: PaymentMethodType.tabCredit,
      label: 'Tab Credit',
      balance: 500,
    ),
  ];

  static final List<MerchantDeal> _fallbackDeals = [
    MerchantDeal(
      id: 'deal_1',
      merchantId: 'merch_1',
      title: '20% Off Signature Rolls',
      description: 'Valid on all signature rolls. Limited time offer!',
      type: DealType.percentage,
      value: 20,
      code: 'SUSHI20',
      expiresAt: DateTime.now().add(const Duration(days: 3, hours: 2, minutes: 15)),
      maxRedemptions: 100,
      currentRedemptions: 42,
    ),
    MerchantDeal(
      id: 'deal_2',
      merchantId: 'merch_1',
      title: 'Free Delivery on \$25+',
      type: DealType.freeDelivery,
      value: 0,
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    ),
    MerchantDeal(
      id: 'deal_3',
      merchantId: 'merch_2',
      title: 'Buy 1 Get 1 Free Burgers',
      description: 'Every Wednesday! Buy any burger and get one free.',
      type: DealType.buyOneGetOne,
      value: 0,
      code: 'BOGOWED',
      expiresAt: DateTime.now().add(const Duration(hours: 8)),
      maxRedemptions: 50,
      currentRedemptions: 31,
    ),
    const MerchantDeal(
      id: 'deal_4',
      merchantId: 'merch_3',
      title: '\$5 Off First Pharmacy Order',
      type: DealType.fixedAmount,
      value: 5,
      code: 'PHARM5',
      isPersonalized: true,
    ),
    MerchantDeal(
      id: 'deal_5',
      merchantId: 'merch_8',
      title: '15% Off Groceries',
      description: 'Weekend special: 15% off all grocery items.',
      type: DealType.percentage,
      value: 15,
      code: 'FRESH15',
      expiresAt: DateTime.now().add(const Duration(days: 2)),
      maxRedemptions: 200,
      currentRedemptions: 87,
    ),
  ];

  static final List<MerchantPost> _fallbackMerchantPosts = [
    MerchantPost(
      id: 'post_1',
      merchantId: 'merch_1',
      content: 'Our new Dragon Roll is here! Made with the freshest ingredients imported daily from Tokyo. 🐉🍣',
      postType: 'image',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      views: 142,
      likes: 42,
      shares: 8,
    ),
    MerchantPost(
      id: 'post_2',
      merchantId: 'merch_1',
      content: '🎉 Special announcement: We are extending our hours! Now open until midnight on weekends.',
      postType: 'announcement',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      views: 89,
      likes: 31,
      shares: 5,
    ),
    MerchantPost(
      id: 'post_3',
      merchantId: 'merch_1',
      content: 'Watch our head chef prepare the legendary Omakase experience! 🎬',
      postType: 'video',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      views: 534,
      likes: 156,
      shares: 23,
    ),
  ];

  static final List<RejectedReturnVideo> _fallbackRejectedVideos = [
    RejectedReturnVideo(
      id: 'rv_1',
      returnId: 'RET-789099',
      title: 'Return #RET-789099 — Damaged Package',
      durationSeconds: 45,
      reason: ReturnReason.damaged,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      resolutionStatus: 'pending',
    ),
    RejectedReturnVideo(
      id: 'rv_2',
      returnId: 'RET-789088',
      title: 'Return #RET-789088 — Wrong Item',
      durationSeconds: 32,
      reason: ReturnReason.wrongItem,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      resolutionStatus: 'resolved',
    ),
    RejectedReturnVideo(
      id: 'rv_3',
      returnId: 'RET-789077',
      title: 'Return #RET-789077 — Item Expired',
      durationSeconds: 18,
      reason: ReturnReason.expired,
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      resolutionStatus: 'escalated',
    ),
  ];
}
