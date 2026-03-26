/// ═══════════════════════════════════════════════════════════════════════════
/// UTILITY MODULE Provider
/// Master state management for all 9 utility screens:
/// Dashboard, Settings, Notifications, Search, Help, Privacy,
/// Accessibility, Advanced Data, System Monitor
///
/// Pattern: API-first with fallback demo data.
/// Most of this provider is client-side / device-local. The init() method
/// verifies backend connectivity via AuthService.getMe().
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/utility_models.dart';
import '../../prompt/models/rbac_models.dart';
import '../../../core/services/services.dart';

class UtilityProvider extends ChangeNotifier {
  // ─── Service instances ───────────────────────────────────────────────────
  final AuthService _authService = AuthService();

  // ─── Loading / error state ───────────────────────────────────────────────
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ═══════════════════════════════════════════════════════════════════════════
  // INIT — verify connectivity & populate mutable lists
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> init() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Verify backend connectivity via AuthService
      final meResponse = await _authService.getMe();
      if (meResponse.success) {
        // Connection is good — update system health to online
        _systemHealth = SystemHealthSummary(
          overallScore: _systemHealth.overallScore,
          activeAlerts: _systemHealth.activeAlerts,
          storageUsedMB: _systemHealth.storageUsedMB,
          storageTotalMB: _systemHealth.storageTotalMB,
          lastBackup: _systemHealth.lastBackup,
          pendingUpdates: _systemHealth.pendingUpdates,
          connectionStatus: ConnectionStatus.online,
        );
      }
    } catch (e) {
      _errorMessage = 'Could not verify connectivity: $e';
      debugPrint('UtilityProvider.init error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // U0 - DASHBOARD STATE
  // ═══════════════════════════════════════════════════════════════════════════

  SystemHealthSummary _systemHealth = SystemHealthSummary(
    overallScore: 0.92,
    activeAlerts: 3,
    storageUsedMB: 12.4,
    storageTotalMB: 50.0,
    lastBackup: DateTime.now().subtract(const Duration(hours: 2)),
    pendingUpdates: 1,
    connectionStatus: ConnectionStatus.online,
  );

  SystemHealthSummary get systemHealth => _systemHealth;

  // ─── Recent Activities (fallback pattern) ────────────────────────────────

  static final List<RecentActivity> _fallbackRecentActivities = [
    RecentActivity(
      id: 'ra_1',
      title: 'Security Scan Complete',
      description: 'No threats detected',
      icon: Icons.security,
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      category: ActivityCategory.security,
    ),
    RecentActivity(
      id: 'ra_2',
      title: 'Data Backup Completed',
      description: 'All data backed up (12.4 MB)',
      icon: Icons.backup,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      category: ActivityCategory.data,
    ),
    RecentActivity(
      id: 'ra_3',
      title: 'App Updated',
      description: 'Version 2.4.1 installed',
      icon: Icons.system_update,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      category: ActivityCategory.system,
    ),
    RecentActivity(
      id: 'ra_4',
      title: 'Privacy Settings Changed',
      description: 'Location sharing disabled',
      icon: Icons.privacy_tip,
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      category: ActivityCategory.user,
    ),
    RecentActivity(
      id: 'ra_5',
      title: 'New Notification Rule',
      description: 'Quiet hours configured',
      icon: Icons.notifications_paused,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      category: ActivityCategory.notification,
    ),
  ];

  List<RecentActivity> _recentActivities = [];

  List<RecentActivity> get recentActivities =>
      _recentActivities.isNotEmpty ? _recentActivities : _fallbackRecentActivities;

  List<UtilityQuickAction> getQuickActions(UserRole role) {
    final actions = <UtilityQuickAction>[
      const UtilityQuickAction(
        id: 'qa_settings',
        label: 'Settings',
        icon: Icons.settings,
        color: Color(0xFF6366F1),
        route: '/utility/settings',
      ),
      UtilityQuickAction(
        id: 'qa_notifications',
        label: 'Notifications',
        icon: Icons.notifications_outlined,
        color: const Color(0xFFF59E0B),
        route: '/utility/notifications',
        badgeCount: _unreadCount,
      ),
      const UtilityQuickAction(
        id: 'qa_search',
        label: 'Search',
        icon: Icons.search,
        color: Color(0xFF3B82F6),
        route: '/utility/search',
      ),
      const UtilityQuickAction(
        id: 'qa_help',
        label: 'Help',
        icon: Icons.help_outline,
        color: Color(0xFF10B981),
        route: '/utility/help',
      ),
      const UtilityQuickAction(
        id: 'qa_privacy',
        label: 'Privacy',
        icon: Icons.privacy_tip_outlined,
        color: Color(0xFF8B5CF6),
        route: '/utility/privacy',
      ),
      const UtilityQuickAction(
        id: 'qa_accessibility',
        label: 'Accessibility',
        icon: Icons.accessibility_new,
        color: Color(0xFF06B6D4),
        route: '/utility/accessibility',
      ),
    ];

    // Advanced tools only for owner/admin/branchManager
    if (role == UserRole.owner ||
        role == UserRole.administrator ||
        role == UserRole.branchManager) {
      actions.addAll([
        const UtilityQuickAction(
          id: 'qa_data',
          label: 'Data Tools',
          icon: Icons.storage,
          color: Color(0xFFEC4899),
          route: '/utility/advanced-data',
        ),
        const UtilityQuickAction(
          id: 'qa_monitor',
          label: 'Monitor',
          icon: Icons.monitor_heart,
          color: Color(0xFFEF4444),
          route: '/utility/system-monitor',
        ),
      ]);
    }

    return actions;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // U1 - SETTINGS STATE
  // ═══════════════════════════════════════════════════════════════════════════

  UserPreferences _preferences = const UserPreferences();
  UserPreferences get preferences => _preferences;

  static const List<LanguageOption> availableLanguages = [
    LanguageOption(code: 'en', name: 'English', nativeName: 'English'),
    LanguageOption(code: 'fr', name: 'French', nativeName: 'Français'),
    LanguageOption(code: 'es', name: 'Spanish', nativeName: 'Español'),
    LanguageOption(code: 'de', name: 'German', nativeName: 'Deutsch'),
    LanguageOption(code: 'ar', name: 'Arabic', nativeName: 'العربية', isRTL: true),
    LanguageOption(code: 'zh', name: 'Chinese', nativeName: '中文'),
    LanguageOption(code: 'tw', name: 'Twi', nativeName: 'Twi'),
  ];

  String get currentLanguageName {
    final lang = availableLanguages.firstWhere(
      (l) => l.code == _preferences.languageCode,
      orElse: () => availableLanguages.first,
    );
    return lang.name;
  }

  void updateTheme(ThemePreference theme) {
    _preferences = _preferences.copyWith(theme: theme);
    notifyListeners();
  }

  void updateLanguage(String code) {
    _preferences = _preferences.copyWith(languageCode: code);
    notifyListeners();
  }

  void updateDateFormat(DateFormatPreference format) {
    _preferences = _preferences.copyWith(dateFormat: format);
    notifyListeners();
  }

  void updateTimeFormat(TimeFormatPreference format) {
    _preferences = _preferences.copyWith(timeFormat: format);
    notifyListeners();
  }

  void toggleHapticFeedback() {
    _preferences = _preferences.copyWith(hapticFeedback: !_preferences.hapticFeedback);
    notifyListeners();
  }

  void toggleSoundEffects() {
    _preferences = _preferences.copyWith(soundEffects: !_preferences.soundEffects);
    notifyListeners();
  }

  void toggleAutoUpdate() {
    _preferences = _preferences.copyWith(autoUpdate: !_preferences.autoUpdate);
    notifyListeners();
  }

  void toggleAnalytics() {
    _preferences = _preferences.copyWith(analyticsEnabled: !_preferences.analyticsEnabled);
    notifyListeners();
  }

  void toggleCrashReporting() {
    _preferences = _preferences.copyWith(crashReportingEnabled: !_preferences.crashReportingEnabled);
    notifyListeners();
  }

  void toggleCompactMode() {
    _preferences = _preferences.copyWith(compactMode: !_preferences.compactMode);
    notifyListeners();
  }

  void toggleShowAnimations() {
    _preferences = _preferences.copyWith(showAnimations: !_preferences.showAnimations);
    notifyListeners();
  }

  void updateTextScale(double scale) {
    _preferences = _preferences.copyWith(textScaleFactor: scale);
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // U2 - NOTIFICATIONS STATE
  // ═══════════════════════════════════════════════════════════════════════════

  NotificationFilter _notificationFilter = NotificationFilter.all;
  NotificationFilter get notificationFilter => _notificationFilter;

  NotificationType? _notificationTypeFilter;
  NotificationType? get notificationTypeFilter => _notificationTypeFilter;

  // ─── Notifications (fallback pattern) ────────────────────────────────────

  static final List<NotificationItem> _fallbackNotifications = [
    NotificationItem(
      id: 'n_1',
      title: 'Security Alert',
      body: 'New login detected from Chrome on Windows. If this wasn\'t you, secure your account immediately.',
      type: NotificationType.security,
      priority: NotificationPriority.critical,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      senderName: 'Security System',
      actionRoute: '/user-details/security',
    ),
    NotificationItem(
      id: 'n_2',
      title: 'Payment Received',
      body: 'You received GHS 250.00 from Kwame Mensah via QPoints transfer.',
      type: NotificationType.transaction,
      priority: NotificationPriority.high,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      senderName: 'Kwame Mensah',
    ),
    NotificationItem(
      id: 'n_3',
      title: 'Order #4521 Delivered',
      body: 'Your order from Wizdom Shop has been delivered successfully.',
      type: NotificationType.transaction,
      priority: NotificationPriority.medium,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: true,
    ),
    NotificationItem(
      id: 'n_4',
      title: 'App Update Available',
      body: 'Version 2.5.0 is available with new features and bug fixes.',
      type: NotificationType.update,
      priority: NotificationPriority.low,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      actionRoute: '/utility/settings',
    ),
    NotificationItem(
      id: 'n_5',
      title: 'New Follower',
      body: 'Ama Serwaa started following your business page.',
      type: NotificationType.social,
      priority: NotificationPriority.low,
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      senderName: 'Ama Serwaa',
      isRead: true,
    ),
    NotificationItem(
      id: 'n_6',
      title: 'Weekly Reminder',
      body: 'Review your weekly sales report and pending orders.',
      type: NotificationType.reminder,
      priority: NotificationPriority.medium,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    NotificationItem(
      id: 'n_7',
      title: 'System Maintenance',
      body: 'Scheduled maintenance on Sunday 2:00 AM - 4:00 AM GMT.',
      type: NotificationType.system,
      priority: NotificationPriority.medium,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
      isRead: true,
    ),
    NotificationItem(
      id: 'n_8',
      title: 'Flash Sale!',
      body: '50% off on all logistics services this weekend. Don\'t miss out!',
      type: NotificationType.promotion,
      priority: NotificationPriority.low,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
  ];

  List<NotificationItem> _notifications = [];

  List<NotificationItem> get notifications =>
      _notifications.isNotEmpty ? _notifications : _fallbackNotifications;

  List<NotificationItem> get filteredNotifications {
    var result = List<NotificationItem>.from(notifications);

    // Apply read/unread filter
    switch (_notificationFilter) {
      case NotificationFilter.unread:
        result = result.where((n) => !n.isRead).toList();
        break;
      case NotificationFilter.read:
        result = result.where((n) => n.isRead && !n.isArchived).toList();
        break;
      case NotificationFilter.archived:
        result = result.where((n) => n.isArchived).toList();
        break;
      case NotificationFilter.all:
        result = result.where((n) => !n.isArchived).toList();
        break;
    }

    // Apply type filter
    if (_notificationTypeFilter != null) {
      result = result.where((n) => n.type == _notificationTypeFilter).toList();
    }

    return result;
  }

  int get _unreadCount => notifications.where((n) => !n.isRead).length;
  int get unreadCount => _unreadCount;

  void setNotificationFilter(NotificationFilter filter) {
    _notificationFilter = filter;
    notifyListeners();
  }

  void setNotificationTypeFilter(NotificationType? type) {
    _notificationTypeFilter = type;
    notifyListeners();
  }

  void markNotificationRead(String id) {
    _ensureMutableNotifications();
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllRead() {
    _ensureMutableNotifications();
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  void archiveNotification(String id) {
    _ensureMutableNotifications();
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isArchived: true);
      notifyListeners();
    }
  }

  void deleteNotification(String id) {
    _ensureMutableNotifications();
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  /// Ensures _notifications is populated so mutation works against a real list.
  void _ensureMutableNotifications() {
    if (_notifications.isEmpty) {
      _notifications = List<NotificationItem>.from(_fallbackNotifications);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // U3 - SEARCH STATE
  // ═══════════════════════════════════════════════════════════════════════════

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  SearchCategory _searchCategory = SearchCategory.all;
  SearchCategory get searchCategory => _searchCategory;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  List<RecentSearch> _recentSearches = [
    RecentSearch(query: 'payment settings', timestamp: DateTime.now().subtract(const Duration(hours: 1))),
    RecentSearch(query: 'Kwame Mensah', category: SearchCategory.people, timestamp: DateTime.now().subtract(const Duration(hours: 3))),
    RecentSearch(query: 'order #4521', category: SearchCategory.orders, timestamp: DateTime.now().subtract(const Duration(days: 1))),
    RecentSearch(query: 'dark mode', category: SearchCategory.settings, timestamp: DateTime.now().subtract(const Duration(days: 2))),
  ];

  List<RecentSearch> get recentSearches => _recentSearches;

  static const List<SearchSuggestion> quickSuggestions = [
    SearchSuggestion(text: 'Change password', icon: Icons.lock, category: SearchCategory.settings),
    SearchSuggestion(text: 'Export data', icon: Icons.download, category: SearchCategory.settings),
    SearchSuggestion(text: 'Contact support', icon: Icons.headset_mic, category: SearchCategory.help),
    SearchSuggestion(text: 'Recent orders', icon: Icons.receipt_long, category: SearchCategory.orders),
    SearchSuggestion(text: 'Notification settings', icon: Icons.notifications, category: SearchCategory.settings),
    SearchSuggestion(text: 'Privacy policy', icon: Icons.policy, category: SearchCategory.help),
  ];

  // Demo search results pool
  static final List<SearchResult> _allResults = [
    const SearchResult(
      id: 'sr_1', title: 'Payment Settings', subtitle: 'Configure payment methods and preferences',
      category: SearchCategory.settings, icon: Icons.payment, iconColor: Color(0xFF6366F1), route: '/utility/settings',
    ),
    const SearchResult(
      id: 'sr_2', title: 'Kwame Mensah', subtitle: 'Contact · Last seen 2h ago',
      category: SearchCategory.people, icon: Icons.person, iconColor: Color(0xFF10B981),
    ),
    const SearchResult(
      id: 'sr_3', title: 'Order #4521', subtitle: 'Delivered · GHS 125.00',
      category: SearchCategory.orders, icon: Icons.receipt_long, iconColor: Color(0xFFF59E0B),
    ),
    const SearchResult(
      id: 'sr_4', title: 'Dark Mode', subtitle: 'Settings → Appearance → Theme',
      category: SearchCategory.settings, icon: Icons.dark_mode, iconColor: Color(0xFF64748B), route: '/utility/settings',
    ),
    const SearchResult(
      id: 'sr_5', title: 'How to reset password', subtitle: 'Help article · Updated 3 days ago',
      category: SearchCategory.help, icon: Icons.help_outline, iconColor: Color(0xFF3B82F6), route: '/utility/help',
    ),
    const SearchResult(
      id: 'sr_6', title: 'Transaction History', subtitle: 'View all your past transactions',
      category: SearchCategory.transactions, icon: Icons.history, iconColor: Color(0xFF8B5CF6),
    ),
    const SearchResult(
      id: 'sr_7', title: 'Ama Serwaa', subtitle: 'Contact · Online now',
      category: SearchCategory.people, icon: Icons.person, iconColor: Color(0xFF10B981),
    ),
    const SearchResult(
      id: 'sr_8', title: 'Chat with Support', subtitle: 'Message our support team directly',
      category: SearchCategory.messages, icon: Icons.chat, iconColor: Color(0xFF06B6D4), route: '/utility/help',
    ),
    const SearchResult(
      id: 'sr_9', title: 'Wireless Headphones', subtitle: 'Product · GHS 89.99 · In Stock',
      category: SearchCategory.products, icon: Icons.headphones, iconColor: Color(0xFFEC4899),
    ),
    const SearchResult(
      id: 'sr_10', title: 'Notification Preferences', subtitle: 'Settings → Notifications',
      category: SearchCategory.settings, icon: Icons.notifications, iconColor: Color(0xFFF59E0B), route: '/utility/settings',
    ),
  ];

  List<SearchResult> _searchResults = [];
  List<SearchResult> get searchResults => _searchResults;

  void updateSearchQuery(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _searchResults = [];
      _isSearching = false;
    } else {
      _isSearching = true;
      _performSearch(query);
    }
    notifyListeners();
  }

  void setSearchCategory(SearchCategory category) {
    _searchCategory = category;
    if (_searchQuery.isNotEmpty) {
      _performSearch(_searchQuery);
    }
    notifyListeners();
  }

  void _performSearch(String query) {
    final lowerQuery = query.toLowerCase();
    var results = _allResults.where((r) {
      return r.title.toLowerCase().contains(lowerQuery) ||
          r.subtitle.toLowerCase().contains(lowerQuery);
    }).toList();

    if (_searchCategory != SearchCategory.all) {
      results = results.where((r) => r.category == _searchCategory).toList();
    }

    results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
    _searchResults = results;
  }

  void addRecentSearch(String query) {
    _recentSearches.removeWhere((s) => s.query == query);
    _recentSearches.insert(0, RecentSearch(
      query: query,
      category: _searchCategory != SearchCategory.all ? _searchCategory : null,
      timestamp: DateTime.now(),
    ));
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.sublist(0, 10);
    }
    notifyListeners();
  }

  void clearRecentSearches() {
    _recentSearches = [];
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _isSearching = false;
    _searchCategory = SearchCategory.all;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // U4 - HELP & SUPPORT STATE
  // ═══════════════════════════════════════════════════════════════════════════

  HelpCategory? _helpCategoryFilter;
  HelpCategory? get helpCategoryFilter => _helpCategoryFilter;

  String _helpSearchQuery = '';
  String get helpSearchQuery => _helpSearchQuery;

  // ─── Help Articles (fallback pattern) ────────────────────────────────────

  static final List<HelpArticle> _fallbackHelpArticles = [
    HelpArticle(
      id: 'ha_1', title: 'Getting Started with thePG',
      content: 'Welcome to thePG! Follow these steps to set up your account and start using all features.',
      category: HelpCategory.gettingStarted, icon: Icons.rocket_launch,
      isPinned: true, viewCount: 1250, tags: ['setup', 'beginner', 'start'],
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    HelpArticle(
      id: 'ha_2', title: 'How to Add a Payment Method',
      content: 'Navigate to Settings → Payment Methods and tap "Add New". You can add mobile money, bank cards, or QPoints.',
      category: HelpCategory.payments, icon: Icons.credit_card,
      viewCount: 890, tags: ['payment', 'mobile money', 'card'],
      updatedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    HelpArticle(
      id: 'ha_3', title: 'Reset Your Password',
      content: 'Go to Settings → Security → Change Password. Enter your current password and set a new one.',
      category: HelpCategory.security, icon: Icons.lock_reset,
      viewCount: 2100, tags: ['password', 'security', 'reset'],
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    HelpArticle(
      id: 'ha_4', title: 'Understanding Your Account Roles',
      content: 'thePG supports multiple roles: Owner, Administrator, Manager, and more. Each role has specific permissions.',
      category: HelpCategory.account, icon: Icons.badge,
      viewCount: 654, tags: ['roles', 'permissions', 'rbac'],
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    HelpArticle(
      id: 'ha_5', title: 'Track Your Orders',
      content: 'View real-time order tracking from the LIVE module. You can see delivery status, ETA, and driver location.',
      category: HelpCategory.orders, icon: Icons.local_shipping,
      viewCount: 1100, tags: ['orders', 'tracking', 'delivery'],
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    HelpArticle(
      id: 'ha_6', title: 'Troubleshooting Login Issues',
      content: 'If you can\'t log in, try: 1) Check your internet connection 2) Verify your phone number 3) Reset your password',
      category: HelpCategory.troubleshooting, icon: Icons.build,
      viewCount: 1800, tags: ['login', 'troubleshoot', 'fix'],
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    HelpArticle(
      id: 'ha_7', title: 'Contact Our Support Team',
      content: 'Reach us via in-app chat, email at support@thepg.com, or call +233 XX XXX XXXX during business hours.',
      category: HelpCategory.contact, icon: Icons.headset_mic,
      isPinned: true, viewCount: 3200, tags: ['contact', 'support', 'help'],
      updatedAt: DateTime.now().subtract(const Duration(days: 0)),
    ),
  ];

  List<HelpArticle> _helpArticles = [];

  List<HelpArticle> get helpArticles {
    final source = _helpArticles.isNotEmpty ? _helpArticles : _fallbackHelpArticles;
    var result = List<HelpArticle>.from(source);

    if (_helpCategoryFilter != null) {
      result = result.where((a) => a.category == _helpCategoryFilter).toList();
    }

    if (_helpSearchQuery.isNotEmpty) {
      final lower = _helpSearchQuery.toLowerCase();
      result = result.where((a) =>
          a.title.toLowerCase().contains(lower) ||
          a.content.toLowerCase().contains(lower) ||
          a.tags.any((t) => t.toLowerCase().contains(lower)),
      ).toList();
    }

    // Pinned first, then by view count
    result.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.viewCount.compareTo(a.viewCount);
    });

    return result;
  }

  void setHelpCategory(HelpCategory? category) {
    _helpCategoryFilter = category;
    notifyListeners();
  }

  void setHelpSearch(String query) {
    _helpSearchQuery = query;
    notifyListeners();
  }

  // ─── Support Tickets (fallback pattern) ──────────────────────────────────

  static final List<SupportTicket> _fallbackSupportTickets = [
    SupportTicket(
      id: 'tkt_001',
      subject: 'Payment not reflected',
      description: 'I sent GHS 100 but it hasn\'t shown in my balance.',
      status: TicketStatus.inProgress,
      priority: TicketPriority.high,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      assignedAgent: 'Support Agent Kofi',
      messages: [
        TicketMessage(
          id: 'tm_1', content: 'I sent GHS 100 but it hasn\'t shown in my balance.',
          isAgent: false, timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
        TicketMessage(
          id: 'tm_2', content: 'We\'re looking into this. Can you share the transaction reference?',
          isAgent: true, timestamp: DateTime.now().subtract(const Duration(hours: 20)),
        ),
      ],
    ),
  ];

  List<SupportTicket> _supportTickets = [];

  List<SupportTicket> get supportTickets =>
      _supportTickets.isNotEmpty ? _supportTickets : _fallbackSupportTickets;

  static const List<ContactOption> contactOptions = [
    ContactOption(
      label: 'Live Chat', subtitle: 'Avg. response: 2 min',
      icon: Icons.chat_bubble, color: Color(0xFF3B82F6), action: 'chat',
    ),
    ContactOption(
      label: 'Email Support', subtitle: 'support@thepg.com',
      icon: Icons.email, color: Color(0xFF10B981), action: 'email',
    ),
    ContactOption(
      label: 'Phone', subtitle: '+233 XX XXX XXXX',
      icon: Icons.phone, color: Color(0xFF8B5CF6), action: 'phone',
    ),
    ContactOption(
      label: 'Community Forum', subtitle: 'Ask the community',
      icon: Icons.forum, color: Color(0xFFF59E0B), action: 'forum',
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // U5 - DATA & PRIVACY STATE
  // ═══════════════════════════════════════════════════════════════════════════

  // ─── Privacy Settings (fallback pattern) ─────────────────────────────────

  static const List<PrivacySetting> _fallbackPrivacySettings = [
    PrivacySetting(
      id: 'ps_1', label: 'Location Sharing', description: 'Allow apps and services to access your location',
      icon: Icons.location_on, enabled: false, level: PrivacyLevel.strict,
    ),
    PrivacySetting(
      id: 'ps_2', label: 'Activity Tracking', description: 'Track your usage patterns for personalized experience',
      icon: Icons.timeline, enabled: true, level: PrivacyLevel.standard,
    ),
    PrivacySetting(
      id: 'ps_3', label: 'Profile Visibility', description: 'Allow others to find and view your profile',
      icon: Icons.visibility, enabled: true, level: PrivacyLevel.standard,
    ),
    PrivacySetting(
      id: 'ps_4', label: 'Data Personalization', description: 'Use your data to personalize content and ads',
      icon: Icons.auto_awesome, enabled: true, level: PrivacyLevel.minimal,
    ),
    PrivacySetting(
      id: 'ps_5', label: 'Read Receipts', description: 'Let others know when you\'ve read their messages',
      icon: Icons.done_all, enabled: true, level: PrivacyLevel.standard,
    ),
    PrivacySetting(
      id: 'ps_6', label: 'Online Status', description: 'Show when you\'re currently online',
      icon: Icons.circle, enabled: true, level: PrivacyLevel.standard,
    ),
    PrivacySetting(
      id: 'ps_7', label: 'Contact Sync', description: 'Sync your phone contacts to find friends',
      icon: Icons.sync, enabled: false, level: PrivacyLevel.strict,
    ),
  ];

  List<PrivacySetting> _privacySettings = [];

  List<PrivacySetting> get privacySettings =>
      _privacySettings.isNotEmpty ? _privacySettings : List<PrivacySetting>.from(_fallbackPrivacySettings);

  void togglePrivacySetting(String id) {
    _ensureMutablePrivacySettings();
    final idx = _privacySettings.indexWhere((p) => p.id == id);
    if (idx != -1) {
      _privacySettings[idx] = _privacySettings[idx].copyWith(
        enabled: !_privacySettings[idx].enabled,
      );
      notifyListeners();
    }
  }

  /// Ensures _privacySettings is populated so mutation works against a real list.
  void _ensureMutablePrivacySettings() {
    if (_privacySettings.isEmpty) {
      _privacySettings = List<PrivacySetting>.from(_fallbackPrivacySettings);
    }
  }

  final List<DataCategory> _dataCategories = const [
    DataCategory(name: 'Messages', icon: Icons.chat, color: Color(0xFF3B82F6), sizeMB: 4.2, itemCount: 1250),
    DataCategory(name: 'Photos', icon: Icons.photo, color: Color(0xFF10B981), sizeMB: 3.8, itemCount: 89),
    DataCategory(name: 'Transactions', icon: Icons.payment, color: Color(0xFF8B5CF6), sizeMB: 1.6, itemCount: 342),
    DataCategory(name: 'Cache', icon: Icons.cached, color: Color(0xFFF59E0B), sizeMB: 1.8, itemCount: 560),
    DataCategory(name: 'Documents', icon: Icons.description, color: Color(0xFFEC4899), sizeMB: 0.7, itemCount: 24),
    DataCategory(name: 'Other', icon: Icons.folder, color: Color(0xFF64748B), sizeMB: 0.3, itemCount: 15),
  ];

  List<DataCategory> get dataCategories => _dataCategories;

  double get totalDataMB => _dataCategories.fold(0.0, (sum, c) => sum + c.sizeMB);

  List<ConnectedApp> _connectedApps = [
    ConnectedApp(
      id: 'ca_1', name: 'Google', icon: Icons.g_mobiledata,
      permissions: ['Email', 'Profile'], connectedAt: DateTime(2023, 3, 15),
      lastAccessed: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    ConnectedApp(
      id: 'ca_2', name: 'MTN Mobile Money', icon: Icons.phone_android,
      permissions: ['Payments', 'Balance'], connectedAt: DateTime(2023, 6, 1),
      lastAccessed: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ConnectedApp(
      id: 'ca_3', name: 'Uber Logistics', icon: Icons.local_shipping,
      permissions: ['Location', 'Orders'], connectedAt: DateTime(2024, 1, 10),
      lastAccessed: DateTime.now().subtract(const Duration(days: 7)), isActive: false,
    ),
  ];

  List<ConnectedApp> get connectedApps => _connectedApps;

  void revokeApp(String id) {
    _connectedApps.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  List<DataExportRequest> _exportRequests = [
    DataExportRequest(
      id: 'exp_1', format: DataExportFormat.json,
      status: DataExportStatus.ready,
      requestedAt: DateTime.now().subtract(const Duration(days: 3)),
      completedAt: DateTime.now().subtract(const Duration(days: 3, hours: -1)),
      fileSizeMB: 8.2,
    ),
  ];

  List<DataExportRequest> get exportRequests => _exportRequests;

  void requestExport(DataExportFormat format) {
    _exportRequests.insert(0, DataExportRequest(
      id: 'exp_${_exportRequests.length + 1}',
      format: format,
      status: DataExportStatus.processing,
      requestedAt: DateTime.now(),
    ));
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // U6 - ACCESSIBILITY STATE
  // ═══════════════════════════════════════════════════════════════════════════

  AccessibilityConfig _accessibilityConfig = const AccessibilityConfig();
  AccessibilityConfig get accessibilityConfig => _accessibilityConfig;

  void updateAccessibility(AccessibilityConfig config) {
    _accessibilityConfig = config;
    notifyListeners();
  }

  void setTextScale(double scale) {
    _accessibilityConfig = _accessibilityConfig.copyWith(textScale: scale);
    notifyListeners();
  }

  void toggleBoldText() {
    _accessibilityConfig = _accessibilityConfig.copyWith(boldText: !_accessibilityConfig.boldText);
    notifyListeners();
  }

  void toggleHighContrast() {
    _accessibilityConfig = _accessibilityConfig.copyWith(highContrast: !_accessibilityConfig.highContrast);
    notifyListeners();
  }

  void toggleReduceMotion() {
    _accessibilityConfig = _accessibilityConfig.copyWith(reduceMotion: !_accessibilityConfig.reduceMotion);
    notifyListeners();
  }

  void toggleReduceTransparency() {
    _accessibilityConfig = _accessibilityConfig.copyWith(reduceTransparency: !_accessibilityConfig.reduceTransparency);
    notifyListeners();
  }

  void toggleScreenReader() {
    _accessibilityConfig = _accessibilityConfig.copyWith(screenReaderOptimized: !_accessibilityConfig.screenReaderOptimized);
    notifyListeners();
  }

  void setColorBlindnessMode(ColorBlindnessMode mode) {
    _accessibilityConfig = _accessibilityConfig.copyWith(colorBlindnessMode: mode);
    notifyListeners();
  }

  void toggleAccessibilityHaptic() {
    _accessibilityConfig = _accessibilityConfig.copyWith(hapticFeedback: !_accessibilityConfig.hapticFeedback);
    notifyListeners();
  }

  void toggleAudioDescriptions() {
    _accessibilityConfig = _accessibilityConfig.copyWith(audioDescriptions: !_accessibilityConfig.audioDescriptions);
    notifyListeners();
  }

  void setTouchTargetSize(double size) {
    _accessibilityConfig = _accessibilityConfig.copyWith(touchTargetSize: size);
    notifyListeners();
  }

  void toggleFocusIndicators() {
    _accessibilityConfig = _accessibilityConfig.copyWith(showFocusIndicators: !_accessibilityConfig.showFocusIndicators);
    notifyListeners();
  }

  void toggleLargePointer() {
    _accessibilityConfig = _accessibilityConfig.copyWith(largePointer: !_accessibilityConfig.largePointer);
    notifyListeners();
  }

  void applyPreset(AccessibilityPreset preset) {
    _accessibilityConfig = preset.config;
    notifyListeners();
  }

  static const List<AccessibilityPreset> presets = [
    AccessibilityPreset(
      id: 'ap_1', name: 'Default', description: 'Standard settings for most users',
      icon: Icons.tune,
      config: AccessibilityConfig(),
    ),
    AccessibilityPreset(
      id: 'ap_2', name: 'Low Vision', description: 'Larger text, bold fonts, high contrast',
      icon: Icons.visibility,
      config: AccessibilityConfig(textScale: 1.4, boldText: true, highContrast: true, showFocusIndicators: true),
    ),
    AccessibilityPreset(
      id: 'ap_3', name: 'Motor Accessibility', description: 'Larger touch targets, reduced motion',
      icon: Icons.accessibility,
      config: AccessibilityConfig(touchTargetSize: 56.0, reduceMotion: true, hapticFeedback: true),
    ),
    AccessibilityPreset(
      id: 'ap_4', name: 'Screen Reader', description: 'Optimized for screen reader usage',
      icon: Icons.record_voice_over,
      config: AccessibilityConfig(screenReaderOptimized: true, reduceMotion: true, showFocusIndicators: true, audioDescriptions: true),
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // U7 - ADVANCED DATA TOOLS STATE
  // ═══════════════════════════════════════════════════════════════════════════

  StorageAnalytics _storageAnalytics = StorageAnalytics(
    totalMB: 50.0,
    usedMB: 12.4,
    breakdown: const [
      DataCategory(name: 'Messages', icon: Icons.chat, color: Color(0xFF3B82F6), sizeMB: 4.2, itemCount: 1250),
      DataCategory(name: 'Photos', icon: Icons.photo, color: Color(0xFF10B981), sizeMB: 3.8, itemCount: 89),
      DataCategory(name: 'Transactions', icon: Icons.payment, color: Color(0xFF8B5CF6), sizeMB: 1.6, itemCount: 342),
      DataCategory(name: 'Cache', icon: Icons.cached, color: Color(0xFFF59E0B), sizeMB: 1.8, itemCount: 560),
      DataCategory(name: 'Documents', icon: Icons.description, color: Color(0xFFEC4899), sizeMB: 0.7, itemCount: 24),
      DataCategory(name: 'Other', icon: Icons.folder, color: Color(0xFF64748B), sizeMB: 0.3, itemCount: 15),
    ],
    lastAnalyzed: DateTime.now().subtract(const Duration(hours: 1)),
  );

  StorageAnalytics get storageAnalytics => _storageAnalytics;

  List<DataBackup> _backups = [
    DataBackup(
      id: 'bk_1', createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      sizeMB: 12.4, status: BackupStatus.completed, type: BackupType.full,
      description: 'Auto backup',
    ),
    DataBackup(
      id: 'bk_2', createdAt: DateTime.now().subtract(const Duration(days: 1)),
      sizeMB: 11.9, status: BackupStatus.completed, type: BackupType.full,
      description: 'Daily backup',
    ),
    DataBackup(
      id: 'bk_3', createdAt: DateTime.now().subtract(const Duration(days: 7)),
      sizeMB: 10.1, status: BackupStatus.completed, type: BackupType.full,
      description: 'Weekly backup',
    ),
  ];

  List<DataBackup> get backups => _backups;

  List<CacheInfo> _cacheInfo = [
    CacheInfo(category: 'Images', icon: Icons.image, sizeMB: 0.8, itemCount: 230,
        lastCleaned: DateTime.now().subtract(const Duration(days: 3))),
    CacheInfo(category: 'API Responses', icon: Icons.cloud, sizeMB: 0.5, itemCount: 180,
        lastCleaned: DateTime.now().subtract(const Duration(days: 1))),
    CacheInfo(category: 'Search Index', icon: Icons.search, sizeMB: 0.3, itemCount: 90,
        lastCleaned: DateTime.now().subtract(const Duration(days: 5))),
    CacheInfo(category: 'Thumbnails', icon: Icons.photo_size_select_actual, sizeMB: 0.2, itemCount: 60,
        lastCleaned: DateTime.now().subtract(const Duration(days: 2))),
  ];

  List<CacheInfo> get cacheInfo => _cacheInfo;

  double get totalCacheMB => _cacheInfo.fold(0.0, (sum, c) => sum + c.sizeMB);

  void clearCache() {
    _cacheInfo = _cacheInfo.map((c) => CacheInfo(
      category: c.category, icon: c.icon, sizeMB: 0.0, itemCount: 0,
      lastCleaned: DateTime.now(),
    )).toList();
    notifyListeners();
  }

  void createBackup() {
    _backups.insert(0, DataBackup(
      id: 'bk_${_backups.length + 1}',
      createdAt: DateTime.now(),
      sizeMB: _storageAnalytics.usedMB,
      status: BackupStatus.inProgress,
      type: BackupType.full,
      description: 'Manual backup',
    ));
    notifyListeners();
  }

  List<SyncStatus> _syncStatuses = [
    SyncStatus(module: 'Messages', icon: Icons.chat, lastSynced: DateTime.now().subtract(const Duration(seconds: 30)),
        state: SyncState.synced, pendingItems: 0),
    SyncStatus(module: 'Contacts', icon: Icons.contacts, lastSynced: DateTime.now().subtract(const Duration(minutes: 5)),
        state: SyncState.synced, pendingItems: 0),
    SyncStatus(module: 'Orders', icon: Icons.receipt_long, lastSynced: DateTime.now().subtract(const Duration(minutes: 2)),
        state: SyncState.synced, pendingItems: 0),
    SyncStatus(module: 'Settings', icon: Icons.settings, lastSynced: DateTime.now().subtract(const Duration(hours: 1)),
        state: SyncState.pending, pendingItems: 2),
    SyncStatus(module: 'Media', icon: Icons.photo_library, lastSynced: DateTime.now().subtract(const Duration(hours: 3)),
        state: SyncState.syncing, pendingItems: 5),
  ];

  List<SyncStatus> get syncStatuses => _syncStatuses;

  // ═══════════════════════════════════════════════════════════════════════════
  // U8 - SYSTEM MONITOR STATE
  // ═══════════════════════════════════════════════════════════════════════════

  PerformanceSnapshot _performance = PerformanceSnapshot(
    cpuUsage: 0.23,
    memoryUsage: 0.67,
    batteryLevel: 0.82,
    networkLatencyMs: 45.0,
    fps: 60,
    timestamp: DateTime.now(),
  );

  PerformanceSnapshot get performance => _performance;

  DeviceInfoModel _deviceInfo = const DeviceInfoModel(
    deviceName: 'Pixel 7 Pro',
    osVersion: 'Android 14',
    appVersion: '2.4.1',
    buildNumber: '241',
    deviceId: 'PX7P-XXXX-XXXX',
    screenResolution: '1440 × 3120',
    locale: 'en_GH',
    timezone: 'Africa/Accra (GMT+0)',
    totalStorageMB: 50.0,
    freeStorageMB: 37.6,
    totalMemoryMB: 8192.0,
  );

  DeviceInfoModel get deviceInfo => _deviceInfo;

  // ─── System Logs (fallback pattern) ──────────────────────────────────────

  static final List<SystemLogEntry> _fallbackSystemLogs = [
    SystemLogEntry(
      id: 'log_1', message: 'App started successfully',
      level: LogLevel.info, source: 'Application',
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
    SystemLogEntry(
      id: 'log_2', message: 'Network latency spike detected: 120ms',
      level: LogLevel.warning, source: 'Network',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    SystemLogEntry(
      id: 'log_3', message: 'Background sync completed for messages',
      level: LogLevel.info, source: 'Sync',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    SystemLogEntry(
      id: 'log_4', message: 'Cache cleaned: 2.4 MB freed',
      level: LogLevel.debug, source: 'Storage',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    SystemLogEntry(
      id: 'log_5', message: 'Failed to sync media: timeout',
      level: LogLevel.error, source: 'Sync',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    SystemLogEntry(
      id: 'log_6', message: 'Security scan passed — no threats found',
      level: LogLevel.info, source: 'Security',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  List<SystemLogEntry> _systemLogs = [];

  List<SystemLogEntry> get systemLogs =>
      _systemLogs.isNotEmpty ? _systemLogs : _fallbackSystemLogs;

  LogLevel? _logFilter;
  LogLevel? get logFilter => _logFilter;

  List<SystemLogEntry> get filteredLogs {
    final source = systemLogs;
    if (_logFilter == null) return source;
    return source.where((l) => l.level == _logFilter).toList();
  }

  void setLogFilter(LogLevel? level) {
    _logFilter = level;
    notifyListeners();
  }

  // ─── Active Sessions (fallback pattern) ──────────────────────────────────

  static final List<ActiveSession> _fallbackActiveSessions = [
    ActiveSession(
      id: 'sess_1', deviceName: 'Pixel 7 Pro', location: 'Accra, Ghana',
      ipAddress: '192.168.1.xxx', startedAt: DateTime.now().subtract(const Duration(hours: 2)),
      isCurrent: true,
    ),
    ActiveSession(
      id: 'sess_2', deviceName: 'Chrome on Windows', location: 'Accra, Ghana',
      ipAddress: '41.242.xxx.xxx', startedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  List<ActiveSession> _activeSessions = [];

  List<ActiveSession> get activeSessions =>
      _activeSessions.isNotEmpty ? _activeSessions : _fallbackActiveSessions;

  void terminateSession(String id) {
    _ensureMutableSessions();
    _activeSessions.removeWhere((s) => s.id == id && !s.isCurrent);
    notifyListeners();
  }

  /// Ensures _activeSessions is populated so mutation works against a real list.
  void _ensureMutableSessions() {
    if (_activeSessions.isEmpty) {
      _activeSessions = List<ActiveSession>.from(_fallbackActiveSessions);
    }
  }

  List<SystemMetric> get systemMetrics => [
    SystemMetric(
      label: 'CPU Usage', value: '${(_performance.cpuUsage * 100).toStringAsFixed(0)}%',
      icon: Icons.memory, color: const Color(0xFF3B82F6),
      percentage: _performance.cpuUsage, trend: MetricTrend.stable,
    ),
    SystemMetric(
      label: 'Memory', value: '${(_performance.memoryUsage * 100).toStringAsFixed(0)}%',
      icon: Icons.storage, color: const Color(0xFF8B5CF6),
      percentage: _performance.memoryUsage, trend: MetricTrend.up,
    ),
    SystemMetric(
      label: 'Battery', value: '${(_performance.batteryLevel * 100).toStringAsFixed(0)}%',
      icon: Icons.battery_std, color: const Color(0xFF10B981),
      percentage: _performance.batteryLevel, trend: MetricTrend.down,
    ),
    SystemMetric(
      label: 'Network', value: '${_performance.networkLatencyMs.toStringAsFixed(0)}ms',
      icon: Icons.signal_wifi_4_bar, color: const Color(0xFFF59E0B),
      percentage: (_performance.networkLatencyMs / 200).clamp(0.0, 1.0), trend: MetricTrend.stable,
    ),
    SystemMetric(
      label: 'FPS', value: '${_performance.fps}',
      icon: Icons.speed, color: const Color(0xFF06B6D4),
      percentage: _performance.fps / 60.0, trend: MetricTrend.stable,
    ),
    SystemMetric(
      label: 'Storage', value: '${_deviceInfo.freeStorageMB.toStringAsFixed(1)} MB free',
      icon: Icons.sd_storage, color: const Color(0xFFEC4899),
      percentage: _deviceInfo.freeStorageMB / _deviceInfo.totalStorageMB,
      trend: MetricTrend.stable,
    ),
  ];
}
