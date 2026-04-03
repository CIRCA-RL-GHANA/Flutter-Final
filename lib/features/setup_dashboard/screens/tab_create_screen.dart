/// ═══════════════════════════════════════════════════════════════════════════
/// SD1.3-CREATE: TAB CREATE WIZARD — 4-Step Form
/// Steps: Customer → Credit Settings → Payment Terms → Review
/// RBAC: Admin(full), BM(branch), SO(full), BSO(branch)
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../prompt/providers/context_provider.dart';
import '../providers/setup_dashboard_provider.dart';
import '../widgets/shared_widgets.dart';

class TabCreateScreen extends StatefulWidget {
  const TabCreateScreen({super.key});

  @override
  State<TabCreateScreen> createState() => _TabCreateScreenState();
}

class _TabCreateScreenState extends State<TabCreateScreen> {
  int _currentStep = 0;
  static const _stepCount = 4;
  static const _stepLabels = ['Customer', 'Credit Settings', 'Payment Terms', 'Review'];

  // Form state
  final _customerNameCtrl = TextEditingController();
  final _customerPhoneCtrl = TextEditingController();
  final _customerEmailCtrl = TextEditingController();
  final _creditLimitCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _customerType = 'Individual';
  int _paymentDays = 30;
  bool _autoReminders = true;
  bool _requireApproval = false;
  String _interestRate = 'None';

