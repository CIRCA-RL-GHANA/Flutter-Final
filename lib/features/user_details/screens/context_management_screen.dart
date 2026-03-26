/// ═══════════════════════════════════════════════════════════════════════════
/// Screen 2: Context Management & Switcher
/// Search + filter, context grid, archived section, create/merge actions
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../prompt/models/rbac_models.dart';
import '../../prompt/providers/context_provider.dart';
import '../models/user_details_models.dart';
import '../providers/user_details_provider.dart';
import '../widgets/shared_widgets.dart';

class ContextManagementScreen extends StatelessWidget {
  const ContextManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserDetailsProvider, ContextProvider>(
      builder: (context, udp, ctxProvider, _) {
        final filtered = udp.filterContexts(ctxProvider.availableContexts);
        final archived = udp.archivedContexts;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FC),
          appBar: const ModuleHeader(
            title: 'Your Contexts',
            contextColor: Color(0xFF6366F1),
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

              // ─── Search Bar ──────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: TextField(
                  onChanged: udp.setContextSearch,
                  decoration: InputDecoration(
                    hintText: 'Search contexts...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),

              // ─── Filter Chips ────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: ContextFilter.values.map((f) {
                    final selected = udp.contextFilter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(f.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.textSecondary)),
                        selected: selected,
                        onSelected: (_) {
                          HapticFeedback.selectionClick();
                          udp.setContextFilter(f);
                        },
                        selectedColor: const Color(0xFF6366F1),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                    );
                  }).toList(),
                ),
              ),

              // ─── Context Grid ────────────────────────────
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.swap_horiz, size: 48, color: AppColors.textTertiary.withOpacity(0.4)),
                            const SizedBox(height: 12),
                            const Text('No contexts found', style: TextStyle(color: AppColors.textTertiary)),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                        children: [
                          // Active Contexts
                          ...filtered.map((ctx) => _ContextTile(
                                context: ctx,
                                isActive: ctx.id == ctxProvider.activeContext.id,
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  ctxProvider.switchContext(ctx);
                                  Navigator.pop(context);
                                },
                                onArchive: () => udp.archiveContext(ctx),
                              )),

                          // Archived Section
                          if (archived.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            SectionCard(
                              child: CollapsibleSection(
                                title: 'Archived (${archived.length})',
                                icon: Icons.archive_outlined,
                                iconColor: AppColors.textTertiary,
                                initiallyExpanded: false,
                                child: Column(
                                  children: archived.map((ctx) => _ArchivedTile(
                                        context: ctx,
                                        onRestore: () => udp.restoreContext(ctx),
                                      )).toList(),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),

          // ─── Bottom Action Bar ──────────────────────────
          bottomNavigationBar: Container(
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
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/user-details/create-entity'),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Create New Context', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Context Tile
// ═══════════════════════════════════════════════════════════════════════════

class _ContextTile extends StatelessWidget {
  final AppContextModel context;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onArchive;

  const _ContextTile({
    required this.context,
    required this.isActive,
    required this.onTap,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context2) {
    final color = contextTypeColor(context.entityType);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SectionCard(
        borderColor: isActive ? color : null,
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: contextTypeGradient(context.entityType),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Center(
                    child: Text(
                      context.name.isNotEmpty ? context.name[0].toUpperCase() : '?',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              context.name,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Active',
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.subtitle,
                        style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          StatusBadge(
                            label: context.roleLabel,
                            color: RoleColors.forRole(context.role),
                          ),
                          const SizedBox(width: 6),
                          StatusBadge(
                            label: context.entityType.toString().split('.').last,
                            color: color,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Archive
                if (!isActive)
                  IconButton(
                    icon: const Icon(Icons.archive_outlined, size: 18),
                    color: AppColors.textTertiary,
                    onPressed: onArchive,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArchivedTile extends StatelessWidget {
  final AppContextModel context;
  final VoidCallback onRestore;
  const _ArchivedTile({required this.context, required this.onRestore});

  @override
  Widget build(BuildContext context2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.textTertiary.withOpacity(0.1),
            child: Text(
              context.name.isNotEmpty ? context.name[0] : '?',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textTertiary),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(context.name, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: onRestore,
            child: const Text('Restore', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
