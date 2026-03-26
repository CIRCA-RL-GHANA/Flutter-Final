/// ═══════════════════════════════════════════════════════════════════════════
/// LIVE MODULE — Screen 21: Incident Reporting
/// Structured incident report: type/severity selection, description,
/// photo evidence, location tagging, submission flow
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../models/live_models.dart';
import '../widgets/live_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class LiveIncidentReportScreen extends StatefulWidget {
  const LiveIncidentReportScreen({super.key});

  @override
  State<LiveIncidentReportScreen> createState() => _LiveIncidentReportScreenState();
}

class _LiveIncidentReportScreenState extends State<LiveIncidentReportScreen> {
  int _step = 0; // 0=type+severity, 1=details+evidence, 2=confirmation
  IncidentType? _selectedType;
  IncidentSeverity _severity = IncidentSeverity.minor;
  final _descriptionController = TextEditingController();
  bool _locationTagged = true;
  int _photoCount = 0;
  bool _submitted = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: _SubmittedView(onDone: () => Navigator.pop(context)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const LiveAppBar(title: 'Report Incident'),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                _StepDot(index: 0, current: _step, label: 'Type'),
                Expanded(child: Container(height: 2, color: _step > 0 ? kLiveColor : Colors.grey.shade300)),
                _StepDot(index: 1, current: _step, label: 'Details'),
                Expanded(child: Container(height: 2, color: _step > 1 ? kLiveColor : Colors.grey.shade300)),
                _StepDot(index: 2, current: _step, label: 'Review'),
              ],
            ),
          ),

          Consumer<AIInsightsNotifier>(
            builder: (context, ai, _) {
              if (ai.insights.isEmpty) return const SizedBox.shrink();
              return Container(
                color: kLiveColor.withOpacity(0.07),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 14, color: kLiveColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'AI: ${ai.insights.first['title'] ?? ''}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kLiveColor),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          Expanded(
            child: IndexedStack(
              index: _step,
              children: [
                _TypeSeverityStep(
                  selectedType: _selectedType,
                  severity: _severity,
                  onTypeSelected: (t) => setState(() => _selectedType = t),
                  onSeverityChanged: (s) => setState(() => _severity = s),
                ),
                _DetailsStep(
                  controller: _descriptionController,
                  locationTagged: _locationTagged,
                  photoCount: _photoCount,
                  onLocationTaggedChanged: (v) => setState(() => _locationTagged = v),
                  onAddPhoto: () => setState(() => _photoCount++),
                ),
                _ReviewStep(
                  type: _selectedType,
                  severity: _severity,
                  description: _descriptionController.text,
                  locationTagged: _locationTagged,
                  photoCount: _photoCount,
                ),
              ],
            ),
          ),

          // Bottom bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))],
            ),
            child: Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _step--),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _step == 2
                        ? () {
                            HapticFeedback.mediumImpact();
                            setState(() => _submitted = true);
                          }
                        : (_step == 0 && _selectedType == null)
                            ? null
                            : (_step == 1 && _descriptionController.text.trim().isEmpty)
                                ? null
                                : () => setState(() => _step++),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _step == 2 ? kLiveColor : AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _step == 2 ? 'Submit Report' : 'Continue',
                      style: const TextStyle(fontWeight: FontWeight.w700),
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
}

class _TypeSeverityStep extends StatelessWidget {
  final IncidentType? selectedType;
  final IncidentSeverity severity;
  final ValueChanged<IncidentType> onTypeSelected;
  final ValueChanged<IncidentSeverity> onSeverityChanged;

