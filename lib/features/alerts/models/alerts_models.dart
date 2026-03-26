/// Alerts Module — Data Models
/// Unified incident resolution tracking system
/// Module Color: Red (0xFFEF4444)
/// Visibility: All roles EXCEPT Owner

// ═══════════════════════════════════════════
// ENUMS
// ═══════════════════════════════════════════

/// Priority levels for alerts
enum AlertPriority { critical, high, medium, low }

/// Alert lifecycle status
enum AlertStatus {
  // Pending statuses
  newAlert,
  assigned,
  inProgress,
  escalated,
  // Resolved statuses
  resolved,
  verified,
  closed,
  archived,
}

/// Issue category taxonomy
enum AlertCategory {
  payment,
  shipment,
  system,
  driverRide,
  returnRefund,
  account,
  security,
  other,
}

/// Payment sub-types
enum PaymentSubType { doubleCharge, failed, refundDelay, wrongAmount, unauthorised }

/// Shipment sub-types
enum ShipmentSubType { delayed, damaged, lost, wrongAddress, misdelivered }

/// System sub-types
enum SystemSubType { outage, slowPerformance, dataError, syncFailure, apiError }

/// Resolution method options
enum ResolutionMethod { fixed, workaround, cannotReproduce, duplicate, byDesign, wontFix }

/// Activity event types on timeline
enum ActivityEventType {
  created,
  assigned,
  commented,
  statusChanged,
  fileAttached,
  escalated,
  resolved,
  verified,
}

/// Dashboard tab segments
enum AlertDashboardTab { pending, resolved, all }

/// Time filter presets
enum TimeFilter { last24h, last7d, last30d, thisMonth, custom }

/// Notification channel options
enum NotificationChannel { push, email, sms, inApp }

/// Template types
enum AlertTemplateType { resolution, alert, communication, workflow }

/// Sentiment categories (AI)
enum AlertSentiment { negative, urgent, confused, neutral }

/// Complexity levels (AI)
enum AlertComplexity { simple, medium, complex }

/// Sort options for search
enum AlertSortOption { relevance, date, priority, assignee }

/// Analytics time range
enum AnalyticsRange { daily, weekly, monthly, quarterly }

/// Knowledge base item type
enum KnowledgeItemType { pastResolution, article, communitySolution }

/// Bulk action types
enum BulkActionType { assign, changeStatus, addTags, export, merge }

/// Customer notification method
enum CustomerNotifyMethod { sms, email, inApp, none }

/// Verification status
enum VerificationStatus { verified, pendingReview, rejected }

/// Escalation path level
enum EscalationLevel { team, branch, regional, executive }

/// SLA status
enum SlaStatus { onTrack, atRisk, breached }

// ═══════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════

/// Core alert model — single source of truth
class AlertItem {
  final String id;
  final String title;
  final String description;
  final AlertPriority priority;
  final AlertStatus status;
  final AlertCategory category;
  final String? subCategory;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? assigneeId;
  final String? assigneeName;
  final String? assigneeRole;
  final String? assigneeAvatar;
  final List<String> tags;
  final List<AlertAttachment> attachments;
  final List<ActivityEvent> timeline;
  final AlertResolution? resolution;
  final AlertSlaInfo? slaInfo;
  final AlertTechnicalDetails? technicalDetails;
  final bool isBookmarked;

  const AlertItem({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.category,
    this.subCategory,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.assigneeId,
    this.assigneeName,
    this.assigneeRole,
    this.assigneeAvatar,
    this.tags = const [],
    this.attachments = const [],
    this.timeline = const [],
    this.resolution,
    this.slaInfo,
    this.technicalDetails,
    this.isBookmarked = false,
  });

  bool get isPending =>
      status == AlertStatus.newAlert ||
      status == AlertStatus.assigned ||
      status == AlertStatus.inProgress ||
      status == AlertStatus.escalated;

  bool get isResolved =>
      status == AlertStatus.resolved ||
      status == AlertStatus.verified ||
      status == AlertStatus.closed ||
      status == AlertStatus.archived;

  String get priorityLabel {
    switch (priority) {
      case AlertPriority.critical:
        return '🚨 CRITICAL';
      case AlertPriority.high:
        return '🔥 HIGH';
      case AlertPriority.medium:
        return '⚠️ MEDIUM';
      case AlertPriority.low:
        return 'ℹ️ LOW';
    }
  }

