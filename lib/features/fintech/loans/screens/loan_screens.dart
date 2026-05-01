/// Fintech › Loans — Loan Application Screen
/// Shows competing FI offers, lets user apply & tracks repayment progress.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/fintech_service.dart';
import '../../../../core/services/ai_insights_notifier.dart';

const _kGold = Color(0xFFD4A017);
const _kCyan = Color(0xFF00BCD4);

class LoanApplicationScreen extends StatefulWidget {
  const LoanApplicationScreen({super.key});
  @override
  State<LoanApplicationScreen> createState() => _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends State<LoanApplicationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _fintechSvc = FintechService();

  // Apply tab
  final _amountCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();
  int _termDays = 30;
  List<Map<String, dynamic>> _offers = [];
  bool _loadingOffers = false;
  String? _selectedFiId;

  // My loans tab
  List<Map<String, dynamic>> _myLoans = [];
  bool _loadingLoans = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadLoans();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _amountCtrl.dispose();
    _purposeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadLoans() async {
    setState(() => _loadingLoans = true);
    final res = await _fintechSvc.getLoanApplications();
    if (mounted) {
      setState(() {
        _myLoans = res.data ?? [];
        _loadingLoans = false;
      });
    }
  }

  Future<void> _fetchOffers() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    final purpose = _purposeCtrl.text.trim();
    if (amount == null || amount <= 0 || purpose.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount and purpose')),
      );
      return;
    }
    setState(() => _loadingOffers = true);
    final res = await _fintechSvc.getLoanOffers(amountQp: amount, purpose: purpose);
    if (mounted) {
      setState(() {
        _offers = res.data ?? [];
        _loadingOffers = false;
      });
    }
  }

  Future<void> _apply() async {
    if (_selectedFiId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select an FI offer first')),
      );
      return;
    }
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    final res = await _fintechSvc.applyForLoan(
      fiEntityId: _selectedFiId!,
      amountQp: amount,
      purpose: _purposeCtrl.text.trim(),
      termDays: _termDays,
    );
    if (mounted) {
      if (res.data != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loan application submitted successfully!')),
        );
        _tabs.animateTo(1);
        _loadLoans();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message ?? 'Application failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Loans', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: TabBar(
          controller: _tabs,
          labelColor: _kGold,
          unselectedLabelColor: Colors.grey,
          indicatorColor: _kGold,
          tabs: const [Tab(text: 'Apply'), Tab(text: 'My Loans')],
        ),
      ),
      body: Column(
        children: [
          // Genie AI strip
          Consumer<AIInsightsNotifier>(
            builder: (context, ai, _) {
              if (ai.insights.isEmpty) return const SizedBox.shrink();
              return Container(
                color: _kGold.withOpacity(0.07),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(children: [
                  Icon(Icons.auto_awesome, size: 14, color: _kGold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Genie: ${ai.insights.first['label'] ?? 'Loan tips available'}',
                      style: TextStyle(fontSize: 11, color: _kGold),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]),
              );
            },
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [_buildApplyTab(), _buildMyLoansTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyTab() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      // Input card
      _Card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Loan Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          _FieldLabel('Amount (QP)'),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration('e.g. 1000'),
          ),
          const SizedBox(height: 10),
          _FieldLabel('Purpose'),
          TextField(
            controller: _purposeCtrl,
            decoration: _inputDecoration('e.g. inventory, equipment'),
          ),
          const SizedBox(height: 10),
          _FieldLabel('Term: $_termDays days'),
          Slider(
            value: _termDays.toDouble(),
            min: 7, max: 365, divisions: 20,
            activeColor: _kGold,
            onChanged: (v) => setState(() => _termDays = v.round()),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loadingOffers ? null : _fetchOffers,
              style: ElevatedButton.styleFrom(backgroundColor: _kGold, foregroundColor: Colors.white),
              child: _loadingOffers
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Get Offers'),
            ),
          ),
        ]),
      ),
      if (_offers.isNotEmpty) ...[
        const SizedBox(height: 16),
        const Text('Available Offers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        ..._offers.map((o) => LoanOfferTile(
          offer: o,
          isSelected: _selectedFiId == o['fiEntityId'],
          onTap: () => setState(() => _selectedFiId = o['fiEntityId'] as String?),
        )),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedFiId != null ? _apply : null,
            style: ElevatedButton.styleFrom(backgroundColor: _kCyan, foregroundColor: Colors.white),
            child: const Text('Apply Now'),
          ),
        ),
      ],
    ]);
  }

  Widget _buildMyLoansTab() {
    if (_loadingLoans) return const Center(child: CircularProgressIndicator());
    if (_myLoans.isEmpty) {
      return const Center(child: Text('No loan applications yet', style: TextStyle(color: Colors.grey)));
    }
    return RefreshIndicator(
      onRefresh: _loadLoans,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _myLoans.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _LoanTile(loan: _myLoans[i]),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true, fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
  );
}

