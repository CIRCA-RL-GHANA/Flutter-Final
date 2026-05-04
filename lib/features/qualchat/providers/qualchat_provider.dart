/// qualChat Module — State Management & Demo Data
/// Provides all state for 15 screens + prompt widget
/// Wired to SocialService with fallback demo data for offline mode.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show RangeValues;

import '../../../core/services/social_service.dart';
import '../models/qualchat_models.dart';

class QualChatProvider extends ChangeNotifier {
  // ──────────────────────────────────────────────
  //  SERVICE & LOADING STATE
  // ──────────────────────────────────────────────

  final SocialService _socialService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  QualChatProvider({SocialService? socialService})
      : _socialService = socialService ?? SocialService();

  /// Bootstrap: load conversations + heyya requests from backend.
  Future<void> init() async {
    await Future.wait([
      loadConversations(),
      loadHeyYaRequests(),
    ]);
  }

  // ──────────────────────────────────────────────
  //  DASHBOARD STATE
  // ──────────────────────────────────────────────

  ChatMode _mode = ChatMode.social;
  ChatMode get mode => _mode;
  void setMode(ChatMode m) {
    _mode = m;
    notifyListeners();
  }

  QualChatWidgetState _widgetState = QualChatWidgetState.loaded;
  QualChatWidgetState get widgetState => _widgetState;
  void setWidgetState(QualChatWidgetState s) {
    _widgetState = s;
    notifyListeners();
  }

  // ──────────────────────────────────────────────
  //  PRESENCE DATA
  // ──────────────────────────────────────────────

  static const PresenceStats presenceStats = PresenceStats(
    online: 92,
    idle: 28,
    offline: 8,
    total: 128,
    onlineChangePercent: 12,
    idleChangePercent: -4,
    offlineChangePercent: -8,
  );

  PresenceFilter _presenceFilter = PresenceFilter.individual;
  PresenceFilter get presenceFilter => _presenceFilter;
  void setPresenceFilter(PresenceFilter f) {
    _presenceFilter = f;
    notifyListeners();
  }

  PresenceStatus? _statusFilter;
  PresenceStatus? get statusFilter => _statusFilter;
  void setStatusFilter(PresenceStatus? s) {
    _statusFilter = s;
    notifyListeners();
  }

  String _presenceSearch = '';
  String get presenceSearch => _presenceSearch;
  void setPresenceSearch(String s) {
    _presenceSearch = s;
    notifyListeners();
  }

  static final List<ActivityDataPoint> activityData = [
    ActivityDataPoint(label: '09:00', value: 0.2, time: DateTime(2026, 2, 8, 9)),
    ActivityDataPoint(label: '10:00', value: 0.4, time: DateTime(2026, 2, 8, 10)),
    ActivityDataPoint(label: '11:00', value: 0.7, time: DateTime(2026, 2, 8, 11)),
    ActivityDataPoint(label: '12:00', value: 0.9, time: DateTime(2026, 2, 8, 12)),
  ];

  // ──────────────────────────────────────────────
  //  CHAT USERS
  // ──────────────────────────────────────────────

  static final List<ChatUser> _fallbackUsers = [
    ChatUser(
      id: 'u1', name: 'Alex Morgan', role: 'Mentor',
      presence: PresenceStatus.online,
      statusMessage: 'Available for quick chats',
      lastSeen: DateTime.now(),
      department: 'Engineering', avgResponseMinutes: 3, isFavorite: true,
    ),
    ChatUser(
      id: 'u2', name: 'Sarah Chen', role: 'Peer',
      presence: PresenceStatus.online,
      statusMessage: 'In meeting until 3 PM',
      lastSeen: DateTime.now(), department: 'Design', avgResponseMinutes: 8,
    ),
    ChatUser(
      id: 'u3', name: 'David Osei', role: 'Manager',
      presence: PresenceStatus.idle,
      statusMessage: 'Away',
      lastSeen: DateTime.now().subtract(const Duration(minutes: 5)),
      department: 'Operations', avgResponseMinutes: 12,
    ),
    ChatUser(
      id: 'u4', name: 'Lisa Park', role: 'Driver',
      presence: PresenceStatus.offline,
      statusMessage: 'Shift ends 6 PM',
      lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
      department: 'Logistics', avgResponseMinutes: 30,
    ),
    ChatUser(
      id: 'u5', name: 'John Doe', role: 'Lead',
      presence: PresenceStatus.online,
      lastSeen: DateTime.now(), department: 'Engineering', avgResponseMinutes: 5,
    ),
    ChatUser(
      id: 'u6', name: 'Maria Santos', role: 'Senior',
      presence: PresenceStatus.online,
      lastSeen: DateTime.now(), department: 'Engineering', avgResponseMinutes: 7,
    ),
    ChatUser(
      id: 'u7', name: 'Tom Harris', role: 'Junior',
      presence: PresenceStatus.idle,
      lastSeen: DateTime.now().subtract(const Duration(minutes: 10)),
      department: 'Engineering', avgResponseMinutes: 15,
    ),
  ];

  /// Public accessor — preserved for backward compatibility.
  static final List<ChatUser> allUsers = _fallbackUsers;

  List<ChatUser> _users = [];

