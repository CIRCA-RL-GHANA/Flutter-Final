/// GO Screen 8 — Favorite Detail
/// Entity passport, relationship dashboard, financial relationship,
/// communication hub, transaction tools, relationship management

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../models/go_models.dart';
import '../providers/go_provider.dart';
import '../widgets/go_widgets.dart';

class GoFavoriteDetailScreen extends StatelessWidget {
  final String? favoriteId;
  const GoFavoriteDetailScreen({super.key, this.favoriteId});

  @override
  Widget build(BuildContext context) {
    final fId = favoriteId ?? (ModalRoute.of(context)?.settings.arguments as String? ?? '');
    return Consumer<GoProvider>(
      builder: (context, provider, _) {
        final fav = provider.favorites.firstWhere((f) => f.id == fId, orElse: () => provider.favorites.first);
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: const GoAppBar(title: 'Favorite Detail'),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
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
                              maxLines: 2, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // 1 — Entity passport
              _buildPassport(fav),
              const SizedBox(height: 14),
              // 2 — Relationship dashboard
              _buildRelationship(fav),
              const SizedBox(height: 14),
              // 3 — Quick actions
              _buildQuickActions(context),
              const SizedBox(height: 14),
              // 4 — Transaction history
              _buildTransactionHistory(fav),
              const SizedBox(height: 14),
              // 5 — Notes / Context
              _buildNotes(fav),
              const SizedBox(height: 14),
              // 6 — Admin tools
              _buildAdminTools(context, fav),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPassport(FavoriteEntity fav) {
    return GoSectionCard(
      child: Column(children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: kGoColorLight,
          child: Text(fav.name.substring(0, 1), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: kGoColor)),
        ),
        const SizedBox(height: 10),
        Text(fav.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        Text(fav.role, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _Badge(label: fav.category.name, color: kGoColor),
          const SizedBox(width: 6),
          if (fav.trustScore > 50) const _Badge(label: 'Trusted', color: kGoPositive),
        ]),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _StatCol(label: 'Transactions', value: '${fav.transactionCount}'),
          _StatCol(label: 'Total Volume', value: '${(fav.totalSpent / 1000).toStringAsFixed(1)}K QP'),
          _StatCol(label: 'Since', value: '${fav.favoriteSince.month}/${fav.favoriteSince.year}'),
        ]),
      ]),
    );
  }

  Widget _buildRelationship(FavoriteEntity fav) {
    return GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const GoSectionHeader(title: 'Relationship', icon: Icons.handshake),
      const SizedBox(height: 10),
      _InfoRow(label: 'Trust Score', value: fav.trustScore > 50 ? 'High (Verified)' : 'Medium', color: fav.trustScore > 50 ? kGoPositive : kGoWarning),
      _InfoRow(label: 'Last Transaction', value: fav.lastInteraction != null ? '${fav.lastInteraction!.day}/${fav.lastInteraction!.month}/${fav.lastInteraction!.year}' : 'N/A'),
      _InfoRow(label: 'Avg Transaction', value: fav.transactionCount > 0 ? '${(fav.totalSpent / fav.transactionCount).toStringAsFixed(0)} QP' : 'N/A'),
      _InfoRow(label: 'Category', value: fav.category.name),
      const SizedBox(height: 8),
      // Relationship strength bar
      Row(children: [
        const Text('Strength', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
        const SizedBox(width: 10),
        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
          value: fav.transactionCount > 20 ? 0.9 : fav.transactionCount / 20,
          minHeight: 6, backgroundColor: const Color(0xFFE5E7EB), valueColor: const AlwaysStoppedAnimation(kGoColor),
        ))),
        const SizedBox(width: 8),
        Text(fav.transactionCount > 20 ? 'Strong' : fav.transactionCount > 5 ? 'Growing' : 'New', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: kGoColor)),
      ]),
    ]));
  }

  Widget _buildQuickActions(BuildContext context) {
    return GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const GoSectionHeader(title: 'Quick Actions', icon: Icons.flash_on),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [
        _ActionBtn(icon: Icons.send, label: 'Send QP', onTap: () => Navigator.pushNamed(context, '/go/transfer')),
        _ActionBtn(icon: Icons.request_page, label: 'Request', onTap: () => Navigator.pushNamed(context, '/go/requests')),
        _ActionBtn(icon: Icons.receipt_long, label: 'New Tab', onTap: () => Navigator.pushNamed(context, '/go/tabs')),
        _ActionBtn(icon: Icons.message, label: 'Message', onTap: () {}),
        _ActionBtn(icon: Icons.schedule, label: 'Schedule', onTap: () {}),
        _ActionBtn(icon: Icons.share, label: 'Share', onTap: () {}),
      ]),
    ]));
  }

  Widget _buildTransactionHistory(FavoriteEntity fav) {
    return GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Expanded(child: GoSectionHeader(title: 'Recent Activity', icon: Icons.history)),
        TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(fontSize: 11, color: kGoColor))),
      ]),
      const SizedBox(height: 8),
      // Mock recent transactions
      ...List.generate(3, (i) => _TxnRow(
        type: i == 0 ? 'Sent' : i == 1 ? 'Received' : 'Tab',
        amount: '${(i + 1) * 250} QP',
        date: '${DateTime.now().subtract(Duration(days: i * 3)).day}/${DateTime.now().month}',
        isPositive: i == 1,
      )),
    ]));
  }

  Widget _buildNotes(FavoriteEntity fav) {
    return GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const GoSectionHeader(title: 'Notes & Tags', icon: Icons.note),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
        child: const Text('No notes yet. Tap to add a note.', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
      ),
      const SizedBox(height: 8),
      Wrap(spacing: 6, children: [
        Chip(label: const Text('Frequent', style: TextStyle(fontSize: 10)), backgroundColor: kGoColorLight, side: BorderSide.none, padding: EdgeInsets.zero, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
        Chip(label: const Text('Verified', style: TextStyle(fontSize: 10)), backgroundColor: kGoPositive.withOpacity(0.1), side: BorderSide.none, padding: EdgeInsets.zero, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
        ActionChip(label: const Text('+ Tag', style: TextStyle(fontSize: 10)), onPressed: () {}, backgroundColor: Colors.white, side: const BorderSide(color: Color(0xFFE5E7EB)), padding: EdgeInsets.zero, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
      ]),
    ]));
  }

  Widget _buildAdminTools(BuildContext context, FavoriteEntity fav) {
    return GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const GoSectionHeader(title: 'Management', icon: Icons.settings),
      const SizedBox(height: 8),
      ListTile(
        leading: const Icon(Icons.block, color: kGoNegative, size: 20),
        title: const Text('Block Party', style: TextStyle(fontSize: 13, color: kGoNegative)),
        dense: true, contentPadding: EdgeInsets.zero,
        onTap: () {},
      ),
      ListTile(
        leading: const Icon(Icons.delete_outline, color: Color(0xFF9CA3AF), size: 20),
        title: const Text('Remove from Favorites', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        dense: true, contentPadding: EdgeInsets.zero,
        onTap: () {},
      ),
      ListTile(
        leading: const Icon(Icons.flag_outlined, color: kGoWarning, size: 20),
        title: const Text('Report', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        dense: true, contentPadding: EdgeInsets.zero,
        onTap: () {},
      ),
    ]));
  }
}

class _Badge extends StatelessWidget {
  final String label; final Color color;
  const _Badge({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
    child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
  );
}

class _StatCol extends StatelessWidget {
  final String label; final String value;
  const _StatCol({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
    Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
  ]);
}

class _InfoRow extends StatelessWidget {
  final String label; final String value; final Color? color;
  const _InfoRow({required this.label, required this.value, this.color});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [
    Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)))),
    Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
  ]));
}

class _ActionBtn extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: kGoColorLight, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: kGoColor),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kGoColor)),
      ]),
    ),
  );
}

class _TxnRow extends StatelessWidget {
  final String type; final String amount; final String date; final bool isPositive;
  const _TxnRow({required this.type, required this.amount, required this.date, this.isPositive = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Icon(isPositive ? Icons.arrow_downward : Icons.arrow_upward, size: 14, color: isPositive ? kGoPositive : kGoNegative),
      const SizedBox(width: 8),
      Expanded(child: Text(type, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
      Text(amount, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isPositive ? kGoPositive : kGoNegative)),
      const SizedBox(width: 8),
      Text(date, style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
    ]),
  );
}
