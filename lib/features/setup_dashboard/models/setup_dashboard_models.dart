/// ═══════════════════════════════════════════════════════════════════════════
/// SETUP DASHBOARD MODULE — Data Models
/// Comprehensive models for 19+ screens:
/// Hub Dashboard, Products, Vehicles, Tabs, Discounts, Staff, Places,
/// Delivery Zones, Vehicle Bands, Branches, Campaigns, Social, Connections,
/// Audit Log, Outlook, Q-Points, My Activity, Profile, Subscription, Interests
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

// ─── Enums ──────────────────────────────────────────────────────────────────

/// Access level for a dashboard card per role
enum CardAccessLevel {
  fullAccess,
  branchScoped,
  viewOnly,
  branchViewOnly,
  personalOnly,
  ownOnly,
  hidden,
}

/// Card loading / data states
enum CardState { loading, loaded, empty, error }

/// Stock levels
enum StockLevel { inStock, lowStock, outOfStock }

/// Vehicle operational status
enum VehicleStatus { active, maintenance, offline, idle }

/// Tab account status
enum TabStatus { active, overdue, atLimit, frozen, closed }

/// Discount tier type
enum DiscountType { percentage, fixedAmount, buyXGetY }

/// Discount status
enum DiscountStatus { active, paused, scheduled, draft, ended }

/// Staff presence status
enum StaffStatus { online, offline, idle, onLeave }

/// Place type
enum PlaceType { retail, warehouse, office, home, custom }

/// Place visibility
enum PlaceVisibility { public, private }

/// Zone status
enum ZoneStatus { active, inactive, partial }

/// Band utilization level
enum BandUtilization { optimal, low, high, critical }

/// Branch online status
enum BranchStatus { online, offline, maintenance }

/// Campaign type
enum CampaignType { discount, email, socialMedia, sms, push, multiChannel }

/// Campaign goal
enum CampaignGoal { increaseSales, brandAwareness, customerRetention, productLaunch }

/// Campaign status
enum CampaignStatus { active, paused, scheduled, draft, ended }

/// Post platform
enum SocialPlatform { facebook, instagram, twitter, linkedIn, tikTok }

/// Post status
enum PostStatus { published, scheduled, draft }

/// Connection type
enum ConnectionType { supplier, customer, partner, other }

/// Connection status
enum ConnectionStatus { active, pending, blocked }

/// Audit action type
enum AuditAction { create, read, update, delete, login, export, import_ }

/// Audit outcome
enum AuditOutcome { success, failure, suspicious }

/// Notification priority
enum AlertPriority { critical, important, normal, informational }

/// Q-Points transaction type
enum QPointsTransactionType { earned, redeemed, expired, bonus, transferred }

/// Q-Points transaction status
enum QPointsTransactionStatus { completed, pending, failed }

/// Task status
enum TaskStatus { todo, inProgress, completed, overdue, blocked, cancelled }

/// Goal status
enum GoalStatus { onTrack, ahead, atRisk, behind, needsAttention, completed }

/// Subscription plan
enum SubscriptionPlan { free, basic, premium, enterprise }

// ─── Hub Dashboard Models ───────────────────────────────────────────────────

/// A module card on the Setup Dashboard Hub
class DashboardCard {
  final String id;
  final String title;
  final IconData icon;
  final String route;
  final CardState state;
  final int alertCount;
  final Map<String, String> metrics;
  final List<String> actionLabels;
  final CardAccessLevel accessLevel;

  /// Optional progress bar (0.0–1.0), e.g. stock utilisation or credit usage
  final double? progress;
  /// Optional label above/below progress bar
  final String? progressLabel;

  /// Status dots for quick fleet/staff glance (color, label)
  final List<StatusDot> statusDots;

  /// Optional highlight accent colour override (e.g. green for healthy)
  final Color? highlightColor;

  /// Single-line summary beneath metrics, e.g. "Coverage: 85% of target"
  final String? summaryLine;

  /// Subtitle shown under title, e.g. "₵312,450 total credit"
  final String? subtitle;

