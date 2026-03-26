/// GO Module — Unified Financial Center
/// All data models, enums, and value objects
/// Module Color: Emerald Green (0xFF10B981)
/// Visibility: Owner + Administrator only

import 'package:flutter/material.dart';

// ═══════════════════════════════════════════
// ENUMS
// ═══════════════════════════════════════════

/// Financial context type for context switcher (Screen 0)
enum FinancialContextType { personal, business, branch, entity }

/// Permission level within a context
enum ContextPermission { fullAccess, viewOnly, restricted }

/// Gateway connection status
enum GatewayStatus { live, pending, offline, setupRequired }

/// Transaction type
enum TransactionType { buy, sell, transfer, tabSettlement, batchPayment, fee, adjustment }

/// Transaction status
enum TransactionStatus { draft, pending, processing, completed, failed, cancelled, disputed, reversed }

/// Currency used in the system
enum QPCurrency { qp, ghs }

/// Funding source type
enum FundingSourceType { gatewayBalance, bankAccount, card, mobileMoney, crypto }

/// Tab status
enum TabStatus { active, overdue, settled, closed, frozen, disputed }

/// Tab risk level
enum TabRisk { low, medium, high, critical }

/// Request type for Request Center
enum RequestType {
  creditLimitChange, tabClosure, paymentExtension, disputeFiling,
  termsModification, newTab, documentRequest, relationshipChange
}

/// Request status pipeline
enum RequestStatus { draft, submitted, underReview, approved, rejected, implemented, closed }

/// Favorite category
enum FavoriteCategory { people, businesses, services, internal }

/// Verification method
enum GoVerificationMethod { faceId, fingerprint, pin, otp }

/// Verification state
enum GoVerificationState { pending, verifying, verified, failed }

/// Batch action type
enum BatchActionType { transfer, tabSettlement, reminder, creditAdjust, close, export }

/// Financial goal type
enum GoalType { savings, investment, debtReduction, revenue, custom }

/// Goal status
enum GoalStatus { onTrack, atRisk, behind, completed, paused }

/// Report type
enum ReportType { income, balanceSheet, cashFlow, agedDebtors, custom }

/// Report format
enum ReportFormat { pdf, excel, csv, api }

/// Compliance status
enum ComplianceStatus { compliant, actionRequired, nonCompliant, pending }

/// Integration status
enum IntegrationStatus { connected, disconnected, error, configuring }

/// Integration category
enum IntegrationCategory { accounting, banking, business, custom }

/// Archive period
enum ArchivePeriod { lastYear, last2Years, last5Years, all }

/// Dashboard tab for Screen 1 section 7
enum ActivityTab { all, credits, debits, transfers, system }

/// Rate alert notification channel
enum RateAlertChannel { push, email, sms }

/// Transfer scheduling option
enum TransferSchedule { now, later, onRate, recurring }

/// Recurring frequency
enum RecurringFrequency { daily, weekly, biWeekly, monthly, quarterly }

/// Tax category
enum TaxCategory { income, expense, transfer, fee, adjustment }

/// Audit event severity
enum AuditSeverity { info, warning, critical }

/// Financial health metric
enum HealthMetric { liquidity, debtRatio, cashFlow, reserveDepth, gatewayDiversity }

/// SLA status for escalation
enum EscalationTier { level1, level2, level3, managerReview }

// ═══════════════════════════════════════════
// CORE DATA MODELS
// ═══════════════════════════════════════════

/// Financial context for context switcher
class FinancialContext {
  final String id;
  final String name;
  final String role;
  final FinancialContextType type;
  final ContextPermission permission;
  final double qpBalance;
  final String lastActivity;
  final int activeTabs;
  final int pendingTransactions;
  final int unreadAlerts;
  final int favoritesCount;
  final String? avatarUrl;

  const FinancialContext({
    required this.id,
    required this.name,
    required this.role,
    required this.type,
    required this.permission,
    required this.qpBalance,
    required this.lastActivity,
    this.activeTabs = 0,
    this.pendingTransactions = 0,
    this.unreadAlerts = 0,
    this.favoritesCount = 0,
    this.avatarUrl,
  });

  String get typeLabel {
    switch (type) {
      case FinancialContextType.personal: return 'Personal Finance';
      case FinancialContextType.business: return 'Business Finance';
      case FinancialContextType.branch: return 'Branch Finance';
      case FinancialContextType.entity: return 'Entity Finance';
    }
  }

