/// ═══════════════════════════════════════════════════════════════════════════
/// MY UPDATES MODULE — Data Models
/// Comprehensive models for the social updates/feed module:
/// Updates, Comments, Engagement, Notifications, Interests, Following,
/// Shares, Reports, Polls, Collections, Insights
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

// ─── Enums ──────────────────────────────────────────────────────────────────

/// Content type for an update
enum UpdateContentType { text, image, video, audio, poll, document, product, event }

/// Visibility level for an update
enum UpdateVisibility { publicAll, followersOnly, specificPeople, privateOnly }

/// Feed filter mode
enum FeedFilter { forYou, latest, following, trending, announcements }

/// Reaction type
enum ReactionType { like, love, fire, laugh, surprise, sad, thumbsUp }

/// Comment sort mode
enum CommentSort { top, newest, questions, mostLiked }

/// Notification type for updates module
enum UpdateNotificationType { like, comment, mention, share, follow, system }

/// Report reason
enum ReportReason {
  spam,
  nudity,
  hateSpeech,
  violence,
  bullying,
  intellectualProperty,
  selfHarm,
  scam,
  falseInfo,
  notInterested,
  other,
}

/// Report status
enum ReportStatus { pending, underReview, resolved, dismissed }

/// Interest category
enum InterestCategory { business, finance, technology, logistics, social, health, education, entertainment }

/// Following entity type
enum FollowingType { entity, person, topic, list }

/// Mute duration
enum MuteDuration { twentyFourHours, sevenDays, thirtyDays, forever }

/// Update insights metric type
enum InsightMetric { reach, impressions, engagement, clicks, saves, shares }

/// Poll duration preset
enum PollDuration { oneHour, sixHours, twentyFourHours, sevenDays, custom }

/// Share platform
enum SharePlatform { qualChat, copyLink, external, saveDevice, embed, qrCode }

/// Saved view mode
enum SavedViewMode { grid, list, calendar }

/// Search tab
enum SearchTab { top, latest, accounts, hashtags, nearby }

/// Options menu section
enum OptionsSection { engagement, contentManagement, sharing, advanced, accessibility }

// ─── Data Models ────────────────────────────────────────────────────────────

/// A mention reference in update content
class UserMention {
  final String userId;
  final String username;
  final String displayName;
  final bool isVerified;

  const UserMention({
    required this.userId,
    required this.username,
    required this.displayName,
    this.isVerified = false,
  });
}

/// A poll option
class PollOption {
  final String id;
  final String text;
  final int votes;
  final double percentage;

  const PollOption({
    required this.id,
    required this.text,
    this.votes = 0,
    this.percentage = 0.0,
  });
}

/// A poll attached to an update
class UpdatePoll {
  final String question;
  final List<PollOption> options;
  final PollDuration duration;
  final bool allowMultiple;
  final bool isAnonymous;
  final int totalVotes;
  final bool hasVoted;
  final String? selectedOptionId;
  final DateTime endsAt;

  const UpdatePoll({
    required this.question,
    required this.options,
    this.duration = PollDuration.twentyFourHours,
    this.allowMultiple = false,
    this.isAnonymous = false,
    this.totalVotes = 0,
    this.hasVoted = false,
    this.selectedOptionId,
    required this.endsAt,
  });
}

/// Engagement metrics for an update
class EngagementMetrics {
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int savesCount;
  final int viewsCount;
  final double engagementRate;
  final List<String> likedByPreview; // first 2-3 usernames

  const EngagementMetrics({
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.savesCount = 0,
    this.viewsCount = 0,
    this.engagementRate = 0.0,
    this.likedByPreview = const [],
  });
}

/// A single update entity
class UpdateEntity {
  final String id;
  final String entityId;
  final String entityName;
  final String entityAvatar;
  final bool isVerified;
  final String authorRole;
  final String? contextPath; // "Business → Main Branch"
  final UpdateContentType contentType;
  final List<String> mediaUrls;
  final String caption;
  final List<UserMention> mentions;
  final List<String> hashtags;
  final UpdateVisibility visibility;
  final DateTime? scheduledTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEdited;
  final String? locationName;
  final EngagementMetrics engagement;
  final UpdatePoll? poll;
  final bool isAnnouncement;
  final bool isLikedByMe;
  final bool isSavedByMe;
  final ReactionType? myReaction;
  final bool isSensitive;
  final String? sensitiveWarning;
  final String postedVia;

