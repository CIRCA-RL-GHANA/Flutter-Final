/// ═══════════════════════════════════════════════════════════════════════════
/// LIVE MODULE — Data Models
/// Comprehensive models for real-time operations center:
/// Orders, Packages, Returns, Drivers, Rides, Incidents, Analytics,
/// Verification, Emergency, Settings, Notifications
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

// ─── Enums ──────────────────────────────────────────────────────────────────

/// Order priority level
enum OrderPriority { urgent, normal, flexible, scheduled }

/// Order processing status
enum LiveOrderStatus {
  newOrder,
  assigned,
  preparing,
  readyForPickup,
  inTransit,
  delivered,
  selfPickup,
  held,
  cancelled,
  overdue,
}

/// Package status
enum PackageStatus { created, active, inTransit, delivered, returned, cancelled }

/// Package type
enum PackageType { standard, fragile, refrigerated, highValue, confidential }

/// Return review status
enum LiveReturnStatus { pending, underReview, approved, partiallyApproved, rejected, escalated }

/// Return rejection reason
enum RejectionReason {
  damageAfterDelivery,
  itemNotAsDescribed,
  missingPackaging,
  returnPeriodExpired,
  signsOfMisuse,
  serialMismatch,
  nonReturnable,
  insufficientEvidence,
  customizedProduct,
  other,
}

/// Adjudication option
enum AdjudicationOption { approve, partialApprove, offerReplacement, offerStoreCredit, requestMoreInfo, reject }

/// Driver availability
enum DriverAvailability { online, offline, onBreak }

/// Driver type specialization
enum LiveDriverType { shopLogistics, transport }

/// Verification method
enum VerificationMethod { biometric, pin, governmentId, phoneDigits, securityQuestion, qrCode }

/// Stop type in a package
enum StopType { delivery, returnPickup, customStop }

/// Stop status
enum StopStatus { completed, inProgress, upcoming, skipped, failed }

/// Ride status for transport driver
enum LiveRideStatus {
  available,
  accepted,
  pickingUp,
  arrived,
  inProgress,
  completed,
  cancelled,
}

/// Incident type
enum IncidentType {
  theftRobbery,
  vehicleAccident,
  customerDispute,
  packageDamageLoss,
  harassment,
  medicalEmergency,
  other,
}

/// Incident severity
enum IncidentSeverity { minor, major, critical }

/// Emergency contact type
enum EmergencyContactType { police, security, branchManager, personalContact }

/// Notification category for LIVE module
enum LiveNotificationType { orderAlert, driverUpdate, returnRequest, securityAlert, performanceMilestone }

/// Analytics time period
enum AnalyticsPeriod { today, yesterday, thisWeek, thisMonth, last30Days, custom }

/// Default verification preset
enum DefaultVerification { biometricOnly, pinOnly, biometricAndPin, photoSignature }

/// Widget state for the LIVE prompt widget
enum LiveWidgetState { activeOperations, quiet, emergency, offline }

/// Tab selection in live dashboard
enum LiveDashboardTab { orders, returns, packages }

/// Order sub-tab
enum OrderSubTab { newOrders, inProgress, ready, all }

/// Return sub-tab
enum ReturnSubTab { pending, underReview, resolved }

/// Package sub-tab
enum PackageSubTab { active, inTransit, delivered }

// ─── Order Models ───────────────────────────────────────────────────────────

/// A live order in the operations center
class LiveOrder {
  final String id;
  final String customerId;
  final String customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String? customerCompany;
  final double customerRating;
  final int customerOrderCount;
  final String deliveryAddress;
  final String? deliveryFloor;
  final String? deliveryReception;
  final String? accessCode;
  final String? parkingNote;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String paymentMethod;
  final LiveOrderStatus status;
  final OrderPriority priority;
  final String? customerNote;
  final String? assignedDriverId;
  final String? assignedDriverName;
  final double? driverDistanceMiles;
  final int? driverEtaMinutes;
  final int? prepTimeMinutes;
  final int? deliveryTimeMinutes;
  final DateTime createdAt;
  final List<OrderTimelineEntry> timeline;
  final bool requiresColdStorage;
  final bool requiresIdVerification;
  final bool isFragile;
  final double preparationProgress;

