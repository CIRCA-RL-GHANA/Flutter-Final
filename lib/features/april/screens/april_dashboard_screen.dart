import 'package:flutter/material.dart';
import '../../../core/design/ive_tokens.dart';
import '../../../core/design/ive_text.dart';

class AprilDashboardScreen extends StatefulWidget {
  const AprilDashboardScreen({super.key});

  @override
  State<AprilDashboardScreen> createState() => _AprilDashboardScreenState();
}

class _AprilDashboardScreenState extends State<AprilDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathe;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _breathe, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathe.dispose();
    super.dispose();
  }

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
              const SizedBox(height: IveTokens.s5),
              Text('APRIL · ACTION CORE', style: IveType.monoCaps),
              const SizedBox(height: IveTokens.s2),
              Text('Your second mind.', style: IveType.title1),
              const SizedBox(height: IveTokens.s8),
              Center(child: _OrbButton(scale: _scale)),
              const SizedBox(height: IveTokens.s6),
              _ActionGrid(),
              const SizedBox(height: IveTokens.s5),
              Text('RECENT', style: IveType.monoCaps),
              const SizedBox(height: IveTokens.s3),
              _RecentCommands(),
              const SizedBox(height: IveTokens.s8),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrbButton extends StatelessWidget {
  const _OrbButton({required this.scale});

  final Animation<double> scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: scale,
          builder: (context, child) => Transform.scale(
            scale: scale.value,
            child: child,
          ),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: IveTokens.genieSoft,
              shape: BoxShape.circle,
              border: Border.all(color: IveTokens.genieLine, width: 1.5),
            ),
            child: Center(
              child: Container(
                width: 12,
                height: 28,
                decoration: BoxDecoration(
                  color: IveTokens.genie,
                  borderRadius: BorderRadius.circular(IveTokens.rPill),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: IveTokens.s3),
        Text('Tap to speak', style: IveType.caption),
      ],
    );
  }
}

class _ActionCard {
  const _ActionCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

class _ActionGrid extends StatelessWidget {
  static const _cards = [
    _ActionCard(title: 'Plan my week', subtitle: '3 deadlines synced'),
    _ActionCard(title: 'Settle tabs', subtitle: '2 open · 340 QP'),
    _ActionCard(title: 'Draft a reply', subtitle: 'qualChat · Ama'),
    _ActionCard(title: 'Forecast cash', subtitle: 'next 30 days'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: IveTokens.s3,
      mainAxisSpacing: IveTokens.s3,
      childAspectRatio: 1.8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: _cards.map((c) => _ActionCardWidget(card: c)).toList(),
    );
  }
}

class _ActionCardWidget extends StatelessWidget {
  const _ActionCardWidget({required this.card});

  final _ActionCard card;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(IveTokens.s3),
      decoration: BoxDecoration(
        color: IveTokens.surface,
        borderRadius: BorderRadius.circular(IveTokens.rContainer),
        border: Border.all(color: IveTokens.hairline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.title,
            style: IveType.callout.copyWith(
              color: IveTokens.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(card.subtitle, style: IveType.caption),
        ],
      ),
    );
  }
}

class _RecentCommand {
  const _RecentCommand({
    required this.text,
    required this.time,
    required this.dotColor,
  });

  final String text;
  final String time;
  final Color dotColor;
}

class _RecentCommands extends StatelessWidget {
  static const _commands = [
    _RecentCommand(
      text: '"Move 200 QP to savings"',
      time: '2m',
      dotColor: IveTokens.success,
    ),
    _RecentCommand(
      text: '"Summarise the Osu thread"',
      time: '1h',
      dotColor: IveTokens.info,
    ),
    _RecentCommand(
      text: '"Reorder cocoa — needs approval"',
      time: '3h',
      dotColor: IveTokens.genie,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _commands
          .map((cmd) => Padding(
                padding: const EdgeInsets.only(bottom: IveTokens.s3),
                child: _RecentCommandRow(command: cmd),
              ))
          .toList(),
    );
  }
}

class _RecentCommandRow extends StatelessWidget {
  const _RecentCommandRow({required this.command});

  final _RecentCommand command;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: command.dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: IveTokens.s3),
        Expanded(
          child: Text(
            command.text,
            style: IveType.callout.copyWith(color: IveTokens.ink),
          ),
        ),
        const SizedBox(width: IveTokens.s2),
        Text(command.time, style: IveType.caption),
      ],
    );
  }
}
