/// Alerts Screen 4 — Alert Composer (Create New Alert)
/// Stepped wizard: Type → Describe → Assignment → Review
/// Admin/Branch Manager only

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alerts_models.dart';
import '../providers/alerts_provider.dart';
import '../widgets/alerts_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class AlertsComposerScreen extends StatefulWidget {
  const AlertsComposerScreen({super.key});

  @override
  State<AlertsComposerScreen> createState() => _AlertsComposerScreenState();
}

class _AlertsComposerScreenState extends State<AlertsComposerScreen> {
  int _step = 0;
  AlertCategory _category = AlertCategory.payment;
  AlertPriority _priority = AlertPriority.medium;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String? _selectedAssignee;
  final _tagsController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AlertsProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1A1A1A),
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('New Alert', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                Text(
                  'Step ${_step + 1} of 4 — ${_stepLabel(_step)}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
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
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kAlertsColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI: ${ai.insights.first['title'] ?? ''}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kAlertsColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // ──── STEP INDICATOR ────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Row(
                  children: List.generate(4, (i) => Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: i <= _step ? kAlertsColor : const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  )),
                ),
              ),

              // ──── STEP CONTENT ────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _buildStep(provider),
                  ),
                ),
              ),
            ],
          ),

          // ──── NAVIGATION FOOTER ────
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(top: BorderSide(color: Color(0xFFE5E7EB))),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _step--),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6B7280),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Back', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _step == 3 ? () => _submitAlert(context, provider) : () => setState(() => _step++),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _step == 3 ? kAlertsResolved : kAlertsColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        _step == 3 ? 'Create Alert' : 'Next',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStep(AlertsProvider provider) {
    switch (_step) {
      case 0: return _StepType(key: const ValueKey(0), category: _category, priority: _priority, onCategoryChanged: (v) => setState(() => _category = v), onPriorityChanged: (v) => setState(() => _priority = v));
      case 1: return _StepDescribe(key: const ValueKey(1), titleController: _titleController, descController: _descController, tagsController: _tagsController);
      case 2: return _StepAssignment(key: const ValueKey(2), staff: provider.staff, selectedAssignee: _selectedAssignee, onChanged: (v) => setState(() => _selectedAssignee = v));
      case 3: return _StepReview(key: const ValueKey(3), category: _category, priority: _priority, title: _titleController.text, description: _descController.text, assignee: _selectedAssignee, tags: _tagsController.text);
      default: return const SizedBox.shrink();
    }
  }

  String _stepLabel(int step) {
    switch (step) {
      case 0: return 'Type & Priority';
      case 1: return 'Describe Issue';
      case 2: return 'Assignment';
      case 3: return 'Review & Submit';
      default: return '';
    }
  }

  void _submitAlert(BuildContext context, AlertsProvider provider) {
    // In a real app, this would create and add the alert
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alert created successfully'),
        backgroundColor: kAlertsResolved,
      ),
    );
    Navigator.pop(context);
  }
}

// ──────────────────────────────────────────────
// Step 1: Type & Priority
// ──────────────────────────────────────────────

class _StepType extends StatelessWidget {
  final AlertCategory category;
  final AlertPriority priority;
  final ValueChanged<AlertCategory> onCategoryChanged;
  final ValueChanged<AlertPriority> onPriorityChanged;

