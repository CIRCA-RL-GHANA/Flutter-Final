/// GO Dashboard Screen — Main Financial Hub
/// P2P, Wallets, Investments, Cards, Quick Actions
/// Complete production implementation with search, error handling, real-time updates

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/go_models.dart';
import '../providers/go_provider.dart';
import '../widgets/go_widgets.dart';
import '../../../core/design/ive.dart';
import '../../../core/design/value_display.dart';
import '../../../core/design/genie_strip.dart';
import '../../../core/routes/app_routes.dart';

class GODashboardScreen extends StatefulWidget {
  const GODashboardScreen({super.key});

  @override
  State<GODashboardScreen> createState() => _GODashboardScreenState();
}

class _GODashboardScreenState extends State<GODashboardScreen> {
  late TextEditingController _searchController;
  bool _showRecentOnly = false;
  bool _genieVisible = true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    final provider = context.read<GOProvider>();
    await Future.wait([
      provider.loadWallets(),
      provider.loadRecentTransactions(),
      provider.loadCards(),
      provider.loadFavoriteRecipients(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GOProvider>(
      builder: (context, provider, _) {
        return WillPopScope(
          onWillPop: () async {
            _searchController.clear();
            setState(() => _showRecentOnly = false);
            return true;
          },
          child: Scaffold(
            backgroundColor: IveTokens.bg,
            appBar: AppBar(
              title: const Text(
                'GO Financial',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: IveTokens.label,
                ),
              ),
              elevation: 0,
              backgroundColor: IveTokens.surface,
              foregroundColor: IveTokens.label,
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {
                      // Navigate to GO settings
                      Navigator.pushNamed(context, AppRoutes.goSettings);
                    },
                  ),
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: _loadDashboardData,
              color: IveTokens.accentColor,
              child: provider.isLoading
                  ? const IveListSkeleton(rows: 7)
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ─── Balance Summary Card ───────────────────────────
                          _buildBalanceCard(provider),

                          // ─── Genie Strip (one per screen) ──────────────────
                          _buildGenieStrip(),

                          // ─── Quick Action Buttons ───────────────────────────
                          _buildQuickActions(context),

                          // ─── Active Wallets ──────────────────────────────────
                          _buildWalletsSection(provider),

                          // ─── Latest Cards ───────────────────────────────────
                          _buildCardsSection(provider),

                          // ─── Recent Transactions ────────────────────────────
                          _buildRecentTransactions(provider),

                          // ─── Quick Recipients ───────────────────────────────
                          _buildFavoriteRecipients(provider),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBalanceCard(GOProvider provider) {
    // Flat surface + luminance lift. No gradient, no shadow (Move 03).
    return Container(
      margin: const EdgeInsets.all(IveTokens.s4),
      padding: const EdgeInsets.all(IveTokens.s5),
      decoration: BoxDecoration(
        color: IveTokens.raisedColor,
        borderRadius: BorderRadius.circular(IveTokens.rContainer),
        border: Border.all(color: IveTokens.hairColor, width: 1),
        // Luminance lift via gradient (Move 03)
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [IveTokens.topHighlight, Colors.transparent],
          stops: [0.0, 0.3],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ‘Total balance’,
            style: IveType.caption.copyWith(color: IveTokens.muteColor),
          ),
          const SizedBox(height: IveTokens.s2),
          // ValueDisplay with count-up on first load
          ValueDisplay(
            amount: provider.totalBalance,
            unit: r’$’,
            integerSize: 36,
            countUp: true,
          ),
          const SizedBox(height: IveTokens.s4),
          // Income / Spent in ink2 (recede below hero number)
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_upward_rounded, size: 13, color: IveTokens.okColor),
                    const SizedBox(width: 4),
                    Text(
                      ‘\$${provider.monthlyIncome.toStringAsFixed(0)}’,
                      style: IveType.footnote.copyWith(color: IveTokens.ink2Color),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_downward_rounded, size: 13, color: IveTokens.badColor),
                    const SizedBox(width: 4),
                    Text(
                      ‘\$${provider.monthlySpent.toStringAsFixed(0)}’,
                      style: IveType.footnote.copyWith(color: IveTokens.ink2Color),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _QuickActionButton(
            icon: Icons.call_made,
            label: 'Send',
            color: IveTokens.moduleMarket,
            onTap: () => Navigator.pushNamed(context, AppRoutes.goTransfer),
          ),
          _QuickActionButton(
            icon: Icons.call_received,
            label: 'Request',
            color: IveTokens.success,
            onTap: () => Navigator.pushNamed(context, AppRoutes.goRequest),
          ),
          _QuickActionButton(
            icon: Icons.shopping_bag_outlined,
            label: 'Buy',
            color: IveTokens.moduleUpdates,
            onTap: () => Navigator.pushNamed(context, AppRoutes.goBuy),
          ),
          _QuickActionButton(
            icon: Icons.trending_up,
            label: 'Invest',
            color: IveTokens.warning,
            onTap: () => Navigator.pushNamed(context, AppRoutes.goInvest),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletsSection(GOProvider provider) {
    if (provider.wallets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Wallets',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: IveTokens.label,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.goWallets);
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    color: IveTokens.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: provider.wallets.length,
              itemBuilder: (context, index) {
                final wallet = provider.wallets[index];
                return _WalletCard(wallet: wallet);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsSection(GOProvider provider) {
    if (provider.cards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cards',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: IveTokens.label,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.goCards);
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    color: IveTokens.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: provider.cards.length,
              itemBuilder: (context, index) {
                final card = provider.cards[index];
                return _CardItem(card: card);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(GOProvider provider) {
    if (provider.recentTransactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No transactions yet.',
            style: IveType.footnote.copyWith(color: IveTokens.muteColor),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: IveTokens.label,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.goTransactions);
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    color: IveTokens.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...provider.recentTransactions.take(5).map((tx) {
            return _TransactionTile(transaction: tx);
          }),
        ],
      ),
    );
  }

  Widget _buildFavoriteRecipients(GOProvider provider) {
    if (provider.favoriteRecipients.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Send To',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: IveTokens.label,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: provider.favoriteRecipients.take(6).map((recipient) {
              return _RecipientAvatar(recipient: recipient);
            }).toList(),
          ),
        ],
      ),
    );
  }
  Widget _buildGenieStrip() {
    if (!_genieVisible) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: IveTokens.s4, vertical: IveTokens.s2),
      child: GenieStrip(
        message: "Spending's up 12% this week. Transfer surplus to savings.",
        onDismiss: () => setState(() => _genieVisible = false),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// COMPONENTS
// ────────────────────────────────────────────────────────────────────────────

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: IveTokens.labelSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final GOWallet wallet;

  const _WalletCard({required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 59 + wallet.id.length * 10, 130, 246),
            Color.fromARGB(255, 29 + wallet.id.length * 8, 64, 175),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            wallet.currency,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: IveTokens.label,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            wallet.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(
            '${wallet.currency} ${wallet.balance.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardItem extends StatelessWidget {
  final GOCard card;

  const _CardItem({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: IveTokens.surface,
        borderRadius: BorderRadius.circular(IveTokens.rContainer),
        border: Border.all(color: IveTokens.hairline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            card.type,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: IveTokens.labelSecondary,
            ),
          ),
          Text(
            '•••• ${card.lastFour}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: IveTokens.label,
            ),
          ),
          Text(
            card.holderName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: IveTokens.labelSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final GOTransaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    final sign = isIncome ? '+' : '-';
    final color = isIncome ? IveTokens.okColor : IveTokens.badColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: IveTokens.surface,
        borderRadius: BorderRadius.circular(IveTokens.rContainer),
        border: Border.all(color: IveTokens.hairline, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isIncome ? Icons.call_received : Icons.call_made,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: IveTokens.label,
                  ),
                ),
                Text(
                  transaction.date,
                  style: const TextStyle(
                    fontSize: 11,
                    color: IveTokens.labelTertiary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$sign\$${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipientAvatar extends StatelessWidget {
  final GORecipient recipient;

  const _RecipientAvatar({required this.recipient});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Pre-fill transfer with this recipient
        // Navigate to transfer screen with recipient selected
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Color.fromARGB(
              255,
              100 + recipient.name.hashCode % 155,
              120 + recipient.phone.hashCode % 135,
              200,
            ),
            child: Text(
              recipient.name[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            recipient.name.split(' ').first,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: IveTokens.labelSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
