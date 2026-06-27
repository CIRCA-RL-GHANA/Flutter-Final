/// 
/// U3: OMNISCIENT SEARCH Screen
/// Cross-module search with category filters, recent searches,
/// quick suggestions, real-time results
/// 
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive.dart';
import '../../../core/services/ai_service.dart';
import '../models/utility_models.dart';
import '../providers/utility_provider.dart';
import '../widgets/shared_widgets.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  List<Map<String, dynamic>> _aiResults = [];
  bool _aiLoading = false;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (mounted) setState(() => _focused = _focusNode.hasFocus);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _runAISearch(String query, UtilityProvider prov) async {
    if (query.length < 2) {
      setState(() { _aiResults = []; _aiLoading = false; });
      return;
    }
    setState(() => _aiLoading = true);
    try {
      final aiService = context.read<AIService>();
      // Build lightweight document list from existing results for re-ranking
      final docs = prov.searchResults
          .map((r) => {'id': r.title, 'text': '${r.title} ${r.subtitle}'})
          .toList();
      if (docs.isNotEmpty) {
        final ranked = await aiService.searchDocuments(
          query: query,
          documents: docs,
          topN: 8,
        );
        if (mounted) setState(() => _aiResults = (ranked as List?)?.cast<Map<String, dynamic>>() ?? []);
      }
    } catch (_) {
      // AI ranking is best-effort  fall back to standard results silently
    } finally {
      if (mounted) setState(() => _aiLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UtilityProvider>(
      builder: (context, prov, _) {
        final hasQuery = prov.searchQuery.isNotEmpty;

        return Scaffold(
          backgroundColor: IveTokens.voidColor,
          appBar: UtilityAppBar(
            title: 'Search',
            actions: [
              if (hasQuery)
                IconButton(
                  icon: const Icon(Icons.clear, size: 20, color: IveTokens.inkColor),
                  onPressed: () {
                    _controller.clear();
                    prov.clearSearch();
                  },
                ),
              const SizedBox(width: 4),
            ],
          ),
          body: Column(
            children: [
              //  Genie-style search input (OmniSearch P1) 
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    // Genie gold border on focus, hairline at rest
                    color: const Color(0xFF0E0E1A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _focused
                          ? IveTokens.genieLine
                          : IveTokens.hairColor,
                      width: _focused ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Spark appears on focus (Move 16  OmniSearch Genie focus)
                      Padding(
                        padding: const EdgeInsets.only(left: 14),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: _focused
                              ? const Icon(
                                  Icons.auto_awesome_rounded,
                                  key: ValueKey('spark'),
                                  color: IveTokens.genieColor,
                                  size: 18,
                                )
                              : const Icon(
                                  Icons.search_rounded,
                                  key: ValueKey('search'),
                                  color: IveTokens.muteColor,
                                  size: 18,
                                ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          onChanged: (q) {
                            prov.updateSearchQuery(q);
                            _runAISearch(q, prov);
                          },
                          onSubmitted: (q) {
                            if (q.isNotEmpty) prov.addRecentSearch(q);
                          },
                          style: const TextStyle(
                            color: Color(0xFFE8E8F0),
                            fontSize: 15,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Search everything',
                            hintStyle: TextStyle(color: Color(0xFF6B6B88), fontSize: 15),
                            border: InputBorder.none,
              filled: false,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              //  Category Chips 
              const SizedBox(height: 12),
              UtilityFilterChipRow(
                labels: SearchCategory.values.map((c) => _categoryLabel(c)).toList(),
                selectedIndex: prov.searchCategory.index,
                onSelected: (i) => prov.setSearchCategory(SearchCategory.values[i]),
                selectedColor: const Color(0xFF3B82F6),
              ),

              const SizedBox(height: 8),

              //  AI Search Banner 
              if (hasQuery)
                _AISearchBanner(
                  isLoading: _aiLoading,
                  aiResults: _aiResults,
                  onChipTap: (kw) {
                    _controller.text = kw;
                    prov.updateSearchQuery(kw);
                    _runAISearch(kw, prov);
                  },
                ),

              //  Content 
              Expanded(
                child: hasQuery
                    ? _SearchResults(
                        results: prov.searchResults,
                        aiRankedIds: _aiResults.map((r) => r['id']?.toString() ?? '').toList(),
                      )
                    : _SearchIdleView(prov: prov, controller: _controller),
              ),
            ],
          ),
        );
      },
    );
  }

  String _categoryLabel(SearchCategory c) {
    switch (c) {
      case SearchCategory.all: return 'All';
      case SearchCategory.people: return 'People';
      case SearchCategory.transactions: return 'Transactions';
      case SearchCategory.messages: return 'Messages';
      case SearchCategory.settings: return 'Settings';
      case SearchCategory.help: return 'Help';
      case SearchCategory.products: return 'Products';
      case SearchCategory.orders: return 'Orders';
    }
  }
}

//  Search Idle View 

class _SearchIdleView extends StatelessWidget {
  final UtilityProvider prov;
  final TextEditingController controller;

  const _SearchIdleView({required this.prov, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      children: [
        // Recent Searches
        if (prov.recentSearches.isNotEmpty) ...[
          Row(
            children: [
              Text('Recent searches', style: IveType.callout.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton(
                onPressed: prov.clearRecentSearches,
                style: TextButton.styleFrom(
                  foregroundColor: IveTokens.muteColor,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                ),
                child: Text('Clear', style: IveType.caption.copyWith(color: IveTokens.muteColor)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: prov.recentSearches.map((s) => GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                controller.text = s.query;
                prov.updateSearchQuery(s.query);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: IveTokens.raisedColor,
                  borderRadius: BorderRadius.circular(IveTokens.rChip),
                  border: Border.all(color: IveTokens.hairColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.history, size: 14, color: IveTokens.muteColor),
                    const SizedBox(width: 6),
                    Text(s.query, style: IveType.caption.copyWith(color: IveTokens.ink2Color)),
                  ],
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 20),
        ],

        // Quick Suggestions
        Text('Quick suggestions', style: IveType.callout.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        UtilitySectionCard(
          child: Column(
            children: UtilityProvider.quickSuggestions.map((s) => UtilityActionTile(
              label: s.text,
              icon: s.icon,
              iconColor: const Color(0xFF3B82F6),
              onTap: () {
                controller.text = s.text;
                prov.updateSearchQuery(s.text);
              },
            )).toList(),
          ),
        ),
      ],
    );
  }
}

//  AI Search Banner 

class _AISearchBanner extends StatelessWidget {
  final bool isLoading;
  final List<Map<String, dynamic>> aiResults;
  final void Function(String) onChipTap;

  const _AISearchBanner({
    required this.isLoading,
    required this.aiResults,
    required this.onChipTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 14, height: 14,
              child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF8B5CF6)),
            ),
            SizedBox(width: 8),
            Text('AI re-ranking', style: TextStyle(fontSize: 11, color: Color(0xFF8B5CF6))),
          ],
        ),
      );
    }
    if (aiResults.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, size: 13, color: Color(0xFF8B5CF6)),
          const SizedBox(width: 6),
          Expanded(
            child: Wrap(
              spacing: 4,
              children: aiResults.take(5).map((r) {
                final label = r['id']?.toString() ?? '';
                return GestureDetector(
                  onTap: () => onChipTap(label),
                  child: Chip(
                    label: Text(label, style: const TextStyle(fontSize: 10)),
                    backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    side: BorderSide.none,
                    labelStyle: const TextStyle(color: Color(0xFF8B5CF6)),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

//  Search Results 

class _SearchResults extends StatelessWidget {
  final List<SearchResult> results;
  final List<String> aiRankedIds;
  const _SearchResults({required this.results, this.aiRankedIds = const []});

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const UtilityEmptyState(
        icon: Icons.search_off,
        title: 'No Results Found',
        subtitle: 'Try a different search term or category.',
      );
    }

    // If AI has ranked results, surface them first
    final sorted = aiRankedIds.isEmpty
        ? results
        : [...results]..sort((a, b) {
            final ai = aiRankedIds.indexOf(a.title);
            final bi = aiRankedIds.indexOf(b.title);
            if (ai == -1 && bi == -1) return 0;
            if (ai == -1) return 1;
            if (bi == -1) return -1;
            return ai.compareTo(bi);
          });

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final result = sorted[i];
        final isAITop = aiRankedIds.isNotEmpty && aiRankedIds.indexOf(result.title) < 3 && aiRankedIds.contains(result.title);
        return UtilitySectionCard(
          onTap: result.route != null
              ? () => Navigator.pushNamed(context, result.route!)
              : null,
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: result.iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(result.icon, size: 20, color: result.iconColor),
                  ),
                  if (isAITop)
                    Positioned(
                      top: -4, right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Color(0xFF8B5CF6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.auto_awesome, size: 7, color: IveTokens.inkColor),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      style: IveType.callout.copyWith(fontWeight: isAITop ? FontWeight.w600 : FontWeight.w500),
                    ),
                    Text(
                      result.subtitle,
                      style: IveType.caption.copyWith(color: IveTokens.muteColor),
                    ),
                  ],
                ),
              ),
              UtilityStatusIndicator(
                label: _categoryLabel(result.category),
                color: result.iconColor,
              ),
            ],
          ),
        );
      },
    );
  }

  String _categoryLabel(SearchCategory c) {
    switch (c) {
      case SearchCategory.all: return 'All';
      case SearchCategory.people: return 'People';
      case SearchCategory.transactions: return 'Txn';
      case SearchCategory.messages: return 'Msg';
      case SearchCategory.settings: return 'Settings';
      case SearchCategory.help: return 'Help';
      case SearchCategory.products: return 'Product';
      case SearchCategory.orders: return 'Order';
    }
  }
}
