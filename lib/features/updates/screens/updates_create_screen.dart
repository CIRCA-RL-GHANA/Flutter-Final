/// ═══════════════════════════════════════════════════════════════════════════
/// SCREEN 8 — Create Update
/// Full composer: media attach, text with mentions/hashtags, poll builder,
/// visibility picker, scheduling, preview before publish.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../models/updates_models.dart';
import '../providers/updates_provider.dart';
import '../widgets/updates_widgets.dart';

class UpdatesCreateScreen extends StatelessWidget {
  const UpdatesCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UpdatesProvider(),
      child: const _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();
  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _captionController = TextEditingController();
  UpdateContentType _contentType = UpdateContentType.text;
  UpdateVisibility _visibility = UpdateVisibility.publicAll;
  bool _isPollMode = false;
  bool _isScheduleMode = false;
  DateTime? _scheduledDate;
  int _mediaCount = 0;

  // Poll state
  final _pollQuestionController = TextEditingController();
  final List<TextEditingController> _pollOptionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  PollDuration _pollDuration = PollDuration.twentyFourHours;

  @override
  void dispose() {
    _captionController.dispose();
    _pollQuestionController.dispose();
    for (final c in _pollOptionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 22),
          color: AppColors.textPrimary,
          onPressed: () => _showDiscardDialog(context),
        ),
        title: const Text('Create Update', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        actions: [
          if (_isScheduleMode)
            TextButton.icon(
              onPressed: () => _pickScheduleDate(context),
              icon: const Icon(Icons.schedule, size: 16),
              label: Text(
                _scheduledDate != null ? _formatDate(_scheduledDate!) : 'Schedule',
                style: const TextStyle(fontSize: 12),
              ),
              style: TextButton.styleFrom(foregroundColor: kUpdatesAccent),
            ),
          TextButton(
            onPressed: _captionController.text.isNotEmpty || _isPollMode
                ? () => _showPreviewSheet(context)
                : null,
            child: const Text('Preview', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            style: TextButton.styleFrom(foregroundColor: kUpdatesColor),
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: _captionController.text.isNotEmpty || _isPollMode
                  ? () => _publish(context)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: kUpdatesColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade200,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(_isScheduleMode ? 'Schedule' : 'Publish', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            // Author identity
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: kUpdatesColorLight,
                    child: Text('W', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kUpdatesColor)),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Wizdom Shop', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        Text('Publishing as entity owner', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                      ],
                    ),
                  ),
                  // Visibility picker
                  GestureDetector(
                    onTap: () => _showVisibilityPicker(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: kUpdatesColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kUpdatesColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_visibilityIcon(_visibility), size: 14, color: kUpdatesColor),
                          const SizedBox(width: 4),
                          Text(_visibilityLabel(_visibility), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kUpdatesColor)),
                          const Icon(Icons.arrow_drop_down, size: 16, color: kUpdatesColor),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Caption text area
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: TextField(
                controller: _captionController,
                maxLines: null,
                minLines: 4,
                maxLength: 2000,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontSize: 15, height: 1.5),
                decoration: const InputDecoration(
                  hintText: 'What\'s happening? Share an update...',
                  hintStyle: TextStyle(fontSize: 15, color: AppColors.textTertiary),
                  border: InputBorder.none,
                  counterStyle: TextStyle(fontSize: 10, color: AppColors.textTertiary),
                ),
              ),
            ),

