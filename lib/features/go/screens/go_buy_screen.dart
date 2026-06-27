/// GO Screen 2A  Buy QPoints Flow (5-Step Process)
/// Step 1: Gateway Selection, Step 2: Amount, Step 3: Review,
/// Step 4: Security, Step 5: Processing/Confirmation
library;

import 'package:flutter/material.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/design/ive.dart';
import 'package:provider/provider.dart';
import '../models/go_models.dart';
import '../providers/go_provider.dart';
import '../widgets/go_widgets.dart';

class GoBuyScreen extends StatefulWidget {
  const GoBuyScreen({super.key});

  @override
  State<GoBuyScreen> createState() => _GoBuyScreenState();
}

class _GoBuyScreenState extends State<GoBuyScreen> {
  int _step = 0;
  String? _selectedGwId;
  double _amount = 0;
  String? _selectedFundingId;
  final _amountCtrl = TextEditingController();
  bool _termsAccepted = false;
  bool _processing = false;
  bool? _success;

  @override
  void dispose() { _amountCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: IveTokens.bg,
          appBar: const GoAppBar(title: 'Buy QPoints'),
          body: Column(
            children: [
              GoStepIndicator(currentStep: _step, totalSteps: 5, labels: const ['Gateway', 'Amount', 'Review', 'Verify', 'Done']),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildStep(provider),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStep(GoProvider provider) {
    switch (_step) {
      case 0: return _StepGateway(gateways: provider.gateways, selectedId: _selectedGwId, onSelect: (id) => setState(() => _selectedGwId = id), onNext: () { if (_selectedGwId != null) setState(() => _step = 1); });
      case 1: return _StepAmount(gateway: provider.gateways.firstWhere((g) => g.id == _selectedGwId), controller: _amountCtrl, amount: _amount, fundingSources: provider.fundingSources, selectedFundingId: _selectedFundingId, onAmountChanged: (v) => setState(() => _amount = v), onFundingSelected: (id) => setState(() => _selectedFundingId = id), onBack: () => setState(() => _step = 0), onNext: () { if (_amount > 0) setState(() => _step = 2); });
      case 2: return _StepReview(gateway: provider.gateways.firstWhere((g) => g.id == _selectedGwId), amount: _amount, termsAccepted: _termsAccepted, onTermsChanged: (v) => setState(() => _termsAccepted = v), onBack: () => setState(() => _step = 1), onNext: () { if (_termsAccepted) setState(() => _step = 3); });
      case 3: return _StepVerify(onBack: () => setState(() => _step = 2), onVerified: () async {
        setState(() { _step = 4; _processing = true; });
        final ok = await provider.buy(amount: _amount, source: _selectedGwId ?? 'card');
        if (mounted) setState(() { _processing = false; _success = ok; });
      });
      case 4: return _StepResult(processing: _processing, success: _success, amount: _amount, onDone: () => Navigator.pop(context), onRetry: () => setState(() { _step = 0; _processing = false; _success = null; }));
      default: return const SizedBox.shrink();
    }
  }
}

//  Step 1: Gateway Selection 
class _StepGateway extends StatelessWidget {
  final List<PaymentGateway> gateways;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;

  const _StepGateway({required this.gateways, this.selectedId, required this.onSelect, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: gateways.length,
            itemBuilder: (_, i) {
              final gw = gateways[i];
              final selected = gw.id == selectedId;
              return GestureDetector(
                onTap: gw.status == GatewayStatus.live || gw.status == GatewayStatus.pending ? () => onSelect(gw.id) : null,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: IveTokens.surface,
                    borderRadius: BorderRadius.circular(IveTokens.rSm),
                    border: Border.all(color: selected ? IveTokens.moduleGo : IveTokens.hairline2, width: selected ? 2 : 1),
                  ),
                  child: Row(
                    children: [
                      // ignore: deprecated_member_use
                      Radio<String>(value: gw.id, groupValue: selectedId, onChanged: gw.status == GatewayStatus.live || gw.status == GatewayStatus.pending ? (v) => onSelect(v!) : null, activeColor: IveTokens.moduleGo),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Text(gw.name, style: IveType.bodyEmphasis.copyWith(color: IveTokens.ink)),
                              const SizedBox(width: 8),
                              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: gw.statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(IveTokens.rXs)), child: Text(gw.statusLabel, style: TextStyle(fontSize: 10, color: gw.statusColor, fontWeight: FontWeight.w600))),
                            ]),
                            const SizedBox(height: 4),
                            Text('Rate: 1 QP = ${gw.buyRate} GHS  Fee: ${gw.feePercent}%${gw.flatFee > 0 ? ' + ${gw.flatFee.toStringAsFixed(0)} QP' : ''}', style: IveType.caption.copyWith(color: IveTokens.mute)),
                            Text('Limits: ${gw.minBuy.toStringAsFixed(0)}-${gw.maxBuy.toStringAsFixed(0)} QP  ${gw.processingTime}', style: IveType.caption.copyWith(color: IveTokens.ink2)),
                            if (gw.status == GatewayStatus.live) Text('Balance: ${gw.balance.toStringAsFixed(0)} ${gw.currency}', style: IveType.caption.copyWith(color: IveTokens.mute)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        _NavFooter(onBack: null, onNext: selectedId != null ? onNext : null, nextLabel: 'Proceed'),
      ],
    );
  }
}

//  Step 2: Amount 
class _StepAmount extends StatelessWidget {
  final PaymentGateway gateway;
  final TextEditingController controller;
  final double amount;
  final List<FundingSource> fundingSources;
  final String? selectedFundingId;
  final ValueChanged<double> onAmountChanged;
  final ValueChanged<String> onFundingSelected;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _StepAmount({required this.gateway, required this.controller, required this.amount, required this.fundingSources, this.selectedFundingId, required this.onAmountChanged, required this.onFundingSelected, required this.onBack, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final cost = amount * gateway.buyRate;
    final fee = cost * (gateway.feePercent / 100);
    final totalCost = cost + fee;
    final netQp = amount - gateway.flatFee;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GoSectionCard(
                child: Column(
                  children: [
                    Text('I WANT TO BUY', style: IveType.caption.copyWith(color: IveTokens.ink2)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: IveType.display.copyWith(color: IveTokens.ink),
                      decoration: InputDecoration(suffixText: 'QPoints', border: OutlineInputBorder(borderRadius: BorderRadius.circular(IveTokens.rSm), borderSide: BorderSide.none), filled: true, fillColor: IveTokens.hairline2),
                      onChanged: (v) => onAmountChanged(double.tryParse(v) ?? 0),
                    ),
                    const SizedBox(height: 8),
                    Text('WHICH WILL COST', style: IveType.caption.copyWith(color: IveTokens.ink2)),
                    const SizedBox(height: 4),
                    ValueDisplay(amount: cost, unit: 'GHS', unitLeading: false, integerSize: 20),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Quick select
              Wrap(
                spacing: 8,
                children: [100, 500, 1000, 5000, 10000].map((v) => ActionChip(
                  label: Text('$v', style: IveType.caption),
                  onPressed: () { controller.text = '$v'; onAmountChanged(v.toDouble()); },
                  backgroundColor: IveTokens.surface, side: const BorderSide(color: IveTokens.hairline),
                )).toList(),
              ),
              const SizedBox(height: 14),
              // Breakdown
              if (amount > 0) GoSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BREAKDOWN', style: IveType.caption.copyWith(color: IveTokens.ink2, letterSpacing: 0.5)),
                    const Divider(height: 16, color: IveTokens.hairline),
                    _BreakdownRow(label: 'QPoints to receive', value: amount.toStringAsFixed(0)),
                    _BreakdownRow(label: 'Gateway rate', value: '${gateway.buyRate} GHS/QP'),
                    _BreakdownRow(label: 'Subtotal', value: '${cost.toStringAsFixed(2)} GHS'),
                    _BreakdownRow(label: 'Gateway fee (${gateway.feePercent}%)', value: '${fee.toStringAsFixed(2)} GHS'),
                    if (gateway.flatFee > 0) _BreakdownRow(label: 'Service fee', value: '${gateway.flatFee.toStringAsFixed(0)} QP'),
                    const Divider(height: 16, color: IveTokens.hairline),
                    _BreakdownRow(label: 'TOTAL COST', value: '${totalCost.toStringAsFixed(2)} GHS', bold: true),
                    _BreakdownRow(label: 'NET QPOINTS', value: '${netQp.toStringAsFixed(0)} QP', bold: true, valueColor: IveTokens.moduleGo),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Funding source
              Text('FUND FROM', style: IveType.caption.copyWith(color: IveTokens.ink2, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              ...fundingSources.map((fs) => GestureDetector(
                onTap: () => onFundingSelected(fs.id),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: IveTokens.surface,
                    borderRadius: BorderRadius.circular(IveTokens.rSm),
                    border: Border.all(color: selectedFundingId == fs.id ? IveTokens.moduleGo : IveTokens.hairline2, width: selectedFundingId == fs.id ? 2 : 1),
                  ),
                  child: Row(
                    children: [
                      // ignore: deprecated_member_use
                      Radio<String>(value: fs.id, groupValue: selectedFundingId, onChanged: (v) => onFundingSelected(v!), activeColor: IveTokens.moduleGo),
                      Icon(fs.icon, size: 18, color: IveTokens.mute),
                      const SizedBox(width: 8),
                      Expanded(child: Text(fs.label, style: IveType.body.copyWith(color: IveTokens.ink))),
                      if (fs.balance != null) Text('${fs.balance!.toStringAsFixed(0)} GHS', style: IveType.caption.copyWith(color: IveTokens.mute)),
                      if (fs.lastFour != null) Text(' ${fs.lastFour}', style: IveType.caption.copyWith(color: IveTokens.ink2)),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ),
        _NavFooter(onBack: onBack, onNext: amount > 0 ? onNext : null, nextLabel: 'Review'),
      ],
    );
  }
}

//  Step 3: Review 
class _StepReview extends StatelessWidget {
  final PaymentGateway gateway;
  final double amount;
  final bool termsAccepted;
  final ValueChanged<bool> onTermsChanged;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _StepReview({required this.gateway, required this.amount, required this.termsAccepted, required this.onTermsChanged, required this.onBack, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final cost = amount * gateway.buyRate;
    final fee = cost * (gateway.feePercent / 100);
    final total = cost + fee;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GoSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Text('TRANSACTION REVIEW', style: IveType.caption.copyWith(color: IveTokens.ink2, letterSpacing: 0.8))),
                    const SizedBox(height: 12),
                    const _ReviewRow(label: 'Type', value: 'Buy QPoints'),
                    _ReviewRow(label: 'Amount', value: '${amount.toStringAsFixed(0)} QP'),
                    _ReviewRow(label: 'Cost', value: '${total.toStringAsFixed(2)} GHS'),
                    _ReviewRow(label: 'Gateway', value: gateway.name),
                    _ReviewRow(label: 'ETA', value: gateway.processingTime),
                    _ReviewRow(label: 'Reference', value: 'TX-BUY-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Party flow
              GoSectionCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const _ReviewParty(label: 'YOU', icon: Icons.person, color: IveTokens.moduleGo),
                    const Icon(Icons.arrow_forward, size: 16, color: IveTokens.ink2),
                    _ReviewParty(label: gateway.name.toUpperCase(), icon: Icons.payment, color: IveTokens.info),
                    const Icon(Icons.arrow_forward, size: 16, color: IveTokens.ink2),
                    const _ReviewParty(label: 'QP WALLET', icon: Icons.account_balance_wallet, color: IveTokens.accent),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Terms
              GoSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ignore: deprecated_member_use
                    CheckboxListTile(
                      value: termsAccepted,
                      onChanged: (v) => onTermsChanged(v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: IveTokens.moduleGo,
                      title: Text('I agree to the gateway fee and confirm this transaction is authorized', style: IveType.caption.copyWith(color: IveTokens.ink)),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 4),
                    Text('This transaction will be logged and audited. Contact support: finance@qualremit.com', style: IveType.caption.copyWith(color: IveTokens.ink2)),
                  ],
                ),
              ),
            ],
          ),
        ),
        _NavFooter(onBack: onBack, onNext: termsAccepted ? onNext : null, nextLabel: 'Confirm & Verify'),
      ],
    );
  }
}

//  Step 4: Verify 
class _StepVerify extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onVerified;

  const _StepVerify({required this.onBack, required this.onVerified});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shield, size: 56, color: IveTokens.moduleGo),
          const SizedBox(height: 16),
          Text('SECURE APPROVAL REQUIRED', style: IveType.title3.copyWith(color: IveTokens.ink)),
          const SizedBox(height: 24),
          _VerifyOption(icon: Icons.face, label: 'Use Face ID', onTap: onVerified),
          const SizedBox(height: 10),
          _VerifyOption(icon: Icons.fingerprint, label: 'Use Fingerprint', onTap: onVerified),
          const SizedBox(height: 10),
          _VerifyOption(icon: Icons.pin, label: 'Enter PIN', onTap: onVerified),
          const SizedBox(height: 10),
          _VerifyOption(icon: Icons.sms, label: 'Receive OTP via SMS', onTap: onVerified),
          const Spacer(),
          IveButton.text(label: 'Back', onPressed: onBack),
        ],
      ),
    );
  }
}

