/// 
/// LIVE MODULE  Screen 15: Multi-Hop Transfer Flow
/// Package hand-off between drivers: scan verification,
/// condition check, chain-of-custody log, transfer confirmation
/// 
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive.dart';
import '../../../core/theme/app_colors.dart';
import '../models/live_models.dart';
import '../providers/live_provider.dart';
import '../widgets/live_widgets.dart';

class LiveMultiHopTransferScreen extends StatefulWidget {
  const LiveMultiHopTransferScreen({super.key});

  @override
  State<LiveMultiHopTransferScreen> createState() => _LiveMultiHopTransferScreenState();
}

class _LiveMultiHopTransferScreenState extends State<LiveMultiHopTransferScreen> {
  int _step = 0; // 0=Scan, 1=Verify, 2=Handoff, 3=Complete
  bool _scanned = false;
  bool _conditionVerified = false;
  bool _handoffConfirmed = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveProvider>(
      builder: (context, prov, _) {
        final pkg = prov.selectedPackage ?? prov.packages.first;
        const TransferRequest? transfer = null;

        if (_step == 3) {
          return _TransferCompleteView(package: pkg, onDone: () => Navigator.pop(context));
        }

        return Scaffold(
          backgroundColor: IveTokens.bg,
          appBar: LiveAppBar(
            title: _step == 0 ? 'Scan Package' : _step == 1 ? 'Verify Condition' : 'Confirm Handoff',
          ),
          body: Column(
            children: [
              // Step indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: IveTokens.s4, vertical: IveTokens.s2),
                color: IveTokens.surface,
                child: Row(
                  children: [
                    _TransferStep(label: 'Scan', index: 0, current: _step, completed: _scanned),
                    Expanded(child: Container(height: 2, color: _scanned ? IveTokens.success : IveTokens.hairline)),
                    _TransferStep(label: 'Verify', index: 1, current: _step, completed: _conditionVerified),
                    Expanded(child: Container(height: 2, color: _conditionVerified ? IveTokens.success : IveTokens.hairline)),
                    _TransferStep(label: 'Handoff', index: 2, current: _step, completed: _handoffConfirmed),
                  ],
                ),
              ),


              Expanded(
                child: IndexedStack(
                  index: _step,
                  children: [
                    // Step 0: Scan
                    _ScanStep(
                      scanned: _scanned,
                      package: pkg,
                      onScan: () => setState(() => _scanned = true),
                    ),
                    // Step 1: Verify
                    _VerifyStep(
                      verified: _conditionVerified,
                      package: pkg,
                      onVerify: () => setState(() => _conditionVerified = true),
                    ),
                    // Step 2: Handoff
                    _HandoffStep(
                      confirmed: _handoffConfirmed,
                      package: pkg,
                      transfer: transfer,
                      onConfirm: () => setState(() => _handoffConfirmed = true),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(IveTokens.s4, IveTokens.s2, IveTokens.s4, IveTokens.s6),
            decoration: const BoxDecoration(color: IveTokens.surface),
            child: Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: IveButton.secondary(
                      label: 'BACK',
                      onPressed: () => setState(() => _step--),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: IveTokens.s3),
                Expanded(
                  flex: 2,
                  child: IveButton.primary(
                    label: _step == 0 ? 'NEXT: VERIFY' : _step == 1 ? 'NEXT: HANDOFF' : 'COMPLETE TRANSFER',
                    onPressed: _canProceed ? () => setState(() => _step++) : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool get _canProceed {
    switch (_step) {
      case 0:
        return _scanned;
      case 1:
        return _conditionVerified;
      case 2:
        return _handoffConfirmed;
      default:
        return false;
    }
  }
}

class _ScanStep extends StatelessWidget {
  final bool scanned;
  final LivePackage package;
  final VoidCallback onScan;
  const _ScanStep({required this.scanned, required this.package, required this.onScan});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(IveTokens.s4),
      children: [
        const SizedBox(height: IveTokens.s5),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(IveTokens.s4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scanned ? IveTokens.success.withValues(alpha: 0.1) : IveTokens.accent.withValues(alpha: 0.1),
                ),
                child: Icon(
                  scanned ? Icons.check_circle : Icons.qr_code_scanner,
                  size: 48,
                  color: scanned ? IveTokens.success : IveTokens.accent,
                ),
              ),
              const SizedBox(height: IveTokens.s4),
              Text(scanned ? 'PACKAGE SCANNED' : 'SCAN PACKAGE QR CODE', style: IveType.headline.copyWith(fontWeight: FontWeight.w800, color: scanned ? IveTokens.success : IveTokens.ink)),
              const SizedBox(height: IveTokens.s1),
              Text('Scan the QR code on package ${package.id}', style: IveType.subhead),
            ],
          ),
        ),
        const SizedBox(height: IveTokens.s6),
        if (!scanned) ...[
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: IveTokens.surfaceRaised,
              borderRadius: const BorderRadius.all(Radius.circular(IveTokens.rSm)),
              border: Border.all(color: IveTokens.accent.withValues(alpha: 0.3), width: 2),
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code_scanner, size: 48, color: IveTokens.mute),
                  SizedBox(height: IveTokens.s2),
                  Text('Point camera at QR code', style: TextStyle(fontSize: 13, color: IveTokens.mute)),
                ],
              ),
            ),
          ),
          const SizedBox(height: IveTokens.s3),
          IveButton.primary(
            label: 'SCAN QR CODE',
            icon: Icons.qr_code_scanner,
            onPressed: onScan,
          ),
          const SizedBox(height: IveTokens.s2),
          Center(child: IveButton.text(label: 'Enter code manually', onPressed: onScan)),
        ] else
          LiveSectionCard(
            title: 'PACKAGE VERIFIED',
            icon: Icons.verified,
            iconColor: IveTokens.success,
            child: Column(
              children: [
                _TransferInfoRow(label: 'Package ID', value: package.id),
                _TransferInfoRow(label: 'Type', value: package.type.name.toUpperCase()),
                _TransferInfoRow(label: 'Stops remaining', value: '${package.stops.where((s) => s.status != StopStatus.completed).length}'),
                _TransferInfoRow(label: 'Value', value: '${package.driverEarnings.toStringAsFixed(0)}'),
              ],
            ),
          ),
      ],
    );
  }
}

