/// Alerts Screen 5 — Resolution Workspace
/// Method selection, templates, composer, verification panel

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alerts_models.dart';
import '../providers/alerts_provider.dart';
import '../widgets/alerts_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class AlertsResolutionScreen extends StatefulWidget {
  final String alertId;
  const AlertsResolutionScreen({super.key, required this.alertId});

  @override
  State<AlertsResolutionScreen> createState() => _AlertsResolutionScreenState();
}

class _AlertsResolutionScreenState extends State<AlertsResolutionScreen> {
  ResolutionMethod _method = ResolutionMethod.fixed;
  final _summaryController = TextEditingController();
  final _rootCauseController = TextEditingController();
  final _preventionController = TextEditingController();
  CustomerNotifyMethod _notifyMethod = CustomerNotifyMethod.email;
  bool _showTemplates = false;

  @override
  void dispose() {
    _summaryController.dispose();
    _rootCauseController.dispose();
    _preventionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AlertsProvider>(
      builder: (context, provider, _) {
        final alert = provider.getAlertById(widget.alertId);
        if (alert == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Resolve')),
            body: const AlertsEmptyState(icon: Icons.error_outline, title: 'Alert Not Found', message: 'Cannot find the alert to resolve.'),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: AlertsAppBar(
            title: 'Resolve #${alert.id}',
            actions: [
              IconButton(
                icon: Icon(_showTemplates ? Icons.edit_note : Icons.description, size: 22),
                onPressed: () => setState(() => _showTemplates = !_showTemplates),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                // ──── ALERT CONTEXT ────
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kAlertsColorLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kAlertsColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Text(alert.categoryEmoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(alert.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            Text(alert.priorityLabel, style: TextStyle(fontSize: 12, color: _priorityColor(alert.priority))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ──── TEMPLATES (TOGGLE) ────
                if (_showTemplates) ...[
                  AlertsSectionCard(
                    title: '📝 Resolution Templates',
                    child: Column(
                      children: provider.templatesByType(AlertTemplateType.resolution).map((tpl) => GestureDetector(
                        onTap: () {
                          _summaryController.text = tpl.content;
                          setState(() => _showTemplates = false);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.description, size: 16, color: kAlertsResolved),
                              const SizedBox(width: 8),
                              Expanded(child: Text(tpl.name, style: const TextStyle(fontSize: 13))),
                              const Icon(Icons.add_circle_outline, size: 16, color: kAlertsInfo),
                            ],
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ──── RESOLUTION METHOD ────
                AlertsSectionCard(
                  title: '🔧 Resolution Method',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ResolutionMethod.values.map((m) {
                      final isActive = _method == m;
                      return GestureDetector(
                        onTap: () => setState(() => _method = m),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isActive ? kAlertsResolved.withOpacity(0.1) : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isActive ? kAlertsResolved : const Color(0xFFE5E7EB)),
                          ),
                          child: Text(_methodLabel(m), style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400, color: isActive ? kAlertsResolved : const Color(0xFF6B7280))),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // ──── RESOLUTION DETAILS ────
                AlertsSectionCard(
                  title: '✍️ Resolution Details',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Summary *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _summaryController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Describe how the issue was resolved...',
                          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                          filled: true,
                          fillColor: const Color(0xFFF3F4F6),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      const Text('Root Cause', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _rootCauseController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'What caused this issue?',
                          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                          filled: true,
                          fillColor: const Color(0xFFF3F4F6),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      const Text('Prevention Measures', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _preventionController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'How can this be prevented?',
                          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                          filled: true,
                          fillColor: const Color(0xFFF3F4F6),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ──── CUSTOMER NOTIFICATION ────
                AlertsSectionCard(
                  title: '📨 Customer Notification',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: CustomerNotifyMethod.values.map((m) {
                      final isActive = _notifyMethod == m;
                      return GestureDetector(
                        onTap: () => setState(() => _notifyMethod = m),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isActive ? kAlertsInfo.withOpacity(0.1) : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isActive ? kAlertsInfo : const Color(0xFFE5E7EB)),
                          ),
                          child: Text(_notifyLabel(m), style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400, color: isActive ? kAlertsInfo : const Color(0xFF6B7280))),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // ──── KNOWLEDGE BASE SUGGESTION ────
                AlertsSectionCard(
                  title: '💡 Related Knowledge',
                  trailing: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/alerts/knowledge', arguments: alert.id),
                    child: const Text('View All', style: TextStyle(fontSize: 12, color: kAlertsInfo)),
                  ),
                  child: Column(
                    children: provider.knowledgeForAlert(alert).take(2).map((kb) => KnowledgeItemCard(item: kb)).toList(),
                  ),
                ),

                const SizedBox(height: 80), // space for bottom bar
              ],
            ),
          ),

          // ──── SUBMIT FOOTER ────
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(top: BorderSide(color: Color(0xFFE5E7EB))),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: () => _submit(context, provider, alert),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAlertsResolved,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Submit Resolution', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              ),
            ),
          ),
        );
      },
    );
  }

  void _submit(BuildContext context, AlertsProvider provider, AlertItem alert) {
    if (_summaryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a resolution summary'), backgroundColor: kAlertsWarning),
      );
      return;
    }

    final resolution = AlertResolution(
      method: _method,
      summary: _summaryController.text,
      rootCause: _rootCauseController.text.isNotEmpty ? _rootCauseController.text : null,
      preventionMeasures: _preventionController.text.isNotEmpty ? _preventionController.text : null,
      resolverName: alert.assigneeName ?? 'You',
      resolvedAt: DateTime.now(),
      customerNotified: _notifyMethod,
    );

    provider.resolveAlert(alert.id, resolution);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alert resolved successfully! ✅'), backgroundColor: kAlertsResolved),
    );
    Navigator.popUntil(context, (route) => route.settings.name == '/alerts' || route.isFirst);
  }

  Color _priorityColor(AlertPriority p) {
    switch (p) {
      case AlertPriority.critical: return kAlertsCritical;
      case AlertPriority.high: return kAlertsColor;
      case AlertPriority.medium: return kAlertsWarning;
      case AlertPriority.low: return kAlertsInfo;
    }
  }

  String _methodLabel(ResolutionMethod m) {
    switch (m) {
      case ResolutionMethod.fixed: return '✅ Fixed';
      case ResolutionMethod.workaround: return '🔧 Workaround';
      case ResolutionMethod.cannotReproduce: return '❓ Can\'t Reproduce';
      case ResolutionMethod.duplicate: return '📋 Duplicate';
      case ResolutionMethod.byDesign: return '📐 By Design';
      case ResolutionMethod.wontFix: return '🚫 Won\'t Fix';
    }
  }

  String _notifyLabel(CustomerNotifyMethod m) {
    switch (m) {
      case CustomerNotifyMethod.sms: return '📱 SMS';
      case CustomerNotifyMethod.email: return '📧 Email';
      case CustomerNotifyMethod.inApp: return '🔔 In-App';
      case CustomerNotifyMethod.none: return '🔇 None';
    }
  }
}
