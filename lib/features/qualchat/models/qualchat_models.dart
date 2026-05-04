/// qualChat Module — Data Models
/// Communications Hub: Messages, Presence, HeyYa
/// Module Color: Cyan 0xFF06B6D4

// ──────────────────────────────────────────────
//  ENUMS
// ──────────────────────────────────────────────

/// Widget loading state machine
enum QualChatWidgetState { loading, loaded, error, empty }

/// Dashboard mode toggle
enum ChatMode { social, professional }

/// User presence / online status
enum PresenceStatus { online, idle, offline }

/// Hey Ya request status
enum HeyYaStatus { pending, accepted, expired, rejected, withdrawn }

/// Hey Ya tab filter
enum HeyYaTab { all, sent, received, matches }

/// Timeline event types
enum TimelineEventType { sent, seen, viewed, reacted, replied, matched, expired }

/// Nudge type from AI wingmate
enum NudgeType { followUp, reEngagement, profileUpdate, compatibility, activity }

/// Nudge swipe action
enum NudgeAction { accept, snooze, pass, custom }

/// Action Center task priority
enum TaskPriority { high, medium, low }

/// Action Center task status
enum TaskStatus { actNow, considerLater, completed, dismissed }

/// Action Center task type
enum TaskType { communication, profile, discovery, learning, social }

/// Chat message type
enum MessageType { text, image, video, voice, file, location, qpoints, system, action }

/// Message delivery status
enum DeliveryStatus { sending, sent, delivered, read, failed }

/// Chat type
enum ChatType { individual, group }

/// Chat list tab filter
enum ChatListTab { all, unread, priority, groups }

/// Archive sort option
enum ArchiveSort { newest, oldest, largest, name }

/// Archive filter
enum ArchiveFilter { all, byDate, bySize, byType, individual, group, media }

/// Conversation priority (AI-detected)
enum ConversationPriority { critical, high, normal, low }

/// Presence filter scope
enum PresenceFilter { individual, entity, all }

/// Quick filter for new chat
enum RecipientFilter { online, favorites, recent, department, nearby, recommended }

/// Report reason in chat
enum ChatReportReason { spam, harassment, inappropriate, scam, impersonation, other }

/// Vibe tag for preferences
enum VibeTag { adventurous, creative, nerdy, foodie, musical, pets, travel, gaming, calm }

/// Reaction type for messages
enum MessageReaction { smile, heart, thumbsUp, fire, surprised, sad, celebration }

/// Onboarding chat usage type
enum ChatUsageType { socialDating, professionalNetworking, teamCommunications, driverConnections, monitoring }

/// Settings section
enum ChatSettingsSection { notifications, privacy, media, appearance, accessibility, advanced }

/// Notification type in qualchat
enum ChatNotificationType { newMessage, reaction, heyYaMatch, heyYaView, mention, groupInvite }

/// Sentiment trend
enum SentimentTrend { positive, neutral, negative }

/// Conversation insight priority
enum InsightPriority { unresolved, followUp, completed }

// ──────────────────────────────────────────────
//  DATA MODELS
// ──────────────────────────────────────────────

/// Represents a user in the qualChat system
class ChatUser {
  final String id;
  final String name;
  final String? avatarUrl;
  final String role;
  final PresenceStatus presence;
  final String? statusMessage;
  final DateTime lastSeen;
  final String? department;
  final double? distanceKm;
  final int avgResponseMinutes;
  final bool isFavorite;

  const ChatUser({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.role,
    required this.presence,
    this.statusMessage,
    required this.lastSeen,
    this.department,
    this.distanceKm,
    this.avgResponseMinutes = 5,
    this.isFavorite = false,
  });
}