  List<ChatUser> get filteredUsers {
    var list = (_users.isNotEmpty ? _users : _fallbackUsers).toList();
    if (_statusFilter != null) {
      list = list.where((u) => u.presence == _statusFilter).toList();
    }
    if (_presenceSearch.isNotEmpty) {
      final q = _presenceSearch.toLowerCase();
      list = list.where((u) =>
        u.name.toLowerCase().contains(q) ||
        u.role.toLowerCase().contains(q) ||
        (u.department?.toLowerCase().contains(q) ?? false)
      ).toList();
    }
    return list;
  }

  // ──────────────────────────────────────────────
  //  CONVERSATIONS
  // ──────────────────────────────────────────────

  ChatListTab _chatTab = ChatListTab.all;
  ChatListTab get chatTab => _chatTab;
  void setChatTab(ChatListTab t) {
    _chatTab = t;
    notifyListeners();
  }

  String _chatSearch = '';
  String get chatSearch => _chatSearch;
  void setChatSearch(String s) {
    _chatSearch = s;
    notifyListeners();
  }

  static final List<Conversation> _fallbackConversations = [
    Conversation(
      id: 'c1', type: ChatType.individual, title: 'Alex Morgan',
      lastMessage: 'Let\'s sync at 3 PM today',
      lastSenderName: 'Alex Morgan',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 2)),
      unreadCount: 3, isPinned: true, priority: ConversationPriority.high,
      participants: [_fallbackUsers[0]], onlineCount: 1, relationshipScore: 0.92,
    ),
    Conversation(
      id: 'c2', type: ChatType.group, title: 'Project Team',
      lastMessage: 'Maria: Updated the requirements...',
      lastSenderName: 'Maria Santos',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
      unreadCount: 12, isPinned: true, priority: ConversationPriority.high,
      participants: [_fallbackUsers[0], _fallbackUsers[1], _fallbackUsers[4], _fallbackUsers[5]],
      onlineCount: 4,
    ),
    Conversation(
      id: 'c3', type: ChatType.individual, title: 'Sarah Chen',
      lastMessage: 'Budget approved!',
      lastSenderName: 'Sarah Chen',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 1, participants: [_fallbackUsers[1]], onlineCount: 1,
    ),
    Conversation(
      id: 'c4', type: ChatType.individual, title: 'David Osei',
      lastMessage: 'Meeting notes attached',
      lastSenderName: 'David Osei',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
      participants: [_fallbackUsers[2]],
    ),
    Conversation(
      id: 'c5', type: ChatType.individual, title: 'Lisa Park',
      lastMessage: 'Delivery complete',
      lastSenderName: 'Lisa Park',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      participants: [_fallbackUsers[3]],
    ),
    Conversation(
      id: 'c6', type: ChatType.group, title: 'Team Alpha',
      lastMessage: 'Sprint review tomorrow',
      lastSenderName: 'John Doe',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
      participants: [_fallbackUsers[0], _fallbackUsers[4], _fallbackUsers[5], _fallbackUsers[6]],
      onlineCount: 3,
    ),
    Conversation(
      id: 'c7', type: ChatType.group, title: 'Social Club',
      lastMessage: 'Who\'s up for lunch?',
      lastSenderName: 'Tom Harris',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 4)),
      participants: _fallbackUsers, onlineCount: 5,
    ),
  ];

  /// Public accessor — preserved for backward compatibility.
  static final List<Conversation> conversations = _fallbackConversations;

  List<Conversation> _conversations = [];

  List<Conversation> get filteredConversations {
    final source = _conversations.isNotEmpty ? _conversations : _fallbackConversations;
    var list = source.where((c) => !c.isArchived).toList();
    switch (_chatTab) {
      case ChatListTab.unread:
        list = list.where((c) => c.unreadCount > 0).toList();
      case ChatListTab.priority:
        list = list.where((c) =>
          c.priority == ConversationPriority.high ||
          c.priority == ConversationPriority.critical
        ).toList();
      case ChatListTab.groups:
        list = list.where((c) => c.type == ChatType.group).toList();
      case ChatListTab.all:
        break;
    }
    if (_chatSearch.isNotEmpty) {
      final q = _chatSearch.toLowerCase();
      list = list.where((c) =>
        c.title.toLowerCase().contains(q) ||
        c.lastMessage.toLowerCase().contains(q)
      ).toList();
    }
    return list;
  }

  List<Conversation> get pinnedConversations =>
      filteredConversations.where((c) => c.isPinned).toList();

  List<Conversation> get unpinnedConversations =>
      filteredConversations.where((c) => !c.isPinned).toList();

  int get totalUnreadCount {
    final source = _conversations.isNotEmpty ? _conversations : _fallbackConversations;
    return source.fold(0, (sum, c) => sum + c.unreadCount);
  }

  // ──────────────────────────────────────────────
  //  MESSAGES (for Chat Thread — Screen 10)
  // ──────────────────────────────────────────────

  String? _activeConversationId;
  String? get activeConversationId => _activeConversationId;
  void openConversation(String id) {
    _activeConversationId = id;
    notifyListeners();
  }

  static final List<ChatMessage> _fallbackMessages = [
    ChatMessage(
      id: 'm1', senderId: 'u1', senderName: 'Alex Morgan',
      type: MessageType.text,
      content: 'Hey! Are we still meeting at 3?',
      timestamp: DateTime(2026, 2, 8, 14, 30),
      status: DeliveryStatus.read,
    ),
    ChatMessage(
      id: 'm2', senderId: 'me', senderName: 'You',
      type: MessageType.text,
      content: 'Yes, conference room B',
      timestamp: DateTime(2026, 2, 8, 14, 31),
      status: DeliveryStatus.read,
    ),
    ChatMessage(
      id: 'm3', senderId: 'u1', senderName: 'Alex Morgan',
      type: MessageType.text,
      content: 'Perfect. I\'ll bring the project docs',
      timestamp: DateTime(2026, 2, 8, 14, 31),
      status: DeliveryStatus.read,
      reactions: [MessageReaction.heart],
    ),
    ChatMessage(
      id: 'm4', senderId: 'me', senderName: 'You',
      type: MessageType.text,
      content: 'Great. Also need to discuss budget',
      timestamp: DateTime(2026, 2, 8, 14, 32),
      status: DeliveryStatus.sent,
    ),
    ChatMessage(
      id: 'm5', senderId: 'me', senderName: 'You',
      type: MessageType.file,
      content: 'budget_q2.pdf',
      timestamp: DateTime(2026, 2, 8, 14, 32),
      status: DeliveryStatus.sent,
      attachmentName: 'budget_q2.pdf',
      attachmentSizeMb: 2.4,
    ),
  ];

  /// Public accessor — preserved for backward compatibility.
  static final List<ChatMessage> demoMessages = _fallbackMessages;

  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages =>
      _messages.isNotEmpty ? _messages : _fallbackMessages;

  /// The currently-open conversation (looked up by [activeConversationId]).
  Conversation? get activeConversation {
    if (_activeConversationId == null) return null;
    final source =
        _conversations.isNotEmpty ? _conversations : _fallbackConversations;
    try {
      return source.firstWhere((c) => c.id == _activeConversationId);
    } catch (_) {
      return null;
    }
  }

  // ──────────────────────────────────────────────
  //  HEY YA DATA (Owner only)
  // ──────────────────────────────────────────────

  HeyYaTab _heyYaTab = HeyYaTab.all;
  HeyYaTab get heyYaTab => _heyYaTab;
  void setHeyYaTab(HeyYaTab t) {
    _heyYaTab = t;
    notifyListeners();
  }

  HeyYaStatus? _heyYaStatusFilter;
  HeyYaStatus? get heyYaStatusFilter => _heyYaStatusFilter;
  void setHeyYaStatusFilter(HeyYaStatus? s) {
    _heyYaStatusFilter = s;
    notifyListeners();
  }

  int get activeSparks {
    final source = _heyYaRequests.isNotEmpty ? _heyYaRequests : _fallbackHeyYas;
    return source.where((h) => h.status == HeyYaStatus.pending).length;
  }

  int get matchCount {
    final source = _heyYaRequests.isNotEmpty ? _heyYaRequests : _fallbackHeyYas;
    return source.where((h) => h.status == HeyYaStatus.accepted).length;
  }

  int get energyLevel => 84;

  static final List<ConnectionSuccess> connectionHistory = [
    const ConnectionSuccess(index: 1, isSuccess: true),
    const ConnectionSuccess(index: 2, isSuccess: true),
    const ConnectionSuccess(index: 3, isSuccess: true),
    const ConnectionSuccess(index: 4, isSuccess: true),
    const ConnectionSuccess(index: 5, isSuccess: true),
    const ConnectionSuccess(index: 6, isSuccess: false),
    const ConnectionSuccess(index: 7, isSuccess: false),
    const ConnectionSuccess(index: 8, isSuccess: true),
    const ConnectionSuccess(index: 9, isSuccess: false),
    const ConnectionSuccess(index: 10, isSuccess: false),
  ];

  static final List<HeyYaRequest> _fallbackHeyYas = [
    HeyYaRequest(
      id: 'h1',
      person: ChatUser(
        id: 'hu1', name: 'Alex Morgan', role: 'Creative Designer',
        presence: PresenceStatus.online,
        lastSeen: DateTime.now(), distanceKm: 8,
      ),
      status: HeyYaStatus.pending,
      matchPercentage: 92,
      message: 'Love your energy! Let\'s chat?',
      sentAt: DateTime.now().subtract(const Duration(days: 2)),
      expiresAt: DateTime.now().add(const Duration(days: 2, hours: 4)),
      isSentByMe: true,
      viewCount: 3,
      timeline: [
        TimelineEvent(
          type: TimelineEventType.sent,
          description: 'You sent Hey Ya',
          timestamp: DateTime(2026, 2, 6, 14, 30),
        ),
        TimelineEvent(
          type: TimelineEventType.seen,
          description: 'Alex saw your vibe',
          timestamp: DateTime(2026, 2, 6, 15, 45),
        ),
        TimelineEvent(
          type: TimelineEventType.viewed,
          description: 'Viewed photo 3 times',
          timestamp: DateTime(2026, 2, 6, 16, 20),
          detail: '3 views',
        ),
      ],
    ),
    HeyYaRequest(
      id: 'h2',
      person: ChatUser(
        id: 'hu2', name: 'Sam Boateng', role: 'Photographer',
        presence: PresenceStatus.idle,
        lastSeen: DateTime.now().subtract(const Duration(hours: 1)), distanceKm: 15,
      ),
      status: HeyYaStatus.accepted,
      matchPercentage: 88,
      message: 'Your travel photos are amazing!',
      sentAt: DateTime.now().subtract(const Duration(days: 5)),
      isSentByMe: false,
      viewCount: 8,
    ),
    HeyYaRequest(
      id: 'h3',
      person: ChatUser(
        id: 'hu3', name: 'Leo Mensah', role: 'Entrepreneur',
        presence: PresenceStatus.offline,
        lastSeen: DateTime.now().subtract(const Duration(days: 1)), distanceKm: 3,
      ),
      status: HeyYaStatus.pending,
      matchPercentage: 84,
      message: 'Hey! Fellow adventurer here 🏔️',
      sentAt: DateTime.now().subtract(const Duration(days: 3)),
      expiresAt: DateTime.now().add(const Duration(days: 1)),
      isSentByMe: true,
      viewCount: 1,
    ),
    HeyYaRequest(
      id: 'h4',
      person: ChatUser(
        id: 'hu4', name: 'Ama Asante', role: 'Writer',
        presence: PresenceStatus.online,
        lastSeen: DateTime.now(), distanceKm: 22,
      ),
      status: HeyYaStatus.expired,
      matchPercentage: 76,
      sentAt: DateTime.now().subtract(const Duration(days: 10)),
      isSentByMe: true,
    ),
    HeyYaRequest(
      id: 'h5',
      person: ChatUser(
        id: 'hu5', name: 'Kwame Ofori', role: 'Developer',
        presence: PresenceStatus.online,
        lastSeen: DateTime.now(), distanceKm: 5,
      ),
      status: HeyYaStatus.accepted,
      matchPercentage: 90,
      message: 'We should pair program sometime!',
      sentAt: DateTime.now().subtract(const Duration(days: 7)),
      isSentByMe: false,
      viewCount: 12,
    ),
  ];

  /// Public accessor — preserved for backward compatibility.
  static final List<HeyYaRequest> heyYaRequests = _fallbackHeyYas;

  List<HeyYaRequest> _heyYaRequests = [];

  List<HeyYaRequest> get filteredHeyYas {
    final source = _heyYaRequests.isNotEmpty ? _heyYaRequests : _fallbackHeyYas;
    var list = source.toList();
    switch (_heyYaTab) {
      case HeyYaTab.sent:
        list = list.where((h) => h.isSentByMe).toList();
      case HeyYaTab.received:
        list = list.where((h) => !h.isSentByMe).toList();
      case HeyYaTab.matches:
        list = list.where((h) => h.status == HeyYaStatus.accepted).toList();
      case HeyYaTab.all:
        break;
    }
    if (_heyYaStatusFilter != null) {
      list = list.where((h) => h.status == _heyYaStatusFilter).toList();
    }
    return list;
  }

  // ──────────────────────────────────────────────
  //  VIBE IMAGE (Screen 5)
  // ──────────────────────────────────────────────

  static const VibeImage currentVibeImage = VibeImage(
    id: 'vi1',
    isActive: true,
    expiresAt: null,
    views: 1248,
    likes: 42,
    comments: 18,
    connections: 5,
    matches: 3,
    remainingPercent: 65,
    analysisText:
        'Your photo shows confidence and approachability. '
        'Lighting: Excellent • Composition: Good. '
        'Suggested: Add a smile for 23% more responses',
  );

  // ──────────────────────────────────────────────
  //  SMART NUDGES (Screen 11)
  // ──────────────────────────────────────────────

  int _currentNudgeIndex = 0;
  int get currentNudgeIndex => _currentNudgeIndex;

  static final List<SmartNudge> nudges = [
    SmartNudge(
      id: 'n1', type: NudgeType.followUp,
      person: _fallbackHeyYas[0].person, matchPercentage: 92,
      prompt: 'Follow up?',
      suggestedOpener: 'Hey Alex! Loved our chat about travel destinations...',
      reason: 'You matched 3 days ago. Send a message to keep the spark alive!',
      createdAt: DateTime.now(),
    ),
    SmartNudge(
      id: 'n2', type: NudgeType.reEngagement,
      person: _fallbackHeyYas[1].person, matchPercentage: 88,
      prompt: 'Reconnect with Sam?',
      suggestedOpener: 'Hey Sam! Have you been on any photo trips lately?',
      reason: 'Your conversation went quiet 5 days ago.',
      createdAt: DateTime.now(),
    ),
    SmartNudge(
      id: 'n3', type: NudgeType.compatibility,
      person: _fallbackHeyYas[4].person, matchPercentage: 90,
      prompt: 'High match alert!',
      suggestedOpener: 'Hey Kwame! Fellow developer here — what tech stack do you use?',
      reason: 'New high-match user is available and online right now.',
      createdAt: DateTime.now(),
    ),
  ];

  void nextNudge() {
    if (_currentNudgeIndex < nudges.length - 1) {
      _currentNudgeIndex++;
      notifyListeners();
    }
  }

  void previousNudge() {
    if (_currentNudgeIndex > 0) {
      _currentNudgeIndex--;
      notifyListeners();
    }
  }

  void handleNudgeAction(NudgeAction action) {
    // In production: process the action, then advance
    nextNudge();
  }

  // ──────────────────────────────────────────────
  //  ACTION CENTER (Screen 12)
  // ──────────────────────────────────────────────

  int get profileCompleteness => 75;

  static final List<ActionTask> tasks = [
    ActionTask(
      id: 't1', type: TaskType.communication, priority: TaskPriority.high,
      status: TaskStatus.actNow,
      title: 'Reply to Sam',
      description: 'Waiting for your response',
      dueDate: DateTime.now(),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      quickActions: ['Reply Now', '1h', 'Move'],
    ),
    ActionTask(
      id: 't2', type: TaskType.profile, priority: TaskPriority.medium,
      status: TaskStatus.actNow,
      title: 'Update profile photo',
      description: 'Current photo is 2 weeks old',
      dueDate: DateTime.now(),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      quickActions: ['Take Photo', 'Choose', 'Tomorrow'],
    ),
    ActionTask(
      id: 't3', type: TaskType.communication, priority: TaskPriority.high,
      status: TaskStatus.actNow,
      title: 'Follow up with Leo',
      description: 'Hey Ya pending for 3 days',
      dueDate: DateTime.now(),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      quickActions: ['Message', 'Nudge', 'Pass'],
    ),
    ActionTask(
      id: 't4', type: TaskType.discovery, priority: TaskPriority.low,
      status: TaskStatus.considerLater,
      title: 'Review 5 new matches',
      description: 'New matches since yesterday',
      createdAt: DateTime.now(),
    ),
    ActionTask(
      id: 't5', type: TaskType.profile, priority: TaskPriority.low,
      status: TaskStatus.considerLater,
      title: 'Complete dating preferences',
      description: 'Finish setting up your vibe tags',
      createdAt: DateTime.now(),
    ),
    ActionTask(
      id: 't6', type: TaskType.communication, priority: TaskPriority.medium,
      status: TaskStatus.considerLater,
      title: 'Send 2 follow-up messages',
      description: 'Keep conversations going',
      createdAt: DateTime.now(),
    ),
    ActionTask(
      id: 't7', type: TaskType.profile, priority: TaskPriority.low,
      status: TaskStatus.considerLater,
      title: 'Update your bio',
      description: 'Bio was last updated 30 days ago',
      createdAt: DateTime.now(),
    ),
  ];

  static const List<AISuggestion> aiSuggestions = [
    AISuggestion(id: 'ai1', text: 'Try adding "Travel" to your interests'),
    AISuggestion(id: 'ai2', text: 'Increase discovery radius to 50km'),
    AISuggestion(id: 'ai3', text: 'Schedule Hey Ya refresh for Friday'),
    AISuggestion(id: 'ai4', text: 'Join "Adventure Seekers" social group'),
    AISuggestion(id: 'ai5', text: 'Read article: "First date conversation tips"'),
  ];

  static const TaskAnalytics taskAnalytics = TaskAnalytics(
    completedThisWeek: 8,
    totalThisWeek: 12,
    avgCompletionDays: 2.3,
    mostProductiveDay: 'Tuesday',
    mostCommonTask: 'Profile updates',
    aiInsight:
        'You complete communication tasks 40% faster. '
        'Consider scheduling profile tasks on weekends. '
        'Your response rate improves by 2.3x with reminders.',
  );

  // ──────────────────────────────────────────────
  //  PREFERENCES (Screen 4)
  // ──────────────────────────────────────────────

  bool _isOpenToConnections = true;
  bool get isOpenToConnections => _isOpenToConnections;
  void toggleOpenToConnections() {
    _isOpenToConnections = !_isOpenToConnections;
    notifyListeners();
  }

  bool _incognitoMode = false;
  bool get incognitoMode => _incognitoMode;
  void toggleIncognito() {
    _incognitoMode = !_incognitoMode;
    notifyListeners();
  }

  RangeValues _ageRange = const RangeValues(25, 35);
  RangeValues get ageRange => _ageRange;
  void setAgeRange(RangeValues r) {
    _ageRange = r;
    notifyListeners();
  }

  double _distanceKm = 50;
  double get distanceKm => _distanceKm;
  void setDistanceKm(double d) {
    _distanceKm = d;
    notifyListeners();
  }

  final Set<VibeTag> _selectedVibeTags = {VibeTag.adventurous, VibeTag.creative, VibeTag.travel};
  Set<VibeTag> get selectedVibeTags => _selectedVibeTags;
  void toggleVibeTag(VibeTag t) {
    if (_selectedVibeTags.contains(t)) {
      _selectedVibeTags.remove(t);
    } else if (_selectedVibeTags.length < 5) {
      _selectedVibeTags.add(t);
    }
    notifyListeners();
  }

  static const List<CompatibilityWeight> compatibilityWeights = [
    CompatibilityWeight(label: 'Interests', percent: 85),
    CompatibilityWeight(label: 'Values', percent: 70),
    CompatibilityWeight(label: 'Lifestyle', percent: 55),
    CompatibilityWeight(label: 'Background', percent: 40),
  ];

  // Privacy toggles
  final Map<String, bool> _privacyToggles = {
    'Show online status': true,
    'Show read receipts': true,
    'Show typing indicator': false,
    'Allow notifications': true,
    'Share activity status': false,
  };
  Map<String, bool> get privacyToggles => Map.unmodifiable(_privacyToggles);
  void setPrivacyToggle(String key, bool val) {
    _privacyToggles[key] = val;
    notifyListeners();
  }

  // ──────────────────────────────────────────────
  //  CONVERSATION INSIGHTS (Dashboard Section C)
  // ──────────────────────────────────────────────

  static const List<ConversationInsight> insights = [
    ConversationInsight(
      priority: InsightPriority.unresolved,
      title: 'Budget approval pending',
    ),
    ConversationInsight(
      priority: InsightPriority.followUp,
      title: 'Meeting tomorrow at 2 PM',
    ),
    ConversationInsight(
      priority: InsightPriority.completed,
      title: 'Project delivered',
    ),
  ];

  static const SentimentTrend sentimentTrend = SentimentTrend.positive;
  static const int avgResponseMinutes = 12;

  static final List<RecentMedia> recentMedia = [
    RecentMedia(id: 'rm1', type: MessageType.image, timestamp: DateTime.now()),
    RecentMedia(id: 'rm2', type: MessageType.video, timestamp: DateTime.now()),
    RecentMedia(id: 'rm3', type: MessageType.file, timestamp: DateTime.now()),
  ];

  // ──────────────────────────────────────────────
  //  ARCHIVED CHATS (Screen 9)
  // ──────────────────────────────────────────────

  ArchiveSort _archiveSort = ArchiveSort.newest;
  ArchiveSort get archiveSort => _archiveSort;
  void setArchiveSort(ArchiveSort s) {
    _archiveSort = s;
    notifyListeners();
  }

  static final List<ArchivedChat> archivedChats = [
    ArchivedChat(
      conversation: Conversation(
        id: 'ac1', type: ChatType.individual, title: 'Alice Roberts',
        lastMessage: 'Thanks for the help with...',
        lastSenderName: 'Alice Roberts',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
        isArchived: true,
      ),
      archivedAt: DateTime.now().subtract(const Duration(hours: 2)),
      sizeMb: 2.4, messageCount: 45,
    ),
    ArchivedChat(
      conversation: Conversation(
        id: 'ac2', type: ChatType.group, title: 'Team Beta',
        lastMessage: 'Weekly sync notes and...',
        lastSenderName: 'Team Beta',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
        isArchived: true,
      ),
      archivedAt: DateTime.now().subtract(const Duration(days: 1)),
      sizeMb: 8.1, messageCount: 120,
    ),
    ArchivedChat(
      conversation: Conversation(
        id: 'ac3', type: ChatType.individual, title: 'Customer Support',
        lastMessage: 'Issue #45 resolved',
        lastSenderName: 'Support',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 3)),
        isArchived: true,
      ),
      archivedAt: DateTime.now().subtract(const Duration(days: 3)),
      sizeMb: 1.2, messageCount: 22,
    ),
  ];

  double get totalArchivedSizeMb =>
      archivedChats.fold(0.0, (sum, a) => sum + a.sizeMb);

  void restoreAllArchived() {
    archivedChats.clear();
    notifyListeners();
  }

  void emptyArchive() {
    archivedChats.clear();
    notifyListeners();
  }

  void deleteArchivedChat(String id) {
    archivedChats.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  void restoreArchivedChat(String id) {
    archivedChats.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // ──────────────────────────────────────────────
  //  SETTINGS (Screen 13)
  // ──────────────────────────────────────────────

  final Map<String, bool> _settingsToggles = {
    // Notifications
    'New messages': true,
    'Message reactions': true,
    'Typing indicators': false,
    'Hey Ya matches': true,
    'Hey Ya views': false,
    // Privacy
    'Online status': true,
    'Read receipts': true,
    'Typing indicator': false,
    'End-to-end encryption': true,
    'Auto-delete messages': false,
    // Media
    'Auto-download photos': true,
    'Auto-download videos': false,
    'Auto-download documents': true,
    // Accessibility
    'VoiceOver support': true,
    'Reduce motion': true,
    'High contrast': false,
    'Screen reader optimizations': true,
  };

  Map<String, bool> get settingsToggles => Map.unmodifiable(_settingsToggles);
  void setSettingToggle(String key, bool val) {
    _settingsToggles[key] = val;
    notifyListeners();
  }

  int _fontSizeIndex = 1; // 0=small, 1=medium, 2=large
  int get fontSizeIndex => _fontSizeIndex;
  void setFontSizeIndex(int i) {
    _fontSizeIndex = i;
    notifyListeners();
  }

  int _themeIndex = 0; // 0=System, 1=Light, 2=Dark, 3=Auto
  int get themeIndex => _themeIndex;
  void setThemeIndex(int i) {
    _themeIndex = i;
    notifyListeners();
  }

  int _bubbleStyleIndex = 0; // 0=Default, 1=Minimal, 2=Fancy
  int get bubbleStyleIndex => _bubbleStyleIndex;
  void setBubbleStyleIndex(int i) {
    _bubbleStyleIndex = i;
    notifyListeners();
  }

  // ──────────────────────────────────────────────
  //  ONBOARDING (Screen 14)
  // ──────────────────────────────────────────────

  int _onboardingStep = 0;
  int get onboardingStep => _onboardingStep;
  void setOnboardingStep(int s) {
    _onboardingStep = s;
    notifyListeners();
  }

  void nextOnboardingStep() {
    if (_onboardingStep < 3) {
      _onboardingStep++;
      notifyListeners();
    }
  }

  ChatUsageType? _selectedUsageType;
  ChatUsageType? get selectedUsageType => _selectedUsageType;
  void setUsageType(ChatUsageType t) {
    _selectedUsageType = t;
    notifyListeners();
  }

  // ──────────────────────────────────────────────
  //  NEW CHAT (Screen 7)
  // ──────────────────────────────────────────────

  ChatType _newChatType = ChatType.individual;
  ChatType get newChatType => _newChatType;
  void setNewChatType(ChatType t) {
    _newChatType = t;
    notifyListeners();
  }

  RecipientFilter _recipientFilter = RecipientFilter.online;
  RecipientFilter get recipientFilter => _recipientFilter;
  void setRecipientFilter(RecipientFilter f) {
    _recipientFilter = f;
    notifyListeners();
  }

  ChatUser? _selectedRecipient;
  ChatUser? get selectedRecipient => _selectedRecipient;
  void selectRecipient(ChatUser? u) {
    _selectedRecipient = u;
    notifyListeners();
  }

  final List<ChatUser> _groupMembers = [];
  List<ChatUser> get groupMembers => List.unmodifiable(_groupMembers);
  void addGroupMember(ChatUser u) {
    if (!_groupMembers.any((m) => m.id == u.id)) {
      _groupMembers.add(u);
      notifyListeners();
    }
  }
  void removeGroupMember(String id) {
    _groupMembers.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  // ══════════════════════════════════════════════
  //  ASYNC DATA-LOADING (wired to SocialService)
  // ══════════════════════════════════════════════

  /// Load conversations from backend; falls back to demo data on error.
  Future<void> loadConversations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _socialService.getChatSessions();
      if (response.success && response.data != null) {
        _conversations = response.data!
            .map((json) => _conversationFromJson(json))
            .toList();
      } else {
        _conversations = List.of(_fallbackConversations);
      }
    } catch (_) {
      _conversations = List.of(_fallbackConversations);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load messages for a specific chat session; falls back to demo data.
  Future<void> loadMessages(String sessionId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _socialService.getMessages(sessionId: sessionId);
      if (response.success && response.data != null) {
        _messages = response.data!
            .map((json) => _messageFromJson(json))
            .toList();
      } else {
        _messages = List.of(_fallbackMessages);
      }
    } catch (_) {
      _messages = List.of(_fallbackMessages);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load heyya requests from backend; falls back to demo data.
  Future<void> loadHeyYaRequests() async {
    // HeyYa listing isn't exposed via a dedicated list endpoint in
    // SocialService yet, so we keep fallback data. When the backend
    // provides an endpoint, swap in the call here.
    _heyYaRequests = List.of(_fallbackHeyYas);
    notifyListeners();
  }

  /// Send a chat message via the backend and add it locally on success.
  Future<void> sendMessage(String sessionId, String content) async {
    try {
      final response = await _socialService.sendMessage(
        sessionId: sessionId,
        content: content,
      );
      if (response.success && response.data != null) {
        final msg = _messageFromJson(response.data!);
        _messages = [..._messages, msg];
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to send message';
      notifyListeners();
    }
  }

  /// Send a HeyYa request to another user.
  Future<bool> sendHeyYa(String targetUserId, {String? message}) async {
    try {
      final response = await _socialService.sendHeyya(
        targetUserId: targetUserId,
        message: message,
      );
      if (response.success) {
        await loadHeyYaRequests();
        return true;
      }
      return false;
    } catch (_) {
      _errorMessage = 'Failed to send HeyYa';
      notifyListeners();
      return false;
    }
  }

  /// Respond to a HeyYa request (accept / decline).
  Future<bool> respondToHeyYa(String heyyaId, {required bool accepted}) async {
    try {
      final response = await _socialService.respondToHeyya(
        heyyaId: heyyaId,
        accepted: accepted,
      );
      if (response.success) {
        await loadHeyYaRequests();
        return true;
      }
      return false;
    } catch (_) {
      _errorMessage = 'Failed to respond to HeyYa';
      notifyListeners();
      return false;
    }
  }

  /// Create a new conversation / chat session.
  Future<Conversation?> createConversation(List<String> participantIds) async {
    try {
      if (participantIds.length < 2) return null;
      final response = await _socialService.createChatSession(
        user1Id: participantIds[0],
        user2Id: participantIds[1],
      );
      if (response.success && response.data != null) {
        final conv = _conversationFromJson(response.data!);
        _conversations = [..._conversations, conv];
        notifyListeners();
        return conv;
      }
      return null;
    } catch (_) {
      _errorMessage = 'Failed to create conversation';
      notifyListeners();
      return null;
    }
  }

  // ══════════════════════════════════════════════
  //  JSON → MODEL HELPERS (models lack fromJson)
  // ══════════════════════════════════════════════

  static PresenceStatus _presenceFromString(String? s) {
    switch (s) {
      case 'online':
        return PresenceStatus.online;
      case 'idle':
        return PresenceStatus.idle;
      default:
        return PresenceStatus.offline;
    }
  }

  static HeyYaStatus _heyYaStatusFromString(String? s) {
    switch (s) {
      case 'pending':
        return HeyYaStatus.pending;
      case 'accepted':
        return HeyYaStatus.accepted;
      case 'expired':
        return HeyYaStatus.expired;
      case 'rejected':
        return HeyYaStatus.rejected;
      case 'withdrawn':
        return HeyYaStatus.withdrawn;
      default:
        return HeyYaStatus.pending;
    }
  }

  static DeliveryStatus _deliveryStatusFromString(String? s) {
    switch (s) {
      case 'sending':
        return DeliveryStatus.sending;
      case 'sent':
        return DeliveryStatus.sent;
      case 'delivered':
        return DeliveryStatus.delivered;
      case 'read':
        return DeliveryStatus.read;
      case 'failed':
        return DeliveryStatus.failed;
      default:
        return DeliveryStatus.sent;
    }
  }

  static MessageType _messageTypeFromString(String? s) {
    switch (s) {
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'voice':
        return MessageType.voice;
      case 'file':
        return MessageType.file;
      case 'location':
        return MessageType.location;
      case 'qpoints':
        return MessageType.qpoints;
      case 'system':
        return MessageType.system;
      case 'action':
        return MessageType.action;
      default:
        return MessageType.text;
    }
  }

  static ChatType _chatTypeFromString(String? s) {
    return s == 'group' ? ChatType.group : ChatType.individual;
  }

  static ConversationPriority _priorityFromString(String? s) {
    switch (s) {
      case 'critical':
        return ConversationPriority.critical;
      case 'high':
        return ConversationPriority.high;
      case 'low':
        return ConversationPriority.low;
      default:
        return ConversationPriority.normal;
    }
  }

  static ChatUser _userFromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
      role: json['role']?.toString() ?? '',
      presence: _presenceFromString(json['presence']?.toString()),
      statusMessage: json['statusMessage']?.toString(),
      lastSeen: json['lastSeen'] != null
          ? DateTime.tryParse(json['lastSeen'].toString()) ?? DateTime.now()
          : DateTime.now(),
      department: json['department']?.toString(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      avgResponseMinutes: (json['avgResponseMinutes'] as num?)?.toInt() ?? 5,
      isFavorite: json['isFavorite'] == true,
    );
  }

  static Conversation _conversationFromJson(Map<String, dynamic> json) {
    final participants = (json['participants'] as List<dynamic>?)
            ?.map((p) => _userFromJson(p as Map<String, dynamic>))
            .toList() ??
        [];

    return Conversation(
      id: json['id']?.toString() ?? '',
      type: _chatTypeFromString(json['type']?.toString()),
      title: json['title']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
      lastMessage: json['lastMessage']?.toString() ?? '',
      lastSenderName: json['lastSenderName']?.toString() ?? '',
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.tryParse(json['lastMessageTime'].toString()) ??
              DateTime.now()
          : DateTime.now(),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      isPinned: json['isPinned'] == true,
      isMuted: json['isMuted'] == true,
      isArchived: json['isArchived'] == true,
      priority: _priorityFromString(json['priority']?.toString()),
      participants: participants,
      onlineCount: (json['onlineCount'] as num?)?.toInt(),
      typingUser: json['typingUser']?.toString(),
      relationshipScore: (json['relationshipScore'] as num?)?.toDouble(),
    );
  }

  static ChatMessage _messageFromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderName: json['senderName']?.toString() ?? '',
      type: _messageTypeFromString(json['type']?.toString()),
      content: json['content']?.toString() ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: _deliveryStatusFromString(json['status']?.toString()),
      attachmentUrl: json['attachmentUrl']?.toString(),
      attachmentName: json['attachmentName']?.toString(),
      attachmentSizeMb: (json['attachmentSizeMb'] as num?)?.toDouble(),
      isPinned: json['isPinned'] == true,
      replyToId: json['replyToId']?.toString(),
    );
  }

  // ignore: unused_element
  static HeyYaRequest _heyYaFromJson(Map<String, dynamic> json) {
    return HeyYaRequest(
      id: json['id']?.toString() ?? '',
      person: json['person'] != null
          ? _userFromJson(json['person'] as Map<String, dynamic>)
          : _fallbackHeyYas[0].person,
      status: _heyYaStatusFromString(json['status']?.toString()),
      matchPercentage: (json['matchPercentage'] as num?)?.toInt() ?? 0,
      message: json['message']?.toString(),
      sentAt: json['sentAt'] != null
          ? DateTime.tryParse(json['sentAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())
          : null,
      isSentByMe: json['isSentByMe'] == true,
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
    );
  }
}
