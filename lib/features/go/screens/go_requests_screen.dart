/// GO Screen 6 — Request Center
/// 3-tab interface: My Requests, Pending Approval, Templates
/// 8 request types, creation flow, status pipeline

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/go_models.dart';
import '../providers/go_provider.dart';
import '../widgets/go_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class GoRequestsScreen extends StatefulWidget {
  const GoRequestsScreen({super.key});
  @override
  State<GoRequestsScreen> createState() => _GoRequestsScreenState();
}

class _GoRequestsScreenState extends State<GoRequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  RequestType? _typeFilter;
  bool _showCreate = false;

  @override
  void initState() { super.initState(); _tabCtrl = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoProvider>(
      builder: (context, provider, _) {
        final myReqs = provider.requests;
        final pending = provider.requests.where((r) => r.status == RequestStatus.submitted).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: const GoAppBar(title: 'Request Center'),
          body: Column(
            children: [
              // Summary strip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Colors.white,
                child: Row(children: [
                  _CountBadge(label: 'Sent', count: myReqs.length, color: kGoColor),
                  const SizedBox(width: 8),
                  _CountBadge(label: 'Pending', count: pending.length, color: kGoWarning),
                  const SizedBox(width: 8),
                  _CountBadge(label: 'Approved', count: myReqs.where((r) => r.status == RequestStatus.approved).length, color: kGoPositive),
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
                  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  tabs: const [Tab(text: 'My Requests'), Tab(text: 'Pending'), Tab(text: 'Templates')],
                ),
              ),
              // Type filters
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  children: [
                    _FilterChip(label: 'All', selected: _typeFilter == null, onTap: () => setState(() => _typeFilter = null)),
                    ...RequestType.values.map((t) => _FilterChip(label: t.name[0].toUpperCase() + t.name.substring(1), selected: _typeFilter == t, onTap: () => setState(() => _typeFilter = t))),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _buildRequestList(_typeFilter == null ? myReqs : myReqs.where((r) => r.type == _typeFilter).toList()),
                    _buildRequestList(pending),
                    _buildTemplates(),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => setState(() => _showCreate = !_showCreate),
            backgroundColor: kGoColor,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('New Request', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          bottomSheet: _showCreate ? _buildCreateSheet() : null,
        );
      },
    );
  }

  Widget _buildRequestList(List<GoRequest> reqs) {
    if (reqs.isEmpty) return const GoEmptyState(icon: Icons.inbox, title: 'No requests', message: 'Create a new request to get started.');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reqs.length,
      itemBuilder: (_, i) => GoRequestCard(request: reqs[i], onTap: () {}),
    );
  }

  Widget _buildTemplates() {
    final templates = [
      ('Payment Request', Icons.payments, 'Request payment from a party'),
      ('Refund Request', Icons.replay, 'Request refund for a transaction'),
      ('Credit Extension', Icons.credit_card, 'Request credit limit increase'),
      ('Account Linking', Icons.link, 'Link external account'),
      ('Rate Lock', Icons.lock_clock, 'Lock in exchange rate'),
      ('Bulk Transfer', Icons.group, 'Multi-party transfer request'),
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: templates.length,
      itemBuilder: (_, i) {
        final t = templates[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
          child: ListTile(
            leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: kGoColorLight, borderRadius: BorderRadius.circular(8)), child: Icon(t.$2, color: kGoColor, size: 20)),
            title: Text(t.$1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: Text(t.$3, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFD1D5DB)),
            onTap: () {},
          ),
        );
      },
    );
  }

  Widget _buildCreateSheet() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('New Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const Spacer(),
          IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => setState(() => _showCreate = false)),
        ]),
        const SizedBox(height: 10),
        const Text('Select request type:', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        const SizedBox(height: 10),
        Expanded(
          child: GridView.count(
            crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 0.9,
            children: RequestType.values.map((t) => GestureDetector(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(color: kGoColorLight, borderRadius: BorderRadius.circular(10)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(_typeIcon(t), color: kGoColor, size: 22),
                  const SizedBox(height: 4),
                  Text(t.name, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
            )).toList(),
          ),
        ),
      ]),
    );
  }

  IconData _typeIcon(RequestType t) {
    switch (t) {
      case RequestType.creditLimitChange: return Icons.payments;
      case RequestType.tabClosure: return Icons.replay;
      case RequestType.paymentExtension: return Icons.credit_card;
      case RequestType.disputeFiling: return Icons.gavel;
      case RequestType.termsModification: return Icons.swap_horiz;
      case RequestType.newTab: return Icons.verified;
      case RequestType.documentRequest: return Icons.description;
      case RequestType.relationshipChange: return Icons.more_horiz;
    }
  }
}

class _CountBadge extends StatelessWidget {
  final String label; final int count; final Color color;
  const _CountBadge({required this.label, required this.count, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
      child: Column(children: [
        Text('$count', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
      ]),
    ),
  );
}

class _FilterChip extends StatelessWidget {
  final String label; final bool selected; final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 6),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: selected ? kGoColor : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: selected ? kGoColor : const Color(0xFFE5E7EB))),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: selected ? Colors.white : const Color(0xFF6B7280))),
      ),
    ),
  );
}