  const LiveOrder({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.customerCompany,
    this.customerRating = 4.5,
    this.customerOrderCount = 1,
    required this.deliveryAddress,
    this.deliveryFloor,
    this.deliveryReception,
    this.accessCode,
    this.parkingNote,
    required this.items,
    required this.subtotal,
    this.deliveryFee = 15.0,
    required this.total,
    this.paymentMethod = 'QPoints',
    this.status = LiveOrderStatus.newOrder,
    this.priority = OrderPriority.normal,
    this.customerNote,
    this.assignedDriverId,
    this.assignedDriverName,
    this.driverDistanceMiles,
    this.driverEtaMinutes,
    this.prepTimeMinutes,
    this.deliveryTimeMinutes,
    required this.createdAt,
    this.timeline = const [],
    this.requiresColdStorage = false,
    this.requiresIdVerification = false,
    this.isFragile = false,
    this.preparationProgress = 0.0,
  });

  bool get isOverdue {
    final elapsed = DateTime.now().difference(createdAt).inMinutes;
    return elapsed > 30 && status == LiveOrderStatus.newOrder;
  }

  String get timeSinceCreated {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min ago';
    return '${diff.inHours}h ago';
  }

  Color get priorityColor {
    switch (priority) {
      case OrderPriority.urgent:
        return const Color(0xFFEF4444);
      case OrderPriority.normal:
        return const Color(0xFFF59E0B);
      case OrderPriority.flexible:
        return const Color(0xFF10B981);
      case OrderPriority.scheduled:
        return const Color(0xFF3B82F6);
    }
  }
}

/// An item in a live order
class OrderItem {
  final String id;
  final String name;
  final String? sku;
  final String? serialNumber;
  final String? stockLocation;
  final double price;
  final int quantity;
  final String? imageUrl;
  final bool isVerified;

  const OrderItem({
    required this.id,
    required this.name,
    this.sku,
    this.serialNumber,
    this.stockLocation,
    required this.price,
    this.quantity = 1,
    this.imageUrl,
    this.isVerified = false,
  });
}

/// Timeline entry for an order
class OrderTimelineEntry {
  final String title;
  final DateTime timestamp;
  final bool isCompleted;
  final String? description;

  const OrderTimelineEntry({
    required this.title,
    required this.timestamp,
    this.isCompleted = true,
    this.description,
  });
}

// ─── Driver Models ──────────────────────────────────────────────────────────

/// A driver in the operations center
class LiveDriver {
  final String id;
  final String name;
  final String? avatarUrl;
  final double rating;
  final double completionRate;
  final double distanceMiles;
  final int etaToStoreMinutes;
  final int etaToCustomerMinutes;
  final List<String> specialties;
  final DriverAvailability availability;
  final LiveDriverType driverType;
  final int todayDeliveries;
  final int todayCompletedDeliveries;
  final int todayStopsCompleted;
  final int todayTotalStops;
  final double todayEarnings;
  final double efficiencyBonus;
  final double ratingImpact;
  final double onTimeRate;
  final int totalDeliveries;
  final double averageDeliveryTime;
  final double distanceEfficiency;
  final double totalEarnings;
  final int completedTrainingModules;
  final int totalTrainingModules;
  final Duration onlineTime;
  final Duration nextBreakIn;
  final List<DriverBadge> badges;
  final List<DriverFeedback> recentFeedback;
  final String? activePackageId;

  const LiveDriver({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.rating = 4.5,
    this.completionRate = 0.95,
    this.distanceMiles = 1.0,
    this.etaToStoreMinutes = 5,
    this.etaToCustomerMinutes = 15,
    this.specialties = const [],
    this.availability = DriverAvailability.online,
    this.driverType = LiveDriverType.shopLogistics,
    this.todayDeliveries = 0,
    this.todayCompletedDeliveries = 0,
    this.todayStopsCompleted = 0,
    this.todayTotalStops = 0,
    this.todayEarnings = 0.0,
    this.efficiencyBonus = 0.0,
    this.ratingImpact = 0.0,
    this.onTimeRate = 0.95,
    this.totalDeliveries = 0,
    this.averageDeliveryTime = 18.0,
    this.distanceEfficiency = 0.9,
    this.totalEarnings = 0.0,
    this.completedTrainingModules = 0,
    this.totalTrainingModules = 4,
    this.onlineTime = const Duration(hours: 3, minutes: 22),
    this.nextBreakIn = const Duration(minutes: 45),
    this.badges = const [],
    this.recentFeedback = const [],
    this.activePackageId,
  });
}