  String get typeEmoji {
    switch (type) {
      case FinancialContextType.personal: return '👤';
      case FinancialContextType.business: return '🏢';
      case FinancialContextType.branch: return '🏪';
      case FinancialContextType.entity: return '🌐';
    }
  }

  String get permissionLabel {
    switch (permission) {
      case ContextPermission.fullAccess: return 'Full Access';
      case ContextPermission.viewOnly: return 'View Only';
      case ContextPermission.restricted: return 'Restricted';
    }
  }
}

/// Payment gateway info
class PaymentGateway {
  final String id;
  final String name;
  final GatewayStatus status;
  final double balance;
  final String currency;
  final double buyRate;
  final double sellRate;
  final double minBuy;
  final double maxBuy;
  final double minSell;
  final double maxSell;
  final double feePercent;
  final double flatFee;
  final String processingTime;

  const PaymentGateway({
    required this.id,
    required this.name,
    required this.status,
    required this.balance,
    this.currency = 'GHS',
    required this.buyRate,
    required this.sellRate,
    required this.minBuy,
    required this.maxBuy,
    required this.minSell,
    required this.maxSell,
    required this.feePercent,
    this.flatFee = 0,
    required this.processingTime,
  });

  String get statusLabel {
    switch (status) {
      case GatewayStatus.live: return '🟢 Live';
      case GatewayStatus.pending: return '🟡 Pending';
      case GatewayStatus.offline: return '🔴 Offline';
      case GatewayStatus.setupRequired: return '🔴 Setup Required';
    }
  }

  Color get statusColor {
    switch (status) {
      case GatewayStatus.live: return const Color(0xFF10B981);
      case GatewayStatus.pending: return const Color(0xFFF59E0B);
      case GatewayStatus.offline: return const Color(0xFFEF4444);
      case GatewayStatus.setupRequired: return const Color(0xFFEF4444);
    }
  }
}

/// Transaction record
class GoTransaction {
  final String id;
  final TransactionType type;
  final TransactionStatus status;
  final double amount;
  final double? feeAmount;
  final double? netAmount;
  final String fromEntity;
  final String toEntity;
  final String? gatewayName;
  final String? fundingSource;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? reference;
  final String? note;
  final String? category;

  const GoTransaction({
    required this.id,
    required this.type,
    required this.status,
    required this.amount,
    this.feeAmount,
    this.netAmount,
    required this.fromEntity,
    required this.toEntity,
    this.gatewayName,
    this.fundingSource,
    required this.createdAt,
    this.completedAt,
    this.reference,
    this.note,
    this.category,
  });

  String get typeLabel {
    switch (type) {
      case TransactionType.buy: return 'Buy QPoints';
      case TransactionType.sell: return 'Sell QPoints';
      case TransactionType.transfer: return 'Transfer';
      case TransactionType.tabSettlement: return 'Tab Settlement';
      case TransactionType.batchPayment: return 'Batch Payment';
      case TransactionType.fee: return 'Service Fee';
      case TransactionType.adjustment: return 'Adjustment';
    }
  }

  String get statusLabel {
    switch (status) {
      case TransactionStatus.draft: return 'Draft';
      case TransactionStatus.pending: return 'Pending';
      case TransactionStatus.processing: return 'Processing';
      case TransactionStatus.completed: return 'Completed';
      case TransactionStatus.failed: return 'Failed';
      case TransactionStatus.cancelled: return 'Cancelled';
      case TransactionStatus.disputed: return 'Disputed';
      case TransactionStatus.reversed: return 'Reversed';
    }
  }

  String get statusEmoji {
    switch (status) {
      case TransactionStatus.completed: return '✅';
      case TransactionStatus.pending: return '🕓';
      case TransactionStatus.processing: return '⏳';
      case TransactionStatus.failed: return '❌';
      case TransactionStatus.cancelled: return '🚫';
      case TransactionStatus.disputed: return '⚠️';
      case TransactionStatus.reversed: return '↩️';
      case TransactionStatus.draft: return '📝';
    }
  }

  IconData get typeIcon {
    switch (type) {
      case TransactionType.buy: return Icons.arrow_downward;
      case TransactionType.sell: return Icons.arrow_upward;
      case TransactionType.transfer: return Icons.swap_horiz;
      case TransactionType.tabSettlement: return Icons.receipt_long;
      case TransactionType.batchPayment: return Icons.playlist_add_check;
      case TransactionType.fee: return Icons.toll;
      case TransactionType.adjustment: return Icons.tune;
    }
  }

