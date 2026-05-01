/// Fintech › Credit Data — Credit Score Gauge & FI query screen

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/services/fintech_service.dart';

const _kPurple = Color(0xFF9C27B0);

/// A reusable credit score gauge widget.
/// [score] should be 0–1000.
class CreditScoreGauge extends StatelessWidget {
  final int score;
  final double size;

  const CreditScoreGauge({super.key, required this.score, this.size = 160});

  @override
  Widget build(BuildContext context) {
    final ratio = (score / 1000).clamp(0.0, 1.0);
    final color = _scoreColor(ratio);
    return SizedBox(
      width: size, height: size,
      child: Stack(alignment: Alignment.center, children: [
        CustomPaint(size: Size(size, size), painter: _GaugePainter(ratio: ratio, color: color)),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text('$score', style: TextStyle(fontSize: size * 0.22, fontWeight: FontWeight.bold, color: Colors.black87)),
          Text(_scoreLabel(ratio), style: TextStyle(fontSize: size * 0.09, color: color, fontWeight: FontWeight.w600)),
        ]),
      ]),
    );
  }

  Color _scoreColor(double ratio) {
    if (ratio >= 0.75) return Colors.green;
    if (ratio >= 0.50) return Colors.orange;
    return Colors.red;
  }

  String _scoreLabel(double ratio) {
    if (ratio >= 0.75) return 'Excellent';
    if (ratio >= 0.60) return 'Good';
    if (ratio >= 0.40) return 'Fair';
    return 'Poor';
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
    final strokeWidth = size.width * 0.1;

    // Background arc
    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        math.pi * 0.75, math.pi * 1.5, false, bgPaint);

    // Foreground arc
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        math.pi * 0.75, math.pi * 1.5 * ratio, false, fgPaint);
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.ratio != ratio || old.color != color;
}

// ─── Credit Data Screen (FI admin use) ───────────────────────────────────────

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter user ID and consent ID')));
      return;
    }
    setState(() { _loading = true; _result = null; });
    final res = await _fintechSvc.requestCreditScore(subjectUserId: userId, consentId: consentId);
    if (mounted) {
      setState(() { _result = res.data; _loading = false; });
      if (res.data == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message ?? 'Query failed')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final score = _result?['score'] as int? ?? 0;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Credit Data', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, foregroundColor: Colors.black87, elevation: 0,
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Query Credit Score', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            const Text('Subject User ID', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            TextField(controller: _userIdCtrl, decoration: _dec('User UUID')),
            const SizedBox(height: 10),
            const Text('Consent ID', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            TextField(controller: _consentIdCtrl, decoration: _dec('Consent transaction UUID')),
            const SizedBox(height: 14),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: _loading ? null : _query,
              style: ElevatedButton.styleFrom(backgroundColor: _kPurple, foregroundColor: Colors.white),
              child: _loading
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Get Credit Score'),
            )),
          ]),
        ),
        if (_result != null) ...[
          const SizedBox(height: 24),
          Center(child: CreditScoreGauge(score: score)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
            child: Column(children: [
              _MetricRow('QP Balance', '${_result!['dataJson']?['qpBalance'] ?? '—'} QP'),
              _MetricRow('Total Loans', '${_result!['dataJson']?['totalLoans'] ?? 0}'),
              _MetricRow('Repaid Loans', '${_result!['dataJson']?['repaidLoans'] ?? 0}'),
              _MetricRow('Defaulted Loans', '${_result!['dataJson']?['defaultedLoans'] ?? 0}'),
            ]),
          ),
        ],
      ]),
    );
  }

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint, filled: true, fillColor: Colors.grey.shade50,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
  );
}

class _MetricRow extends StatelessWidget {
  final String label, value;
  const _MetricRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
    ]),
  );
}
