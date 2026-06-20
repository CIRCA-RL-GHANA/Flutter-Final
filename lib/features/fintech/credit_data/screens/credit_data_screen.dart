/// Fintech › Credit Data — Credit Score Gauge & FI query screen
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_animations.dart';
import '../../../../core/design/ive.dart';
import '../../../../core/services/fintech_service.dart';

/// Credit score gauge that sweeps from 0 → score on first render (800ms).
/// Band label appears only after animation completes.
class CreditScoreGauge extends StatefulWidget {
  final int score;
  final double size;

  const CreditScoreGauge({super.key, required this.score, this.size = 180});

  @override
  State<CreditScoreGauge> createState() => _CreditScoreGaugeState();
}

class _CreditScoreGaugeState extends State<CreditScoreGauge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  bool _labelVisible = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: AppAnimations.dpCreditGauge,
    );
    final targetRatio = (widget.score / 1000).clamp(0.0, 1.0);
    _anim = Tween<double>(begin: 0.0, end: targetRatio).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );

    // Label resolves at animation end
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _labelVisible = true);
      }
    });

    if (MediaQuery.of(context).disableAnimations) {
      _ctrl.value = 1.0;
      _labelVisible = true;
    } else {
      _ctrl.forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _scoreColor(double ratio) {
    if (ratio >= 0.75) return IveTokens.okColor;
    if (ratio >= 0.50) return IveTokens.warnColor;
    return IveTokens.badColor;
  }

  String _scoreLabel(double ratio) {
    if (ratio >= 0.75) return 'Excellent';
    if (ratio >= 0.60) return 'Good';
    if (ratio >= 0.40) return 'Fair';
    return 'Poor';
  }

  @override
  Widget build(BuildContext context) {
    final finalRatio = (widget.score / 1000).clamp(0.0, 1.0);
    final color = _scoreColor(finalRatio);

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(alignment: Alignment.center, children: [
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _GaugePainter(ratio: _anim.value, color: color),
            ),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                '${(widget.score * _anim.value).round()}',
                style: GoogleFonts.ibmPlexMono(
                  fontSize: widget.size * 0.22,
                  fontWeight: FontWeight.w700,
                  color: IveTokens.inkColor,
                  fontFeatures: [const FontFeature.tabularFigures()],
                ),
              ),
              AnimatedOpacity(
                opacity: _labelVisible ? 1.0 : 0.0,
                duration: AppAnimations.dpSurface,
                child: Text(
                  _scoreLabel(finalRatio),
                  style: TextStyle(
                    fontSize: widget.size * 0.09,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ]),
          ]),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double ratio;
  final Color color;
  const _GaugePainter({required this.ratio, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.44;
    final strokeWidth = size.width * 0.09;

    // Track
    final bgPaint = Paint()
      ..color = IveTokens.hairColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        math.pi * 0.75, math.pi * 1.5, false, bgPaint);

    if (ratio <= 0) return;

    // Sweep arc
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        math.pi * 0.75, math.pi * 1.5 * ratio, false, fgPaint);
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.ratio != ratio || old.color != color;
}

// ─── Credit Data Screen ────────────────────────────────────────────────────────

class CreditDataScreen extends StatefulWidget {
  const CreditDataScreen({super.key});
  @override
  State<CreditDataScreen> createState() => _CreditDataScreenState();
}

class _CreditDataScreenState extends State<CreditDataScreen> {
  final _fintechSvc = FintechService();
  final _userIdCtrl = TextEditingController();
  final _consentIdCtrl = TextEditingController();
  Map<String, dynamic>? _result;
  bool _loading = false;
  // Key forces gauge to rebuild (and re-animate) each time a new result comes in
  Key _gaugeKey = UniqueKey();