  @override
  void dispose() {
    _customerNameCtrl.dispose();
    _customerPhoneCtrl.dispose();
    _customerEmailCtrl.dispose();
    _creditLimitCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _stepCount - 1) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Customer tab created successfully!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FC),
          appBar: SetupAppBar(
            title: 'New Tab',
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ],
          ),
          body: Column(
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kSetupColor.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kSetupColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI: ${ai.insights.first[\'title\'] ?? \'\'}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kSetupColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              _TabStepIndicator(
                currentStep: _currentStep,
                stepCount: _stepCount,
                labels: _stepLabels,
              ),
              Expanded(
                child: IndexedStack(
                  index: _currentStep,
                  children: [
                    _CustomerStep(
                      nameCtrl: _customerNameCtrl,
                      phoneCtrl: _customerPhoneCtrl,
                      emailCtrl: _customerEmailCtrl,
                      customerType: _customerType,
                      onTypeChanged: (v) => setState(() => _customerType = v),
                    ),
                    _CreditSettingsStep(
                      creditLimitCtrl: _creditLimitCtrl,
                      interestRate: _interestRate,
                      requireApproval: _requireApproval,
                      onInterestChanged: (v) => setState(() => _interestRate = v),
                      onApprovalChanged: (v) => setState(() => _requireApproval = v),
                    ),
                    _PaymentTermsStep(
                      paymentDays: _paymentDays,
                      autoReminders: _autoReminders,
                      notesCtrl: _notesCtrl,
                      onDaysChanged: (v) => setState(() => _paymentDays = v),
                      onRemindersChanged: (v) => setState(() => _autoReminders = v),
                    ),
                    _TabReviewStep(
                      customerName: _customerNameCtrl.text,
                      customerType: _customerType,
                      creditLimit: _creditLimitCtrl.text,
                      paymentDays: _paymentDays,
                      interestRate: _interestRate,
                      autoReminders: _autoReminders,
                    ),
                  ],
                ),
              ),
              _TabNavBar(
                currentStep: _currentStep,
                stepCount: _stepCount,
                onNext: _nextStep,
                onPrev: _prevStep,
                onSubmit: _submit,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Step Indicator ──────────────────────────────────────────────────────────

class _TabStepIndicator extends StatelessWidget {
  final int currentStep;
  final int stepCount;
  final List<String> labels;

  const _TabStepIndicator({
    required this.currentStep,
    required this.stepCount,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (currentStep + 1) / stepCount,
              backgroundColor: kSetupColor.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(kSetupColor),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${currentStep + 1} of $stepCount',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kSetupColor),
              ),
              Text(
                labels[currentStep],
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Step 1: Customer ────────────────────────────────────────────────────────

class _CustomerStep extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController emailCtrl;
  final String customerType;
  final ValueChanged<String> onTypeChanged;

  const _CustomerStep({
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.emailCtrl,
    required this.customerType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // Customer Type
        const Text(
          'Customer Type',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Row(
          children: ['Individual', 'Business'].map((t) {
            final isSelected = customerType == t;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: t == 'Individual' ? 5 : 0, left: t == 'Business' ? 5 : 0),
                child: InkWell(
                  onTap: () => onTypeChanged(t),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? kSetupColor.withOpacity(0.08) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? kSetupColor.withOpacity(0.3) : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          t == 'Individual' ? Icons.person : Icons.business,
                          color: isSelected ? kSetupColor : AppColors.textTertiary,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? kSetupColor : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        SetupFormField(
          label: customerType == 'Individual' ? 'Full Name' : 'Business Name',
          hint: customerType == 'Individual' ? 'Enter customer name' : 'Enter business name',
          controller: nameCtrl,
        ),
        const SizedBox(height: 14),
        SetupFormField(
          label: 'Phone Number',
          hint: 'e.g., 024 123 4567',
          controller: phoneCtrl,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 14),
        SetupFormField(
          label: 'Email',
          hint: 'e.g., user@email.com',
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ─── Step 2: Credit Settings ─────────────────────────────────────────────────

class _CreditSettingsStep extends StatelessWidget {
  final TextEditingController creditLimitCtrl;
  final String interestRate;
  final bool requireApproval;
  final ValueChanged<String> onInterestChanged;
  final ValueChanged<bool> onApprovalChanged;

  const _CreditSettingsStep({
    required this.creditLimitCtrl,
    required this.interestRate,
    required this.requireApproval,
    required this.onInterestChanged,
    required this.onApprovalChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        SetupFormField(
          label: 'Credit Limit (₵)',
          hint: '0.00',
          controller: creditLimitCtrl,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 14),

        // Interest Rate
        const Text(
          'Interest Rate',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: interestRate,
              items: ['None', '1% monthly', '2% monthly', '5% monthly', 'Custom']
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) {
                if (v != null) onInterestChanged(v);
              },
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Approval toggle
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Require Manager Approval',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    const Text(
                      'Purchases above limit need authorization',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Switch(
                value: requireApproval,
                onChanged: onApprovalChanged,
                activeColor: kSetupColor,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning.withOpacity(0.15)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber, size: 18, color: AppColors.warning),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Setting a credit limit establishes financial liability. Ensure the customer\'s creditworthiness has been verified.',
                  style: TextStyle(fontSize: 12, color: AppColors.warning),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ─── Step 3: Payment Terms ───────────────────────────────────────────────────

class _PaymentTermsStep extends StatelessWidget {
  final int paymentDays;
  final bool autoReminders;
  final TextEditingController notesCtrl;
  final ValueChanged<int> onDaysChanged;
  final ValueChanged<bool> onRemindersChanged;

  const _PaymentTermsStep({
    required this.paymentDays,
    required this.autoReminders,
    required this.notesCtrl,
    required this.onDaysChanged,
    required this.onRemindersChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const Text(
          'Payment Period',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [7, 14, 30, 60, 90].map((d) {
            final isSelected = paymentDays == d;
            return InkWell(
              onTap: () => onDaysChanged(d),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? kSetupColor.withOpacity(0.08) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? kSetupColor.withOpacity(0.3) : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  'Net $d',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? kSetupColor : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Auto reminders
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Automatic Reminders',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    const Text(
                      'Send SMS/email reminders before due date',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Switch(
                value: autoReminders,
                onChanged: onRemindersChanged,
                activeColor: kSetupColor,
              ),
            ],
          ),
        ),

        if (autoReminders) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reminder Schedule',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.info),
                ),
                const SizedBox(height: 4),
                Text(
                  '• 5 days before due date\n• On due date\n• 3 days after due date (overdue)',
                  style: TextStyle(fontSize: 11, color: AppColors.info.withOpacity(0.8)),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 14),
        SetupFormField(
          label: 'Notes',
          hint: 'Any special payment arrangements...',
          controller: notesCtrl,
          maxLines: 3,
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ─── Step 4: Review ──────────────────────────────────────────────────────────

class _TabReviewStep extends StatelessWidget {
  final String customerName;
  final String customerType;
  final String creditLimit;
  final int paymentDays;
  final String interestRate;
  final bool autoReminders;

  const _TabReviewStep({
    required this.customerName,
    required this.customerType,
    required this.creditLimit,
    required this.paymentDays,
    required this.interestRate,
    required this.autoReminders,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kSetupColor.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kSetupColor.withOpacity(0.15)),
          ),
          child: const Row(
            children: [
              Icon(Icons.check_circle, size: 18, color: kSetupColor),
              SizedBox(width: 10),
              Text(
                'Review tab details before creating',
                style: TextStyle(fontSize: 12, color: kSetupColor, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SetupSectionTitle(title: 'Customer Details', icon: Icons.person),
              SetupInfoRow(label: 'Name', value: customerName.isNotEmpty ? customerName : '—'),
              SetupInfoRow(label: 'Type', value: customerType),
            ],
          ),
        ),

        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SetupSectionTitle(title: 'Credit & Payment', icon: Icons.credit_card),
              SetupInfoRow(label: 'Credit Limit', value: creditLimit.isNotEmpty ? '₵$creditLimit' : '—'),
              SetupInfoRow(label: 'Payment Terms', value: 'Net $paymentDays'),
              SetupInfoRow(label: 'Interest', value: interestRate),
              SetupInfoRow(label: 'Reminders', value: autoReminders ? 'Enabled' : 'Disabled'),
            ],
          ),
        ),

        // Risk estimate
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.success.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.shield, size: 18, color: AppColors.success),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Risk Assessment: Low',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success),
                    ),
                    Text(
                      'Based on credit limit and payment terms',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ─── Nav Bar ─────────────────────────────────────────────────────────────────

class _TabNavBar extends StatelessWidget {
  final int currentStep;
  final int stepCount;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final VoidCallback onSubmit;

  const _TabNavBar({
    required this.currentStep,
    required this.stepCount,
    required this.onNext,
    required this.onPrev,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isFirst = currentStep == 0;
    final isLast = currentStep == stepCount - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (!isFirst)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPrev,
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            if (!isFirst) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isLast ? onSubmit : onNext,
                icon: Icon(isLast ? Icons.check : Icons.arrow_forward, size: 18),
                label: Text(isLast ? 'Create Tab' : 'Continue'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLast ? AppColors.success : kSetupColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
