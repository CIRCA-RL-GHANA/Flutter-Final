/// GO Screen 1 — GO Page Hub (Unified Financial Command Center)
/// 10 sections: Context Bar, Financial Pulse, Quick Actions, Exchange Hub,
/// Party Info, Health Score, Recent Activity, Upcoming Events, Favorites, AI Insights

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/go_models.dart';
import '../providers/go_provider.dart';
import '../widgets/go_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class GoHubScreen extends StatefulWidget {
  const GoHubScreen({super.key});

  @override
  State<GoHubScreen> createState() => _GoHubScreenState();
}

class _GoHubScreenState extends State<GoHubScreen> {
  ActivityTab _activityTab = ActivityTab.all;
  bool _pulseExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<GoProvider>(
      builder: (context, provider, _) {
        final ctx = provider.activeContext;
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          body: SafeArea(
            child: Column(
              children: [
                // ── SECTION 1: Persistent Context Bar ──────────
                _ContextBar(provider: provider, ctx: ctx),

                // ── Scrollable Content ──────────
                Expanded(
                  child: RefreshIndicator(
                    color: kGoColor,
                    onRefresh: () => provider.init(),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        const SizedBox(height: 12),

                        // ── SECTION 2: Master Financial Pulse ──────────
                        _buildPulseSection(provider),
                        const SizedBox(height: 16),

                        // ── SECTION 3: Quick Actions ──────────
                        GoSectionHeader(title: 'Quick Actions', icon: Icons.flash_on),
                        _buildQuickActions(context),
                        const SizedBox(height: 16),

                        // ── SECTION 4: Live Exchange Hub ──────────
                        GoSectionHeader(title: 'Live Exchange Hub', icon: Icons.currency_exchange, actionLabel: 'Set Alert', onAction: () => _showRateAlertSheet(context)),
                        _buildExchangeHub(provider),
                        const SizedBox(height: 16),

                        // ── SECTION 5: Party Info ──────────
                        GoSectionHeader(title: 'Transaction Flow', icon: Icons.account_tree_outlined),
                        _buildPartyInfo(),
                        const SizedBox(height: 16),

                        // ── SECTION 6: Financial Health ──────────
                        GoSectionHeader(title: 'Financial Health', icon: Icons.favorite_border),
                        _buildHealthSection(provider),
                        const SizedBox(height: 16),

                        // ── SECTION 7: Recent Activity ──────────
                        GoSectionHeader(title: 'Recent Activity', icon: Icons.history, actionLabel: 'View All', onAction: () {}),
                        _buildActivitySection(provider),
                        const SizedBox(height: 16),

                        // ── SECTION 8: Upcoming Events ──────────
                        GoSectionHeader(title: 'Upcoming (Next 7 days)', icon: Icons.event),
                        _buildUpcomingSection(provider),
                        const SizedBox(height: 16),

                        // ── SECTION 9: Quick Access Favorites ──────────
                        GoSectionHeader(title: 'Favorite Receivers', icon: Icons.star, actionLabel: 'See All', onAction: () => Navigator.pushNamed(context, '/go/favorites')),
                        _buildFavorites(context, provider),
                        const SizedBox(height: 16),

                        // ── SECTION 10: AI Insights ──────────
                        GoSectionHeader(title: 'AI Insights 🔮', icon: Icons.auto_awesome),
                        _buildInsights(provider),
                        const SizedBox(height: 32),
                      ],
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

  // ── Section 2: Financial Pulse ──────────
  Widget _buildPulseSection(GoProvider provider) {
    final liq = provider.liquidity;
    return GoSectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () => setState(() => _pulseExpanded = !_pulseExpanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Text('TOTAL NET WORTH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF), letterSpacing: 0.8)),
                  const Spacer(),
                  Icon(_pulseExpanded ? Icons.expand_less : Icons.expand_more, size: 20, color: const Color(0xFF9CA3AF)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${provider.totalNetWorth.toStringAsFixed(0)} QP', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(color: kGoColorLight, borderRadius: BorderRadius.circular(6)),
                  child: Text('▲${provider.change24h}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kGoColorDark)),
                ),
              ],
            ),
          ),
          if (_pulseExpanded) ...[
            const SizedBox(height: 14),
            const Divider(height: 1),
            // Liquidity Breakdown
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('LIQUIDITY BREAKDOWN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF), letterSpacing: 0.8)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _LiquidityBox(label: 'Available', value: liq.available, pct: liq.availablePercent, color: kGoPositive),
                      const SizedBox(width: 8),
                      _LiquidityBox(label: 'Frozen', value: liq.frozen, pct: liq.frozenPercent, color: kGoInfo),
                      const SizedBox(width: 8),
                      _LiquidityBox(label: 'Reserved', value: liq.reserved, pct: liq.reservedPercent, color: kGoPurple),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('GATEWAY STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF), letterSpacing: 0.8)),
                  const SizedBox(height: 6),
                  ...provider.gateways.map((gw) => GatewayStatusRow(gateway: gw)),
                ],
              ),
            ),
          ] else
            const SizedBox(height: 14),
        ],
      ),
    );
  }

  // ── Section 3: Quick Actions ──────────
  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.95,
      children: [
        GoQuickAction(icon: Icons.arrow_downward, label: 'Buy QP', subtitle: 'From gateway', badge: 'Best: 0.085', onTap: () => Navigator.pushNamed(context, '/go/buy')),
        GoQuickAction(icon: Icons.arrow_upward, label: 'Sell QP', subtitle: 'To bank', badge: 'Fee: 1.5%', onTap: () => Navigator.pushNamed(context, '/go/sell')),
        GoQuickAction(icon: Icons.swap_horiz, label: 'Transfer', subtitle: 'P2P instant', badge: '0 fee til 5PM', onTap: () => Navigator.pushNamed(context, '/go/transfer')),
        GoQuickAction(icon: Icons.receipt_long, label: 'My Tabs', subtitle: 'Credit mgmt', badge: '3 overdue', onTap: () => Navigator.pushNamed(context, '/go/tabs')),
        GoQuickAction(icon: Icons.playlist_add_check, label: 'Batch Ops', subtitle: 'Bulk payments', badge: 'New', onTap: () => Navigator.pushNamed(context, '/go/batch')),
        GoQuickAction(icon: Icons.assessment, label: 'Planner', subtitle: 'Forecast & budget', badge: 'Q3 ready', onTap: () => Navigator.pushNamed(context, '/go/planner')),
      ],
    );
  }