  String get statusLabel {
    switch (status) {
      case AlertStatus.newAlert:
        return 'New';
      case AlertStatus.assigned:
        return 'Assigned';
      case AlertStatus.inProgress:
        return 'In Progress';
      case AlertStatus.escalated:
        return 'Escalated';
      case AlertStatus.resolved:
        return 'Resolved';
      case AlertStatus.verified:
        return 'Verified';
      case AlertStatus.closed:
        return 'Closed';
      case AlertStatus.archived:
        return 'Archived';
    }
  }

  String get categoryEmoji {
    switch (category) {
      case AlertCategory.payment:
        return '💳';
      case AlertCategory.shipment:
        return '📦';
      case AlertCategory.system:
        return '⚙️';
      case AlertCategory.driverRide:
        return '🚗';
      case AlertCategory.returnRefund:
        return '↩️';
      case AlertCategory.account:
        return '👤';
      case AlertCategory.security:
        return '🔒';
      case AlertCategory.other:
        return '📋';
    }
  }

  String get categoryLabel {
    switch (category) {
      case AlertCategory.payment:
        return 'Payment';
      case AlertCategory.shipment:
        return 'Shipment';
      case AlertCategory.system:
        return 'System';
      case AlertCategory.driverRide:
        return 'Driver/Ride';
      case AlertCategory.returnRefund:
        return 'Return/Refund';
      case AlertCategory.account:
        return 'Account';
      case AlertCategory.security:
        return 'Security';
      case AlertCategory.other:
        return 'Other';
    }
  }
}

/// File/image attachment
class AlertAttachment {
  final String id;
  final String name;
  final String url;
  final String type; // image, pdf, doc
  final int sizeBytes;
  final DateTime uploadedAt;

  const AlertAttachment({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.sizeBytes,
    required this.uploadedAt,
  });
}

/// Single activity event on the timeline
class ActivityEvent {
  final String id;
  final ActivityEventType type;
  final String actorName;
  final String? actorAvatar;
  final String description;
  final DateTime timestamp;
  final String? details;

  const ActivityEvent({
    required this.id,
    required this.type,
    required this.actorName,
    this.actorAvatar,
    required this.description,
    required this.timestamp,
    this.details,
  });

  String get typeEmoji {
    switch (type) {
      case ActivityEventType.created:
        return '📢';
      case ActivityEventType.assigned:
        return '👤';
      case ActivityEventType.commented:
        return '💬';
      case ActivityEventType.statusChanged:
        return '🔄';
      case ActivityEventType.fileAttached:
        return '📎';
      case ActivityEventType.escalated:
        return '⚠️';
      case ActivityEventType.resolved:
        return '✅';
      case ActivityEventType.verified:
        return '🔒';
    }
  }
}

/// Resolution data for a resolved alert
class AlertResolution {
  final ResolutionMethod method;
  final String summary;
  final String? details;
  final String? rootCause;
  final String? preventionMeasures;
  final String resolverName;
  final String? resolverAvatar;
  final DateTime resolvedAt;
  final VerificationStatus verificationStatus;
  final String? verifierName;
  final CustomerNotifyMethod customerNotified;
  final int? qualityScore; // 0-100

  const AlertResolution({
    required this.method,
    required this.summary,
    this.details,
    this.rootCause,
    this.preventionMeasures,
    required this.resolverName,
    this.resolverAvatar,
    required this.resolvedAt,
    this.verificationStatus = VerificationStatus.pendingReview,
    this.verifierName,
    this.customerNotified = CustomerNotifyMethod.none,
    this.qualityScore,
  });

  String get methodLabel {
    switch (method) {
      case ResolutionMethod.fixed:
        return 'Fixed';
      case ResolutionMethod.workaround:
        return 'Workaround';
      case ResolutionMethod.cannotReproduce:
        return 'Cannot Reproduce';
      case ResolutionMethod.duplicate:
        return 'Duplicate';
      case ResolutionMethod.byDesign:
        return 'By Design';
      case ResolutionMethod.wontFix:
        return "Won't Fix";
    }
  }
}

/// SLA tracking info
class AlertSlaInfo {
  final Duration targetTime;
  final DateTime deadline;
  final SlaStatus status;

  const AlertSlaInfo({
    required this.targetTime,
    required this.deadline,
    required this.status,
  });

  Duration get remainingTime => deadline.difference(DateTime.now());

