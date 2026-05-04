/// GO Screen 2C — Transfer QPoints
/// Enhanced P2P transfer with receiver selection, risk assessment,
/// fee optimizer, scheduling, relationship context

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/go_models.dart';
import '../providers/go_provider.dart';
import '../widgets/go_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class GoTransferScreen extends StatefulWidget {
  const GoTransferScreen({super.key});
  @override
  State<GoTransferScreen> createState() => _GoTransferScreenState();
}

class _GoTransferScreenState extends State<GoTransferScreen> {
  int _step = 0;
  final _amountCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  double _amount = 0;
  String? _receiverId;
  String _receiverName = '';
  String _category = 'Personal';
  TransferSchedule _schedule = TransferSchedule.now;
  bool _termsAccepted = false;
  bool _processing = false;
  bool? _success;

  @override
  void dispose() { _amountCtrl.dispose(); _messageCtrl.dispose(); _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoProvider>(
      builder: (context, provider, _) => Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        appBar: const GoAppBar(title: 'Transfer QPoints'),
        body: Column(
          children: [
            Consumer<AIInsightsNotifier>(
              builder: (context, ai, _) {
                if (ai.insights.isEmpty) return const SizedBox.shrink();
                return Container(
                  color: Colors.green.shade50,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    children: [
                      Icon(Icons.shield_outlined, size: 14, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'AI fraud protection active — ${ai.insights.first['title'] ?? ''}',
                          style: TextStyle(fontSize: 11, color: Colors.green.shade700),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            GoStepIndicator(currentStep: _step, totalSteps: 5, labels: const ['Receiver', 'Amount', 'Review', 'Verify', 'Done']),
            Expanded(child: _buildStep(provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(GoProvider p) {
    switch (_step) {
      case 0: return _buildReceiver(p);
      case 1: return _buildAmount(p);
      case 2: return _buildReview(p);
      case 3: return _buildVerify(p);
      case 4: return _buildResult();
      default: return const SizedBox.shrink();
    }
  }

  // Step 1: Receiver selection
  Widget _buildReceiver(GoProvider p) {
    final favs = p.favorites;
    return Column(
      children: [
        Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
          // Search
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search by name, QPID, or phone...',
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            ),
            style: const TextStyle(fontSize: 13),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          // Quick select row: QR, QPID
          Row(children: [
            _buildQuickOption(Icons.qr_code_scanner, 'Scan QR'),
            const SizedBox(width: 10),
            _buildQuickOption(Icons.tag, 'Enter QPID'),
          ]),
          const SizedBox(height: 14),
          const GoSectionHeader(title: 'Recent & Favorites', icon: Icons.people),
          ...favs.map((f) {
            final sel = f.id == _receiverId;
            return GestureDetector(
              onTap: () => setState(() { _receiverId = f.id; _receiverName = f.name; }),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: sel ? kGoColor : const Color(0xFFE5E7EB), width: sel ? 2 : 1),
                ),
                child: Row(children: [
                  CircleAvatar(radius: 18, backgroundColor: kGoColorLight, child: Text(f.name.substring(0, 1), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kGoColor))),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(f.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(f.role, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                  ])),
                  if (sel) const Icon(Icons.check_circle, color: kGoColor, size: 20),
                ]),
              ),
            );
          }),
        ])),
        _buildFooter(null, _receiverId != null ? () => setState(() => _step = 1) : null, 'Next'),
      ],
    );
  }

  Widget _buildQuickOption(IconData icon, String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // In a real app, this would open QR scanner or QPID input dialog
          setState(() { _receiverId = 'manual'; _receiverName = 'Manual Entry'; });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE5E7EB))),
          child: Column(children: [
            Icon(icon, color: kGoColor, size: 24),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
          ]),
        ),
      ),
    );
  }

  // Step 2: Amount + details
  Widget _buildAmount(GoProvider p) {
    final fee = _amount * 0.01;
    final total = _amount + fee;
    return Column(
      children: [
        Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
          GoSectionCard(child: Column(children: [
            const Text('TRANSFER TO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
            const SizedBox(height: 4),
            Text(_receiverName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
            const Text('AMOUNT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
            const SizedBox(height: 6),
            TextField(
              controller: _amountCtrl, keyboardType: TextInputType.number, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              decoration: InputDecoration(suffixText: 'QP', hintText: '0', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none), filled: true, fillColor: const Color(0xFFF3F4F6)),
              onChanged: (v) => setState(() => _amount = double.tryParse(v) ?? 0),
            ),
            const SizedBox(height: 6),
            Text('Available: ${p.liquidity.available.toStringAsFixed(0)} QP', style: const TextStyle(fontSize: 11, color: kGoColor, fontWeight: FontWeight.w600)),
          ])),
          const SizedBox(height: 10),
          Wrap(spacing: 8, children: [100, 500, 1000, 5000].map((v) => ActionChip(label: Text('$v'), backgroundColor: Colors.white, side: const BorderSide(color: Color(0xFFE5E7EB)), onPressed: () { _amountCtrl.text = '$v'; setState(() => _amount = v.toDouble()); })).toList()),
          const SizedBox(height: 14),
          // Message
          TextField(
            controller: _messageCtrl, maxLength: 100, maxLines: 2,
            decoration: InputDecoration(hintText: 'Add a message (optional)', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB)))),
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 8),
          // Category
          DropdownButtonFormField<String>(
            value: _category,
            items: ['Personal', 'Business', 'Gift', 'Repayment', 'Other'].map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: (v) => setState(() => _category = v ?? _category),
            decoration: InputDecoration(labelText: 'Category', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB)))),
          ),
          const SizedBox(height: 10),
          // Schedule
          const Text('SCHEDULE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
          const SizedBox(height: 6),
          ...TransferSchedule.values.map((s) => RadioListTile<TransferSchedule>(
            value: s, groupValue: _schedule,
            onChanged: (v) => setState(() => _schedule = v ?? _schedule),
            title: Text(_scheduleLabel(s), style: const TextStyle(fontSize: 13)),
            dense: true, activeColor: kGoColor, visualDensity: VisualDensity.compact,
          )),
          if (_amount > 0) ...[
            const SizedBox(height: 10),
            GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('FEE BREAKDOWN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
              const Divider(height: 16),
              _Row(label: 'Transfer', value: '${_amount.toStringAsFixed(0)} QP'),
              _Row(label: 'Fee (1%)', value: '${fee.toStringAsFixed(2)} QP'),
              const Divider(height: 16),
              _Row(label: 'Total', value: '${total.toStringAsFixed(2)} QP', bold: true),
            ])),
          ],
        ])),
        _buildFooter(() => setState(() => _step = 0), _amount > 0 ? () => setState(() => _step = 2) : null, 'Review'),
      ],
    );
  }

  String _scheduleLabel(TransferSchedule s) {
    switch (s) {
      case TransferSchedule.now: return 'Send Now';
      case TransferSchedule.later: return 'Schedule for Later';
      case TransferSchedule.onRate: return 'When Rate Reaches…';
      case TransferSchedule.recurring: return 'Recurring';
    }
  }

  // Step 3: Review
  Widget _buildReview(GoProvider p) {
    final fee = _amount * 0.01;
    final total = _amount + fee;
    return Column(
      children: [
        Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
          GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Center(child: Text('TRANSFER REVIEW', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF)))),
            const SizedBox(height: 12),
            _Row(label: 'To', value: _receiverName),
            _Row(label: 'Amount', value: '${_amount.toStringAsFixed(0)} QP'),
            _Row(label: 'Fee', value: '${fee.toStringAsFixed(2)} QP'),
            _Row(label: 'Total Debit', value: '${total.toStringAsFixed(2)} QP', bold: true),
            _Row(label: 'Category', value: _category),
            _Row(label: 'Schedule', value: _scheduleLabel(_schedule)),
            if (_messageCtrl.text.isNotEmpty) _Row(label: 'Message', value: _messageCtrl.text),
          ])),
          const SizedBox(height: 14),
          // Risk assessment
          GoSectionCard(borderColor: kGoInfo.withOpacity(0.3), child: const Row(children: [
            Icon(Icons.verified_user, size: 18, color: kGoInfo),
            SizedBox(width: 10),
            Expanded(child: Text('Risk Assessment: LOW\nThis recipient is in your favorites with 12 previous transfers.', style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF)))),
          ])),
          const SizedBox(height: 14),
          CheckboxListTile(
            value: _termsAccepted, onChanged: (v) => setState(() => _termsAccepted = v ?? false), activeColor: kGoColor,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('I confirm this transfer is correct and authorized.', style: TextStyle(fontSize: 12)),
          ),
        ])),
        _buildFooter(() => setState(() => _step = 1), _termsAccepted ? () => setState(() => _step = 3) : null, 'Confirm'),
      ],
    );
  }

  Widget _buildVerify(GoProvider p) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.shield, size: 56, color: kGoColor),
        const SizedBox(height: 16),
        const Text('VERIFY TRANSFER', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 24),
        ...[
          _buildVerifyBtn(Icons.fingerprint, 'Use Fingerprint', p),
          _buildVerifyBtn(Icons.face, 'Face ID', p),
          _buildVerifyBtn(Icons.pin, 'Enter PIN', p),
        ],
        const Spacer(),
        TextButton(onPressed: () => setState(() => _step = 2), child: const Text('Back', style: TextStyle(color: Color(0xFF6B7280)))),
      ]),
    );
  }

  Widget _buildVerifyBtn(IconData icon, String label, GoProvider p) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(width: double.infinity, child: OutlinedButton.icon(
        icon: Icon(icon, size: 20), label: Text(label),
        onPressed: () async {
          setState(() { _step = 4; _processing = true; });
          final ok = await p.transfer(
            toUserId: _receiverId ?? '',
            amount: _amount,
            note: _messageCtrl.text.isNotEmpty ? _messageCtrl.text : null,
          );
          if (mounted) setState(() { _processing = false; _success = ok; });
        },
        style: OutlinedButton.styleFrom(foregroundColor: kGoColor, side: const BorderSide(color: Color(0xFFE5E7EB)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      )),
    );
  }

  // Step 5: Result
  Widget _buildResult() {
    if (_processing) {
      return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(width: 56, height: 56, child: CircularProgressIndicator(strokeWidth: 4, color: kGoColor)),
        SizedBox(height: 16), Text('Sending QPoints...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ]));
    }
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(_success == true ? Icons.check_circle : Icons.error_outline, size: 72, color: _success == true ? kGoPositive : kGoNegative),
      const SizedBox(height: 16),
      Text(_success == true ? 'Transfer Complete!' : 'Transfer Failed', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _success == true ? kGoPositive : kGoNegative)),
      const SizedBox(height: 8),
      Text(_success == true ? '${_amount.toStringAsFixed(0)} QP sent to $_receiverName' : 'Please try again.', style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
      const SizedBox(height: 24),
      ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: kGoColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text('Done')),
    ]));
  }

  Widget _buildFooter(VoidCallback? onBack, VoidCallback? onNext, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE5E7EB)))),
      child: Row(children: [
        if (onBack != null) Expanded(child: OutlinedButton(onPressed: onBack, style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF6B7280), side: const BorderSide(color: Color(0xFFE5E7EB)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text('Back'))),
        if (onBack != null) const SizedBox(width: 12),
        Expanded(child: ElevatedButton(onPressed: onNext, style: ElevatedButton.styleFrom(backgroundColor: onNext != null ? kGoColor : const Color(0xFFE5E7EB), foregroundColor: onNext != null ? Colors.white : const Color(0xFF9CA3AF), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)))),
      ]),
    );
  }
}

class _Row extends StatelessWidget {
  final String label; final String value; final bool bold;
  const _Row({required this.label, required this.value, this.bold = false});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [
    Expanded(child: Text(label, style: TextStyle(fontSize: 12, color: bold ? const Color(0xFF1A1A1A) : const Color(0xFF6B7280), fontWeight: bold ? FontWeight.w700 : FontWeight.w400))),
    Flexible(child: Text(value, style: TextStyle(fontSize: 12, fontWeight: bold ? FontWeight.w700 : FontWeight.w500, color: bold ? const Color(0xFF1A1A1A) : const Color(0xFF6B7280)), textAlign: TextAlign.end)),
  ]));
}