  const DashboardCard({
    required this.id,
    required this.title,
    required this.icon,
    required this.route,
    this.state = CardState.loaded,
    this.alertCount = 0,
    this.metrics = const {},
    this.actionLabels = const [],
    this.accessLevel = CardAccessLevel.fullAccess,
    this.progress,
    this.progressLabel,
    this.statusDots = const [],
    this.highlightColor,
    this.summaryLine,
    this.subtitle,
  });

  bool get hasAlerts => alertCount > 0;
  bool get isViewOnly =>
      accessLevel == CardAccessLevel.viewOnly ||
      accessLevel == CardAccessLevel.branchViewOnly;
}

/// Tiny coloured dot for fleet/staff status visualization
class StatusDot {
  final Color color;
  final String label;
  const StatusDot({required this.color, required this.label});
}

/// Sync status indicator
enum SyncState { synced, syncing, offline }

/// Dashboard header info
class DashboardHeaderInfo {
  final String userName;
  final String roleName;
  final String branchName;
  final SyncState syncState;
  final DateTime lastUpdated;

  const DashboardHeaderInfo({
    required this.userName,
    required this.roleName,
    required this.branchName,
    this.syncState = SyncState.synced,
    required this.lastUpdated,
  });
}

// ─── Product Models ────────────────────────────────────────────────────────

class Product {
  final String id;
  final String name;
  final String sku;
  final String category;
  final String? brand;
  final String? description;
  final double basePrice;
  final double currentPrice;
  final int stock;
  final int lowStockThreshold;
  final double rating;
  final int reviewCount;
  final StockLevel stockLevel;
  final List<String> tags;
  final List<String> imageUrls;
  final DateTime? lastSold;
  final int soldToday;

  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    this.brand,
    this.description,
    required this.basePrice,
    required this.currentPrice,
    required this.stock,
    this.lowStockThreshold = 10,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.stockLevel = StockLevel.inStock,
    this.tags = const [],
    this.imageUrls = const [],
    this.lastSold,
    this.soldToday = 0,
  });

  double get discountPercent =>
      basePrice > 0 ? ((basePrice - currentPrice) / basePrice * 100) : 0;
  bool get hasDiscount => currentPrice < basePrice;
  bool get isLowStock => stock <= lowStockThreshold && stock > 0;
  bool get isOutOfStock => stock <= 0;
}

class ProductFilter {
  final String? searchQuery;
  final String? category;
  final StockLevel? stockLevel;
  final double? minPrice;
  final double? maxPrice;
  final List<String> tags;

  const ProductFilter({
    this.searchQuery,
    this.category,
    this.stockLevel,
    this.minPrice,
    this.maxPrice,
    this.tags = const [],
  });
}

// ─── Vehicle / Fleet Models ────────────────────────────────────────────────

class Vehicle {
  final String id;
  final String plateNumber;
  final String make;
  final String model;
  final int year;
  final VehicleStatus status;
  final String? assignedDriverId;
  final String? assignedDriverName;
  final String? zone;
  final double fuelLevel;
  final double distanceToday;
  final int deliveriesToday;
  final int deliveriesTarget;
  final double onTimeRate;
  final int capacityKg;
  final DateTime? lastMaintenance;
  final double? nextServiceKm;

  const Vehicle({
    required this.id,
    required this.plateNumber,
    required this.make,
    required this.model,
    required this.year,
    this.status = VehicleStatus.active,
    this.assignedDriverId,
    this.assignedDriverName,
    this.zone,
    this.fuelLevel = 0.0,
    this.distanceToday = 0.0,
    this.deliveriesToday = 0,
    this.deliveriesTarget = 0,
    this.onTimeRate = 0.0,
    this.capacityKg = 0,
    this.lastMaintenance,
    this.nextServiceKm,
  });

  bool get isAssigned => assignedDriverId != null;
  bool get needsMaintenance =>
      nextServiceKm != null && nextServiceKm! <= 200;
  IconData get typeIcon {
    if (capacityKg > 2000) return Icons.local_shipping;
    if (capacityKg > 1000) return Icons.airport_shuttle;
    if (capacityKg > 500) return Icons.directions_car;
    return Icons.two_wheeler;
  }
}

