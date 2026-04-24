/// GO Screen 2B — Sell QPoints Flow
/// Mirror of Buy flow with sell-specific differences:
/// Destination selection, minimum 500 QP, processing time warning,
/// additional verification for large amounts

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/go_models.dart';
import '../providers/go_provider.dart';
import '../widgets/go_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class GoSellScreen extends StatefulWidget {
  const GoSellScreen({super.key});
  @override
  State<GoSellScreen> createState() => _GoSellScreenState();
}

class _GoSellScreenState extends State<GoSellScreen> {
  int _step = 0;
  String? _selectedGwId;
  double _amount = 0;
  final _amountCtrl = TextEditingController();
  bool _termsAccepted = false;
  bool _processing = false;
  bool? _success;
  String _purpose = 'Personal withdrawal';

  @override
  void dispose() { _amountCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: const GoAppBar(title: 'Sell QPoints'),
          body: Column(
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kGoColor.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kGoColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI: ${ai.insights.first['title'] ?? ''}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kGoColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              GoStepIndicator(currentStep: _step, totalSteps: 5, labels: const ['Destination', 'Amount', 'Review', 'Verify', 'Done']),
              Expanded(child: _buildStep(provider)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStep(GoProvider provider) {
    switch (_step) {
      case 0: return _buildDestination(provider);
      case 1: return _buildAmount(provider);
      case 2: return _buildReview(provider);
      case 3: return _buildVerify(provider);
      case 4: return _buildResult();
      default: return const SizedBox.shrink();
    }
  }

  // Step 1: Destination
  Widget _buildDestination(GoProvider provider) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const GoSectionHeader(title: 'Withdraw To', icon: Icons.account_balance),
              ...provider.gateways.where((g) => g.status != GatewayStatus.setupRequired).map((gw) {
                final sel = gw.id == _selectedGwId;
                return GestureDetector(
                  onTap: () => setState(() => _selectedGwId = gw.id),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: sel ? kGoColor : const Color(0xFFE5E7EB), width: sel ? 2 : 1)),
                    child: Row(
                      children: [
                        Radio<String>(value: gw.id, groupValue: _selectedGwId, onChanged: (v) => setState(() => _selectedGwId = v), activeColor: kGoColor),
                        const SizedBox(width: 8),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(gw.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          Text('Rate: 1 QP = ${gw.sellRate} GHS • Min: ${gw.minSell.toStringAsFixed(0)} QP', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                          Text('Processing: ${gw.processingTime}', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                        ])),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 10),
              GoSectionCard(
                borderColor: kGoWarning.withOpacity(0.3),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: kGoWarning),
                    SizedBox(width: 10),
                    Expanded(child: Text('Withdrawals take 1-3 business days.\nFor instant cash-out, use P2P transfer.', style: TextStyle(fontSize: 12, color: Color(0xFF92400E)))),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildFooter(null, _selectedGwId != null ? () => setState(() => _step = 1) : null, 'Proceed'),
      ],
    );
  }

  // Step 2: Amount
  Widget _buildAmount(GoProvider provider) {
    final gw = provider.gateways.firstWhere((g) => g.id == _selectedGwId);
    final revenue = _amount * gw.sellRate;
    final fee = revenue * (gw.feePercent / 100);
    final net = revenue - fee;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GoSectionCard(
                child: Column(
                  children: [
                    const Text('SELL AMOUNT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
                    const SizedBox(height: 8),
                    Text('Available: ${provider.liquidity.available.toStringAsFixed(0)} QP', style: const TextStyle(fontSize: 12, color: kGoColor, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(suffixText: 'QPoints', hintText: 'Min ${gw.minSell.toStringAsFixed(0)}', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none), filled: true, fillColor: const Color(0xFFF3F4F6)),
                      onChanged: (v) => setState(() => _amount = double.tryParse(v) ?? 0),
                    ),
                    if (_amount > 0 && _amount < gw.minSell)
                      Padding(padding: const EdgeInsets.only(top: 6), child: Text('Minimum sell: ${gw.minSell.toStringAsFixed(0)} QP', style: const TextStyle(fontSize: 11, color: kGoNegative))),
                    const SizedBox(height: 12),
                    const Text('YOU WILL RECEIVE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
                    const SizedBox(height: 4),
                    Text('${net.toStringAsFixed(2)} GHS', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Wrap(spacing: 8, children: [500, 1000, 5000, 10000].map((v) => ActionChip(label: Text('$v'), onPressed: () { _amountCtrl.text = '$v'; setState(() => _amount = v.toDouble()); }, backgroundColor: Colors.white, side: const BorderSide(color: Color(0xFFE5E7EB)))).toList()),
              const SizedBox(height: 14),
              if (_amount >= gw.minSell) GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('BREAKDOWN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
                const Divider(height: 16),
                _Row(label: 'QPoints to sell', value: '${_amount.toStringAsFixed(0)}'),
                _Row(label: 'Rate', value: '${gw.sellRate} GHS/QP'),
                _Row(label: 'Revenue', value: '${revenue.toStringAsFixed(2)} GHS'),
                _Row(label: 'Fee (${gw.feePercent}%)', value: '-${fee.toStringAsFixed(2)} GHS'),
                const Divider(height: 16),
                _Row(label: 'NET RECEIVE', value: '${net.toStringAsFixed(2)} GHS', bold: true, color: kGoPositive),
              ])),
              const SizedBox(height: 14),
              // Purpose
              const Text('PURPOSE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _purpose,
                items: ['Personal withdrawal', 'Business expense', 'Supplier payment', 'Tax payment', 'Other'].map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (v) => setState(() => _purpose = v ?? _purpose),
                decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB)))),
              ),
            ],
          ),
        ),
        _buildFooter(() => setState(() => _step = 0), _amount >= gw.minSell ? () => setState(() => _step = 2) : null, 'Review'),
      ],
    );
  }

  // Step 3: Review
  Widget _buildReview(GoProvider provider) {
    final gw = provider.gateways.firstWhere((g) => g.id == _selectedGwId);
    final revenue = _amount * gw.sellRate;
    final fee = revenue * (gw.feePercent / 100);
    final net = revenue - fee;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Center(child: Text('SELL REVIEW', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF)))),
                const SizedBox(height: 12),
                const _Row(label: 'Type', value: 'Sell QPoints'),
                _Row(label: 'Amount', value: '${_amount.toStringAsFixed(0)} QP'),
                _Row(label: 'You Receive', value: '${net.toStringAsFixed(2)} GHS'),
                _Row(label: 'Gateway', value: gw.name),
                _Row(label: 'Processing', value: gw.processingTime),
                _Row(label: 'Purpose', value: _purpose),
              ])),
              if (_amount > 10000) ...[
                const SizedBox(height: 10),
                GoSectionCard(
                  borderColor: kGoWarning.withOpacity(0.3),
                  child: const Row(children: [
                    Icon(Icons.warning_amber, size: 18, color: kGoWarning),
                    SizedBox(width: 10),
                    Expanded(child: Text('Large withdrawal requires manual review and may take up to 48 hours.', style: TextStyle(fontSize: 12, color: Color(0xFF92400E)))),
                  ]),
                ),
              ],
              const SizedBox(height: 14),
              CheckboxListTile(
                value: _termsAccepted,
                onChanged: (v) => setState(() => _termsAccepted = v ?? false),
                activeColor: kGoColor,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('I confirm this withdrawal and understand the processing timeline.', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
        _buildFooter(() => setState(() => _step = 1), _termsAccepted ? () => setState(() => _step = 3) : null, 'Confirm & Verify'),
      ],
    );
  }

  // Step 4: Verify
  Widget _buildVerify(GoProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shield, size: 56, color: kGoColor),
          const SizedBox(height: 16),
          const Text('VERIFY WITHDRAWAL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 24),
          ...[
            _buildVerifyBtn(Icons.fingerprint, 'Use Fingerprint', provider),
            _buildVerifyBtn(Icons.pin, 'Enter PIN', provider),
            _buildVerifyBtn(Icons.sms, 'OTP via SMS', provider),
          ],
          const Spacer(),
          TextButton(onPressed: () => setState(() => _step = 2), child: const Text('Back', style: TextStyle(color: Color(0xFF6B7280)))),
        ],
      ),
    );
  }

  Widget _buildVerifyBtn(IconData icon, String label, GoProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: Icon(icon, size: 20),
          label: Text(label),
          onPressed: () async {
            setState(() { _step = 4; _processing = true; });
            final ok = await provider.sell(
              amount: _amount,
              destination: _selectedGwId ?? 'gateway',
            );
            if (mounted) setState(() { _processing = false; _success = ok; });
          },
          style: OutlinedButton.styleFrom(foregroundColor: kGoColor, side: const BorderSide(color: Color(0xFFE5E7EB)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        ),
      ),
    );
  }

  // Step 5: Result
  Widget _buildResult() {
    if (_processing) {
      return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(width: 56, height: 56, child: CircularProgressIndicator(strokeWidth: 4, color: kGoColor)),
        SizedBox(height: 16), Text('Processing withdrawal...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ]));
    }
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(_success == true ? Icons.check_circle : Icons.error_outline, size: 72, color: _success == true ? kGoPositive : kGoNegative),
      const SizedBox(height: 16),
      Text(_success == true ? 'Withdrawal Initiated!' : 'Withdrawal Failed', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _success == true ? kGoPositive : kGoNegative)),
      const SizedBox(height: 8),
      Text(_success == true ? 'Your funds will arrive in 1-3 business days.' : 'Please try again.', style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
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
  final String label; final String value; final bool bold; final Color? color;
  const _Row({required this.label, required this.value, this.bold = false, this.color});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [
    Expanded(child: Text(label, style: TextStyle(fontSize: 12, color: bold ? const Color(0xFF1A1A1A) : const Color(0xFF6B7280), fontWeight: bold ? FontWeight.w700 : FontWeight.w400))),
    Text(value, style: TextStyle(fontSize: 12, fontWeight: bold ? FontWeight.w700 : FontWeight.w500, color: color ?? (bold ? const Color(0xFF1A1A1A) : const Color(0xFF6B7280)))),
  ]));
}