class _VerifyStep extends StatelessWidget {
  final bool verified;
  final LivePackage package;
  final VoidCallback onVerify;
  const _VerifyStep({required this.verified, required this.package, required this.onVerify});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const LiveSectionCard(
          title: 'CONDITION CHECK',
          icon: Icons.checklist,
          iconColor: IveTokens.accent,
          child: Column(
            children: [
              _ConditionCheckItem(label: 'Package seal intact', checked: true),
              _ConditionCheckItem(label: 'No visible damage', checked: true),
              _ConditionCheckItem(label: 'Correct package count', checked: true),
              _ConditionCheckItem(label: 'Temperature within range', checked: false),
            ],
          ),
        ),

        const LiveSectionCard(
          title: 'CHAIN OF CUSTODY',
          icon: Icons.link,
          iconColor: IveTokens.accent,
          child: Column(
            children: [
              _CustodyEntry(name: 'Branch Warehouse', time: '09:15 AM', action: 'Created'),
              _CustodyEntry(name: 'James Wilson', time: '09:32 AM', action: 'Picked up'),
              _CustodyEntry(name: 'Transfer Point A', time: '10:05 AM', action: 'Current'),
            ],
          ),
        ),

        if (!verified)
          Padding(
            padding: const EdgeInsets.only(top: IveTokens.s2),
            child: IveButton.primary(
              label: 'VERIFY CONDITION',
              icon: Icons.verified,
              onPressed: onVerify,
            ),
          ),
      ],
    );
  }
}