  double get progressPercent {
    final elapsed = DateTime.now().difference(deadline.subtract(targetTime));
    return (elapsed.inMinutes / targetTime.inMinutes).clamp(0.0, 1.0);
  }
}

/// Technical debugging info
class AlertTechnicalDetails {
  final String? errorCode;
  final List<String> transactionIds;
  final String? userId;
  final String? deviceInfo;
  final String? appVersion;
  final Map<String, String> additionalData;

  const AlertTechnicalDetails({
    this.errorCode,
    this.transactionIds = const [],
    this.userId,
    this.deviceInfo,
    this.appVersion,
    this.additionalData = const {},
  });
}

/// Issue distribution for donut chart
class IssueDistribution {
  final AlertCategory category;
  final double percentage;
  final int count;

  const IssueDistribution({
    required this.category,
    required this.percentage,
    required this.count,
  });
}

/// Staff member for assignment
class AlertStaffMember {
  final String id;
  final String name;
  final String role;
  final String? avatar;
  final int activeAlerts;
  final bool isAvailable;
  final String? branch;

  const AlertStaffMember({
    required this.id,
    required this.name,
    required this.role,
    this.avatar,
    required this.activeAlerts,
    required this.isAvailable,
    this.branch,
  });
}

/// Filter preset
class AlertFilterPreset {
  final String id;
  final String name;
  final bool isDefault;
  final bool isShared;
  final Map<String, dynamic> filters;

  const AlertFilterPreset({
    required this.id,
    required this.name,
    this.isDefault = false,
    this.isShared = false,
    this.filters = const {},
  });
}

/// Alert template
class AlertTemplate {
  final String id;
  final String name;
  final AlertTemplateType type;
  final String content;
  final List<String> variables;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final int usageCount;

  const AlertTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.content,
    this.variables = const [],
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.usageCount = 0,
  });

  String get typeLabel {
    switch (type) {
      case AlertTemplateType.resolution:
        return '✅ Resolution';
      case AlertTemplateType.alert:
        return '🚨 Alert';
      case AlertTemplateType.communication:
        return '📧 Communication';
      case AlertTemplateType.workflow:
        return '🔄 Workflow';
    }
  }
}

/// Knowledge base item
class KnowledgeBaseItem {
  final String id;
  final String title;
  final String summary;
  final KnowledgeItemType type;
  final double similarityScore;
  final int helpfulCount;
  final DateTime createdAt;
  final String? source;

  const KnowledgeBaseItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.type,
    required this.similarityScore,
    this.helpfulCount = 0,
    required this.createdAt,
    this.source,
  });
}

/// Analytics data point
class AlertAnalyticsPoint {
  final String label;
  final int count;
  final double? value;

  const AlertAnalyticsPoint({
    required this.label,
    required this.count,
    this.value,
  });
}

/// Resolver leaderboard entry
class ResolverStats {
  final String name;
  final String role;
  final int resolvedCount;
  final Duration avgResolutionTime;
  final double satisfactionScore;

  const ResolverStats({
    required this.name,
    required this.role,
    required this.resolvedCount,
    required this.avgResolutionTime,
    required this.satisfactionScore,
  });
}

/// Escalation path configuration
class EscalationPath {
  final EscalationLevel level;
  final Duration afterDuration;
  final String targetRole;
  final String? targetPerson;

  const EscalationPath({
    required this.level,
    required this.afterDuration,
    required this.targetRole,
    this.targetPerson,
  });
}

/// Workflow auto-assignment rule
class AssignmentRule {
  final String id;
  final AlertCategory category;
  final AlertPriority? priority;
  final String assignToRole;
  final String? assignToPerson;
  final bool isActive;

  const AssignmentRule({
    required this.id,
    required this.category,
    this.priority,
    required this.assignToRole,
    this.assignToPerson,
    this.isActive = true,
  });
}

/// Recent search entry
class RecentSearch {
  final String query;
  final DateTime timestamp;
  final int resultCount;

  const RecentSearch({
    required this.query,
    required this.timestamp,
    required this.resultCount,
  });
}

/// Saved search with filters
class SavedSearch {
  final String id;
  final String name;
  final String query;
  final Map<String, dynamic> filters;
  final DateTime createdAt;

  const SavedSearch({
    required this.id,
    required this.name,
    required this.query,
    this.filters = const {},
    required this.createdAt,
  });
}