/// A badge/achievement for a driver
class DriverBadge {
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const DriverBadge({
    required this.name,
    required this.description,
    this.icon = Icons.emoji_events,
    this.color = const Color(0xFFFFD700),
  });
}

/// Customer feedback for a driver
class DriverFeedback {
  final String customerName;
  final String comment;
  final double rating;
  final DateTime date;

  const DriverFeedback({
    required this.customerName,
    required this.comment,
    this.rating = 5.0,
    required this.date,
  });
}

// ─── Package Models ─────────────────────────────────────────────────────────

/// A delivery/return package
class LivePackage {
  final String id;
  final String? driverId;
  final String? driverName;
  final double? driverRating;
  final PackageStatus status;
  final PackageType type;
  final List<PackageStop> stops;
  final int completedStops;
  final double totalDistanceMiles;
  final int estimatedTimeMinutes;
  final double driverEarnings;
  final double priorityBonus;
  final bool biometricRequired;
  final bool pinRequired;
  final String? fallbackPin;
  final bool signatureRequired;
  final bool photoRequired;
  final bool recordHandoff;
  final double insuranceCoverage;
  final int evidenceRetentionDays;
  final bool highValueItems;
  final bool ageRestricted;
  final DateTime createdAt;
  final double onTimeScore;
  final double distanceEfficiency;
  final double costPerMile;

  const LivePackage({
    required this.id,
    this.driverId,
    this.driverName,
    this.driverRating,
    this.status = PackageStatus.created,
    this.type = PackageType.standard,
    this.stops = const [],
    this.completedStops = 0,
    this.totalDistanceMiles = 0.0,
    this.estimatedTimeMinutes = 0,
    this.driverEarnings = 0.0,
    this.priorityBonus = 0.0,
    this.biometricRequired = false,
    this.pinRequired = false,
    this.fallbackPin,
    this.signatureRequired = false,
    this.photoRequired = false,
    this.recordHandoff = false,
    this.insuranceCoverage = 0.0,
    this.evidenceRetentionDays = 30,
    this.highValueItems = false,
    this.ageRestricted = false,
    required this.createdAt,
    this.onTimeScore = 0.92,
    this.distanceEfficiency = 0.87,
    this.costPerMile = 0.42,
  });

  int get totalStops => stops.length;
  String get progressText => '$completedStops/$totalStops';
}

/// A stop in a package route
class PackageStop {
  final String id;
  final int sequence;
  final StopType type;
  final StopStatus status;
  final String address;
  final String customerName;
  final String? orderId;
  final String? returnId;
  final String? itemDescription;
  final double distanceMiles;
  final int etaMinutes;
  final bool idVerificationRequired;
  final bool photoRequired;
  final bool signatureRequired;
  final String? specialNote;
  final DateTime? completedAt;
  final List<String> evidenceUrls;

  const PackageStop({
    required this.id,
    required this.sequence,
    required this.type,
    this.status = StopStatus.upcoming,
    required this.address,
    required this.customerName,
    this.orderId,
    this.returnId,
    this.itemDescription,
    this.distanceMiles = 1.0,
    this.etaMinutes = 10,
    this.idVerificationRequired = false,
    this.photoRequired = false,
    this.signatureRequired = false,
    this.specialNote,
    this.completedAt,
    this.evidenceUrls = const [],
  });
}

// ─── Return Models ──────────────────────────────────────────────────────────

