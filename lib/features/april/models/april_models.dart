/// APRIL Module  Data Models
/// Personal Assistant & Command Core: ActionCore, Planner, Calendar, Wishlist, Statement
/// Module Color: Gold 0xFFFFD700
library;

// 
//  ENUMS
// 

enum AprilWidgetState { loading, loaded, error, empty }

/// Voice assistant states
enum VoiceState { idle, listening, processing, success, error }

/// Notification types across all plugins
enum AprilNotificationType { financial, calendar, wishlist, personal, system }

/// Notification actions
enum NotificationAction { pay, snooze, dismiss, viewDetails, join, reschedule, decline, purchase, remove }

/// Plugin identifiers
enum AprilPlugin { planner, calendar, wishlist, statement }

/// Plugin sync status
enum SyncStatus { synced, pending, error, offline }

/// Planner tabs
enum PlannerTab { overview, transactions, budgets, analytics }

/// Transaction category
enum TransactionCategory {
  dining, groceries, transport, entertainment, utilities,
  housing, healthcare, education, shopping, salary,
  freelance, investment, subscription, insurance, other,
}

/// Transaction type
enum TransactionType { income, expense }

/// Recurring frequency
enum RecurringFrequency { daily, weekly, biWeekly, monthly, yearly, custom }

/// Budget status
enum BudgetStatus { onTrack, warning, overBudget, completed }

/// Calendar view mode
enum CalendarView { day, week, month, agenda, year }

/// Event type
enum EventType { meeting, call, personal, travel, deadline, reminder, allDay }

/// Event status
enum EventStatus { confirmed, tentative, cancelled }

/// Availability marking
enum Availability { busy, free, tentative, outOfOffice }

/// Wishlist view mode
enum WishlistViewMode { grid, list, priority, timeline }

/// Wishlist item priority (1-5 stars)
enum WishlistPriority { low, medium, high, veryHigh, critical }

/// Item availability
enum ItemAvailability { inStock, outOfStock, preOrder, discontinued, unknown }

/// Personal statement card types
enum StatementCard {
  lifestyle, family, career, financial,
  health, legal, growth,
}

/// Statement sharing permission
enum SharePermission { view, comment, edit }

/// APRIL settings sections
enum SettingsSection {
  general, voice, plugins, notifications,
  privacy, advanced, help,
}

/// Command type for voice/text
enum CommandType { voice, text }

/// Task priority for actions
enum ActionPriority { critical, high, medium, low }

/// Action status
enum ActionStatus { pending, inProgress, completed, overdue, cancelled }

// 
//  DATA MODELS
// 

/// Voice command entry
class VoiceCommand {
  final String id;
  final String text;
  final CommandType type;
  final DateTime timestamp;
  final bool successful;
  final String? result;

  const VoiceCommand({
    required this.id,
    required this.text,
    required this.type,
    required this.timestamp,
    required this.successful,
    this.result,
  });

  factory VoiceCommand.fromJson(Map<String, dynamic> json) => VoiceCommand(
        id: json['id'] as String? ?? '',
        text: json['text'] as String? ?? '',
        type: CommandType.values.firstWhere(
          (e) => e.name == (json['type'] as String? ?? ''),
          orElse: () => CommandType.text,
        ),
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
        successful: json['successful'] as bool? ?? false,
        result: json['result'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'type': type.name,
        'timestamp': timestamp.toIso8601String(),
        'successful': successful,
        'result': result,
      };
}

/// Notification item
class AprilNotification {
  final String id;
  final AprilNotificationType type;
  final String title;
  final String message;
  final String? emoji;
  final DateTime timestamp;
  final bool isRead;
  final List<NotificationAction> actions;
  final String? actionRoute;

  const AprilNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.emoji,
    required this.timestamp,
    this.isRead = false,
    this.actions = const [],
    this.actionRoute,
  });

  factory AprilNotification.fromJson(Map<String, dynamic> json) => AprilNotification(
        id: json['id'] as String? ?? '',
        type: AprilNotificationType.values.firstWhere(
          (e) => e.name == (json['type'] as String? ?? ''),
          orElse: () => AprilNotificationType.system,
        ),
        title: json['title'] as String? ?? '',
        message: json['message'] as String? ?? '',
        emoji: json['emoji'] as String?,
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
        isRead: json['isRead'] as bool? ?? false,
        actions: (json['actions'] as List<dynamic>? ?? [])
            .map((e) => NotificationAction.values.firstWhere(
                  (a) => a.name == (e as String? ?? ''),
                  orElse: () => NotificationAction.dismiss,
                ))
            .toList(),
        actionRoute: json['actionRoute'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'message': message,
        'emoji': emoji,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
        'actions': actions.map((e) => e.name).toList(),
        'actionRoute': actionRoute,
      };
}

