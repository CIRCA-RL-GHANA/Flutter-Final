import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ive_tokens.dart';

/// Numeral rhythm widget for monetary and financial values.
///
/// Enforces the three-tier visual hierarchy:
///   • Integer part  — [integerSize] / full opacity / [IveTokens.inkColor]
///   • Decimal part  — 70 % of integer size / [IveTokens.ink2Color]
///   • Unit / symbol — same size as integer / [IveTokens.muteColor]
///
/// Uses IBM Plex Mono with tabular figures so digits never reflow.
///
/// Set [countUp] to `true` on first display for the GO dashboard hero
/// balance entrance (600 ms by default).
///
/// Example:
/// ```dart
/// ValueDisplay(
///   amount: 1234.56,
///   unit: 'QP',
///   unitLeading: false,
///   countUp: true,
/// )
/// ```
class ValueDisplay extends StatefulWidget {
  const ValueDisplay({
    super.key,
    required this.amount,
    this.unit = '',
    this.unitLeading = true,
    this.integerSize = 34,
    this.countUp = false,
    this.countUpDuration = const Duration(milliseconds: 600),
    this.textAlign = TextAlign.start,
  });

  /// Numeric value. Negative values prepend '−'.
  final double amount;

  /// Currency / unit symbol (e.g. '\$', '₵', 'QP'). Empty = no unit.
  final String unit;

  /// If true, unit precedes the number (e.g. '\$1,200'). Else follows ('1,200 QP').
  final bool unitLeading;

  /// Font size for the integer portion (decimal = 70 %, unit = same).
  final double integerSize;

  /// When true, count from 0 → [amount] on first render.
  final bool countUp;

  /// Duration of the count-up animation.
  final Duration countUpDuration;

  final TextAlign textAlign;

  @override
  State<ValueDisplay> createState() => _ValueDisplayState();
}

class _ValueDisplayState extends State<ValueDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.countUpDuration);
    _anim = Tween<double>(begin: 0, end: widget.amount)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    if (widget.countUp) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (MediaQuery.of(context).disableAnimations) {
          _ctrl.value = 1.0;
        } else {
          _ctrl.forward();
        }
      });
    } else {
      _ctrl.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ValueDisplay old) {
    super.didUpdateWidget(old);
    if (old.amount != widget.amount) {
      _anim = Tween<double>(begin: old.amount, end: widget.amount)
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _fmtInt(int v) {
    if (v == 0) return '0';
    final s = v.toString();
    final buf = StringBuffer();
    final offset = s.length % 3;
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (i - offset) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final intSize = widget.integerSize;
    final decSize = intSize * 0.70;
    final negative = widget.amount < 0;

    final monoBase = GoogleFonts.ibmPlexMono(
      height: 1.0,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final val = _anim.value;
        final absVal = val.abs();
        final intPart = absVal.truncate();
        final decPart = ((absVal - intPart) * 100).round();
        final intStr = '${negative ? '−' : ''}${_fmtInt(intPart)}';
        final decStr = '.${decPart.toString().padLeft(2, '0')}';

        final unitSpan = TextSpan(
          text: widget.unit,
          style: monoBase.copyWith(
            fontSize: intSize * 0.65,
            fontWeight: FontWeight.w500,
            color: IveTokens.muteColor,
          ),
        );

        final intSpan = TextSpan(
          text: intStr,
          style: monoBase.copyWith(
            fontSize: intSize,
            fontWeight: FontWeight.w700,
            color: IveTokens.inkColor,
          ),
        );

        final decSpan = TextSpan(
          text: decStr,
          style: monoBase.copyWith(
            fontSize: decSize,
            fontWeight: FontWeight.w500,
            color: IveTokens.ink2Color,
          ),
        );

        final spans = <TextSpan>[
          if (widget.unitLeading && widget.unit.isNotEmpty) unitSpan,
          intSpan,
          decSpan,
          if (!widget.unitLeading && widget.unit.isNotEmpty)
            TextSpan(
              text: ' ${widget.unit}',
              style: monoBase.copyWith(
                fontSize: intSize * 0.55,
                fontWeight: FontWeight.w500,
                color: IveTokens.muteColor,
              ),
            ),
        ];

        return RichText(
          textAlign: widget.textAlign,
          text: TextSpan(children: spans),
        );
      },
    );
  }
}
