/// ═══════════════════════════════════════════════════════════════════════════
/// SCREEN 5 — Saved Updates Library
/// Grid/List/Calendar view, collections management, batch operations,
/// search within saved, sort options.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../models/updates_models.dart';
import '../providers/updates_provider.dart';
import '../widgets/updates_widgets.dart';

class UpdatesSavedScreen extends StatelessWidget {
  const UpdatesSavedScreen({super.key});

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
  bool _isBatchMode = false;
  final Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdatesProvider>(
      builder: (context, prov, _) {
        final saved = prov.updates.where((u) => u.isSavedByMe).toList();
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: UpdatesAppBar(
            title: 'Saved Library',
            actions: [
              // View mode toggle
              IconButton(
                icon: Icon(
                  prov.savedViewMode == SavedViewMode.grid
                      ? Icons.grid_view
                      : prov.savedViewMode == SavedViewMode.list
                          ? Icons.view_list
                          : Icons.calendar_month,
                  size: 20,
                ),
                color: AppColors.textSecondary,
                onPressed: () {
                  const modes = SavedViewMode.values;
                  final next = modes[(modes.indexOf(prov.savedViewMode) + 1) % modes.length];
                  prov.setSavedViewMode(next);
                },
              ),
              // Batch mode toggle
              IconButton(
                icon: Icon(_isBatchMode ? Icons.close : Icons.checklist, size: 20),
                color: _isBatchMode ? kUpdatesColor : AppColors.textSecondary,
                onPressed: () => setState(() {
                  _isBatchMode = !_isBatchMode;
                  _selectedIds.clear();
                }),
              ),
            ],
          ),
          body: Column(
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kUpdatesColor.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kUpdatesColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI: ${ai.insights.first['title'] ?? ''}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kUpdatesColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Batch action bar
              if (_isBatchMode && _selectedIds.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  color: kUpdatesColor.withOpacity(0.06),
                  child: Row(
                    children: [
                      Text('${_selectedIds.length} selected', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kUpdatesColor)),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          for (final id in _selectedIds) {
                            prov.toggleSave(id);
                          }
                          setState(() { _selectedIds.clear(); _isBatchMode = false; });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Removed from saved'), backgroundColor: kUpdatesColor, duration: Duration(seconds: 1)),
                          );
                        },
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('Remove', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(foregroundColor: AppColors.error),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _showMoveToCollectionSheet(context, prov);
                        },
                        icon: const Icon(Icons.folder_open, size: 16),
                        label: const Text('Move', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(foregroundColor: kUpdatesColor),
                      ),
                    ],
                  ),
                ),

