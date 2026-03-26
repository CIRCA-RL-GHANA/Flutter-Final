/// APRIL Module — Data Models
/// Personal Assistant & Command Core: ActionCore, Planner, Calendar, Wishlist, Statement
/// Module Color: Gold 0xFFFFD700

// ──────────────────────────────────────────────
//  ENUMS
// ──────────────────────────────────────────────

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

// ──────────────────────────────────────────────
//  DATA MODELS
// ──────────────────────────────────────────────

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
}
