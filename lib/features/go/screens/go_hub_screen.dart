library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/design/ive.dart';
import '../../../core/routes/app_routes.dart';

class GoHubScreen extends StatefulWidget {
  const GoHubScreen({super.key});

  @override
  State<GoHubScreen> createState() => _GoHubScreenState();
}

class _GoHubScreenState extends State<GoHubScreen> {
  bool _recentOnly = true;

  static const _transactions = [
    _Tx('Ama Boateng',      'Received · 1% fee',  true,  '₵ 250',   Color(0xFF34D399)),
    _Tx('Buy QPoints',      'MTN MoMo gateway',   true,  '₵ 500',   Color(0xFF34D399)),
    _Tx('Kofi Logistics',   'Sent · Services',    false, '₵ 80',    Color(0xFFEF4444)),
    _Tx('Tech Stocks Fund', 'Investment',         false, '₵ 1,000', Color(0xFFEF4444)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IveTokens.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 16, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FINANCIAL COMMAND',
                        style: IveType.caption.copyWith(
                          color: IveTokens.mute,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text('GO', style: IveType.title3),
                    ],
                  ),
                  const Spacer(),
                  _HeaderIcon(
                    icon: Icons.search_rounded,
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.utilitySearch),
                  ),
                  const SizedBox(width: 4),
                  _HeaderIcon(icon: Icons.settings_outlined, onTap: () {}),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: IveTokens.surface,
                        borderRadius: BorderRadius.circular(IveTokens.rContainer),
                        border: Border.all(color: IveTokens.hairline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'TOTAL BALANCE',
                                style: IveType.caption.copyWith(
                                  color: IveTokens.mute,
                                  letterSpacing: 0.7,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: IveTokens.success.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                      color: IveTokens.success.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  'HEALTH 86',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: IveTokens.success,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('₵ 12,840.50', style: IveType.title1.copyWith(fontSize: 32)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _BalanceStat(label: 'TODAY IN',  value: '+ ₵ 480',  color: IveTokens.success),
                              const SizedBox(width: 28),
                              _BalanceStat(label: 'TODAY OUT', value: '– ₵ 120',  color: const Color(0xFFEF4444)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Action row
                    Row(
                      children: [
                        _ActionBtn(icon: Icons.swap_horiz_rounded, label: 'TRANSFER',
                            onTap: () => Navigator.of(context).pushNamed(AppRoutes.goTransfer)),
                        const SizedBox(width: 10),
                        _ActionBtn(icon: Icons.add, label: 'BUY',
                            onTap: () => Navigator.of(context).pushNamed(AppRoutes.goBuy)),
                        const SizedBox(width: 10),
                        _ActionBtn(icon: Icons.remove, label: 'SELL',
                            onTap: () => Navigator.of(context).pushNamed(AppRoutes.goSell)),
                        const SizedBox(width: 10),
                        _ActionBtn(icon: Icons.grid_view_outlined, label: 'SCAN', onTap: () {}),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Recent activity header
                    Row(
                      children: [
                        Text(
                          'RECENT ACTIVITY',
                          style: IveType.caption.copyWith(
                            color: IveTokens.mute,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'RECENT ONLY',
                          style: IveType.caption.copyWith(
                            color: IveTokens.mute,
                            letterSpacing: 0.6,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch.adaptive(
                          value: _recentOnly,
                          onChanged: (v) => setState(() => _recentOnly = v),
                          activeColor: IveTokens.accent,
                          activeTrackColor: IveTokens.accent.withValues(alpha: 0.3),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    ..._transactions.map((tx) => _TxRow(tx: tx)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 20, color: IveTokens.mute),
        ),
      );
}

class _BalanceStat extends StatelessWidget {
  const _BalanceStat({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: IveType.caption.copyWith(
                  color: IveTokens.mute,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w600)),
          Text(value,
              style: IveType.callout.copyWith(color: color, fontWeight: FontWeight.w600)),
        ],
      );
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: IveTokens.surface,
              borderRadius: BorderRadius.circular(IveTokens.rSm),
              border: Border.all(color: IveTokens.hairline),
            ),
            child: Column(
              children: [
                Icon(icon, size: 20, color: IveTokens.accent),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: IveType.caption.copyWith(
                    fontSize: 9,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w700,
                    color: IveTokens.ink2,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _Tx {
  final String name;
  final String sub;
  final bool isIn;
  final String amount;
  final Color amountColor;
  const _Tx(this.name, this.sub, this.isIn, this.amount, this.amountColor);
}

class _TxRow extends StatelessWidget {
  const _TxRow({required this.tx});
  final _Tx tx;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: IveTokens.hairline, width: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tx.isIn
                    ? IveTokens.success.withValues(alpha: 0.15)
                    : const Color(0xFFEF4444).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(IveTokens.rSm),
              ),
              child: Icon(
                tx.isIn ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                size: 18,
                color: tx.isIn ? IveTokens.success : const Color(0xFFEF4444),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx.name, style: IveType.callout.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(tx.sub, style: IveType.caption.copyWith(color: IveTokens.mute)),
                ],
              ),
            ),
            Text(
              '${tx.isIn ? '+' : '–'} ${tx.amount}',
              style: IveType.callout.copyWith(color: tx.amountColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
}
