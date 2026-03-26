/// ═══════════════════════════════════════════════════════════════════════════
/// LIVE MODULE — Screen 9: Packages Tab
/// All packages with sub-tabs, progress tracking,
/// security info, and real-time status
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../models/live_models.dart';
import '../providers/live_provider.dart';
import '../widgets/live_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class LivePackagesScreen extends StatefulWidget {
  const LivePackagesScreen({super.key});

  @override
  State<LivePackagesScreen> createState() => _LivePackagesScreenState();
}

class _LivePackagesScreenState extends State<LivePackagesScreen> with SingleTickerProviderStateMixin {
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
        final pending = prov.packages.where((p) => p.status == PackageStatus.created).toList();
        final active = prov.packages.where((p) => p.status == PackageStatus.inTransit || p.status == PackageStatus.active).toList();
        final delivered = prov.packages.where((p) => p.status == PackageStatus.delivered).toList();

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: LiveAppBar(
            title: 'Package Management',
            actions: [
              IconButton(icon: const Icon(Icons.filter_list, size: 20), color: AppColors.textSecondary, onPressed: () {}),
              IconButton(icon: const Icon(Icons.search, size: 20), color: AppColors.textSecondary, onPressed: () {}),
            ],
          ),
          body: Column(
            children: [
              // AI insights strip
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kLiveColor.withOpacity(0.06),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 13, color: kLiveColor),
                        const SizedBox(width: 8),
                        Expanded(child: Text('AI: ${ai.insights.first['title'] ?? ''}', style: const TextStyle(fontSize: 12, color: kLiveColor), maxLines: 1, overflow: TextOverflow.ellipsis)),
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
                    Tab(text: 'ACTIVE (${active.length})'),
                    Tab(text: 'DELIVERED (${delivered.length})'),
                    Tab(text: 'ALL (${prov.packages.length})'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _PackageList(packages: pending, prov: prov),
                    _PackageList(packages: active, prov: prov),
                    _PackageList(packages: delivered, prov: prov),
                    _PackageList(packages: prov.packages, prov: prov),
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
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.livePackageCreation),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('CREATE NEW PACKAGE', style: TextStyle(fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(backgroundColor: kLiveColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.file_download, size: 16),
                  label: const Text('EXPORT', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.textSecondary, padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PackageList extends StatelessWidget {
  final List<LivePackage> packages;
  final LiveProvider prov;
  const _PackageList({required this.packages, required this.prov});

  @override
  Widget build(BuildContext context) {
    if (packages.isEmpty) {
      return const LiveEmptyState(
        icon: Icons.inventory_2,
        title: 'No packages here',
        subtitle: 'Packages matching this filter will appear here.',
      );
    }

    return RefreshIndicator(
      color: kLiveColor,
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: packages.length,
        itemBuilder: (context, i) => LivePackageCard(
          package: packages[i],
          onTap: () {
            prov.selectPackage(packages[i].id);
            Navigator.pushNamed(context, AppRoutes.livePackageDetail);
          },
        ),
      ),
    );
  }
}