class MaintenanceRecord {
  final String id;
  final String vehicleId;
  final String serviceType;
  final DateTime date;
  final double cost;
  final String? notes;
  final bool isUrgent;

  const MaintenanceRecord({
    required this.id,
    required this.vehicleId,
    required this.serviceType,
    required this.date,
    required this.cost,
    this.notes,
    this.isUrgent = false,
  });
}

class FuelEntry {
  final String id;
  final String vehicleId;
  final double liters;
  final double cost;
  final double odometer;
  final DateTime date;

  const FuelEntry({
    required this.id,
    required this.vehicleId,
    required this.liters,
    required this.cost,
    required this.odometer,
    required this.date,
  });
}

// ─── Tab / Credit Models ───────────────────────────────────────────────────

class CustomerTab {
  final String id;
  final String tabNumber;
  final String customerName;
  final double creditLimit;
  final double amountUsed;
  final TabStatus status;
  final double customerRating;
  final DateTime createdAt;
  final DateTime? nextPaymentDate;
  final double nextPaymentAmount;
  final bool autoPayEnabled;

  const CustomerTab({
    required this.id,
    required this.tabNumber,
    required this.customerName,
    required this.creditLimit,
    required this.amountUsed,
    this.status = TabStatus.active,
    this.customerRating = 0.0,
    required this.createdAt,
    this.nextPaymentDate,
    this.nextPaymentAmount = 0.0,
    this.autoPayEnabled = false,
  });

  double get availableCredit => creditLimit - amountUsed;
  double get utilizationPercent =>
      creditLimit > 0 ? (amountUsed / creditLimit * 100) : 0;
  bool get isOverdue => status == TabStatus.overdue;
  bool get isAtLimit => amountUsed >= creditLimit;
}

class TabTransaction {
  final String id;
  final String tabId;
  final String description;
  final double amount;
  final bool isPayment;
  final String category;
  final DateTime date;

  const TabTransaction({
    required this.id,
    required this.tabId,
    required this.description,
    required this.amount,
    required this.isPayment,
    this.category = '',
    required this.date,
  });
}

// ─── Discount Models ───────────────────────────────────────────────────────

class DiscountTier {
  final String id;
  final String name;
  final String? code;
  final String? description;
  final DiscountType type;
  final DiscountStatus status;
  final double value;
  final double? minimumPurchase;
  final double? maximumDiscount;
  final String productScope;
  final int customerCount;
  final double revenueImpact;
  final DateTime? startDate;
  final DateTime? endDate;

  const DiscountTier({
    required this.id,
    required this.name,
    this.code,
    this.description,
    required this.type,
    this.status = DiscountStatus.active,
    required this.value,
    this.minimumPurchase,
    this.maximumDiscount,
    this.productScope = 'All',
    this.customerCount = 0,
    this.revenueImpact = 0.0,
    this.startDate,
    this.endDate,
  });

  String get valueDisplay {
    switch (type) {
      case DiscountType.percentage:
        return '${value.toStringAsFixed(0)}% off';
      case DiscountType.fixedAmount:
        return '₵${value.toStringAsFixed(0)} off';
      case DiscountType.buyXGetY:
        return 'Buy ${value.toInt()} Get 1';
    }
  }
}

// ─── Staff Models ──────────────────────────────────────────────────────────

class StaffMember {
  final String id;
  final String name;
  final String role;
  final String department;
  final String? branch;
  final StaffStatus status;
  final double rating;
  final int reviewCount;
  final DateTime joinedDate;
  final double hoursThisWeek;
  final double hoursTarget;
  final int tasksCompleted;
  final int tasksTotal;
  final String? vehicleId;
  final String? email;
  final String? phone;

  const StaffMember({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    this.branch,
    this.status = StaffStatus.online,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.joinedDate,
    this.hoursThisWeek = 0.0,
    this.hoursTarget = 40.0,
    this.tasksCompleted = 0,
    this.tasksTotal = 0,
    this.vehicleId,
    this.email,
    this.phone,
  });

