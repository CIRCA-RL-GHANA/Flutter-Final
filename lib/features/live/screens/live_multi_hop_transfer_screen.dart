/// ═══════════════════════════════════════════════════════════════════════════
/// LIVE MODULE — Screen 15: Multi-Hop Transfer Flow
/// Package hand-off between drivers: scan verification,
/// condition check, chain-of-custody log, transfer confirmation
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../models/live_models.dart';
import '../providers/live_provider.dart';
import '../widgets/live_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

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
        final TransferRequest? transfer = null;

        if (_step == 3) {
          return _TransferCompleteView(package: pkg, onDone: () => Navigator.pop(context));
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: LiveAppBar(
            title: _step == 0 ? 'Scan Package' : _step == 1 ? 'Verify Condition' : 'Confirm Handoff',
          ),
          body: Column(
            children: [
              // Step indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Row(
                  children: [
                    _TransferStep(label: 'Scan', index: 0, current: _step, completed: _scanned),
                    Expanded(child: Container(height: 2, color: _scanned ? const Color(0xFF10B981) : const Color(0xFFE5E7EB))),
                    _TransferStep(label: 'Verify', index: 1, current: _step, completed: _conditionVerified),
                    Expanded(child: Container(height: 2, color: _conditionVerified ? const Color(0xFF10B981) : const Color(0xFFE5E7EB))),
                    _TransferStep(label: 'Handoff', index: 2, current: _step, completed: _handoffConfirmed),
                  ],
                ),
              ),

              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kLiveColor.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kLiveColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI: ${ai.insights.first['title'] ?? ''}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kLiveColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))],
            ),
            child: Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _step--),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text('BACK'),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _canProceed ? () => setState(() => _step++) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _step == 2 ? const Color(0xFF10B981) : kLiveColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _step == 0 ? 'NEXT: VERIFY' : _step == 1 ? 'NEXT: HANDOFF' : '✅ COMPLETE TRANSFER',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
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
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scanned ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFF8B5CF6).withOpacity(0.1),
                ),
                child: Icon(
                  scanned ? Icons.check_circle : Icons.qr_code_scanner,
                  size: 48,
                  color: scanned ? const Color(0xFF10B981) : const Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(height: 16),
              Text(scanned ? 'PACKAGE SCANNED ✅' : 'SCAN PACKAGE QR CODE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: scanned ? const Color(0xFF10B981) : AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text('Scan the QR code on package ${package.id}', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (!scanned) ...[
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3), width: 2),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code_scanner, size: 48, color: AppColors.textTertiary),
                  const SizedBox(height: 8),
                  Text('Point camera at QR code', style: TextStyle(fontSize: 13, color: AppColors.textTertiary)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.qr_code_scanner, size: 18),
              label: const Text('SCAN QR CODE', style: TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
          const SizedBox(height: 8),
          Center(child: TextButton(onPressed: onScan, child: const Text('Enter code manually', style: TextStyle(color: AppColors.textSecondary)))),
        ] else
          LiveSectionCard(
            title: 'PACKAGE VERIFIED',
            icon: Icons.verified,
            iconColor: const Color(0xFF10B981),
            child: Column(
              children: [
                _TransferInfoRow(label: 'Package ID', value: package.id),
                _TransferInfoRow(label: 'Type', value: package.type.name.toUpperCase()),
                _TransferInfoRow(label: 'Stops remaining', value: '${package.stops.where((s) => s.status != StopStatus.completed).length}'),
                _TransferInfoRow(label: 'Value', value: '₵${package.driverEarnings.toStringAsFixed(0)}'),
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
        LiveSectionCard(
          title: 'CONDITION CHECK',
          icon: Icons.checklist,
          iconColor: const Color(0xFF3B82F6),
          child: Column(
            children: const [
              _ConditionCheckItem(label: 'Package seal intact', checked: true),
              _ConditionCheckItem(label: 'No visible damage', checked: true),
              _ConditionCheckItem(label: 'Correct package count', checked: true),
              _ConditionCheckItem(label: 'Temperature within range', checked: false),
            ],
          ),
        ),

        LiveSectionCard(
          title: 'CHAIN OF CUSTODY',
          icon: Icons.link,
          iconColor: const Color(0xFF8B5CF6),
          child: Column(
            children: [
              const _CustodyEntry(name: 'Branch Warehouse', time: '09:15 AM', action: 'Created'),
              const _CustodyEntry(name: 'James Wilson', time: '09:32 AM', action: 'Picked up'),
              const _CustodyEntry(name: 'Transfer Point A', time: '10:05 AM', action: 'Current'),
            ],
          ),
        ),

        if (!verified)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onVerify,
                icon: const Icon(Icons.verified, size: 18),
                label: const Text('VERIFY CONDITION', style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
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
          iconColor: const Color(0xFF3B82F6),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF3B82F6).withOpacity(0.1),
                child: const Text('SC', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF3B82F6))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sarah Chen', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 2),
                        Text('4.7', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(width: 8),
                        Text('ID verified ✅', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
          iconColor: kLiveColor,
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
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.warning, size: 16, color: Color(0xFFF59E0B)),
                  SizedBox(width: 8),
                  Expanded(child: Text('Both drivers must confirm this transfer. Custody will be logged automatically.', style: TextStyle(fontSize: 12, color: Color(0xFF92400E)))),
                ],
              ),
            ),
          ),

        if (!confirmed)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  onConfirm();
                },
                icon: const Icon(Icons.handshake, size: 18),
                label: const Text('CONFIRM HANDOFF', style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
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
      backgroundColor: AppColors.backgroundLight,
      appBar: const LiveAppBar(title: 'Transfer Complete'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF10B981).withOpacity(0.1)),
                child: const Icon(Icons.handshake, size: 64, color: Color(0xFF10B981)),
              ),
              const SizedBox(height: 20),
              const Text('🤝 TRANSFER COMPLETE!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('Package ${package.id} handed off successfully', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              const Text('Chain of custody updated', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF10B981))),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onDone,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: const Text('BACK TO HOME', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
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
            color: completed ? const Color(0xFF10B981) : index == current ? kLiveColor : const Color(0xFFE5E7EB),
          ),
          child: Center(
            child: completed ? const Icon(Icons.check, size: 16, color: Colors.white) : index == current ? const Icon(Icons.circle, size: 8, color: Colors.white) : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: index <= current ? AppColors.textPrimary : AppColors.textTertiary)),
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
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(checked ? Icons.check_circle : Icons.radio_button_unchecked, size: 18, color: checked ? const Color(0xFF10B981) : AppColors.textTertiary),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 13, color: checked ? AppColors.textPrimary : AppColors.textTertiary)),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: action == 'Current' ? kLiveColor : const Color(0xFF10B981)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text('$time — $action', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
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
          Text(label, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
