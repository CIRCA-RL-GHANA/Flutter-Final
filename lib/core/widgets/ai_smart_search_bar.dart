import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_insights_notifier.dart';
import '../theme/app_colors.dart';

/// AI-powered smart search bar with animated results overlay.
///
/// Usage: Provide an [AIInsightsNotifier] in your widget tree and pass
/// [documents] as the list of items to search through.
class AISmartSearchBar extends StatefulWidget {
  final List<Map<String, String>> documents; // {id, text}
  final ValueChanged<String>? onResultSelected;
  final String hintText;
  final Color? accentColor;

  const AISmartSearchBar({
    super.key,
    required this.documents,
    this.onResultSelected,
    this.hintText  = 'AI-powered search…',
    this.accentColor,
  });

  @override
  State<AISmartSearchBar> createState() => _AISmartSearchBarState();
}

class _AISmartSearchBarState extends State<AISmartSearchBar> {
  final TextEditingController _ctrl         = TextEditingController();
  final FocusNode             _focus         = FocusNode();
  bool                        _showResults   = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    if (v.length < 2) {
      context.read<AIInsightsNotifier>().clearSearch();
      setState(() => _showResults = false);
      return;
    }

    setState(() => _showResults = true);
    // debounce: trigger after 300 ms of inactivity
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_ctrl.text == v && mounted) {
        context.read<AIInsightsNotifier>().smartSearch(
          query:     v,
          documents: widget.documents,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.accentColor ?? AppColors.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search input
        Container(
          decoration: BoxDecoration(
            color:        Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color:      Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset:     const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller:  _ctrl,
            focusNode:   _focus,
            onChanged:   _onChanged,
            style:       const TextStyle(fontSize: 14),
            decoration:  InputDecoration(
              hintText:        widget.hintText,
              hintStyle:       const TextStyle(
                  color: AppColors.textTertiary, fontSize: 13),
              prefixIcon:      Icon(Icons.auto_awesome, color: color, size: 18),
              suffixIcon: Consumer<AIInsightsNotifier>(
                builder: (_, notifier, __) => notifier.loadingSearch
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : _ctrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: () {
                              _ctrl.clear();
                              context.read<AIInsightsNotifier>().clearSearch();
                              setState(() => _showResults = false);
                            },
                          )
                        : const SizedBox.shrink(),
              ),
              border:          InputBorder.none,
              contentPadding:  const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
            ),
          ),
        ),

        // Results dropdown
        if (_showResults)
          Consumer<AIInsightsNotifier>(
            builder: (context, notifier, _) {
              final results = notifier.searchResults;
              if (results.isEmpty && !notifier.loadingSearch) {
                return const SizedBox.shrink();
              }
              return Container(
                margin:      const EdgeInsets.only(top: 4),
                constraints: const BoxConstraints(maxHeight: 200),
                decoration:  BoxDecoration(
                  color:        Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color:      Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset:     const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.builder(
                  padding:     const EdgeInsets.symmetric(vertical: 6),
                  shrinkWrap:  true,
                  itemCount:   results.length,
                  itemBuilder: (_, i) {
                    final r     = results[i];
                    final docId = r['id'] as String? ?? '';
                    // Find original text from documents
                    final doc  = widget.documents
                        .where((d) => d['id'] == docId)
                        .firstOrNull;
                    final text = doc?['text'] ?? docId;
                    final score = ((r['score'] as num?)?.toDouble() ?? 0)
                        .toStringAsFixed(2);
                    return ListTile(
                      dense:     true,
                      leading:   Icon(Icons.search, color: color, size: 16),
                      title:     Text(text,
                          maxLines:  1,
                          overflow:  TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13)),
                      trailing:  Text(
                        'score: $score',
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textTertiary),
                      ),
                      onTap: () {
                        _focus.unfocus();
                        setState(() => _showResults = false);
                        widget.onResultSelected?.call(docId);
                      },
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}