  double get productivity =>
      tasksTotal > 0 ? (tasksCompleted / tasksTotal * 100) : 0;
}

// ─── Places Models ─────────────────────────────────────────────────────────

class Place {
  final String id;
  final String name;
  final PlaceType type;
  final PlaceVisibility visibility;
  final String? address;
  final String? area;
  final double rating;
  final int reviewCount;
  final int staffCount;
  final int productCount;
  final String? hoursDisplay;

  const Place({
    required this.id,
    required this.name,
    required this.type,
    this.visibility = PlaceVisibility.public,
    this.address,
    this.area,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.staffCount = 0,
    this.productCount = 0,
    this.hoursDisplay,
  });

  IconData get typeIcon {
    switch (type) {
      case PlaceType.retail:
        return Icons.storefront;
      case PlaceType.warehouse:
        return Icons.warehouse;
      case PlaceType.office:
        return Icons.business;
      case PlaceType.home:
        return Icons.home;
      case PlaceType.custom:
        return Icons.place;
    }
  }
}

// ─── Delivery Zone Models ──────────────────────────────────────────────────

class DeliveryZone {
  final String id;
  final String name;
  final ZoneStatus status;
  final double fee;
  final double minimumOrder;
  final String estimatedTime;
  final int vehicleCount;
  final int dailyDeliveries;
  final double coverageKm2;
  final int populationServed;

  const DeliveryZone({
    required this.id,
    required this.name,
    this.status = ZoneStatus.active,
    required this.fee,
    this.minimumOrder = 0.0,
    this.estimatedTime = '',
    this.vehicleCount = 0,
    this.dailyDeliveries = 0,
    this.coverageKm2 = 0.0,
    this.populationServed = 0,
  });
}

// ─── Vehicle Band Models ───────────────────────────────────────────────────

class VehicleBand {
  final String id;
  final String name;
  final String purpose;
  final int vehicleCount;
  final double utilization;
  final bool isActive;
  final List<String> vehicleIds;
  final int maxCapacity;
  final double maintenanceCostMonthly;

  const VehicleBand({
    required this.id,
    required this.name,
    this.purpose = '',
    this.vehicleCount = 0,
    this.utilization = 0.0,
    this.isActive = true,
    this.vehicleIds = const [],
    this.maxCapacity = 12,
    this.maintenanceCostMonthly = 0.0,
  });

  BandUtilization get utilizationLevel {
    if (utilization >= 90) return BandUtilization.critical;
    if (utilization >= 70) return BandUtilization.optimal;
    if (utilization >= 40) return BandUtilization.low;
    return BandUtilization.low;
  }
}

// ─── Branch Models ─────────────────────────────────────────────────────────

class Branch {
  final String id;
  final String name;
  final String type;
  final BranchStatus status;
  final String? managerName;
  final double rating;
  final int staffCount;
  final int vehicleCount;
  final double monthlyRevenue;
  final DateTime? lastSync;
  final String? area;

  const Branch({
    required this.id,
    required this.name,
    required this.type,
    this.status = BranchStatus.online,
    this.managerName,
    this.rating = 0.0,
    this.staffCount = 0,
    this.vehicleCount = 0,
    this.monthlyRevenue = 0.0,
    this.lastSync,
    this.area,
  });

  Color get statusColor {
    switch (status) {
      case BranchStatus.online:
        return const Color(0xFF10B981);
      case BranchStatus.offline:
        return const Color(0xFFEF4444);
      case BranchStatus.maintenance:
        return const Color(0xFFF59E0B);
    }
  }
}

// ─── Campaign Models ───────────────────────────────────────────────────────

class Campaign {
  final String id;
  final String name;
  final CampaignType type;
  final CampaignGoal goal;
  final CampaignStatus status;
  final double budget;
  final double spent;
  final int reach;
  final int conversions;
  final double roi;
  final DateTime? startDate;
  final DateTime? endDate;

