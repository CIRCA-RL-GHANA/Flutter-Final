/// Fintech › Deposits — Term Deposit Screen
/// User picks a bank, amount, and term length to lock Q-Points.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/fintech_service.dart';
import '../../../../core/services/ai_insights_notifier.dart';

const _kIndigo = Color(0xFF3F51B5);

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});
  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final _fintechSvc = FintechService();
  final _amountCtrl = TextEditingController();
  final _fiIdCtrl = TextEditingController();
  int _termDays = 90;
  bool _loading = false;
  List<Map<String, dynamic>> _deposits = [];
  bool _loadingDeposits = false;

  @override
  void initState() {
    super.initState();
    _loadDeposits();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _fiIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDeposits() async {
    setState(() => _loadingDeposits = true);
    final res = await _fintechSvc.getDeposits();
    if (mounted) {
      setState(() {
        _deposits = res.data ?? [];
        _loadingDeposits = false;
      });
    }
  }

  Future<void> _create() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    final fiId = _fiIdCtrl.text.trim();
    if (amount == null || amount <= 0 || fiId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount and FI Entity ID')),
      );
      return;
    }
    setState(() => _loading = true);
    final res = await _fintechSvc.createDeposit(
      fiEntityId: fiId,
      amountQp: amount,
      termDays: _termDays,
    );
    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.data != null ? 'Deposit created! Matures in $_termDays days.' : (res.message ?? 'Failed'))),
      );
      if (res.data != null) _loadDeposits();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Term Deposits', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, foregroundColor: Colors.black87, elevation: 0,
      ),
      body: Column(
        children: [
          Consumer<AIInsightsNotifier>(
            builder: (context, ai, _) {
              if (ai.insights.isEmpty) return const SizedBox.shrink();
              return Container(
                color: _kIndigo.withOpacity(0.06),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(children: [
                  const Icon(Icons.auto_awesome, size: 14, color: _kIndigo),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    'Genie: ${ai.insights.first['label'] ?? 'Earn interest on locked QP'}',
                    style: const TextStyle(fontSize: 11, color: _kIndigo),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  )),
                ]),
              );
            },
          ),
          Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
            // Create deposit card
            _DepositCard(
              amount: _amountCtrl,
              fiId: _fiIdCtrl,
              termDays: _termDays,
              onTermChanged: (v) => setState(() => _termDays = v),
              loading: _loading,
              onCreate: _create,
            ),
            const SizedBox(height: 20),
            const Text('My Deposits', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),
            if (_loadingDeposits)
              const Center(child: CircularProgressIndicator())
            else if (_deposits.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No deposits yet', style: TextStyle(color: Colors.grey)),
              ))
            else
              ..._deposits.map((d) => _DepositTile(deposit: d)),
          ])),
        ],
      ),
    );
  }
}

class _DepositCard extends StatelessWidget {
  final TextEditingController amount, fiId;
  final int termDays;
  final ValueChanged<int> onTermChanged;
  final bool loading;
  final VoidCallback onCreate;

  const _DepositCard({
    required this.amount, required this.fiId, required this.termDays,
    required this.onTermChanged, required this.loading, required this.onCreate,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE5E7EB)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Lock Q-Points', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 12),
      const Text('Amount (QP)', style: TextStyle(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 4),
      TextField(
        controller: amount,
        keyboardType: TextInputType.number,
        decoration: _inputDec('e.g. 500'),
      ),
      const SizedBox(height: 10),
      const Text('FI Entity ID', style: TextStyle(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 4),
      TextField(controller: fiId, decoration: _inputDec('Bank entity UUID')),
      const SizedBox(height: 10),
      Text('Term: $termDays days', style: const TextStyle(fontSize: 12, color: Colors.grey)),
      Slider(
        value: termDays.toDouble(),
        min: 7, max: 365, divisions: 24,
        activeColor: _kIndigo,
        onChanged: (v) => onTermChanged(v.round()),
      ),
      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: loading ? null : onCreate,
          style: ElevatedButton.styleFrom(backgroundColor: _kIndigo, foregroundColor: Colors.white),
          child: loading
              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Lock Q-Points'),
        ),
      ),
    ]),
  );

  InputDecoration _inputDec(String hint) => InputDecoration(
    hintText: hint, filled: true, fillColor: Colors.grey.shade50,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
  );
}

class _DepositTile extends StatelessWidget {
  final Map<String, dynamic> deposit;
  const _DepositTile({required this.deposit});

  @override
  Widget build(BuildContext context) {
    final status = deposit['status'] as String? ?? 'active';
    final locked = deposit['lockedQp'] ?? 0;
    final interest = ((deposit['interestRate'] as num? ?? 0) * 100).toStringAsFixed(1);
    final maturity = deposit['maturityDate'] as String? ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: _kIndigo.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.lock, color: _kIndigo, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$locked QP locked', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text('$interest% p.a. · matures ${maturity.substring(0, maturity.length > 10 ? 10 : maturity.length)}',
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: (status == 'active' ? Colors.green : Colors.grey).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(status, style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600,
            color: status == 'active' ? Colors.green : Colors.grey,
          )),
        ),
      ]),
    );
  }
}
