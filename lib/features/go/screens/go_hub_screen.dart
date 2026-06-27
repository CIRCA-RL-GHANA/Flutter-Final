import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/design/ive_tokens.dart';
import '../../../core/design/ive_text.dart';
import '../../../core/design/genie_strip.dart';

class GoHubScreen extends StatefulWidget {
  const GoHubScreen({super.key});

  @override
  State<GoHubScreen> createState() => _GoHubScreenState();
}

class _GoHubScreenState extends State<GoHubScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IveTokens.bg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: IveTokens.s5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: IveTokens.s6),
              _BalanceSection(),
              const SizedBox(height: IveTokens.s5),
              _ActionRow(),
              const SizedBox(height: IveTokens.s4),
              GenieStrip(
                message:
                    "Spending's up 12% this week — mostly Market. Want to cap it?",
              ),
              const SizedBox(height: IveTokens.s5),
              Text(
                'RECENT',
                style: IveType.monoCaps,
              ),
              const SizedBox(height: IveTokens.s3),
              _TransactionList(),
              const SizedBox(height: IveTokens.s8),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TOTAL BALANCE',
          style: IveType.monoCaps,
        ),
        const SizedBox(height: IveTokens.s2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '14,250',
              style: GoogleFonts.ibmPlexMono(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: IveTokens.ink,
                letterSpacing: -0.5,
                height: 1.0,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 2),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                '.00',
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: IveTokens.ink2,
                  height: 1.0,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: IveTokens.s2),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'QP',
                style: IveType.monoCaps.copyWith(
                  color: IveTokens.mute,
                  fontSize: IveType.dCaption,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: IveTokens.s2),
        Row(
          children: [
            Text(
              '▲',
              style: TextStyle(
                fontSize: 11,
                color: IveTokens.success,
                height: 1.3,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '1.4% this week',
              style: IveType.caption.copyWith(color: IveTokens.success),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionButton(
          label: 'Send',
          icon: Icons.arrow_upward_rounded,
          filled: true,
        ),
        const SizedBox(width: IveTokens.s2),
        _ActionButton(
          label: 'Request',
          icon: Icons.arrow_downward_rounded,
          filled: false,
        ),
        const SizedBox(width: IveTokens.s2),
        _ActionButton(
          label: 'Buy',
          icon: Icons.add_rounded,
          filled: false,
        ),
        const SizedBox(width: IveTokens.s2),
        _ActionButton(
          label: 'Sell',
          icon: Icons.swap_horiz_rounded,
          filled: false,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.filled,
  });

  final String label;
  final IconData icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final bg = filled ? IveTokens.info : IveTokens.surface;
    final textColor = filled ? Colors.white : IveTokens.ink;
    final borderColor = filled ? Colors.transparent : IveTokens.hairline;

    return Expanded(
      child: SizedBox(
        height: 44,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(IveTokens.rContainer),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 16),
              const SizedBox(height: 2),
              Text(
                label,
                style: IveType.caption.copyWith(color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  static const _items = [
    _TxItem(
      icon: Icons.arrow_upward_rounded,
      iconBg: Color(0xFF1C3052),
      name: 'Ama Mensah',
      subtitle: '2m ago',
      amount: '-50',
      decimal: '.00',
      positive: false,
    ),
    _TxItem(
      icon: Icons.add_rounded,
      iconBg: IveTokens.genieSoft,
      name: 'QP purchase',
      subtitle: 'Gateway · today',
      amount: '+500',
      decimal: '.00',
      positive: true,
    ),
    _TxItem(
      icon: Icons.arrow_upward_rounded,
      iconBg: Color(0xFF1C3052),
      name: 'Market — groceries',
      subtitle: '1h ago',
      amount: '-128',
      decimal: '.40',
      positive: false,
    ),
    _TxItem(
      icon: Icons.arrow_downward_rounded,
      iconBg: Color(0xFF0D2C1E),
      name: 'Kofi Owusu',
      subtitle: 'Request paid',
      amount: '+75',
      decimal: '.00',
      positive: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _items
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: IveTokens.s3),
                child: _TransactionRow(item: item),
              ))
          .toList(),
    );
  }
}

class _TxItem {
  const _TxItem({
    required this.icon,
    required this.iconBg,
    required this.name,
    required this.subtitle,
    required this.amount,
    required this.decimal,
    required this.positive,
  });

  final IconData icon;
  final Color iconBg;
  final String name;
  final String subtitle;
  final String amount;
  final String decimal;
  final bool positive;
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.item});

  final _TxItem item;

  @override
  Widget build(BuildContext context) {
    final amountColor = item.positive ? IveTokens.success : IveTokens.ink;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: item.iconBg,
            borderRadius: BorderRadius.circular(IveTokens.rContainer),
          ),
          child: Icon(item.icon, color: IveTokens.ink2, size: 16),
        ),
        const SizedBox(width: IveTokens.s3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: IveType.callout.copyWith(
                  color: IveTokens.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(item.subtitle, style: IveType.caption),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              item.amount,
              style: GoogleFonts.ibmPlexMono(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: amountColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              item.decimal,
              style: GoogleFonts.ibmPlexMono(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: item.positive ? IveTokens.success : IveTokens.ink2,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
