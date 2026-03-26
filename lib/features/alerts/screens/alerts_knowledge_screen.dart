/// Alerts Screen 7 — Knowledge Base Integration
/// AI-suggested solutions, similarity scores, feedback loop

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alerts_models.dart';
import '../providers/alerts_provider.dart';
import '../widgets/alerts_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class AlertsKnowledgeScreen extends StatelessWidget {
  final String? alertId;
  const AlertsKnowledgeScreen({super.key, this.alertId});

  @override
  Widget build(BuildContext context) {
    return Consumer<AlertsProvider>(
      builder: (context, provider, _) {
        final alert = alertId != null ? provider.getAlertById(alertId!) : null;
        final items = alert != null ? provider.knowledgeForAlert(alert) : provider.knowledgeBase;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: AlertsAppBar(
            title: 'Knowledge Base',
            actions: [
              IconButton(
                icon: const Icon(Icons.search, size: 22),
                onPressed: () => Navigator.pushNamed(context, '/alerts/search'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<AIInsightsNotifier>(
                  builder: (context, ai, _) {
                    if (ai.insights.isEmpty) return const SizedBox.shrink();
                    return Container(
                      color: kAlertsColor.withOpacity(0.07),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Row(children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kAlertsColor),
                        const SizedBox(width: 8),
                        Expanded(child: Text('AI: ${ai.insights.first['title'] ?? ''}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kAlertsColor),
                          maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ]),
                    );
                  },
                ),
                // ──── CONTEXT BANNER ────
                if (alert != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kAlertsCriticalLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 20, color: kAlertsCritical),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('AI-Suggested Solutions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kAlertsCritical)),
                              Text('Based on #${alert.id}: ${alert.title}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ──── CATEGORY TABS ────
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _KbFilterChip(label: 'All', isSelected: true, onTap: () {}),
                      _KbFilterChip(label: '📚 Articles', isSelected: false, onTap: () {}),
                      _KbFilterChip(label: '✅ Past Fixes', isSelected: false, onTap: () {}),
                      _KbFilterChip(label: '🌐 Community', isSelected: false, onTap: () {}),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ──── RESULTS COUNT ────
                Text(
                  '${items.length} article${items.length == 1 ? '' : 's'} found',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 12),

                // ──── KNOWLEDGE ITEMS ────
                if (items.isEmpty)
                  const AlertsEmptyState(
                    icon: Icons.library_books,
                    title: 'No Articles Found',
                    message: 'No matching knowledge base articles. Try broadening your search.',
                  )
                else
                  ...items.map((item) => KnowledgeItemCard(
                    item: item,
                    onTap: () => _showKbDetail(context, item),
                  )),

                const SizedBox(height: 16),

                // ──── FEEDBACK PROMPT ────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: kAlertsInfoLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text('Was this helpful?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kAlertsInfo)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _FeedbackButton(icon: Icons.thumb_up, label: 'Helpful', onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanks for your feedback! 👍'), backgroundColor: kAlertsResolved));
                          }),
                          const SizedBox(width: 12),
                          _FeedbackButton(icon: Icons.thumb_down, label: 'Not Helpful', onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('We\'ll improve our suggestions'), backgroundColor: kAlertsWarning));
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showKbDetail(BuildContext context, KnowledgeBaseItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)))),
              Row(
                children: [
                  Expanded(child: Text(item.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: kAlertsResolved.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text('${(item.similarityScore * 100).toInt()}% match', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kAlertsResolved)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(item.summary, style: const TextStyle(fontSize: 14, color: Color(0xFF374151), height: 1.6)),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.thumb_up, size: 16, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 4),
                  Text('${item.helpfulCount} people found this helpful', style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                ],
              ),
              if (item.source != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.source, size: 16, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 4),
                    Text('Source: ${item.source}', style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAlertsResolved,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Apply This Solution', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// KB Filter Chip
// ──────────────────────────────────────────────

class _KbFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _KbFilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? kAlertsCritical : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? kAlertsCritical : const Color(0xFFE5E7EB)),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : const Color(0xFF6B7280))),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Feedback Button
// ──────────────────────────────────────────────

class _FeedbackButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _FeedbackButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: kAlertsInfo),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
