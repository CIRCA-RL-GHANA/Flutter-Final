/// ═══════════════════════════════════════════════════════════════════════════
/// Screen 3: Create / Edit Entity Form
/// 5-step stepper: Type → Core Info → Verification → Role → Review
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../prompt/models/rbac_models.dart';
import '../models/user_details_models.dart';
import '../providers/user_details_provider.dart';
import '../widgets/shared_widgets.dart';

class CreateEntityScreen extends StatelessWidget {
  const CreateEntityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDetailsProvider>(
      builder: (context, udp, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FC),
          appBar: ModuleHeader(
            title: udp.creationStep == 0 ? 'Create Context' : 'Step ${udp.creationStep} of ${UserDetailsProvider.totalCreationSteps - 1}',
            contextColor: udp.selectedEntityType?.color ?? const Color(0xFF6366F1),
            actions: [
              if (udp.creationStep > 0)
                TextButton(
                  onPressed: () {
                    udp.resetCreation();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel', style: TextStyle(color: AppColors.error)),
                ),
            ],
          ),
          body: Column(
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: AppColors.primary.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI: ${ai.insights.first['title'] ?? ''}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.primary),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Progress indicator
              if (udp.creationStep > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: _StepProgress(
                    currentStep: udp.creationStep,
                    totalSteps: UserDetailsProvider.totalCreationSteps - 1,
                    color: udp.selectedEntityType?.color ?? const Color(0xFF6366F1),
                  ),
                ),

              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildStep(context, udp),
                ),
              ),
            ],
          ),

          // Navigation buttons
          bottomNavigationBar: udp.creationStep > 0
              ? _StepNavigation(
                  step: udp.creationStep,
                  totalSteps: UserDetailsProvider.totalCreationSteps - 1,
                  color: udp.selectedEntityType?.color ?? const Color(0xFF6366F1),
                  onBack: () {
                    if (udp.creationStep <= 1) {
                      udp.resetCreation();
                    } else {
                      udp.setCreationStep(udp.creationStep - 1);
                    }
                  },
                  onNext: () {
                    if (udp.creationStep >= UserDetailsProvider.totalCreationSteps - 1) {
                      // Submit
                      HapticFeedback.heavyImpact();
                      udp.resetCreation();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Context created successfully!')),
                      );
                    } else {
                      udp.setCreationStep(udp.creationStep + 1);
                    }
                  },
                  canProceed: _canProceed(udp),
                )
              : null,
        );
      },
    );
  }

  bool _canProceed(UserDetailsProvider udp) {
    switch (udp.creationStep) {
      case 1: return udp.selectedEntityType != null;
      case 2: return udp.entityName.isNotEmpty;
      case 3: return true; // Verification is optional
      case 4: return udp.selectedRole != null;
      default: return true;
    }
  }

  Widget _buildStep(BuildContext context, UserDetailsProvider udp) {
    switch (udp.creationStep) {
      case 0:
      case 1:
        return _Step1TypeSelection(key: const ValueKey('step1'));
      case 2:
        return _Step2CoreInfo(key: const ValueKey('step2'));
      case 3:
        return _Step3Verification(key: const ValueKey('step3'));
      case 4:
        return _Step4RoleAssignment(key: const ValueKey('step4'));
      default:
        return _Step1TypeSelection(key: const ValueKey('step1'));
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Step Progress
// ═══════════════════════════════════════════════════════════════════════════

class _StepProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color color;
  const _StepProgress({required this.currentStep, required this.totalSteps, required this.color});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final labels = ['Type', 'Info', 'Verify', 'Role'];
    return Row(
      children: List.generate(totalSteps, (i) {
        final step = i + 1;
        final isComplete = currentStep > step;
        final isCurrent = currentStep == step;
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isComplete ? color : (isCurrent ? color.withOpacity(0.15) : Colors.grey.withOpacity(0.1)),
                  border: Border.all(
                    color: isCurrent ? color : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isComplete
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Text(
                          '$step',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isCurrent ? color : AppColors.textTertiary,
                          ),
                        ),
                ),
              ),
              if (i < totalSteps - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    color: isComplete ? color : Colors.grey.withOpacity(0.15),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Step 1: Entity Type Selection
// ═══════════════════════════════════════════════════════════════════════════

class _Step1TypeSelection extends StatelessWidget {
  const _Step1TypeSelection({super.key});

  @override
  Widget build(BuildContext context) {
    final udp = context.watch<UserDetailsProvider>();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'What type of context?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Each context represents a different identity or role you operate under.',
          style: TextStyle(fontSize: 13, color: AppColors.textTertiary, height: 1.4),
        ),
        const SizedBox(height: 20),
        ...EntityCreationType.values.map((type) => _TypeCard(
              type: type,
              selected: udp.selectedEntityType == type,
              onTap: () {
                HapticFeedback.selectionClick();
                udp.selectEntityType(type);
              },
            )),
      ],
    );
  }
}

class _TypeCard extends StatelessWidget {
  final EntityCreationType type;
  final bool selected;
  final VoidCallback onTap;
  const _TypeCard({required this.type, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected ? type.color.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? type.color : Colors.grey.withOpacity(0.15),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: type.color.withOpacity(0.1), blurRadius: 8)]
              : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: type.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(type.icon, size: 24, color: type.color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: selected ? type.color : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        type.subtitle,
                        style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle, size: 22, color: type.color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Step 2: Core Info
// ═══════════════════════════════════════════════════════════════════════════

class _Step2CoreInfo extends StatelessWidget {
  const _Step2CoreInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final udp = context.watch<UserDetailsProvider>();
    final type = udp.selectedEntityType;
    final color = type?.color ?? const Color(0xFF6366F1);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          type == EntityCreationType.personal ? 'Personal Details' : '${type?.label ?? "Entity"} Details',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 20),

        _FormField(
          label: type == EntityCreationType.personal ? 'Display Name' : 'Entity Name',
          hint: type == EntityCreationType.business ? 'e.g. Wizdom Electronics' : 'Enter name',
          icon: Icons.badge_outlined,
          color: color,
          initialValue: udp.entityName,
          onChanged: (v) => udp.updateEntityFields(name: v),
        ),

        _FormField(
          label: type == EntityCreationType.personal ? 'Bio' : 'Description',
          hint: 'Brief description',
          icon: Icons.description_outlined,
          color: color,
          initialValue: udp.entitySubtitle,
          onChanged: (v) => udp.updateEntityFields(subtitle: v),
          maxLines: 2,
        ),

        if (type == EntityCreationType.business) ...[
          _FormField(
            label: 'Registration Number',
            hint: 'GH-BRN-XXXXXX',
            icon: Icons.numbers,
            color: color,
            initialValue: udp.entityRegistration ?? '',
            onChanged: (v) => udp.updateEntityFields(registration: v),
          ),
        ],

        if (type == EntityCreationType.branch) ...[
          const SizedBox(height: 12),
          const Text('Branch Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: BranchType.values.map((bt) {
              final selected = udp.entityBranchType == bt;
              return ChoiceChip(
                label: Text(bt.toString().split('.').last),
                selected: selected,
                onSelected: (_) => udp.updateEntityFields(branchType: bt),
                selectedColor: color.withOpacity(0.15),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final Color color;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final int maxLines;

  const _FormField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.color,
    required this.initialValue,
    required this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: initialValue,
            onChanged: onChanged,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, size: 20, color: color),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.15)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.15)),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Step 3: Verification
// ═══════════════════════════════════════════════════════════════════════════

class _Step3Verification extends StatelessWidget {
  const _Step3Verification({super.key});

  @override
  Widget build(BuildContext context) {
    final udp = context.watch<UserDetailsProvider>();
    final color = udp.selectedEntityType?.color ?? const Color(0xFF6366F1);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Verification',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Complete verification steps to unlock more features. You can skip and verify later.',
          style: TextStyle(fontSize: 13, color: AppColors.textTertiary, height: 1.4),
        ),
        const SizedBox(height: 20),

        _VerificationStep(
          title: 'Email Verification',
          subtitle: 'Receive a code to verify your email',
          icon: Icons.email_outlined,
          color: color,
          completed: udp.emailVerificationSent,
          onAction: () {
            HapticFeedback.selectionClick();
            udp.sendEmailVerification();
          },
          actionLabel: udp.emailVerificationSent ? 'Sent ✓' : 'Send Code',
        ),
        _VerificationStep(
          title: 'Phone Verification',
          subtitle: 'Verify via SMS or call',
          icon: Icons.phone_outlined,
          color: color,
          completed: udp.phoneVerificationSent,
          onAction: () {
            HapticFeedback.selectionClick();
            udp.sendPhoneVerification();
          },
          actionLabel: udp.phoneVerificationSent ? 'Sent ✓' : 'Send Code',
        ),
        _VerificationStep(
          title: 'Document Upload',
          subtitle: 'Upload ID or business certificate',
          icon: Icons.upload_file,
          color: color,
          completed: udp.documentUploaded,
          onAction: () {
            HapticFeedback.selectionClick();
            udp.setDocumentUploaded(true);
          },
          actionLabel: udp.documentUploaded ? 'Uploaded ✓' : 'Upload',
        ),
        _VerificationStep(
          title: 'Address Verification',
          subtitle: 'Confirm your location',
          icon: Icons.location_on_outlined,
          color: color,
          completed: udp.addressVerified,
          onAction: () {
            HapticFeedback.selectionClick();
            udp.setAddressVerified(true);
          },
          actionLabel: udp.addressVerified ? 'Verified ✓' : 'Verify',
        ),
      ],
    );
  }
}