/// A single chat message
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final MessageType type;
  final String content;
  final DateTime timestamp;
  final DeliveryStatus status;
  final List<MessageReaction> reactions;
  final String? attachmentUrl;
  final String? attachmentName;
  final double? attachmentSizeMb;
  final bool isPinned;
  final String? replyToId;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.type,
    required this.content,
    required this.timestamp,
    this.status = DeliveryStatus.delivered,
    this.reactions = const [],
    this.attachmentUrl,
    this.attachmentName,
    this.attachmentSizeMb,
    this.isPinned = false,
    this.replyToId,
  });
}

/// A conversation (individual or group)
class Conversation {
  final String id;
  final ChatType type;
  final String title;
  final String? avatarUrl;
  final String lastMessage;
  final String lastSenderName;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isPinned;
  final bool isMuted;
  final bool isArchived;
  final ConversationPriority priority;
  final List<ChatUser> participants;
  final int? onlineCount;
  final String? typingUser;
  final double? relationshipScore;

  const Conversation({
    required this.id,
    required this.type,
    required this.title,
    this.avatarUrl,
    required this.lastMessage,
    required this.lastSenderName,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isPinned = false,
    this.isMuted = false,
    this.isArchived = false,
    this.priority = ConversationPriority.normal,
    this.participants = const [],
    this.onlineCount,
    this.typingUser,
    this.relationshipScore,
  });
}

/// A Hey Ya request (dating / social feature — Owner only)
class HeyYaRequest {
  final String id;
  final ChatUser person;
  final HeyYaStatus status;
  final int matchPercentage;
  final String? message;
  final DateTime sentAt;
  final DateTime? expiresAt;
  final bool isSentByMe;
  final int viewCount;
  final List<TimelineEvent> timeline;

  const HeyYaRequest({
    required this.id,
    required this.person,
    required this.status,
    required this.matchPercentage,
    this.message,
    required this.sentAt,
    this.expiresAt,
    this.isSentByMe = true,
    this.viewCount = 0,
    this.timeline = const [],
  });
}

/// A single event on the Hey Ya request timeline
class TimelineEvent {
  final TimelineEventType type;
  final String description;
  final DateTime timestamp;
  final String? detail;

  const TimelineEvent({
    required this.type,
    required this.description,
    required this.timestamp,
    this.detail,
  });
}

/// Presence stats for the dashboard
class PresenceStats {
  final int online;
  final int idle;
  final int offline;
  final int total;
  final double onlineChangePercent;
  final double idleChangePercent;
  final double offlineChangePercent;

  const PresenceStats({
    required this.online,
    required this.idle,
    required this.offline,
    required this.total,
    this.onlineChangePercent = 0,
    this.idleChangePercent = 0,
    this.offlineChangePercent = 0,
  });
}

/// Activity data point for heat-map / chart
class ActivityDataPoint {
  final String label;
  final double value;
  final DateTime time;

  const ActivityDataPoint({
    required this.label,
    required this.value,
    required this.time,
  });
}

/// Smart nudge card from AI wingmate
class SmartNudge {
  final String id;
  final NudgeType type;
  final ChatUser person;
  final int matchPercentage;
  final String prompt;
  final String suggestedOpener;
  final String reason;
  final DateTime createdAt;

  const SmartNudge({
    required this.id,
    required this.type,
    required this.person,
    required this.matchPercentage,
    required this.prompt,
    required this.suggestedOpener,
    required this.reason,
    required this.createdAt,
  });
}

/// Action center task
class ActionTask {
  final String id;
  final TaskType type;
  final TaskPriority priority;
  final TaskStatus status;
  final String title;
  final String description;
  final DateTime? dueDate;
  final DateTime createdAt;
  final List<String> quickActions;

  const ActionTask({
    required this.id,
    required this.type,
    required this.priority,
    required this.status,
    required this.title,
    required this.description,
    this.dueDate,
    required this.createdAt,
    this.quickActions = const [],
  });
}

/// AI suggestion in action center or preferences
class AISuggestion {
  final String id;
  final String text;
  final String? detail;
  final bool isApplied;

  const AISuggestion({
    required this.id,
    required this.text,
    this.detail,
    this.isApplied = false,
  });
}

