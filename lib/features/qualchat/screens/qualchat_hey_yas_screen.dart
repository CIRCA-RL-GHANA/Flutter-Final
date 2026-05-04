/// qualChat Screen 2 — My Hey Yas (Owner Only)
/// Browse, filter, and manage Hey Ya requests

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/qualchat_models.dart';
import '../providers/qualchat_provider.dart';
import '../widgets/qualchat_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

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
            title: 'My Hey Yas 💖',
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                onSelected: (v) {},
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'date', child: Text('Sort by Date')),
                  const PopupMenuItem(value: 'match', child: Text('Sort by Match %')),
                  const PopupMenuItem(value: 'status', child: Text('Sort by Status')),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.recommendations.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kChatColor.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kChatColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI suggests: ${ai.recommendations.first['name'] ?? ''}',
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
                    final label = tab.name[0].toUpperCase() + tab.name.substring(1);
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
                            label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
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
                        label: s.name[0].toUpperCase() + s.name.substring(1),
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
                        title: 'No Hey Yas yet',
                        message: 'Your vibe attracts your tribe ✨\nSend your first Hey Ya!',
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
          // Sticky footer for batch
          bottomNavigationBar: heyYas.isNotEmpty
              ? Container(
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
                          icon: const Text('✨'),
                          label: const Text('Send Message'),
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
                        icon: const Icon(Icons.schedule, size: 16),
                        label: const Text('Remind'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kChatColor,
                          side: const BorderSide(color: kChatColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                )
              : null,
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
            color: isSelected ? kChatColor.withOpacity(0.1) : const Color(0xFFF3F4F6),
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
