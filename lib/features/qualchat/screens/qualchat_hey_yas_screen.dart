/// qualChat Screen 2 — Hey Ya (Owner Only)
/// Dating feature: express romantic interest, get AI-matched, plan a date

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/qualchat_models.dart';
import '../providers/qualchat_provider.dart';
import '../widgets/qualchat_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

const _kTabLabels = {
  HeyYaTab.all: 'All',
  HeyYaTab.sent: 'Sparked',
  HeyYaTab.received: 'Into Me',
  HeyYaTab.matches: 'Matched ðŸ’˜',
};

const _kStatusLabels = {
  HeyYaStatus.pending: 'Pending',
  HeyYaStatus.accepted: 'Matched',
  HeyYaStatus.expired: 'Expired',
  HeyYaStatus.rejected: 'Passed',
  HeyYaStatus.withdrawn: 'Withdrawn',
};

class QualChatHeyYasScreen extends StatelessWidget {
  const QualChatHeyYasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QualChatProvider>(
      builder: (context, provider, _) {
        final heyYas = provider.filteredHeyYas;
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: QualChatAppBar(
            title: 'Hey Ya ðŸ’–',
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                onSelected: (v) {},
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'match', child: Text('Sort by Match %')),
                  const PopupMenuItem(value: 'date', child: Text('Sort by Date')),
                  const PopupMenuItem(value: 'intent', child: Text('Sort by Date Intent')),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // Dating purpose strip
              Container(
                width: double.infinity,
                color: kChatSocial.withValues(alpha: 0.08),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    const Text('ðŸ’˜', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Spark interest Â· Get matched by Genie AI Â· Plan your date',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF9D174D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // AI insight strip
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.recommendations.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kChatColor.withValues(alpha: 0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kChatColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Genie AI match: ${ai.recommendations.first['name'] ?? ''}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kChatColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Tabs
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: HeyYaTab.values.map((tab) {
                    final isSelected = provider.heyYaTab == tab;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => provider.setHeyYaTab(tab),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? kChatSocial : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _kTabLabels[tab] ?? tab.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Status filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _StatusChip(
                      label: 'All',
                      isSelected: provider.heyYaStatusFilter == null,
                      onTap: () => provider.setHeyYaStatusFilter(null),
                    ),
                    ...HeyYaStatus.values.map((s) {
                      return _StatusChip(
                        label: _kStatusLabels[s] ?? s.name,
                        isSelected: provider.heyYaStatusFilter == s,
                        onTap: () => provider.setHeyYaStatusFilter(s),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // List
              Expanded(
                child: heyYas.isEmpty
                    ? const QualChatEmptyState(
                        icon: Icons.favorite_border,
                        title: 'No sparks yet',
                        message: 'Send a Hey Ya to someone you like — tell them\nyou\'re interested and pick a date idea ✨',
                        ctaLabel: '✨ Send Hey Ya',
                      )
                    : ListView.builder(
                        itemCount: heyYas.length,
                        itemBuilder: (context, index) {
                          final req = heyYas[index];
                          return HeyYaCard(
                            request: req,
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/qualchat/timeline',
                            ),
                            onTimeline: () => Navigator.pushNamed(
                              context,
                              '/qualchat/timeline',
                            ),
                            onFollowUp: () {},
                            onOptions: () {},
                          );
                        },
                      ),
              ),
            ],
          ),
          // Sticky footer
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: const Color(0xFFE5E7EB))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Text('ðŸ’–'),
                    label: const Text('Send Hey Ya'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kChatSocial,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.explore_outlined, size: 16),
                  label: const Text('Discover'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kChatColor,
                    side: const BorderSide(color: kChatColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _StatusChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? kChatColor.withValues(alpha: 0.1) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(16),
            border: isSelected ? Border.all(color: kChatColor) : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? kChatColor : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }
}