  const UpdateEntity({
    required this.id,
    required this.entityId,
    required this.entityName,
    this.entityAvatar = '',
    this.isVerified = false,
    this.authorRole = 'Admin',
    this.contextPath,
    this.contentType = UpdateContentType.text,
    this.mediaUrls = const [],
    required this.caption,
    this.mentions = const [],
    this.hashtags = const [],
    this.visibility = UpdateVisibility.publicAll,
    this.scheduledTime,
    required this.createdAt,
    required this.updatedAt,
    this.isEdited = false,
    this.locationName,
    this.engagement = const EngagementMetrics(),
    this.poll,
    this.isAnnouncement = false,
    this.isLikedByMe = false,
    this.isSavedByMe = false,
    this.myReaction,
    this.isSensitive = false,
    this.sensitiveWarning,
    this.postedVia = 'Mobile App',
  });

  UpdateEntity copyWith({
    bool? isLikedByMe,
    bool? isSavedByMe,
    ReactionType? myReaction,
    EngagementMetrics? engagement,
  }) {
    return UpdateEntity(
      id: id,
      entityId: entityId,
      entityName: entityName,
      entityAvatar: entityAvatar,
      isVerified: isVerified,
      authorRole: authorRole,
      contextPath: contextPath,
      contentType: contentType,
      mediaUrls: mediaUrls,
      caption: caption,
      mentions: mentions,
      hashtags: hashtags,
      visibility: visibility,
      scheduledTime: scheduledTime,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isEdited: isEdited,
      locationName: locationName,
      engagement: engagement ?? this.engagement,
      poll: poll,
      isAnnouncement: isAnnouncement,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      isSavedByMe: isSavedByMe ?? this.isSavedByMe,
      myReaction: myReaction ?? this.myReaction,
      isSensitive: isSensitive,
      sensitiveWarning: sensitiveWarning,
      postedVia: postedVia,
    );
  }
}

/// A comment on an update
class UpdateComment {
  final String id;
  final String userId;
  final String username;
  final String userAvatar;
  final bool isVerified;
  final String text;
  final DateTime createdAt;
  final bool isEdited;
  final int likesCount;
  final bool isLikedByMe;
  final List<UpdateComment> replies;
  final String? mediaUrl;

  const UpdateComment({
    required this.id,
    required this.userId,
    required this.username,
    this.userAvatar = '',
    this.isVerified = false,
    required this.text,
    required this.createdAt,
    this.isEdited = false,
    this.likesCount = 0,
    this.isLikedByMe = false,
    this.replies = const [],
    this.mediaUrl,
  });
}

/// A user who liked an update
class UpdateLiker {
  final String userId;
  final String username;
  final String fullName;
  final String avatar;
  final bool isVerified;
  final bool isFollowing;
  final bool isOnline;
  final int mutualConnections;
  final DateTime likedAt;

  const UpdateLiker({
    required this.userId,
    required this.username,
    required this.fullName,
    this.avatar = '',
    this.isVerified = false,
    this.isFollowing = false,
    this.isOnline = false,
    this.mutualConnections = 0,
    required this.likedAt,
  });
}

/// A share record
class UpdateShare {
  final String userId;
  final String username;
  final String avatar;
  final bool isVerified;
  final int followerCount;
  final String platform;
  final String? addedComment;
  final DateTime sharedAt;

  const UpdateShare({
    required this.userId,
    required this.username,
    this.avatar = '',
    this.isVerified = false,
    this.followerCount = 0,
    required this.platform,
    this.addedComment,
    required this.sharedAt,
  });
}

/// A notification in the updates module
class UpdateNotification {
  final String id;
  final UpdateNotificationType type;
  final String title;
  final String body;
  final String? thumbnailUrl;
  final String? targetUpdateId;
  final DateTime createdAt;
  final bool isRead;

  const UpdateNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.thumbnailUrl,
    this.targetUpdateId,
    required this.createdAt,
    this.isRead = false,
  });
}

/// A user interest for feed personalization
class UserInterest {
  final String id;
  final InterestCategory category;
  final String name;
  final String description;
  final String icon;
  final int followerCount;
  final double relevanceScore;
  final bool isFollowing;
  final double weight; // 0.0 low, 0.5 medium, 1.0 high