  // ── Section 4: Exchange Hub ──────────
  Widget _buildExchangeHub(GoProvider provider) {
    final live = provider.liveGateways;
    return GoSectionCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _RateColumn(title: 'BUY RATES', gateways: live, isBuy: true)),
              Container(width: 1, height: 80, color: const Color(0xFFE5E7EB)),
              Expanded(child: _RateColumn(title: 'SELL RATES', gateways: live, isBuy: false)),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              const Icon(Icons.notifications_outlined, size: 16, color: kGoColor),
              const SizedBox(width: 6),
              Text('${provider.rateAlerts.length} rate alerts active', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              const Spacer(),
              const Text('Auto-refresh: 15s', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
            ],
          ),
        ],
      ),
    );
  }

  // ── Section 5: Party Info ──────────
  Widget _buildPartyInfo() {
    return GoSectionCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const _PartyNode(label: 'YOU', sublabel: 'John', color: kGoColor),
          Column(
            children: [
              const Icon(Icons.arrow_forward, size: 16, color: Color(0xFF9CA3AF)),
              Container(width: 40, height: 1, color: const Color(0xFFE5E7EB)),
              const Text('Fee: 0.85 QP', style: TextStyle(fontSize: 8, color: Color(0xFF9CA3AF))),
            ],
          ),
          const _PartyNode(label: 'G/W', sublabel: 'Payst', color: kGoInfo),
          Column(
            children: [
              const Icon(Icons.arrow_forward, size: 16, color: Color(0xFF9CA3AF)),
              Container(width: 40, height: 1, color: const Color(0xFFE5E7EB)),
              const Text('Instant', style: TextStyle(fontSize: 8, color: Color(0xFF9CA3AF))),
            ],
          ),
          const _PartyNode(label: 'SYS Q', sublabel: 'WALLET', color: kGoPurple),
        ],
      ),
    );
  }

  // ── Section 6: Health ──────────
  Widget _buildHealthSection(GoProvider provider) {
    return GoSectionCard(
      child: Row(
        children: [
          GoHealthGauge(score: provider.healthScore, size: 72),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Financial Health: ${provider.healthScore}/100', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                ...provider.healthMetrics.take(3).map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(m.metricLabel, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)))),
                      SizedBox(
                        width: 50,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(value: m.score / 100, minHeight: 4, backgroundColor: const Color(0xFFF3F4F6), valueColor: AlwaysStoppedAnimation(m.score >= 70 ? kGoPositive : m.score >= 50 ? kGoWarning : kGoNegative)),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text('${m.score.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                    ],
                  ),
                )),
                const SizedBox(height: 4),
                Text('💡 ${provider.healthRecommendation}', style: const TextStyle(fontSize: 10, color: kGoColorDark, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section 7: Activity ──────────
  Widget _buildActivitySection(GoProvider provider) {
    return Column(
      children: [
        // Tabs
        SizedBox(
          height: 32,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: ActivityTab.values.map((tab) {
              final isActive = tab == _activityTab;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _activityTab = tab),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isActive ? kGoColor : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isActive ? kGoColor : const Color(0xFFE5E7EB)),
                    ),
                    alignment: Alignment.center,
                    child: Text(tab.name[0].toUpperCase() + tab.name.substring(1), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isActive ? Colors.white : const Color(0xFF6B7280))),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        ...provider.transactionsByTab(_activityTab).take(3).map((tx) => GoTransactionRow(transaction: tx)),
      ],
    );
  }

  // ── Section 8: Upcoming ──────────
  Widget _buildUpcomingSection(GoProvider provider) {
    return GoSectionCard(
      child: Column(
        children: [
          ...provider.upcomingEvents.map((ev) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(ev.icon, size: 16, color: ev.color),
                const SizedBox(width: 10),
                Expanded(child: Text(ev.title, style: const TextStyle(fontSize: 13))),
                if (ev.amount != null) Text('${ev.amount!.toStringAsFixed(0)} QP', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
              ],
            ),
          )),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () {},
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 14, color: kGoColor),
                SizedBox(width: 4),
                Text('Add Schedule', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kGoColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section 9: Favorites ──────────
  Widget _buildFavorites(BuildContext context, GoProvider provider) {
    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...provider.favorites.take(4).map((fav) => _FavAvatar(entity: fav, onTap: () => Navigator.pushNamed(context, '/go/transfer'))),
          _AddFavAvatar(onTap: () => Navigator.pushNamed(context, '/go/favorites')),
        ],
      ),
    );
  }

  // ── Section 10: Insights ──────────
  Widget _buildInsights(GoProvider provider) {
    return Consumer<AIInsightsNotifier>(
      builder: (context, ai, _) {
        final liveInsights = ai.insights;
        return GoSectionCard(
          child: Column(
            children: [
              if (liveInsights.isNotEmpty) ...
                liveInsights.take(4).map((ins) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 16, color: kGoColor),
                      const SizedBox(width: 10),
                      Expanded(child: Text(ins['label'] as String? ?? '', style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                ))
              else ...
                provider.insights.map((ins) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(ins.icon, size: 16, color: kGoColor),
                      const SizedBox(width: 10),
                      Expanded(child: Text(ins.text, style: const TextStyle(fontSize: 13))),
                      if (ins.isActionable) GestureDetector(
                        onTap: () {},
                        child: Text(ins.actionLabel ?? 'View', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kGoColor)),
                      ),
                    ],
                  ),
                )),
            ],
          ),
        );
      },
    );
  }

  void _showRateAlertSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)))),
            const Text('Rate Alert', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Alert me when rate hits',
                suffixText: 'QP/GHS',
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rate alert set'), backgroundColor: kGoColor)); },
                style: ElevatedButton.styleFrom(backgroundColor: kGoColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text('Set Alert', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Context Bar (Section 1)
// ──────────────────────────────────────────────

class _ContextBar extends StatelessWidget {
  final GoProvider provider;
  final FinancialContext? ctx;
  const _ContextBar({required this.provider, required this.ctx});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(width: 8),
          if (ctx != null) GoContextChip(context: ctx!, onTap: () => Navigator.pushReplacementNamed(context, '/go/context')),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 4),
                Text(provider.financialPeriod, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(value: provider.syncProgress, strokeWidth: 2.5, backgroundColor: const Color(0xFFF3F4F6), valueColor: const AlwaysStoppedAnimation(kGoColor)),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20, color: Color(0xFF6B7280)),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'reports', child: Text('Reports')),
              const PopupMenuItem(value: 'security', child: Text('Security')),
              const PopupMenuItem(value: 'integrations', child: Text('Integrations')),
              const PopupMenuItem(value: 'archive', child: Text('Archive')),
              const PopupMenuItem(value: 'tax', child: Text('Tax & Compliance')),
            ],
            onSelected: (v) {
              switch (v) {
                case 'reports': Navigator.pushNamed(context, '/go/reports'); break;
                case 'security': Navigator.pushNamed(context, '/go/security'); break;
                case 'integrations': Navigator.pushNamed(context, '/go/integrations'); break;
                case 'archive': Navigator.pushNamed(context, '/go/archive'); break;
                case 'tax': Navigator.pushNamed(context, '/go/tax'); break;
              }
            },
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Liquidity Box
// ──────────────────────────────────────────────

class _LiquidityBox extends StatelessWidget {
  final String label;
  final double value;
  final double pct;
  final Color color;
  const _LiquidityBox({required this.label, required this.value, required this.pct, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('${value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const Text('QP', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
            const SizedBox(height: 4),
            Text('${pct.toStringAsFixed(1)}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Rate Column
// ──────────────────────────────────────────────

class _RateColumn extends StatelessWidget {
  final String title;
  final List<PaymentGateway> gateways;
  final bool isBuy;
  const _RateColumn({required this.title, required this.gateways, required this.isBuy});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF), letterSpacing: 0.5)),
          const SizedBox(height: 6),
          ...gateways.map((gw) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gw.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                Text('1 QP = ${(isBuy ? gw.buyRate : gw.sellRate).toStringAsFixed(3)} GHS', style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Party Node
// ──────────────────────────────────────────────

class _PartyNode extends StatelessWidget {
  final String label;
  final String sublabel;
  final Color color;
  const _PartyNode({required this.label, required this.sublabel, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
          Text(sublabel, style: const TextStyle(fontSize: 8, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Fav Avatar
// ──────────────────────────────────────────────

class _FavAvatar extends StatelessWidget {
  final FavoriteEntity entity;
  final VoidCallback? onTap;
  const _FavAvatar({required this.entity, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Column(
          children: [
            CircleAvatar(radius: 24, backgroundColor: kGoColorLight, child: Text(entity.name[0], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kGoColorDark))),
            const SizedBox(height: 4),
            Text(entity.name.split(' ').first, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
            Text(entity.role, style: const TextStyle(fontSize: 9, color: Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }
}

class _AddFavAvatar extends StatelessWidget {
  final VoidCallback? onTap;
  const _AddFavAvatar({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Column(
          children: [
            CircleAvatar(radius: 24, backgroundColor: const Color(0xFFF3F4F6), child: const Icon(Icons.add, size: 20, color: Color(0xFF9CA3AF))),
            const SizedBox(height: 4),
            const Text('+Add', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
            const Text('New', style: TextStyle(fontSize: 9, color: Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }
}
