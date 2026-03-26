/// GO Screen 7 — Favorites Hub
/// Categorized grid (People/Businesses/Services/Internal),
/// entity cards, relationship insights, bulk management, discovery

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/go_models.dart';
import '../providers/go_provider.dart';
import '../widgets/go_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class GoFavoritesScreen extends StatefulWidget {
  const GoFavoritesScreen({super.key});
  @override
  State<GoFavoritesScreen> createState() => _GoFavoritesScreenState();
}

class _GoFavoritesScreenState extends State<GoFavoritesScreen> {
  FavoriteCategory? _filter;
  final _searchCtrl = TextEditingController();
  String _search = '';

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoProvider>(
      builder: (context, provider, _) {
        var favs = provider.favorites;
        if (_filter != null) favs = favs.where((f) => f.category == _filter).toList();
        if (_search.isNotEmpty) favs = favs.where((f) => f.name.toLowerCase().contains(_search.toLowerCase())).toList();

        final catCounts = <FavoriteCategory, int>{};
        for (final f in provider.favorites) { catCounts[f.category] = (catCounts[f.category] ?? 0) + 1; }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: const GoAppBar(title: 'Favorites'),
          body: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    hintText: 'Search favorites...', prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true, fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.recommendations.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kGoColor.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kGoColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI suggests: ${ai.recommendations.first.name}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kGoColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Category pills
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  children: [
                    _Pill(label: 'All (${provider.favorites.length})', selected: _filter == null, onTap: () => setState(() => _filter = null)),
                    ...FavoriteCategory.values.map((c) => _Pill(
                      label: '${c.name[0].toUpperCase()}${c.name.substring(1)} (${catCounts[c] ?? 0})',
                      selected: _filter == c,
                      onTap: () => setState(() => _filter = c),
                    )),
                  ],
                ),
              ),
              // Stats bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(children: [
                  Text('${favs.length} favorites', style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.sort, size: 14),
                    label: const Text('Sort', style: TextStyle(fontSize: 11)),
                    onPressed: () {},
                    style: TextButton.styleFrom(foregroundColor: kGoColor, padding: EdgeInsets.zero, minimumSize: const Size(50, 24)),
                  ),
                ]),
              ),
              // Grid
              Expanded(
                child: favs.isEmpty
                  ? const GoEmptyState(icon: Icons.favorite_border, title: 'No favorites', message: 'Add parties you transact with often.')
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.85),
                      itemCount: favs.length,
                      itemBuilder: (_, i) => _FavoriteGridCard(fav: favs[i], onTap: () => Navigator.pushNamed(context, '/go/favorite-detail', arguments: favs[i].id)),
                    ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            backgroundColor: kGoColor,
            child: const Icon(Icons.person_add, color: Colors.white),
          ),
        );
      },
    );
  }
}

class _Pill extends StatelessWidget {
  final String label; final bool selected; final VoidCallback onTap;
  const _Pill({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 6),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(color: selected ? kGoColor : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: selected ? kGoColor : const Color(0xFFE5E7EB))),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: selected ? Colors.white : const Color(0xFF6B7280))),
      ),
    ),
  );
}

class _FavoriteGridCard extends StatelessWidget {
  final FavoriteEntity fav; final VoidCallback onTap;
  const _FavoriteGridCard({required this.fav, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE5E7EB)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: _catColor.withOpacity(0.15),
              child: Text(fav.name.substring(0, 1), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _catColor)),
            ),
            const SizedBox(height: 10),
            Text(fav.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(fav.role, style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: _catColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(fav.category.name, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: _catColor)),
            ),
            const SizedBox(height: 4),
            Text('${fav.transactionCount} txns', style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }

  Color get _catColor {
    switch (fav.category) {
      case FavoriteCategory.people: return kGoColor;
      case FavoriteCategory.businesses: return kGoInfo;
      case FavoriteCategory.services: return kGoPurple;
      case FavoriteCategory.internal: return kGoWarning;
    }
  }
}