  const UserInterest({
    required this.id,
    required this.category,
    required this.name,
    this.description = '',
    this.icon = '📌',
    this.followerCount = 0,
    this.relevanceScore = 0.0,
    this.isFollowing = false,
    this.weight = 0.5,
  });
}

/// A followed entity
class FollowedEntity {
  final String id;
  final String name;
  final String avatar;
  final bool isVerified;
  final FollowingType type;
  final int followerCount;
  final String updateFrequency;
  final String? lastPostPreview;
  final DateTime? lastPostTime;
  final bool isMuted;
  final double priority; // 0=low, 0.5=medium, 1=high

  const FollowedEntity({
    required this.id,
    required this.name,
    this.avatar = '',
    this.isVerified = false,
    this.type = FollowingType.entity,
    this.followerCount = 0,
    this.updateFrequency = 'Daily',
    this.lastPostPreview,
    this.lastPostTime,
    this.isMuted = false,
    this.priority = 0.5,
  });
}

/// A saved collection
class SavedCollection {
  final String id;
  final String name;
  final Color color;
  final int itemCount;
  final bool isPrivate;

  const SavedCollection({
    required this.id,
    required this.name,
    this.color = const Color(0xFFEC4899),
    this.itemCount = 0,
    this.isPrivate = true,
  });
}

/// A report submission
class UpdateReport {
  final String id;
  final String updateId;
  final ReportReason reason;
  final String? additionalDetails;
  final ReportStatus status;
  final DateTime submittedAt;

  const UpdateReport({
    required this.id,
    required this.updateId,
    required this.reason,
    this.additionalDetails,
    this.status = ReportStatus.pending,
    required this.submittedAt,
  });
}

/// A trending hashtag
class TrendingHashtag {
  final String tag;
  final int postCount;
  final double growthRate;
  final bool isFollowing;

  const TrendingHashtag({
    required this.tag,
    this.postCount = 0,
    this.growthRate = 0.0,
    this.isFollowing = false,
  });
}

/// Search result account
class SearchAccount {
  final String id;
  final String name;
  final String avatar;
  final bool isVerified;
  final int followerCount;
  final int mutualConnections;
  final bool isFollowing;
  final String? recentActivity;

  const SearchAccount({
    required this.id,
    required this.name,
    this.avatar = '',
    this.isVerified = false,
    this.followerCount = 0,
    this.mutualConnections = 0,
    this.isFollowing = false,
    this.recentActivity,
  });
}

/// Update insight metrics
class UpdateInsight {
  final int totalReach;
  final int impressions;
  final int uniqueViewers;
  final double reachRate;
  final double engagementRate;
  final int totalEngagements;
  final int newFollowersGained;
  final String bestPerformingHour;
  final Map<String, double> engagementBreakdown; // likes%, comments%, shares%
  final Map<String, double> audienceDemographics;
  final double vsAveragePerformance;
  final List<String> aiInsights;
  final List<String> recommendations;

  const UpdateInsight({
    this.totalReach = 0,
    this.impressions = 0,
    this.uniqueViewers = 0,
    this.reachRate = 0.0,
    this.engagementRate = 0.0,
    this.totalEngagements = 0,
    this.newFollowersGained = 0,
    this.bestPerformingHour = '2:00 PM',
    this.engagementBreakdown = const {},
    this.audienceDemographics = const {},
    this.vsAveragePerformance = 0.0,
    this.aiInsights = const [],
    this.recommendations = const [],
  });
}

/// Share statistics
class ShareStats {
  final int totalShares;
  final Map<String, double> platformBreakdown; // WhatsApp 42%, etc.
  final double shareGrowth;

  const ShareStats({
    this.totalShares = 0,
    this.platformBreakdown = const {},
    this.shareGrowth = 0.0,
  });
}

/// Following list (custom grouping)
class FollowingList {
  final String id;
  final String name;
  final String? description;
  final bool isPublic;
  final int memberCount;
  final List<String> memberPreviewAvatars;

  const FollowingList({
    required this.id,
    required this.name,
    this.description,
    this.isPublic = false,
    this.memberCount = 0,
    this.memberPreviewAvatars = const [],
  });
}