  bool get isCredit => type == TransactionType.buy || (type == TransactionType.transfer && toEntity == 'You');
  bool get isDebit => type == TransactionType.sell || (type == TransactionType.transfer && fromEntity == 'You');
}

/// Liquidity breakdown
class LiquidityInfo {
  final double available;
  final double frozen;
  final double reserved;

  const LiquidityInfo({required this.available, required this.frozen, required this.reserved});

  double get total => available + frozen + reserved;
  double get availablePercent => total > 0 ? (available / total * 100) : 0;
  double get frozenPercent => total > 0 ? (frozen / total * 100) : 0;
  double get reservedPercent => total > 0 ? (reserved / total * 100) : 0;
}

/// Financial health metric data
class HealthMetricData {
  final HealthMetric metric;
  final double score;
  final String label;

  const HealthMetricData({required this.metric, required this.score, required this.label});

  String get metricLabel {
    switch (metric) {
      case HealthMetric.liquidity: return 'Liquidity';
      case HealthMetric.debtRatio: return 'Debt Ratio';
      case HealthMetric.cashFlow: return 'Cash Flow';
      case HealthMetric.reserveDepth: return 'Reserve Depth';
      case HealthMetric.gatewayDiversity: return 'Gateway Diversity';
    }
  }
}

/// Tab (credit) record
class GoTab {
  final String id;
  final String entityName;
  final String entityRole;
  final String description;
  final TabStatus status;
  final TabRisk risk;
  final double creditLimit;
  final double currentBalance;
  final double minimumDue;
  final DateTime dueDate;
  final DateTime createdAt;
  final DateTime? lastActivity;
  final int onTimePayments;
  final int totalPayments;
  final double interestRate;
  final String? avatarUrl;

  const GoTab({
    required this.id,
    required this.entityName,
    required this.entityRole,
    required this.description,
    required this.status,
    required this.risk,
    required this.creditLimit,
    required this.currentBalance,
    required this.minimumDue,
    required this.dueDate,
    required this.createdAt,
    this.lastActivity,
    this.onTimePayments = 0,
    this.totalPayments = 0,
    this.interestRate = 0,
    this.avatarUrl,
  });

  double get utilization => creditLimit > 0 ? (currentBalance / creditLimit * 100) : 0;
  double get available => creditLimit - currentBalance;
  bool get isOverdue => status == TabStatus.overdue || (dueDate.isBefore(DateTime.now()) && status == TabStatus.active);
  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;

  String get statusLabel {
    switch (status) {
      case TabStatus.active: return 'Active';
      case TabStatus.overdue: return 'Overdue';
      case TabStatus.settled: return 'Settled';
      case TabStatus.closed: return 'Closed';
      case TabStatus.frozen: return 'Frozen';
      case TabStatus.disputed: return 'Disputed';
    }
  }

  Color get statusColor {
    switch (status) {
      case TabStatus.active: return const Color(0xFF10B981);
      case TabStatus.overdue: return const Color(0xFFEF4444);
      case TabStatus.settled: return const Color(0xFF3B82F6);
      case TabStatus.closed: return const Color(0xFF9CA3AF);
      case TabStatus.frozen: return const Color(0xFFF59E0B);
      case TabStatus.disputed: return const Color(0xFF7C3AED);
    }
  }

  Color get riskColor {
    switch (risk) {
      case TabRisk.low: return const Color(0xFF10B981);
      case TabRisk.medium: return const Color(0xFFF59E0B);
      case TabRisk.high: return const Color(0xFFEF4444);
      case TabRisk.critical: return const Color(0xFF7C3AED);
    }
  }
}

/// Tab timeline event
class TabTimelineEvent {
  final String id;
  final String description;
  final DateTime timestamp;
  final double? amount;
  final String? actor;
  final bool isSystem;

  const TabTimelineEvent({
    required this.id,
    required this.description,
    required this.timestamp,
    this.amount,
    this.actor,
    this.isSystem = false,
  });
}

/// Request record
class GoRequest {
  final String id;
  final RequestType type;
  final RequestStatus status;
  final String title;
  final String description;
  final String submittedBy;
  final DateTime submittedAt;
  final DateTime? decidedAt;
  final String? decidedBy;
  final String? relatedTabId;
  final double? amount;
  final String? comments;

  const GoRequest({
    required this.id,
    required this.type,
    required this.status,
    required this.title,
    required this.description,
    required this.submittedBy,
    required this.submittedAt,
    this.decidedAt,
    this.decidedBy,
    this.relatedTabId,
    this.amount,
    this.comments,
  });

