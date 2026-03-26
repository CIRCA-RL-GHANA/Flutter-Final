/// GO Module — Provider (State Management)
/// Comprehensive demo data for all 16 screens
/// Module Color: Emerald Green (0xFF10B981)

import 'package:flutter/material.dart';
import '../models/go_models.dart';
import '../../../core/services/services.dart';

class GoProvider extends ChangeNotifier {
  // ──── SERVICES ────────────────────────────────

  final QPointsService _qPointsService;
  final EntityService _entityService;

  GoProvider({
    QPointsService? qPointsService,
    EntityService? entityService,
  })  : _qPointsService = qPointsService ?? QPointsService(),
        _entityService = entityService ?? EntityService();

  // ──── LOADING / ERROR STATE ────────────────────────────────

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isTransactionsLoading = false;
  bool get isTransactionsLoading => _isTransactionsLoading;

  bool _isBalanceLoading = false;
  bool get isBalanceLoading => _isBalanceLoading;

  String? _error;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ──── INIT ────────────────────────────────

  Future<void> init({String? entityId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        loadTransactions(entityId: entityId),
        loadBalance(entityId: entityId),
      ]);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ──── ACTIVE CONTEXT ────────────────────────────────

  String _activeContextId = 'ctx-2';
  String get activeContextId => _activeContextId;
  void setActiveContext(String id) {
    _activeContextId = id;
    notifyListeners();
  }

  FinancialContext? get activeContext {
    final ctxList = contexts;
    try {
      return ctxList.firstWhere((c) => c.id == _activeContextId);
    } catch (_) {
      return null;
    }
  }

  // ──── CONTEXTS ────────────────────────────────

  List<FinancialContext> _contexts = [];

  static final List<FinancialContext> _fallbackContexts = [
    const FinancialContext(
      id: 'ctx-1',
      name: 'John Doe',
      role: 'Individual',
      type: FinancialContextType.personal,
      permission: ContextPermission.fullAccess,
      qpBalance: 14250,
      lastActivity: '2 hrs ago',
      activeTabs: 2,
      pendingTransactions: 1,
      unreadAlerts: 0,
      favoritesCount: 8,
    ),
    const FinancialContext(
      id: 'ctx-2',
      name: 'Wizdom Shop',
      role: 'Admin',
      type: FinancialContextType.business,
      permission: ContextPermission.fullAccess,
      qpBalance: 172100,
      lastActivity: '15 min ago',
      activeTabs: 5,
      pendingTransactions: 3,
      unreadAlerts: 2,
      favoritesCount: 24,
    ),
    const FinancialContext(
      id: 'ctx-3',
      name: 'Accra-Mall Branch',
      role: 'Branch Manager',
      type: FinancialContextType.branch,
      permission: ContextPermission.viewOnly,
      qpBalance: 24500,
      lastActivity: '1 day ago',
      activeTabs: 1,
      pendingTransactions: 0,
      unreadAlerts: 1,
      favoritesCount: 6,
    ),
    const FinancialContext(
      id: 'ctx-4',
      name: 'BrightMart Admin',
      role: 'Entity Admin',
      type: FinancialContextType.entity,
      permission: ContextPermission.fullAccess,
      qpBalance: 35700,
      lastActivity: '3 hrs ago',
      activeTabs: 3,
      pendingTransactions: 0,
      unreadAlerts: 0,
      favoritesCount: 15,
    ),
  ];

  List<FinancialContext> get contexts =>
      _contexts.isNotEmpty ? _contexts : _fallbackContexts;

  double get totalNetWorth => contexts.fold(0, (s, c) => s + c.qpBalance);
  double get change24h => 2.3;

  // ──── LIQUIDITY ────────────────────────────────

  LiquidityInfo get liquidity =>
      const LiquidityInfo(available: 14250, frozen: 2000, reserved: 230300);

  // ──── GATEWAYS ────────────────────────────────

  static final List<PaymentGateway> _fallbackGateways = [
    const PaymentGateway(id: 'gw-1', name: 'Paystack', status: GatewayStatus.live, balance: 8450, buyRate: 0.085, sellRate: 0.083, minBuy: 100, maxBuy: 50000, minSell: 500, maxSell: 20000, feePercent: 0.85, flatFee: 5, processingTime: 'Instant'),
    const PaymentGateway(id: 'gw-2', name: 'Flutterwave', status: GatewayStatus.live, balance: 12300, buyRate: 0.083, sellRate: 0.081, minBuy: 500, maxBuy: 100000, minSell: 1000, maxSell: 50000, feePercent: 1.2, processingTime: '2-5 min'),
    const PaymentGateway(id: 'gw-3', name: 'Bank Transfer', status: GatewayStatus.pending, balance: 45000, buyRate: 0.086, sellRate: 0.084, minBuy: 1000, maxBuy: 200000, minSell: 2000, maxSell: 100000, feePercent: 0.5, processingTime: '1-3 hrs'),
    const PaymentGateway(id: 'gw-4', name: 'Crypto', status: GatewayStatus.setupRequired, balance: 0, buyRate: 0.09, sellRate: 0.088, minBuy: 0, maxBuy: 999999, minSell: 0, maxSell: 999999, feePercent: 0, processingTime: '~15 min'),
  ];

  List<PaymentGateway> _gateways = [];

  List<PaymentGateway> get gateways =>
      _gateways.isNotEmpty ? _gateways : _fallbackGateways;

  List<PaymentGateway> get liveGateways =>
      gateways.where((g) => g.status == GatewayStatus.live).toList();

  // ──── TRANSACTIONS ────────────────────────────────