  @override
  void dispose() {
    _userIdCtrl.dispose();
    _consentIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _query() async {
    final userId = _userIdCtrl.text.trim();
    final consentId = _consentIdCtrl.text.trim();
    if (userId.isEmpty || consentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter user ID and consent ID')),
      );
      return;
    }
    setState(() { _loading = true; _result = null; });
    final res = await _fintechSvc.requestCreditScore(
      subjectUserId: userId,
      consentId: consentId,
    );
    if (mounted) {
      setState(() {
        _result = res.data;
        _loading = false;
        _gaugeKey = UniqueKey();
      });
      if (res.data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message ?? 'Query failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final score = _result?['score'] as int? ?? 0;
    return Scaffold(
      backgroundColor: IveTokens.voidColor,
      appBar: AppBar(
        title: Text('Credit Data', style: IveType.headline),
        backgroundColor: IveTokens.voidColor,
        foregroundColor: IveTokens.inkColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(IveTokens.s4),
        children: [
          // Query form
          Container(
            padding: const EdgeInsets.all(IveTokens.s4),
            decoration: BoxDecoration(
              color: IveTokens.raisedColor,
              borderRadius: BorderRadius.circular(IveTokens.rContainer),
              border: Border.all(color: IveTokens.hairColor, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Query credit score', style: IveType.headline),
                const SizedBox(height: IveTokens.s4),
                Text('Subject user ID', style: IveType.caption.copyWith(color: IveTokens.muteColor)),
                const SizedBox(height: IveTokens.s2),
                _darkField(_userIdCtrl, 'User UUID'),
                const SizedBox(height: IveTokens.s3),
                Text('Consent ID', style: IveType.caption.copyWith(color: IveTokens.muteColor)),
                const SizedBox(height: IveTokens.s2),
                _darkField(_consentIdCtrl, 'Consent transaction UUID'),
                const SizedBox(height: IveTokens.s4),
                _loading
                    ? const IveSkeleton(width: double.infinity, height: 44, radius: BorderRadius.all(Radius.circular(IveTokens.rAtom)))
                    : IveButton.primary(label: 'Get credit score', onPressed: _query),
              ],
            ),
          ),

          // Result
          if (_result != null) ...[
            const SizedBox(height: IveTokens.s6),
            // Gauge centered
            Center(child: CreditScoreGauge(key: _gaugeKey, score: score)),
            const SizedBox(height: IveTokens.s5),
            // Metrics card
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: IveTokens.s4,
                vertical: IveTokens.s3,
              ),
              decoration: BoxDecoration(
                color: IveTokens.raisedColor,
                borderRadius: BorderRadius.circular(IveTokens.rContainer),
                border: Border.all(color: IveTokens.hairColor, width: 1),
              ),
              child: Column(
                children: [
                  _MetricRow('QP balance', '${_result!['dataJson']?['qpBalance'] ?? '—'} QP'),
                  _MetricRow('Total loans', '${_result!['dataJson']?['totalLoans'] ?? 0}'),
                  _MetricRow('Repaid loans', '${_result!['dataJson']?['repaidLoans'] ?? 0}'),
                  _MetricRow('Defaulted loans', '${_result!['dataJson']?['defaultedLoans'] ?? 0}'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _darkField(TextEditingController ctrl, String hint) => TextField(
    controller: ctrl,
    style: const TextStyle(color: IveTokens.inkColor, fontSize: 14),
    cursorColor: IveTokens.accentColor,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: IveTokens.muteColor, fontSize: 14),
      filled: true,
      fillColor: IveTokens.surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(IveTokens.rAtom),
        borderSide: const BorderSide(color: IveTokens.hairColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(IveTokens.rAtom),
        borderSide: const BorderSide(color: IveTokens.hairColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(IveTokens.rAtom),
        borderSide: const BorderSide(color: IveTokens.accentColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    ),
  );
}

class _MetricRow extends StatelessWidget {
  final String label, value;
  const _MetricRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: IveType.callout.copyWith(color: IveTokens.muteColor)),
        Text(
          value,
          style: GoogleFonts.ibmPlexMono(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: IveTokens.inkColor,
            fontFeatures: [const FontFeature.tabularFigures()],
          ),
        ),
      ],
    ),
  );
}
