/// qualChat Screen 5  My Hey Ya Image (Owner Only)
/// Vibe Snapshot Studio: photo management, analytics, AI enhancement
library;

import 'package:flutter/material.dart';
import '../../../core/design/ive_tokens.dart';
import '../providers/qualchat_provider.dart';
import '../widgets/qualchat_widgets.dart';

class QualChatVibeImageScreen extends StatelessWidget {
  const QualChatVibeImageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const vibe = QualChatProvider.currentVibeImage;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: QualChatAppBar(
        title: 'My Vibe Snapshot "',
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            builder: (_) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.share),
                    title: const Text('Share'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link copied to clipboard')),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: const Text('Delete'),
                    onTap: () => Navigator.pop(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.report_outlined),
                    title: const Text('Report'),
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          );
        }),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Photo placeholder
            Container(
              margin: const EdgeInsets.all(16),
              height: 220,
              decoration: BoxDecoration(
                color: kChatSocial.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kChatSocial.withValues(alpha: 0.2)),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person, size: 64, color: kChatSocial.withValues(alpha: 0.5)),
                    const SizedBox(height: 8),
                    const Text(
                      'YOUR PHOTO',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kChatSocial),
                    ),
                    const Text('16:9  HD', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
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
                    'Status:  Active  Public  Sparkling!',
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
                    borderRadius: BorderRadius.circular(6),
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
                  _MetricRow(emoji: '', label: '${_abbr(vibe.views)} views', detail: '+12% from last'),
                  _MetricRow(emoji: '', label: '${vibe.likes} likes', detail: 'Top 15%'),
                  _MetricRow(emoji: '', label: '${vibe.comments} comments', detail: 'Engagement: High'),
                  _MetricRow(emoji: '', label: '${vibe.connections} connections', detail: '${vibe.matches} matches'),
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
                  _VibeAction(icon: '', label: 'Refresh', onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Refreshing vibe...')),
                    );
                  }),
                  _VibeAction(icon: '', label: 'Edit', onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening editor...')),
                    );
                  }),
                  _VibeAction(icon: '', label: 'Cycle', onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cycling vibe image...')),
                    );
                  }),
                  _VibeAction(icon: '', label: 'Stats', onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Loading stats...')),
                    );
                  }),
                  _VibeAction(icon: '', label: 'Save', onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Saving...')),
                    );
                  }),
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
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Set as profile picture')),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: IveTokens.moduleQualChat,
                            side: const BorderSide(color: IveTokens.moduleQualChat),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Set as Profile'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Schedule next vibe image')),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: IveTokens.moduleQualChat,
                            side: const BorderSide(color: IveTokens.moduleQualChat),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Schedule Next'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('AI enhancing...')),
                            );
                          },
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
            borderRadius: BorderRadius.circular(10),
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