  const Campaign({
    required this.id,
    required this.name,
    required this.type,
    required this.goal,
    this.status = CampaignStatus.active,
    this.budget = 0.0,
    this.spent = 0.0,
    this.reach = 0,
    this.conversions = 0,
    this.roi = 0.0,
    this.startDate,
    this.endDate,
  });

  double get budgetUtilization =>
      budget > 0 ? (spent / budget * 100) : 0;
  double get conversionRate =>
      reach > 0 ? (conversions / reach * 100) : 0;
  int get daysLeft => endDate != null
      ? endDate!.difference(DateTime.now()).inDays
      : 0;
}

// ─── Social / Post Models ──────────────────────────────────────────────────

class SocialPost {
  final String id;
  final String content;
  final PostStatus status;
  final List<SocialPlatform> platforms;
  final int likes;
  final int comments;
  final int shares;
  final int reach;
  final double engagementRate;
  final DateTime? publishDate;
  final DateTime? scheduledDate;
  final bool hasMedia;
  final String? mediaType;

  const SocialPost({
    required this.id,
    required this.content,
    this.status = PostStatus.draft,
    this.platforms = const [],
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.reach = 0,
    this.engagementRate = 0.0,
    this.publishDate,
    this.scheduledDate,
    this.hasMedia = false,
    this.mediaType,
  });

  int get totalEngagement => likes + comments + shares;
}

// ─── Connection Models ─────────────────────────────────────────────────────

class Connection {
  final String id;
  final String name;
  final ConnectionType type;
  final ConnectionStatus status;
  final String? category;
  final double rating;
  final double strengthPercent;
  final DateTime? connectedSince;
  final String? lastInteraction;
  final int totalOrders;
  final double totalValue;

  const Connection({
    required this.id,
    required this.name,
    required this.type,
    this.status = ConnectionStatus.active,
    this.category,
    this.rating = 0.0,
    this.strengthPercent = 0.0,
    this.connectedSince,
    this.lastInteraction,
    this.totalOrders = 0,
    this.totalValue = 0.0,
  });

  Color get statusColor {
    switch (status) {
      case ConnectionStatus.active:
        return const Color(0xFF10B981);
      case ConnectionStatus.pending:
        return const Color(0xFFF59E0B);
      case ConnectionStatus.blocked:
        return const Color(0xFFEF4444);
    }
  }
}

// ─── Audit Log Models ──────────────────────────────────────────────────────

class AuditEntry {
  final String id;
  final AuditAction action;
  final AuditOutcome outcome;
  final String description;
  final String userName;
  final String userRole;
  final String entityType;
  final String? entityId;
  final DateTime timestamp;
  final String? ipAddress;
  final String? deviceInfo;
  final Map<String, String>? changesBefore;
  final Map<String, String>? changesAfter;

  const AuditEntry({
    required this.id,
    required this.action,
    this.outcome = AuditOutcome.success,
    required this.description,
    required this.userName,
    required this.userRole,
    required this.entityType,
    this.entityId,
    required this.timestamp,
    this.ipAddress,
    this.deviceInfo,
    this.changesBefore,
    this.changesAfter,
  });

  Color get outcomeColor {
    switch (outcome) {
      case AuditOutcome.success:
        return const Color(0xFF10B981);
      case AuditOutcome.failure:
        return const Color(0xFFEF4444);
      case AuditOutcome.suspicious:
        return const Color(0xFFF59E0B);
    }
  }

  IconData get actionIcon {
    switch (action) {
      case AuditAction.create:
        return Icons.add_circle_outline;
      case AuditAction.read:
        return Icons.visibility;
      case AuditAction.update:
        return Icons.edit;
      case AuditAction.delete:
        return Icons.delete_outline;
      case AuditAction.login:
        return Icons.login;
      case AuditAction.export:
        return Icons.file_download;
      case AuditAction.import_:
        return Icons.file_upload;
    }
  }
}

// ─── Outlook / Analytics Models ────────────────────────────────────────────

class KPIMetric {
  final String label;
  final String value;
  final String? previousValue;
  final double changePercent;
  final bool isPositive;
  final IconData icon;