/// A return request in the operations center
class LiveReturn {
  final String id;
  final String customerId;
  final String customerName;
  final double customerRating;
  final int customerReturnCount;
  final int customerTotalOrders;
  final double customerLifetimeValue;
  final String originalOrderId;
  final int daysSincePurchase;
  final String itemName;
  final String? itemModel;
  final String? serialNumber;
  final double itemPrice;
  final double restockingFee;
  final String reason;
  final String? reasonDetail;
  final LiveReturnStatus status;
  final String? reviewerName;
  final DateTime? reviewStartedAt;
  final Duration? videoEvidence;
  final Duration? voiceNote;
  final String? voiceNoteTranscript;
  final DateTime createdAt;
  final int? usageDays;

  const LiveReturn({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.customerRating = 4.5,
    this.customerReturnCount = 1,
    this.customerTotalOrders = 5,
    this.customerLifetimeValue = 500.0,
    required this.originalOrderId,
    this.daysSincePurchase = 5,
    required this.itemName,
    this.itemModel,
    this.serialNumber,
    required this.itemPrice,
    this.restockingFee = 0.0,
    required this.reason,
    this.reasonDetail,
    this.status = LiveReturnStatus.pending,
    this.reviewerName,
    this.reviewStartedAt,
    this.videoEvidence,
    this.voiceNote,
    this.voiceNoteTranscript,
    required this.createdAt,
    this.usageDays,
  });

  String get timeSinceCreated {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}min ago';
    return '${diff.inHours}h ago';
  }

  double get refundAmount => itemPrice - restockingFee;

  bool get hasVideo => videoEvidence != null;
  bool get hasVoiceNote => voiceNote != null;
}

// ─── Ride Models (Transport) ────────────────────────────────────────────────

/// A ride request for transport drivers
class LiveRide {
  final String id;
  final String passengerName;
  final double passengerRating;
  final int passengerRideCount;
  final String pickupAddress;
  final String dropoffAddress;
  final double distanceKm;
  final double fare;
  final double surgeMultiplier;
  final double tip;
  final int etaMinutes;
  final LiveRideStatus status;
  final String? preferredLanguage;
  final String? specialRequest;
  final String paymentMethod;
  final DateTime createdAt;
  final double? baseFare;
  final double? distanceCharge;
  final double? timeCharge;
  final double? surgeCharge;

  const LiveRide({
    required this.id,
    required this.passengerName,
    this.passengerRating = 4.5,
    this.passengerRideCount = 10,
    required this.pickupAddress,
    required this.dropoffAddress,
    this.distanceKm = 5.0,
    required this.fare,
    this.surgeMultiplier = 1.0,
    this.tip = 0.0,
    this.etaMinutes = 10,
    this.status = LiveRideStatus.available,
    this.preferredLanguage = 'English',
    this.specialRequest,
    this.paymentMethod = 'QPoints',
    required this.createdAt,
    this.baseFare,
    this.distanceCharge,
    this.timeCharge,
    this.surgeCharge,
  });
}

// ─── Incident & Emergency Models ────────────────────────────────────────────

/// An incident report
class LiveIncident {
  final String id;
  final IncidentType type;
  final IncidentSeverity severity;
  final String? description;
  final String? location;
  final DateTime dateTime;
  final List<String> peopleInvolved;
  final List<String> photoUrls;
  final List<String> videoUrls;
  final List<String> audioUrls;
  final List<String> documentUrls;
  final List<String> witnessStatements;
  final bool policeReportFiled;
  final bool insuranceNotified;
  final bool customerNotified;
  final bool managementInformed;
  final bool followUpRequired;

  const LiveIncident({
    required this.id,
    this.type = IncidentType.other,
    this.severity = IncidentSeverity.minor,
    this.description,
    this.location,
    required this.dateTime,
    this.peopleInvolved = const [],
    this.photoUrls = const [],
    this.videoUrls = const [],
    this.audioUrls = const [],
    this.documentUrls = const [],
    this.witnessStatements = const [],
    this.policeReportFiled = false,
    this.insuranceNotified = false,
    this.customerNotified = false,
    this.managementInformed = false,
    this.followUpRequired = false,
  });
}

/// An emergency contact entry
class EmergencyContact {
  final String name;
  final String phone;
  final EmergencyContactType type;
  final int? etaMinutes;
  final bool isNotified;

