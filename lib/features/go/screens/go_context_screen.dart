/// GO Screen 0 — Context Switcher (Pre-Entry)
/// Full-screen modal for selecting operational financial context
/// Trigger: Tapping GO widget on PROMPT screen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../models/go_models.dart';
import '../providers/go_provider.dart';
import '../widgets/go_widgets.dart';

class GoContextScreen extends StatelessWidget {
  const GoContextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GoProvider>(
      builder: (context, provider, _) {
        final contexts = provider.contexts;

        // Auto-redirect if single context
        if (contexts.length == 1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            provider.setActiveContext(contexts.first.id);
            Navigator.pushReplacementNamed(context, '/go');
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: kGoColor)));
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          body: SafeArea(
            child: Column(
              children: [
                // ── Header ──────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, size: 24, color: Color(0xFF1A1A1A)),
                      ),
                      const SizedBox(width: 12),
                      const Text('Select Financial Context', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Choose which financial environment to enter', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                ),

                const SizedBox(height: 20),

                // ── Global Summary ──────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GoSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('GLOBAL FINANCIAL SUMMARY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF), letterSpacing: 0.8)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Total Net Worth', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                                  const SizedBox(height: 2),
                                  Text('${provider.totalNetWorth.toStringAsFixed(0)} QP', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: kGoColorLight, borderRadius: BorderRadius.circular(8)),
                              child: Text('+${provider.change24h}% 24h', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kGoColorDark)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Distribution bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            height: 8,
                            child: Row(
                              children: contexts.map((c) {
                                final pct = provider.totalNetWorth > 0 ? c.qpBalance / provider.totalNetWorth : 0.0;
                                return Expanded(
                                  flex: (pct * 100).round().clamp(1, 100),
                                  child: Container(color: _contextColor(c.type)),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 12,
                          children: contexts.map((c) {
                            final pct = provider.totalNetWorth > 0 ? (c.qpBalance / provider.totalNetWorth * 100) : 0.0;
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(width: 8, height: 8, decoration: BoxDecoration(color: _contextColor(c.type), borderRadius: BorderRadius.circular(2))),
                                const SizedBox(width: 4),
                                Text('${c.typeLabel.split(' ').first} ${pct.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Consumer<AIInsightsNotifier>(
                  builder: (context, ai, _) {
                    if (ai.insights.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: kGoColor.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome, size: 14, color: kGoColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'AI: ${ai.insights.first['title'] ?? ''}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kGoColor),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // ── Context Grid ──────────────────────────
                Expanded(
                  child: contexts.isEmpty
                      ? GoEmptyState(
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'No Financial Context',
                          message: 'Set up your first financial context to start using GO.',
                          actionLabel: '+ Add Financial Context',
                          onAction: () {},
                        )
                      : GridView.count(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.78,
                          children: contexts.map((c) => _ContextCard(
                            ctx: c,
                            isSelected: c.id == provider.activeContextId,
                            onTap: () {
                              provider.setActiveContext(c.id);
                              Navigator.pushReplacementNamed(context, '/go');
                            },
                          )).toList(),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _contextColor(FinancialContextType type) {
    switch (type) {
      case FinancialContextType.personal: return kGoColor;
      case FinancialContextType.business: return kGoInfo;
      case FinancialContextType.branch: return kGoWarning;
      case FinancialContextType.entity: return kGoPurple;
    }
  }
}

// ──────────────────────────────────────────────
// Context Card
// ──────────────────────────────────────────────

class _ContextCard extends StatelessWidget {
  final FinancialContext ctx;
  final bool isSelected;
  final VoidCallback onTap;

  const _ContextCard({required this.ctx, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? kGoColorLight : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? kGoColor : const Color(0xFFE5E7EB), width: isSelected ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: _typeColor.withOpacity(0.15),
              child: Text(ctx.typeEmoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(height: 10),
            Text(ctx.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(ctx.role, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            const SizedBox(height: 8),
            Text('${ctx.qpBalance.toStringAsFixed(0)} QP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _typeColor)),
            const Spacer(),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: ctx.permission == ContextPermission.fullAccess ? kGoColorLight : kGoWarningLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(ctx.permissionLabel, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: ctx.permission == ContextPermission.fullAccess ? kGoColorDark : const Color(0xFF92400E))),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _QuickStat(icon: Icons.receipt_long, value: '${ctx.activeTabs}'),
                const SizedBox(width: 8),
                _QuickStat(icon: Icons.pending_actions, value: '${ctx.pendingTransactions}'),
                const SizedBox(width: 8),
                _QuickStat(icon: Icons.notifications_active, value: '${ctx.unreadAlerts}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color get _typeColor {
    switch (ctx.type) {
      case FinancialContextType.personal: return kGoColor;
      case FinancialContextType.business: return kGoInfo;
      case FinancialContextType.branch: return kGoWarning;
      case FinancialContextType.entity: return kGoPurple;
    }
  }
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String value;
  const _QuickStat({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 2),
        Text(value, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
      ],
    );
  }
}