  static final List<GoTransaction> _fallbackTransactions = [
    GoTransaction(id: 'TX-4623', type: TransactionType.buy, status: TransactionStatus.completed, amount: 5000, feeAmount: 42.50, netAmount: 4957.50, fromEntity: 'You (John)', toEntity: 'System Wallet', gatewayName: 'Paystack', fundingSource: 'Paystack Balance', createdAt: DateTime.now().subtract(const Duration(hours: 2)), completedAt: DateTime.now().subtract(const Duration(hours: 2)), reference: 'TX-BUY-78901', note: 'Monthly top-up'),
    GoTransaction(id: 'TX-4622', type: TransactionType.transfer, status: TransactionStatus.completed, amount: 1200, feeAmount: 0.85, netAmount: 1199.15, fromEntity: 'You', toEntity: 'Leo Mensah', createdAt: DateTime.now().subtract(const Duration(hours: 5)), completedAt: DateTime.now().subtract(const Duration(hours: 5)), reference: 'TX-TRF-78900', note: 'Driver payment'),
    GoTransaction(id: 'TX-4621', type: TransactionType.tabSettlement, status: TransactionStatus.completed, amount: 800, fromEntity: 'BrightMart', toEntity: 'You', createdAt: DateTime.now().subtract(const Duration(days: 1)), completedAt: DateTime.now().subtract(const Duration(days: 1)), reference: 'TX-TAB-78899'),
    GoTransaction(id: 'TX-4620', type: TransactionType.sell, status: TransactionStatus.processing, amount: 3000, feeAmount: 45, netAmount: 2955, fromEntity: 'System Wallet', toEntity: 'Bank (•••• 4582)', gatewayName: 'Paystack', createdAt: DateTime.now().subtract(const Duration(days: 1)), reference: 'TX-SEL-78898'),
    GoTransaction(id: 'TX-4619', type: TransactionType.buy, status: TransactionStatus.completed, amount: 10000, feeAmount: 85, netAmount: 9915, fromEntity: 'You', toEntity: 'System Wallet', gatewayName: 'Flutterwave', fundingSource: 'Mobile Money', createdAt: DateTime.now().subtract(const Duration(days: 2)), completedAt: DateTime.now().subtract(const Duration(days: 2)), reference: 'TX-BUY-78897'),
    GoTransaction(id: 'TX-4618', type: TransactionType.transfer, status: TransactionStatus.failed, amount: 500, fromEntity: 'You', toEntity: 'Sarah Chen', createdAt: DateTime.now().subtract(const Duration(days: 2)), reference: 'TX-TRF-78896', note: 'Insufficient balance'),
    GoTransaction(id: 'TX-4617', type: TransactionType.fee, status: TransactionStatus.completed, amount: 15, fromEntity: 'System', toEntity: 'Service Fee', createdAt: DateTime.now().subtract(const Duration(days: 3)), completedAt: DateTime.now().subtract(const Duration(days: 3)), reference: 'TX-FEE-78895'),
    GoTransaction(id: 'TX-4616', type: TransactionType.batchPayment, status: TransactionStatus.completed, amount: 4500, fromEntity: 'You', toEntity: '5 receivers', createdAt: DateTime.now().subtract(const Duration(days: 4)), completedAt: DateTime.now().subtract(const Duration(days: 4)), reference: 'TX-BAT-78894', note: 'Weekly payroll'),
  ];

  List<GoTransaction> _transactions = [];

  List<GoTransaction> get transactions =>
      _transactions.isNotEmpty ? _transactions : _fallbackTransactions;

  List<GoTransaction> transactionsByTab(ActivityTab tab) {
    final txns = transactions;
    switch (tab) {
      case ActivityTab.all:
        return txns;
      case ActivityTab.credits:
        return txns.where((t) => t.type == TransactionType.tabSettlement || t.isCredit).toList();
      case ActivityTab.debits:
        return txns.where((t) => t.type == TransactionType.sell || t.isDebit).toList();
      case ActivityTab.transfers:
        return txns.where((t) => t.type == TransactionType.transfer).toList();
      case ActivityTab.system:
        return txns.where((t) => t.type == TransactionType.fee || t.type == TransactionType.adjustment).toList();
    }
  }

  // ──── LOAD TRANSACTIONS FROM API ────────────────────────────────

  Future<void> loadTransactions({String? entityId, int page = 1, int limit = 20}) async {
    _isTransactionsLoading = true;
    notifyListeners();

    try {
      final response = await _qPointsService.getTransactions(
        page: page,
        limit: limit,
      );

      if (response.success && response.data != null) {
        _transactions = response.data!
            .map((json) => _transactionFromJson(json))
            .toList();
      }
    } catch (e) {
      // Keep existing / fallback data on failure
      _error = 'Failed to load transactions: $e';
    } finally {
      _isTransactionsLoading = false;
      notifyListeners();
    }
  }

  // ──── LOAD BALANCE FROM API ────────────────────────────────

  Future<void> loadBalance({String? entityId}) async {
    _isBalanceLoading = true;
    notifyListeners();

    try {
      if (entityId != null) {
        final response = await _entityService.getEntityById(entityId);
        if (response.success && response.data != null) {
          final data = response.data!;
          final balance = (data['qpBalance'] as num?)?.toDouble();
          if (balance != null) {
            _updateContextBalance(_activeContextId, balance);
          }
        }
      }
    } catch (e) {
      _error = 'Failed to load balance: $e';
    } finally {
      _isBalanceLoading = false;
      notifyListeners();
    }
  }

  void _updateContextBalance(String contextId, double newBalance) {
    final source = _contexts.isNotEmpty ? _contexts : List<FinancialContext>.from(_fallbackContexts);
    _contexts = source.map((c) {
      if (c.id == contextId) {
        return FinancialContext(
          id: c.id,
          name: c.name,
          role: c.role,
          type: c.type,
          permission: c.permission,
          qpBalance: newBalance,
          lastActivity: c.lastActivity,
          activeTabs: c.activeTabs,
          pendingTransactions: c.pendingTransactions,
          unreadAlerts: c.unreadAlerts,
          favoritesCount: c.favoritesCount,
          avatarUrl: c.avatarUrl,
        );
      }
      return c;
    }).toList();
  }

  // ──── API-WIRED FINANCIAL OPERATIONS ────────────────────────────────

