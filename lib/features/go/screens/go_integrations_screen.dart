/// GO Screen 14 — Integrations Hub
/// Accounting, banking, business, custom integrations

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../models/go_models.dart';
import '../providers/go_provider.dart';
import '../widgets/go_widgets.dart';

class GoIntegrationsScreen extends StatefulWidget {
  const GoIntegrationsScreen({super.key});
  @override
  State<GoIntegrationsScreen> createState() => _GoIntegrationsScreenState();
}

class _GoIntegrationsScreenState extends State<GoIntegrationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() { super.initState(); _tabCtrl = TabController(length: 4, vsync: this); }
  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoProvider>(
      builder: (context, provider, _) {
        final integrations = provider.integrations;
        final connected = integrations.where((i) => i.status == IntegrationStatus.connected).length;
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: const GoAppBar(title: 'Integrations'),
          body: Column(
            children: [
              // Summary
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(children: [
                  _StatBadge(label: 'Connected', value: '$connected', color: kGoPositive),
                  const SizedBox(width: 8),
                  _StatBadge(label: 'Available', value: '${integrations.length - connected}', color: kGoInfo),
                  const SizedBox(width: 8),
                  _StatBadge(label: 'Total', value: '${integrations.length}', color: const Color(0xFF6B7280)),
                ]),
              ),
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
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabCtrl,
                  labelColor: kGoColor, unselectedLabelColor: const Color(0xFF9CA3AF),
                  indicatorColor: kGoColor, indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  isScrollable: true,
                  tabs: const [Tab(text: 'Accounting'), Tab(text: 'Banking'), Tab(text: 'Business'), Tab(text: 'Custom')],
                ),
              ),
              Expanded(
                child: TabBarView(controller: _tabCtrl, children: [
                  _buildCategoryList(integrations.where((i) => i.category == 'accounting').toList()),
                  _buildCategoryList(integrations.where((i) => i.category == 'banking').toList()),
                  _buildCategoryList(integrations.where((i) => i.category == 'business').toList()),
                  _buildCustomTab(),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryList(List<GoIntegration> items) {
    if (items.isEmpty) return const GoEmptyState(icon: Icons.extension, title: 'No integrations', message: 'Check back for new integrations.');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, i) => _IntegrationCard(integration: items[i]),
    );
  }

  Widget _buildCustomTab() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const GoSectionHeader(title: 'API Access', icon: Icons.code),
        const SizedBox(height: 10),
        const Text('Connect custom applications using our REST API.', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            const Expanded(child: Text('API Key: ••••••••••••a7f3', style: TextStyle(fontSize: 12, fontFamily: 'monospace'))),
            IconButton(icon: const Icon(Icons.copy, size: 16, color: kGoColor), onPressed: () {}),
          ]),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(foregroundColor: kGoColor, side: const BorderSide(color: Color(0xFFE5E7EB))),
            child: const Text('View Docs'),
          )),
          const SizedBox(width: 10),
          Expanded(child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(foregroundColor: kGoColor, side: const BorderSide(color: Color(0xFFE5E7EB))),
            child: const Text('Generate Key'),
          )),
        ]),
      ])),
      const SizedBox(height: 14),
      GoSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const GoSectionHeader(title: 'Webhooks', icon: Icons.webhook),
        const SizedBox(height: 10),
        const Text('Configure webhooks to receive real-time event notifications.', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Webhook'),
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: kGoColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        )),
      ])),
    ]);
  }
}

class _StatBadge extends StatelessWidget {
  final String label; final String value; final Color color;
  const _StatBadge({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
      ]),
    ),
  );
}

class _IntegrationCard extends StatelessWidget {
  final GoIntegration integration;
  const _IntegrationCard({required this.integration});

  @override
  Widget build(BuildContext context) {
    final connected = integration.status == IntegrationStatus.connected;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: kGoColorLight, borderRadius: BorderRadius.circular(10)),
            child: Icon(integration.icon, color: kGoColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(integration.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            Text(integration.description ?? '', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
            if (connected && integration.lastSync != null) ...[
              const SizedBox(height: 2),
              Text('Last sync: ${integration.lastSync!.day}/${integration.lastSync!.month}', style: const TextStyle(fontSize: 10, color: kGoPositive)),
            ],
          ])),
          Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: (connected ? kGoPositive : const Color(0xFF9CA3AF)).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(connected ? 'Connected' : 'Available', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: connected ? kGoPositive : const Color(0xFF9CA3AF))),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () {},
              child: Text(connected ? 'Manage' : 'Connect', style: const TextStyle(fontSize: 11, color: kGoColor, fontWeight: FontWeight.w600)),
            ),
          ]),
        ],
      ),
    );
  }
}