  const _StepType({super.key, required this.category, required this.priority, required this.onCategoryChanged, required this.onPriorityChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category selection
        AlertsSectionCard(
          title: '📂 Issue Category',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AlertCategory.values.map((cat) {
              final isActive = category == cat;
              return GestureDetector(
                onTap: () => onCategoryChanged(cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive ? kAlertsColor.withOpacity(0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isActive ? kAlertsColor : const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_emoji(cat), style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(_label(cat), style: TextStyle(fontSize: 13, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400, color: isActive ? kAlertsColor : const Color(0xFF6B7280))),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Priority selection
        AlertsSectionCard(
          title: '🚩 Priority Level',
          child: Column(
            children: [
              _PriorityOption(label: '🚨 Critical — Immediate action required', value: AlertPriority.critical, current: priority, color: kAlertsCritical, onTap: () => onPriorityChanged(AlertPriority.critical)),
              _PriorityOption(label: '🔥 High — Needs urgent attention', value: AlertPriority.high, current: priority, color: kAlertsColor, onTap: () => onPriorityChanged(AlertPriority.high)),
              _PriorityOption(label: '⚠️ Medium — Standard response time', value: AlertPriority.medium, current: priority, color: kAlertsWarning, onTap: () => onPriorityChanged(AlertPriority.medium)),
              _PriorityOption(label: 'ℹ️ Low — Can be scheduled', value: AlertPriority.low, current: priority, color: kAlertsInfo, onTap: () => onPriorityChanged(AlertPriority.low)),
            ],
          ),
        ),
      ],
    );
  }

  String _emoji(AlertCategory c) {
    const map = { AlertCategory.payment: '💳', AlertCategory.shipment: '📦', AlertCategory.system: '⚙️', AlertCategory.driverRide: '🚗', AlertCategory.returnRefund: '↩️', AlertCategory.account: '👤', AlertCategory.security: '🔒', AlertCategory.other: '📋' };
    return map[c] ?? '📋';
  }

  String _label(AlertCategory c) {
    const map = { AlertCategory.payment: 'Payment', AlertCategory.shipment: 'Shipment', AlertCategory.system: 'System', AlertCategory.driverRide: 'Driver/Ride', AlertCategory.returnRefund: 'Return/Refund', AlertCategory.account: 'Account', AlertCategory.security: 'Security', AlertCategory.other: 'Other' };
    return map[c] ?? 'Other';
  }
}

class _PriorityOption extends StatelessWidget {
  final String label;
  final AlertPriority value;
  final AlertPriority current;
  final Color color;
  final VoidCallback onTap;

  const _PriorityOption({required this.label, required this.value, required this.current, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = value == current;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isActive ? color : const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(isActive ? Icons.radio_button_checked : Icons.radio_button_off, size: 18, color: isActive ? color : const Color(0xFF9CA3AF)),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400))),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Step 2: Describe
// ──────────────────────────────────────────────

class _StepDescribe extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descController;
  final TextEditingController tagsController;

  const _StepDescribe({super.key, required this.titleController, required this.descController, required this.tagsController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AlertsSectionCard(
          title: '✏️ Alert Details',
          child: Column(
            children: [
              _FormField(label: 'Title', hint: 'Brief, descriptive title...', controller: titleController),
              const SizedBox(height: 12),
              _FormField(label: 'Description', hint: 'Detailed description of the issue...', controller: descController, maxLines: 5),
              const SizedBox(height: 12),
              _FormField(label: 'Tags', hint: 'comma-separated tags (optional)', controller: tagsController),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Quick templates
        AlertsSectionCard(
          title: '📝 Quick Templates',
          child: Column(
            children: [
              _TemplateChip(label: 'Payment issue template', onTap: () {
                titleController.text = 'Payment Issue - ';
                descController.text = 'Customer reports a payment issue. Transaction ID: \nAmount: \nDetails: ';
              }),
              _TemplateChip(label: 'Shipment delay template', onTap: () {
                titleController.text = 'Shipment Delayed - Order #';
                descController.text = 'Order has been delayed beyond expected delivery date.\nTracking Number: \nExpected Date: \nCurrent Status: ';
              }),
              _TemplateChip(label: 'System issue template', onTap: () {
                titleController.text = 'System Issue - ';
                descController.text = 'System: \nImpact: \nStart Time: \nAffected Users: \nError Details: ';
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLines;

  const _FormField({required this.label, required this.hint, required this.controller, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(12),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}

class _TemplateChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _TemplateChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.description, size: 16, color: Color(0xFF9CA3AF)),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
            const Icon(Icons.add_circle_outline, size: 16, color: kAlertsInfo),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Step 3: Assignment
// ──────────────────────────────────────────────

class _StepAssignment extends StatelessWidget {
  final List<AlertStaffMember> staff;
  final String? selectedAssignee;
  final ValueChanged<String?> onChanged;

  const _StepAssignment({super.key, required this.staff, this.selectedAssignee, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AlertsSectionCard(
          title: '👤 Assign To',
          child: Column(
            children: [
              // Auto-assign option
              GestureDetector(
                onTap: () => onChanged(null),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selectedAssignee == null ? kAlertsColor.withOpacity(0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selectedAssignee == null ? kAlertsColor : const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 20, color: selectedAssignee == null ? kAlertsColor : const Color(0xFF9CA3AF)),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Auto-Assign', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            Text('System will assign based on rules', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 16),
              // Staff list
              ...staff.map((s) => StaffPickerTile(
                staff: s,
                isSelected: selectedAssignee == s.id,
                onTap: () => onChanged(s.id),
              )),
            ],
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Step 4: Review
// ──────────────────────────────────────────────

class _StepReview extends StatelessWidget {
  final AlertCategory category;
  final AlertPriority priority;
  final String title;
  final String description;
  final String? assignee;
  final String tags;

  const _StepReview({super.key, required this.category, required this.priority, required this.title, required this.description, this.assignee, required this.tags});

  @override
  Widget build(BuildContext context) {
    return AlertsSectionCard(
      title: '📋 Review Alert',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReviewRow(label: 'Category', value: '${_emoji(category)} ${_catLabel(category)}'),
          _ReviewRow(label: 'Priority', value: _priorityLabel(priority)),
          _ReviewRow(label: 'Title', value: title.isEmpty ? '(not set)' : title),
          const SizedBox(height: 8),
          const Text('Description', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
            child: Text(description.isEmpty ? '(not set)' : description, style: const TextStyle(fontSize: 13)),
          ),
          const SizedBox(height: 8),
          _ReviewRow(label: 'Assignment', value: assignee ?? 'Auto-assign'),
          if (tags.isNotEmpty) _ReviewRow(label: 'Tags', value: tags),
        ],
      ),
    );
  }

  String _emoji(AlertCategory c) {
    const map = { AlertCategory.payment: '💳', AlertCategory.shipment: '📦', AlertCategory.system: '⚙️', AlertCategory.driverRide: '🚗', AlertCategory.returnRefund: '↩️', AlertCategory.account: '👤', AlertCategory.security: '🔒', AlertCategory.other: '📋' };
    return map[c] ?? '📋';
  }

  String _catLabel(AlertCategory c) {
    const map = { AlertCategory.payment: 'Payment', AlertCategory.shipment: 'Shipment', AlertCategory.system: 'System', AlertCategory.driverRide: 'Driver/Ride', AlertCategory.returnRefund: 'Return/Refund', AlertCategory.account: 'Account', AlertCategory.security: 'Security', AlertCategory.other: 'Other' };
    return map[c] ?? 'Other';
  }

  String _priorityLabel(AlertPriority p) {
    switch (p) {
      case AlertPriority.critical: return '🚨 Critical';
      case AlertPriority.high: return '🔥 High';
      case AlertPriority.medium: return '⚠️ Medium';
      case AlertPriority.low: return 'ℹ️ Low';
    }
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
