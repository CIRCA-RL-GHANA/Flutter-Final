/// ═══════════════════════════════════════════════════════════════════════════
/// SD0: SETUP DASHBOARD HUB — Master Entry Point
/// 6-row adaptive card matrix with role-based filtering
/// Rows: Operations, Finance & Staff, Logistics, Engagement,
///        Branch Identity, Personal & History
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../prompt/models/rbac_models.dart';
import '../../prompt/providers/context_provider.dart';
import '../models/setup_dashboard_models.dart';
import '../providers/setup_dashboard_provider.dart';
import '../widgets/shared_widgets.dart';

class SetupDashboardScreen extends StatefulWidget {
  const SetupDashboardScreen({super.key});

  @override
  State<SetupDashboardScreen> createState() => _SetupDashboardScreenState();
}

class _SetupDashboardScreenState extends State<SetupDashboardScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        final role = ctxProv.currentRole;
        final cards = setupProv.getCardsForRole(role);
        final header = setupProv.headerInfo;

        // Filter cards by search query
        final filteredCards = _searchQuery.isEmpty
            ? cards
            : cards.where((c) =>
                c.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

        // Group cards into rows
        final rows = _groupCardsIntoRows(filteredCards);

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FC),
          appBar: const SetupAppBar(title: 'Setup Dashboard'),
          body: RefreshIndicator(
            color: kSetupColor,
            onRefresh: () async {
              await setupProv.refreshSection('hub');
            },
            child: CustomScrollView(
              slivers: [
                // ─── Header Banner ────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: _HeaderBanner(header: header, role: role),
                  ),
                ),

                // ─── Search Bar ───────────────────────────────
              // ─── AI Insights ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Consumer<AIInsightsNotifier>(
                  builder: (context, ai, _) {
                    if (ai.insights.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: kSetupColor.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome, size: 14, color: kSetupColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'AI: ${ai.insights.first['title'] ?? ''}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kSetupColor),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _SearchBar(
                      onChanged: (q) => setState(() => _searchQuery = q),
                    ),
                  ),
                ),

                // ─── Card Rows ────────────────────────────────
                ...rows.entries.map((entry) {
                  final rowCards = entry.value;
                  if (rowCards.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SetupSectionTitle(
                            title: entry.key,
                            icon: _rowIcon(entry.key),
                          ),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final crossAxisCount =
                                  constraints.maxWidth > 600 ? 4 :
                                  constraints.maxWidth > 400 ? 3 : 2;
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 0.78,
                                ),
                                itemCount: rowCards.length,
                                itemBuilder: (context, i) {
                                  return SetupModuleCard(
                                    card: rowCards[i],
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      rowCards[i].route,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                // ─── Empty State ──────────────────────────
                if (filteredCards.isEmpty && _searchQuery.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: SetupEmptyState(
                        icon: Icons.search_off,
                        title: 'No modules found',
                        subtitle: 'Try a different search term',
                      ),
                    ),
                  ),

                // ─── SOS Button (Owner/Admin/BranchManager only) ──
                if (WidgetVisibility.canSeeSOS(role))
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: _SOSButton(),
                    ),
                  ),

                // ─── Bottom Spacer ────────────────────────────
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Group cards into named rows
  Map<String, List<DashboardCard>> _groupCardsIntoRows(List<DashboardCard> cards) {
    final Map<String, List<String>> rowDefinitions = {
      'Operations Snapshot': ['products', 'vehicles', 'tabs'],
      'Finance & Staff': ['discounts', 'staff', 'activity_log'],
      'Logistics': ['places', 'delivery_zones', 'vehicle_bands', 'branches'],
      'Engagement': ['marketing', 'social', 'connections'],
      'Branch Identity': ['profile', 'outlook', 'subscription'],
      'Personal & History': ['interests', 'qpoints', 'my_activity'],
    };

    final Map<String, List<DashboardCard>> rows = {};
    for (final entry in rowDefinitions.entries) {
      final rowCards = entry.value
          .map((id) {
            try {
              return cards.firstWhere((c) => c.id == id);
            } catch (_) {
              return null;
            }
          })
          .whereType<DashboardCard>()
          .toList();
      if (rowCards.isNotEmpty) {
        rows[entry.key] = rowCards;
      }
    }
    return rows;
  }

  IconData _rowIcon(String rowTitle) {
    switch (rowTitle) {
      case 'Operations Snapshot':
        return Icons.inventory_2;
      case 'Finance & Staff':
        return Icons.account_balance;
      case 'Logistics':
        return Icons.local_shipping;
      case 'Engagement':
        return Icons.campaign;
      case 'Branch Identity':
        return Icons.badge;
      case 'Personal & History':
        return Icons.person;
      default:
        return Icons.grid_view;
    }
  }
}

// ─── Header Banner ───────────────────────────────────────────────────────────

class _HeaderBanner extends StatelessWidget {
  final DashboardHeaderInfo header;
  final UserRole role;

  const _HeaderBanner({required this.header, required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kSetupColor.withOpacity(0.08),
            kSetupColor.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kSetupColor.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: kSetupColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                header.userName.isNotEmpty ? header.userName[0] : '?',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: kSetupColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${header.userName}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${header.roleName} · ${header.branchName}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Sync indicator
          _SyncBadge(state: header.syncState),
        ],
      ),
    );
  }
}

// ─── Sync Badge ──────────────────────────────────────────────────────────────

class _SyncBadge extends StatelessWidget {
  final SyncState state;
  const _SyncBadge({required this.state});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    final IconData icon;

    switch (state) {
      case SyncState.synced:
        color = AppColors.success;
        label = 'Synced';
        icon = Icons.cloud_done;
        break;
      case SyncState.syncing:
        color = kSetupColor;
        label = 'Syncing';
        icon = Icons.sync;
        break;
      case SyncState.offline:
        color = AppColors.error;
        label = 'Offline';
        icon = Icons.cloud_off;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Search Bar ──────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search, size: 20, color: AppColors.textTertiary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search modules, settings...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: AppColors.textTertiary,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }
}

// ─── SOS Button ──────────────────────────────────────────────────────────────

class _SOSButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SOS Alert Sent'),
            backgroundColor: AppColors.error,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.error.withOpacity(0.1),
              AppColors.error.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withOpacity(0.2)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sos, size: 24, color: AppColors.error),
            SizedBox(width: 10),
            Text(
              'Emergency SOS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