  const EmergencyContact({
    required this.name,
    required this.phone,
    required this.type,
    this.etaMinutes,
    this.isNotified = false,
  });
}

// ─── Analytics Models ───────────────────────────────────────────────────────

/// Operations overview metrics
class OperationsMetrics {
  final int activeDrivers;
  final int totalDrivers;
  final double avgResponseTimeMinutes;
  final double efficiencyScore;
  final double todayRevenue;
  final int ordersProcessed;
  final double avgFulfillmentTimeMinutes;
  final double customerRating;
  final double returnsRate;
  final double revenueChange;
  final double fulfillmentChange;
  final double efficiencyChange;
  final double ratingChange;

  const OperationsMetrics({
    this.activeDrivers = 3,
    this.totalDrivers = 5,
    this.avgResponseTimeMinutes = 3.2,
    this.efficiencyScore = 0.92,
    this.todayRevenue = 1245.0,
    this.ordersProcessed = 124,
    this.avgFulfillmentTimeMinutes = 18.0,
    this.customerRating = 4.7,
    this.returnsRate = 0.032,
    this.revenueChange = 1240.0,
    this.fulfillmentChange = -2.0,
    this.efficiencyChange = 0.03,
    this.ratingChange = 0.1,
  });
}

/// Predictive insight from AI
class PredictiveInsight {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const PredictiveInsight({
    required this.title,
    required this.description,
    this.icon = Icons.lightbulb_outline,
    this.color = const Color(0xFF3B82F6),
  });
}

/// Urgent action item
class UrgentAction {
  final String title;
  final String orderId;
  final int minutesOverdue;
  final List<String> actions;

  const UrgentAction({
    required this.title,
    required this.orderId,
    this.minutesOverdue = 0,
    this.actions = const [],
  });
}

/// Delivery demand zone for heat map
class DeliveryZone {
  final String name;
  final int orderCount;
  final String intensity; // 'hot', 'medium', 'cold'

  const DeliveryZone({
    required this.name,
    required this.orderCount,
    required this.intensity,
  });
}

/// Bottleneck alert
class BottleneckAlert {
  final String title;
  final String description;
  final IconData icon;

  const BottleneckAlert({
    required this.title,
    this.description = '',
    this.icon = Icons.warning_amber,
  });
}

// ─── Notification Models ────────────────────────────────────────────────────

/// A live notification
class LiveNotification {
  final String id;
  final LiveNotificationType type;
  final String title;
  final String body;
  final List<String> actions;
  final DateTime timestamp;
  final bool isRead;

  const LiveNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.actions = const [],
    required this.timestamp,
    this.isRead = false,
  });
}

// ─── Settings Models ────────────────────────────────────────────────────────

/// LIVE module automation settings
class LiveSettings {
  final bool autoAssignOrders;
  final double autoAssignMaxDistance;
  final bool autoCreateBundles;
  final double bundleRadius;
  final double bundleMinSavings;
  final bool autoApproveLowValueReturns;
  final double autoApproveMaxValue;
  final DefaultVerification defaultVerification;
  final double highValueThreshold;
  final int evidenceRetentionDays;
  final int maxSimultaneousPackages;
  final int breakEnforcementMinutes;
  final int breakAfterHours;
  final double minimumDriverRating;
  final double fulfillmentTimeTarget;
  final double customerRatingTarget;
  final double onTimeDeliveryTarget;

  const LiveSettings({
    this.autoAssignOrders = true,
    this.autoAssignMaxDistance = 5.0,
    this.autoCreateBundles = false,
    this.bundleRadius = 2.0,
    this.bundleMinSavings = 0.15,
    this.autoApproveLowValueReturns = true,
    this.autoApproveMaxValue = 50.0,
    this.defaultVerification = DefaultVerification.biometricAndPin,
    this.highValueThreshold = 1000.0,
    this.evidenceRetentionDays = 30,
    this.maxSimultaneousPackages = 3,
    this.breakEnforcementMinutes = 15,
    this.breakAfterHours = 4,
    this.minimumDriverRating = 4.0,
    this.fulfillmentTimeTarget = 20.0,
    this.customerRatingTarget = 4.5,
    this.onTimeDeliveryTarget = 0.95,
  });

