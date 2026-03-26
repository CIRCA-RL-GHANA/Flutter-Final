/// ═══════════════════════════════════════════════════════════════════════════
/// SCREEN 7 / 7A — Options Menu + Report Flow
/// Bottom sheet options menu (save, copy link, mute, follow, report).
/// Report flow: 4-step wizard (reason, details, evidence, submit).
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../models/updates_models.dart';
import '../providers/updates_provider.dart';
import '../widgets/updates_widgets.dart';

class UpdatesOptionsScreen extends StatelessWidget {
  const UpdatesOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UpdatesProvider(),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdatesProvider>(
      builder: (context, prov, _) {
        final update = prov.selectedUpdate ?? prov.updates.first;
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: const UpdatesAppBar(title: 'Options'),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Consumer<AIInsightsNotifier>(
                  builder: (context, ai, _) {
                    if (ai.insights.isEmpty) return const SizedBox.shrink();
                    return Container(
                      color: kUpdatesColor.withOpacity(0.07),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Row(children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kUpdatesColor),
                        const SizedBox(width: 8),
                        Expanded(child: Text('AI: ${ai.insights.first['title'] ?? ''}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kUpdatesColor),
                          maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ]),
                    );
                  },
                ),
                // Update preview
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: kUpdatesColor.withOpacity(0.12),
                        child: Text(update.entityName.substring(0, 1), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kUpdatesColor)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(update.entityName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            Text(update.caption, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Actions section
                UpdatesSectionCard(
                  title: 'ACTIONS',
                  icon: Icons.bolt,
                  child: Column(
                    children: [
                      _OptionTile(
                        icon: update.isSavedByMe ? Icons.bookmark : Icons.bookmark_outline,
                        label: update.isSavedByMe ? 'Remove from Saved' : 'Save Update',
                        subtitle: 'Add to your saved library',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          prov.toggleSave(update.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(update.isSavedByMe ? 'Removed from saved' : 'Saved to library'), backgroundColor: kUpdatesColor, duration: const Duration(seconds: 1)),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _OptionTile(
                        icon: Icons.link,
                        label: 'Copy Link',
                        subtitle: 'Copy shareable link to clipboard',
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          Clipboard.setData(const ClipboardData(text: 'https://thepg.app/update/123'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Link copied!'), backgroundColor: kUpdatesColor, duration: Duration(seconds: 1)),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _OptionTile(
                        icon: Icons.share,
                        label: 'Share to...',
                        subtitle: 'Share via other platforms',
                        onTap: () => HapticFeedback.lightImpact(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Relationship section
                UpdatesSectionCard(
                  title: 'RELATIONSHIP',
                  icon: Icons.people,
                  iconColor: kUpdatesAccent,
                  child: Column(
                    children: [
                      _OptionTile(
                        icon: Icons.person_add_outlined,
                        label: 'Follow ${update.entityName}',
                        subtitle: 'See their updates in your feed',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Following ${update.entityName}'), backgroundColor: kUpdatesColor, duration: const Duration(seconds: 1)),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _OptionTile(
                        icon: Icons.notifications_off_outlined,
                        label: 'Mute ${update.entityName}',
                        subtitle: 'Stop seeing their updates temporarily',
                        onTap: () => _showMuteOptions(context, update.entityName),
                      ),
                      const Divider(height: 1),
                      _OptionTile(
                        icon: Icons.visibility_off_outlined,
                        label: 'Hide this update',
                        subtitle: 'Remove from your feed',
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Update hidden'), backgroundColor: kUpdatesColor, duration: Duration(seconds: 1)),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Report section
                UpdatesSectionCard(
                  title: 'SAFETY',
                  icon: Icons.shield,
                  iconColor: AppColors.error,
                  child: Column(
                    children: [
                      _OptionTile(
                        icon: Icons.flag_outlined,
                        label: 'Report Update',
                        subtitle: 'Report inappropriate content',
                        color: AppColors.error,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const _ReportFlow()),
                        ),
                      ),
                      const Divider(height: 1),
                      _OptionTile(
                        icon: Icons.block,
                        label: 'Block ${update.entityName}',
                        subtitle: 'Prevent all interactions',
                        color: AppColors.error,
                        onTap: () => _showBlockConfirmation(context, update.entityName),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMuteOptions(BuildContext context, String name) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mute $name', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('How long would you like to mute?', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            ...MuteDuration.values.map((d) => ListTile(
              leading: const Icon(Icons.timer, size: 18, color: AppColors.textTertiary),
              title: Text(d.name, style: const TextStyle(fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$name muted for ${d.name}'), backgroundColor: kUpdatesColor, duration: const Duration(seconds: 1)),
                );
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showBlockConfirmation(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Block Entity?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to block $name? They won\'t be able to see your profile or interact with your updates.', style: const TextStyle(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$name blocked'), backgroundColor: AppColors.error, duration: const Duration(seconds: 1)),
              );
            },
            child: const Text('Block', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─── Option Tile ────────────────────────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color? color;
  final VoidCallback onTap;

  const _OptionTile({required this.icon, required this.label, required this.subtitle, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: (color ?? kUpdatesColor).withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 18, color: color ?? kUpdatesColor),
      ),
      title: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color ?? AppColors.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
      trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }
}

// ─── Screen 7A: Report Flow ─────────────────────────────────────────────────

class _ReportFlow extends StatefulWidget {
  const _ReportFlow();
  @override
  State<_ReportFlow> createState() => _ReportFlowState();
}

class _ReportFlowState extends State<_ReportFlow> {
  int _step = 0;
  ReportReason? _selectedReason;
  final _detailsController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: UpdatesAppBar(
        title: 'Report Update',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Text('Step ${_step + 1}/4', style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_step + 1) / 4,
            backgroundColor: Colors.grey.shade100,
            valueColor: const AlwaysStoppedAnimation(kUpdatesColor),
            minHeight: 3,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: switch (_step) {
                  0 => _StepReason(
                    key: const ValueKey(0),
                    selectedReason: _selectedReason,
                    onSelect: (r) => setState(() => _selectedReason = r),
                  ),
                  1 => _StepDetails(key: const ValueKey(1), controller: _detailsController),
                  2 => _StepEvidence(key: const ValueKey(2)),
                  3 => _StepReview(
                    key: const ValueKey(3),
                    reason: _selectedReason,
                    details: _detailsController.text,
                    submitting: _submitting,
                  ),
                  _ => const SizedBox(),
                },
              ),
            ),
          ),

          // Navigation buttons
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).viewPadding.bottom),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, -2))],
            ),
            child: Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _step--),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _canProceed()
                        ? () async {
                            if (_step < 3) {
                              setState(() => _step++);
                            } else {
                              setState(() => _submitting = true);
                              await Future.delayed(const Duration(seconds: 2));
                              if (mounted) {
                                Navigator.pop(context);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Report submitted. Our team will review it within 24 hours.'),
                                    backgroundColor: kUpdatesColor,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              }
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _step == 3 ? AppColors.error : kUpdatesColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade200,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      _step == 3 ? (_submitting ? 'Submitting...' : 'Submit Report') : 'Continue',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    if (_submitting) return false;
    if (_step == 0) return _selectedReason != null;
    return true;
  }
}

// ─── Report Steps ───────────────────────────────────────────────────────────

class _StepReason extends StatelessWidget {
  final ReportReason? selectedReason;
  final ValueChanged<ReportReason> onSelect;
  const _StepReason({super.key, required this.selectedReason, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Why are you reporting this update?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Select the reason that best describes the issue.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        ...ReportReason.values.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: GestureDetector(
            onTap: () => onSelect(r),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selectedReason == r ? kUpdatesColor.withOpacity(0.06) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: selectedReason == r ? kUpdatesColor : Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: selectedReason == r ? kUpdatesColor : Colors.grey.shade300, width: 2),
                      color: selectedReason == r ? kUpdatesColor : Colors.transparent,
                    ),
                    child: selectedReason == r ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(r.name, style: TextStyle(fontSize: 13, fontWeight: selectedReason == r ? FontWeight.w600 : FontWeight.w400))),
                ],
              ),
            ),
          ),
        )),
      ],
    );
  }
}

class _StepDetails extends StatelessWidget {
  final TextEditingController controller;
  const _StepDetails({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Provide additional details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Help us understand the issue better.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          maxLines: 5,
          maxLength: 500,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Describe what happened...',
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.inputBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.inputBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kUpdatesColor)),
          ),
        ),
        const SizedBox(height: 8),
        const Text('Optional — but helpful for our review team.', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
      ],
    );
  }
}