            // Media preview strip
            if (_mediaCount > 0)
              Container(
                height: 100,
                margin: const EdgeInsets.symmetric(horizontal: 14),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _mediaCount + 1, // +1 for add button
                  itemBuilder: (context, i) {
                    if (i == _mediaCount) {
                      return GestureDetector(
                        onTap: () => setState(() => _mediaCount++),
                        child: Container(
                          width: 90, height: 90,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: kUpdatesColor.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: kUpdatesColor.withOpacity(0.2), style: BorderStyle.solid),
                          ),
                          child: const Icon(Icons.add, color: kUpdatesColor),
                        ),
                      );
                    }
                    return Container(
                      width: 90, height: 90,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: kUpdatesColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          Center(child: Icon(_contentTypeIcon(_contentType), size: 24, color: kUpdatesColor.withOpacity(0.3))),
                          Positioned(
                            top: 4, right: 4,
                            child: GestureDetector(
                              onTap: () => setState(() => _mediaCount--),
                              child: Container(
                                width: 20, height: 20,
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.close, size: 12, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            // Poll builder
            if (_isPollMode) ...[
              Padding(
                padding: const EdgeInsets.all(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kUpdatesColor.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.poll, size: 18, color: kUpdatesColor),
                          const SizedBox(width: 6),
                          const Text('Poll', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kUpdatesColor)),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => setState(() => _isPollMode = false),
                            child: const Icon(Icons.close, size: 18, color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _pollQuestionController,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Ask a question...',
                          filled: true,
                          fillColor: AppColors.inputFill,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._pollOptionControllers.asMap().entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: entry.value,
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'Option ${entry.key + 1}',
                                  filled: true,
                                  fillColor: AppColors.inputFill,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                              ),
                            ),
                            if (_pollOptionControllers.length > 2)
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, size: 18),
                                color: AppColors.error,
                                onPressed: () => setState(() {
                                  _pollOptionControllers[entry.key].dispose();
                                  _pollOptionControllers.removeAt(entry.key);
                                }),
                              ),
                          ],
                        ),
                      )),
                      if (_pollOptionControllers.length < 6)
                        TextButton.icon(
                          onPressed: () => setState(() => _pollOptionControllers.add(TextEditingController())),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add option', style: TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(foregroundColor: kUpdatesColor),
                        ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Text('Duration:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(width: 8),
                          DropdownButton<PollDuration>(
                            value: _pollDuration,
                            onChanged: (v) => setState(() => _pollDuration = v!),
                            isDense: true,
                            underline: const SizedBox(),
                            style: const TextStyle(fontSize: 12, color: kUpdatesColor, fontWeight: FontWeight.w600),
                            items: PollDuration.values.map((d) => DropdownMenuItem(
                              value: d,
                              child: Text(d.name),
                            )).toList(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const Divider(height: 1),

            // Toolbar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                children: [
                  _ToolbarButton(icon: Icons.image, label: 'Photo', onTap: () {
                    setState(() { _contentType = UpdateContentType.image; _mediaCount++; });
                  }),
                  _ToolbarButton(icon: Icons.videocam, label: 'Video', onTap: () {
                    setState(() { _contentType = UpdateContentType.video; _mediaCount++; });
                  }),
                  _ToolbarButton(icon: Icons.poll, label: 'Poll', isActive: _isPollMode, onTap: () {
                    setState(() => _isPollMode = !_isPollMode);
                  }),
                  _ToolbarButton(icon: Icons.schedule, label: 'Schedule', isActive: _isScheduleMode, onTap: () {
                    setState(() => _isScheduleMode = !_isScheduleMode);
                    if (_isScheduleMode) _pickScheduleDate(context);
                  }),
                  _ToolbarButton(icon: Icons.tag, label: 'Hashtag', onTap: () {
                    _captionController.text += ' #';
                    _captionController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _captionController.text.length),
                    );
                  }),
                  _ToolbarButton(icon: Icons.alternate_email, label: 'Mention', onTap: () {
                    _captionController.text += ' @';
                    _captionController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _captionController.text.length),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVisibilityPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Who can see this?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...UpdateVisibility.values.map((v) => ListTile(
              leading: Icon(_visibilityIcon(v), size: 20, color: _visibility == v ? kUpdatesColor : AppColors.textTertiary),
              title: Text(_visibilityLabel(v), style: TextStyle(fontWeight: _visibility == v ? FontWeight.w600 : FontWeight.w400)),
              trailing: _visibility == v ? const Icon(Icons.check_circle, size: 20, color: kUpdatesColor) : null,
              onTap: () {
                setState(() => _visibility = v);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _pickScheduleDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (time != null && mounted) {
        setState(() => _scheduledDate = DateTime(date.year, date.month, date.day, time.hour, time.minute));
      }
    }
  }

  void _publish(BuildContext context) {
    HapticFeedback.heavyImpact();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isScheduleMode ? 'Update scheduled!' : 'Update published!'),
        backgroundColor: kUpdatesColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDiscardDialog(BuildContext context) {
    if (_captionController.text.isEmpty && _mediaCount == 0 && !_isPollMode) {
      Navigator.pop(context);
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Discard update?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: const Text('Your draft will be lost.', style: TextStyle(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep editing', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () { Navigator.pop(context); Navigator.pop(context); },
            child: const Text('Discard', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showPreviewSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: controller,
            children: [
              const Center(
                child: Text('Preview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: kUpdatesColorLight,
                          child: Text('W', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kUpdatesColor)),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Wizdom Shop', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                            Text('Just now', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                          ],
                        ),
                        const Spacer(),
                        Icon(_visibilityIcon(_visibility), size: 16, color: AppColors.textTertiary),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(_captionController.text, style: const TextStyle(fontSize: 14, height: 1.4)),
                    if (_mediaCount > 0) ...[
                      const SizedBox(height: 10),
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: kUpdatesColor.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text('${_mediaCount} media attachment(s)', style: TextStyle(color: kUpdatesColor.withOpacity(0.5))),
                        ),
                      ),
                    ],
                    if (_isPollMode) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: kUpdatesColor.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: kUpdatesColor.withOpacity(0.15)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_pollQuestionController.text.isNotEmpty)
                              Text(_pollQuestionController.text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            ..._pollOptionControllers.where((c) => c.text.isNotEmpty).map((c) => Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Text(c.text, style: const TextStyle(fontSize: 12)),
                            )),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _visibilityIcon(UpdateVisibility v) => switch (v) {
        UpdateVisibility.publicAll => Icons.public,
        UpdateVisibility.followersOnly => Icons.people,
        UpdateVisibility.specificPeople => Icons.person,
        UpdateVisibility.privateOnly => Icons.lock,
      };

  String _visibilityLabel(UpdateVisibility v) => switch (v) {
        UpdateVisibility.publicAll => 'Public',
        UpdateVisibility.followersOnly => 'Followers',
        UpdateVisibility.specificPeople => 'Specific',
        UpdateVisibility.privateOnly => 'Private',
      };

  IconData _contentTypeIcon(UpdateContentType t) => switch (t) {
        UpdateContentType.image => Icons.image,
        UpdateContentType.video => Icons.videocam,
        UpdateContentType.audio => Icons.graphic_eq,
        _ => Icons.attach_file,
      };

  String _formatDate(DateTime d) => '${d.day}/${d.month} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
}

// ─── Toolbar Button ─────────────────────────────────────────────────────────

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToolbarButton({required this.icon, required this.label, this.isActive = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: isActive ? kUpdatesColor : AppColors.textTertiary),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(fontSize: 9, color: isActive ? kUpdatesColor : AppColors.textTertiary, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
            ],
          ),
        ),
      ),
    );
  }
}