  String get typeLabel {
    switch (type) {
      case RequestType.creditLimitChange: return 'Credit Limit Change';
      case RequestType.tabClosure: return 'Tab Closure';
      case RequestType.paymentExtension: return 'Payment Extension';
      case RequestType.disputeFiling: return 'Dispute Filing';
      case RequestType.termsModification: return 'Terms Modification';
      case RequestType.newTab: return 'New Tab Request';
      case RequestType.documentRequest: return 'Document Request';
      case RequestType.relationshipChange: return 'Relationship Change';
    }
  }

  IconData get typeIcon {
    switch (type) {
      case RequestType.creditLimitChange: return Icons.credit_score;
      case RequestType.tabClosure: return Icons.cancel_outlined;
      case RequestType.paymentExtension: return Icons.schedule;
      case RequestType.disputeFiling: return Icons.gavel;
      case RequestType.termsModification: return Icons.edit_note;
      case RequestType.newTab: return Icons.add_card;
      case RequestType.documentRequest: return Icons.description;
      case RequestType.relationshipChange: return Icons.group;
    }
  }

  String get statusLabel {
    switch (status) {
      case RequestStatus.draft: return 'Draft';
      case RequestStatus.submitted: return 'Submitted';
      case RequestStatus.underReview: return 'Under Review';
      case RequestStatus.approved: return 'Approved';
      case RequestStatus.rejected: return 'Rejected';
      case RequestStatus.implemented: return 'Implemented';
      case RequestStatus.closed: return 'Closed';
    }
  }

  Color get statusColor {
    switch (status) {
      case RequestStatus.draft: return const Color(0xFF9CA3AF);
      case RequestStatus.submitted: return const Color(0xFF3B82F6);
      case RequestStatus.underReview: return const Color(0xFFF59E0B);
      case RequestStatus.approved: return const Color(0xFF10B981);
      case RequestStatus.rejected: return const Color(0xFFEF4444);
      case RequestStatus.implemented: return const Color(0xFF10B981);
      case RequestStatus.closed: return const Color(0xFF6B7280);
    }
  }
}

/// Favorite entity
class FavoriteEntity {
  final String id;
  final String name;
  final String handle;
  final String role;
  final FavoriteCategory category;
  final double rating;
  final int ratingCount;
  final double totalSpent;
  final double avgTransaction;
  final int transactionCount;
  final DateTime favoriteSince;
  final DateTime? lastInteraction;
  final bool isOnline;
  final bool isMutualFavorite;
  final int trustScore;
  final String? avatarUrl;

  const FavoriteEntity({
    required this.id,
    required this.name,
    required this.handle,
    required this.role,
    required this.category,
    this.rating = 0,
    this.ratingCount = 0,
    this.totalSpent = 0,
    this.avgTransaction = 0,
    this.transactionCount = 0,
    required this.favoriteSince,
    this.lastInteraction,
    this.isOnline = false,
    this.isMutualFavorite = false,
    this.trustScore = 0,
    this.avatarUrl,
  });

  String get categoryLabel {
    switch (category) {
      case FavoriteCategory.people: return 'Person';
      case FavoriteCategory.businesses: return 'Business';
      case FavoriteCategory.services: return 'Service Provider';
      case FavoriteCategory.internal: return 'Internal Staff';
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case FavoriteCategory.people: return Icons.person;
      case FavoriteCategory.businesses: return Icons.storefront;
      case FavoriteCategory.services: return Icons.directions_car;
      case FavoriteCategory.internal: return Icons.badge;
    }
  }
}

/// Batch operation record
class BatchOperation {
  final String id;
  final BatchActionType type;
  final int itemCount;
  final double totalAmount;
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final int completedItems;
  final int failedItems;
  final String? label;

  const BatchOperation({
    required this.id,
    required this.type,
    required this.itemCount,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.scheduledAt,
    this.completedItems = 0,
    this.failedItems = 0,
    this.label,
  });

  String get typeLabel {
    switch (type) {
      case BatchActionType.transfer: return 'Bulk Transfer';
      case BatchActionType.tabSettlement: return 'Tab Settlements';
      case BatchActionType.reminder: return 'Payment Reminders';
      case BatchActionType.creditAdjust: return 'Credit Adjustments';
      case BatchActionType.close: return 'Tab Closures';
      case BatchActionType.export: return 'Data Export';
    }
  }

  double get progress => itemCount > 0 ? (completedItems / itemCount) : 0;
}

