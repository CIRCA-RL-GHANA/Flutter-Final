/// ═══════════════════════════════════════════════════════════════════════════
/// SD1.5-DETAIL: CONNECTION DETAIL — 4-Tab Deep View
/// Tabs: Overview, Transactions, Communication, Notes
/// RBAC: Admin(full), BM(branch), SO(full), BSO(branch), Monitor(viewOnly)
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../prompt/providers/context_provider.dart';
import '../models/setup_dashboard_models.dart';
import '../providers/setup_dashboard_provider.dart';
import '../widgets/shared_widgets.dart';

class ConnectionDetailScreen extends StatefulWidget {
  const ConnectionDetailScreen({super.key});

  @override
  State<ConnectionDetailScreen> createState() => _ConnectionDetailScreenState();
}

class _ConnectionDetailScreenState extends State<ConnectionDetailScreen> {
  int _tabIndex = 0;
  static const _tabs = ['Overview', 'Transactions', 'Communication', 'Notes'];

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        final conn = setupProv.selectedConnection;
        if (conn == null) {
          return Scaffold(
            appBar: const SetupAppBar(title: 'Connection Detail'),
            body: const SetupEmptyState(
              icon: Icons.hub,
              title: 'No connection selected',
              subtitle: 'Select a connection from the list',
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FC),
          appBar: SetupAppBar(title: conn.name),
          body: Column(
            children: [
              _ConnectionHeader(conn: conn),
              const SizedBox(height: 12),
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kSetupColor.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kSetupColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "AI: ${ai.insights.first['title'] ?? ''}",
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kSetupColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SetupDetailTabBar(
                tabs: _tabs,
                selectedIndex: _tabIndex,
                onTabChanged: (i) => setState(() => _tabIndex = i),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: IndexedStack(
                  index: _tabIndex,
                  children: [
                    _OverviewTab(conn: conn),
                    _TransactionsTab(conn: conn),
                    _CommunicationTab(conn: conn),
                    _NotesTab(conn: conn),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _ConnectionHeader extends StatelessWidget {
  final Connection conn;
  const _ConnectionHeader({required this.conn});

  @override
  Widget build(BuildContext context) {
    final statusColor = conn.status == ConnectionStatus.active
        ? AppColors.success
        : conn.status == ConnectionStatus.pending
            ? AppColors.warning
            : AppColors.textTertiary;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [kSetupColor, kSetupColor.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                conn.name.isNotEmpty ? conn.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        conn.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        conn.status.name,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${conn.type.name} · ${conn.category} · ★ ${conn.rating.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                if (conn.connectedSince != null)
                Text(
                  'Connected since ${conn.connectedSince!.day}/${conn.connectedSince!.month}/${conn.connectedSince!.year}',
                  style: TextStyle(
                    fontSize: 11,
                    color: kSetupColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Overview Tab ────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final Connection conn;
  const _OverviewTab({required this.conn});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // KPI Row
        Row(
          children: [
            Expanded(
              child: KPIBadge(
                label: 'Orders',
                value: '${conn.totalOrders}',
                icon: Icons.shopping_bag,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: KPIBadge(
                label: 'Total Value',
                value: '₵${conn.totalValue.toStringAsFixed(0)}',
                icon: Icons.monetization_on,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: KPIBadge(
                label: 'Strength',
                value: '${conn.strengthPercent.toInt()}%',
                icon: Icons.favorite,
                color: conn.strengthPercent >= 70
                    ? AppColors.success
                    : conn.strengthPercent >= 40
                        ? AppColors.warning
                        : AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Contact Info
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SetupSectionTitle(title: 'Contact Information', icon: Icons.contact_page),
              SetupInfoRow(label: 'Type', value: conn.type.name),
              SetupInfoRow(label: 'Category', value: conn.category ?? 'N/A'),
              SetupInfoRow(label: 'Rating', value: '★ ${conn.rating.toStringAsFixed(1)} / 5.0'),
            ],
          ),
        ),

        // Relationship Metrics
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SetupSectionTitle(title: 'Relationship', icon: Icons.handshake),
              if (conn.connectedSince != null)
                SetupInfoRow(
                  label: 'Connected Since',
                  value: '${conn.connectedSince!.day}/${conn.connectedSince!.month}/${conn.connectedSince!.year}',
                ),
              SetupInfoRow(
                label: 'Last Interaction',
                value: conn.lastInteraction ?? 'N/A',
              ),
              SetupInfoRow(
                label: 'Avg Order Value',
                value: conn.totalOrders > 0
                    ? '₵${(conn.totalValue / conn.totalOrders).toStringAsFixed(0)}'
                    : '₵0',
              ),
              const SizedBox(height: 8),
              _StrengthIndicator(value: conn.strengthPercent),
            ],
          ),
        ),

        const SizedBox(height: 80),
      ],
    );
  }
}

// ─── Transactions Tab ────────────────────────────────────────────────────────

class _TransactionsTab extends StatelessWidget {
  final Connection conn;
  const _TransactionsTab({required this.conn});

  @override
  Widget build(BuildContext context) {
    // Demo transaction data
    final txns = List.generate(8, (i) {
      final days = i * 5 + 2;
      final amount = (200 + i * 75.0);
      return {
        'date': DateTime.now().subtract(Duration(days: days)),
        'amount': amount,
        'items': i + 2,
        'status': i < 6 ? 'Completed' : 'Pending',
      };
    });

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // Summary Row
        Row(
          children: [
            Expanded(
              child: KPIBadge(
                label: 'Total Orders',
                value: '${conn.totalOrders}',
                icon: Icons.receipt_long,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: KPIBadge(
                label: 'Total Spent',
                value: '₵${conn.totalValue.toStringAsFixed(0)}',
                icon: Icons.monetization_on,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        ...txns.map((t) {
          final date = t['date'] as DateTime;
          final amount = t['amount'] as double;
          final items = t['items'] as int;
          final status = t['status'] as String;
          final isCompleted = status == 'Completed';

          return SetupSectionCard(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (isCompleted ? AppColors.success : AppColors.warning).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle : Icons.schedule,
                    size: 20,
                    color: isCompleted ? AppColors.success : AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${date.day}/${date.month}/${date.year}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '$items items · $status',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₵${amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 80),
      ],
    );
  }
}

// ─── Communication Tab ───────────────────────────────────────────────────────

class _CommunicationTab extends StatelessWidget {
  final Connection conn;
  const _CommunicationTab({required this.conn});

  @override
  Widget build(BuildContext context) {
    final messages = [
      {'from': 'You', 'msg': 'Hi, the next delivery is scheduled for Friday.', 'time': '2h ago', 'sent': true},
      {'from': conn.name, 'msg': 'Perfect, we\'ll be ready for pickup by 9 AM.', 'time': '1h ago', 'sent': false},
      {'from': 'You', 'msg': 'Great! I\'ll confirm the driver details tomorrow.', 'time': '45m ago', 'sent': true},
      {'from': conn.name, 'msg': 'Sounds good. Also need to discuss the Q2 pricing.', 'time': '30m ago', 'sent': false},
      {'from': 'You', 'msg': 'Sure, let\'s schedule a call for next week.', 'time': '15m ago', 'sent': true},
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // Communication Stats
        Row(
          children: [
            Expanded(
              child: KPIBadge(
                label: 'Last Contact',
                value: conn.lastInteraction ?? 'N/A',
                icon: Icons.access_time,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: KPIBadge(
                label: 'Messages',
                value: '${conn.totalOrders * 3}',
                icon: Icons.chat_bubble,
                color: kSetupColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Message Thread
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SetupSectionTitle(title: 'Recent Messages', icon: Icons.forum),
              const SizedBox(height: 8),
              ...messages.map((m) {
                final isSent = m['sent'] as bool;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: (isSent ? kSetupColor : AppColors.textTertiary).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            (m['from'] as String)[0],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSent ? kSetupColor : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  m['from'] as String,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  m['time'] as String,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              m['msg'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

// ─── Notes Tab ───────────────────────────────────────────────────────────────

class _NotesTab extends StatelessWidget {
  final Connection conn;
  const _NotesTab({required this.conn});

  @override
  Widget build(BuildContext context) {
    final notes = [
      {'title': 'Pricing Discussion', 'date': 'Jan 15, 2025', 'content': 'Agreed on 5% discount for bulk orders above ₵5,000. Review in Q2.'},
      {'title': 'Delivery Preferences', 'date': 'Jan 8, 2025', 'content': 'Prefers morning deliveries (8-10 AM). Loading dock B at warehouse.'},
      {'title': 'Payment Terms', 'date': 'Dec 20, 2024', 'content': 'Net-30 approved. Auto-reminder set for day 25.'},
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // Add Note Prompt
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kSetupColor.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kSetupColor.withOpacity(0.12)),
          ),
          child: Row(
            children: [
              const Icon(Icons.add_circle_outline, color: kSetupColor, size: 20),
              const SizedBox(width: 10),
              const Text(
                'Add a new note...',
                style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        ...notes.map((n) => SetupSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n['title']!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        n['date']!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    n['content']!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 80),
      ],
    );
  }
}

// ─── Helper Widgets ──────────────────────────────────────────────────────────

class _StrengthIndicator extends StatelessWidget {
  final double value;
  const _StrengthIndicator({required this.value});

  @override
  Widget build(BuildContext context) {
    final color = value >= 70
        ? AppColors.success
        : value >= 40
            ? AppColors.warning
            : AppColors.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Relationship Strength',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const Spacer(),
            Text(
              '${value.toInt()}%',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