  LiveSettings copyWith({
    bool? autoAssignOrders,
    double? autoAssignMaxDistance,
    bool? autoCreateBundles,
    double? bundleRadius,
    double? bundleMinSavings,
    bool? autoApproveLowValueReturns,
    double? autoApproveMaxValue,
    DefaultVerification? defaultVerification,
    double? highValueThreshold,
    int? evidenceRetentionDays,
    int? maxSimultaneousPackages,
    int? breakEnforcementMinutes,
    int? breakAfterHours,
    double? minimumDriverRating,
    double? fulfillmentTimeTarget,
    double? customerRatingTarget,
    double? onTimeDeliveryTarget,
  }) {
    return LiveSettings(
      autoAssignOrders: autoAssignOrders ?? this.autoAssignOrders,
      autoAssignMaxDistance: autoAssignMaxDistance ?? this.autoAssignMaxDistance,
      autoCreateBundles: autoCreateBundles ?? this.autoCreateBundles,
      bundleRadius: bundleRadius ?? this.bundleRadius,
      bundleMinSavings: bundleMinSavings ?? this.bundleMinSavings,
      autoApproveLowValueReturns: autoApproveLowValueReturns ?? this.autoApproveLowValueReturns,
      autoApproveMaxValue: autoApproveMaxValue ?? this.autoApproveMaxValue,
      defaultVerification: defaultVerification ?? this.defaultVerification,
      highValueThreshold: highValueThreshold ?? this.highValueThreshold,
      evidenceRetentionDays: evidenceRetentionDays ?? this.evidenceRetentionDays,
      maxSimultaneousPackages: maxSimultaneousPackages ?? this.maxSimultaneousPackages,
      breakEnforcementMinutes: breakEnforcementMinutes ?? this.breakEnforcementMinutes,
      breakAfterHours: breakAfterHours ?? this.breakAfterHours,
      minimumDriverRating: minimumDriverRating ?? this.minimumDriverRating,
      fulfillmentTimeTarget: fulfillmentTimeTarget ?? this.fulfillmentTimeTarget,
      customerRatingTarget: customerRatingTarget ?? this.customerRatingTarget,
      onTimeDeliveryTarget: onTimeDeliveryTarget ?? this.onTimeDeliveryTarget,
    );
  }
}

// ─── Transfer Models ────────────────────────────────────────────────────────

/// A multi-hop transfer request
class TransferRequest {
  final String packageId;
  final String fromDriverId;
  final String fromDriverName;
  final String? toDriverId;
  final String? toDriverName;
  final String reason;
  final String meetingPoint;
  final int remainingStops;
  final double remainingDistance;
  final int estimatedTime;
  final List<String> itemsToTransfer;
  final List<TransferStep> steps;

  const TransferRequest({
    required this.packageId,
    required this.fromDriverId,
    required this.fromDriverName,
    this.toDriverId,
    this.toDriverName,
    required this.reason,
    this.meetingPoint = '',
    this.remainingStops = 0,
    this.remainingDistance = 0.0,
    this.estimatedTime = 0,
    this.itemsToTransfer = const [],
    this.steps = const [],
  });
}

/// A step in the transfer handoff
class TransferStep {
  final int sequence;
  final String title;
  final bool isCompleted;
  final bool isActive;

  const TransferStep({
    required this.sequence,
    required this.title,
    this.isCompleted = false,
    this.isActive = false,
  });
}

// ─── Transport Earnings ─────────────────────────────────────────────────────

/// Transport driver earnings summary
class TransportEarnings {
  final int ridesCompleted;
  final double totalEarnings;
  final double surgeBonus;
  final double tips;
  final int qPointsEarned;
  final Duration onlineTime;

  const TransportEarnings({
    this.ridesCompleted = 7,
    this.totalEarnings = 186.40,
    this.surgeBonus = 24.50,
    this.tips = 32.0,
    this.qPointsEarned = 124,
    this.onlineTime = const Duration(hours: 4, minutes: 15),
  });
}