/// Financial goal
class FinancialGoal {
  final String id;
  final String title;
  final GoalType type;
  final GoalStatus status;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final DateTime createdAt;
  final String? description;

  const FinancialGoal({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.createdAt,
    this.description,
  });

  double get progress => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0, 1) : 0;
  int get daysRemaining => targetDate.difference(DateTime.now()).inDays;

  String get typeEmoji {
    switch (type) {
      case GoalType.savings: return '🏦';
      case GoalType.investment: return '📈';
      case GoalType.debtReduction: return '💳';
      case GoalType.revenue: return '💰';
      case GoalType.custom: return '🎯';
    }
  }

  String get statusLabel {
    switch (status) {
      case GoalStatus.onTrack: return 'On Track';
      case GoalStatus.atRisk: return 'At Risk';
      case GoalStatus.behind: return 'Behind';
      case GoalStatus.completed: return 'Completed';
      case GoalStatus.paused: return 'Paused';
    }
  }

  Color get statusColor {
    switch (status) {
      case GoalStatus.onTrack: return const Color(0xFF10B981);
      case GoalStatus.atRisk: return const Color(0xFFF59E0B);
      case GoalStatus.behind: return const Color(0xFFEF4444);
      case GoalStatus.completed: return const Color(0xFF3B82F6);
      case GoalStatus.paused: return const Color(0xFF9CA3AF);
    }
  }
}

/// Budget category
class BudgetCategory {
  final String id;
  final String name;
  final double allocated;
  final double spent;
  final IconData icon;
  final Color color;

  const BudgetCategory({
    required this.id,
    required this.name,
    required this.allocated,
    required this.spent,
    required this.icon,
    required this.color,
  });

  double get remaining => allocated - spent;
  double get utilization => allocated > 0 ? (spent / allocated * 100).clamp(0, 200) : 0;
  bool get isOverBudget => spent > allocated;
}

/// Cash flow projection point
class CashFlowPoint {
  final String label;
  final double income;
  final double expense;

  const CashFlowPoint({required this.label, required this.income, required this.expense});

  double get net => income - expense;
}

/// Tax transaction record
class TaxEntry {
  final String id;
  final String transactionId;
  final String description;
  final TaxCategory category;
  final double amount;
  final DateTime date;
  final bool isCategorized;
  final String? taxCode;
  final String? receiptPath;

  const TaxEntry({
    required this.id,
    required this.transactionId,
    required this.description,
    required this.category,
    required this.amount,
    required this.date,
    this.isCategorized = false,
    this.taxCode,
    this.receiptPath,
  });
}

/// Generated report record
class GeneratedReport {
  final String id;
  final String title;
  final ReportType type;
  final ReportFormat format;
  final DateTime generatedAt;
  final String period;
  final double fileSize;
  final bool isScheduled;

  const GeneratedReport({
    required this.id,
    required this.title,
    required this.type,
    required this.format,
    required this.generatedAt,
    required this.period,
    required this.fileSize,
    this.isScheduled = false,
  });

  String get typeLabel {
    switch (type) {
      case ReportType.income: return 'Income Statement';
      case ReportType.balanceSheet: return 'Balance Sheet';
      case ReportType.cashFlow: return 'Cash Flow';
      case ReportType.agedDebtors: return 'Aged Debtors';
      case ReportType.custom: return 'Custom Report';
    }
  }

  String get formatLabel {
    switch (format) {
      case ReportFormat.pdf: return 'PDF';
      case ReportFormat.excel: return 'Excel';
      case ReportFormat.csv: return 'CSV';
      case ReportFormat.api: return 'API';
    }
  }

  IconData get formatIcon {
    switch (format) {
      case ReportFormat.pdf: return Icons.picture_as_pdf;
      case ReportFormat.excel: return Icons.table_chart;
      case ReportFormat.csv: return Icons.text_snippet;
      case ReportFormat.api: return Icons.api;
    }
  }
}

/// Audit trail entry
class AuditEntry {
  final String id;
  final String action;
  final String actor;
  final DateTime timestamp;
  final AuditSeverity severity;
  final String? ipAddress;
  final String? details;
  final String? relatedEntityId;

  const AuditEntry({
    required this.id,
    required this.action,
    required this.actor,
    required this.timestamp,
    required this.severity,
    this.ipAddress,
    this.details,
    this.relatedEntityId,
  });

