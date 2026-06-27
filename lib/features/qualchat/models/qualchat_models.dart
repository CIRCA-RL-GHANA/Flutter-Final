/// qualChat Module  Data Models
/// Communications Hub: Messages, Presence, HeyYa
/// Module Color: Cyan 0xFF06B6D4
library;

// 
//  ENUMS
// 

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

/// Hey Ya date intent  what kind of date the sender has in mind
enum HeyYaIntent { coffee, dinner, walk, movie, videoCall, any }

/// Timeline event types
enum TimelineEventType { sent, seen, viewed, reacted, replied, matched, expired, dateProposed, dateConfirmed }

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

// 
//  DATA MODELS
// 

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

  factory ChatUser.fromJson(Map<String, dynamic> json) => ChatUser(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        avatarUrl: json['avatarUrl'] as String?,
        role: json['role'] as String? ?? '',
        presence: PresenceStatus.values.firstWhere(
          (e) => e.name == (json['presence'] as String? ?? ''),
          orElse: () => PresenceStatus.offline,
        ),
        statusMessage: json['statusMessage'] as String?,
        lastSeen: DateTime.tryParse(json['lastSeen'] as String? ?? '') ?? DateTime.now(),
        department: json['department'] as String?,
        distanceKm: (json['distanceKm'] as num?)?.toDouble(),
        avgResponseMinutes: (json['avgResponseMinutes'] as num?)?.toInt() ?? 5,
        isFavorite: json['isFavorite'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarUrl': avatarUrl,
        'role': role,
        'presence': presence.name,
        'statusMessage': statusMessage,
        'lastSeen': lastSeen.toIso8601String(),
        'department': department,
        'distanceKm': distanceKm,
        'avgResponseMinutes': avgResponseMinutes,
        'isFavorite': isFavorite,
      };
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

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String? ?? '',
        senderId: json['senderId'] as String? ?? '',
        senderName: json['senderName'] as String? ?? '',
        type: MessageType.values.firstWhere(
          (e) => e.name == (json['type'] as String? ?? ''),
          orElse: () => MessageType.text,
        ),
        content: json['content'] as String? ?? '',
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
        status: DeliveryStatus.values.firstWhere(
          (e) => e.name == (json['status'] as String? ?? ''),
          orElse: () => DeliveryStatus.delivered,
        ),
        reactions: (json['reactions'] as List<dynamic>? ?? [])
            .map((e) => MessageReaction.values.firstWhere(
                  (r) => r.name == (e as String? ?? ''),
                  orElse: () => MessageReaction.smile,
                ))
            .toList(),
        attachmentUrl: json['attachmentUrl'] as String?,
        attachmentName: json['attachmentName'] as String?,
        attachmentSizeMb: (json['attachmentSizeMb'] as num?)?.toDouble(),
        isPinned: json['isPinned'] as bool? ?? false,
        replyToId: json['replyToId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'senderName': senderName,
        'type': type.name,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'status': status.name,
        'reactions': reactions.map((e) => e.name).toList(),
        'attachmentUrl': attachmentUrl,
        'attachmentName': attachmentName,
        'attachmentSizeMb': attachmentSizeMb,
        'isPinned': isPinned,
        'replyToId': replyToId,
      };
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

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        id: json['id'] as String? ?? '',
        type: ChatType.values.firstWhere(
          (e) => e.name == (json['type'] as String? ?? ''),
          orElse: () => ChatType.individual,
        ),
        title: json['title'] as String? ?? '',
        avatarUrl: json['avatarUrl'] as String?,
        lastMessage: json['lastMessage'] as String? ?? '',
        lastSenderName: json['lastSenderName'] as String? ?? '',
        lastMessageTime: DateTime.tryParse(json['lastMessageTime'] as String? ?? '') ?? DateTime.now(),
        unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
        isPinned: json['isPinned'] as bool? ?? false,
        isMuted: json['isMuted'] as bool? ?? false,
        isArchived: json['isArchived'] as bool? ?? false,
        priority: ConversationPriority.values.firstWhere(
          (e) => e.name == (json['priority'] as String? ?? ''),
          orElse: () => ConversationPriority.normal,
        ),
        participants: (json['participants'] as List<dynamic>? ?? [])
            .map((e) => ChatUser.fromJson(e as Map<String, dynamic>))
            .toList(),
        onlineCount: (json['onlineCount'] as num?)?.toInt(),
        typingUser: json['typingUser'] as String?,
        relationshipScore: (json['relationshipScore'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'avatarUrl': avatarUrl,
        'lastMessage': lastMessage,
        'lastSenderName': lastSenderName,
        'lastMessageTime': lastMessageTime.toIso8601String(),
        'unreadCount': unreadCount,
        'isPinned': isPinned,
        'isMuted': isMuted,
        'isArchived': isArchived,
        'priority': priority.name,
        'participants': participants.map((e) => e.toJson()).toList(),
        'onlineCount': onlineCount,
        'typingUser': typingUser,
        'relationshipScore': relationshipScore,
      };
}

/// A Hey Ya request (dating feature  Owner only)
/// Expresses romantic/social interest in another user and proposes a date intent.
/// Both users must accept for a match; Genie AI scores compatibility.
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
  final HeyYaIntent intent;
  final CompatibilityBreakdown? compatibility;

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
    this.intent = HeyYaIntent.any,
    this.compatibility,
  });

  factory HeyYaRequest.fromJson(Map<String, dynamic> json) => HeyYaRequest(
        id: json['id'] as String? ?? '',
        person: ChatUser.fromJson(json['person'] as Map<String, dynamic>? ?? {}),
        status: HeyYaStatus.values.firstWhere(
          (e) => e.name == (json['status'] as String? ?? ''),
          orElse: () => HeyYaStatus.pending,
        ),
        matchPercentage: (json['matchPercentage'] as num?)?.toInt() ?? 0,
        message: json['message'] as String?,
        sentAt: DateTime.tryParse(json['sentAt'] as String? ?? '') ?? DateTime.now(),
        expiresAt: json['expiresAt'] != null
            ? DateTime.tryParse(json['expiresAt'] as String? ?? '')
            : null,
        isSentByMe: json['isSentByMe'] as bool? ?? true,
        viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
        timeline: (json['timeline'] as List<dynamic>? ?? [])
            .map((e) => TimelineEvent.fromJson(e as Map<String, dynamic>))
            .toList(),
        intent: HeyYaIntent.values.firstWhere(
          (e) => e.name == (json['intent'] as String? ?? ''),
          orElse: () => HeyYaIntent.any,
        ),
        compatibility: json['compatibility'] != null
            ? CompatibilityBreakdown.fromJson(json['compatibility'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'person': person.toJson(),
        'status': status.name,
        'matchPercentage': matchPercentage,
        'message': message,
        'sentAt': sentAt.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
        'isSentByMe': isSentByMe,
        'viewCount': viewCount,
        'timeline': timeline.map((e) => e.toJson()).toList(),
        'intent': intent.name,
        'compatibility': compatibility?.toJson(),
      };
}

/// Genie AI compatibility breakdown for a Hey Ya pair
class CompatibilityBreakdown {
  final int interests;  // 0100
  final int vibe;       // 0100
  final int lifestyle;  // 0100
  final int values;     // 0100

  const CompatibilityBreakdown({
    required this.interests,
    required this.vibe,
    required this.lifestyle,
    required this.values,
  });

  int get overall => ((interests + vibe + lifestyle + values) / 4).round();

  factory CompatibilityBreakdown.fromJson(Map<String, dynamic> json) => CompatibilityBreakdown(
        interests: (json['interests'] as num?)?.toInt() ?? 0,
        vibe: (json['vibe'] as num?)?.toInt() ?? 0,
        lifestyle: (json['lifestyle'] as num?)?.toInt() ?? 0,
        values: (json['values'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'interests': interests,
        'vibe': vibe,
        'lifestyle': lifestyle,
        'values': values,
      };
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

  factory TimelineEvent.fromJson(Map<String, dynamic> json) => TimelineEvent(
        type: TimelineEventType.values.firstWhere(
          (e) => e.name == (json['type'] as String? ?? ''),
          orElse: () => TimelineEventType.sent,
        ),
        description: json['description'] as String? ?? '',
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
        detail: json['detail'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
        'detail': detail,
      };
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

  factory PresenceStats.fromJson(Map<String, dynamic> json) => PresenceStats(
        online: (json['online'] as num?)?.toInt() ?? 0,
        idle: (json['idle'] as num?)?.toInt() ?? 0,
        offline: (json['offline'] as num?)?.toInt() ?? 0,
        total: (json['total'] as num?)?.toInt() ?? 0,
        onlineChangePercent: (json['onlineChangePercent'] as num?)?.toDouble() ?? 0,
        idleChangePercent: (json['idleChangePercent'] as num?)?.toDouble() ?? 0,
        offlineChangePercent: (json['offlineChangePercent'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'online': online,
        'idle': idle,
        'offline': offline,
        'total': total,
        'onlineChangePercent': onlineChangePercent,
        'idleChangePercent': idleChangePercent,
        'offlineChangePercent': offlineChangePercent,
      };
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

  factory ActivityDataPoint.fromJson(Map<String, dynamic> json) => ActivityDataPoint(
        label: json['label'] as String? ?? '',
        value: (json['value'] as num?)?.toDouble() ?? 0,
        time: DateTime.tryParse(json['time'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'label': label,
        'value': value,
        'time': time.toIso8601String(),
      };
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

  factory SmartNudge.fromJson(Map<String, dynamic> json) => SmartNudge(
        id: json['id'] as String? ?? '',
        type: NudgeType.values.firstWhere(
          (e) => e.name == (json['type'] as String? ?? ''),
          orElse: () => NudgeType.followUp,
        ),
        person: ChatUser.fromJson(json['person'] as Map<String, dynamic>? ?? {}),
        matchPercentage: (json['matchPercentage'] as num?)?.toInt() ?? 0,
        prompt: json['prompt'] as String? ?? '',
        suggestedOpener: json['suggestedOpener'] as String? ?? '',
        reason: json['reason'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'person': person.toJson(),
        'matchPercentage': matchPercentage,
        'prompt': prompt,
        'suggestedOpener': suggestedOpener,
        'reason': reason,
        'createdAt': createdAt.toIso8601String(),
      };
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

  factory ActionTask.fromJson(Map<String, dynamic> json) => ActionTask(
        id: json['id'] as String? ?? '',
        type: TaskType.values.firstWhere(
          (e) => e.name == (json['type'] as String? ?? ''),
          orElse: () => TaskType.communication,
        ),
        priority: TaskPriority.values.firstWhere(
          (e) => e.name == (json['priority'] as String? ?? ''),
          orElse: () => TaskPriority.medium,
        ),
        status: TaskStatus.values.firstWhere(
          (e) => e.name == (json['status'] as String? ?? ''),
          orElse: () => TaskStatus.actNow,
        ),
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        dueDate: json['dueDate'] != null
            ? DateTime.tryParse(json['dueDate'] as String? ?? '')
            : null,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        quickActions: (json['quickActions'] as List<dynamic>? ?? [])
            .map((e) => e as String? ?? '')
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'priority': priority.name,
        'status': status.name,
        'title': title,
        'description': description,
        'dueDate': dueDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'quickActions': quickActions,
      };
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

  factory AISuggestion.fromJson(Map<String, dynamic> json) => AISuggestion(
        id: json['id'] as String? ?? '',
        text: json['text'] as String? ?? '',
        detail: json['detail'] as String?,
        isApplied: json['isApplied'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'detail': detail,
        'isApplied': isApplied,
      };
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

  factory ConversationInsight.fromJson(Map<String, dynamic> json) => ConversationInsight(
        priority: InsightPriority.values.firstWhere(
          (e) => e.name == (json['priority'] as String? ?? ''),
          orElse: () => InsightPriority.followUp,
        ),
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'priority': priority.name,
        'title': title,
        'description': description,
      };
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

  factory VibeImage.fromJson(Map<String, dynamic> json) => VibeImage(
        id: json['id'] as String? ?? '',
        imageUrl: json['imageUrl'] as String?,
        isActive: json['isActive'] as bool? ?? true,
        expiresAt: json['expiresAt'] != null
            ? DateTime.tryParse(json['expiresAt'] as String? ?? '')
            : null,
        views: (json['views'] as num?)?.toInt() ?? 0,
        likes: (json['likes'] as num?)?.toInt() ?? 0,
        comments: (json['comments'] as num?)?.toInt() ?? 0,
        connections: (json['connections'] as num?)?.toInt() ?? 0,
        matches: (json['matches'] as num?)?.toInt() ?? 0,
        remainingPercent: (json['remainingPercent'] as num?)?.toDouble() ?? 100,
        analysisText: json['analysisText'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'imageUrl': imageUrl,
        'isActive': isActive,
        'expiresAt': expiresAt?.toIso8601String(),
        'views': views,
        'likes': likes,
        'comments': comments,
        'connections': connections,
        'matches': matches,
        'remainingPercent': remainingPercent,
        'analysisText': analysisText,
      };
}

/// Preference weighting for compatibility algorithm
class CompatibilityWeight {
  final String label;
  final double percent;

  const CompatibilityWeight({required this.label, required this.percent});

  factory CompatibilityWeight.fromJson(Map<String, dynamic> json) => CompatibilityWeight(
        label: json['label'] as String? ?? '',
        percent: (json['percent'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'label': label,
        'percent': percent,
      };
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

  factory ArchivedChat.fromJson(Map<String, dynamic> json) => ArchivedChat(
        conversation: Conversation.fromJson(json['conversation'] as Map<String, dynamic>? ?? {}),
        archivedAt: DateTime.tryParse(json['archivedAt'] as String? ?? '') ?? DateTime.now(),
        sizeMb: (json['sizeMb'] as num?)?.toDouble() ?? 0,
        messageCount: (json['messageCount'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'conversation': conversation.toJson(),
        'archivedAt': archivedAt.toIso8601String(),
        'sizeMb': sizeMb,
        'messageCount': messageCount,
      };
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

  factory OnboardingStep.fromJson(Map<String, dynamic> json) => OnboardingStep(
        stepNumber: (json['stepNumber'] as num?)?.toInt() ?? 0,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        iconEmoji: json['iconEmoji'] as String?,
        isCompleted: json['isCompleted'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'stepNumber': stepNumber,
        'title': title,
        'description': description,
        'iconEmoji': iconEmoji,
        'isCompleted': isCompleted,
      };
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

  factory SettingsToggle.fromJson(Map<String, dynamic> json) => SettingsToggle(
        label: json['label'] as String? ?? '',
        value: json['value'] as bool? ?? false,
        section: ChatSettingsSection.values.firstWhere(
          (e) => e.name == (json['section'] as String? ?? ''),
          orElse: () => ChatSettingsSection.notifications,
        ),
      );

  Map<String, dynamic> toJson() => {
        'label': label,
        'value': value,
        'section': section.name,
      };
}

/// Connection success data point for the bar chart
class ConnectionSuccess {
  final int index;
  final bool isSuccess;

  const ConnectionSuccess({required this.index, required this.isSuccess});

  factory ConnectionSuccess.fromJson(Map<String, dynamic> json) => ConnectionSuccess(
        index: (json['index'] as num?)?.toInt() ?? 0,
        isSuccess: json['isSuccess'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'index': index,
        'isSuccess': isSuccess,
      };
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

  factory NudgeSettings.fromJson(Map<String, dynamic> json) => NudgeSettings(
        frequency: json['frequency'] as String? ?? 'Once daily',
        timing: json['timing'] as String? ?? 'When I\'m usually active',
        maxPerDay: (json['maxPerDay'] as num?)?.toInt() ?? 3,
        followUpAfterDays: (json['followUpAfterDays'] as num?)?.toInt() ?? 3,
        reEngagementAfterDays: (json['reEngagementAfterDays'] as num?)?.toInt() ?? 7,
        followUpsEnabled: json['followUpsEnabled'] as bool? ?? true,
        reEngagementEnabled: json['reEngagementEnabled'] as bool? ?? true,
        newMatchesEnabled: json['newMatchesEnabled'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'frequency': frequency,
        'timing': timing,
        'maxPerDay': maxPerDay,
        'followUpAfterDays': followUpAfterDays,
        'reEngagementAfterDays': reEngagementAfterDays,
        'followUpsEnabled': followUpsEnabled,
        'reEngagementEnabled': reEngagementEnabled,
        'newMatchesEnabled': newMatchesEnabled,
      };
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

  factory TaskAnalytics.fromJson(Map<String, dynamic> json) => TaskAnalytics(
        completedThisWeek: (json['completedThisWeek'] as num?)?.toInt() ?? 0,
        totalThisWeek: (json['totalThisWeek'] as num?)?.toInt() ?? 0,
        avgCompletionDays: (json['avgCompletionDays'] as num?)?.toDouble() ?? 0,
        mostProductiveDay: json['mostProductiveDay'] as String? ?? '',
        mostCommonTask: json['mostCommonTask'] as String? ?? '',
        aiInsight: json['aiInsight'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'completedThisWeek': completedThisWeek,
        'totalThisWeek': totalThisWeek,
        'avgCompletionDays': avgCompletionDays,
        'mostProductiveDay': mostProductiveDay,
        'mostCommonTask': mostCommonTask,
        'aiInsight': aiInsight,
      };
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

  factory GroupSettings.fromJson(Map<String, dynamic> json) => GroupSettings(
        name: json['name'] as String? ?? '',
        members: (json['members'] as List<dynamic>? ?? [])
            .map((e) => ChatUser.fromJson(e as Map<String, dynamic>))
            .toList(),
        showTypingIndicators: json['showTypingIndicators'] as bool? ?? true,
        allowMedia: json['allowMedia'] as bool? ?? true,
        adminOnlyPosting: json['adminOnlyPosting'] as bool? ?? false,
        addToFavorites: json['addToFavorites'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'members': members.map((e) => e.toJson()).toList(),
        'showTypingIndicators': showTypingIndicators,
        'allowMedia': allowMedia,
        'adminOnlyPosting': adminOnlyPosting,
        'addToFavorites': addToFavorites,
      };
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

  factory RecentMedia.fromJson(Map<String, dynamic> json) => RecentMedia(
        id: json['id'] as String? ?? '',
        type: MessageType.values.firstWhere(
          (e) => e.name == (json['type'] as String? ?? ''),
          orElse: () => MessageType.image,
        ),
        thumbnailUrl: json['thumbnailUrl'] as String?,
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'thumbnailUrl': thumbnailUrl,
        'timestamp': timestamp.toIso8601String(),
      };
}