  const _TypeSeverityStep({
    required this.selectedType,
    required this.severity,
    required this.onTypeSelected,
    required this.onSeverityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Incident type selection
        LiveSectionCard(
          title: 'INCIDENT TYPE',
          icon: Icons.warning_amber,
          iconColor: kLiveAccent,
          child: Column(
            children: IncidentType.values.map((type) {
              final info = _typeInfo(type);
              final isSelected = selectedType == type;
              return GestureDetector(
                onTap: () => onTypeSelected(type),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? kLiveColor.withOpacity(0.05) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSelected ? kLiveColor : Colors.grey.shade200, width: isSelected ? 2 : 1),
                  ),
                  child: Row(
                    children: [
                      Text(info.$1, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(info.$2, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? kLiveColor : AppColors.textPrimary)),
                            Text(info.$3, style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                          ],
                        ),
                      ),
                      if (isSelected) const Icon(Icons.check_circle, size: 20, color: kLiveColor),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Severity selection
        LiveSectionCard(
          title: 'SEVERITY LEVEL',
          icon: Icons.speed,
          iconColor: kLiveColor,
          child: Column(
            children: IncidentSeverity.values.map((s) {
              final info = _severityInfo(s);
              final isSelected = severity == s;
              return GestureDetector(
                onTap: () => onSeverityChanged(s),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? info.$3.withOpacity(0.1) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSelected ? info.$3 : Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: info.$3),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(info.$1, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? info.$3 : AppColors.textPrimary)),
                            Text(info.$2, style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                          ],
                        ),
                      ),
                      if (isSelected) Icon(Icons.radio_button_checked, size: 18, color: info.$3),
                      if (!isSelected) Icon(Icons.radio_button_off, size: 18, color: Colors.grey.shade400),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  (String, String, String) _typeInfo(IncidentType type) => switch (type) {
        IncidentType.vehicleAccident => ('🚗', 'Vehicle Accident', 'Collision or road accident'),
        IncidentType.theftRobbery => ('🔒', 'Theft / Robbery', 'Package or vehicle theft'),
        IncidentType.packageDamageLoss => ('📦', 'Package Damage', 'Damaged goods during transit'),
        IncidentType.harassment => ('⚠️', 'Harassment', 'Customer or third-party harassment'),
        IncidentType.customerDispute => ('🗣️', 'Customer Dispute', 'Dispute with customer'),
        IncidentType.medicalEmergency => ('🏥', 'Medical Emergency', 'Medical emergency incident'),
        IncidentType.other => ('📋', 'Other', 'Any other incident type'),
      };

  (String, String, Color) _severityInfo(IncidentSeverity severity) => switch (severity) {
        IncidentSeverity.minor => ('Minor', 'Minor issue, no immediate danger', const Color(0xFF10B981)),
        IncidentSeverity.major => ('Major', 'Moderate disruption, needs attention', const Color(0xFFF59E0B)),
        IncidentSeverity.critical => ('Critical', 'Serious incident, urgent response', const Color(0xFFEF4444)),
      };
}

class _DetailsStep extends StatelessWidget {
  final TextEditingController controller;
  final bool locationTagged;
  final int photoCount;
  final ValueChanged<bool> onLocationTaggedChanged;
  final VoidCallback onAddPhoto;

  const _DetailsStep({
    required this.controller,
    required this.locationTagged,
    required this.photoCount,
    required this.onLocationTaggedChanged,
    required this.onAddPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Description
        LiveSectionCard(
          title: 'DESCRIPTION',
          icon: Icons.edit_note,
          iconColor: AppColors.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Describe what happened', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                maxLines: 5,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Provide details about the incident...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kLiveColor, width: 2)),
                  contentPadding: const EdgeInsets.all(12),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),

        // Photo evidence
        LiveSectionCard(
          title: 'PHOTO EVIDENCE',
          icon: Icons.camera_alt,
          iconColor: const Color(0xFF3B82F6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$photoCount photo(s) attached', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _EvidenceButton(icon: Icons.camera_alt, label: 'Camera', onTap: onAddPhoto),
                  const SizedBox(width: 8),
                  _EvidenceButton(icon: Icons.photo_library, label: 'Gallery', onTap: onAddPhoto),
                ],
              ),
              if (photoCount > 0) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: List.generate(
                    photoCount,
                    (i) => Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Center(child: Icon(Icons.image, size: 24, color: Color(0xFF9CA3AF))),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Location
        LiveSectionCard(
          title: 'LOCATION',
          icon: Icons.location_on,
          iconColor: kLiveColor,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tag current location', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        Text('GPS coordinates will be recorded', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                      ],
                    ),
                  ),
                  Switch(value: locationTagged, onChanged: onLocationTaggedChanged, activeColor: kLiveColor),
                ],
              ),
              if (locationTagged)
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(8)),
                  child: const Row(
                    children: [
                      Icon(Icons.my_location, size: 16, color: Color(0xFF10B981)),
                      SizedBox(width: 8),
                      Text('Location acquired ✓', style: TextStyle(fontSize: 12, color: Color(0xFF059669), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReviewStep extends StatelessWidget {
  final IncidentType? type;
  final IncidentSeverity severity;
  final String description;
  final bool locationTagged;
  final int photoCount;

  const _ReviewStep({
    required this.type,
    required this.severity,
    required this.description,
    required this.locationTagged,
    required this.photoCount,
  });

  @override
  Widget build(BuildContext context) {
    final severityColors = {
      IncidentSeverity.minor: const Color(0xFF10B981),
      IncidentSeverity.major: const Color(0xFFF59E0B),
      IncidentSeverity.critical: const Color(0xFFEF4444),
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [kLiveColor.withOpacity(0.1), kLiveAccent.withOpacity(0.05)]),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kLiveColor.withOpacity(0.2)),
          ),
          child: const Column(
            children: [
              Icon(Icons.fact_check, size: 28, color: kLiveColor),
              SizedBox(height: 6),
              Text('Review Your Report', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kLiveColor)),
              Text('Please verify all details before submitting', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            ],
          ),
        ),
        const SizedBox(height: 12),

        LiveSectionCard(
          title: 'REPORT SUMMARY',
          icon: Icons.description,
          iconColor: AppColors.primary,
          child: Column(
            children: [
              _SummaryRow(label: 'Type', value: type?.name ?? 'Not selected'),
              const Divider(height: 12),
              _SummaryRow(label: 'Severity', value: severity.name.toUpperCase(), valueColor: severityColors[severity]),
              const Divider(height: 12),
              _SummaryRow(label: 'Description', value: description.isEmpty ? 'No description' : (description.length > 60 ? '${description.substring(0, 60)}...' : description)),
              const Divider(height: 12),
              _SummaryRow(label: 'Location tagged', value: locationTagged ? 'Yes ✓' : 'No'),
              const Divider(height: 12),
              _SummaryRow(label: 'Photos', value: '$photoCount attached'),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(10)),
          child: const Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Color(0xFFD97706)),
              SizedBox(width: 8),
              Expanded(child: Text('This report will be reviewed by the operations team within 30 minutes.', style: TextStyle(fontSize: 11, color: Color(0xFF92400E)))),
            ],
          ),
        ),
      ],
    );
  }
}

class _SubmittedView extends StatelessWidget {
  final VoidCallback onDone;
  const _SubmittedView({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF10B981).withOpacity(0.1)),
              child: const Center(child: Icon(Icons.check_circle, size: 48, color: Color(0xFF10B981))),
            ),
            const SizedBox(height: 20),
            const Text('Report Submitted', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Incident #INC-${DateTime.now().millisecondsSinceEpoch % 10000}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kLiveColor)),
            const SizedBox(height: 8),
            Text('Our operations team has been notified and will review your report shortly.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int index;
  final int current;
  final String label;
  const _StepDot({required this.index, required this.current, required this.label});

  @override
  Widget build(BuildContext context) {
    final isActive = index <= current;
    return Column(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? kLiveColor : Colors.grey.shade300,
          ),
          child: Center(
            child: index < current
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text('${index + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isActive ? Colors.white : Colors.grey.shade600)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isActive ? kLiveColor : Colors.grey.shade500)),
      ],
    );
  }
}

class _EvidenceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _EvidenceButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF3B82F6),
          side: BorderSide(color: Colors.grey.shade300),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _SummaryRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 110, child: Text(label, style: TextStyle(fontSize: 12, color: AppColors.textTertiary))),
        Expanded(child: Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: valueColor ?? AppColors.textPrimary))),
      ],
    );
  }
}
