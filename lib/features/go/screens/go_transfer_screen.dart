/// GO Screen 2C — Transfer QPoints
/// Enhanced P2P transfer with receiver selection, risk assessment,
/// fee optimizer, scheduling, relationship context
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_animations.dart';
import '../models/go_models.dart';
import '../providers/go_provider.dart';
import '../widgets/go_widgets.dart';
import '../../../core/design/ive.dart';

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
  String? _amountError;
  String? _receiverId;
  String _receiverName = '';
  String _category = 'Personal';
  TransferSchedule _schedule = TransferSchedule.now;
  bool _termsAccepted = false;
  bool _processing = false;
  bool? _success;

  bool get _isAmountValid => _amount > 0 && _amount <= 1000000 && _amountError == null;

  double get _fee => _amount * 0.01;
  double get _total => _amount + _fee;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _messageCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoProvider>(
      builder: (context, provider, _) => Scaffold(
        backgroundColor: IveTokens.voidColor,
        appBar: const GoAppBar(title: 'Transfer QPoints'),
        body: Column(
          children: [
            // 4-step flow: Receiver → Amount → Review → Done
            GoStepIndicator(
              currentStep: _step,
              totalSteps: 4,
              labels: const ['Receiver', 'Amount', 'Review', 'Done'],
            ),
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
      case 3: return _buildResult();
      default: return const SizedBox.shrink();
    }
  }

  // Step 1: Receiver selection
  Widget _buildReceiver(GoProvider p) {
    final favs = p.favorites;
    return Column(
      children: [
        Expanded(child: ListView(padding: const EdgeInsets.all(IveTokens.s4), children: [
          // Search
          TextField(
            controller: _searchCtrl,
            style: const TextStyle(fontSize: 13, color: IveTokens.inkColor),
            cursorColor: IveTokens.accentColor,
            decoration: InputDecoration(
              hintText: 'Search by name, QPID, or phone...',
              hintStyle: const TextStyle(color: IveTokens.muteColor, fontSize: 13),
              prefixIcon: const Icon(Icons.search, size: 20, color: IveTokens.muteColor),
              filled: true,
              fillColor: IveTokens.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(IveTokens.rAtom),
                borderSide: const BorderSide(color: IveTokens.hairColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(IveTokens.rAtom),
                borderSide: const BorderSide(color: IveTokens.hairColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(IveTokens.rAtom),
                borderSide: const BorderSide(color: IveTokens.accentColor, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: IveTokens.s4),
          // Quick select row
          Row(children: [
            _buildQuickOption(Icons.qr_code_scanner, 'Scan QR'),
            const SizedBox(width: IveTokens.s3),
            _buildQuickOption(Icons.tag, 'Enter QPID'),
          ]),
          const SizedBox(height: IveTokens.s4),
          const GoSectionHeader(title: 'Recent & Favorites', icon: Icons.people),
          ...favs.map((f) {
            final sel = f.id == _receiverId;
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() { _receiverId = f.id; _receiverName = f.name; });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: IveTokens.s2),
                padding: const EdgeInsets.all(IveTokens.s3),
                decoration: BoxDecoration(
                  color: IveTokens.raisedColor,
                  borderRadius: BorderRadius.circular(IveTokens.rContainer),
                  border: Border.all(
                    color: sel ? IveTokens.accentColor : IveTokens.hairColor,
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Row(children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: IveTokens.accentSoftBlue,
                    child: Text(
                      f.name.substring(0, 1),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: IveTokens.accentColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: IveTokens.s3),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(f.name, style: IveType.callout),
                    Text(f.role, style: IveType.caption.copyWith(color: IveTokens.muteColor)),
                  ])),
                  if (sel) const Icon(Icons.check_circle, color: IveTokens.accentColor, size: 20),
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
        onTap: () => setState(() { _receiverId = 'manual'; _receiverName = 'Manual Entry'; }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: IveTokens.s4),
          decoration: BoxDecoration(
            color: IveTokens.raisedColor,
            borderRadius: BorderRadius.circular(IveTokens.rContainer),
            border: Border.all(color: IveTokens.hairColor),
          ),
          child: Column(children: [
            Icon(icon, color: IveTokens.accentColor, size: 24),
            const SizedBox(height: IveTokens.s1),
            Text(label, style: IveType.caption.copyWith(color: IveTokens.muteColor)),
          ]),
        ),
      ),
    );
  }

  // Step 2: Amount + details
  Widget _buildAmount(GoProvider p) {
    return Column(
      children: [
        Expanded(child: ListView(padding: const EdgeInsets.all(IveTokens.s4), children: [
          // Receiver + amount card
          Container(
            padding: const EdgeInsets.all(IveTokens.s4),
            decoration: BoxDecoration(
              color: IveTokens.raisedColor,
              borderRadius: BorderRadius.circular(IveTokens.rContainer),
              border: Border.all(color: IveTokens.hairColor),
            ),
            child: Column(children: [
              Text('TRANSFER TO', style: IveType.caption.copyWith(color: IveTokens.muteColor)),
              const SizedBox(height: IveTokens.s1),
              Text(_receiverName, style: IveType.headline),
              const SizedBox(height: IveTokens.s4),
              Text('AMOUNT', style: IveType.caption.copyWith(color: IveTokens.muteColor)),
              const SizedBox(height: IveTokens.s2),
              TextField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: IveTokens.inkColor,
                  fontFeatures: [const FontFeature.tabularFigures()],
                ),
                cursorColor: IveTokens.accentColor,
                decoration: InputDecoration(
                  suffixText: 'QP',
                  suffixStyle: const TextStyle(color: IveTokens.muteColor, fontSize: 16),
                  hintText: '0',
                  hintStyle: const TextStyle(color: IveTokens.faintColor, fontSize: 28),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(IveTokens.rAtom),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: IveTokens.surfaceColor,
                  errorText: _amountError,
                ),
                onChanged: (v) {
                  final parsed = double.tryParse(v);
                  setState(() {
                    if (v.isEmpty || parsed == null) {
                      _amount = 0; _amountError = null;
                    } else if (parsed <= 0) {
                      _amount = 0; _amountError = 'Amount must be greater than zero';
                    } else if (parsed > 1000000) {
                      _amount = parsed; _amountError = 'Amount exceeds maximum limit';
                    } else if (v.contains('.') && v.split('.').last.length > 2) {
                      _amount = parsed; _amountError = 'Maximum 2 decimal places allowed';
                    } else {
                      _amount = parsed; _amountError = null;
                    }
                  });
                },
              ),
              const SizedBox(height: IveTokens.s2),
              // Real-time fee calculation inline with the amount (spec P1)
              if (_amount > 0)
                AnimatedContainer(
                  duration: AppAnimations.dpStateChange,
                  padding: const EdgeInsets.symmetric(horizontal: IveTokens.s3, vertical: IveTokens.s2),
                  decoration: BoxDecoration(
                    color: IveTokens.surfaceColor,
                    borderRadius: BorderRadius.circular(IveTokens.rAtom),
                    border: Border.all(color: IveTokens.hairColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Fee (1%)', style: IveType.caption.copyWith(color: IveTokens.muteColor)),
                      Text(
                        '${_fee.toStringAsFixed(2)} QP',
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 12,
                          color: IveTokens.muteColor,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: IveTokens.s3),
                      Text('You send', style: IveType.caption.copyWith(color: IveTokens.ink2Color)),
                      Text(
                        '${_total.toStringAsFixed(2)} QP',
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: IveTokens.inkColor,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  'Available: ${p.liquidity.available.toStringAsFixed(0)} QP',
                  style: IveType.caption.copyWith(color: IveTokens.accentColor),
                ),
            ]),
          ),
          const SizedBox(height: IveTokens.s3),
          // Quick-amount chips
          Wrap(
            spacing: IveTokens.s2,
            children: [100, 500, 1000, 5000].map((v) => ActionChip(
              label: Text('$v', style: const TextStyle(color: IveTokens.ink2Color, fontSize: 12)),
              backgroundColor: IveTokens.raisedColor,
              side: const BorderSide(color: IveTokens.hairColor),
              onPressed: () {
                _amountCtrl.text = '$v';
                setState(() { _amount = v.toDouble(); _amountError = null; });
              },
            )).toList(),
          ),
          const SizedBox(height: IveTokens.s4),
          // Message
          TextField(
            controller: _messageCtrl,
            maxLength: 100,
            maxLines: 2,
            style: const TextStyle(fontSize: 13, color: IveTokens.inkColor),
            cursorColor: IveTokens.accentColor,
            decoration: InputDecoration(
              hintText: 'Add a message (optional)',
              hintStyle: const TextStyle(color: IveTokens.muteColor, fontSize: 13),
              filled: true,
              fillColor: IveTokens.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(IveTokens.rAtom),
                borderSide: const BorderSide(color: IveTokens.hairColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(IveTokens.rAtom),
                borderSide: const BorderSide(color: IveTokens.hairColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(IveTokens.rAtom),
                borderSide: const BorderSide(color: IveTokens.accentColor, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: IveTokens.s3),
          // Category
          DropdownButtonFormField<String>(
            initialValue: _category,
            dropdownColor: IveTokens.raisedColor,
            style: const TextStyle(fontSize: 13, color: IveTokens.inkColor),
            items: ['Personal', 'Business', 'Gift', 'Repayment', 'Other']
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _category = v ?? _category),
            decoration: InputDecoration(
              labelText: 'Category',
              labelStyle: const TextStyle(color: IveTokens.muteColor, fontSize: 12),
              filled: true,
              fillColor: IveTokens.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(IveTokens.rAtom),
                borderSide: const BorderSide(color: IveTokens.hairColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(IveTokens.rAtom),
                borderSide: const BorderSide(color: IveTokens.hairColor),
              ),
            ),
          ),
          const SizedBox(height: IveTokens.s3),
          // Schedule
          Text('SCHEDULE', style: IveType.caption.copyWith(color: IveTokens.muteColor)),
          const SizedBox(height: IveTokens.s2),
          ...TransferSchedule.values.map((s) => RadioListTile<TransferSchedule>(
            value: s,
            // ignore: deprecated_member_use
            groupValue: _schedule,
            // ignore: deprecated_member_use
            onChanged: (v) => setState(() => _schedule = v ?? _schedule),
            title: Text(_scheduleLabel(s), style: IveType.callout),
            dense: true,
            activeColor: IveTokens.accentColor,
            visualDensity: VisualDensity.compact,
          )),
        ])),
        _buildFooter(
          () => setState(() => _step = 0),
          _isAmountValid ? () => setState(() => _step = 2) : null,
          'Review',
        ),
      ],
    );
  }

  String _scheduleLabel(TransferSchedule s) {
    switch (s) {
      case TransferSchedule.now: return 'Send now';
      case TransferSchedule.later: return 'Schedule for later';
      case TransferSchedule.onRate: return 'When rate reaches…';
      case TransferSchedule.recurring: return 'Recurring';
    }
  }

  // Step 3: Review — tapping Confirm opens VerifySheet
  Widget _buildReview(GoProvider p) {
    return Column(
      children: [
        Expanded(child: ListView(padding: const EdgeInsets.all(IveTokens.s4), children: [
          Container(
            padding: const EdgeInsets.all(IveTokens.s4),
            decoration: BoxDecoration(
              color: IveTokens.raisedColor,
              borderRadius: BorderRadius.circular(IveTokens.rContainer),
              border: Border.all(color: IveTokens.hairColor),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Text('TRANSFER REVIEW', style: IveType.caption.copyWith(color: IveTokens.muteColor))),
              const SizedBox(height: IveTokens.s3),
              _ReviewRow(label: 'To', value: _receiverName),
              _ReviewRow(label: 'Amount', value: '${_amount.toStringAsFixed(0)} QP'),
              _ReviewRow(label: 'Fee (1%)', value: '${_fee.toStringAsFixed(2)} QP'),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: IveTokens.s2),
                child: Divider(color: IveTokens.hairColor, height: 1),
              ),
              _ReviewRow(label: 'You send', value: '${_total.toStringAsFixed(2)} QP', bold: true),
              const SizedBox(height: IveTokens.s2),
              _ReviewRow(label: 'Category', value: _category),
              _ReviewRow(label: 'Schedule', value: _scheduleLabel(_schedule)),
              if (_messageCtrl.text.isNotEmpty)
                _ReviewRow(label: 'Message', value: _messageCtrl.text),
            ]),
          ),
          const SizedBox(height: IveTokens.s3),
          // Risk indicator
          Container(
            padding: const EdgeInsets.all(IveTokens.s3),
            decoration: BoxDecoration(
              color: IveTokens.surfaceColor,
              borderRadius: BorderRadius.circular(IveTokens.rAtom),
              border: Border.all(color: IveTokens.accentColor.withValues(alpha: 0.3)),
            ),
            child: Row(children: [
              const Icon(Icons.verified_user, size: 16, color: IveTokens.accentColor),
              const SizedBox(width: IveTokens.s3),
              Expanded(
                child: Text(
                  'Risk: LOW — Recipient is a favourite with 12 previous transfers.',
                  style: IveType.caption.copyWith(color: IveTokens.ink2Color),
                ),
              ),
            ]),
          ),
          const SizedBox(height: IveTokens.s3),
          // ignore: deprecated_member_use
          CheckboxListTile(
            value: _termsAccepted,
            onChanged: (v) => setState(() => _termsAccepted = v ?? false),
            activeColor: IveTokens.accentColor,
            checkColor: IveTokens.inkColor,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              'I confirm this transfer is correct and authorized.',
              style: IveType.caption.copyWith(color: IveTokens.ink2Color),
            ),
          ),
        ])),
        _buildFooter(
          () => setState(() => _step = 1),
          _termsAccepted ? () => _confirmTransfer(p) : null,
          'Confirm',
        ),
      ],
    );
  }

  Future<void> _confirmTransfer(GoProvider p) async {
    // VerifySheet title must echo the trigger button "Transfer to {Name}" (spec P1)
    final confirmed = await showVerifySheet(
      context,
      title: 'Transfer to $_receiverName',
      confirmLabel: 'Transfer to $_receiverName',
      subtitle: '${_total.toStringAsFixed(2)} QP will be debited immediately.',
      isDestructive: false,
      onConfirm: () async {
        final ok = await p.transfer(
          toUserId: _receiverId ?? '',
          amount: _amount,
          note: _messageCtrl.text.isNotEmpty ? _messageCtrl.text : null,
        );
        return ok ? null : 'Transfer failed. Try again.';
      },
    );
    if (mounted) {
      setState(() {
        _success = confirmed;
        _step = 3;
        _processing = false;
      });
    }
  }

  // Step 4: Result
  Widget _buildResult() {
    if (_processing) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          IveSkeleton(width: 56, height: 56, radius: BorderRadius.circular(28)),
          const SizedBox(height: IveTokens.s4),
          Text('Sending QPoints…', style: IveType.headline),
        ]),
      );
    }
    final ok = _success == true;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(IveTokens.s6),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (ok ? IveTokens.okColor : IveTokens.badColor).withValues(alpha: 0.12),
            ),
            child: Icon(
              ok ? Icons.check_circle_rounded : Icons.error_outline_rounded,
              size: 40,
              color: ok ? IveTokens.okColor : IveTokens.badColor,
            ),
          ),
          const SizedBox(height: IveTokens.s4),
          Text(
            ok ? 'Transfer complete' : 'Transfer failed',
            style: IveType.title3.copyWith(
              color: ok ? IveTokens.okColor : IveTokens.badColor,
            ),
          ),
          const SizedBox(height: IveTokens.s2),
          Text(
            ok
                ? '${_amount.toStringAsFixed(0)} QP sent to $_receiverName'
                : 'Try again.',
            style: IveType.callout.copyWith(color: IveTokens.ink2Color),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: IveTokens.s6),
          IveButton.primary(label: 'Done', onPressed: () => Navigator.pop(context)),
        ]),
      ),
    );
  }

  Widget _buildFooter(VoidCallback? onBack, VoidCallback? onNext, String label) {
    return Container(
      padding: const EdgeInsets.all(IveTokens.s4),
      decoration: const BoxDecoration(
        color: IveTokens.surfaceColor,
        border: Border(top: BorderSide(color: IveTokens.hairColor, width: 1)),
      ),
      child: Row(children: [
        if (onBack != null) ...[
          Expanded(
            child: IveButton.secondary(label: 'Back', onPressed: onBack),
          ),
          const SizedBox(width: IveTokens.s3),
        ],
        Expanded(
          child: onNext != null
              ? IveButton.primary(label: label, onPressed: onNext)
              : IveButton.primary(label: label, onPressed: null),
        ),
      ]),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label, value;
  final bool bold;
  const _ReviewRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: IveTokens.s1),
    child: Row(children: [
      Expanded(
        child: Text(label, style: IveType.callout.copyWith(
          color: bold ? IveTokens.ink2Color : IveTokens.muteColor,
        )),
      ),
      Flexible(
        child: Text(
          value,
          style: bold
              ? GoogleFonts.ibmPlexMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: IveTokens.inkColor,
                  fontFeatures: [const FontFeature.tabularFigures()],
                )
              : IveType.callout.copyWith(color: IveTokens.ink2Color),
          textAlign: TextAlign.end,
        ),
      ),
    ]),
  );
}
