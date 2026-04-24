/// ═══════════════════════════════════════════════════════════════════════════
/// MY UPDATES MODULE — State Provider
/// ChangeNotifier with API-first + fallback demo data for all screens:
/// Feed, Comments, Likes, Shares, Saved, Search, Notifications,
/// Interests, Following, Insights, Reports
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/services/services.dart';
import '../models/updates_models.dart';

class UpdatesProvider extends ChangeNotifier {
  // ═══════════════════════════════════════════════════════════════════════════
  // SERVICE INSTANCES & LOADING STATE
  // ═══════════════════════════════════════════════════════════════════════════

  final SocialService _socialService = SocialService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Call once from the widget tree (e.g. initState or via Consumer).
  Future<void> init() async {
    await loadUpdates();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 1: FEED STATE
  // ═══════════════════════════════════════════════════════════════════════════

  FeedFilter _activeFilter = FeedFilter.forYou;
  FeedFilter get activeFilter => _activeFilter;

  void setFilter(FeedFilter filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  UpdateEntity? _selectedUpdate;
  UpdateEntity? get selectedUpdate => _selectedUpdate;

  void selectUpdate(UpdateEntity update) {
    _selectedUpdate = update;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 2: UPDATES (API-first + fallback)
  // ═══════════════════════════════════════════════════════════════════════════

  List<UpdateEntity> _updates = [];

  List<UpdateEntity> get updates =>
      _updates.isNotEmpty ? _updates : _fallbackUpdates;

  List<UpdateEntity> get savedUpdates =>
      updates.where((u) => u.isSavedByMe).toList();

  int get savedCount => savedUpdates.length;

  /// Fetch updates from the API; on failure, fall back to local data.
  Future<void> loadUpdates() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _socialService.getUpdates(page: 1, limit: 20);
      if (response.success && response.data != null) {
        _updates = response.data!
            .map((json) => _updateFromJson(json))
            .whereType<UpdateEntity>()
            .toList();
      } else {
        _updates = [];
      }
    } catch (_) {
      _errorMessage = 'Failed to load updates. Showing cached data.';
      // keep _updates as-is; getter falls back to _fallbackUpdates
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<UpdateEntity> filteredUpdates(FeedFilter filter) {
    final source = updates;
    switch (filter) {
      case FeedFilter.forYou:
        return source;
      case FeedFilter.latest:
        final sorted = List<UpdateEntity>.from(source);
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return sorted;
      case FeedFilter.following:
        return source.where((u) => u.entityId == 'e1' || u.entityId == 'e2').toList();
      case FeedFilter.trending:
        return source.where((u) => u.engagement.engagementRate > 10.0).toList();
      case FeedFilter.announcements:
        return source.where((u) => u.isAnnouncement).toList();
    }
  }

  void toggleLike(String updateId) {
    final source = updates;
    final idx = source.indexWhere((u) => u.id == updateId);
    if (idx != -1) {
      final u = source[idx];
      final toggled = u.copyWith(
        isLikedByMe: !u.isLikedByMe,
        engagement: EngagementMetrics(
          likesCount: u.isLikedByMe ? u.engagement.likesCount - 1 : u.engagement.likesCount + 1,
          commentsCount: u.engagement.commentsCount,
          sharesCount: u.engagement.sharesCount,
          savesCount: u.engagement.savesCount,
          viewsCount: u.engagement.viewsCount,
          engagementRate: u.engagement.engagementRate,
          likedByPreview: u.engagement.likedByPreview,
        ),
      );

      // Apply optimistic update to whichever list is active
      if (_updates.isNotEmpty) {
        _updates[idx] = toggled;
      } else {
        // Promote fallback into mutable list so we can mutate
        _updates = List<UpdateEntity>.from(_fallbackUpdates);
        _updates[idx] = toggled;
      }

      if (_selectedUpdate?.id == updateId) {
        _selectedUpdate = toggled;
      }
      notifyListeners();

      // Fire-and-forget API call
      // ignore: body_might_complete_normally_catch_error
      _socialService.likeUpdate(updateId).catchError((_) {
        // Revert on failure
        if (_updates.isNotEmpty) {
          final revertIdx = _updates.indexWhere((e) => e.id == updateId);
          if (revertIdx != -1) {
            _updates[revertIdx] = u;
            if (_selectedUpdate?.id == updateId) {
              _selectedUpdate = u;
            }
            notifyListeners();
          }
        }
      });
    }
  }

  void toggleSave(String updateId) {
    // Local-only — no save endpoint
    final source = updates;
    final idx = source.indexWhere((u) => u.id == updateId);
    if (idx != -1) {
      final u = source[idx];
      final toggled = u.copyWith(isSavedByMe: !u.isSavedByMe);

      if (_updates.isNotEmpty) {
        _updates[idx] = toggled;
      } else {
        _updates = List<UpdateEntity>.from(_fallbackUpdates);
        _updates[idx] = toggled;
      }

      if (_selectedUpdate?.id == updateId) {
        _selectedUpdate = toggled;
      }
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 3: COMMENTS (fallback-only)
  // ═══════════════════════════════════════════════════════════════════════════

  CommentSort _commentSort = CommentSort.top;
  CommentSort get commentSort => _commentSort;

  void setCommentSort(CommentSort sort) {
    _commentSort = sort;
    notifyListeners();
  }

  List<UpdateComment> _comments = [];

  List<UpdateComment> get comments =>
      _comments.isNotEmpty ? _comments : _fallbackComments;

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 4: LIKES (fallback-only)
  // ═══════════════════════════════════════════════════════════════════════════

  List<UpdateLiker> _likers = [];

  List<UpdateLiker> get likers =>
      _likers.isNotEmpty ? _likers : _fallbackLikers;

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 5: SHARES (fallback-only)
  // ═══════════════════════════════════════════════════════════════════════════

  List<UpdateShare> _shares = [];

  List<UpdateShare> get shares =>
      _shares.isNotEmpty ? _shares : _fallbackShares;

  ShareStats get shareStats => const ShareStats(
    totalShares: 42,
    platformBreakdown: {
      'WhatsApp': 42.0,
      'Twitter': 28.0,
      'Facebook': 20.0,
      'Other': 10.0,
    },
    shareGrowth: 12.0,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 6: NOTIFICATIONS (fallback-only)
  // ═══════════════════════════════════════════════════════════════════════════

  List<UpdateNotification> _notifications = [];

  List<UpdateNotification> get notifications =>
      _notifications.isNotEmpty ? _notifications : _fallbackNotifications;

  int get unreadNotificationCount =>
      notifications.where((n) => !n.isRead).length;

  void markAllNotificationsRead() {
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 7: INTERESTS (fallback-only — ownerId not available)
  // ═══════════════════════════════════════════════════════════════════════════

  List<UserInterest> _interests = [];

  List<UserInterest> get interests =>
      _interests.isNotEmpty ? _interests : _fallbackInterests;

  void toggleInterest(String interestId) {
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 8: FOLLOWING (fallback-only)
  // ═══════════════════════════════════════════════════════════════════════════

  List<FollowedEntity> _following = [];

  List<FollowedEntity> get following =>
      _following.isNotEmpty ? _following : _fallbackFollowing;

  List<FollowingList> _followingLists = [];

  List<FollowingList> get followingLists =>
      _followingLists.isNotEmpty ? _followingLists : _fallbackFollowingLists;

  int get followingCount => following.length;

  void toggleFollow(String entityId) {
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 9: SEARCH (fallback-only)
  // ═══════════════════════════════════════════════════════════════════════════

  SearchTab _searchTab = SearchTab.top;
  SearchTab get searchTab => _searchTab;

  void setSearchTab(SearchTab tab) {
    _searchTab = tab;
    notifyListeners();
  }

  List<TrendingHashtag> _trendingHashtags = [];

  List<TrendingHashtag> get trendingHashtags =>
      _trendingHashtags.isNotEmpty ? _trendingHashtags : _fallbackTrendingHashtags;

  List<SearchAccount> _searchAccounts = [];

  List<SearchAccount> get searchAccounts =>
      _searchAccounts.isNotEmpty ? _searchAccounts : _fallbackSearchAccounts;

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 10: INSIGHTS
  // ═══════════════════════════════════════════════════════════════════════════

  UpdateInsight get insight => const UpdateInsight(
    totalReach: 1245,
    impressions: 2890,
    uniqueViewers: 892,
    reachRate: 85.0,
    engagementRate: 12.4,
    totalEngagements: 324,
    newFollowersGained: 12,
    bestPerformingHour: '2:00 PM',
    engagementBreakdown: {'Likes': 42.0, 'Comments': 33.0, 'Shares': 25.0},
    audienceDemographics: {'18-24': 22.0, '25-34': 38.0, '35-44': 25.0, '45+': 15.0},
    vsAveragePerformance: 24.0,
    aiInsights: [
      'Posted at optimal time (2PM)',
      'Used high-engagement hashtags (#business)',
      'Included video content (+35% engagement)',
    ],
    recommendations: [
      'Post similar content on Thursday at 2PM',
      'Use #entrepreneur hashtag for 15% more reach',
      'Tag @relevantEntity for cross-promotion',
      'Boost this update to reach 2,000 more people',
    ],
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 11: SAVED COLLECTIONS (fallback-only)
  // ═══════════════════════════════════════════════════════════════════════════

  SavedViewMode _savedViewMode = SavedViewMode.grid;
  SavedViewMode get savedViewMode => _savedViewMode;

  void setSavedViewMode(SavedViewMode mode) {
    _savedViewMode = mode;
    notifyListeners();
  }

  List<SavedCollection> _collections = [];

  List<SavedCollection> get collections =>
      _collections.isNotEmpty ? _collections : _fallbackCollections;

  // ═══════════════════════════════════════════════════════════════════════════
  // JSON → MODEL HELPER
  // ═══════════════════════════════════════════════════════════════════════════

  /// Best-effort mapping from API JSON to [UpdateEntity].
  /// Fields that don't exist in the response default safely.
  UpdateEntity? _updateFromJson(Map<String, dynamic> json) {
    try {
      return UpdateEntity(
        id: json['id']?.toString() ?? '',
        entityId: json['entityId']?.toString() ?? json['userId']?.toString() ?? '',
        entityName: json['entityName']?.toString() ?? json['userName']?.toString() ?? 'Unknown',
        entityAvatar: json['entityAvatar']?.toString() ?? '',
        isVerified: json['isVerified'] == true,
        authorRole: json['authorRole']?.toString() ?? '',
        contextPath: json['contextPath']?.toString(),
        contentType: _parseContentType(json['contentType']?.toString()),
        mediaUrls: json['mediaUrls'] != null
            ? List<String>.from(json['mediaUrls'] as List)
            : json['attachments'] != null
                ? List<String>.from(json['attachments'] as List)
                : null ?? [],
        caption: json['caption']?.toString() ?? json['content']?.toString() ?? '',
        hashtags: json['hashtags'] != null
            ? List<String>.from(json['hashtags'] as List)
            : null ?? [],
        visibility: _parseVisibility(json['visibility']?.toString()),
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
        locationName: json['locationName']?.toString(),
        engagement: _engagementFromJson(json['engagement'] as Map<String, dynamic>?),
        isLikedByMe: json['isLikedByMe'] == true,
        isSavedByMe: json['isSavedByMe'] == true,
        isAnnouncement: json['isAnnouncement'] == true,
        isEdited: json['isEdited'] == true,
        postedVia: json['postedVia']?.toString() ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  UpdateContentType _parseContentType(String? value) {
    switch (value) {
      case 'image':
        return UpdateContentType.image;
      case 'video':
        return UpdateContentType.video;
      case 'audio':
        return UpdateContentType.audio;
      case 'poll':
        return UpdateContentType.poll;
      default:
        return UpdateContentType.text;
    }
  }

  UpdateVisibility _parseVisibility(String? value) {
    switch (value) {
      case 'followersOnly':
        return UpdateVisibility.followersOnly;
      default:
        return UpdateVisibility.publicAll;
    }
  }

  EngagementMetrics _engagementFromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const EngagementMetrics(
        likesCount: 0,
        commentsCount: 0,
        sharesCount: 0,
        savesCount: 0,
        viewsCount: 0,
        engagementRate: 0.0,
        likedByPreview: [],
      );
    }
    return EngagementMetrics(
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
      sharesCount: (json['sharesCount'] as num?)?.toInt() ?? 0,
      savesCount: (json['savesCount'] as num?)?.toInt() ?? 0,
      viewsCount: (json['viewsCount'] as num?)?.toInt() ?? 0,
      engagementRate: (json['engagementRate'] as num?)?.toDouble() ?? 0.0,
      likedByPreview: json['likedByPreview'] != null
          ? List<String>.from(json['likedByPreview'] as List)
          : const [],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REPORT CONTENT
  // ═══════════════════════════════════════════════════════════════════════════

  Future<bool> reportContent({
    required String contentId,
    required String contentType,
    required String reason,
    String? details,
  }) async {
    try {
      final response = await _socialService.reportContent(
        contentId: contentId,
        contentType: contentType,
        reason: reason,
        details: details,
      );
      return response.success;
    } catch (_) {
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FALLBACK DATA
  // ═══════════════════════════════════════════════════════════════════════════

  static final List<UpdateEntity> _fallbackUpdates = [
    UpdateEntity(
      id: 'u1',
      entityId: 'e1',
      entityName: 'Wizdom Shop',
      entityAvatar: 'W',
      isVerified: true,
      authorRole: 'Owner',
      contextPath: 'Business → Main Branch',
      contentType: UpdateContentType.image,
      mediaUrls: [],
      caption: 'New arrivals just dropped! 🎉 Check out our latest collection of premium items. Quality meets style in every piece. #NewArrivals #ShopNow #Business',
      hashtags: ['NewArrivals', 'ShopNow', 'Business'],
      visibility: UpdateVisibility.publicAll,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      locationName: 'Accra, Ghana',
      engagement: const EngagementMetrics(
        likesCount: 142,
        commentsCount: 28,
        sharesCount: 12,
        savesCount: 8,
        viewsCount: 1245,
        engagementRate: 14.5,
        likedByPreview: ['JohnDoe', 'JaneSmith'],
      ),
      isLikedByMe: true,
      isSavedByMe: true,
      postedVia: 'Mobile App',
    ),
    UpdateEntity(
      id: 'u2',
      entityId: 'e2',
      entityName: 'TechCorp Ghana',
      entityAvatar: 'T',
      isVerified: true,
      authorRole: 'Admin',
      contextPath: 'Business → HQ',
      contentType: UpdateContentType.text,
      caption: '📢 ANNOUNCEMENT: We\'re hiring! Looking for talented Flutter developers to join our growing team. Apply now at careers.techcorp.gh\n\n#Hiring #FlutterDev #GhanaJobs #TechCareers',
      hashtags: ['Hiring', 'FlutterDev', 'GhanaJobs'],
      visibility: UpdateVisibility.publicAll,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      engagement: const EngagementMetrics(
        likesCount: 89,
        commentsCount: 42,
        sharesCount: 35,
        savesCount: 15,
        viewsCount: 2340,
        engagementRate: 18.2,
        likedByPreview: ['DevGhana', 'CodeMaster'],
      ),
      isAnnouncement: true,
      postedVia: 'Web App',
    ),
    UpdateEntity(
      id: 'u3',
      entityId: 'e3',
      entityName: 'Fresh Foods Market',
      entityAvatar: 'F',
      isVerified: false,
      authorRole: 'Admin',
      contentType: UpdateContentType.video,
      mediaUrls: [],
      caption: 'Behind the scenes at our new warehouse! 📦 See how we ensure freshness from farm to your table. Thanks for the 10K followers milestone! 🎉',
      hashtags: ['FreshFood', 'BehindTheScenes', 'FarmToTable'],
      visibility: UpdateVisibility.publicAll,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
      locationName: 'Kumasi, Ghana',
      engagement: const EngagementMetrics(
        likesCount: 256,
        commentsCount: 64,
        sharesCount: 28,
        savesCount: 22,
        viewsCount: 4560,
        engagementRate: 22.8,
        likedByPreview: ['FoodLover', 'HealthyEating'],
      ),
      postedVia: 'Mobile App',
    ),
    UpdateEntity(
      id: 'u4',
      entityId: 'e1',
      entityName: 'Wizdom Shop',
      entityAvatar: 'W',
      isVerified: true,
      authorRole: 'Owner',
      contentType: UpdateContentType.poll,
      caption: 'What product category should we expand into next? Your vote matters! 🗳️',
      hashtags: ['Poll', 'Community', 'YourVoice'],
      visibility: UpdateVisibility.followersOnly,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      engagement: const EngagementMetrics(
        likesCount: 45,
        commentsCount: 18,
        sharesCount: 5,
        savesCount: 3,
        viewsCount: 890,
        engagementRate: 8.4,
        likedByPreview: ['ShopFan'],
      ),
      poll: UpdatePoll(
        question: 'What category should we expand into?',
        options: [
          const PollOption(id: 'p1', text: 'Electronics 📱', votes: 128, percentage: 42.0),
          const PollOption(id: 'p2', text: 'Fashion 👗', votes: 95, percentage: 31.0),
          const PollOption(id: 'p3', text: 'Home & Garden 🏡', votes: 52, percentage: 17.0),
          const PollOption(id: 'p4', text: 'Sports & Fitness 🏋️', votes: 30, percentage: 10.0),
        ],
        totalVotes: 305,
        hasVoted: true,
        selectedOptionId: 'p1',
        endsAt: DateTime.now().add(const Duration(days: 2)),
      ),
      postedVia: 'Mobile App',
    ),
    UpdateEntity(
      id: 'u5',
      entityId: 'e4',
      entityName: 'Swift Logistics',
      entityAvatar: 'S',
      isVerified: true,
      authorRole: 'Admin',
      contextPath: 'Logistics Provider',
      contentType: UpdateContentType.image,
      mediaUrls: [],
      caption: 'Fleet expansion! 🚚 We\'ve added 5 new electric vehicles to our delivery fleet. Going green for a sustainable future! 🌱 #GreenLogistics #EcoFriendly',
      hashtags: ['GreenLogistics', 'EcoFriendly', 'FleetExpansion'],
      visibility: UpdateVisibility.publicAll,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      isEdited: true,
      engagement: const EngagementMetrics(
        likesCount: 178,
        commentsCount: 32,
        sharesCount: 45,
        savesCount: 18,
        viewsCount: 3200,
        engagementRate: 16.7,
        likedByPreview: ['EcoDriver', 'LogisticsGH'],
      ),
      isSavedByMe: true,
      postedVia: 'Web App',
    ),
    UpdateEntity(
      id: 'u6',
      entityId: 'e5',
      entityName: 'Sarah Johnson',
      entityAvatar: 'S',
      isVerified: false,
      authorRole: 'Individual',
      contentType: UpdateContentType.audio,
      mediaUrls: [],
      caption: '🎤 Voice update: Sharing my thoughts on the latest fintech trends in Ghana. Exciting times ahead! #Fintech #GhanaRising',
      hashtags: ['Fintech', 'GhanaRising'],
      visibility: UpdateVisibility.publicAll,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      engagement: const EngagementMetrics(
        likesCount: 34,
        commentsCount: 12,
        sharesCount: 8,
        savesCount: 6,
        viewsCount: 560,
        engagementRate: 10.5,
        likedByPreview: ['FintechGH'],
      ),
      postedVia: 'Mobile App',
    ),
  ];

  static final List<UpdateComment> _fallbackComments = [
    UpdateComment(
      id: 'c1',
      userId: 'user1',
      username: 'JohnDoe',
      userAvatar: 'J',
      isVerified: true,
      text: 'Amazing collection! Can\'t wait to check them out in store. 🔥',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      likesCount: 12,
      isLikedByMe: true,
      replies: [
        UpdateComment(
          id: 'c1r1',
          userId: 'user5',
          username: 'WizdomShop',
          userAvatar: 'W',
          isVerified: true,
          text: 'Thanks John! Visit us this weekend for exclusive previews 🎁',
          createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
          likesCount: 5,
        ),
        UpdateComment(
          id: 'c1r2',
          userId: 'user6',
          username: 'StyleFan',
          text: 'I second that! The quality is always top-notch',
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          likesCount: 2,
        ),
      ],
    ),
    UpdateComment(
      id: 'c2',
      userId: 'user2',
      username: 'JaneSmith',
      userAvatar: 'J',
      text: 'Do you ship internationally? I\'d love to order from abroad! 🌍',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      likesCount: 8,
      replies: [
        UpdateComment(
          id: 'c2r1',
          userId: 'user5',
          username: 'WizdomShop',
          userAvatar: 'W',
          isVerified: true,
          text: 'Yes! We ship to 15+ countries. Check our website for details.',
          createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
          likesCount: 3,
        ),
      ],
    ),
    UpdateComment(
      id: 'c3',
      userId: 'user3',
      username: 'MarketWatch',
      userAvatar: 'M',
      isVerified: true,
      text: 'Great business growth! Your Q4 numbers must be impressive. Any plans for expansion?',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      likesCount: 15,
      isEdited: true,
    ),
    UpdateComment(
      id: 'c4',
      userId: 'user4',
      username: 'LocalShopper',
      text: 'Best shop in town! Been a customer for 2 years now 💯',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      likesCount: 6,
    ),
    UpdateComment(
      id: 'c5',
      userId: 'user7',
      username: 'FashionBlogger',
      userAvatar: 'F',
      text: 'Love the new designs! Would love to collaborate on a review 📸',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      likesCount: 4,
    ),
  ];

  static final List<UpdateLiker> _fallbackLikers = [
    UpdateLiker(
      userId: 'l1', username: 'JohnDoe', fullName: 'John Doe',
      isVerified: true, isFollowing: true, isOnline: true,
      mutualConnections: 5,
      likedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    UpdateLiker(
      userId: 'l2', username: 'JaneSmith', fullName: 'Jane Smith',
      isVerified: false, isFollowing: true, isOnline: false,
      mutualConnections: 3,
      likedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    UpdateLiker(
      userId: 'l3', username: 'TechGuru', fullName: 'Tech Guru',
      isVerified: true, isFollowing: false, isOnline: true,
      mutualConnections: 8,
      likedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    UpdateLiker(
      userId: 'l4', username: 'AccraFoodie', fullName: 'Accra Foodie',
      isVerified: false, isFollowing: false, isOnline: false,
      mutualConnections: 1,
      likedAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    UpdateLiker(
      userId: 'l5', username: 'BusinessGH', fullName: 'Business Ghana',
      isVerified: true, isFollowing: true, isOnline: true,
      mutualConnections: 12,
      likedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  static final List<UpdateShare> _fallbackShares = [
    UpdateShare(
      userId: 's1', username: 'MarketKing', isVerified: true,
      followerCount: 1200, platform: 'WhatsApp',
      addedComment: 'Check this out! Great products.',
      sharedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    UpdateShare(
      userId: 's2', username: 'ShopReview', isVerified: false,
      followerCount: 850, platform: 'Twitter',
      sharedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    UpdateShare(
      userId: 's3', username: 'AccraBiz', isVerified: true,
      followerCount: 3400, platform: 'Facebook',
      addedComment: 'Supporting local businesses! 🇬🇭',
      sharedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  static final List<UpdateNotification> _fallbackNotifications = [
    UpdateNotification(
      id: 'n1', type: UpdateNotificationType.like,
      title: 'New likes', body: 'John and 3 others liked your update',
      targetUpdateId: 'u1',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    UpdateNotification(
      id: 'n2', type: UpdateNotificationType.comment,
      title: 'New comment', body: 'Jane commented: "Great news!"',
      targetUpdateId: 'u1',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    UpdateNotification(
      id: 'n3', type: UpdateNotificationType.share,
      title: 'Shared', body: 'Your update was shared 12 times',
      targetUpdateId: 'u1',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    UpdateNotification(
      id: 'n4', type: UpdateNotificationType.follow,
      title: 'New follower', body: 'New follower: Tech Guru',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    UpdateNotification(
      id: 'n5', type: UpdateNotificationType.mention,
      title: 'Mentioned', body: 'You were mentioned by TechCorp Ghana',
      targetUpdateId: 'u2',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      isRead: true,
    ),
    UpdateNotification(
      id: 'n6', type: UpdateNotificationType.system,
      title: 'New feature', body: 'New feature: Scheduled posts are now available!',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      isRead: true,
    ),
    UpdateNotification(
      id: 'n7', type: UpdateNotificationType.like,
      title: 'Milestone', body: 'Your update reached 100 likes! 🎉',
      targetUpdateId: 'u3',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      isRead: true,
    ),
  ];

  static final List<UserInterest> _fallbackInterests = [
    const UserInterest(id: 'i1', category: InterestCategory.business, name: 'Entrepreneurship', icon: '💼', description: 'Startup news and business growth tips', followerCount: 12400, relevanceScore: 92.0, isFollowing: true, weight: 0.8),
    const UserInterest(id: 'i2', category: InterestCategory.finance, name: 'Digital Banking', icon: '🏦', description: 'Fintech and mobile money trends', followerCount: 8900, relevanceScore: 85.0, isFollowing: true, weight: 0.7),
    const UserInterest(id: 'i3', category: InterestCategory.technology, name: 'AI & Machine Learning', icon: '🤖', description: 'Artificial intelligence breakthroughs', followerCount: 15600, relevanceScore: 78.0, isFollowing: false, weight: 0.5),
    const UserInterest(id: 'i4', category: InterestCategory.technology, name: 'Mobile Development', icon: '📱', description: 'Flutter, React Native and native dev', followerCount: 9200, relevanceScore: 88.0, isFollowing: true, weight: 0.9),
    const UserInterest(id: 'i5', category: InterestCategory.logistics, name: 'Last-Mile Delivery', icon: '🚚', description: 'Delivery innovation and logistics', followerCount: 4500, relevanceScore: 72.0, isFollowing: false, weight: 0.4),
    const UserInterest(id: 'i6', category: InterestCategory.social, name: 'Local Events', icon: '🎉', description: 'Community events and networking', followerCount: 6800, relevanceScore: 65.0, isFollowing: true, weight: 0.6),
    const UserInterest(id: 'i7', category: InterestCategory.business, name: 'Startup Funding', icon: '💰', description: 'Venture capital and fundraising', followerCount: 7300, relevanceScore: 80.0, isFollowing: false, weight: 0.5),
    const UserInterest(id: 'i8', category: InterestCategory.health, name: 'Wellness', icon: '🧘', description: 'Health tips and wellness trends', followerCount: 11200, relevanceScore: 45.0, isFollowing: false, weight: 0.3),
    const UserInterest(id: 'i9', category: InterestCategory.education, name: 'Online Learning', icon: '📚', description: 'Courses, certifications and skills', followerCount: 14000, relevanceScore: 70.0, isFollowing: false, weight: 0.5),
    const UserInterest(id: 'i10', category: InterestCategory.entertainment, name: 'Creative Content', icon: '🎨', description: 'Art, design and media creation', followerCount: 8600, relevanceScore: 55.0, isFollowing: false, weight: 0.4),
  ];

  static final List<FollowedEntity> _fallbackFollowing = [
    FollowedEntity(
      id: 'f1', name: 'TechCorp Ghana', isVerified: true,
      type: FollowingType.entity, followerCount: 12400,
      updateFrequency: '3 posts/day',
      lastPostPreview: 'We\'re hiring! Looking for Flutter devs...',
      lastPostTime: DateTime.now().subtract(const Duration(hours: 5)),
      priority: 0.8,
    ),
    FollowedEntity(
      id: 'f2', name: 'Fresh Foods Market', isVerified: false,
      type: FollowingType.entity, followerCount: 5600,
      updateFrequency: 'Daily',
      lastPostPreview: 'Behind the scenes at our warehouse...',
      lastPostTime: DateTime.now().subtract(const Duration(hours: 8)),
      priority: 0.6,
    ),
    FollowedEntity(
      id: 'f3', name: 'Sarah Johnson', isVerified: false,
      type: FollowingType.person, followerCount: 890,
      updateFrequency: 'Weekly',
      lastPostPreview: 'Voice update on fintech trends...',
      lastPostTime: DateTime.now().subtract(const Duration(days: 2)),
      priority: 0.5,
    ),
    const FollowedEntity(
      id: 'f4', name: '#FlutterDev', isVerified: false,
      type: FollowingType.topic, followerCount: 45000,
      updateFrequency: '50+ posts/day',
      priority: 0.7,
    ),
    FollowedEntity(
      id: 'f5', name: 'Swift Logistics', isVerified: true,
      type: FollowingType.entity, followerCount: 3200,
      updateFrequency: '2 posts/week',
      lastPostPreview: 'Fleet expansion with electric vehicles...',
      lastPostTime: DateTime.now().subtract(const Duration(days: 1)),
      isMuted: true,
      priority: 0.3,
    ),
  ];

  static const List<FollowingList> _fallbackFollowingLists = [
    FollowingList(id: 'fl1', name: 'Tech Companies', description: 'Ghana tech ecosystem', isPublic: true, memberCount: 12),
    FollowingList(id: 'fl2', name: 'Local Shops', description: 'My favorite local businesses', isPublic: false, memberCount: 8),
    FollowingList(id: 'fl3', name: 'Industry Leaders', description: 'Top voices in business', isPublic: true, memberCount: 25),
  ];

  static const List<TrendingHashtag> _fallbackTrendingHashtags = [
    TrendingHashtag(tag: '#GhanaBusiness', postCount: 1240, growthRate: 124.0, isFollowing: true),
    TrendingHashtag(tag: '#Fintech', postCount: 890, growthRate: 85.0),
    TrendingHashtag(tag: '#NewArrivals', postCount: 567, growthRate: 45.0),
    TrendingHashtag(tag: '#FlutterDev', postCount: 2340, growthRate: 32.0, isFollowing: true),
    TrendingHashtag(tag: '#EcoFriendly', postCount: 456, growthRate: 78.0),
  ];

  static const List<SearchAccount> _fallbackSearchAccounts = [
    SearchAccount(id: 'sa1', name: 'TechCorp Ghana', isVerified: true, followerCount: 12400, mutualConnections: 8, isFollowing: true, recentActivity: 'Posted 2h ago'),
    SearchAccount(id: 'sa2', name: 'Fresh Foods Market', followerCount: 5600, mutualConnections: 3, recentActivity: 'Posted yesterday'),
    SearchAccount(id: 'sa3', name: 'Swift Logistics', isVerified: true, followerCount: 3200, mutualConnections: 5, isFollowing: true, recentActivity: 'Shared an update'),
    SearchAccount(id: 'sa4', name: 'Sarah Johnson', followerCount: 890, mutualConnections: 2, recentActivity: 'New voice update'),
  ];

  static const List<SavedCollection> _fallbackCollections = [
    SavedCollection(id: 'col1', name: 'Business Ideas', color: Color(0xFF3B82F6), itemCount: 12),
    SavedCollection(id: 'col2', name: 'Product Inspiration', color: Color(0xFF10B981), itemCount: 8),
    SavedCollection(id: 'col3', name: 'Read Later', color: Color(0xFFF59E0B), itemCount: 5),
  ];
}
