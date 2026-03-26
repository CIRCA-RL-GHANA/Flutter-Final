/// GO Screen 3 — Verification Modal
/// Universal bottom-sheet verification with 4 methods:
/// Face ID, Fingerprint, PIN, OTP
/// 4 states: pending, verifying, verified, failed

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../models/go_models.dart';
import '../widgets/go_widgets.dart';

class GoVerificationScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final double? amount;
  final VoidCallback? onVerified;
  const GoVerificationScreen({super.key, this.title = 'Verify Action', this.subtitle = 'Please verify your identity to proceed.', this.amount, this.onVerified});

  /// Show as a bottom sheet
  static Future<bool?> show(BuildContext context, {String title = 'Verify Action', String subtitle = 'Confirm to proceed.', double? amount}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (ctx, scrollCtrl) => Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          child: GoVerificationScreen(title: title, subtitle: subtitle, amount: amount, onVerified: () => Navigator.pop(ctx, true)),
        ),
      ),
    );
  }

  @override
  State<GoVerificationScreen> createState() => _GoVerificationScreenState();
}

class _GoVerificationScreenState extends State<GoVerificationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  GoVerificationState _state = GoVerificationState.pending;
  GoVerificationMethod? _selectedMethod;
  final _pinCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  @override
  void initState() { super.initState(); _tabCtrl = TabController(length: 4, vsync: this); }
  @override
  void dispose() { _tabCtrl.dispose(); _pinCtrl.dispose(); _otpCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Drag handle
        Container(margin: const EdgeInsets.only(top: 10), width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFD1D5DB), borderRadius: BorderRadius.circular(2))),
        Consumer<AIInsightsNotifier>(
          builder: (context, ai, _) {
            if (ai.insights.isEmpty) return const SizedBox.shrink();
            return Container(
              color: kGoColor.withOpacity(0.07),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(children: [
                const Icon(Icons.auto_awesome, size: 14, color: kGoColor),
                const SizedBox(width: 8),
                Expanded(child: Text('AI: ${ai.insights.first['title'] ?? ''}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kGoColor),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(widget.subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)), textAlign: TextAlign.center),
            if (widget.amount != null) ...[
              const SizedBox(height: 8),
              Text('${widget.amount!.toStringAsFixed(2)} QP', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: kGoColor)),
            ],
          ]),
        ),
        if (_state == GoVerificationState.pending) ...[
          TabBar(
            controller: _tabCtrl,
            labelColor: kGoColor, unselectedLabelColor: const Color(0xFF9CA3AF),
            indicatorColor: kGoColor, indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            tabs: const [Tab(text: 'Quick'), Tab(text: 'Detail'), Tab(text: 'Security'), Tab(text: 'Help')],
          ),
          Expanded(
            child: TabBarView(controller: _tabCtrl, children: [
              _buildQuickTab(),
              _buildDetailTab(),
              _buildSecurityTab(),
              _buildHelpTab(),
            ]),
          ),
        ] else ...[
          Expanded(child: _buildStateView()),
        ],
      ],
    );
  }

  // Tab 1: Quick Verify
  Widget _buildQuickTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMethodCard(GoVerificationMethod.faceId, Icons.face, 'Face ID', 'Verify with facial recognition'),
        _buildMethodCard(GoVerificationMethod.fingerprint, Icons.fingerprint, 'Fingerprint', 'Use your registered fingerprint'),
        _buildMethodCard(GoVerificationMethod.pin, Icons.pin, 'PIN Code', 'Enter your 6-digit PIN'),
        _buildMethodCard(GoVerificationMethod.otp, Icons.sms, 'OTP', 'Receive code via SMS'),
      ],
    );
  }

  Widget _buildMethodCard(GoVerificationMethod method, IconData icon, String title, String desc) {
    final sel = _selectedMethod == method;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedMethod = method);
        if (method == GoVerificationMethod.faceId || method == GoVerificationMethod.fingerprint) {
          _startVerification();
        }
        // PIN and OTP need input first
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: sel ? kGoColorLight : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: sel ? kGoColor : const Color(0xFFE5E7EB), width: sel ? 2 : 1)),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: kGoColorLight, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: kGoColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
          ])),
          if (sel) const Icon(Icons.check_circle, color: kGoColor, size: 20),
        ]),
      ),
    );
  }

  // Tab 2: Detailed Review
  Widget _buildDetailTab() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('TRANSACTION DETAILS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
        const Divider(height: 16),
        _DetailRow(label: 'Action', value: widget.title),
        if (widget.amount != null) _DetailRow(label: 'Amount', value: '${widget.amount!.toStringAsFixed(2)} QP'),
        _DetailRow(label: 'Time', value: TimeOfDay.now().format(context)),
        const _DetailRow(label: 'Device', value: 'This device (verified)'),
        const _DetailRow(label: 'IP', value: '192.168.1.***'),
        const _DetailRow(label: 'Risk Level', value: 'Low'),
      ])),
      const SizedBox(height: 16),
      SizedBox(width: double.infinity, child: ElevatedButton(
        onPressed: _selectedMethod != null ? _startVerification : null,
        style: ElevatedButton.styleFrom(backgroundColor: kGoColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        child: const Text('Proceed with Verification', style: TextStyle(fontWeight: FontWeight.w600)),
      )),
    ]);
  }

  // Tab 3: Security Settings
  Widget _buildSecurityTab() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('VERIFICATION PREFERENCES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
        const Divider(height: 16),
        SwitchListTile(title: const Text('Require for all transactions', style: TextStyle(fontSize: 13)), value: true, onChanged: (_) {}, activeColor: kGoColor, dense: true),
        SwitchListTile(title: const Text('Biometric preferred', style: TextStyle(fontSize: 13)), value: true, onChanged: (_) {}, activeColor: kGoColor, dense: true),
        SwitchListTile(title: const Text('Remember device (7 days)', style: TextStyle(fontSize: 13)), value: false, onChanged: (_) {}, activeColor: kGoColor, dense: true),
      ])),
      const SizedBox(height: 10),
      GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('THRESHOLDS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
        const Divider(height: 16),
        const _DetailRow(label: 'Single transaction limit', value: '50,000 QP'),
        const _DetailRow(label: 'Daily limit', value: '200,000 QP'),
        const _DetailRow(label: 'Monthly limit', value: '1,000,000 QP'),
      ])),
    ]);
  }

  // Tab 4: Help
  Widget _buildHelpTab() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      _buildFAQ('Why do I need to verify?', 'Verification protects your account from unauthorized transactions and ensures compliance with financial regulations.'),
      _buildFAQ('What if biometric fails?', 'You can always use PIN or OTP as fallback methods. If issues persist, contact support.'),
      _buildFAQ('How is my data protected?', 'All verification data is encrypted end-to-end and never stored on our servers.'),
      _buildFAQ('Can I change my verification method?', 'Yes, go to Security tab in this modal or visit Settings → Security to manage preferences.'),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        icon: const Icon(Icons.support_agent, size: 18),
        label: const Text('Contact Support'),
        onPressed: () {},
        style: OutlinedButton.styleFrom(foregroundColor: kGoColor, side: const BorderSide(color: Color(0xFFE5E7EB)), padding: const EdgeInsets.symmetric(vertical: 12)),
      ),
    ]);
  }

  Widget _buildFAQ(String q, String a) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(q, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      children: [Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(a, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))))],
    );
  }

  void _startVerification() {
    setState(() => _state = GoVerificationState.verifying);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _state = GoVerificationState.verified);
        Future.delayed(const Duration(milliseconds: 800), () {
          widget.onVerified?.call();
        });
      }
    });
  }

  Widget _buildStateView() {
    switch (_state) {
      case GoVerificationState.verifying:
        return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(width: 64, height: 64, child: CircularProgressIndicator(strokeWidth: 4, color: kGoColor)),
          const SizedBox(height: 20),
          Text(_selectedMethod == GoVerificationMethod.faceId ? 'Scanning face...' : _selectedMethod == GoVerificationMethod.fingerprint ? 'Reading fingerprint...' : 'Verifying...', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Please hold still', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
        ]));
      case GoVerificationState.verified:
        return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_circle, size: 72, color: kGoPositive),
          const SizedBox(height: 16),
          const Text('Verified!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kGoPositive)),
          const SizedBox(height: 8),
          const Text('Identity confirmed successfully.', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        ]));
      case GoVerificationState.failed:
        return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, size: 72, color: kGoNegative),
          const SizedBox(height: 16),
          const Text('Verification Failed', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kGoNegative)),
          const SizedBox(height: 8),
          const Text('Please try again with a different method.', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: () => setState(() { _state = GoVerificationState.pending; _selectedMethod = null; }), style: ElevatedButton.styleFrom(backgroundColor: kGoColor, foregroundColor: Colors.white), child: const Text('Try Again')),
        ]));
      default:
        return const SizedBox.shrink();
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label; final String value;
  const _DetailRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [
    Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)))),
    Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
  ]));
}