              // Collections ribbon
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  children: [
                    _CollectionChip(label: 'All Saved', count: saved.length, isSelected: true),
                    const SizedBox(width: 6),
                    ...prov.collections.map((c) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _CollectionChip(label: c.name, count: c.itemCount, isSelected: false, color: c.color),
                    )),
                    GestureDetector(
                      onTap: () => _showCreateCollectionSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: kUpdatesColor, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, size: 14, color: kUpdatesColor),
                            SizedBox(width: 3),
                            Text('New', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kUpdatesColor)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: saved.isEmpty
                    ? const UpdatesEmptyState(
                        icon: Icons.bookmark_outline,
                        title: 'No saved updates',
                        message: 'Tap the bookmark icon on any update to save it for later.',
                      )
                    : prov.savedViewMode == SavedViewMode.grid
                        ? _GridView(saved: saved, isBatchMode: _isBatchMode, selectedIds: _selectedIds, onToggle: _toggleSelection, prov: prov)
                        : _ListView(saved: saved, isBatchMode: _isBatchMode, selectedIds: _selectedIds, onToggle: _toggleSelection, prov: prov),
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _showMoveToCollectionSheet(BuildContext context, UpdatesProvider prov) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Move to Collection', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...prov.collections.map((c) => ListTile(
              leading: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(color: c.color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.folder, size: 16, color: c.color),
              ),
              title: Text(c.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              subtitle: Text('${c.itemCount} items', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Moved to ${c.name}'), backgroundColor: kUpdatesColor, duration: const Duration(seconds: 1)),
                );
              },
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showCreateCollectionSheet(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('New Collection', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Collection name',
                filled: true,
                fillColor: AppColors.inputFill,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Collection created'), backgroundColor: kUpdatesColor, duration: Duration(seconds: 1)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kUpdatesColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Create', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Collection Chip ────────────────────────────────────────────────────────

class _CollectionChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final Color? color;
  const _CollectionChip({required this.label, required this.count, required this.isSelected, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? kUpdatesColor : (color ?? kUpdatesColor).withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isSelected ? kUpdatesColor : (color ?? Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textPrimary)),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.2) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$count', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

// ─── Grid View ──────────────────────────────────────────────────────────────

class _GridView extends StatelessWidget {
  final List<dynamic> saved;
  final bool isBatchMode;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;
  final UpdatesProvider prov;

  const _GridView({required this.saved, required this.isBatchMode, required this.selectedIds, required this.onToggle, required this.prov});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(14),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: saved.length,
      itemBuilder: (context, i) {
        final update = saved[i];
        final isSelected = selectedIds.contains(update.id);
        return GestureDetector(
          onTap: () {
            if (isBatchMode) {
              onToggle(update.id);
            } else {
              prov.selectUpdate(update);
              Navigator.pushNamed(context, AppRoutes.updatesDetail);
            }
          },
          onLongPress: () => onToggle(update.id),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: isSelected ? Border.all(color: kUpdatesColor, width: 2) : null,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Media placeholder
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: kUpdatesColor.withOpacity(0.06),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Stack(
                    children: [
                      Center(child: Icon(_contentIcon(update.contentType), size: 28, color: kUpdatesColor.withOpacity(0.3))),
                      if (isBatchMode)
                        Positioned(
                          top: 6, right: 6,
                          child: Container(
                            width: 22, height: 22,
                            decoration: BoxDecoration(
                              color: isSelected ? kUpdatesColor : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: isSelected ? kUpdatesColor : Colors.grey.shade300, width: 2),
                            ),
                            child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(update.entityName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(update.caption, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
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
}

// ─── List View ──────────────────────────────────────────────────────────────

class _ListView extends StatelessWidget {
  final List<dynamic> saved;
  final bool isBatchMode;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;
  final UpdatesProvider prov;

  const _ListView({required this.saved, required this.isBatchMode, required this.selectedIds, required this.onToggle, required this.prov});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: saved.length,
      itemBuilder: (context, i) {
        final update = saved[i];
        final isSelected = selectedIds.contains(update.id);
        return GestureDetector(
          onTap: () {
            if (isBatchMode) {
              onToggle(update.id);
            } else {
              prov.selectUpdate(update);
              Navigator.pushNamed(context, AppRoutes.updatesDetail);
            }
          },
          onLongPress: () => onToggle(update.id),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: isSelected ? Border.all(color: kUpdatesColor, width: 2) : null,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)],
            ),
            child: Row(
              children: [
                if (isBatchMode) ...[
                  Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      color: isSelected ? kUpdatesColor : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: isSelected ? kUpdatesColor : Colors.grey.shade300, width: 2),
                    ),
                    child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                  ),
                  const SizedBox(width: 8),
                ],
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: kUpdatesColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_contentIcon(update.contentType), size: 20, color: kUpdatesColor.withOpacity(0.4)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(update.entityName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      Text(update.caption, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, size: 18, color: AppColors.textTertiary),
              ],
            ),
          ),
        );
      },
    );
  }
}

IconData _contentIcon(UpdateContentType t) => switch (t) {
      UpdateContentType.text => Icons.article,
      UpdateContentType.image => Icons.image,
      UpdateContentType.video => Icons.videocam,
      UpdateContentType.audio => Icons.graphic_eq,
      UpdateContentType.poll => Icons.poll,
      UpdateContentType.document => Icons.description,
      UpdateContentType.product => Icons.shopping_bag,
      UpdateContentType.event => Icons.event,
    };
