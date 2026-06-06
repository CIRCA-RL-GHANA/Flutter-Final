/// qualChat Screen 3 — Hey Ya Journey (Owner Only)
/// Dating timeline: track your connection journey and plan a date
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/qualchat_models.dart';
import '../providers/qualchat_provider.dart';
import '../widgets/qualchat_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/routes/app_routes.dart';

class QualChatTimelineScreen extends StatelessWidget {
  const QualChatTimelineScreen({super.key});

  String _intentLabel(HeyYaIntent intent) {
    const labels = {
      HeyYaIntent.coffee: 'Coffee â˜•',
      HeyYaIntent.dinner: 'Dinner ðŸ½ï¸',
      HeyYaIntent.walk: 'Walk ðŸš¶',
      HeyYaIntent.movie: 'Movie Night ðŸŽ¬',
      HeyYaIntent.videoCall: 'Video Date ðŸ“¹',
      HeyYaIntent.any: 'Open to Anything ðŸ’«',
    };
    return labels[intent] ?? 'Open to Anything';
  }

  String _statusLabel(HeyYaStatus status) {
    const labels = {
      HeyYaStatus.pending: 'â³ Awaiting response',
      HeyYaStatus.accepted: 'ðŸ’˜ Matched!',
      HeyYaStatus.expired: 'âŒ› Expired',
      HeyYaStatus.rejected: 'ðŸ’” Passed',
      HeyYaStatus.withdrawn: 'â†©ï¸ Withdrawn',
    };
    return labels[status] ?? status.name;
  }

  @override
  Widget build(BuildContext context) {
    // Use first Hey Ya as demo
    final request = QualChatProvider.heyYaRequests.first;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: QualChatAppBar(
        title: 'Dating Journey ðŸ’˜',
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Link copied to clipboard')),
              );
            },
            child: const Text('Share', style: TextStyle(color: kChatColor)),
          ),
        ],
      ),
      body: Column(
        children: [
          Consumer<AIInsightsNotifier>(
            builder: (context, ai, _) {
              if (ai.insights.isEmpty) return const SizedBox.shrink();
              return Container(
                color: kChatColor.withValues(alpha: 0.07),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(children: [
                  const Icon(Icons.auto_awesome, size: 14, color: kChatColor),
                  const SizedBox(width: 8),
                  Expanded(child: Text('AI: ${ai.insights.first['title'] ?? ''}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kChatColor),
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
              );
            },
          ),
          // Header card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: kChatSocial.withValues(alpha: 0.1),
                  child: Text(
                    request.person.name[0],
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kChatSocial),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.person.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Match Score: ${request.matchPercentage}% ðŸ’˜',
                        style: const TextStyle(fontSize: 13, color: kChatSocial),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ðŸ“… Intent: ${_intentLabel(request.intent)}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Status: ${_statusLabel(request.status)}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Timeline
          Expanded(
            child: request.timeline.isEmpty
                ? const QualChatEmptyState(
                    icon: Icons.timeline,
                    title: 'No timeline events',
                    message: 'Events will appear as your connection progresses.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: request.timeline.length + 1, // +1 for pending
                    itemBuilder: (context, index) {
                      if (index < request.timeline.length) {
                        return _TimelineItem(
                          event: request.timeline[index],
                          isLast: index == request.timeline.length - 1 &&
                              request.status != HeyYaStatus.pending,
                        );
                      }
                      // Pending / expiration item
                      if (request.status == HeyYaStatus.pending) {
                        return _PendingTimelineItem(request: request);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
          ),
        ],
      ),
      // Action panel
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              request.status == HeyYaStatus.accepted
                  ? 'ðŸ’˜ You matched! Ready to plan your date?'
                  : 'Still into ${request.person.name}? ðŸ˜Š',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _ActionButton(icon: '💌', label: 'Say Hi', onTap: () => Navigator.pushNamed(context, AppRoutes.qualChatDashboard)),
                const SizedBox(width: 8),
                _ActionButton(icon: '📅', label: 'Plan Date', onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening planner...')),
                  );
                }, isPrimary: true),
                const SizedBox(width: 8),
                _ActionButton(icon: '🎤', label: 'Voice Note', onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Recording voice note...')),
                  );
                }),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _ActionButton(icon: '✅', label: 'Accept', onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Accepted!')),
                  );
                }, isPrimary: request.status == HeyYaStatus.pending && !request.isSentByMe),
                const SizedBox(width: 8),
                _ActionButton(icon: '🔄', label: 'Re-spark', onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Re-sparked!')),
                  );
                }),
                const SizedBox(width: 8),
                _ActionButton(icon: '❌', label: 'Withdraw', onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Withdrawn')),
                  );
                }, isDestructive: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final TimelineEvent event;
  final bool isLast;
  const _TimelineItem({required this.event, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline connector
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: kChatSocial,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: kChatSocial.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.description,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  if (event.detail != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      event.detail!,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    'â° ${_formatDateTime(event.timestamp)}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, $hour:${dt.minute.toString().padLeft(2, '0')} $amPm';
  }
}

class _PendingTimelineItem extends StatelessWidget {
  final HeyYaRequest request;
  const _PendingTimelineItem({required this.request});

  @override
  Widget build(BuildContext context) {
    final remaining = request.expiresAt?.difference(DateTime.now());
    return Column(
      children: [
        // Pending badge
        Row(
          children: [
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                  Container(width: 2, height: 16, color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'â³ PENDING RESPONSE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Expiry
        if (remaining != null)
          Row(
            children: [
              const SizedBox(width: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'â° Expires in: ${remaining.inDays}d ${remaining.inHours % 24}h',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isDestructive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isPrimary
                ? kChatSocial
                : isDestructive
                    ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                    : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isPrimary
                      ? Colors.white
                      : isDestructive
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