  /// Transfer QPoints to another entity/user
  Future<bool> transfer({
    required String toUserId,
    required double amount,
    String? note,
    String deviceFingerprint = 'flutter-app',
    String ipAddress = '0.0.0.0',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _qPointsService.transfer(
        toUserId: toUserId,
        amount: amount,
        description: note ?? 'Transfer',
        deviceFingerprint: deviceFingerprint,
        ipAddress: ipAddress,
      );

      if (response.success) {
        await loadTransactions();
        return true;
      } else {
        _error = response.message ?? 'Transfer failed';
        return false;
      }
    } catch (e) {
      _error = 'Transfer error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Buy (deposit) QPoints
  Future<bool> buy({
    required double amount,
    required String source,
    String deviceFingerprint = 'flutter-app',
    String ipAddress = '0.0.0.0',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _qPointsService.deposit(
        amount: amount,
        description: 'Buy QPoints via $source',
        deviceFingerprint: deviceFingerprint,
        ipAddress: ipAddress,
      );

      if (response.success) {
        await loadTransactions();
        return true;
      } else {
        _error = response.message ?? 'Purchase failed';
        return false;
      }
    } catch (e) {
      _error = 'Purchase error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sell (withdraw) QPoints
  Future<bool> sell({
    required double amount,
    required String destination,
    String deviceFingerprint = 'flutter-app',
    String ipAddress = '0.0.0.0',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _qPointsService.withdraw(
        amount: amount,
        description: 'Sell QPoints to $destination',
        deviceFingerprint: deviceFingerprint,
        ipAddress: ipAddress,
      );

      if (response.success) {
        await loadTransactions();
        return true;
      } else {
        _error = response.message ?? 'Sell failed';
        return false;
      }
    } catch (e) {
      _error = 'Sell error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ──── TRANSACTION JSON PARSER ────────────────────────────────

  static GoTransaction _transactionFromJson(Map<String, dynamic> json) {
    return GoTransaction(
      id: json['id']?.toString() ?? '',
      type: _parseTransactionType(json['type'] as String?),
      status: _parseTransactionStatus(json['status'] as String?),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      feeAmount: (json['feeAmount'] as num?)?.toDouble(),
      netAmount: (json['netAmount'] as num?)?.toDouble(),
      fromEntity: json['fromEntity']?.toString() ?? json['from']?.toString() ?? '',
      toEntity: json['toEntity']?.toString() ?? json['to']?.toString() ?? '',
      gatewayName: json['gatewayName']?.toString() ?? json['gateway']?.toString(),
      fundingSource: json['fundingSource']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString())
          : null,
      reference: json['reference']?.toString(),
      note: json['note']?.toString() ?? json['description']?.toString(),
      category: json['category']?.toString(),
    );
  }

  static TransactionType _parseTransactionType(String? value) {
    switch (value?.toLowerCase()) {
      case 'buy':
      case 'deposit':
        return TransactionType.buy;
      case 'sell':
      case 'withdraw':
        return TransactionType.sell;
      case 'transfer':
        return TransactionType.transfer;
      case 'tabsettlement':
      case 'tab_settlement':
        return TransactionType.tabSettlement;
      case 'batchpayment':
      case 'batch_payment':
        return TransactionType.batchPayment;
      case 'fee':
        return TransactionType.fee;
      case 'adjustment':
        return TransactionType.adjustment;
      default:
        return TransactionType.transfer;
    }
  }

  static TransactionStatus _parseTransactionStatus(String? value) {
    switch (value?.toLowerCase()) {
      case 'completed':
        return TransactionStatus.completed;
      case 'processing':
        return TransactionStatus.processing;
      case 'failed':
        return TransactionStatus.failed;
      case 'pending':
        return TransactionStatus.pending;
      case 'cancelled':
        return TransactionStatus.cancelled;
      case 'disputed':
        return TransactionStatus.disputed;
      case 'reversed':
        return TransactionStatus.reversed;
      case 'draft':
        return TransactionStatus.draft;
      default:
        return TransactionStatus.pending;
    }
  }

  // ──── FINANCIAL HEALTH ────────────────────────────────

  int get healthScore => 78;
  List<HealthMetricData> get healthMetrics => const [
    HealthMetricData(metric: HealthMetric.liquidity, score: 80, label: 'Good liquidity position'),
    HealthMetricData(metric: HealthMetric.debtRatio, score: 80, label: 'Debt well managed'),
    HealthMetricData(metric: HealthMetric.cashFlow, score: 60, label: 'Cash flow could improve'),
    HealthMetricData(metric: HealthMetric.reserveDepth, score: 90, label: 'Strong reserves'),
    HealthMetricData(metric: HealthMetric.gatewayDiversity, score: 40, label: 'Add 2nd gateway'),
  ];

  String get healthRecommendation => 'Add 2nd gateway for redundancy';

  // ──── UPCOMING EVENTS ────────────────────────────────

  static final List<UpcomingEvent> _fallbackUpcomingEvents = [
    UpcomingEvent(id: 'ev-1', title: 'Tab payment due (T-8821)', date: DateTime.now().add(const Duration(days: 1)), amount: 1200, relatedId: 'T-8821', icon: Icons.receipt_long, color: const Color(0xFFEF4444)),
    UpcomingEvent(id: 'ev-2', title: 'Scheduled transfer to Leo', date: DateTime.now().add(const Duration(days: 2)), amount: 500, icon: Icons.swap_horiz, color: const Color(0xFF3B82F6)),
    UpcomingEvent(id: 'ev-3', title: 'Paystack auto-topup', date: DateTime.now().add(const Duration(days: 4)), amount: 10000, icon: Icons.arrow_downward, color: const Color(0xFF10B981)),
    UpcomingEvent(id: 'ev-4', title: 'Monthly financial report', date: DateTime.now().add(const Duration(days: 6)), icon: Icons.assessment, color: const Color(0xFF6B7280)),
  ];

  List<UpcomingEvent> _upcomingEvents = [];

  List<UpcomingEvent> get upcomingEvents =>
      _upcomingEvents.isNotEmpty ? _upcomingEvents : _fallbackUpcomingEvents;

  // ──── FAVORITES ────────────────────────────────

  static final List<FavoriteEntity> _fallbackFavorites = [
    FavoriteEntity(id: 'fav-1', name: 'Leo Mensah', handle: '@leo_driver', role: 'Driver', category: FavoriteCategory.services, rating: 4.8, ratingCount: 124, totalSpent: 6400, avgTransaction: 500, transactionCount: 42, favoriteSince: DateTime(2024, 5, 1), lastInteraction: DateTime.now().subtract(const Duration(days: 1)), isOnline: true, isMutualFavorite: true, trustScore: 92),
    FavoriteEntity(id: 'fav-2', name: 'Sarah\'s Shop', handle: '@sarah_shop', role: 'Vendor', category: FavoriteCategory.businesses, rating: 4.6, ratingCount: 89, totalSpent: 12800, avgTransaction: 1200, transactionCount: 28, favoriteSince: DateTime(2024, 3, 15), lastInteraction: DateTime.now().subtract(const Duration(hours: 8)), isOnline: true, isMutualFavorite: true, trustScore: 88),
    FavoriteEntity(id: 'fav-3', name: 'BrightMart Admin', handle: '@brightmart', role: 'Administrator', category: FavoriteCategory.businesses, rating: 4.9, ratingCount: 45, totalSpent: 25600, avgTransaction: 2100, transactionCount: 15, favoriteSince: DateTime(2024, 1, 10), lastInteraction: DateTime.now().subtract(const Duration(days: 3)), isOnline: false, isMutualFavorite: false, trustScore: 95),
    FavoriteEntity(id: 'fav-4', name: 'David Lee', handle: '@david_tech', role: 'Technician', category: FavoriteCategory.people, rating: 4.3, ratingCount: 56, totalSpent: 3200, avgTransaction: 400, transactionCount: 8, favoriteSince: DateTime(2024, 6, 1), lastInteraction: DateTime.now().subtract(const Duration(days: 5)), isOnline: false, trustScore: 72),
    FavoriteEntity(id: 'fav-5', name: 'Jane Smith', handle: '@jane_admin', role: 'Team Lead', category: FavoriteCategory.internal, rating: 5.0, ratingCount: 12, totalSpent: 1500, avgTransaction: 300, transactionCount: 5, favoriteSince: DateTime(2024, 7, 1), lastInteraction: DateTime.now().subtract(const Duration(hours: 2)), isOnline: true, trustScore: 98),
  ];

  List<FavoriteEntity> _favorites = [];

  List<FavoriteEntity> get favorites =>
      _favorites.isNotEmpty ? _favorites : _fallbackFavorites;

  List<FavoriteEntity> favoritesByCategory(FavoriteCategory? cat) {
    final favs = favorites;
    if (cat == null) return favs;
    return favs.where((f) => f.category == cat).toList();
  }

  FavoriteEntity? getFavoriteById(String id) {
    try { return favorites.firstWhere((f) => f.id == id); } catch (_) { return null; }
  }

  // ──── TABS (CREDIT) ────────────────────────────────

  static final List<GoTab> _fallbackTabs = [
    GoTab(id: 'T-8821', entityName: 'Wizdom Shop', entityRole: 'Owner', description: 'Electronics Supply', status: TabStatus.active, risk: TabRisk.high, creditLimit: 2500, currentBalance: 1200, minimumDue: 600, dueDate: DateTime.now().add(const Duration(days: 1)), createdAt: DateTime(2024, 8, 1), lastActivity: DateTime.now().subtract(const Duration(hours: 4)), onTimePayments: 12, totalPayments: 12, interestRate: 0),
    GoTab(id: 'T-8820', entityName: 'BrightMart', entityRole: 'Administrator', description: 'Office Supplies', status: TabStatus.overdue, risk: TabRisk.critical, creditLimit: 5000, currentBalance: 3800, minimumDue: 1900, dueDate: DateTime.now().subtract(const Duration(days: 3)), createdAt: DateTime(2024, 6, 15), lastActivity: DateTime.now().subtract(const Duration(days: 2)), onTimePayments: 8, totalPayments: 10, interestRate: 2.5),
    GoTab(id: 'T-8819', entityName: 'Leo Mensah', entityRole: 'Driver', description: 'Fuel Advances', status: TabStatus.active, risk: TabRisk.low, creditLimit: 1000, currentBalance: 350, minimumDue: 175, dueDate: DateTime.now().add(const Duration(days: 12)), createdAt: DateTime(2024, 7, 1), lastActivity: DateTime.now().subtract(const Duration(days: 1)), onTimePayments: 6, totalPayments: 6, interestRate: 0),
    GoTab(id: 'T-8818', entityName: 'Sarah\'s Shop', entityRole: 'Vendor', description: 'Product Inventory', status: TabStatus.overdue, risk: TabRisk.medium, creditLimit: 3000, currentBalance: 2100, minimumDue: 1050, dueDate: DateTime.now().subtract(const Duration(days: 1)), createdAt: DateTime(2024, 5, 20), lastActivity: DateTime.now().subtract(const Duration(days: 5)), onTimePayments: 10, totalPayments: 12, interestRate: 1.5),
    GoTab(id: 'T-8817', entityName: 'Mike Johnson', entityRole: 'Contractor', description: 'Services Rendered', status: TabStatus.settled, risk: TabRisk.low, creditLimit: 4000, currentBalance: 0, minimumDue: 0, dueDate: DateTime.now().add(const Duration(days: 30)), createdAt: DateTime(2024, 4, 1), lastActivity: DateTime.now().subtract(const Duration(days: 10)), onTimePayments: 15, totalPayments: 15, interestRate: 0),
    GoTab(id: 'T-8816', entityName: 'Tech Hub', entityRole: 'Supplier', description: 'Hardware Lease', status: TabStatus.active, risk: TabRisk.low, creditLimit: 8000, currentBalance: 2400, minimumDue: 800, dueDate: DateTime.now().add(const Duration(days: 20)), createdAt: DateTime(2024, 3, 1), lastActivity: DateTime.now().subtract(const Duration(days: 7)), onTimePayments: 20, totalPayments: 20, interestRate: 0),
    GoTab(id: 'T-8815', entityName: 'David Lee', entityRole: 'Technician', description: 'Maintenance Contract', status: TabStatus.frozen, risk: TabRisk.medium, creditLimit: 1500, currentBalance: 750, minimumDue: 375, dueDate: DateTime.now().add(const Duration(days: 5)), createdAt: DateTime(2024, 2, 1), lastActivity: DateTime.now().subtract(const Duration(days: 15)), onTimePayments: 4, totalPayments: 6, interestRate: 3.0),
    GoTab(id: 'T-8814', entityName: 'Accra-Mall Branch', entityRole: 'Branch', description: 'Operational Float', status: TabStatus.active, risk: TabRisk.low, creditLimit: 15000, currentBalance: 4500, minimumDue: 1500, dueDate: DateTime.now().add(const Duration(days: 25)), createdAt: DateTime(2024, 1, 15), lastActivity: DateTime.now().subtract(const Duration(days: 3)), onTimePayments: 24, totalPayments: 24, interestRate: 0),
  ];

  List<GoTab> _tabs = [];

  List<GoTab> get tabs => _tabs.isNotEmpty ? _tabs : _fallbackTabs;

  int get activeTabCount => tabs.where((t) => t.status == TabStatus.active).length;
  int get overdueTabCount => tabs.where((t) => t.isOverdue).length;
  double get totalExposure => tabs.where((t) => t.status != TabStatus.settled && t.status != TabStatus.closed).fold(0, (s, t) => s + t.currentBalance);
  double get totalCreditLimit => tabs.where((t) => t.status != TabStatus.settled && t.status != TabStatus.closed).fold(0, (s, t) => s + t.creditLimit);
  double get creditUtilization => totalCreditLimit > 0 ? (totalExposure / totalCreditLimit * 100) : 0;

  GoTab? getTabById(String id) {
    try { return tabs.firstWhere((t) => t.id == id); } catch (_) { return null; }
  }

  List<GoTab> tabsByStatus(TabStatus? status) {
    if (status == null) return tabs;
    return tabs.where((t) => t.status == status).toList();
  }

  // ──── TAB TIMELINE ────────────────────────────────

  List<TabTimelineEvent> getTabTimeline(String tabId) {
    return [
      TabTimelineEvent(id: 'tle-1', description: 'Payment received', timestamp: DateTime.now().subtract(const Duration(hours: 4)), amount: 200, actor: 'System'),
      TabTimelineEvent(id: 'tle-2', description: 'Purchase: Electronics', timestamp: DateTime.now().subtract(const Duration(days: 2)), amount: 1000, actor: 'John Doe'),
      TabTimelineEvent(id: 'tle-3', description: 'Credit limit increased to 2,500 QP', timestamp: DateTime.now().subtract(const Duration(days: 5)), actor: 'Admin', isSystem: true),
      TabTimelineEvent(id: 'tle-4', description: 'Monthly statement generated', timestamp: DateTime.now().subtract(const Duration(days: 10)), isSystem: true),
      TabTimelineEvent(id: 'tle-5', description: 'Payment received', timestamp: DateTime.now().subtract(const Duration(days: 15)), amount: 800, actor: 'BrightMart'),
      TabTimelineEvent(id: 'tle-6', description: 'Tab opened', timestamp: DateTime.now().subtract(const Duration(days: 60)), actor: 'Admin', isSystem: true),
    ];
  }

  // ──── REQUESTS ────────────────────────────────

  static final List<GoRequest> _fallbackRequests = [
    GoRequest(id: 'RQC-78901', type: RequestType.creditLimitChange, status: RequestStatus.underReview, title: 'Increase credit limit: 2,500 → 5,000 QP', description: 'Business expansion requires higher credit.', submittedBy: 'BrightMart Admin', submittedAt: DateTime.now().subtract(const Duration(hours: 3)), relatedTabId: 'T-8821', amount: 5000),
    GoRequest(id: 'RQC-78900', type: RequestType.paymentExtension, status: RequestStatus.submitted, title: 'Extend due date for T-8820', description: 'Cash flow delay from client. Expecting payment next week.', submittedBy: 'BrightMart Admin', submittedAt: DateTime.now().subtract(const Duration(days: 1)), relatedTabId: 'T-8820'),
    GoRequest(id: 'RQC-78899', type: RequestType.newTab, status: RequestStatus.approved, title: 'New tab for Fleet Services', description: 'Monthly fleet maintenance credit line.', submittedBy: 'John Doe', submittedAt: DateTime.now().subtract(const Duration(days: 3)), decidedAt: DateTime.now().subtract(const Duration(days: 2)), decidedBy: 'Admin', amount: 3000),
    GoRequest(id: 'RQC-78898', type: RequestType.disputeFiling, status: RequestStatus.implemented, title: 'Dispute: Service fee overcharge', description: 'Charged 50 QP service fee, should be 25 QP per agreement.', submittedBy: 'Sarah Chen', submittedAt: DateTime.now().subtract(const Duration(days: 7)), decidedAt: DateTime.now().subtract(const Duration(days: 5)), decidedBy: 'Finance Officer', amount: 25, comments: 'Refund processed'),
    GoRequest(id: 'RQC-78897', type: RequestType.tabClosure, status: RequestStatus.rejected, title: 'Close tab T-8815 early', description: 'Requesting early closure due to contract termination.', submittedBy: 'David Lee', submittedAt: DateTime.now().subtract(const Duration(days: 10)), decidedAt: DateTime.now().subtract(const Duration(days: 8)), decidedBy: 'Admin', relatedTabId: 'T-8815', comments: 'Outstanding balance must be settled first'),
  ];

  List<GoRequest> _requests = [];

  List<GoRequest> get requests =>
      _requests.isNotEmpty ? _requests : _fallbackRequests;

  List<GoRequest> get myRequests => requests.where((r) => r.submittedBy == 'John Doe' || r.submittedBy == 'BrightMart Admin').toList();
  List<GoRequest> get pendingApproval => requests.where((r) => r.status == RequestStatus.submitted || r.status == RequestStatus.underReview).toList();

  // ──── BATCH OPERATIONS ────────────────────────────────

  static final List<BatchOperation> _fallbackBatchOps = [
    BatchOperation(id: 'BATCH-001', type: BatchActionType.transfer, itemCount: 5, totalAmount: 4500, status: TransactionStatus.completed, createdAt: DateTime.now().subtract(const Duration(days: 4)), completedItems: 5, failedItems: 0, label: 'Weekly payroll'),
    BatchOperation(id: 'BATCH-002', type: BatchActionType.reminder, itemCount: 8, totalAmount: 0, status: TransactionStatus.completed, createdAt: DateTime.now().subtract(const Duration(days: 7)), completedItems: 8, label: 'Payment reminders'),
    BatchOperation(id: 'BATCH-003', type: BatchActionType.tabSettlement, itemCount: 3, totalAmount: 2800, status: TransactionStatus.processing, createdAt: DateTime.now().subtract(const Duration(hours: 6)), completedItems: 1, failedItems: 0, label: 'Quarterly settlements'),
  ];

  List<BatchOperation> _batchOps = [];

  List<BatchOperation> get batchOperations =>
      _batchOps.isNotEmpty ? _batchOps : _fallbackBatchOps;

  // ──── FINANCIAL PLANNER ────────────────────────────────

  static final List<FinancialGoal> _fallbackGoals = [
    FinancialGoal(id: 'goal-1', title: 'Emergency Fund', type: GoalType.savings, status: GoalStatus.onTrack, targetAmount: 50000, currentAmount: 35000, targetDate: DateTime(2025, 6, 30), createdAt: DateTime(2024, 1, 1), description: 'Build 3-month operational reserve'),
    FinancialGoal(id: 'goal-2', title: 'Fleet Expansion', type: GoalType.investment, status: GoalStatus.atRisk, targetAmount: 100000, currentAmount: 42000, targetDate: DateTime(2025, 3, 31), createdAt: DateTime(2024, 3, 1), description: 'Add 5 new vehicles to fleet'),
    FinancialGoal(id: 'goal-3', title: 'Clear Outstanding Tabs', type: GoalType.debtReduction, status: GoalStatus.behind, targetAmount: 15100, currentAmount: 3500, targetDate: DateTime(2025, 1, 31), createdAt: DateTime(2024, 6, 1)),
    FinancialGoal(id: 'goal-4', title: 'Q4 Revenue Target', type: GoalType.revenue, status: GoalStatus.onTrack, targetAmount: 200000, currentAmount: 158000, targetDate: DateTime(2025, 12, 31), createdAt: DateTime(2024, 1, 1)),
  ];

  List<FinancialGoal> _goals = [];

  List<FinancialGoal> get goals =>
      _goals.isNotEmpty ? _goals : _fallbackGoals;

  static final List<BudgetCategory> _fallbackBudgets = [
    const BudgetCategory(id: 'bud-1', name: 'Operations', allocated: 25000, spent: 18500, icon: Icons.settings, color: Color(0xFF3B82F6)),
    const BudgetCategory(id: 'bud-2', name: 'Payroll', allocated: 15000, spent: 14200, icon: Icons.people, color: Color(0xFF10B981)),
    const BudgetCategory(id: 'bud-3', name: 'Inventory', allocated: 20000, spent: 22100, icon: Icons.inventory_2, color: Color(0xFFEF4444)),
    const BudgetCategory(id: 'bud-4', name: 'Marketing', allocated: 5000, spent: 2800, icon: Icons.campaign, color: Color(0xFFF59E0B)),
    const BudgetCategory(id: 'bud-5', name: 'Maintenance', allocated: 8000, spent: 6100, icon: Icons.build, color: Color(0xFF6366F1)),
  ];

  List<BudgetCategory> _budgets = [];

  List<BudgetCategory> get budgets =>
      _budgets.isNotEmpty ? _budgets : _fallbackBudgets;

  List<CashFlowPoint> get cashFlowForecast => const [
    CashFlowPoint(label: 'Jan', income: 45000, expense: 38000),
    CashFlowPoint(label: 'Feb', income: 42000, expense: 40000),
    CashFlowPoint(label: 'Mar', income: 50000, expense: 42000),
    CashFlowPoint(label: 'Apr', income: 48000, expense: 45000),
    CashFlowPoint(label: 'May', income: 55000, expense: 43000),
    CashFlowPoint(label: 'Jun', income: 52000, expense: 47000),
  ];

  // ──── TAX & COMPLIANCE ────────────────────────────────

  static final List<TaxEntry> _fallbackTaxEntries = [
    TaxEntry(id: 'tax-1', transactionId: 'TX-4623', description: 'QPoints Purchase', category: TaxCategory.expense, amount: 425, date: DateTime.now().subtract(const Duration(hours: 2)), isCategorized: true, taxCode: 'EXP-001'),
    TaxEntry(id: 'tax-2', transactionId: 'TX-4622', description: 'Driver Payment', category: TaxCategory.expense, amount: 1200, date: DateTime.now().subtract(const Duration(hours: 5)), isCategorized: true, taxCode: 'EXP-002'),
    TaxEntry(id: 'tax-3', transactionId: 'TX-4621', description: 'Tab Settlement Received', category: TaxCategory.income, amount: 800, date: DateTime.now().subtract(const Duration(days: 1)), isCategorized: true, taxCode: 'INC-001'),
    TaxEntry(id: 'tax-4', transactionId: 'TX-4617', description: 'Service Fee', category: TaxCategory.fee, amount: 15, date: DateTime.now().subtract(const Duration(days: 3)), isCategorized: false),
    TaxEntry(id: 'tax-5', transactionId: 'TX-4616', description: 'Batch Payroll', category: TaxCategory.expense, amount: 4500, date: DateTime.now().subtract(const Duration(days: 4)), isCategorized: true, taxCode: 'EXP-003'),
  ];

  List<TaxEntry> _taxEntries = [];

  List<TaxEntry> get taxEntries =>
      _taxEntries.isNotEmpty ? _taxEntries : _fallbackTaxEntries;

  int get uncategorizedCount => taxEntries.where((t) => !t.isCategorized).length;

  static final List<ComplianceCheck> _fallbackComplianceChecks = [
    ComplianceCheck(id: 'cc-1', title: 'KYC Verification', description: 'All users verified with government ID', status: ComplianceStatus.compliant, lastChecked: DateTime.now().subtract(const Duration(days: 7))),
    ComplianceCheck(id: 'cc-2', title: 'Transaction Monitoring', description: 'AML screening on all transactions >5,000 QP', status: ComplianceStatus.compliant, lastChecked: DateTime.now().subtract(const Duration(hours: 12))),
    ComplianceCheck(id: 'cc-3', title: 'Tax Reporting', description: 'Quarterly tax reports submission', status: ComplianceStatus.actionRequired, deadline: DateTime.now().add(const Duration(days: 15))),
    ComplianceCheck(id: 'cc-4', title: 'Data Protection', description: 'GDPR/local data protection compliance', status: ComplianceStatus.compliant, lastChecked: DateTime.now().subtract(const Duration(days: 30))),
    ComplianceCheck(id: 'cc-5', title: 'Gateway PCI Compliance', description: 'Payment gateway security certification', status: ComplianceStatus.pending, deadline: DateTime.now().add(const Duration(days: 45))),
  ];

  List<ComplianceCheck> _complianceChecks = [];

  List<ComplianceCheck> get complianceChecks =>
      _complianceChecks.isNotEmpty ? _complianceChecks : _fallbackComplianceChecks;

  // ──── REPORTS ────────────────────────────────

  static final List<GeneratedReport> _fallbackReports = [
    GeneratedReport(id: 'rpt-1', title: 'Q3 2024 Income Statement', type: ReportType.income, format: ReportFormat.pdf, generatedAt: DateTime.now().subtract(const Duration(days: 5)), period: 'Jul-Sep 2024', fileSize: 2.4),
    GeneratedReport(id: 'rpt-2', title: 'Monthly Cash Flow - Aug 2024', type: ReportType.cashFlow, format: ReportFormat.excel, generatedAt: DateTime.now().subtract(const Duration(days: 10)), period: 'Aug 2024', fileSize: 1.8),
    GeneratedReport(id: 'rpt-3', title: 'Aged Debtors Report', type: ReportType.agedDebtors, format: ReportFormat.pdf, generatedAt: DateTime.now().subtract(const Duration(days: 2)), period: 'As of Today', fileSize: 0.9),
    GeneratedReport(id: 'rpt-4', title: 'Weekly Transaction Summary', type: ReportType.custom, format: ReportFormat.csv, generatedAt: DateTime.now().subtract(const Duration(days: 1)), period: 'This Week', fileSize: 0.5, isScheduled: true),
  ];

  List<GeneratedReport> _reports = [];

  List<GeneratedReport> get reports =>
      _reports.isNotEmpty ? _reports : _fallbackReports;

  // ──── SECURITY & AUDIT ────────────────────────────────

  static final List<AuditEntry> _fallbackAuditEntries = [
    AuditEntry(id: 'aud-1', action: 'Transaction initiated: Buy 5,000 QP', actor: 'John Doe', timestamp: DateTime.now().subtract(const Duration(hours: 2)), severity: AuditSeverity.info, ipAddress: '192.168.1.100'),
    AuditEntry(id: 'aud-2', action: 'Credit limit change requested', actor: 'BrightMart Admin', timestamp: DateTime.now().subtract(const Duration(hours: 3)), severity: AuditSeverity.info),
    AuditEntry(id: 'aud-3', action: 'Failed login attempt (3rd)', actor: 'Unknown', timestamp: DateTime.now().subtract(const Duration(hours: 8)), severity: AuditSeverity.warning, ipAddress: '10.0.0.55'),
    AuditEntry(id: 'aud-4', action: 'Large transfer: 10,000 QP', actor: 'John Doe', timestamp: DateTime.now().subtract(const Duration(days: 2)), severity: AuditSeverity.warning, ipAddress: '192.168.1.100', details: 'Amount exceeds daily threshold'),
    AuditEntry(id: 'aud-5', action: 'Gateway credentials updated', actor: 'Admin', timestamp: DateTime.now().subtract(const Duration(days: 3)), severity: AuditSeverity.critical, ipAddress: '192.168.1.1'),
    AuditEntry(id: 'aud-6', action: 'Tab T-8817 settled in full', actor: 'System', timestamp: DateTime.now().subtract(const Duration(days: 10)), severity: AuditSeverity.info),
  ];

  List<AuditEntry> _auditEntries = [];

  List<AuditEntry> get auditEntries =>
      _auditEntries.isNotEmpty ? _auditEntries : _fallbackAuditEntries;

  final Map<String, bool> _securitySettings = {
    'twoFactorAuth': true,
    'biometricLogin': true,
    'ipWhitelist': false,
    'transactionLimits': true,
    'deviceBinding': true,
    'sessionTimeout': true,
    'anomalyAlerts': true,
    'autoBlock': false,
  };

  bool getSecuritySetting(String key) => _securitySettings[key] ?? false;
  void setSecuritySetting(String key, bool v) { _securitySettings[key] = v; notifyListeners(); }

  // ──── INTEGRATIONS ────────────────────────────────

  static final List<GoIntegration> _fallbackIntegrations = [
    GoIntegration(id: 'int-1', name: 'QuickBooks', category: IntegrationCategory.accounting, status: IntegrationStatus.connected, description: 'Auto-sync transactions & invoices', lastSync: DateTime.now().subtract(const Duration(hours: 1)), icon: Icons.receipt_long),
    GoIntegration(id: 'int-2', name: 'Xero', category: IntegrationCategory.accounting, status: IntegrationStatus.disconnected, description: 'Cloud accounting platform', icon: Icons.cloud),
    GoIntegration(id: 'int-3', name: 'GCB Bank API', category: IntegrationCategory.banking, status: IntegrationStatus.connected, description: 'Direct bank transfers & reconciliation', lastSync: DateTime.now().subtract(const Duration(minutes: 30)), icon: Icons.account_balance),
    GoIntegration(id: 'int-4', name: 'Paystack API', category: IntegrationCategory.banking, status: IntegrationStatus.connected, description: 'Payment gateway integration', lastSync: DateTime.now().subtract(const Duration(minutes: 5)), icon: Icons.payment),
    GoIntegration(id: 'int-5', name: 'Salesforce CRM', category: IntegrationCategory.business, status: IntegrationStatus.error, description: 'Customer relationship management', errorCount: 3, icon: Icons.people),
    GoIntegration(id: 'int-6', name: 'Custom Webhook', category: IntegrationCategory.custom, status: IntegrationStatus.configuring, description: 'Custom API endpoint for events', icon: Icons.webhook),
  ];

  List<GoIntegration> _integrations = [];

  List<GoIntegration> get integrations =>
      _integrations.isNotEmpty ? _integrations : _fallbackIntegrations;

  List<GoIntegration> integrationsByCategory(IntegrationCategory cat) => integrations.where((i) => i.category == cat).toList();

  // ──── ARCHIVE ────────────────────────────────

  static final List<ArchivedRecord> _fallbackArchives = [
    ArchivedRecord(id: 'arc-1', title: 'FY 2023 Transactions', type: 'Transactions', archivedAt: DateTime(2024, 1, 15), period: 'Jan-Dec 2023', transactionCount: 1245, totalValue: 856000),
    ArchivedRecord(id: 'arc-2', title: 'Q1-Q2 2024 Tab Settlements', type: 'Settlements', archivedAt: DateTime(2024, 7, 5), period: 'Jan-Jun 2024', transactionCount: 189, totalValue: 124500),
    ArchivedRecord(id: 'arc-3', title: 'FY 2022 Complete Archive', type: 'Full Archive', archivedAt: DateTime(2023, 2, 1), period: 'Jan-Dec 2022', transactionCount: 980, totalValue: 620000, isOnLegalHold: true),
  ];

  List<ArchivedRecord> _archives = [];

  List<ArchivedRecord> get archives =>
      _archives.isNotEmpty ? _archives : _fallbackArchives;

  // ──── RATE ALERTS ────────────────────────────────

  static const List<RateAlert> _fallbackRateAlerts = [
    RateAlert(id: 'ra-1', targetRate: 0.080, channel: RateAlertChannel.push, isActive: true),
    RateAlert(id: 'ra-2', targetRate: 0.075, channel: RateAlertChannel.email, isActive: true),
  ];

  List<RateAlert> _rateAlerts = [];

  List<RateAlert> get rateAlerts =>
      _rateAlerts.isNotEmpty ? _rateAlerts : _fallbackRateAlerts;

  // ──── AI INSIGHTS ────────────────────────────────

  static const List<FinancialInsight> _fallbackInsights = [
    FinancialInsight(id: 'ins-1', text: 'Weekly cash burn: 2,400 QP', icon: Icons.local_fire_department),
    FinancialInsight(id: 'ins-2', text: 'Projected balance in 30d: 18,500 QP', icon: Icons.trending_up),
    FinancialInsight(id: 'ins-3', text: 'Suggestion: Delay large purchases until 15th', icon: Icons.lightbulb, isActionable: true, actionLabel: 'View Schedule'),
    FinancialInsight(id: 'ins-4', text: 'Anomaly: Unusual transfer pattern detected', icon: Icons.warning_amber, isActionable: true, actionLabel: 'Review'),
  ];

  List<FinancialInsight> _insights = [];

  List<FinancialInsight> get insights =>
      _insights.isNotEmpty ? _insights : _fallbackInsights;

  // ──── FUNDING SOURCES ────────────────────────────────

  static const List<FundingSource> _fallbackFundingSources = [
    FundingSource(id: 'fs-1', label: 'Paystack Balance', type: FundingSourceType.gatewayBalance, balance: 8450, isDefault: true),
    FundingSource(id: 'fs-2', label: 'Linked Bank Account', type: FundingSourceType.bankAccount, lastFour: '4582'),
    FundingSource(id: 'fs-3', label: 'Visa Card', type: FundingSourceType.card, lastFour: '9012'),
    FundingSource(id: 'fs-4', label: 'Mobile Money', type: FundingSourceType.mobileMoney, lastFour: '7890'),
  ];

  List<FundingSource> _fundingSources = [];

  List<FundingSource> get fundingSources =>
      _fundingSources.isNotEmpty ? _fundingSources : _fallbackFundingSources;

  // ──── SYNC ────────────────────────────────

  double _syncProgress = 0.72;
  double get syncProgress => _syncProgress;
  void setSyncProgress(double v) { _syncProgress = v; notifyListeners(); }

  String _financialPeriod = 'Q3 2024 • Week 32';
  String get financialPeriod => _financialPeriod;

  // ──── BUY/SELL/TRANSFER STATE ────────────────────────────────

  int _transactionStep = 0;
  int get transactionStep => _transactionStep;
  void setTransactionStep(int step) { _transactionStep = step; notifyListeners(); }

  String? _selectedGatewayId;
  String? get selectedGatewayId => _selectedGatewayId;
  void selectGateway(String id) { _selectedGatewayId = id; notifyListeners(); }

  PaymentGateway? get selectedGateway {
    if (_selectedGatewayId == null) return null;
    try { return gateways.firstWhere((g) => g.id == _selectedGatewayId); } catch (_) { return null; }
  }

  double _transactionAmount = 0;
  double get transactionAmount => _transactionAmount;
  void setTransactionAmount(double v) { _transactionAmount = v; notifyListeners(); }

  String? _selectedFundingSourceId;
  String? get selectedFundingSourceId => _selectedFundingSourceId;
  void selectFundingSource(String id) { _selectedFundingSourceId = id; notifyListeners(); }

  String? _transferReceiverId;
  String? get transferReceiverId => _transferReceiverId;
  void setTransferReceiver(String id) { _transferReceiverId = id; notifyListeners(); }

  TransferSchedule _transferSchedule = TransferSchedule.now;
  TransferSchedule get transferSchedule => _transferSchedule;
  void setTransferSchedule(TransferSchedule s) { _transferSchedule = s; notifyListeners(); }

  void resetTransactionState() {
    _transactionStep = 0;
    _selectedGatewayId = null;
    _transactionAmount = 0;
    _selectedFundingSourceId = null;
    _transferReceiverId = null;
    _transferSchedule = TransferSchedule.now;
    notifyListeners();
  }

  // ──── VERIFICATION STATE ────────────────────────────────

  GoVerificationState _verificationState = GoVerificationState.pending;
  GoVerificationState get verificationState => _verificationState;
  void setVerificationState(GoVerificationState s) { _verificationState = s; notifyListeners(); }

  GoVerificationMethod _verificationMethod = GoVerificationMethod.fingerprint;
  GoVerificationMethod get verificationMethod => _verificationMethod;
  void setVerificationMethod(GoVerificationMethod m) { _verificationMethod = m; notifyListeners(); }

  // ──── TABS FILTER ────────────────────────────────

  TabStatus? _tabFilter;
  TabStatus? get tabFilter => _tabFilter;
  void setTabFilter(TabStatus? status) { _tabFilter = status; notifyListeners(); }

  List<GoTab> get filteredTabs => tabsByStatus(_tabFilter);

  // ──── FAVORITES FILTER ────────────────────────────────

  FavoriteCategory? _favCategory;
  FavoriteCategory? get favCategory => _favCategory;
  void setFavCategory(FavoriteCategory? cat) { _favCategory = cat; notifyListeners(); }

  List<FavoriteEntity> get filteredFavorites => favoritesByCategory(_favCategory);
}