  const KPIMetric({
    required this.label,
    required this.value,
    this.previousValue,
    this.changePercent = 0.0,
    this.isPositive = true,
    required this.icon,
  });
}

class AIInsight {
  final String title;
  final String description;
  final String recommendation;
  final AlertPriority priority;
  final String? impact;
  final IconData icon;

  const AIInsight({
    required this.title,
    required this.description,
    required this.recommendation,
    this.priority = AlertPriority.normal,
    this.impact,
    required this.icon,
  });
}

// ─── Q-Points Models ───────────────────────────────────────────────────────

class QPointsBalance {
  final int available;
  final int lifetime;
  final int redeemed;
  final int pending;
  final String tier;
  final int expiringPoints;
  final int daysToExpiry;
  final int onHold;
  final int reserved;
  final double exchangeRate;
  final int earnedThisMonth;
  final int spentThisMonth;
  final int expiringAmount;
  final DateTime? expiringDate;

  const QPointsBalance({
    required this.available,
    this.lifetime = 0,
    this.redeemed = 0,
    this.pending = 0,
    this.tier = 'Bronze',
    this.expiringPoints = 0,
    this.daysToExpiry = 0,
    this.onHold = 0,
    this.reserved = 0,
    this.exchangeRate = 0.085,
    this.earnedThisMonth = 0,
    this.spentThisMonth = 0,
    this.expiringAmount = 0,
    this.expiringDate,
  });

  double get cashValue => available * exchangeRate;
  int get total => available + onHold + reserved;
}

class QPointsTransaction {
  final String id;
  final QPointsTransactionType type;
  final QPointsTransactionStatus status;
  final int amount;
  final String description;
  final String? relatedId;
  final DateTime date;
  final String? source;

  const QPointsTransaction({
    required this.id,
    required this.type,
    this.status = QPointsTransactionStatus.completed,
    required this.amount,
    required this.description,
    this.relatedId,
    required this.date,
    this.source,
  });

  bool get isEarning =>
      type == QPointsTransactionType.earned ||
      type == QPointsTransactionType.bonus;

  int get points => amount;

  Color get typeColor {
    switch (type) {
      case QPointsTransactionType.earned:
        return const Color(0xFF10B981);
      case QPointsTransactionType.redeemed:
        return const Color(0xFF8B5CF6);
      case QPointsTransactionType.expired:
        return const Color(0xFFEF4444);
      case QPointsTransactionType.bonus:
        return const Color(0xFFFFD700);
      case QPointsTransactionType.transferred:
        return const Color(0xFF3B82F6);
    }
  }
}

// ─── My Activity / Task Models ─────────────────────────────────────────────

class UserTask {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final DateTime? dueDate;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final List<String> tags;
  final double progress;
  final String assignee;
  final String priority;
  final String? assignedBy;
  final List<TaskChecklistItem> checklist;

  const UserTask({
    required this.id,
    required this.title,
    this.description = '',
    this.status = TaskStatus.todo,
    this.dueDate,
    this.startedAt,
    this.completedAt,
    this.tags = const [],
    this.progress = 0.0,
    this.assignee = 'Me',
    this.priority = 'medium',
    this.assignedBy,
    this.checklist = const [],
  });

  bool get isOverdue =>
      status != TaskStatus.completed &&
      dueDate != null &&
      dueDate!.isBefore(DateTime.now());
  int get completedChecklist =>
      checklist.where((c) => c.isCompleted).length;
}

class TaskChecklistItem {
  final String label;
  final bool isCompleted;

  const TaskChecklistItem({
    required this.label,
    this.isCompleted = false,
  });

  bool get isDone => isCompleted;
}

class UserGoal {
  final String id;
  final String title;
  final String? description;
  final GoalStatus status;
  final double progress;
  final String? target;
  final String? current;
  final String currentValue;
  final String targetValue;
  final String unit;
  final DateTime? dueDate;
  final DateTime? deadline;
  final String category;

