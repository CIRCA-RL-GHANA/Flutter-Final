/// Fintech › Insurance — Policy Purchase & Claims Screen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/fintech_service.dart';
import '../../../../core/services/ai_insights_notifier.dart';

const _kTeal = Color(0xFF009688);

class InsuranceScreen extends StatefulWidget {
  const InsuranceScreen({super.key});
  @override
  State<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends State<InsuranceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _fintechSvc = FintechService();

  // Browse/purchase
  final _fiIdCtrl = TextEditingController();
  final _coverageCtrl = TextEditingController();
  final _premiumCtrl = TextEditingController();
  String _policyType = 'motor';
  int _durationDays = 365;
  bool _buying = false;

  // My policies & claims
  List<Map<String, dynamic>> _policies = [];
  List<Map<String, dynamic>> _claims = [];
  bool _loadingPolicies = false;

  static const _policyTypes = ['motor', 'health', 'inventory', 'life', 'property', 'travel', 'other'];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadPolicies();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _fiIdCtrl.dispose();
    _coverageCtrl.dispose();
    _premiumCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPolicies() async {
    setState(() => _loadingPolicies = true);
    final pRes = await _fintechSvc.getPolicies();
    final cRes = await _fintechSvc.getClaims();
    if (mounted) {
      setState(() {
        _policies = pRes.data ?? [];
        _claims = cRes.data ?? [];
        _loadingPolicies = false;
      });
    }
  }

  Future<void> _purchase() async {
    final fi = _fiIdCtrl.text.trim();
    final coverage = double.tryParse(_coverageCtrl.text.trim());
    final premium = double.tryParse(_premiumCtrl.text.trim());
    if (fi.isEmpty || coverage == null || premium == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill all fields')));
      return;
    }
    setState(() => _buying = true);
    final res = await _fintechSvc.purchasePolicy(
      fiEntityId: fi,
      policyType: _policyType,
      coverageQp: coverage,
      premiumQp: premium,
      durationDays: _durationDays,
    );
    if (mounted) {
      setState(() => _buying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.data != null ? 'Policy purchased!' : (res.message ?? 'Failed'))),
      );
      if (res.data != null) { _tabs.animateTo(1); _loadPolicies(); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Insurance', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, foregroundColor: Colors.black87, elevation: 0,
        bottom: TabBar(
          controller: _tabs,
          labelColor: _kTeal, unselectedLabelColor: Colors.grey, indicatorColor: _kTeal,
          tabs: const [Tab(text: 'Browse'), Tab(text: 'My Policies')],
        ),
      ),
      body: Column(children: [
        Consumer<AIInsightsNotifier>(builder: (context, ai, _) {
          if (ai.insights.isEmpty) return const SizedBox.shrink();
          return Container(
            color: _kTeal.withOpacity(0.06),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(children: [
              const Icon(Icons.auto_awesome, size: 14, color: _kTeal),
              const SizedBox(width: 8),
              Expanded(child: Text('Genie: ${ai.insights.first['label'] ?? 'Protect your assets'}',
                style: const TextStyle(fontSize: 11, color: _kTeal),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
          );
        }),
        Expanded(child: TabBarView(controller: _tabs, children: [
          _buildBrowseTab(),
          _buildPoliciesTab(),
        ])),
      ]),
    );
  }

  Widget _buildBrowseTab() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      _PolicyTypeSelector(selected: _policyType, onSelect: (t) => setState(() => _policyType = t), types: _policyTypes),
      const SizedBox(height: 16),
      _PurchaseCard(
        fiIdCtrl: _fiIdCtrl,
        coverageCtrl: _coverageCtrl,
        premiumCtrl: _premiumCtrl,
        durationDays: _durationDays,
        onDurationChanged: (d) => setState(() => _durationDays = d),
        loading: _buying,
        onPurchase: _purchase,
      ),
    ]);
  }

  Widget _buildPoliciesTab() {
    if (_loadingPolicies) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      onRefresh: _loadPolicies,
      child: ListView(padding: const EdgeInsets.all(16), children: [
        if (_policies.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No policies yet', style: TextStyle(color: Colors.grey))))
        else ...[
          const Text('Active Policies', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          ..._policies.map((p) => PolicyCard(policy: p, onFileClaim: () => _showFileClaimSheet(p))),
        ],
        if (_claims.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text('Claims', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          ..._claims.map((c) => _ClaimTile(claim: c)),
        ],
      ]),
    );
  }

  void _showFileClaimSheet(Map<String, dynamic> policy) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ClaimsSheet(policy: policy, fintechSvc: _fintechSvc, onSubmitted: _loadPolicies),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _PolicyTypeSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  final List<String> types;
  const _PolicyTypeSelector({required this.selected, required this.onSelect, required this.types});

  @override
  Widget build(BuildContext context) => Wrap(spacing: 8, runSpacing: 8, children: types.map((t) =>
    GestureDetector(
      onTap: () => onSelect(t),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected == t ? _kTeal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected == t ? _kTeal : const Color(0xFFE5E7EB)),
        ),
        child: Text(t, style: TextStyle(fontSize: 12, color: selected == t ? Colors.white : Colors.grey.shade700, fontWeight: FontWeight.w500)),
      ),
    ),
  ).toList());
}

