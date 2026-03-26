/// APRIL Module — State Management
/// Provider with API-first loading + fallback demo data for all 7 screens
/// Module Color: Gold 0xFFFFD700

import 'package:flutter/foundation.dart';
import '../../../core/services/services.dart';
import '../models/april_models.dart';

class AprilProvider extends ChangeNotifier {
  // ──────────────────────────────────────────────
  //  SERVICE INSTANCES
  // ──────────────────────────────────────────────

  final CalendarService _calendarService = CalendarService();
  final WishlistService _wishlistService = WishlistService();
  final PlannerService _plannerService = PlannerService();
  // ignore: unused_field
  final StatementService _statementService = StatementService();
  // ignore: unused_field
  final AIService _aiService = AIService();

  // ──────────────────────────────────────────────
  //  LOADING / ERROR STATE
  // ──────────────────────────────────────────────

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ──────────────────────────────────────────────
  //  INIT
  // ──────────────────────────────────────────────

  Future<void> init() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.wait([
      loadEvents(),
      loadWishlistItems(),
      loadTransactions(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  // ──────────────────────────────────────────────
  //  GLOBAL STATE (local only)
  // ──────────────────────────────────────────────

  String _userName = 'John';
  String get userName => _userName;

  VoiceState _voiceState = VoiceState.idle;
  VoiceState get voiceState => _voiceState;

  DateTime _lastSync = DateTime.now().subtract(const Duration(minutes: 2));
  DateTime get lastSync => _lastSync;

  void setVoiceState(VoiceState state) {
    _voiceState = state;
    notifyListeners();
  }

  void refreshSync() {
    _lastSync = DateTime.now();
    notifyListeners();
  }

  // ──────────────────────────────────────────────
  //  VOICE COMMANDS  (fallback only)
  // ──────────────────────────────────────────────

  static final List<VoiceCommand> _fallbackVoiceHistory = [
    VoiceCommand(
      id: 'vc1',
      text: 'Add meeting with Alex tomorrow at 10 AM',
      type: CommandType.voice,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      successful: true,
      result: 'Meeting added to calendar',
    ),
    VoiceCommand(
      id: 'vc2',
      text: 'Review budget for this month',
      type: CommandType.voice,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      successful: true,
      result: 'Opening Planner overview',
    ),
    VoiceCommand(
      id: 'vc3',
      text: 'Add PlayStation 5 to wishlist',
      type: CommandType.text,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      successful: true,
      result: 'Item added to Personal wishlist',
    ),
    VoiceCommand(
      id: 'vc4',
      text: 'Check upcoming bills',
      type: CommandType.voice,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      successful: true,
      result: '3 bills due this month',
    ),
    VoiceCommand(
      id: 'vc5',
      text: 'Update career goals',
      type: CommandType.voice,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
      successful: false,
      result: 'Could not parse command',
    ),
  ];

  List<VoiceCommand> _voiceHistory = [];
  List<VoiceCommand> get voiceHistory =>
      _voiceHistory.isNotEmpty ? _voiceHistory : _fallbackVoiceHistory;

  void removeVoiceCommand(String id) {
    if (_voiceHistory.isEmpty) {
      _voiceHistory = List.from(_fallbackVoiceHistory);
    }
    _voiceHistory.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // ──────────────────────────────────────────────
  //  NOTIFICATIONS  (fallback only)
  // ──────────────────────────────────────────────

  static final List<AprilNotification> _fallbackNotifications = [
    AprilNotification(
      id: 'n1',
      type: AprilNotificationType.financial,
      title: 'Bill due tomorrow',
      message: 'Electricity: ₵150',
      emoji: '⚠️',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      actions: [NotificationAction.pay, NotificationAction.snooze, NotificationAction.dismiss],
    ),
    AprilNotification(
      id: 'n2',
      type: AprilNotificationType.calendar,
      title: 'Meeting with team in 30 min',
      message: '10:00 AM • Conference Room A',
      emoji: '✅',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      actions: [NotificationAction.join, NotificationAction.snooze, NotificationAction.reschedule],
    ),
    AprilNotification(
      id: 'n3',
      type: AprilNotificationType.financial,
      title: 'Budget alert: Dining exceeds limit',
      message: 'You\'ve spent ₵480 of ₵400 budget',
      emoji: '💰',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      actions: [NotificationAction.viewDetails, NotificationAction.dismiss],
    ),
    AprilNotification(
      id: 'n4',
      type: AprilNotificationType.wishlist,
      title: 'Price drop alert!',
      message: 'PlayStation 5 dropped by 15%',
      emoji: '🎉',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      actions: [NotificationAction.viewDetails, NotificationAction.purchase, NotificationAction.dismiss],
    ),
  ];

  List<AprilNotification> _notifications = [];
  List<AprilNotification> get notifications =>
      _notifications.isNotEmpty ? _notifications : _fallbackNotifications;
  int get unreadNotificationCount => notifications.where((n) => !n.isRead).length;

  void dismissNotification(String id) {
    if (_notifications.isEmpty) {
      _notifications = List.from(_fallbackNotifications);
    }
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void markAllNotificationsRead() {
    notifyListeners();
  }

  // ──────────────────────────────────────────────
  //  PLUGIN STATUS  (fallback only)
  // ──────────────────────────────────────────────

  static final List<PluginStatus> _fallbackPluginStatuses = [
    PluginStatus(
      plugin: AprilPlugin.planner,
      syncStatus: SyncStatus.synced,
      statusText: '₵12,458 balance',
      badgeCount: 3,
      lastSynced: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    PluginStatus(
      plugin: AprilPlugin.calendar,
      syncStatus: SyncStatus.synced,
      statusText: '3 events today',
      badgeCount: 1,
      lastSynced: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    PluginStatus(
      plugin: AprilPlugin.wishlist,
      syncStatus: SyncStatus.pending,
      statusText: '2 high-priority',
      badgeCount: 2,
      lastSynced: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    PluginStatus(
      plugin: AprilPlugin.statement,
      syncStatus: SyncStatus.synced,
      statusText: 'Updated 2d ago',
      lastSynced: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  List<PluginStatus> _pluginStatuses = [];
  List<PluginStatus> get pluginStatuses =>
      _pluginStatuses.isNotEmpty ? _pluginStatuses : _fallbackPluginStatuses;

  // ──────────────────────────────────────────────
  //  PENDING ACTIONS  (fallback only)
  // ──────────────────────────────────────────────

  static final List<PendingAction> _fallbackPendingActions = [
    PendingAction(
      id: 'pa1',
      description: 'Pay electricity bill — ₵150',
      priority: ActionPriority.critical,
      dueText: 'Tomorrow',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      sourcePlugin: AprilPlugin.planner,
    ),
    PendingAction(
      id: 'pa2',
      description: 'Prepare meeting agenda for team sync',
      priority: ActionPriority.high,
      dueText: 'Today',
      dueDate: DateTime.now(),
      sourcePlugin: AprilPlugin.calendar,
    ),
    PendingAction(
      id: 'pa3',
      description: 'Review savings goal progress',
      priority: ActionPriority.medium,
      dueText: 'This week',
      dueDate: DateTime.now().add(const Duration(days: 3)),
      sourcePlugin: AprilPlugin.planner,
    ),
    PendingAction(
      id: 'pa4',
      description: 'Update career section in statement',
      priority: ActionPriority.low,
      dueText: 'Mar 20',
      dueDate: DateTime.now().add(const Duration(days: 7)),
      sourcePlugin: AprilPlugin.statement,
    ),
    const PendingAction(
      id: 'pa5',
      description: 'Check PS5 price at local retailers',
      priority: ActionPriority.low,
      dueText: 'Anytime',
      sourcePlugin: AprilPlugin.wishlist,
    ),
  ];

  List<PendingAction> _pendingActions = [];
  List<PendingAction> get pendingActions =>
      _pendingActions.isNotEmpty ? _pendingActions : _fallbackPendingActions;
  int get pendingActionCount => pendingActions.where((a) => a.status == ActionStatus.pending).length;

  void completeAction(String id) {
    if (_pendingActions.isEmpty) {
      _pendingActions = List.from(_fallbackPendingActions);
    }
    _pendingActions.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  // ──────────────────────────────────────────────
  //  PLANNER — FINANCIAL DATA  (API-wired)
  // ──────────────────────────────────────────────

  PlannerTab _plannerTab = PlannerTab.overview;
  PlannerTab get plannerTab => _plannerTab;
  void setPlannerTab(PlannerTab tab) {
    _plannerTab = tab;
    notifyListeners();
  }

  // --- Monthly summary (fallback only) ---

  static const MonthlySummary _fallbackMonthlySummary = MonthlySummary(
    totalBalance: 12458.75,
    balanceChange: 12.0,
    income: 8500.00,
    incomeChange: 15.0,
    expenses: 6200.00,
    expenseChange: 8.0,
    savings: 2300.00,
    savingsChange: 42.0,
  );

  MonthlySummary get monthlySummary => _fallbackMonthlySummary;

  // --- Upcoming bills (fallback only) ---

  static final List<UpcomingBill> _fallbackUpcomingBills = [
    UpcomingBill(
      id: 'b1', name: 'Electricity', amount: 150.0,
      dueDate: DateTime.now().add(const Duration(days: 1)),
      category: TransactionCategory.utilities,
    ),
    UpcomingBill(
      id: 'b2', name: 'Internet', amount: 89.0,
      dueDate: DateTime.now().add(const Duration(days: 7)),
      category: TransactionCategory.utilities,
    ),
    UpcomingBill(
      id: 'b3', name: 'Mortgage', amount: 2400.0,
      dueDate: DateTime.now().add(const Duration(days: 12)),
      category: TransactionCategory.housing,
    ),
  ];

  List<UpcomingBill> get upcomingBills => _fallbackUpcomingBills;

  // --- Transactions (API-wired) ---

  static final List<Transaction> _fallbackTransactions = [
    Transaction(
      id: 't1', title: 'Uber Eats', amount: 45.80,
      type: TransactionType.expense, category: TransactionCategory.dining,
      date: DateTime.now().subtract(const Duration(hours: 5)),
      tags: ['dining', 'personal'],
    ),
    Transaction(
      id: 't2', title: 'Monthly Salary', amount: 8500.00,
      type: TransactionType.income, category: TransactionCategory.salary,
      date: DateTime.now().subtract(const Duration(days: 3)),
      tags: ['salary', 'work'], isRecurring: true,
      recurringFrequency: RecurringFrequency.monthly,
    ),
    Transaction(
      id: 't3', title: 'Grocery Store', amount: 125.40,
      type: TransactionType.expense, category: TransactionCategory.groceries,
      date: DateTime.now().subtract(const Duration(days: 1)),
      tags: ['groceries'], hasReceipt: true,
    ),
    Transaction(
      id: 't4', title: 'Netflix', amount: 15.99,
      type: TransactionType.expense, category: TransactionCategory.subscription,
      date: DateTime.now().subtract(const Duration(days: 5)),
      isRecurring: true, recurringFrequency: RecurringFrequency.monthly,
    ),
    Transaction(
      id: 't5', title: 'Freelance Project', amount: 1200.00,
      type: TransactionType.income, category: TransactionCategory.freelance,
      date: DateTime.now().subtract(const Duration(days: 7)),
      tags: ['freelance', 'design'],
    ),
    Transaction(
      id: 't6', title: 'Gas Station', amount: 65.00,
      type: TransactionType.expense, category: TransactionCategory.transport,
      date: DateTime.now().subtract(const Duration(days: 2)),
      tags: ['transport'],
    ),
    Transaction(
      id: 't7', title: 'Gym Membership', amount: 50.00,
      type: TransactionType.expense, category: TransactionCategory.healthcare,
      date: DateTime.now().subtract(const Duration(days: 10)),
      isRecurring: true, recurringFrequency: RecurringFrequency.monthly,
    ),
  ];

  List<Transaction> _transactions = [];
  List<Transaction> get transactions =>
      _transactions.isNotEmpty ? _transactions : _fallbackTransactions;

  Future<void> loadTransactions() async {
    try {
      final response = await _plannerService.getTransactions();
      if (response.success && response.data != null) {
        _transactions = response.data!.map(_parseTransaction).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('loadTransactions fallback: $e');
      // keep _transactions empty → getter returns _fallbackTransactions
    }
  }

  Future<void> addTransaction({
    required String type,
    required double amount,
    required String category,
    String? description,
  }) async {
    try {
      final response = await _plannerService.addTransaction(
        type: type,
        amount: amount,
        category: category,
        description: description,
      );
      if (response.success) {
        await loadTransactions();
      }
    } catch (e) {
      debugPrint('addTransaction error: $e');
    }
  }

  Future<void> updateTransaction(String id, Map<String, dynamic> data) async {
    try {
      final response = await _plannerService.updateTransaction(id, data);
      if (response.success) {
        await loadTransactions();
      }
    } catch (e) {
      debugPrint('updateTransaction error: $e');
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      final response = await _plannerService.deleteTransaction(id);
      if (response.success) {
        await loadTransactions();
      }
    } catch (e) {
      debugPrint('deleteTransaction error: $e');
    }
  }

  String _transactionSearch = '';
  void setTransactionSearch(String s) {
    _transactionSearch = s;
    notifyListeners();
  }

  TransactionCategory? _transactionCategoryFilter;
  TransactionCategory? get transactionCategoryFilter => _transactionCategoryFilter;

  /// Alias used by planner screen category filter chips
  TransactionCategory? get categoryFilter => _transactionCategoryFilter;
  void setCategoryFilter(TransactionCategory? c) => setTransactionCategoryFilter(c);

  void setTransactionCategoryFilter(TransactionCategory? c) {
    _transactionCategoryFilter = c;
    notifyListeners();
  }

  List<Transaction> get filteredTransactions {
    var list = transactions;
    if (_transactionSearch.isNotEmpty) {
      list = list.where((t) => t.title.toLowerCase().contains(_transactionSearch.toLowerCase())).toList();
    }
    if (_transactionCategoryFilter != null) {
      list = list.where((t) => t.category == _transactionCategoryFilter).toList();
    }
    return list;
  }

  // --- Budget categories (fallback only) ---

  static const List<BudgetCategory> _fallbackBudgetCategories = [
    BudgetCategory(id: 'bg1', name: 'Dining', category: TransactionCategory.dining, limit: 400, spent: 480, status: BudgetStatus.overBudget),
    BudgetCategory(id: 'bg2', name: 'Transport', category: TransactionCategory.transport, limit: 300, spent: 210, status: BudgetStatus.onTrack),
    BudgetCategory(id: 'bg3', name: 'Groceries', category: TransactionCategory.groceries, limit: 500, spent: 380, status: BudgetStatus.warning),
    BudgetCategory(id: 'bg4', name: 'Entertainment', category: TransactionCategory.entertainment, limit: 200, spent: 95, status: BudgetStatus.onTrack),
    BudgetCategory(id: 'bg5', name: 'Utilities', category: TransactionCategory.utilities, limit: 350, spent: 240, status: BudgetStatus.onTrack),
    BudgetCategory(id: 'bg6', name: 'Shopping', category: TransactionCategory.shopping, limit: 250, spent: 175, status: BudgetStatus.warning),
  ];

  List<BudgetCategory> get budgetCategories => _fallbackBudgetCategories;

  // --- Spending trend (fallback only) ---

  static const List<SpendingDataPoint> _fallbackSpendingTrend = [
    SpendingDataPoint(label: 'Jan', amount: 5200),
    SpendingDataPoint(label: 'Feb', amount: 5800),
    SpendingDataPoint(label: 'Mar', amount: 6200),
    SpendingDataPoint(label: 'Apr', amount: 4900),
    SpendingDataPoint(label: 'May', amount: 5500),
    SpendingDataPoint(label: 'Jun', amount: 6100),
  ];

  List<SpendingDataPoint> get spendingTrend => _fallbackSpendingTrend;

  /// Alias used by analytics tab
  List<SpendingDataPoint> get spendingData => spendingTrend;

  // --- Financial health (fallback only) ---

  static const FinancialHealth _fallbackFinancialHealth = FinancialHealth(
    score: 78,
    grade: 'B+',
    summary: 'Good financial health with room for improvement in dining budget',
    recommendations: [
      'Reduce dining expenses by 20%',
      'Increase emergency fund contributions',
      'Consider consolidating subscriptions',
    ],
  );

  FinancialHealth get financialHealth => _fallbackFinancialHealth;

  // ──────────────────────────────────────────────
  //  CALENDAR DATA  (API-wired)
  // ──────────────────────────────────────────────

  CalendarView _calendarView = CalendarView.day;
  CalendarView get calendarView => _calendarView;
  void setCalendarView(CalendarView view) {
    _calendarView = view;
    notifyListeners();
  }

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  static final List<CalendarEvent> _fallbackEvents = [
    CalendarEvent(
      id: 'e1', title: 'Team Standup', type: EventType.meeting,
      startTime: DateTime.now().copyWith(hour: 8, minute: 0),
      endTime: DateTime.now().copyWith(hour: 8, minute: 30),
      location: 'Meeting Room A', calendarName: 'Work', colorIndex: 0,
      guests: ['alex@company.com', 'sarah@company.com'],
    ),
    CalendarEvent(
      id: 'e2', title: 'Client Call', type: EventType.call,
      startTime: DateTime.now().copyWith(hour: 9, minute: 30),
      endTime: DateTime.now().copyWith(hour: 10, minute: 30),
      location: 'Zoom', calendarName: 'Work', colorIndex: 1,
      guests: ['alex.johnson@client.com'],
      description: 'Quarterly review discussion',
    ),
    CalendarEvent(
      id: 'e3', title: 'Lunch with Sarah', type: EventType.personal,
      startTime: DateTime.now().copyWith(hour: 12, minute: 0),
      endTime: DateTime.now().copyWith(hour: 13, minute: 0),
      location: 'Café Azure', calendarName: 'Personal', colorIndex: 2,
    ),
    CalendarEvent(
      id: 'e4', title: 'Project Deadline', type: EventType.deadline,
      startTime: DateTime.now().copyWith(hour: 17, minute: 0),
      endTime: DateTime.now().copyWith(hour: 17, minute: 0),
      calendarName: 'Work', colorIndex: 3,
      description: 'Submit final design mockups',
    ),
    CalendarEvent(
      id: 'e5', title: 'Gym Session', type: EventType.personal,
      startTime: DateTime.now().copyWith(hour: 18, minute: 0),
      endTime: DateTime.now().copyWith(hour: 19, minute: 0),
      location: 'FitPro Gym', calendarName: 'Personal', colorIndex: 4,
    ),
    CalendarEvent(
      id: 'e6', title: 'Board Meeting', type: EventType.meeting,
      startTime: DateTime.now().add(const Duration(days: 1)).copyWith(hour: 10, minute: 0),
      endTime: DateTime.now().add(const Duration(days: 1)).copyWith(hour: 12, minute: 0),
      location: 'Conference Room B', calendarName: 'Work', colorIndex: 0,
      guests: ['ceo@company.com', 'cfo@company.com'],
    ),
  ];

  List<CalendarEvent> _events = [];
  List<CalendarEvent> get events =>
      _events.isNotEmpty ? _events : _fallbackEvents;

  Future<void> loadEvents() async {
    try {
      final response = await _calendarService.getEvents();
      if (response.success && response.data != null) {
        _events = response.data!.map(_parseCalendarEvent).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('loadEvents fallback: $e');
      // keep _events empty → getter returns _fallbackEvents
    }
  }

  Future<void> createEvent({
    required String title,
    required String startTime,
    required String endTime,
    String? description,
    String? recurrence,
  }) async {
    try {
      final response = await _calendarService.createEvent(
        title: title,
        startTime: startTime,
        endTime: endTime,
        description: description,
        recurrence: recurrence,
      );
      if (response.success) {
        await loadEvents();
      }
    } catch (e) {
      debugPrint('createEvent error: $e');
    }
  }

  Future<void> updateEvent(String id, Map<String, dynamic> data) async {
    try {
      final response = await _calendarService.updateEvent(id, data);
      if (response.success) {
        await loadEvents();
      }
    } catch (e) {
      debugPrint('updateEvent error: $e');
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      final response = await _calendarService.deleteEvent(id);
      if (response.success) {
        await loadEvents();
      }
    } catch (e) {
      debugPrint('deleteEvent error: $e');
    }
  }

  List<CalendarEvent> eventsForDate(DateTime date) {
    return events.where((e) =>
      e.startTime.year == date.year &&
      e.startTime.month == date.month &&
      e.startTime.day == date.day
    ).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<CalendarEvent> get todayEvents => eventsForDate(DateTime.now());
  int get todayEventCount => todayEvents.length;

  // ──────────────────────────────────────────────
  //  WISHLIST DATA  (API-wired)
  // ──────────────────────────────────────────────

  WishlistViewMode _wishlistView = WishlistViewMode.grid;
  WishlistViewMode get wishlistView => _wishlistView;
  void setWishlistView(WishlistViewMode mode) {
    _wishlistView = mode;
    notifyListeners();
  }

  String _wishlistSearch = '';
  void setWishlistSearch(String s) {
    _wishlistSearch = s;
    notifyListeners();
  }

  WishlistPriority? _wishlistPriorityFilter;
  WishlistPriority? get wishlistPriorityFilter => _wishlistPriorityFilter;
  void setWishlistPriorityFilter(WishlistPriority? p) {
    _wishlistPriorityFilter = p;
    notifyListeners();
  }

  static final List<WishlistItem> _fallbackWishlistItems = [
    WishlistItem(
      id: 'w1', name: 'PlayStation 5 Console', priority: WishlistPriority.critical,
      price: 3499.99, savedAmount: 1200, category: 'Electronics',
      tags: ['gaming', 'birthday', 'console'], availability: ItemAvailability.inStock,
      desiredBy: DateTime.now().add(const Duration(days: 120)),
      notes: 'Want the digital edition', addedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    WishlistItem(
      id: 'w2', name: 'MacBook Pro 14"', priority: WishlistPriority.veryHigh,
      price: 8999.00, savedAmount: 3500, category: 'Electronics',
      tags: ['work', 'productivity'], availability: ItemAvailability.inStock,
      addedAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    WishlistItem(
      id: 'w3', name: 'Noise Cancelling Headphones', priority: WishlistPriority.high,
      price: 1299.99, savedAmount: 800, category: 'Electronics',
      tags: ['audio', 'work'], availability: ItemAvailability.inStock,
      addedAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    WishlistItem(
      id: 'w4', name: 'Standing Desk', priority: WishlistPriority.medium,
      price: 2500.00, savedAmount: 0, category: 'Furniture',
      tags: ['office', 'health'], availability: ItemAvailability.preOrder,
      desiredBy: DateTime.now().add(const Duration(days: 60)),
      addedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    WishlistItem(
      id: 'w5', name: 'Camping Tent', priority: WishlistPriority.low,
      price: 450.00, savedAmount: 200, category: 'Outdoors',
      tags: ['travel', 'adventure'], availability: ItemAvailability.inStock,
      addedAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    WishlistItem(
      id: 'w6', name: 'Cooking Masterclass Course', priority: WishlistPriority.medium,
      price: 199.99, savedAmount: 199.99, category: 'Education',
      tags: ['cooking', 'learning'], availability: ItemAvailability.inStock,
      isPurchased: true,
      addedAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
  ];

  List<WishlistItem> _wishlistItems = [];
  List<WishlistItem> get wishlistItems =>
      _wishlistItems.isNotEmpty ? _wishlistItems : _fallbackWishlistItems;

  Future<void> loadWishlistItems() async {
    try {
      final response = await _wishlistService.getWishlist();
      if (response.success && response.data != null) {
        _wishlistItems = response.data!.map(_parseWishlistItem).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('loadWishlistItems fallback: $e');
      // keep _wishlistItems empty → getter returns _fallbackWishlistItems
    }
  }

  Future<void> addWishlistItem({
    required String name,
    required double estimatedPrice,
    required String priority,
    required String category,
    String? notes,
  }) async {
    try {
      final response = await _wishlistService.addItem(
        name: name,
        estimatedPrice: estimatedPrice,
        priority: priority,
        category: category,
        notes: notes,
      );
      if (response.success) {
        await loadWishlistItems();
      }
    } catch (e) {
      debugPrint('addWishlistItem error: $e');
    }
  }

  Future<void> updateWishlistItem(String id, Map<String, dynamic> data) async {
    try {
      final response = await _wishlistService.updateItem(id, data);
      if (response.success) {
        await loadWishlistItems();
      }
    } catch (e) {
      debugPrint('updateWishlistItem error: $e');
    }
  }

  Future<void> deleteWishlistItem(String id) async {
    try {
      final response = await _wishlistService.deleteItem(id);
      if (response.success) {
        await loadWishlistItems();
      }
    } catch (e) {
      debugPrint('deleteWishlistItem error: $e');
    }
  }

  List<WishlistItem> get filteredWishlistItems {
    var list = wishlistItems.where((i) => !i.isPurchased).toList();
    if (_wishlistSearch.isNotEmpty) {
      list = list.where((i) => i.name.toLowerCase().contains(_wishlistSearch.toLowerCase())).toList();
    }
    if (_wishlistPriorityFilter != null) {
      list = list.where((i) => i.priority == _wishlistPriorityFilter).toList();
    }
    return list;
  }

  int get highPriorityWishlistCount =>
      wishlistItems.where((i) => !i.isPurchased && (i.priority == WishlistPriority.critical || i.priority == WishlistPriority.veryHigh)).length;

  double get totalWishlistValue => wishlistItems.where((i) => !i.isPurchased).fold(0.0, (sum, i) => sum + i.price);
  double get totalWishlistSaved => wishlistItems.where((i) => !i.isPurchased).fold(0.0, (sum, i) => sum + i.savedAmount);

  static const List<WishlistCollection> _fallbackWishlistCollections = [
    WishlistCollection(id: 'wc1', name: 'Personal', emoji: '🎁', itemCount: 4, totalValue: 8249.98),
    WishlistCollection(id: 'wc2', name: 'Birthday Ideas', emoji: '🎂', itemCount: 2, totalValue: 3949.99, isShared: true),
    WishlistCollection(id: 'wc3', name: 'Home Office', emoji: '🏠', itemCount: 3, totalValue: 4800.00),
  ];

  List<WishlistCollection> get wishlistCollections => _fallbackWishlistCollections;

  // ──────────────────────────────────────────────
  //  PERSONAL STATEMENT DATA  (fallback only)
  // ──────────────────────────────────────────────

  static final List<StatementCardData> _fallbackStatementCards = [
    StatementCardData(
      type: StatementCard.lifestyle, title: 'Lifestyle & Values', emoji: '🌟',
      summary: 'Core values, daily routines, and life philosophy',
      completionPercent: 85, lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
      highlights: ['Integrity', 'Family first', 'Continuous learning'],
    ),
    StatementCardData(
      type: StatementCard.family, title: 'Family & Relationships', emoji: '👨‍👩‍👧‍👦',
      summary: 'Family connections, important dates, and relationship goals',
      completionPercent: 70, lastUpdated: DateTime.now().subtract(const Duration(days: 10)),
      highlights: ['Wife: Sarah', 'Son: James (8)', 'Anniversary: Jun 15'],
    ),
    StatementCardData(
      type: StatementCard.career, title: 'Career & Education', emoji: '💼',
      summary: 'Professional journey, skills, and career goals',
      completionPercent: 90, lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
      highlights: ['Product Manager', '10+ years experience', 'MBA, Stanford'],
    ),
    StatementCardData(
      type: StatementCard.financial, title: 'Financial Statement', emoji: '💰',
      summary: 'Net worth, goals, and investment philosophy',
      completionPercent: 65, lastUpdated: DateTime.now().subtract(const Duration(days: 15)),
      highlights: ['Retirement goal: 55', 'House fund: 40%', 'Emergency fund: 6mo'],
    ),
    StatementCardData(
      type: StatementCard.health, title: 'Health & Wellness', emoji: '💚',
      summary: 'Medical profile, fitness goals, and wellness tracking',
      completionPercent: 55, lastUpdated: DateTime.now().subtract(const Duration(days: 20)),
      highlights: ['No allergies', 'Target: 10k steps/day', 'Mediterranean diet'],
    ),
    StatementCardData(
      type: StatementCard.legal, title: 'Legal & Administrative', emoji: '📜',
      summary: 'Important documents, digital assets, and privacy preferences',
      completionPercent: 40, lastUpdated: DateTime.now().subtract(const Duration(days: 30)),
      isLocked: true,
      highlights: ['Passport: Valid until 2028', 'Will: Draft'],
    ),
    StatementCardData(
      type: StatementCard.growth, title: 'Personal Growth', emoji: '🌱',
      summary: 'Bucket list, personal projects, and reflection journal',
      completionPercent: 75, lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
      highlights: ['Reading: 24/50 books', 'Learn Spanish', 'Run marathon'],
    ),
  ];

  List<StatementCardData> get statementCards => _fallbackStatementCards;

  int get overallCompletionPercent {
    final cards = statementCards;
    if (cards.isEmpty) return 0;
    return (cards.fold<int>(0, (sum, c) => sum + c.completionPercent) / cards.length).round();
  }

  static final List<StatementVersion> _fallbackStatementVersions = [
    StatementVersion(id: 'sv1', versionNumber: 12, createdAt: DateTime.now().subtract(const Duration(days: 2)), changeComment: 'Updated career goals for Q2'),
    StatementVersion(id: 'sv2', versionNumber: 11, createdAt: DateTime.now().subtract(const Duration(days: 10)), changeComment: 'Added family medical history'),
    StatementVersion(id: 'sv3', versionNumber: 10, createdAt: DateTime.now().subtract(const Duration(days: 20)), changeComment: 'Updated financial projections'),
  ];

  List<StatementVersion> get statementVersions => _fallbackStatementVersions;

  // ──────────────────────────────────────────────
  //  SETTINGS DATA  (local only)
  // ──────────────────────────────────────────────

  final Map<String, bool> _settingsToggles = {
    'auto_backup': true,
    'biometric_lock': true,
    'wake_word': false,
    'voice_data_retention': false,
    'planner_enabled': true,
    'calendar_enabled': true,
    'wishlist_enabled': true,
    'statement_enabled': true,
    'push_notifications': true,
    'email_notifications': false,
    'quiet_hours': true,
    'emergency_override': true,
    'two_factor_auth': true,
    'auto_lock': true,
    'data_encryption': true,
  };

  Map<String, bool> get settingsToggles => _settingsToggles;

  bool getSettingToggle(String key) => _settingsToggles[key] ?? false;

  void setSettingToggle(String key, bool value) {
    _settingsToggles[key] = value;
    notifyListeners();
  }

  int _themeIndex = 0; // 0=light, 1=dark, 2=auto, 3=custom
  int get themeIndex => _themeIndex;
  void setThemeIndex(int i) { _themeIndex = i; notifyListeners(); }

  int _autoLockMinutes = 5;
  int get autoLockMinutes => _autoLockMinutes;
  void setAutoLockMinutes(int m) { _autoLockMinutes = m; notifyListeners(); }

  String _backupFrequency = 'Daily';
  String get backupFrequency => _backupFrequency;
  void setBackupFrequency(String f) { _backupFrequency = f; notifyListeners(); }

  // ──────────────────────────────────────────────
  //  JSON PARSE HELPERS
  // ──────────────────────────────────────────────

  static CalendarEvent _parseCalendarEvent(Map<String, dynamic> json) {
    final eventTypeMap = <String, EventType>{
      'meeting': EventType.meeting,
      'call': EventType.call,
      'personal': EventType.personal,
      'travel': EventType.travel,
      'deadline': EventType.deadline,
      'reminder': EventType.reminder,
      'allDay': EventType.allDay,
    };

    return CalendarEvent(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      type: eventTypeMap[json['type']?.toString()] ?? EventType.personal,
      startTime: DateTime.tryParse(json['startTime']?.toString() ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(json['endTime']?.toString() ?? '') ?? DateTime.now(),
      location: json['location']?.toString(),
      calendarName: json['calendarName']?.toString() ?? 'Personal',
      colorIndex: (json['colorIndex'] as num?)?.toInt() ?? 0,
      guests: (json['guests'] as List<dynamic>?)?.map((g) => g.toString()).toList() ?? [],
      description: json['description']?.toString(),
    );
  }

  static Transaction _parseTransaction(Map<String, dynamic> json) {
    final typeMap = <String, TransactionType>{
      'income': TransactionType.income,
      'expense': TransactionType.expense,
    };

    final categoryMap = <String, TransactionCategory>{
      'dining': TransactionCategory.dining,
      'groceries': TransactionCategory.groceries,
      'transport': TransactionCategory.transport,
      'entertainment': TransactionCategory.entertainment,
      'utilities': TransactionCategory.utilities,
      'housing': TransactionCategory.housing,
      'healthcare': TransactionCategory.healthcare,
      'education': TransactionCategory.education,
      'shopping': TransactionCategory.shopping,
      'salary': TransactionCategory.salary,
      'freelance': TransactionCategory.freelance,
      'investment': TransactionCategory.investment,
      'subscription': TransactionCategory.subscription,
      'insurance': TransactionCategory.insurance,
      'other': TransactionCategory.other,
    };

    final recurringMap = <String, RecurringFrequency>{
      'daily': RecurringFrequency.daily,
      'weekly': RecurringFrequency.weekly,
      'biWeekly': RecurringFrequency.biWeekly,
      'monthly': RecurringFrequency.monthly,
      'yearly': RecurringFrequency.yearly,
      'custom': RecurringFrequency.custom,
    };

    return Transaction(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['description']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: typeMap[json['type']?.toString()] ?? TransactionType.expense,
      category: categoryMap[json['category']?.toString()] ?? TransactionCategory.other,
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      tags: (json['tags'] as List<dynamic>?)?.map((t) => t.toString()).toList() ?? [],
      isRecurring: json['isRecurring'] == true,
      recurringFrequency: recurringMap[json['recurringFrequency']?.toString()],
      hasReceipt: json['hasReceipt'] == true,
    );
  }

  static WishlistItem _parseWishlistItem(Map<String, dynamic> json) {
    final priorityMap = <String, WishlistPriority>{
      'low': WishlistPriority.low,
      'medium': WishlistPriority.medium,
      'high': WishlistPriority.high,
      'veryHigh': WishlistPriority.veryHigh,
      'critical': WishlistPriority.critical,
    };

    final availabilityMap = <String, ItemAvailability>{
      'inStock': ItemAvailability.inStock,
      'outOfStock': ItemAvailability.outOfStock,
      'preOrder': ItemAvailability.preOrder,
      'discontinued': ItemAvailability.discontinued,
      'unknown': ItemAvailability.unknown,
    };

    return WishlistItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      priority: priorityMap[json['priority']?.toString()] ?? WishlistPriority.medium,
      price: (json['estimatedPrice'] as num?)?.toDouble() ?? (json['price'] as num?)?.toDouble() ?? 0.0,
      savedAmount: (json['savedAmount'] as num?)?.toDouble() ?? 0.0,
      category: json['category']?.toString() ?? 'Other',
      tags: (json['tags'] as List<dynamic>?)?.map((t) => t.toString()).toList() ?? [],
      availability: availabilityMap[json['availability']?.toString()] ?? ItemAvailability.unknown,
      desiredBy: json['desiredBy'] != null ? DateTime.tryParse(json['desiredBy'].toString()) : null,
      notes: json['notes']?.toString(),
      addedAt: DateTime.tryParse(json['addedAt']?.toString() ?? json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      isPurchased: json['isPurchased'] == true || json['status'] == 'purchased',
    );
  }
}
