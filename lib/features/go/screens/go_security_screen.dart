/// GO Screen 13 — Security Center
/// Access control, audit trail, security settings

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../providers/go_provider.dart';
import '../widgets/go_widgets.dart';

class GoSecurityScreen extends StatefulWidget {
  const GoSecurityScreen({super.key});
  @override
  State<GoSecurityScreen> createState() => _GoSecurityScreenState();
}

class _GoSecurityScreenState extends State<GoSecurityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() { super.initState(); _tabCtrl = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoProvider>(
      builder: (context, provider, _) => Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        appBar: const GoAppBar(title: 'Security Center'),
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
                          'AI security: ${ai.insights.first['title'] ?? ''}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kGoColor),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabCtrl,
                labelColor: kGoColor, unselectedLabelColor: const Color(0xFF9CA3AF),
                indicatorColor: kGoColor, indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                tabs: const [Tab(text: 'Overview'), Tab(text: 'Audit Trail'), Tab(text: 'Settings')],
              ),
            ),
            Expanded(
              child: TabBarView(controller: _tabCtrl, children: [
                _buildOverview(provider),
                _buildAuditTrail(provider),
                _buildSettings(provider),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverview(GoProvider p) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      // Security score
      GoSectionCard(child: Column(children: [
        const Text('SECURITY SCORE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
        const SizedBox(height: 10),
        const GoHealthGauge(score: 85, size: 110),
        const SizedBox(height: 8),
        const Text('Strong', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kGoPositive)),
        const SizedBox(height: 4),
        const Text('2 recommendations to improve', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
      ])),
      const SizedBox(height: 14),
      // Status cards
      const GoSectionHeader(title: 'Security Status', icon: Icons.shield),
      const SizedBox(height: 8),
      _StatusRow(icon: Icons.fingerprint, label: 'Biometric Auth', status: p.getSecuritySetting('biometricLogin') ? 'Enabled' : 'Disabled', isGood: p.getSecuritySetting('biometricLogin')),
      _StatusRow(icon: Icons.phonelink_lock, label: '2-Factor Auth', status: p.getSecuritySetting('twoFactorAuth') ? 'Enabled' : 'Disabled', isGood: p.getSecuritySetting('twoFactorAuth')),
      _StatusRow(icon: Icons.notifications_active, label: 'Transaction Alerts', status: p.getSecuritySetting('anomalyAlerts') ? 'On' : 'Off', isGood: p.getSecuritySetting('anomalyAlerts')),
      _StatusRow(icon: Icons.lock, label: 'Auto-lock', status: '5 min', isGood: true),
      _StatusRow(icon: Icons.devices, label: 'Known Devices', status: '2 devices', isGood: true),
      const SizedBox(height: 14),
      // Recommendations
      const GoSectionHeader(title: 'Recommendations', icon: Icons.lightbulb),
      const SizedBox(height: 8),
      _RecommendCard(icon: Icons.lock, title: 'Enable 2FA', desc: 'Add an extra layer of security with two-factor authentication.', action: 'Enable'),
      _RecommendCard(icon: Icons.password, title: 'Update PIN', desc: 'Your PIN hasn\'t been changed in 90 days.', action: 'Change'),
    ]);
  }

  Widget _buildAuditTrail(GoProvider p) {
    final audits = p.auditEntries;
    return ListView(padding: const EdgeInsets.all(16), children: [
      // Filters
      Row(children: [
        const Text('Recent Activity', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const Spacer(),
        TextButton.icon(
          icon: const Icon(Icons.filter_list, size: 14),
          label: const Text('Filter', style: TextStyle(fontSize: 11)),
          onPressed: () {},
          style: TextButton.styleFrom(foregroundColor: kGoColor),
        ),
      ]),
      const SizedBox(height: 8),
      ...audits.map((a) => GoAuditRow(entry: a)),
      if (audits.isEmpty) const GoEmptyState(icon: Icons.history, title: 'No audit entries', message: 'Activity will appear here.'),
    ]);
  }

  Widget _buildSettings(GoProvider p) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const GoSectionHeader(title: 'Authentication', icon: Icons.lock),
        const SizedBox(height: 8),
        _ToggleRow(label: 'Biometric Login', value: p.getSecuritySetting('biometricLogin'), onChanged: (v) => p.setSecuritySetting('biometricLogin', v)),
        _ToggleRow(label: 'Two-Factor Authentication', value: p.getSecuritySetting('twoFactorAuth'), onChanged: (v) => p.setSecuritySetting('twoFactorAuth', v)),
        _ToggleRow(label: 'Require PIN for transactions', value: true, onChanged: (v) {}),
      ])),
      const SizedBox(height: 14),
      GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const GoSectionHeader(title: 'Notifications', icon: Icons.notifications),
        const SizedBox(height: 8),
        _ToggleRow(label: 'Transaction alerts', value: p.getSecuritySetting('anomalyAlerts'), onChanged: (v) {}),
        _ToggleRow(label: 'Login alerts', value: true, onChanged: (v) {}),
        _ToggleRow(label: 'Security warnings', value: true, onChanged: (v) {}),
      ])),
      const SizedBox(height: 14),
      GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const GoSectionHeader(title: 'Limits', icon: Icons.speed),
        const SizedBox(height: 8),
        _LimitRow(label: 'Single Transaction', value: '50000 QP'),
        _LimitRow(label: 'Daily Limit', value: '200000 QP'),
        _LimitRow(label: 'Monthly Limit', value: '1000000 QP'),
        const SizedBox(height: 8),
        SizedBox(width: double.infinity, child: OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(foregroundColor: kGoColor, side: const BorderSide(color: Color(0xFFE5E7EB))),
          child: const Text('Request Limit Increase'),
        )),
      ])),
      const SizedBox(height: 14),
      GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const GoSectionHeader(title: 'Danger Zone', icon: Icons.warning),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.lock_reset, color: kGoWarning, size: 20),
          title: const Text('Reset Security Settings', style: TextStyle(fontSize: 13)),
          dense: true, contentPadding: EdgeInsets.zero,
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.block, color: kGoNegative, size: 20),
          title: const Text('Freeze Account', style: TextStyle(fontSize: 13, color: kGoNegative)),
          dense: true, contentPadding: EdgeInsets.zero,
          onTap: () {},
        ),
      ])),
    ]);
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon; final String label; final String status; final bool isGood;
  const _StatusRow({required this.icon, required this.label, required this.status, required this.isGood});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE5E7EB))),
    child: Row(children: [
      Icon(icon, size: 20, color: kGoColor),
      const SizedBox(width: 10),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: (isGood ? kGoPositive : kGoWarning).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isGood ? kGoPositive : kGoWarning)),
      ),
    ]),
  );
}

class _RecommendCard extends StatelessWidget {
  final IconData icon; final String title; final String desc; final String action;
  const _RecommendCard({required this.icon, required this.title, required this.desc, required this.action});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: kGoWarning.withOpacity(0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: kGoWarning.withOpacity(0.2))),
    child: Row(children: [
      Icon(icon, size: 20, color: kGoWarning),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
      ])),
      TextButton(onPressed: () {}, child: Text(action, style: const TextStyle(fontSize: 11, color: kGoColor, fontWeight: FontWeight.w600))),
    ]),
  );
}

class _ToggleRow extends StatelessWidget {
  final String label; final bool value; final ValueChanged<bool> onChanged;
  const _ToggleRow({required this.label, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => SwitchListTile(
    title: Text(label, style: const TextStyle(fontSize: 13)),
    value: value, onChanged: onChanged, activeColor: kGoColor, dense: true, contentPadding: EdgeInsets.zero,
  );
}

class _LimitRow extends StatelessWidget {
  final String label; final String value;
  const _LimitRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)))),
      Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    ]),
  );
}