class _PurchaseCard extends StatelessWidget {
  final TextEditingController fiIdCtrl, coverageCtrl, premiumCtrl;
  final int durationDays;
  final ValueChanged<int> onDurationChanged;
  final bool loading;
  final VoidCallback onPurchase;
  const _PurchaseCard({required this.fiIdCtrl, required this.coverageCtrl, required this.premiumCtrl,
    required this.durationDays, required this.onDurationChanged, required this.loading, required this.onPurchase});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Purchase Policy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 12),
      _Field('FI Entity ID', fiIdCtrl, 'Bank entity UUID'),
      _Field('Coverage (QP)', coverageCtrl, 'e.g. 5000'),
      _Field('Premium (QP)', premiumCtrl, 'e.g. 50'),
      const SizedBox(height: 6),
      Text('Duration: $durationDays days', style: const TextStyle(fontSize: 12, color: Colors.grey)),
      Slider(value: durationDays.toDouble(), min: 30, max: 1095, divisions: 30, activeColor: _kTeal,
        onChanged: (v) => onDurationChanged(v.round())),
      const SizedBox(height: 10),
      SizedBox(width: double.infinity, child: ElevatedButton(
        onPressed: loading ? null : onPurchase,
        style: ElevatedButton.styleFrom(backgroundColor: _kTeal, foregroundColor: Colors.white),
        child: loading
            ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Buy Policy'),
      )),
    ]),
  );
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String hint;
  const _Field(this.label, this.ctrl, this.hint);

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey))),
    TextField(controller: ctrl,
      keyboardType: label.contains('QP') ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(hintText: hint, filled: true, fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12))),
  ]);
}

class PolicyCard extends StatelessWidget {
  final Map<String, dynamic> policy;
  final VoidCallback onFileClaim;
  const PolicyCard({super.key, required this.policy, required this.onFileClaim});

  @override
  Widget build(BuildContext context) {
    final type = policy['policyType'] as String? ?? 'other';
    final coverage = policy['coverageQp'] ?? 0;
    final status = policy['status'] as String? ?? 'active';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            const Icon(Icons.shield, color: _kTeal, size: 20),
            const SizedBox(width: 8),
            Text(type.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: (status == 'active' ? Colors.green : Colors.grey).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: status == 'active' ? Colors.green : Colors.grey)),
          ),
        ]),
        const SizedBox(height: 6),
        Text('Coverage: $coverage QP', style: const TextStyle(color: Colors.grey, fontSize: 12)),
        if (status == 'active')
          TextButton(onPressed: onFileClaim, child: const Text('File a Claim →', style: TextStyle(color: _kTeal))),
      ]),
    );
  }
}

class _ClaimTile extends StatelessWidget {
  final Map<String, dynamic> claim;
  const _ClaimTile({required this.claim});

  @override
  Widget build(BuildContext context) {
    final status = claim['status'] as String? ?? 'submitted';
    final amount = claim['amountClaimedQp'] ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Row(children: [
        const Icon(Icons.receipt_long, color: Colors.orange, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Claimed: $amount QP', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Text(claim['description'] as String? ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: _claimStatusColor(status).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text(status.replaceAll('_', ' '), style: TextStyle(fontSize: 11, color: _claimStatusColor(status), fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }

  Color _claimStatusColor(String s) {
    switch (s) {
      case 'paid_out': return Colors.green;
      case 'approved': return Colors.blue;
      case 'rejected': return Colors.red;
      case 'under_review': return Colors.orange;
      default: return Colors.grey;
    }
  }
}

// ─── File Claim Bottom Sheet ──────────────────────────────────────────────────

class ClaimsScreen extends StatefulWidget {
  const ClaimsScreen({super.key});
  @override
  State<ClaimsScreen> createState() => _ClaimsScreenState();
}

class _ClaimsScreenState extends State<ClaimsScreen> {
  final _fintechSvc = FintechService();
  List<Map<String, dynamic>> _claims = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await _fintechSvc.getClaims();
    if (mounted) setState(() { _claims = res.data ?? []; _loading = false; });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('My Claims'), backgroundColor: Colors.white, foregroundColor: Colors.black87, elevation: 0),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _claims.isEmpty
            ? const Center(child: Text('No claims filed', style: TextStyle(color: Colors.grey)))
            : ListView.separated(padding: const EdgeInsets.all(16), itemCount: _claims.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _ClaimTile(claim: _claims[i])),
  );
}

class ClaimsSheet extends StatefulWidget {
  final Map<String, dynamic> policy;
  final FintechService fintechSvc;
  final VoidCallback onSubmitted;
  const ClaimsSheet({super.key, required this.policy, required this.fintechSvc, required this.onSubmitted});

  @override
  State<ClaimsSheet> createState() => _ClaimsSheetState();
}

class _ClaimsSheetState extends State<ClaimsSheet> {
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() { _amountCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    final desc = _descCtrl.text.trim();
    if (amount == null || desc.isEmpty) return;
    setState(() => _submitting = true);
    final res = await widget.fintechSvc.fileClaim(
      policyId: widget.policy['id'] as String,
      amountClaimedQp: amount,
      description: desc,
    );
    if (mounted) {
      setState(() => _submitting = false);
      if (res.data != null) { widget.onSubmitted(); Navigator.pop(context); }
      else ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message ?? 'Failed')));
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('File a Claim', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 12),
      TextField(controller: _amountCtrl, keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Claim Amount (QP)', border: OutlineInputBorder())),
      const SizedBox(height: 10),
      TextField(controller: _descCtrl, maxLines: 3,
        decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
      const SizedBox(height: 14),
      SizedBox(width: double.infinity, child: ElevatedButton(
        onPressed: _submitting ? null : _submit,
        style: ElevatedButton.styleFrom(backgroundColor: _kTeal, foregroundColor: Colors.white),
        child: _submitting
            ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Submit Claim'),
      )),
      const SizedBox(height: 20),
    ]),
  );
}