  const UserGoal({
    required this.id,
    required this.title,
    this.description,
    this.status = GoalStatus.onTrack,
    this.progress = 0.0,
    this.target,
    this.current,
    this.currentValue = '',
    this.targetValue = '',
    this.unit = '',
    this.dueDate,
    this.deadline,
    this.category = 'Professional',
  });

  Color get statusColor {
    switch (status) {
      case GoalStatus.ahead:
        return const Color(0xFF10B981);
      case GoalStatus.onTrack:
        return const Color(0xFFF59E0B);
      case GoalStatus.atRisk:
        return const Color(0xFFF59E0B);
      case GoalStatus.behind:
        return const Color(0xFFEF4444);
      case GoalStatus.needsAttention:
        return const Color(0xFFEF4444);
      case GoalStatus.completed:
        return const Color(0xFF3B82F6);
    }
  }
}

class ActivityTimelineEntry {
  final String title;
  final String subtitle;
  final DateTime? timestamp;
  final String action;
  final String time;
  final String description;
  final bool isCompleted;
  final bool isCurrent;

  const ActivityTimelineEntry({
    this.title = '',
    this.subtitle = '',
    this.timestamp,
    this.action = '',
    this.time = '',
    this.description = '',
    this.isCompleted = false,
    this.isCurrent = false,
  });
}

// ─── Profile Models ────────────────────────────────────────────────────────

class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String displayName;
  final String title;
  final String company;
  final String department;
  final String? bio;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String? country;
  final double profileCompleteness;
  final double rating;
  final int reviewCount;
  final DateTime memberSince;
  final List<String> skills;
  final Map<String, String> socialLinks;
  final bool isVerified;
  final int connectionCount;

  const UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    this.title = '',
    this.company = '',
    this.department = '',
    this.bio,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.country,
    this.profileCompleteness = 0.0,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.memberSince,
    this.skills = const [],
    this.socialLinks = const {},
    this.isVerified = false,
    this.connectionCount = 0,
  });
}

// ─── Subscription Models ───────────────────────────────────────────────────

class SubscriptionInfo {
  final SubscriptionPlan plan;
  final double monthlyPrice;
  final bool isActive;
  final DateTime? renewalDate;
  final bool autoRenew;
  final int staffLimit;
  final int staffUsed;
  final double storageGB;
  final double storageUsedGB;
  final int apiCallLimit;
  final int apiCallsUsed;
  final double utilizationPercent;

  const SubscriptionInfo({
    required this.plan,
    required this.monthlyPrice,
    this.isActive = true,
    this.renewalDate,
    this.autoRenew = true,
    this.staffLimit = 50,
    this.staffUsed = 0,
    this.storageGB = 100,
    this.storageUsedGB = 0,
    this.apiCallLimit = 50000,
    this.apiCallsUsed = 0,
    this.utilizationPercent = 0.0,
  });

  String get planName {
    switch (plan) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.basic:
        return 'Basic';
      case SubscriptionPlan.premium:
        return 'Premium';
      case SubscriptionPlan.enterprise:
        return 'Enterprise';
    }
  }

  IconData get planIcon {
    switch (plan) {
      case SubscriptionPlan.free:
        return Icons.star_border;
      case SubscriptionPlan.basic:
        return Icons.star_half;
      case SubscriptionPlan.premium:
        return Icons.diamond;
      case SubscriptionPlan.enterprise:
        return Icons.workspace_premium;
    }
  }

  int get daysUntilRenewal =>
      renewalDate != null
          ? renewalDate!.difference(DateTime.now()).inDays
          : 0;
}

// ─── Interest Models ───────────────────────────────────────────────────────

class UserInterest {
  final String id;
  final String name;
  final String emoji;
  final int updateCount;
  final bool isFollowing;
  final String? category;

  const UserInterest({
    required this.id,
    required this.name,
    required this.emoji,
    this.updateCount = 0,
    this.isFollowing = true,
    this.category,
  });
}

class InterestRecommendation {
  final String name;
  final int followerGrowth;
  final int matchPercent;

  const InterestRecommendation({
    required this.name,
    required this.followerGrowth,
    required this.matchPercent,
  });
}