  Color get severityColor {
    switch (severity) {
      case AuditSeverity.info: return const Color(0xFF3B82F6);
      case AuditSeverity.warning: return const Color(0xFFF59E0B);
      case AuditSeverity.critical: return const Color(0xFFEF4444);
    }
  }

  String get severityLabel {
    switch (severity) {
      case AuditSeverity.info: return 'Info';
      case AuditSeverity.warning: return 'Warning';
      case AuditSeverity.critical: return 'Critical';
    }
  }
}

/// Third-party integration
class GoIntegration {
  final String id;
  final String name;
  final IntegrationCategory category;
  final IntegrationStatus status;
  final String? description;
  final DateTime? lastSync;
  final int errorCount;
  final IconData icon;

  const GoIntegration({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    this.description,
    this.lastSync,
    this.errorCount = 0,
    required this.icon,
  });

  String get statusLabel {
    switch (status) {
      case IntegrationStatus.connected: return 'Connected';
      case IntegrationStatus.disconnected: return 'Disconnected';
      case IntegrationStatus.error: return 'Error';
      case IntegrationStatus.configuring: return 'Configuring';
    }
  }

  Color get statusColor {
    switch (status) {
      case IntegrationStatus.connected: return const Color(0xFF10B981);
      case IntegrationStatus.disconnected: return const Color(0xFF9CA3AF);
      case IntegrationStatus.error: return const Color(0xFFEF4444);
      case IntegrationStatus.configuring: return const Color(0xFFF59E0B);
    }
  }
}

/// Archived record
class ArchivedRecord {
  final String id;
  final String title;
  final String type;
  final DateTime archivedAt;
  final String period;
  final int transactionCount;
  final double totalValue;
  final bool isOnLegalHold;

  const ArchivedRecord({
    required this.id,
    required this.title,
    required this.type,
    required this.archivedAt,
    required this.period,
    required this.transactionCount,
    required this.totalValue,
    this.isOnLegalHold = false,
  });
}

/// Upcoming financial event
class UpcomingEvent {
  final String id;
  final String title;
  final DateTime date;
  final double? amount;
  final String? relatedId;
  final IconData icon;
  final Color color;

  const UpcomingEvent({
    required this.id,
    required this.title,
    required this.date,
    this.amount,
    this.relatedId,
    required this.icon,
    required this.color,
  });
}

/// Rate alert configuration
class RateAlert {
  final String id;
  final double targetRate;
  final RateAlertChannel channel;
  final bool isActive;

  const RateAlert({required this.id, required this.targetRate, required this.channel, this.isActive = true});
}

/// AI insight
class FinancialInsight {
  final String id;
  final String text;
  final IconData icon;
  final bool isActionable;
  final String? actionLabel;

  const FinancialInsight({required this.id, required this.text, required this.icon, this.isActionable = false, this.actionLabel});
}

/// Compliance check item
class ComplianceCheck {
  final String id;
  final String title;
  final String description;
  final ComplianceStatus status;
  final DateTime? lastChecked;
  final DateTime? deadline;

  const ComplianceCheck({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.lastChecked,
    this.deadline,
  });

  Color get statusColor {
    switch (status) {
      case ComplianceStatus.compliant: return const Color(0xFF10B981);
      case ComplianceStatus.actionRequired: return const Color(0xFFF59E0B);
      case ComplianceStatus.nonCompliant: return const Color(0xFFEF4444);
      case ComplianceStatus.pending: return const Color(0xFF9CA3AF);
    }
  }

  String get statusLabel {
    switch (status) {
      case ComplianceStatus.compliant: return 'Compliant';
      case ComplianceStatus.actionRequired: return 'Action Required';
      case ComplianceStatus.nonCompliant: return 'Non-Compliant';
      case ComplianceStatus.pending: return 'Pending';
    }
  }
}

/// Funding source for transactions
class FundingSource {
  final String id;
  final String label;
  final FundingSourceType type;
  final double? balance;
  final String? lastFour;
  final bool isDefault;

  const FundingSource({
    required this.id,
    required this.label,
    required this.type,
    this.balance,
    this.lastFour,
    this.isDefault = false,
  });

  IconData get icon {
    switch (type) {
      case FundingSourceType.gatewayBalance: return Icons.account_balance_wallet;
      case FundingSourceType.bankAccount: return Icons.account_balance;
      case FundingSourceType.card: return Icons.credit_card;
      case FundingSourceType.mobileMoney: return Icons.phone_android;
      case FundingSourceType.crypto: return Icons.currency_bitcoin;
    }
  }
}