//  Step 5: Result 
class _StepResult extends StatelessWidget {
  final bool processing;
  final bool? success;
  final double amount;
  final VoidCallback onDone;
  final VoidCallback onRetry;

  const _StepResult({required this.processing, this.success, required this.amount, required this.onDone, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (processing) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 56, height: 56, child: CircularProgressIndicator(strokeWidth: 4, color: IveTokens.moduleGo)),
            const SizedBox(height: 16),
            Text('Processing...', style: IveType.title3.copyWith(color: IveTokens.ink)),
            const SizedBox(height: 8),
            Text('Validating  Converting  Crediting', style: IveType.caption.copyWith(color: IveTokens.ink2)),
          ],
        ),
      );
    }

    if (success == true) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 72, color: IveTokens.success),
            const SizedBox(height: 16),
            Text('SUCCESS!', style: IveType.title1.copyWith(color: IveTokens.success)),
            const SizedBox(height: 8),
            ValueDisplay(amount: amount, unit: 'QP', unitLeading: false, integerSize: 18),
            Text('ADDED TO WALLET', style: IveType.caption.copyWith(color: IveTokens.mute)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IveButton.text(label: 'View Receipt', onPressed: () => AppToast.show(context, 'Preparing download...')),
                const SizedBox(width: 12),
                IveButton.text(label: 'Share', onPressed: () => AppToast.show(context, 'Link copied to clipboard')),
              ],
            ),
            const SizedBox(height: 16),
            IveButton.primary(label: 'Done', onPressed: onDone, expand: false, compact: false),
          ],
        ),
      );
    }

    // Failure
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 72, color: IveTokens.danger),
          const SizedBox(height: 16),
          Text('Transaction Failed', style: IveType.title1.copyWith(color: IveTokens.danger)),
          const SizedBox(height: 8),
          Text('Try again or contact support.', style: IveType.body.copyWith(color: IveTokens.mute)),
          const SizedBox(height: 24),
          IveButton.primary(label: 'Retry', onPressed: onRetry, expand: false),
          IveButton.text(label: 'Contact Support', onPressed: () => Navigator.pushNamed(context, AppRoutes.utilityHelp)),
        ],
      ),
    );
  }
}

