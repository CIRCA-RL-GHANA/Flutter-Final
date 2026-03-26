/// APRIL Screen 5 — Personal Statement Dashboard
/// 7 modular statement cards, version control, completion tracking

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../models/april_models.dart';
import '../providers/april_provider.dart';
import '../widgets/april_widgets.dart';

class AprilStatementScreen extends StatelessWidget {
  const AprilStatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AprilProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: AprilAppBar(
            title: '📝 Personal Statement',
            actions: [
              IconButton(icon: const Icon(Icons.share, size: 22), onPressed: () => _showShareSheet(context)),
              IconButton(icon: const Icon(Icons.history, size: 22), onPressed: () => _showVersionHistory(context, provider)),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Overall Progress Card
              _OverallProgressCard(provider: provider),
              const SizedBox(height: 16),

              // Statement Cards
              ...provider.statementCards.map((card) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: StatementCardWidget(
                  card: card,
                  onTap: () => _showCardEditor(context, card),
                ),
              )),
              const SizedBox(height: 16),

              // AI Assistant Section (real NLP keywords + sentiment)
              Consumer<AIInsightsNotifier>(
                builder: (ctx, aiNotifier, _) {
                  final insights = aiNotifier.insights;
                  final spending = aiNotifier.spendingPattern;
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [kAprilAccent.withOpacity(0.05), kAprilAccent.withOpacity(0.1)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kAprilAccent.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text('🤖', style: TextStyle(fontSize: 20)),
                            SizedBox(width: 8),
                            Text('AI Writing Assistant', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Let APRIL help you refine and complete your personal statement sections.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                        ),
                        // AI keyword insights strip
                        if (insights.isNotEmpty) ...
                          insights.take(1).map((i) {
                            final label = i['label']?.toString() ?? i['text']?.toString() ?? '';
                            if (label.isEmpty) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 10, bottom: 2),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: kAprilAccent.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.auto_awesome, size: 13, color: kAprilAccent),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'AI insight: $label',
                                        style: const TextStyle(fontSize: 11, color: kAprilAccent, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _AIActionChip(label: '✍️ Draft section', onTap: () {}),
                            _AIActionChip(label: '🔍 Review & refine', onTap: () {}),
                            _AIActionChip(label: '📊 Suggest highlights', onTap: () {}),
                            _AIActionChip(label: '🌐 Translate', onTap: () {}),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Security & Privacy
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock, size: 18, color: Color(0xFF10B981)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('End-to-End Encrypted', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          Text('Your personal statement is secured with 256-bit encryption',
                            style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Protected', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF10B981))),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  void _showCardEditor(BuildContext context, StatementCardData card) {
    final emojis = {
      StatementCard.lifestyle: '🏠',
      StatementCard.family: '👨‍👩‍👧‍👦',
      StatementCard.career: '💼',
      StatementCard.financial: '💰',
      StatementCard.health: '🏥',
      StatementCard.legal: '⚖️',
      StatementCard.growth: '🌱',
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2))),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(emojis[card.type] ?? '📄', style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(card.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        Text('${card.completionPercent}% complete', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // Completion Progress
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: card.completionPercent / 100,
                      backgroundColor: const Color(0xFFF3F4F6),
                      valueColor: const AlwaysStoppedAnimation(kAprilColor),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Highlights
                  if (card.highlights.isNotEmpty) ...[
                    const Text('Highlights', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: card.highlights.map((h) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: kAprilColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(h, style: const TextStyle(fontSize: 12, color: kAprilColorDark)),
                      )).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Content Field
                  const Text('Content', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    maxLines: 10,
                    initialValue: card.summary,
                    decoration: InputDecoration(
                      hintText: 'Write about your ${card.title.toLowerCase()}...',
                      hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Last Updated
                  Text(
                    'Last updated: ${_formatDate(card.lastUpdated)}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                  ),
                  const SizedBox(height: 16),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAprilColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVersionHistory(BuildContext context, AprilProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('Version History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Previous versions of your statement', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
            const SizedBox(height: 16),
            ...provider.statementVersions.map((v) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kAprilColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Text(v.versionNumber.toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kAprilColorDark))),
              ),
              title: Text(v.changeComment, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: Text(_formatDate(v.createdAt), style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              trailing: TextButton(
                onPressed: () {},
                child: const Text('Restore', style: TextStyle(fontSize: 12, color: kAprilColorDark)),
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('Share Statement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.picture_as_pdf, color: Color(0xFFEF4444)),
              title: const Text('Export as PDF'),
              subtitle: const Text('Download formatted document', style: TextStyle(fontSize: 12)),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.link, color: Color(0xFF3B82F6)),
              title: const Text('Share Link'),
              subtitle: const Text('Create a secure sharing link', style: TextStyle(fontSize: 12)),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.email, color: kAprilColorDark),
              title: const Text('Email'),
              subtitle: const Text('Send via email', style: TextStyle(fontSize: 12)),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

// ═══════════════════════════════════════════
// Overall Progress Card
// ═══════════════════════════════════════════
class _OverallProgressCard extends StatelessWidget {
  final AprilProvider provider;
  const _OverallProgressCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final percent = provider.overallCompletionPercent;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF283593)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Personal Statement', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: percent / 100,
                      strokeWidth: 5,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(kAprilColor),
                    ),
                    Text('${percent.toInt()}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      percent >= 80
                          ? 'Almost complete! 🎯'
                          : percent >= 50
                              ? 'Good progress! Keep going 💪'
                              : 'Let\'s build your story 📝',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${provider.statementCards.length} sections • ${provider.statementCards.where((c) => c.completionPercent == 100).length} complete',
                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AIActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AIActionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kAprilAccent.withOpacity(0.3)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