/// Conversation insight for the intelligence section
class ConversationInsight {
  final InsightPriority priority;
  final String title;
  final String? description;

  const ConversationInsight({
    required this.priority,
    required this.title,
    this.description,
  });
}

/// Hey Ya vibe image data
class VibeImage {
  final String id;
  final String? imageUrl;
  final bool isActive;
  final DateTime? expiresAt;
  final int views;
  final int likes;
  final int comments;
  final int connections;
  final int matches;
  final double remainingPercent;
  final String? analysisText;

  const VibeImage({
    required this.id,
    this.imageUrl,
    this.isActive = true,
    this.expiresAt,
    this.views = 0,
    this.likes = 0,
    this.comments = 0,
    this.connections = 0,
    this.matches = 0,
    this.remainingPercent = 100,
    this.analysisText,
  });
}

/// Preference weighting for compatibility algorithm
class CompatibilityWeight {
  final String label;
  final double percent;

  const CompatibilityWeight({required this.label, required this.percent});
}

/// Archive item with metadata
class ArchivedChat {
  final Conversation conversation;
  final DateTime archivedAt;
  final double sizeMb;
  final int messageCount;

  const ArchivedChat({
    required this.conversation,
    required this.archivedAt,
    required this.sizeMb,
    required this.messageCount,
  });

  String get id => conversation.id;
  int get mediaCount => 0;
}

/// Onboarding step data
class OnboardingStep {
  final int stepNumber;
  final String title;
  final String description;
  final String? iconEmoji;
  final bool isCompleted;

  const OnboardingStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    this.iconEmoji,
    this.isCompleted = false,
  });
}

/// Settings toggle item
class SettingsToggle {
  final String label;
  final bool value;
  final ChatSettingsSection section;

  const SettingsToggle({
    required this.label,
    required this.value,
    required this.section,
  });
}

/// Connection success data point for the bar chart
class ConnectionSuccess {
  final int index;
  final bool isSuccess;

  const ConnectionSuccess({required this.index, required this.isSuccess});
}

/// Nudge settings configuration
class NudgeSettings {
  final String frequency;
  final String timing;
  final int maxPerDay;
  final int followUpAfterDays;
  final int reEngagementAfterDays;
  final bool followUpsEnabled;
  final bool reEngagementEnabled;
  final bool newMatchesEnabled;

  const NudgeSettings({
    this.frequency = 'Once daily',
    this.timing = 'When I\'m usually active',
    this.maxPerDay = 3,
    this.followUpAfterDays = 3,
    this.reEngagementAfterDays = 7,
    this.followUpsEnabled = true,
    this.reEngagementEnabled = true,
    this.newMatchesEnabled = true,
  });
}

/// Task completion analytics
class TaskAnalytics {
  final int completedThisWeek;
  final int totalThisWeek;
  final double avgCompletionDays;
  final String mostProductiveDay;
  final String mostCommonTask;
  final String aiInsight;

  const TaskAnalytics({
    required this.completedThisWeek,
    required this.totalThisWeek,
    required this.avgCompletionDays,
    required this.mostProductiveDay,
    required this.mostCommonTask,
    required this.aiInsight,
  });
}

/// Group chat settings
class GroupSettings {
  final String name;
  final List<ChatUser> members;
  final bool showTypingIndicators;
  final bool allowMedia;
  final bool adminOnlyPosting;
  final bool addToFavorites;

  const GroupSettings({
    required this.name,
    required this.members,
    this.showTypingIndicators = true,
    this.allowMedia = true,
    this.adminOnlyPosting = false,
    this.addToFavorites = true,
  });
}

/// Media item in recent media section
class RecentMedia {
  final String id;
  final MessageType type;
  final String? thumbnailUrl;
  final DateTime timestamp;

  const RecentMedia({
    required this.id,
    required this.type,
    this.thumbnailUrl,
    required this.timestamp,
  });
}
