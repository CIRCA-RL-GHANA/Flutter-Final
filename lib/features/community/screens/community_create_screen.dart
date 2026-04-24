/// ═══════════════════════════════════════════════════════════════════════════
/// COMMUNITY MODULE — Create Community Screen
/// User picks type → fills details → creates a community space.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/ai_insights_notifier.dart';
import 'community_hub_screen.dart' show kCommunityColor, kCommunityColorDark;

const _types = [
  {'type': 'library',  'label': 'Library',  'icon': Icons.local_library,  'color': 0xFF0F766E, 'hint': 'Book clubs, e-book curation, reading schedules'},
  {'type': 'playlist', 'label': 'Playlist', 'icon': Icons.queue_music,     'color': 0xFF7C3AED, 'hint': 'Music/video sequences, collaborative curation'},
  {'type': 'theater',  'label': 'Theater',  'icon': Icons.theaters,        'color': 0xFFDC2626, 'hint': 'Synchronized movie/show viewing groups'},
  {'type': 'fair',     'label': 'Fair',     'icon': Icons.storefront,      'color': 0xFFD97706, 'hint': 'Pop-up marketplace or artist showcase'},
  {'type': 'hub',      'label': 'Hub',      'icon': Icons.hub,             'color': 0xFF2563EB, 'hint': 'Topical forum, knowledge base, discussion'},
  {'type': 'hangout',  'label': 'Hangout',  'icon': Icons.event,           'color': 0xFF059669, 'hint': 'Schedule events — virtual or physical'},
  {'type': 'journal',  'label': 'Journal',  'icon': Icons.book,            'color': 0xFF6366F1, 'hint': 'Blog, shared notes, community documentation'},
];

class CommunityCreateScreen extends StatefulWidget {
  final String? initialType;
  const CommunityCreateScreen({super.key, this.initialType});

  @override
  State<CommunityCreateScreen> createState() => _CommunityCreateScreenState();
}

class _CommunityCreateScreenState extends State<CommunityCreateScreen> {
  String? _selectedType;
  String _visibility = 'public';
  bool _creating = false;

  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic>? get _selectedArchetype => _selectedType == null
      ? null
      : _types.firstWhere((t) => t['type'] == _selectedType, orElse: () => _types.first);

  @override
  Widget build(BuildContext context) {
    return Consumer<AIInsightsNotifier>(
      builder: (context, ai, _) {
        final arch = _selectedArchetype;
        final color = arch != null ? Color(arch['color'] as int) : kCommunityColor;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: kCommunityColorDark,
            foregroundColor: Colors.white,
            title: const Text('Create Community', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Step 1: Pick type ─────────────────────────────────
                const Text('Choose Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Each type enables a different way to connect.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 12),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 2.2, crossAxisSpacing: 8, mainAxisSpacing: 8,
                  ),
                  itemCount: _types.length,
                  itemBuilder: (ctx, i) {
                    final t = _types[i];
                    final c = Color(t['color'] as int);
                    final isSelected = _selectedType == t['type'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedType = t['type'] as String),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected ? c : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? c : AppColors.inputBorder, width: 2),
                          boxShadow: isSelected ? [BoxShadow(color: c.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))] : [],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(children: [
                          Icon(t['icon'] as IconData, color: isSelected ? Colors.white : c, size: 20),
                          const SizedBox(width: 8),
                          Text(t['label'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isSelected ? Colors.white : AppColors.textPrimary)),
                        ]),
                      ),
                    );
                  },
                ),

                if (arch != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.2))),
                    child: Row(children: [
                      Icon(Icons.info_outline, color: color, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(arch['hint'] as String, style: TextStyle(fontSize: 12, color: color))),
                    ]),
                  ),
                ],

                const SizedBox(height: 24),

                // ── AI insight ────────────────────────────────────────
                if (ai.insights.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: kCommunityColor.withOpacity(0.07), borderRadius: BorderRadius.circular(10), border: Border.all(color: kCommunityColor.withOpacity(0.2))),
                    child: Row(children: [
                      const Icon(Icons.auto_awesome, color: kCommunityColor, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(ai.insights.first['title'] ?? '', style: const TextStyle(fontSize: 12))),
                    ]),
                  ),

                // ── Step 2: Details ────────────────────────────────────
                const Text('Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Community Name',
                    hintText: 'e.g. Accra Book Club',
                    filled: true, fillColor: AppColors.inputFill,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description (optional)',
                    filled: true, fillColor: AppColors.inputFill,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _tagsCtrl,
                  decoration: InputDecoration(
                    labelText: 'Tags (comma-separated)',
                    hintText: 'e.g. books, africa, fiction',
                    filled: true, fillColor: AppColors.inputFill,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),

                const SizedBox(height: 16),
                const Text('Visibility', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(children: [
                  for (final v in [
                    {'val': 'public', 'label': 'Public', 'icon': Icons.public},
                    {'val': 'invite_only', 'label': 'Invite Only', 'icon': Icons.lock_open},
                    {'val': 'private', 'label': 'Private', 'icon': Icons.lock},
                  ]) ...[
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _visibility = v['val'] as String),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _visibility == v['val'] ? color : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _visibility == v['val'] ? color : AppColors.inputBorder),
                          ),
                          child: Column(children: [
                            Icon(v['icon'] as IconData, size: 18, color: _visibility == v['val'] ? Colors.white : AppColors.textSecondary),
                            const SizedBox(height: 4),
                            Text(v['label'] as String, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _visibility == v['val'] ? Colors.white : AppColors.textPrimary), textAlign: TextAlign.center),
                          ]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ]),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (_selectedType == null || _creating) ? null : _create,
                    icon: _creating
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.check_circle_outline),
                    label: Text(_creating ? 'Creating…' : 'Create Community'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      disabledBackgroundColor: AppColors.inputBorder,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _create() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a community name.')));
      return;
    }
    setState(() => _creating = true);
    await Future.delayed(const Duration(milliseconds: 1200)); // API stub
    if (mounted) {
      setState(() => _creating = false);
      Navigator.pushReplacementNamed(context, AppRoutes.communityDetail, arguments: {
        'name': _nameCtrl.text.trim(),
        'type': _selectedType,
        'members': '1',
        'isNew': true,
      });
    }
  }
}
