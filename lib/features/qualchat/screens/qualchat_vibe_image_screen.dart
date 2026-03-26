/// qualChat Screen 5 — My Hey Ya Image (Owner Only)
/// Vibe Snapshot Studio: photo management, analytics, AI enhancement

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/qualchat_provider.dart';
import '../widgets/qualchat_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class QualChatVibeImageScreen extends StatelessWidget {
  const QualChatVibeImageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const vibe = QualChatProvider.currentVibeImage;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: QualChatAppBar(
        title: 'My Vibe Snapshot 📸',
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Consumer<AIInsightsNotifier>(
              builder: (context, ai, _) {
                if (ai.insights.isEmpty) return const SizedBox.shrink();
                return Container(
                  color: const Color(0xFF06B6D4).withOpacity(0.07),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(children: [
                    const Icon(Icons.auto_awesome, size: 14, color: Color(0xFF06B6D4)),
                    const SizedBox(width: 8),
                    Expanded(child: Text('AI: ${ai.insights.first['title'] ?? ''}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF06B6D4)),
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                );
              },
            ),
            // Photo placeholder
            Container(
              margin: const EdgeInsets.all(16),
              height: 220,
              decoration: BoxDecoration(
                color: kChatSocial.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kChatSocial.withOpacity(0.2)),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person, size: 64, color: kChatSocial.withOpacity(0.5)),
                    const SizedBox(height: 8),
                    const Text(
                      'YOUR PHOTO',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kChatSocial),
                    ),
                    const Text('16:9 • HD', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                  ],
                ),
              ),
            ),

            // Status + expiration
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status: 🟢 Active • Public • Sparkling!',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Expires: 2 days, 4 hours remaining',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 8),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: vibe.remainingPercent / 100,
                      backgroundColor: const Color(0xFFE5E7EB),
                      color: kChatSocial,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${vibe.remainingPercent.toInt()}% remaining',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ),

            // Performance Metrics
            QualChatSectionCard(
              title: 'Performance Metrics',
              child: Column(
                children: [
                  _MetricRow(emoji: '👁️', label: '${_abbr(vibe.views)} views', detail: '↑12% from last'),
                  _MetricRow(emoji: '❤️', label: '${vibe.likes} likes', detail: 'Top 15%'),
                  _MetricRow(emoji: '💬', label: '${vibe.comments} comments', detail: 'Engagement: High'),
                  _MetricRow(emoji: '👥', label: '${vibe.connections} connections', detail: '${vibe.matches} matches'),
                ],
              ),
            ),

            // Vibe Analysis
            QualChatSectionCard(
              title: 'Vibe Analysis',
              child: Text(
                vibe.analysisText ?? '',
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.5),
              ),
            ),

            // Actions grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _VibeAction(icon: '🧃', label: 'Refresh', onTap: () {}),
                  _VibeAction(icon: '✏️', label: 'Edit', onTap: () {}),
                  _VibeAction(icon: '🔄', label: 'Cycle', onTap: () {}),
                  _VibeAction(icon: '📊', label: 'Stats', onTap: () {}),
                  _VibeAction(icon: '⬇️', label: 'Save', onTap: () {}),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Bottom actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kChatColor,
                            side: const BorderSide(color: kChatColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Set as Profile'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kChatColor,
                            side: const BorderSide(color: kChatColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Schedule Next'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kChatSocial,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('AI Enhance'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  static String _abbr(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

class _MetricRow extends StatelessWidget {
  final String emoji;
  final String label;
  final String detail;
  const _MetricRow({required this.emoji, required this.label, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
          const Spacer(),
          Text(detail, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }
}

class _VibeAction extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  const _VibeAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            ],
          ),
        ),
      ),
    );
  }
}
