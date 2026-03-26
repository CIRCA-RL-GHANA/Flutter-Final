/// ═══════════════════════════════════════════════════════════════════════════
/// SCREEN 10 — Interests Management
/// Category-based interest grid, weight sliders, feed preview toggle,
/// suggestion AI, follow/unfollow interests.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../models/updates_models.dart';
import '../providers/updates_provider.dart';
import '../widgets/updates_widgets.dart';

class UpdatesInterestsScreen extends StatelessWidget {
  const UpdatesInterestsScreen({super.key});

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
  InterestCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdatesProvider>(
      builder: (context, prov, _) {
        const categories = InterestCategory.values;
        final filtered = _selectedCategory == null
            ? prov.interests
            : prov.interests.where((i) => i.category == _selectedCategory).toList();
        final followingCount = prov.interests.where((i) => i.isFollowing).length;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: UpdatesAppBar(
            title: 'Interests',
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: kUpdatesColor.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                    child: Text('$followingCount following', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kUpdatesColor)),
                  ),
                ),
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

              // Header card
              Container(
                margin: const EdgeInsets.fromLTRB(14, 8, 14, 4),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kUpdatesColor.withOpacity(0.06), kUpdatesAccent.withOpacity(0.04)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 24, color: kUpdatesColor),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Personalize Your Feed', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                          Text('Follow interests to see more relevant updates in your feed.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Category filters
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  children: [
                    _CategoryChip(
                      label: 'All',
                      icon: Icons.apps,
                      isSelected: _selectedCategory == null,
                      onTap: () => setState(() => _selectedCategory = null),
                    ),
                    ...categories.map((c) => Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: _CategoryChip(
                        label: c.name,
                        icon: _categoryIcon(c),
                        isSelected: _selectedCategory == c,
                        onTap: () => setState(() => _selectedCategory = c),
                      ),
                    )),
                  ],
                ),
              ),

              // Interests grid
              Expanded(
                child: filtered.isEmpty
                    ? const UpdatesEmptyState(
                        icon: Icons.explore,
                        title: 'No interests found',
                        message: 'Try selecting a different category.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) => _InterestCard(
                          interest: filtered[i],
                          onToggle: () {
                            HapticFeedback.lightImpact();
                            prov.toggleInterest(filtered[i].id);
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _categoryIcon(InterestCategory c) => switch (c) {
        InterestCategory.business => Icons.business,
        InterestCategory.technology => Icons.computer,
        InterestCategory.social => Icons.restaurant,
        InterestCategory.finance => Icons.spa,
        InterestCategory.health => Icons.favorite,
        InterestCategory.entertainment => Icons.movie,
        InterestCategory.logistics => Icons.sports,
        InterestCategory.education => Icons.school,
      };
}

// ─── Category Chip ──────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? kUpdatesColor : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isSelected ? kUpdatesColor : Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : AppColors.textTertiary),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ─── Interest Card ──────────────────────────────────────────────────────────

class _InterestCard extends StatefulWidget {
  final UserInterest interest;
  final VoidCallback onToggle;
  const _InterestCard({required this.interest, required this.onToggle});

  @override
  State<_InterestCard> createState() => _InterestCardState();
}

class _InterestCardState extends State<_InterestCard> {
  late double _weight;

  @override
  void initState() {
    super.initState();
    _weight = widget.interest.weight;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: widget.interest.isFollowing
            ? Border.all(color: kUpdatesColor.withOpacity(0.3))
            : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: kUpdatesColor.withOpacity(widget.interest.isFollowing ? 0.12 : 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _categoryIcon(widget.interest.category),
                  size: 18,
                  color: widget.interest.isFollowing ? kUpdatesColor : AppColors.textTertiary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.interest.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(color: kUpdatesColor.withOpacity(0.06), borderRadius: BorderRadius.circular(6)),
                          child: Text(widget.interest.category.name, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: kUpdatesColor)),
                        ),
                        const SizedBox(width: 6),
                        Text('${(widget.interest.relevanceScore * 100).toStringAsFixed(0)}% match', style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: widget.onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.interest.isFollowing ? kUpdatesColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: kUpdatesColor),
                  ),
                  child: Text(
                    widget.interest.isFollowing ? 'Following' : 'Follow',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: widget.interest.isFollowing ? Colors.white : kUpdatesColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Weight slider (only when following)
          if (widget.interest.isFollowing) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Feed priority:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: kUpdatesColor,
                      inactiveTrackColor: kUpdatesColor.withOpacity(0.1),
                      thumbColor: kUpdatesColor,
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    ),
                    child: Slider(
                      value: _weight,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      onChanged: (v) => setState(() => _weight = v),
                    ),
                  ),
                ),
                Text('${(_weight * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kUpdatesColor)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  IconData _categoryIcon(InterestCategory c) => switch (c) {
        InterestCategory.business => Icons.business,
        InterestCategory.technology => Icons.computer,
        InterestCategory.social => Icons.restaurant,
        InterestCategory.finance => Icons.spa,
        InterestCategory.health => Icons.favorite,
        InterestCategory.entertainment => Icons.movie,
        InterestCategory.logistics => Icons.sports,
        InterestCategory.education => Icons.school,
      };
}
