/// Alerts Module — State Management & Demo Data
/// Unified incident resolution tracking system
/// Module Color: Red (0xFFEF4444)
/// API-first with fallback demo data pattern

import 'package:flutter/foundation.dart';
import '../models/alerts_models.dart';

class AlertsProvider extends ChangeNotifier {
  // ──── LOADING / ERROR STATE ───────────────────────────

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ──── GLOBAL STATE ────────────────────────────────────

  AlertDashboardTab _dashboardTab = AlertDashboardTab.pending;
  AlertDashboardTab get dashboardTab => _dashboardTab;
  void setDashboardTab(AlertDashboardTab tab) {
    _dashboardTab = tab;
    notifyListeners();
  }

  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  DateTime _lastSync = DateTime.now().subtract(const Duration(minutes: 3));
  DateTime get lastSync => _lastSync;
  void refreshSync() {
    _lastSync = DateTime.now();
    notifyListeners();
  }

  // ──── INIT ────────────────────────────────────────────

  Future<void> init() async {
    await loadAlerts();
  }

  Future<void> loadAlerts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // No dedicated alerts endpoint exists — populate from fallback
      _alerts = List.from(_fallbackAlerts);
    } catch (e) {
      debugPrint('AlertsProvider.loadAlerts error: $e');
      _errorMessage = e.toString();
      _alerts = List.from(_fallbackAlerts);
    } finally {
      _isLoading = false;
      _lastSync = DateTime.now();
      notifyListeners();
    }
  }

  // ──── ALERTS DATA ────────────────────────────────────

  List<AlertItem> _alerts = [];

  static final List<AlertItem> _fallbackAlerts = [
    // Pending alerts
    AlertItem(
      id: 'TX-2041',
      title: 'Payment Error - QPoints Debited Twice',
      description: 'Customer reports QPoints were debited twice for a single transaction. Amount: ₵245.00 each. Customer is requesting immediate refund of the duplicate charge.',
      priority: AlertPriority.high,
      status: AlertStatus.assigned,
      category: AlertCategory.payment,
      subCategory: 'Double Charge',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      createdBy: 'System',
      assigneeId: 'staff-1',
      assigneeName: 'Jane Smith',
      assigneeRole: 'Administrator',
      tags: ['urgent', 'customer-waiting'],
      slaInfo: AlertSlaInfo(
        targetTime: const Duration(hours: 4),
        deadline: DateTime.now().add(const Duration(hours: 2, minutes: 15)),
        status: SlaStatus.onTrack,
      ),
      technicalDetails: const AlertTechnicalDetails(
        errorCode: 'ERR_QP_DOUBLE_2041',
        transactionIds: ['T-901', 'T-902'],
        userId: 'U-7843',
        deviceInfo: 'iOS 16.4.1',
        appVersion: 'v4.2.1',
      ),
      timeline: [
        ActivityEvent(
          id: 'ev-1',
          type: ActivityEventType.created,
          actorName: 'System',
          description: 'Alert created automatically',
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        ActivityEvent(
          id: 'ev-2',
          type: ActivityEventType.assigned,
          actorName: 'Auto-Router',
          description: 'Assigned to Jane Smith (Administrator)',
          timestamp: DateTime.now().subtract(const Duration(minutes: 14)),
        ),
        ActivityEvent(
          id: 'ev-3',
          type: ActivityEventType.commented,
          actorName: 'Jane Smith',
          description: 'Investigating transaction logs',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          details: 'Found duplicate entry in payment gateway logs. Contacting payment provider.',
        ),
      ],
    ),
    AlertItem(
      id: 'TX-2040',
      title: 'Shipment Delayed - Order #ORD-8829',
      description: 'Customer order has been in transit for 5 days beyond expected delivery. Tracking shows package stuck at regional hub.',
      priority: AlertPriority.medium,
      status: AlertStatus.inProgress,
      category: AlertCategory.shipment,
      subCategory: 'Delayed',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      createdBy: 'Customer Report',
      assigneeId: 'staff-2',
      assigneeName: 'Mike Johnson',
      assigneeRole: 'Response Officer',
      tags: ['delivery', 'customer-complaint'],
      slaInfo: AlertSlaInfo(
        targetTime: const Duration(hours: 8),
        deadline: DateTime.now().add(const Duration(hours: 2)),
        status: SlaStatus.atRisk,
      ),
      timeline: [
        ActivityEvent(
          id: 'ev-4',
          type: ActivityEventType.created,
          actorName: 'Customer Report',
          description: 'Alert created from customer complaint',
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        ActivityEvent(
          id: 'ev-5',
          type: ActivityEventType.assigned,
          actorName: 'Branch Manager',
          description: 'Assigned to Mike Johnson',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        ActivityEvent(
          id: 'ev-6',
          type: ActivityEventType.statusChanged,
          actorName: 'Mike Johnson',
          description: 'Status changed to In Progress',
          timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        ),
      ],
    ),
    AlertItem(
      id: 'TX-2039',
      title: 'System Sync Failure - Inventory Module',
      description: 'Inventory sync between POS and backend has been failing intermittently for the last 2 hours. Stock counts may be inaccurate.',
      priority: AlertPriority.critical,
      status: AlertStatus.escalated,
      category: AlertCategory.system,
      subCategory: 'Sync Failure',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 20)),
      createdBy: 'System Monitor',
      assigneeId: 'staff-3',
      assigneeName: 'Sarah Chen',
      assigneeRole: 'Branch Manager',
      tags: ['critical', 'system-down', 'inventory'],
      slaInfo: AlertSlaInfo(
        targetTime: const Duration(hours: 2),
        deadline: DateTime.now().subtract(const Duration(minutes: 10)),
        status: SlaStatus.breached,
      ),
      timeline: [
        ActivityEvent(
          id: 'ev-7',
          type: ActivityEventType.created,
          actorName: 'System Monitor',
          description: 'Automatic alert: Sync failure detected',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        ActivityEvent(
          id: 'ev-8',
          type: ActivityEventType.escalated,
          actorName: 'System',
          description: 'Auto-escalated: SLA at risk',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
      ],
    ),
    AlertItem(
      id: 'TX-2038',
      title: 'Driver No-Show - Ride #R-4421',
      description: 'Customer reports driver accepted ride but never arrived. Customer has been waiting 25 minutes.',
      priority: AlertPriority.high,
      status: AlertStatus.newAlert,
      category: AlertCategory.driverRide,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      createdBy: 'Customer',
      tags: ['driver', 'no-show', 'urgent'],
      slaInfo: AlertSlaInfo(
        targetTime: const Duration(hours: 1),
        deadline: DateTime.now().add(const Duration(minutes: 30)),
        status: SlaStatus.atRisk,
      ),
      timeline: [
        ActivityEvent(
          id: 'ev-9',
          type: ActivityEventType.created,
          actorName: 'Customer App',
          description: 'Alert created: Driver no-show reported',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
      ],
    ),
    AlertItem(
      id: 'TX-2037',
      title: 'Refund Request - Wrong Item Received',
      description: 'Customer received incorrect item. Order was for blue jacket size M, received red scarf. Requesting full refund and correct item.',
      priority: AlertPriority.low,
      status: AlertStatus.assigned,
      category: AlertCategory.returnRefund,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
      createdBy: 'Customer',
      assigneeId: 'staff-4',
      assigneeName: 'David Lee',
      assigneeRole: 'Social Officer',
      tags: ['refund', 'wrong-item'],
      timeline: [
        ActivityEvent(
          id: 'ev-10',
          type: ActivityEventType.created,
          actorName: 'Customer',
          description: 'Refund request submitted',
          timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        ),
        ActivityEvent(
          id: 'ev-11',
          type: ActivityEventType.assigned,
          actorName: 'Auto-Router',
          description: 'Assigned to David Lee',
          timestamp: DateTime.now().subtract(const Duration(hours: 11)),
        ),
      ],
    ),
    // Resolved alerts
    AlertItem(
      id: 'TX-2036',
      title: 'Account Login Issue - 2FA Failure',
      description: 'Customer unable to login due to 2FA code not being received. Issue was traced to SMS provider delay.',
      priority: AlertPriority.medium,
      status: AlertStatus.resolved,
      category: AlertCategory.account,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 18)),
      createdBy: 'Customer',
      assigneeId: 'staff-1',
      assigneeName: 'Jane Smith',
      assigneeRole: 'Administrator',
      tags: ['login', '2fa'],
      resolution: AlertResolution(
        method: ResolutionMethod.fixed,
        summary: 'Resent 2FA code via alternative channel. Customer access restored.',
        rootCause: 'SMS provider delay due to carrier maintenance window',
        preventionMeasures: 'Added email as fallback 2FA channel',
        resolverName: 'Jane Smith',
        resolvedAt: DateTime.now().subtract(const Duration(hours: 18)),
        verificationStatus: VerificationStatus.verified,
        verifierName: 'Admin',
        customerNotified: CustomerNotifyMethod.email,
        qualityScore: 92,
      ),
      timeline: [
        ActivityEvent(
          id: 'ev-12',
          type: ActivityEventType.created,
          actorName: 'Customer',
          description: 'Login issue reported',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
        ActivityEvent(
          id: 'ev-13',
          type: ActivityEventType.resolved,
          actorName: 'Jane Smith',
          description: 'Resolved: Sent 2FA via email, access restored',
          timestamp: DateTime.now().subtract(const Duration(hours: 18)),
        ),
        ActivityEvent(
          id: 'ev-14',
          type: ActivityEventType.verified,
          actorName: 'Admin',
          description: 'Resolution verified and closed',
          timestamp: DateTime.now().subtract(const Duration(hours: 16)),
        ),
      ],
    ),
    AlertItem(
      id: 'TX-2035',
      title: 'Payment Refund Processed - Order #ORD-8801',
      description: 'Customer refund of ₵89.50 has been processed and confirmed by payment gateway.',
      priority: AlertPriority.low,
      status: AlertStatus.closed,
      category: AlertCategory.payment,
      subCategory: 'Refund Delay',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      createdBy: 'System',
      assigneeId: 'staff-2',
      assigneeName: 'Mike Johnson',
      assigneeRole: 'Response Officer',
      resolution: AlertResolution(
        method: ResolutionMethod.fixed,
        summary: 'Refund of ₵89.50 processed. Customer notified via SMS.',
        resolverName: 'Mike Johnson',
        resolvedAt: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
        verificationStatus: VerificationStatus.verified,
        customerNotified: CustomerNotifyMethod.sms,
        qualityScore: 88,
      ),
      timeline: [
        ActivityEvent(
          id: 'ev-15',
          type: ActivityEventType.created,
          actorName: 'System',
          description: 'Refund request logged',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
        ),
        ActivityEvent(
          id: 'ev-16',
          type: ActivityEventType.resolved,
          actorName: 'Mike Johnson',
          description: 'Refund processed successfully',
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
        ),
      ],
    ),
    AlertItem(
      id: 'TX-2034',
      title: 'Security Alert - Unusual Login Pattern',
      description: 'Multiple failed login attempts detected from different locations for merchant account M-2201.',
      priority: AlertPriority.high,
      status: AlertStatus.verified,
      category: AlertCategory.security,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      createdBy: 'Security System',
      assigneeId: 'staff-1',
      assigneeName: 'Jane Smith',
      assigneeRole: 'Administrator',
      tags: ['security', 'brute-force'],
      resolution: AlertResolution(
        method: ResolutionMethod.fixed,
        summary: 'Account temporarily locked. Password reset forced. IP addresses blocked.',
        rootCause: 'Brute force attack from 3 different IPs',
        preventionMeasures: 'Enhanced rate limiting deployed. Added geo-restriction.',
        resolverName: 'Jane Smith',
        resolvedAt: DateTime.now().subtract(const Duration(hours: 14)),
        verificationStatus: VerificationStatus.verified,
        verifierName: 'Security Team',
        customerNotified: CustomerNotifyMethod.email,
        qualityScore: 95,
      ),
      timeline: [
        ActivityEvent(
          id: 'ev-17',
          type: ActivityEventType.created,
          actorName: 'Security System',
          description: 'Unusual login pattern detected',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
        ActivityEvent(
          id: 'ev-18',
          type: ActivityEventType.escalated,
          actorName: 'System',
          description: 'Auto-escalated to Administrator',
          timestamp: DateTime.now().subtract(const Duration(hours: 23)),
        ),
        ActivityEvent(
          id: 'ev-19',
          type: ActivityEventType.resolved,
          actorName: 'Jane Smith',
          description: 'Account secured, IPs blocked',
          timestamp: DateTime.now().subtract(const Duration(hours: 14)),
        ),
      ],
    ),
    AlertItem(
      id: 'TX-2033',
      title: 'Shipment Delivered - Confirmation Pending',
      description: 'Package marked as delivered but customer hasn\'t confirmed receipt. Auto-close in 48 hours.',
      priority: AlertPriority.low,
      status: AlertStatus.resolved,
      category: AlertCategory.shipment,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      createdBy: 'System',
      assigneeId: 'staff-4',
      assigneeName: 'David Lee',
      assigneeRole: 'Social Officer',
      resolution: AlertResolution(
        method: ResolutionMethod.fixed,
        summary: 'Customer confirmed receipt via phone call. Issue closed.',
        resolverName: 'David Lee',
        resolvedAt: DateTime.now().subtract(const Duration(days: 2)),
        verificationStatus: VerificationStatus.pendingReview,
        customerNotified: CustomerNotifyMethod.inApp,
        qualityScore: 85,
      ),
      timeline: [],
    ),
    AlertItem(
      id: 'TX-2032',
      title: 'System Outage - Notification Service',
      description: 'Push notification service was down for 45 minutes. Approximately 2,300 notifications delayed.',
      priority: AlertPriority.critical,
      status: AlertStatus.closed,
      category: AlertCategory.system,
      subCategory: 'Outage',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      createdBy: 'System Monitor',
      assigneeId: 'staff-3',
      assigneeName: 'Sarah Chen',
      assigneeRole: 'Branch Manager',
      tags: ['outage', 'notifications', 'postmortem'],
      resolution: AlertResolution(
        method: ResolutionMethod.fixed,
        summary: 'Service restarted. Backlog of 2,300 notifications sent within 10 minutes. Root cause: memory leak.',
        rootCause: 'Memory leak in notification queue processor',
        preventionMeasures: 'Added memory monitoring alerts. Deployed auto-restart on memory threshold.',
        resolverName: 'Sarah Chen',
        resolvedAt: DateTime.now().subtract(const Duration(days: 3, hours: 12)),
        verificationStatus: VerificationStatus.verified,
        verifierName: 'Admin',
        customerNotified: CustomerNotifyMethod.none,
        qualityScore: 90,
      ),
      timeline: [],
    ),
    AlertItem(
      id: 'TX-2031',
      title: 'Driver Complaint - Vehicle Condition',
      description: 'Passenger reported vehicle had broken AC and unclean interior for ride R-4320.',
      priority: AlertPriority.medium,
      status: AlertStatus.resolved,
      category: AlertCategory.driverRide,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      createdBy: 'Customer',
      assigneeId: 'staff-2',
      assigneeName: 'Mike Johnson',
      assigneeRole: 'Response Officer',
      resolution: AlertResolution(
        method: ResolutionMethod.fixed,
        summary: 'Driver warned. Vehicle inspection scheduled. 20% refund issued to customer.',
        resolverName: 'Mike Johnson',
        resolvedAt: DateTime.now().subtract(const Duration(days: 4)),
        verificationStatus: VerificationStatus.verified,
        customerNotified: CustomerNotifyMethod.sms,
        qualityScore: 82,
      ),
      timeline: [],
    ),
    AlertItem(
      id: 'TX-2030',
      title: 'Return Rejected - Policy Violation',
      description: 'Customer return request rejected: Item damaged by customer (not covered under warranty).',
      priority: AlertPriority.low,
      status: AlertStatus.archived,
      category: AlertCategory.returnRefund,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 6)),
      createdBy: 'Staff',
      assigneeId: 'staff-4',
      assigneeName: 'David Lee',
      assigneeRole: 'Social Officer',
      resolution: AlertResolution(
        method: ResolutionMethod.byDesign,
        summary: 'Return rejected per policy. Customer informed of warranty terms.',
        resolverName: 'David Lee',
        resolvedAt: DateTime.now().subtract(const Duration(days: 6)),
        verificationStatus: VerificationStatus.verified,
        customerNotified: CustomerNotifyMethod.email,
        qualityScore: 78,
      ),
      timeline: [],
    ),
  ];

  List<AlertItem> get alerts => _alerts.isNotEmpty ? _alerts : _fallbackAlerts;

  List<AlertItem> get pendingAlerts =>
      alerts.where((a) => a.isPending).toList()
        ..sort((a, b) => a.priority.index.compareTo(b.priority.index));

  List<AlertItem> get resolvedAlerts =>
      alerts.where((a) => a.isResolved).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  int get pendingCount => pendingAlerts.length;
  int get resolvedCount => resolvedAlerts.length;
  int get totalCount => alerts.length;

  int get highPriorityPendingCount =>
      pendingAlerts.where((a) => a.priority == AlertPriority.high || a.priority == AlertPriority.critical).length;

  // ──── FILTERING ────────────────────────────────────────

  AlertPriority? _priorityFilter;
  AlertPriority? get priorityFilter => _priorityFilter;
  void setPriorityFilter(AlertPriority? p) {
    _priorityFilter = p;
    notifyListeners();
  }

  AlertCategory? _categoryFilter;
  AlertCategory? get categoryFilter => _categoryFilter;
  void setCategoryFilter(AlertCategory? c) {
    _categoryFilter = c;
    notifyListeners();
  }

  TimeFilter _timeFilter = TimeFilter.last7d;
  TimeFilter get timeFilter => _timeFilter;
  void setTimeFilter(TimeFilter t) {
    _timeFilter = t;
    notifyListeners();
  }

  bool _assignedToMeOnly = false;
  bool get assignedToMeOnly => _assignedToMeOnly;
  void setAssignedToMeOnly(bool v) {
    _assignedToMeOnly = v;
    notifyListeners();
  }

  int get activeFilterCount {
    int count = 0;
    if (_priorityFilter != null) count++;
    if (_categoryFilter != null) count++;
    if (_timeFilter != TimeFilter.last7d) count++;
    if (_assignedToMeOnly) count++;
    return count;
  }

  void clearAllFilters() {
    _priorityFilter = null;
    _categoryFilter = null;
    _timeFilter = TimeFilter.last7d;
    _assignedToMeOnly = false;
    _searchQuery = '';
    notifyListeners();
  }

  List<AlertItem> get filteredAlerts {
    List<AlertItem> result;
    switch (_dashboardTab) {
      case AlertDashboardTab.pending:
        result = pendingAlerts;
        break;
      case AlertDashboardTab.resolved:
        result = resolvedAlerts;
        break;
      case AlertDashboardTab.all:
        result = List.from(alerts);
        break;
    }

    if (_priorityFilter != null) {
      result = result.where((a) => a.priority == _priorityFilter).toList();
    }
    if (_categoryFilter != null) {
      result = result.where((a) => a.category == _categoryFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((a) =>
          a.title.toLowerCase().contains(q) ||
          a.id.toLowerCase().contains(q) ||
          a.description.toLowerCase().contains(q) ||
          a.tags.any((t) => t.toLowerCase().contains(q))).toList();
    }
    return result;
  }

  // ──── ALERT ACTIONS ────────────────────────────────────

  AlertItem? getAlertById(String id) {
    try {
      return _alerts.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  void acceptAlert(String id) {
    final idx = _alerts.indexWhere((a) => a.id == id);
    if (idx == -1) return;
    final a = _alerts[idx];
    _alerts[idx] = AlertItem(
      id: a.id, title: a.title, description: a.description,
      priority: a.priority, status: AlertStatus.inProgress,
      category: a.category, subCategory: a.subCategory,
      createdAt: a.createdAt, updatedAt: DateTime.now(),
      createdBy: a.createdBy, assigneeId: a.assigneeId,
      assigneeName: a.assigneeName, assigneeRole: a.assigneeRole,
      tags: a.tags, attachments: a.attachments,
      timeline: [...a.timeline, ActivityEvent(
        id: 'ev-auto-${DateTime.now().millisecondsSinceEpoch}',
        type: ActivityEventType.statusChanged,
        actorName: a.assigneeName ?? 'You',
        description: 'Accepted and started working',
        timestamp: DateTime.now(),
      )],
      slaInfo: a.slaInfo, technicalDetails: a.technicalDetails,
    );
    notifyListeners();
  }

  void resolveAlert(String id, AlertResolution resolution) {
    final idx = _alerts.indexWhere((a) => a.id == id);
    if (idx == -1) return;
    final a = _alerts[idx];
    _alerts[idx] = AlertItem(
      id: a.id, title: a.title, description: a.description,
      priority: a.priority, status: AlertStatus.resolved,
      category: a.category, subCategory: a.subCategory,
      createdAt: a.createdAt, updatedAt: DateTime.now(),
      createdBy: a.createdBy, assigneeId: a.assigneeId,
      assigneeName: a.assigneeName, assigneeRole: a.assigneeRole,
      tags: a.tags, attachments: a.attachments, resolution: resolution,
      timeline: [...a.timeline, ActivityEvent(
        id: 'ev-auto-${DateTime.now().millisecondsSinceEpoch}',
        type: ActivityEventType.resolved,
        actorName: resolution.resolverName,
        description: 'Resolved: ${resolution.summary}',
        timestamp: DateTime.now(),
      )],
      slaInfo: a.slaInfo, technicalDetails: a.technicalDetails,
    );
    notifyListeners();
  }

  void escalateAlert(String id) {
    final idx = _alerts.indexWhere((a) => a.id == id);
    if (idx == -1) return;
    final a = _alerts[idx];
    _alerts[idx] = AlertItem(
      id: a.id, title: a.title, description: a.description,
      priority: a.priority, status: AlertStatus.escalated,
      category: a.category, subCategory: a.subCategory,
      createdAt: a.createdAt, updatedAt: DateTime.now(),
      createdBy: a.createdBy, assigneeId: a.assigneeId,
      assigneeName: a.assigneeName, assigneeRole: a.assigneeRole,
      tags: a.tags, attachments: a.attachments,
      timeline: [...a.timeline, ActivityEvent(
        id: 'ev-auto-${DateTime.now().millisecondsSinceEpoch}',
        type: ActivityEventType.escalated,
        actorName: 'You',
        description: 'Alert escalated to next level',
        timestamp: DateTime.now(),
      )],
      slaInfo: a.slaInfo, technicalDetails: a.technicalDetails,
    );
    notifyListeners();
  }

  void bookmarkAlert(String id) {
    final idx = _alerts.indexWhere((a) => a.id == id);
    if (idx == -1) return;
    final a = _alerts[idx];
    _alerts[idx] = AlertItem(
      id: a.id, title: a.title, description: a.description,
      priority: a.priority, status: a.status,
      category: a.category, subCategory: a.subCategory,
      createdAt: a.createdAt, updatedAt: a.updatedAt,
      createdBy: a.createdBy, assigneeId: a.assigneeId,
      assigneeName: a.assigneeName, assigneeRole: a.assigneeRole,
      tags: a.tags, attachments: a.attachments,
      timeline: a.timeline, resolution: a.resolution,
      slaInfo: a.slaInfo, technicalDetails: a.technicalDetails,
      isBookmarked: !a.isBookmarked,
    );
    notifyListeners();
  }

  // ──── BULK OPERATIONS ────────────────────────────────────

  final Set<String> _selectedAlertIds = {};
  Set<String> get selectedAlertIds => _selectedAlertIds;
  bool get isSelectMode => _selectedAlertIds.isNotEmpty;
  int get selectedCount => _selectedAlertIds.length;

  void toggleSelectAlert(String id) {
    if (_selectedAlertIds.contains(id)) {
      _selectedAlertIds.remove(id);
    } else {
      _selectedAlertIds.add(id);
    }
    notifyListeners();
  }

  void selectAll() {
    _selectedAlertIds.addAll(filteredAlerts.map((a) => a.id));
    notifyListeners();
  }

  void clearSelection() {
    _selectedAlertIds.clear();
    notifyListeners();
  }

  void bulkAssign(String assigneeName) {
    for (final id in _selectedAlertIds) {
      final idx = _alerts.indexWhere((a) => a.id == id);
      if (idx == -1) continue;
      final a = _alerts[idx];
      _alerts[idx] = AlertItem(
        id: a.id, title: a.title, description: a.description,
        priority: a.priority, status: AlertStatus.assigned,
        category: a.category, subCategory: a.subCategory,
        createdAt: a.createdAt, updatedAt: DateTime.now(),
        createdBy: a.createdBy,
        assigneeName: assigneeName, assigneeRole: a.assigneeRole,
        tags: a.tags, attachments: a.attachments, timeline: a.timeline,
        slaInfo: a.slaInfo, technicalDetails: a.technicalDetails,
      );
    }
    _selectedAlertIds.clear();
    notifyListeners();
  }

  // ──── ISSUE DISTRIBUTION ────────────────────────────────

  List<IssueDistribution> get issueDistribution {
    final source = alerts;
    final total = source.length;
    if (total == 0) return [];
    final counts = <AlertCategory, int>{};
    for (final a in source) {
      counts[a.category] = (counts[a.category] ?? 0) + 1;
    }
    return counts.entries.map((e) => IssueDistribution(
      category: e.key,
      percentage: (e.value / total * 100),
      count: e.value,
    )).toList()
      ..sort((a, b) => b.percentage.compareTo(a.percentage));
  }

  // ──── SEARCH ────────────────────────────────────────

  final List<RecentSearch> _recentSearches = [
    RecentSearch(query: 'payment double charge', timestamp: DateTime.now().subtract(const Duration(hours: 2)), resultCount: 3),
    RecentSearch(query: 'TX-2041', timestamp: DateTime.now().subtract(const Duration(hours: 5)), resultCount: 1),
    RecentSearch(query: 'shipment delayed', timestamp: DateTime.now().subtract(const Duration(days: 1)), resultCount: 5),
    RecentSearch(query: 'driver complaint', timestamp: DateTime.now().subtract(const Duration(days: 2)), resultCount: 2),
    RecentSearch(query: 'system outage', timestamp: DateTime.now().subtract(const Duration(days: 3)), resultCount: 1),
  ];

  List<RecentSearch> get recentSearches => _recentSearches;

  void clearRecentSearches() {
    _recentSearches.clear();
    notifyListeners();
  }

  final List<SavedSearch> _savedSearches = [
    SavedSearch(id: 'ss-1', name: 'My Open Items', query: '', createdAt: DateTime.now().subtract(const Duration(days: 30))),
    SavedSearch(id: 'ss-2', name: 'High Priority Unassigned', query: '', createdAt: DateTime.now().subtract(const Duration(days: 20))),
  ];

  List<SavedSearch> get savedSearches => _savedSearches;

  // ──── STAFF DATA (fallback-only) ────────────────────────

  static const List<AlertStaffMember> _fallbackStaff = [
    AlertStaffMember(id: 'staff-1', name: 'Jane Smith', role: 'Administrator', activeAlerts: 3, isAvailable: true, branch: 'Main'),
    AlertStaffMember(id: 'staff-2', name: 'Mike Johnson', role: 'Response Officer', activeAlerts: 5, isAvailable: true, branch: 'Main'),
    AlertStaffMember(id: 'staff-3', name: 'Sarah Chen', role: 'Branch Manager', activeAlerts: 2, isAvailable: false, branch: 'North'),
    AlertStaffMember(id: 'staff-4', name: 'David Lee', role: 'Social Officer', activeAlerts: 4, isAvailable: true, branch: 'Main'),
    AlertStaffMember(id: 'staff-5', name: 'Emma Wilson', role: 'Monitor', activeAlerts: 0, isAvailable: true, branch: 'South'),
    AlertStaffMember(id: 'staff-6', name: 'James Brown', role: 'Driver', activeAlerts: 1, isAvailable: true, branch: 'East'),
  ];

  List<AlertStaffMember> _staff = [];

  List<AlertStaffMember> get staff => _staff.isNotEmpty ? _staff : _fallbackStaff;

  // ──── TEMPLATES (fallback-only) ─────────────────────────

  static final List<AlertTemplate> _fallbackTemplates = [
    AlertTemplate(id: 'tpl-1', name: 'Payment Refund Resolution', type: AlertTemplateType.resolution,
      content: 'Refund of \${amount} processed for order \${orderId}. Customer notified via \${channel}. Expected completion: 3-5 business days.',
      variables: ['amount', 'orderId', 'channel'],
      createdAt: DateTime.now().subtract(const Duration(days: 60)), updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      createdBy: 'Admin', usageCount: 45),
    AlertTemplate(id: 'tpl-2', name: 'Shipment Delay Apology', type: AlertTemplateType.communication,
      content: 'Dear \${customer}, we apologize for the delay in your shipment. Your order \${orderId} is now expected to arrive by \${date}.',
      variables: ['customer', 'orderId', 'date'],
      createdAt: DateTime.now().subtract(const Duration(days: 45)), updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      createdBy: 'Admin', usageCount: 32),
    AlertTemplate(id: 'tpl-3', name: 'System Issue Report', type: AlertTemplateType.alert,
      content: 'System: \${system}\nImpact: \${impact}\nStart Time: \${startTime}\nAffected Users: \${userCount}',
      variables: ['system', 'impact', 'startTime', 'userCount'],
      createdAt: DateTime.now().subtract(const Duration(days: 30)), updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      createdBy: 'Admin', usageCount: 18),
    AlertTemplate(id: 'tpl-4', name: 'Driver Investigation', type: AlertTemplateType.workflow,
      content: '1. Contact driver\n2. Review GPS logs\n3. Interview customer\n4. Document findings\n5. Apply policy action',
      variables: [],
      createdAt: DateTime.now().subtract(const Duration(days: 20)), updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      createdBy: 'Branch Manager', usageCount: 12),
    AlertTemplate(id: 'tpl-5', name: 'Account Recovery', type: AlertTemplateType.resolution,
      content: 'Account \${accountId} recovered. Actions taken: \${actions}. Customer verified via \${method}.',
      variables: ['accountId', 'actions', 'method'],
      createdAt: DateTime.now().subtract(const Duration(days: 15)), updatedAt: DateTime.now().subtract(const Duration(days: 8)),
      createdBy: 'Admin', usageCount: 22),
  ];

  List<AlertTemplate> _templates = [];

  List<AlertTemplate> get templates => _templates.isNotEmpty ? _templates : _fallbackTemplates;
  List<AlertTemplate> templatesByType(AlertTemplateType type) => templates.where((t) => t.type == type).toList();

  // ──── KNOWLEDGE BASE (fallback-only) ────────────────────

  static final List<KnowledgeBaseItem> _fallbackKnowledgeBase = [
    KnowledgeBaseItem(id: 'kb-1', title: 'Resolving Double Charge Issues', summary: 'Step-by-step guide to investigate and refund duplicate payment charges.',
      type: KnowledgeItemType.article, similarityScore: 0.95, helpfulCount: 127, createdAt: DateTime.now().subtract(const Duration(days: 90))),
    KnowledgeBaseItem(id: 'kb-2', title: 'Shipment Tracking Troubleshooting', summary: 'Common causes and fixes for shipment tracking discrepancies.',
      type: KnowledgeItemType.article, similarityScore: 0.82, helpfulCount: 89, createdAt: DateTime.now().subtract(const Duration(days: 60))),
    KnowledgeBaseItem(id: 'kb-3', title: 'Driver No-Show Protocol', summary: 'Standard operating procedure when a driver fails to arrive.',
      type: KnowledgeItemType.article, similarityScore: 0.78, helpfulCount: 56, createdAt: DateTime.now().subtract(const Duration(days: 45))),
    KnowledgeBaseItem(id: 'kb-4', title: 'Similar: Payment sync delay - Branch North', summary: 'Resolved by restarting payment gateway connector. Issue traced to stale cache.',
      type: KnowledgeItemType.pastResolution, similarityScore: 0.91, helpfulCount: 34, createdAt: DateTime.now().subtract(const Duration(days: 14)), source: 'Branch North'),
    KnowledgeBaseItem(id: 'kb-5', title: 'Community: Handling mass refund requests', summary: 'Best practices from high-volume branches for processing bulk refunds efficiently.',
      type: KnowledgeItemType.communitySolution, similarityScore: 0.73, helpfulCount: 45, createdAt: DateTime.now().subtract(const Duration(days: 30)), source: 'Branch East'),
  ];

  List<KnowledgeBaseItem> _knowledgeBase = [];

  List<KnowledgeBaseItem> get knowledgeBase => _knowledgeBase.isNotEmpty ? _knowledgeBase : _fallbackKnowledgeBase;
  List<KnowledgeBaseItem> knowledgeForAlert(AlertItem alert) {
    final source = knowledgeBase;
    return source.where((kb) => kb.similarityScore > 0.7).toList()
      ..sort((a, b) => b.similarityScore.compareTo(a.similarityScore));
  }

  // ──── ANALYTICS DATA (fallback-only) ────────────────────

  List<AlertAnalyticsPoint> get volumeByDay => const [
    AlertAnalyticsPoint(label: 'Mon', count: 8),
    AlertAnalyticsPoint(label: 'Tue', count: 12),
    AlertAnalyticsPoint(label: 'Wed', count: 6),
    AlertAnalyticsPoint(label: 'Thu', count: 15),
    AlertAnalyticsPoint(label: 'Fri', count: 10),
    AlertAnalyticsPoint(label: 'Sat', count: 4),
    AlertAnalyticsPoint(label: 'Sun', count: 3),
  ];

  double get slaCompliancePercent => 87.5;
  Duration get avgResolutionTime => const Duration(hours: 3, minutes: 42);

  List<ResolverStats> get topResolvers => const [
    ResolverStats(name: 'Jane Smith', role: 'Administrator', resolvedCount: 45, avgResolutionTime: Duration(hours: 2, minutes: 15), satisfactionScore: 4.8),
    ResolverStats(name: 'Mike Johnson', role: 'Response Officer', resolvedCount: 38, avgResolutionTime: Duration(hours: 3, minutes: 30), satisfactionScore: 4.5),
    ResolverStats(name: 'David Lee', role: 'Social Officer', resolvedCount: 29, avgResolutionTime: Duration(hours: 4, minutes: 10), satisfactionScore: 4.3),
    ResolverStats(name: 'Sarah Chen', role: 'Branch Manager', resolvedCount: 22, avgResolutionTime: Duration(hours: 2, minutes: 45), satisfactionScore: 4.7),
  ];

  List<AlertAnalyticsPoint> get categoryDistribution => const [
    AlertAnalyticsPoint(label: 'Payment', count: 45),
    AlertAnalyticsPoint(label: 'Shipment', count: 25),
    AlertAnalyticsPoint(label: 'System', count: 15),
    AlertAnalyticsPoint(label: 'Ride', count: 10),
    AlertAnalyticsPoint(label: 'Other', count: 5),
  ];

  // ──── FILTER PRESETS (fallback-only) ────────────────────

  static const List<AlertFilterPreset> _fallbackFilterPresets = [
    AlertFilterPreset(id: 'fp-1', name: 'My Open Items', isDefault: true),
    AlertFilterPreset(id: 'fp-2', name: 'Due Today', isDefault: true),
    AlertFilterPreset(id: 'fp-3', name: 'Unassigned High Priority', isDefault: true),
    AlertFilterPreset(id: 'fp-4', name: 'Payment Issues (Team)', isShared: true),
  ];

  List<AlertFilterPreset> get filterPresets => _fallbackFilterPresets;

  // ──── SETTINGS ────────────────────────────────────────

  final Map<String, bool> _settingsToggles = {
    'pushNotifications': true,
    'emailNotifications': true,
    'smsNotifications': false,
    'inAppNotifications': true,
    'notifyOnAssign': true,
    'notifyOnEscalate': true,
    'notifyOnResolve': true,
    'notifyOnComment': false,
    'quietHours': false,
    'autoAssign': true,
    'soundAlerts': true,
    'vibration': true,
  };

  bool getSettingToggle(String key) => _settingsToggles[key] ?? false;
  void setSettingToggle(String key, bool v) {
    _settingsToggles[key] = v;
    notifyListeners();
  }

  String _quietHoursStart = '22:00';
  String get quietHoursStart => _quietHoursStart;
  void setQuietHoursStart(String v) { _quietHoursStart = v; notifyListeners(); }

  String _quietHoursEnd = '07:00';
  String get quietHoursEnd => _quietHoursEnd;
  void setQuietHoursEnd(String v) { _quietHoursEnd = v; notifyListeners(); }

  // ──── ESCALATION PATHS (fallback-only) ──────────────────

  static const List<EscalationPath> _fallbackEscalationPaths = [
    EscalationPath(level: EscalationLevel.team, afterDuration: Duration(hours: 2), targetRole: 'Team Lead'),
    EscalationPath(level: EscalationLevel.branch, afterDuration: Duration(hours: 4), targetRole: 'Branch Manager'),
    EscalationPath(level: EscalationLevel.regional, afterDuration: Duration(hours: 8), targetRole: 'Regional Manager'),
    EscalationPath(level: EscalationLevel.executive, afterDuration: Duration(hours: 24), targetRole: 'Administrator'),
  ];

  List<EscalationPath> get escalationPaths => _fallbackEscalationPaths;

  // ──── ASSIGNMENT RULES (fallback-only) ──────────────────

  static const List<AssignmentRule> _fallbackAssignmentRules = [
    AssignmentRule(id: 'ar-1', category: AlertCategory.payment, assignToRole: 'Administrator', isActive: true),
    AssignmentRule(id: 'ar-2', category: AlertCategory.shipment, assignToRole: 'Response Officer', isActive: true),
    AssignmentRule(id: 'ar-3', category: AlertCategory.driverRide, assignToRole: 'Response Officer', isActive: true),
    AssignmentRule(id: 'ar-4', category: AlertCategory.system, priority: AlertPriority.critical, assignToRole: 'Branch Manager', isActive: true),
    AssignmentRule(id: 'ar-5', category: AlertCategory.security, assignToRole: 'Administrator', isActive: true),
  ];

  List<AssignmentRule> get assignmentRules => _fallbackAssignmentRules;
}