class _StepEvidence extends StatelessWidget {
  const _StepEvidence({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Attach evidence (optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Screenshots or links help us review faster.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
          ),
          child: Column(
            children: [
              Icon(Icons.cloud_upload_outlined, size: 40, color: kUpdatesColor.withOpacity(0.4)),
              const SizedBox(height: 8),
              const Text('Tap to upload', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kUpdatesColor)),
              const Text('PNG, JPG up to 5MB', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text('Or paste a link:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'https://...',
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.inputBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.inputBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kUpdatesColor)),
          ),
        ),
      ],
    );
  }
}

class _StepReview extends StatelessWidget {
  final ReportReason? reason;
  final String details;
  final bool submitting;
  const _StepReview({super.key, required this.reason, required this.details, required this.submitting});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Review your report', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Please confirm the details before submitting.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ReviewRow(label: 'Reason', value: reason?.name ?? 'Not selected'),
              if (details.isNotEmpty) ...[
                const SizedBox(height: 10),
                _ReviewRow(label: 'Details', value: details),
              ],
              const SizedBox(height: 10),
              const _ReviewRow(label: 'Status', value: 'Will be reviewed within 24 hours'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: Color(0xFFF59E0B)),
              SizedBox(width: 8),
              Expanded(
                child: Text('False reports may result in account restrictions.', style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
              ),
            ],
          ),
        ),
        if (submitting) ...[
          const SizedBox(height: 20),
          const Center(
            child: Column(
              children: [
                CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(kUpdatesColor)),
                SizedBox(height: 10),
                Text('Submitting report...', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
      ],
    );
  }
}