// ─── Loan Repayment Screen ────────────────────────────────────────────────────

class LoanRepaymentScreen extends StatefulWidget {
  final Map<String, dynamic> loan;
  const LoanRepaymentScreen({super.key, required this.loan});
  @override
  State<LoanRepaymentScreen> createState() => _LoanRepaymentScreenState();
}

class _LoanRepaymentScreenState extends State<LoanRepaymentScreen> {
  final _fintechSvc = FintechService();
  final _amountCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _repay() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) return;
    setState(() => _loading = true);
    final res = await _fintechSvc.repayLoan(
      applicationId: widget.loan['id'] as String,
      amountQp: amount,
    );
    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.data != null ? 'Repayment successful!' : (res.message ?? 'Failed'))),
      );
      if (res.data != null) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final outstanding = widget.loan['outstandingQp'] ?? 0;
    final autoSweep = ((widget.loan['autoSweepPct'] ?? 0.1) * 100).toStringAsFixed(0);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Repay Loan'),
        backgroundColor: Colors.white, foregroundColor: Colors.black87, elevation: 0,
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Outstanding Balance', style: TextStyle(color: Colors.grey, fontSize: 13)),
            Text('${outstanding} QP', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _kGold)),
          ]),
          const SizedBox(height: 8),
          Text('Auto-sweep: $autoSweep% of incoming revenue', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const Divider(height: 20),
          const Text('Manual Repayment', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Amount in QP',
              filled: true, fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _repay,
              style: ElevatedButton.styleFrom(backgroundColor: _kCyan, foregroundColor: Colors.white),
              child: _loading
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Repay Now'),
            ),
          ),
        ])),
      ]),
    );
  }
}

// ─── Shared sub-widgets ───────────────────────────────────────────────────────

class LoanOfferTile extends StatelessWidget {
  final Map<String, dynamic> offer;
  final bool isSelected;
  final VoidCallback onTap;
  const LoanOfferTile({super.key, required this.offer, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rate = ((offer['interestRate'] as num? ?? 0) * 100).toStringAsFixed(1);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? _kGold : const Color(0xFFE5E7EB), width: isSelected ? 2 : 1),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: _kGold.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.account_balance, color: _kGold, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Rate: $rate% p.a.', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text('Max: ${offer['maxAmount'] ?? '–'} QP', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ])),
          if (isSelected) const Icon(Icons.check_circle, color: _kGold),
        ]),
      ),
    );
  }
}

class _LoanTile extends StatelessWidget {
  final Map<String, dynamic> loan;
  const _LoanTile({required this.loan});

  @override
  Widget build(BuildContext context) {
    final status = loan['status'] as String? ?? 'pending';
    final outstanding = loan['outstandingQp'] ?? 0;
    final statusColor = _statusColor(status);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(loan['purpose'] as String? ?? 'Loan', style: const TextStyle(fontWeight: FontWeight.bold)),
          _StatusChip(label: status, color: statusColor),
        ]),
        const SizedBox(height: 6),
        Text('Outstanding: $outstanding QP', style: const TextStyle(color: _kGold, fontWeight: FontWeight.w600)),
        if (status == 'active')
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoanRepaymentScreen(loan: loan))),
            child: const Text('Repay Now →'),
          ),
      ]),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'active': return Colors.green;
      case 'pending': return Colors.orange;
      case 'repaid': return Colors.blue;
      case 'defaulted': return Colors.red;
      default: return Colors.grey;
    }
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE5E7EB)),
    ),
    child: child,
  );
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
  );
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
  );
}
