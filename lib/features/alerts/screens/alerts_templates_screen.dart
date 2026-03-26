/// Alerts Screen 9 — Templates Library
/// Template grid (resolution/alert/communication/workflow),
/// variable support, version control

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alerts_models.dart';
import '../providers/alerts_provider.dart';
import '../widgets/alerts_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class AlertsTemplatesScreen extends StatefulWidget {
  const AlertsTemplatesScreen({super.key});

  @override
  State<AlertsTemplatesScreen> createState() => _AlertsTemplatesScreenState();
}

class _AlertsTemplatesScreenState extends State<AlertsTemplatesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AlertsProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: AlertsAppBar(
            title: 'Templates',
            actions: [
              IconButton(
                icon: const Icon(Icons.add, size: 22),
                onPressed: () => _showCreateTemplate(context),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: kAlertsColor,
              unselectedLabelColor: const Color(0xFF6B7280),
              indicatorColor: kAlertsColor,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(text: 'All (${provider.templates.length})'),
                Tab(text: '✅ Resolution (${provider.templatesByType(AlertTemplateType.resolution).length})'),
                Tab(text: '🚨 Alert (${provider.templatesByType(AlertTemplateType.alert).length})'),
                Tab(text: '📧 Comms (${provider.templatesByType(AlertTemplateType.communication).length})'),
                Tab(text: '🔄 Workflow (${provider.templatesByType(AlertTemplateType.workflow).length})'),
              ],
            ),
          ),
          body: Column(
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kAlertsColor.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(children: [
                      const Icon(Icons.auto_awesome, size: 14, color: kAlertsColor),
                      const SizedBox(width: 8),
                      Expanded(child: Text('AI: ${ai.insights.first['title'] ?? ''}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kAlertsColor),
                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                  );
                },
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _TemplateList(templates: provider.templates),
                    _TemplateList(templates: provider.templatesByType(AlertTemplateType.resolution)),
                    _TemplateList(templates: provider.templatesByType(AlertTemplateType.alert)),
                    _TemplateList(templates: provider.templatesByType(AlertTemplateType.communication)),
                    _TemplateList(templates: provider.templatesByType(AlertTemplateType.workflow)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCreateTemplate(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)))),
              const Text('Create Template', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Template Name',
                  hintText: 'e.g., Quick Refund Resolution',
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Template Content',
                  hintText: 'Use \${variable} for dynamic fields...',
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Template created'), backgroundColor: kAlertsResolved),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAlertsColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Create', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Template List
// ──────────────────────────────────────────────

class _TemplateList extends StatelessWidget {
  final List<AlertTemplate> templates;
  const _TemplateList({required this.templates});

  @override
  Widget build(BuildContext context) {
    if (templates.isEmpty) {
      return const AlertsEmptyState(
        icon: Icons.description,
        title: 'No Templates',
        message: 'Create your first template to get started.',
        actionLabel: 'Create Template',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final tpl = templates[index];
        return _ExpandableTemplateCard(template: tpl);
      },
    );
  }
}

// ──────────────────────────────────────────────
// Expandable Template Card
// ──────────────────────────────────────────────

class _ExpandableTemplateCard extends StatefulWidget {
  final AlertTemplate template;
  const _ExpandableTemplateCard({required this.template});

  @override
  State<_ExpandableTemplateCard> createState() => _ExpandableTemplateCardState();
}

class _ExpandableTemplateCardState extends State<_ExpandableTemplateCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(widget.template.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                      Text(widget.template.typeLabel, style: const TextStyle(fontSize: 11)),
                      const SizedBox(width: 8),
                      Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 20, color: const Color(0xFF9CA3AF)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (widget.template.variables.isNotEmpty) ...[
                        const Icon(Icons.data_object, size: 12, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 4),
                        Text('${widget.template.variables.length} vars', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                        const SizedBox(width: 12),
                      ],
                      const Icon(Icons.repeat, size: 12, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 4),
                      Text('${widget.template.usageCount} uses', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                      const Spacer(),
                      Text('by ${widget.template.createdBy}', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Content', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(widget.template.content, style: const TextStyle(fontSize: 13, height: 1.5)),
                  ),
                  if (widget.template.variables.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text('Variables', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: widget.template.variables.map((v) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: kAlertsCriticalLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('\${$v}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kAlertsCritical)),
                      )).toList(),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('Copy'),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Template copied to clipboard'), backgroundColor: kAlertsResolved));
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kAlertsColor,
                            side: const BorderSide(color: kAlertsColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit'),
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF6B7280),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