class _VerificationStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool completed;
  final VoidCallback onAction;
  final String actionLabel;

  const _VerificationStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.completed,
    required this.onAction,
    required this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SectionCard(
        borderColor: completed ? const Color(0xFF10B981).withOpacity(0.3) : null,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (completed ? const Color(0xFF10B981) : color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                completed ? Icons.check_circle : icon,
                size: 22,
                color: completed ? const Color(0xFF10B981) : color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                ],
              ),
            ),
            TextButton(
              onPressed: completed ? null : onAction,
              child: Text(
                actionLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: completed ? const Color(0xFF10B981) : color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Step 4: Role Assignment
// ═══════════════════════════════════════════════════════════════════════════

class _Step4RoleAssignment extends StatelessWidget {
  const _Step4RoleAssignment({super.key});

  @override
  Widget build(BuildContext context) {
    final udp = context.watch<UserDetailsProvider>();
    final color = udp.selectedEntityType?.color ?? const Color(0xFF6366F1);

    // Filter roles based on entity type
    final availableRoles = _rolesForType(udp.selectedEntityType);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Assign Role',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Your role determines what features and permissions are available.',
          style: TextStyle(fontSize: 13, color: AppColors.textTertiary, height: 1.4),
        ),
        const SizedBox(height: 20),
        ...availableRoles.map((role) {
          final selected = udp.selectedRole == role;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                udp.selectRole(role);
              },
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected ? color.withOpacity(0.06) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? color : Colors.grey.withOpacity(0.15),
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: RoleColors.forRole(role).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.person_outline, size: 20, color: RoleColors.forRole(role)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            role.toString().split('.').last.replaceAllMapped(
                              RegExp(r'([A-Z])'),
                              (m) => ' ${m.group(0)}',
                            ).trim(),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                    if (selected) Icon(Icons.check_circle, size: 20, color: color),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  List<UserRole> _rolesForType(EntityCreationType? type) {
    switch (type) {
      case EntityCreationType.personal:
        return [UserRole.owner];
      case EntityCreationType.business:
        return [UserRole.owner, UserRole.administrator, UserRole.socialOfficer, UserRole.responseOfficer, UserRole.monitor];
      case EntityCreationType.branch:
        return [UserRole.branchManager, UserRole.branchResponseOfficer, UserRole.branchMonitor, UserRole.branchSocialOfficer];
      case EntityCreationType.specialPurpose:
        return [UserRole.owner, UserRole.administrator, UserRole.monitor];
      default:
        return UserRole.values;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Step Navigation
// ═══════════════════════════════════════════════════════════════════════════

class _StepNavigation extends StatelessWidget {
  final int step;
  final int totalSteps;
  final Color color;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final bool canProceed;

  const _StepNavigation({
    required this.step,
    required this.totalSteps,
    required this.color,
    required this.onBack,
    required this.onNext,
    required this.canProceed,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = step >= totalSteps;
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 12,
        top: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.inputBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(step <= 1 ? 'Cancel' : 'Back'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canProceed ? onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                disabledBackgroundColor: color.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                isLast ? 'Create Context' : 'Continue',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