/// Plugin status indicator
class PluginStatus {
  final AprilPlugin plugin;
  final SyncStatus syncStatus;
  final String statusText;
  final int? badgeCount;
  final DateTime lastSynced;

  const PluginStatus({
    required this.plugin,
    required this.syncStatus,
    required this.statusText,
    this.badgeCount,
    required this.lastSynced,
  });

  factory PluginStatus.fromJson(Map<String, dynamic> json) => PluginStatus(
        plugin: AprilPlugin.values.firstWhere(
          (e) => e.name == (json['plugin'] as String? ?? ''),
          orElse: () => AprilPlugin.planner,
        ),
        syncStatus: SyncStatus.values.firstWhere(
          (e) => e.name == (json['syncStatus'] as String? ?? ''),
          orElse: () => SyncStatus.offline,
        ),
        statusText: json['statusText'] as String? ?? '',
        badgeCount: (json['badgeCount'] as num?)?.toInt(),
        lastSynced: DateTime.tryParse(json['lastSynced'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'plugin': plugin.name,
        'syncStatus': syncStatus.name,
        'statusText': statusText,
        'badgeCount': badgeCount,
        'lastSynced': lastSynced.toIso8601String(),
      };
}

/// Pending action item
class PendingAction {
  final String id;
  final String description;
  final ActionPriority priority;
  final ActionStatus status;
  final String? dueText;
  final DateTime? dueDate;
  final AprilPlugin? sourcePlugin;

  const PendingAction({
    required this.id,
    required this.description,
    required this.priority,
    this.status = ActionStatus.pending,
    this.dueText,
    this.dueDate,
    this.sourcePlugin,
  });

  factory PendingAction.fromJson(Map<String, dynamic> json) => PendingAction(
        id: json['id'] as String? ?? '',
        description: json['description'] as String? ?? '',
        priority: ActionPriority.values.firstWhere(
          (e) => e.name == (json['priority'] as String? ?? ''),
          orElse: () => ActionPriority.medium,
        ),
        status: ActionStatus.values.firstWhere(
          (e) => e.name == (json['status'] as String? ?? ''),
          orElse: () => ActionStatus.pending,
        ),
        dueText: json['dueText'] as String?,
        dueDate: json['dueDate'] != null
            ? DateTime.tryParse(json['dueDate'] as String? ?? '')
            : null,
        sourcePlugin: json['sourcePlugin'] != null
            ? AprilPlugin.values.firstWhere(
                (e) => e.name == (json['sourcePlugin'] as String? ?? ''),
                orElse: () => AprilPlugin.planner,
              )
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'priority': priority.name,
        'status': status.name,
        'dueText': dueText,
        'dueDate': dueDate?.toIso8601String(),
        'sourcePlugin': sourcePlugin?.name,
      };
}

/// Financial transaction
class Transaction {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final TransactionCategory category;
  final DateTime date;
  final String? description;
  final List<String> tags;
  final bool isRecurring;
  final RecurringFrequency? recurringFrequency;
  final bool hasReceipt;

  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.description,
    this.tags = const [],
    this.isRecurring = false,
    this.recurringFrequency,
    this.hasReceipt = false,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        type: TransactionType.values.firstWhere(
          (e) => e.name == (json['type'] as String? ?? ''),
          orElse: () => TransactionType.expense,
        ),
        category: TransactionCategory.values.firstWhere(
          (e) => e.name == (json['category'] as String? ?? ''),
          orElse: () => TransactionCategory.other,
        ),
        date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        description: json['description'] as String?,
        tags: (json['tags'] as List<dynamic>? ?? [])
            .map((e) => e as String? ?? '')
            .toList(),
        isRecurring: json['isRecurring'] as bool? ?? false,
        recurringFrequency: json['recurringFrequency'] != null
            ? RecurringFrequency.values.firstWhere(
                (e) => e.name == (json['recurringFrequency'] as String? ?? ''),
                orElse: () => RecurringFrequency.monthly,
              )
            : null,
        hasReceipt: json['hasReceipt'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'type': type.name,
        'category': category.name,
        'date': date.toIso8601String(),
        'description': description,
        'tags': tags,
        'isRecurring': isRecurring,
        'recurringFrequency': recurringFrequency?.name,
        'hasReceipt': hasReceipt,
      };
}

/// Upcoming bill
class UpcomingBill {
  final String id;
  final String name;
  final double amount;
  final DateTime dueDate;
  final TransactionCategory category;
  final bool isPaid;
  final bool isAutoPay;

  const UpcomingBill({
    required this.id,
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.category,
    this.isPaid = false,
    this.isAutoPay = false,
  });

  bool get isOverdue => !isPaid && dueDate.isBefore(DateTime.now());

  factory UpcomingBill.fromJson(Map<String, dynamic> json) => UpcomingBill(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        dueDate: DateTime.tryParse(json['dueDate'] as String? ?? '') ?? DateTime.now(),
        category: TransactionCategory.values.firstWhere(
          (e) => e.name == (json['category'] as String? ?? ''),
          orElse: () => TransactionCategory.other,
        ),
        isPaid: json['isPaid'] as bool? ?? false,
        isAutoPay: json['isAutoPay'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'dueDate': dueDate.toIso8601String(),
        'category': category.name,
        'isPaid': isPaid,
        'isAutoPay': isAutoPay,
      };
}

/// Budget category
class BudgetCategory {
  final String id;
  final String name;
  final TransactionCategory category;
  final double limit;
  final double spent;
  final BudgetStatus status;

  const BudgetCategory({
    required this.id,
    required this.name,
    required this.category,
    required this.limit,
    required this.spent,
    required this.status,
  });

  double get percentage => limit > 0 ? (spent / limit).clamp(0.0, 1.5) : 0;
  double get remaining => limit - spent;

  factory BudgetCategory.fromJson(Map<String, dynamic> json) => BudgetCategory(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        category: TransactionCategory.values.firstWhere(
          (e) => e.name == (json['category'] as String? ?? ''),
          orElse: () => TransactionCategory.other,
        ),
        limit: (json['limit'] as num?)?.toDouble() ?? 0.0,
        spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
        status: BudgetStatus.values.firstWhere(
          (e) => e.name == (json['status'] as String? ?? ''),
          orElse: () => BudgetStatus.onTrack,
        ),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.name,
        'limit': limit,
        'spent': spent,
        'status': status.name,
      };
}

/// Monthly financial summary
class MonthlySummary {
  final double totalBalance;
  final double balanceChange;
  final double income;
  final double incomeChange;
  final double expenses;
  final double expenseChange;
  final double savings;
  final double savingsChange;

  const MonthlySummary({
    required this.totalBalance,
    required this.balanceChange,
    required this.income,
    required this.incomeChange,
    required this.expenses,
    required this.expenseChange,
    required this.savings,
    required this.savingsChange,
  });

  // Convenience getters for UI access
  double get currentBalance => totalBalance;
  double get totalIncome => income;
  double get totalExpenses => expenses;
  double get savingsRate => totalBalance > 0 ? (savings / totalBalance) * 100 : 0;

  factory MonthlySummary.fromJson(Map<String, dynamic> json) => MonthlySummary(
        totalBalance: (json['totalBalance'] as num?)?.toDouble() ?? 0.0,
        balanceChange: (json['balanceChange'] as num?)?.toDouble() ?? 0.0,
        income: (json['income'] as num?)?.toDouble() ?? 0.0,
        incomeChange: (json['incomeChange'] as num?)?.toDouble() ?? 0.0,
        expenses: (json['expenses'] as num?)?.toDouble() ?? 0.0,
        expenseChange: (json['expenseChange'] as num?)?.toDouble() ?? 0.0,
        savings: (json['savings'] as num?)?.toDouble() ?? 0.0,
        savingsChange: (json['savingsChange'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'totalBalance': totalBalance,
        'balanceChange': balanceChange,
        'income': income,
        'incomeChange': incomeChange,
        'expenses': expenses,
        'expenseChange': expenseChange,
        'savings': savings,
        'savingsChange': savingsChange,
      };
}

/// Calendar event
class CalendarEvent {
  final String id;
  final String title;
  final EventType type;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAllDay;
  final String? location;
  final String? description;
  final List<String> guests;
  final EventStatus status;
  final Availability availability;
  final String? calendarName;
  final int colorIndex;
  final List<int> reminderMinutes;

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.type,
    required this.startTime,
    required this.endTime,
    this.isAllDay = false,
    this.location,
    this.description,
    this.guests = const [],
    this.status = EventStatus.confirmed,
    this.availability = Availability.busy,
    this.calendarName,
    this.colorIndex = 0,
    this.reminderMinutes = const [15],
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) => CalendarEvent(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        type: EventType.values.firstWhere(
          (e) => e.name == (json['type'] as String? ?? ''),
          orElse: () => EventType.personal,
        ),
        startTime: DateTime.tryParse(json['startTime'] as String? ?? '') ?? DateTime.now(),
        endTime: DateTime.tryParse(json['endTime'] as String? ?? '') ?? DateTime.now(),
        isAllDay: json['isAllDay'] as bool? ?? false,
        location: json['location'] as String?,
        description: json['description'] as String?,
        guests: (json['guests'] as List<dynamic>? ?? [])
            .map((e) => e as String? ?? '')
            .toList(),
        status: EventStatus.values.firstWhere(
          (e) => e.name == (json['status'] as String? ?? ''),
          orElse: () => EventStatus.confirmed,
        ),
        availability: Availability.values.firstWhere(
          (e) => e.name == (json['availability'] as String? ?? ''),
          orElse: () => Availability.busy,
        ),
        calendarName: json['calendarName'] as String?,
        colorIndex: (json['colorIndex'] as num?)?.toInt() ?? 0,
        reminderMinutes: (json['reminderMinutes'] as List<dynamic>? ?? [15])
            .map((e) => (e as num?)?.toInt() ?? 15)
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type.name,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'isAllDay': isAllDay,
        'location': location,
        'description': description,
        'guests': guests,
        'status': status.name,
        'availability': availability.name,
        'calendarName': calendarName,
        'colorIndex': colorIndex,
        'reminderMinutes': reminderMinutes,
      };
}

/// Wishlist item
class WishlistItem {
  final String id;
  final String name;
  final String? imageUrl;
  final WishlistPriority priority;
  final double price;
  final double savedAmount;
  final String? category;
  final List<String> tags;
  final DateTime? desiredBy;
  final String? url;
  final String? notes;
  final ItemAvailability availability;
  final bool isPurchased;
  final DateTime addedAt;

  const WishlistItem({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.priority,
    required this.price,
    this.savedAmount = 0,
    this.category,
    this.tags = const [],
    this.desiredBy,
    this.url,
    this.notes,
    this.availability = ItemAvailability.inStock,
    this.isPurchased = false,
    required this.addedAt,
  });

  double get savedPercentage => price > 0 ? (savedAmount / price * 100).clamp(0, 100) : 0;

  factory WishlistItem.fromJson(Map<String, dynamic> json) => WishlistItem(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        imageUrl: json['imageUrl'] as String?,
        priority: WishlistPriority.values.firstWhere(
          (e) => e.name == (json['priority'] as String? ?? ''),
          orElse: () => WishlistPriority.medium,
        ),
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        savedAmount: (json['savedAmount'] as num?)?.toDouble() ?? 0,
        category: json['category'] as String?,
        tags: (json['tags'] as List<dynamic>? ?? [])
            .map((e) => e as String? ?? '')
            .toList(),
        desiredBy: json['desiredBy'] != null
            ? DateTime.tryParse(json['desiredBy'] as String? ?? '')
            : null,
        url: json['url'] as String?,
        notes: json['notes'] as String?,
        availability: ItemAvailability.values.firstWhere(
          (e) => e.name == (json['availability'] as String? ?? ''),
          orElse: () => ItemAvailability.unknown,
        ),
        isPurchased: json['isPurchased'] as bool? ?? false,
        addedAt: DateTime.tryParse(json['addedAt'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
        'priority': priority.name,
        'price': price,
        'savedAmount': savedAmount,
        'category': category,
        'tags': tags,
        'desiredBy': desiredBy?.toIso8601String(),
        'url': url,
        'notes': notes,
        'availability': availability.name,
        'isPurchased': isPurchased,
        'addedAt': addedAt.toIso8601String(),
      };
}

/// Personal statement card data
class StatementCardData {
  final StatementCard type;
  final String title;
  final String emoji;
  final String summary;
  final int completionPercent;
  final DateTime lastUpdated;
  final bool isLocked;
  final List<String> highlights;

  const StatementCardData({
    required this.type,
    required this.title,
    required this.emoji,
    required this.summary,
    required this.completionPercent,
    required this.lastUpdated,
    this.isLocked = false,
    this.highlights = const [],
  });

  factory StatementCardData.fromJson(Map<String, dynamic> json) => StatementCardData(
        type: StatementCard.values.firstWhere(
          (e) => e.name == (json['type'] as String? ?? ''),
          orElse: () => StatementCard.lifestyle,
        ),
        title: json['title'] as String? ?? '',
        emoji: json['emoji'] as String? ?? '',
        summary: json['summary'] as String? ?? '',
        completionPercent: (json['completionPercent'] as num?)?.toInt() ?? 0,
        lastUpdated: DateTime.tryParse(json['lastUpdated'] as String? ?? '') ?? DateTime.now(),
        isLocked: json['isLocked'] as bool? ?? false,
        highlights: (json['highlights'] as List<dynamic>? ?? [])
            .map((e) => e as String? ?? '')
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'title': title,
        'emoji': emoji,
        'summary': summary,
        'completionPercent': completionPercent,
        'lastUpdated': lastUpdated.toIso8601String(),
        'isLocked': isLocked,
        'highlights': highlights,
      };
}

/// Statement version for version control
class StatementVersion {
  final String id;
  final int versionNumber;
  final DateTime createdAt;
  final String changeComment;
  final String? changedBy;

  const StatementVersion({
    required this.id,
    required this.versionNumber,
    required this.createdAt,
    required this.changeComment,
    this.changedBy,
  });

  factory StatementVersion.fromJson(Map<String, dynamic> json) => StatementVersion(
        id: json['id'] as String? ?? '',
        versionNumber: (json['versionNumber'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        changeComment: json['changeComment'] as String? ?? '',
        changedBy: json['changedBy'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'versionNumber': versionNumber,
        'createdAt': createdAt.toIso8601String(),
        'changeComment': changeComment,
        'changedBy': changedBy,
      };
}

/// Settings toggle item
class AprilSettingsToggle {
  final String key;
  final String title;
  final String? subtitle;
  final bool value;

  const AprilSettingsToggle({
    required this.key,
    required this.title,
    this.subtitle,
    required this.value,
  });

  factory AprilSettingsToggle.fromJson(Map<String, dynamic> json) => AprilSettingsToggle(
        key: json['key'] as String? ?? '',
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String?,
        value: json['value'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'key': key,
        'title': title,
        'subtitle': subtitle,
        'value': value,
      };
}

/// Spending analytics data point
class SpendingDataPoint {
  final String label;
  final double amount;
  final TransactionCategory? category;

  const SpendingDataPoint({
    required this.label,
    required this.amount,
    this.category,
  });

  factory SpendingDataPoint.fromJson(Map<String, dynamic> json) => SpendingDataPoint(
        label: json['label'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        category: json['category'] != null
            ? TransactionCategory.values.firstWhere(
                (e) => e.name == (json['category'] as String? ?? ''),
                orElse: () => TransactionCategory.other,
              )
            : null,
      );

  Map<String, dynamic> toJson() => {
        'label': label,
        'amount': amount,
        'category': category?.name,
      };
}

/// Financial health score
class FinancialHealth {
  final int score;
  final String grade;
  final String summary;
  final List<String> recommendations;

  const FinancialHealth({
    required this.score,
    required this.grade,
    required this.summary,
    this.recommendations = const [],
  });

  /// Alias for UI compatibility
  List<String> get tips => recommendations;

  factory FinancialHealth.fromJson(Map<String, dynamic> json) => FinancialHealth(
        score: (json['score'] as num?)?.toInt() ?? 0,
        grade: json['grade'] as String? ?? '',
        summary: json['summary'] as String? ?? '',
        recommendations: (json['recommendations'] as List<dynamic>? ?? [])
            .map((e) => e as String? ?? '')
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'score': score,
        'grade': grade,
        'summary': summary,
        'recommendations': recommendations,
      };
}

/// Wishlist collection
class WishlistCollection {
  final String id;
  final String name;
  final String emoji;
  final int itemCount;
  final double totalValue;
  final bool isShared;

  const WishlistCollection({
    required this.id,
    required this.name,
    required this.emoji,
    required this.itemCount,
    required this.totalValue,
    this.isShared = false,
  });

  factory WishlistCollection.fromJson(Map<String, dynamic> json) => WishlistCollection(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        emoji: json['emoji'] as String? ?? '',
        itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
        totalValue: (json['totalValue'] as num?)?.toDouble() ?? 0.0,
        isShared: json['isShared'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'itemCount': itemCount,
        'totalValue': totalValue,
        'isShared': isShared,
      };
}
