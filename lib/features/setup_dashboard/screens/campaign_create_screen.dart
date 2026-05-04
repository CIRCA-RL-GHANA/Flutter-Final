/// ═══════════════════════════════════════════════════════════════════════════
/// SD1.10-CREATE: CAMPAIGN CREATE WIZARD — 5-Step Form
/// Steps: Type → Audience → Budget → Content → Review
/// RBAC: Admin(full), BM(branch), SO(full), BSO(branch)
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../prompt/providers/context_provider.dart';
import '../models/setup_dashboard_models.dart';
import '../providers/setup_dashboard_provider.dart';
import '../widgets/shared_widgets.dart';

class CampaignCreateScreen extends StatefulWidget {
  const CampaignCreateScreen({super.key});

  @override
  State<CampaignCreateScreen> createState() => _CampaignCreateScreenState();
}

class _CampaignCreateScreenState extends State<CampaignCreateScreen> {
  int _currentStep = 0;
  static const _stepCount = 5;
  static const _stepLabels = ['Type', 'Audience', 'Budget', 'Content', 'Review'];

  // Form state
  // ignore: unused_field
  String _campaignName = '';
  CampaignType _type = CampaignType.discount;
  CampaignGoal _goal = CampaignGoal.brandAwareness;
  final _nameCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _headlineCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  final Set<String> _selectedAudiences = {'All Customers'};
  String _selectedChannel = 'All Channels';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _budgetCtrl.dispose();
    _headlineCtrl.dispose();
    _bodyCtrl.dispose();
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
        content: const Text('Campaign created successfully!'),
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
            title: 'New Campaign',
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
                            "AI: ${ai.insights.first['title'] ?? ''}",
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kSetupColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              _CampaignStepIndicator(
                currentStep: _currentStep,
                stepCount: _stepCount,
                labels: _stepLabels,
              ),
              Expanded(
                child: IndexedStack(
                  index: _currentStep,
                  children: [
                    _TypeStep(
                      nameCtrl: _nameCtrl,
                      type: _type,
                      goal: _goal,
                      onTypeChanged: (v) => setState(() => _type = v),
                      onGoalChanged: (v) => setState(() => _goal = v),
                    ),
                    _AudienceStep(
                      selectedAudiences: _selectedAudiences,
                      onToggle: (a) => setState(() {
                        if (_selectedAudiences.contains(a)) {
                          _selectedAudiences.remove(a);
                        } else {
                          _selectedAudiences.add(a);
                        }
                      }),
                    ),
                    _BudgetStep(
                      budgetCtrl: _budgetCtrl,
                      startDate: _startDate,
                      endDate: _endDate,
                      channel: _selectedChannel,
                      onStartChanged: (d) => setState(() => _startDate = d),
                      onEndChanged: (d) => setState(() => _endDate = d),
                      onChannelChanged: (c) => setState(() => _selectedChannel = c),
                    ),
                    _ContentStep(
                      headlineCtrl: _headlineCtrl,
                      bodyCtrl: _bodyCtrl,
                    ),
                    _CampaignReviewStep(
                      name: _nameCtrl.text,
                      type: _type,
                      goal: _goal,
                      budget: _budgetCtrl.text,
                      audiences: _selectedAudiences,
                      channel: _selectedChannel,
                    ),
                  ],
                ),
              ),
              _CampaignNavBar(
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

class _CampaignStepIndicator extends StatelessWidget {
  final int currentStep;
  final int stepCount;
  final List<String> labels;

  const _CampaignStepIndicator({
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

// ─── Step 1: Type ────────────────────────────────────────────────────────────

class _TypeStep extends StatelessWidget {
  final TextEditingController nameCtrl;
  final CampaignType type;
  final CampaignGoal goal;
  final ValueChanged<CampaignType> onTypeChanged;
  final ValueChanged<CampaignGoal> onGoalChanged;

  const _TypeStep({
    required this.nameCtrl,
    required this.type,
    required this.goal,
    required this.onTypeChanged,
    required this.onGoalChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        SetupFormField(
          label: 'Campaign Name',
          hint: 'Enter a memorable name',
          controller: nameCtrl,
        ),
        const SizedBox(height: 16),
        const Text(
          'Campaign Type',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        ...CampaignType.values.map((t) => _SelectionTile(
              title: t.name[0].toUpperCase() + t.name.substring(1),
              icon: _typeIcon(t),
              isSelected: type == t,
              onTap: () => onTypeChanged(t),
            )),
        const SizedBox(height: 16),
        const Text(
          'Campaign Goal',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        ...CampaignGoal.values.map((g) => _SelectionTile(
              title: g.name[0].toUpperCase() + g.name.substring(1),
              icon: _goalIcon(g),
              isSelected: goal == g,
              onTap: () => onGoalChanged(g),
            )),
        const SizedBox(height: 40),
      ],
    );
  }

  IconData _typeIcon(CampaignType t) {
    switch (t) {
      case CampaignType.discount:
        return Icons.local_offer;
      case CampaignType.email:
        return Icons.email;
      case CampaignType.socialMedia:
        return Icons.share;
      case CampaignType.sms:
        return Icons.sms;
      case CampaignType.push:
        return Icons.notifications;
      case CampaignType.multiChannel:
        return Icons.campaign;
    }
  }

  IconData _goalIcon(CampaignGoal g) {
    switch (g) {
      case CampaignGoal.increaseSales:
        return Icons.shopping_cart;
      case CampaignGoal.brandAwareness:
        return Icons.visibility;
      case CampaignGoal.customerRetention:
        return Icons.people;
      case CampaignGoal.productLaunch:
        return Icons.rocket_launch;
    }
  }
}

// ─── Step 2: Audience ────────────────────────────────────────────────────────

class _AudienceStep extends StatelessWidget {
  final Set<String> selectedAudiences;
  final ValueChanged<String> onToggle;

  const _AudienceStep({
    required this.selectedAudiences,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final audiences = [
      {'name': 'All Customers', 'count': '12,450', 'icon': Icons.people},
      {'name': 'Loyal Customers', 'count': '3,280', 'icon': Icons.favorite},
      {'name': 'New Customers (30d)', 'count': '890', 'icon': Icons.person_add},
      {'name': 'High Spenders', 'count': '1,520', 'icon': Icons.monetization_on},
      {'name': 'Inactive (90d+)', 'count': '2,340', 'icon': Icons.person_off},
      {'name': 'VIP Members', 'count': '450', 'icon': Icons.star},
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kSetupColor.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.people, size: 20, color: kSetupColor),
              const SizedBox(width: 10),
              Text(
                '${selectedAudiences.length} segment(s) selected',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kSetupColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...audiences.map((a) {
          final name = a['name'] as String;
          final count = a['count'] as String;
          final icon = a['icon'] as IconData;
          final isSelected = selectedAudiences.contains(name);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => onToggle(name),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? kSetupColor.withOpacity(0.06) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? kSetupColor.withOpacity(0.3) : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 22, color: isSelected ? kSetupColor : AppColors.textTertiary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? kSetupColor : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '$count potential reach',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) => onToggle(name),
                      activeColor: kSetupColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ─── Step 3: Budget ──────────────────────────────────────────────────────────

class _BudgetStep extends StatelessWidget {
  final TextEditingController budgetCtrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final String channel;
  final ValueChanged<DateTime> onStartChanged;
  final ValueChanged<DateTime> onEndChanged;
  final ValueChanged<String> onChannelChanged;

  const _BudgetStep({
    required this.budgetCtrl,
    required this.startDate,
    required this.endDate,
    required this.channel,
    required this.onStartChanged,
    required this.onEndChanged,
    required this.onChannelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        SetupFormField(
          label: 'Total Budget (₵)',
          hint: '0.00',
          controller: budgetCtrl,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 14),

        // Date range
        const Text(
          'Schedule',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _DatePickerTile(
                label: 'Start Date',
                date: startDate,
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (d != null) onStartChanged(d);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DatePickerTile(
                label: 'End Date',
                date: endDate,
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: startDate ?? DateTime.now(),
                    firstDate: startDate ?? DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (d != null) onEndChanged(d);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Channel selection
        const Text(
          'Distribution Channel',
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
              value: channel,
              items: ['All Channels', 'Email', 'SMS', 'Push Notification', 'In-App', 'Social Media']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                if (v != null) onChannelChanged(v);
              },
            ),
          ),
        ),

        const SizedBox(height: 16),
        // Budget estimates
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.info.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.analytics, size: 16, color: AppColors.info),
                  SizedBox(width: 6),
                  Text('Estimated Performance', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.info)),
                ],
              ),
              const SizedBox(height: 8),
              const SetupInfoRow(label: 'Est. Reach', value: '5,000 – 12,000'),
              const SetupInfoRow(label: 'Est. Clicks', value: '250 – 600'),
              const SetupInfoRow(label: 'Est. Cost/Click', value: '₵0.15 – ₵0.40'),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ─── Step 4: Content ─────────────────────────────────────────────────────────

class _ContentStep extends StatelessWidget {
  final TextEditingController headlineCtrl;
  final TextEditingController bodyCtrl;

  const _ContentStep({
    required this.headlineCtrl,
    required this.bodyCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        SetupFormField(
          label: 'Headline',
          hint: 'Write an attention-grabbing headline',
          controller: headlineCtrl,
        ),
        const SizedBox(height: 14),
        SetupFormField(
          label: 'Body Copy',
          hint: 'Write your campaign message...',
          controller: bodyCtrl,
          maxLines: 6,
        ),
        const SizedBox(height: 16),

        // Creative upload
        const Text(
          'Creative Assets',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kSetupColor.withOpacity(0.3)),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_upload_outlined, size: 36, color: kSetupColor.withOpacity(0.4)),
                const SizedBox(height: 8),
                const Text(
                  'Upload banner or creative',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  'PNG, JPG · Recommended 1200×628',
                  style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),
        // CTA button
        const Text(
          'Call-to-Action',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Shop Now', 'Learn More', 'Sign Up', 'Book Now', 'Get Offer'].map((cta) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                cta,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ─── Step 5: Review ──────────────────────────────────────────────────────────

class _CampaignReviewStep extends StatelessWidget {
  final String name;
  final CampaignType type;
  final CampaignGoal goal;
  final String budget;
  final Set<String> audiences;
  final String channel;

  const _CampaignReviewStep({
    required this.name,
    required this.type,
    required this.goal,
    required this.budget,
    required this.audiences,
    required this.channel,
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
                'Review campaign details before launching',
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
              const SetupSectionTitle(title: 'Campaign Summary', icon: Icons.campaign),
              SetupInfoRow(label: 'Name', value: name.isNotEmpty ? name : '—'),
              SetupInfoRow(label: 'Type', value: type.name),
              SetupInfoRow(label: 'Goal', value: goal.name),
              SetupInfoRow(label: 'Budget', value: budget.isNotEmpty ? '₵$budget' : '—'),
              SetupInfoRow(label: 'Channel', value: channel),
              SetupInfoRow(label: 'Audiences', value: audiences.join(', ')),
            ],
          ),
        ),

        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SetupSectionTitle(title: 'Estimated Results', icon: Icons.analytics),
              const SetupInfoRow(label: 'Reach', value: '5,000 – 12,000'),
              const SetupInfoRow(label: 'Engagement', value: '3.5% – 5.2%'),
              const SetupInfoRow(label: 'Conversions', value: '50 – 150'),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ─── Nav Bar ─────────────────────────────────────────────────────────────────

class _CampaignNavBar extends StatelessWidget {
  final int currentStep;
  final int stepCount;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final VoidCallback onSubmit;

  const _CampaignNavBar({
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
                icon: Icon(isLast ? Icons.rocket_launch : Icons.arrow_forward, size: 18),
                label: Text(isLast ? 'Launch Campaign' : 'Continue'),
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

// ─── Shared Widgets ──────────────────────────────────────────────────────────

class _SelectionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectionTile({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? kSetupColor.withOpacity(0.06) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? kSetupColor.withOpacity(0.3) : Colors.grey.shade200,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: isSelected ? kSetupColor : AppColors.textTertiary),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? kSetupColor : AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (isSelected)
                const Icon(Icons.check_circle, size: 20, color: kSetupColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DatePickerTile({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: kSetupColor),
                const SizedBox(width: 6),
                Text(
                  date != null
                      ? '${date!.day}/${date!.month}/${date!.year}'
                      : 'Select',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: date != null ? AppColors.textPrimary : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