//  Helpers 

class _NavFooter extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String nextLabel;
  const _NavFooter({this.onBack, this.onNext, this.nextLabel = 'Next'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: IveTokens.surface, border: Border(top: BorderSide(color: IveTokens.hairline))),
      child: Row(
        children: [
          if (onBack != null) Expanded(child: IveButton.secondary(label: 'Back', onPressed: onBack)),
          if (onBack != null) const SizedBox(width: 12),
          Expanded(child: IveButton.primary(label: nextLabel, onPressed: onNext)),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;
  const _BreakdownRow({required this.label, required this.value, this.bold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: IveType.caption.copyWith(color: bold ? IveTokens.ink : IveTokens.mute, fontWeight: bold ? FontWeight.w700 : FontWeight.w400))),
          Text(value, style: IveType.caption.copyWith(fontWeight: bold ? FontWeight.w700 : FontWeight.w500, color: valueColor ?? (bold ? IveTokens.ink : IveTokens.mute))),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: IveType.body.copyWith(color: IveTokens.mute)),
          const Spacer(),
          Text(value, style: IveType.bodyEmphasis.copyWith(color: IveTokens.ink)),
        ],
      ),
    );
  }
}

class _ReviewParty extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _ReviewParty({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(radius: 18, backgroundColor: color.withValues(alpha: 0.12), child: Icon(icon, size: 18, color: color)),
        const SizedBox(height: 4),
        Text(label, style: IveType.caption.copyWith(color: IveTokens.ink, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _VerifyOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _VerifyOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(icon, size: 20),
        label: Text(label),
        onPressed: onTap,
        style: OutlinedButton.styleFrom(foregroundColor: IveTokens.moduleGo, side: const BorderSide(color: IveTokens.hairline), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(IveTokens.rSm))),
      ),
    );
  }
}
