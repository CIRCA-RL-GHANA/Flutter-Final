/// ═══════════════════════════════════════════════════════════════════════════
/// LIVE MODULE — Screen 6: Returns Tab
/// Filtered return requests with sub-tabs, bulk actions,
/// evidence previews, and auto-approve controls
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/routes/app_routes.dart';
import '../models/live_models.dart';
import '../providers/live_provider.dart';
import '../widgets/live_widgets.dart';

class LiveReturnsScreen extends StatefulWidget {
  const LiveReturnsScreen({super.key});

  @override
  State<LiveReturnsScreen> createState() => _LiveReturnsScreenState();
}

class _LiveReturnsScreenState extends State<LiveReturnsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveProvider>(
      builder: (context, prov, _) {
        final pending = prov.returns.where((r) => r.status == LiveReturnStatus.pending).toList();
        final underReview = prov.returns.where((r) => r.status == LiveReturnStatus.underReview).toList();
        final approved = prov.returns.where((r) => r.status == LiveReturnStatus.approved).toList();

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: LiveAppBar(
            title: 'Returns Management',
            actions: [
              IconButton(icon: const Icon(Icons.filter_list, size: 20), color: AppColors.textSecondary, onPressed: () {}),
              IconButton(icon: const Icon(Icons.search, size: 20), color: AppColors.textSecondary, onPressed: () {}),
            ],
          ),
          body: Column(
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kLiveColor.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kLiveColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI: ${ai.insights.first['title'] ?? ''}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kLiveColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: kLiveColor,
                  unselectedLabelColor: AppColors.textTertiary,
                  indicatorColor: kLiveColor,
                  labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  tabs: [
                    Tab(text: 'PENDING (${pending.length})'),
                    Tab(text: 'REVIEW (${underReview.length})'),
                    Tab(text: 'APPROVED (${approved.length})'),
                    Tab(text: 'ALL (${prov.returns.length})'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _ReturnList(returns: pending, prov: prov),
                    _ReturnList(returns: underReview, prov: prov),
                    _ReturnList(returns: approved, prov: prov),
                    _ReturnList(returns: prov.returns, prov: prov),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.check_circle, size: 16),
                    label: const Text('BULK REVIEW', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(foregroundColor: kLiveColor, padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.auto_awesome, size: 16),
                    label: const Text('AUTO-APPROVE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF10B981), padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.file_download, size: 16),
                    label: const Text('EXPORT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.textSecondary, padding: const EdgeInsets.symmetric(vertical: 12)),
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

class _ReturnList extends StatelessWidget {
  final List<LiveReturn> returns;
  final LiveProvider prov;
  const _ReturnList({required this.returns, required this.prov});

  @override
  Widget build(BuildContext context) {
    if (returns.isEmpty) {
      return const LiveEmptyState(
        icon: Icons.assignment_return,
        title: 'No returns here',
        subtitle: 'Returns matching this filter will appear here.',
      );
    }

    return RefreshIndicator(
      color: kLiveColor,
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        await prov.loadReturns();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: returns.length,
        itemBuilder: (context, i) => LiveReturnCard(
          ret: returns[i],
          onReview: () {
            prov.selectReturn(returns[i].id);
            Navigator.pushNamed(context, AppRoutes.liveReturnReview);
          },
        ),
      ),
    );
  }
}
