/// ═══════════════════════════════════════════════════════════════════════════
/// SD1.12: CONNECTIONS — Network Management
/// Connection list, types, strength, interaction history
/// RBAC: Owner(personal), Admin(full), BM(branch), SO(full), BSO(branch),
///        Monitor/BrMon(view), RO/BRO(own), Driver(own)
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../prompt/providers/context_provider.dart';
import '../models/setup_dashboard_models.dart';
import '../providers/setup_dashboard_provider.dart';
import '../widgets/shared_widgets.dart';

class ConnectionsScreen extends StatelessWidget {
  const ConnectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        final connections = setupProv.connections;

        return SetupRbacGate(
          cardId: 'connections',
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FC),
            appBar: SetupAppBar(
              title: 'Connections',
              actions: [
                DataScopeIndicator(access: setupProv.getCardAccess('connections', ctxProv.currentRole)),
                SizedBox(width: 16),
              ],
            ),
            floatingActionButton: SetupRbacFAB(
              cardId: 'connections',
              onPressed: () {},
              label: 'Add Contact',
              icon: Icons.person_add,
            ),
          body: CustomScrollView(
            slivers: [
              // ─── Network KPIs ─────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: KPIBadge(
                          label: 'Active',
                          value: '${setupProv.activeConnectionCount}',
                          icon: Icons.handshake,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: KPIBadge(
                          label: 'Pending',
                          value: '${connections.where((c) => c.status == ConnectionStatus.pending).length}',
                          icon: Icons.hourglass_empty,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: KPIBadge(
                          label: 'Net. Value',
                          value: '₵${(connections.fold<double>(0, (s, c) => s + c.totalValue) / 1000).toStringAsFixed(0)}K',
                          icon: Icons.account_balance_wallet,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Type Filter ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _TypeFilterChip(label: 'All', count: connections.length, isSelected: true),
                        const SizedBox(width: 6),
                        _TypeFilterChip(label: 'Suppliers', count: connections.where((c) => c.type == ConnectionType.supplier).length, color: const Color(0xFF8B5CF6)),
                        const SizedBox(width: 6),
                        _TypeFilterChip(label: 'Customers', count: connections.where((c) => c.type == ConnectionType.customer).length, color: AppColors.success),
                        const SizedBox(width: 6),
                        _TypeFilterChip(label: 'Partners', count: connections.where((c) => c.type == ConnectionType.partner).length, color: kSetupColor),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── Network Health ───────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Network Strength',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _NetworkStat(
                                label: 'Strong',
                                count: connections.where((c) => c.strengthPercent >= 70).length,
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _NetworkStat(
                                label: 'Growing',
                                count: connections.where((c) => c.strengthPercent >= 40 && c.strengthPercent < 70).length,
                                color: AppColors.warning,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _NetworkStat(
                                label: 'New',
                                count: connections.where((c) => c.strengthPercent < 40).length,
                                color: AppColors.info,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: const SetupSectionTitle(title: 'Your Network', icon: Icons.handshake),
                ),
              ),
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
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _ConnectionCard(connection: connections[i]),
                    childCount: connections.length,
                  ),
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

class _ConnectionCard extends StatelessWidget {
  final Connection connection;
  const _ConnectionCard({required this.connection});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<SetupDashboardProvider>().selectConnection(connection.id);
        Navigator.pushNamed(context, AppRoutes.setupConnectionDetail);
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _typeColor(connection.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    connection.name.isNotEmpty ? connection.name[0] : '?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _typeColor(connection.type),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      connection.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    Text(
                      '${connection.type.name} · ${connection.category ?? "General"}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              SetupStatusIndicator(
                label: connection.status.name,
                color: connection.status == ConnectionStatus.active
                    ? AppColors.success
                    : connection.status == ConnectionStatus.pending
                        ? AppColors.warning
                        : AppColors.error,
              ),
            ],
          ),
          if (connection.status == ConnectionStatus.active) ...[
            const Divider(height: 16),
            Row(
              children: [
                if (connection.strengthPercent > 0) ...[
                  SetupPercentageRing(
                    percentage: connection.strengthPercent / 100,
                    color: kSetupColor,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (connection.totalOrders > 0)
                        Text(
                          '${connection.totalOrders} orders · ₵${(connection.totalValue / 1000).toStringAsFixed(0)}K',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                      if (connection.lastInteraction != null)
                        Text(
                          'Last: ${connection.lastInteraction}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                        ),
                    ],
                  ),
                ),
                if (connection.rating > 0) ...[
                  const Icon(Icons.star, size: 14, color: AppColors.accent),
                  const SizedBox(width: 2),
                  Text(
                    connection.rating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    ),
    );
  }

  Color _typeColor(ConnectionType type) {
    switch (type) {
      case ConnectionType.supplier:
        return const Color(0xFF8B5CF6);
      case ConnectionType.customer:
        return AppColors.success;
      case ConnectionType.partner:
        return kSetupColor;
      case ConnectionType.other:
        return AppColors.textTertiary;
    }
  }
}

// ─── Type Filter Chip ────────────────────────────────────────────────────────

class _TypeFilterChip extends StatelessWidget {
  final String label;
  final int count;
  final Color? color;
  final bool isSelected;

  const _TypeFilterChip({
    required this.label,
    required this.count,
    this.color,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? kSetupColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? c.withOpacity(0.12) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? c.withOpacity(0.4) : AppColors.inputBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? c : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: c.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$count', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: c)),
          ),
        ],
      ),
    );
  }
}

// ─── Network Stat ────────────────────────────────────────────────────────────

class _NetworkStat extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _NetworkStat({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text('$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}