class _HandoffStep extends StatelessWidget {
  final bool confirmed;
  final LivePackage package;
  final TransferRequest? transfer;
  final VoidCallback onConfirm;
  const _HandoffStep({required this.confirmed, required this.package, required this.transfer, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        LiveSectionCard(
          title: 'RECEIVING DRIVER',
          icon: Icons.person,
          iconColor: IveTokens.accent,
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: IveTokens.accentSoft,
                child: const Text('SC', style: TextStyle(fontWeight: FontWeight.w700, color: IveTokens.accent)),
              ),
              const SizedBox(width: IveTokens.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sarah Chen', style: IveType.callout.copyWith(fontWeight: FontWeight.w700, color: IveTokens.ink)),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: IveTokens.warning),
                        const SizedBox(width: 2),
                        Text('4.7', style: IveType.footnote),
                        const SizedBox(width: IveTokens.s2),
                        Text('ID verified', style: IveType.footnote.copyWith(color: IveTokens.success)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        LiveSectionCard(
          title: 'TRANSFER DETAILS',
          icon: Icons.swap_horiz,
          iconColor: IveTokens.moduleLive,
          child: Column(
            children: [
              _TransferInfoRow(label: 'Package', value: package.id),
              _TransferInfoRow(label: 'Remaining stops', value: '${package.stops.where((s) => s.status != StopStatus.completed).length}'),
              const _TransferInfoRow(label: 'Transfer reason', value: 'Zone handoff'),
              const _TransferInfoRow(label: 'Location', value: 'Transfer Point A'),
            ],
          ),
        ),

        if (!confirmed)
          Padding(
            padding: const EdgeInsets.only(top: IveTokens.s2),
            child: Container(
              padding: const EdgeInsets.all(IveTokens.s3),
              decoration: const BoxDecoration(color: IveTokens.surfaceRaised, borderRadius: BorderRadius.all(Radius.circular(IveTokens.rSm))),
              child: const Row(
                children: [
                  Icon(Icons.warning, size: 16, color: IveTokens.warning),
                  SizedBox(width: IveTokens.s2),
                  Expanded(child: Text('Both drivers must confirm this transfer. Custody will be logged automatically.', style: TextStyle(fontSize: 12, color: IveTokens.warning))),
                ],
              ),
            ),
          ),

        if (!confirmed)
          Padding(
            padding: const EdgeInsets.only(top: IveTokens.s3),
            child: IveButton.primary(
              label: 'CONFIRM HANDOFF',
              icon: Icons.handshake,
              onPressed: () {
                HapticFeedback.heavyImpact();
                onConfirm();
              },
            ),
          ),
      ],
    );
  }
}

class _TransferCompleteView extends StatelessWidget {
  final LivePackage package;
  final VoidCallback onDone;
  const _TransferCompleteView({required this.package, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IveTokens.bg,
      appBar: const LiveAppBar(title: 'Transfer Complete'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(IveTokens.s6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(IveTokens.s6),
                decoration: BoxDecoration(shape: BoxShape.circle, color: IveTokens.success.withValues(alpha: 0.1)),
                child: const Icon(Icons.handshake, size: 64, color: IveTokens.success),
              ),
              const SizedBox(height: IveTokens.s5),
              Text('TRANSFER COMPLETE!', style: IveType.title2.copyWith(fontWeight: FontWeight.w900, color: IveTokens.ink)),
              const SizedBox(height: IveTokens.s2),
              Text('Package ${package.id} handed off successfully', style: IveType.callout),
              const SizedBox(height: IveTokens.s1),
              Text('Chain of custody updated', style: IveType.subhead.copyWith(fontWeight: FontWeight.w600, color: IveTokens.success)),
              const SizedBox(height: IveTokens.s6),
              IveButton.primary(label: 'BACK TO HOME', onPressed: onDone),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransferStep extends StatelessWidget {
  final String label;
  final int index;
  final int current;
  final bool completed;
  const _TransferStep({required this.label, required this.index, required this.current, required this.completed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: completed ? IveTokens.success : index == current ? IveTokens.moduleLive : IveTokens.hairline,
          ),
          child: Center(
            child: completed ? const Icon(Icons.check, size: 16, color: IveTokens.ink) : index == current ? const Icon(Icons.circle, size: 8, color: IveTokens.ink) : null,
          ),
        ),
        const SizedBox(height: IveTokens.s1),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: index <= current ? IveTokens.ink : IveTokens.mute)),
      ],
    );
  }
}

class _ConditionCheckItem extends StatelessWidget {
  final String label;
  final bool checked;
  const _ConditionCheckItem({required this.label, required this.checked});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: IveTokens.s1 + 2),
      child: Row(
        children: [
          Icon(checked ? Icons.check_circle : Icons.radio_button_unchecked, size: 18, color: checked ? IveTokens.success : IveTokens.mute),
          const SizedBox(width: IveTokens.s2),
          Text(label, style: IveType.subhead.copyWith(color: checked ? IveTokens.ink : IveTokens.mute)),
        ],
      ),
    );
  }
}

class _CustodyEntry extends StatelessWidget {
  final String name;
  final String time;
  final String action;
  const _CustodyEntry({required this.name, required this.time, required this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: IveTokens.s2),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: action == 'Current' ? IveTokens.moduleLive : IveTokens.success),
          ),
          const SizedBox(width: IveTokens.s2 + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: IveType.subhead.copyWith(fontWeight: FontWeight.w600, color: IveTokens.ink)),
                Text('$time  $action', style: IveType.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransferInfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _TransferInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
