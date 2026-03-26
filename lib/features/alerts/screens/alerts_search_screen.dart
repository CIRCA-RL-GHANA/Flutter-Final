/// Alerts Screen 1.1 — Advanced Search & Discovery
/// Full-width search bar, grouped results by status, search highlighting,
/// AI suggestions, recent/saved searches

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../models/alerts_models.dart';
import '../providers/alerts_provider.dart';
import '../widgets/alerts_widgets.dart';

class AlertsSearchScreen extends StatefulWidget {
  const AlertsSearchScreen({super.key});

  @override
  State<AlertsSearchScreen> createState() => _AlertsSearchScreenState();
}

class _AlertsSearchScreenState extends State<AlertsSearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AlertsProvider>(
      builder: (context, provider, _) {
        final results = _showResults ? provider.filteredAlerts : <AlertItem>[];
        final pendingResults = results.where((a) => a.isPending).toList();
        final resolvedResults = results.where((a) => a.isResolved).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1A1A1A),
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            titleSpacing: 0,
            title: Container(
              height: 40,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: (v) {
                  provider.setSearchQuery(v);
                  setState(() => _showResults = v.isNotEmpty);
                },
                decoration: const InputDecoration(
                  hintText: 'Search alerts by ID, title, tag...',
                  hintStyle: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                  prefixIcon: Icon(Icons.search, size: 20, color: Color(0xFF9CA3AF)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            actions: [
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _controller.clear();
                    provider.setSearchQuery('');
                    setState(() => _showResults = false);
                  },
                ),
            ],
          ),
          body: _showResults
              ? _buildResults(context, provider, pendingResults, resolvedResults)
              : _buildDiscovery(context, provider),
        );
      },
    );
  }

  Widget _buildDiscovery(BuildContext context, AlertsProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ──── AI SUGGESTIONS (dynamic) ────
          Consumer<AIInsightsNotifier>(
            builder: (ctx, aiNotifier, _) {
              final aiRecs = aiNotifier.recommendations;
              final chips = aiRecs.isNotEmpty
                  ? aiRecs
                      .take(4)
                      .map((r) => r['name']?.toString() ?? r['id']?.toString() ?? '')
                      .where((s) => s.isNotEmpty)
                      .toList()
                  : const [
                      'Unresolved payment issues',
                      'Critical system alerts',
                      'Overdue SLA alerts',
                      'Driver complaints this week',
                    ];
              final isAI = aiRecs.isNotEmpty;
              return AlertsSectionCard(
                title: isAI ? '✨ AI Smart Suggestions' : '🤖 AI Suggestions',
                child: Column(
                  children: chips
                      .map((label) => _SuggestionChip(
                            label: label,
                            onTap: () => _runQuery(label),
                          ))
                      .toList(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // ──── RECENT SEARCHES ────
          if (provider.recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Searches', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                GestureDetector(
                  onTap: provider.clearRecentSearches,
                  child: const Text('Clear', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...provider.recentSearches.map((rs) => _RecentSearchTile(
              search: rs,
              onTap: () => _runQuery(rs.query),
            )),
            const SizedBox(height: 16),
          ],

          // ──── SAVED SEARCHES ────
          if (provider.savedSearches.isNotEmpty) ...[
            const Text('Saved Searches', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...provider.savedSearches.map((ss) => _SavedSearchTile(
              search: ss,
              onTap: () => _runQuery(ss.query.isNotEmpty ? ss.query : ss.name),
            )),
          ],

          // ──── SEARCH TIPS ────
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kAlertsInfoLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡 Search Tips', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kAlertsInfo)),
                const SizedBox(height: 8),
                _tip('Search by ID: TX-2041'),
                _tip('Search by category: payment, shipment'),
                _tip('Search by tag: urgent, critical'),
                _tip('Search by assignee name'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context, AlertsProvider provider, List<AlertItem> pending, List<AlertItem> resolved) {
    if (pending.isEmpty && resolved.isEmpty) {
      return AlertsEmptyState(
        icon: Icons.search_off,
        title: 'No Results',
        message: 'No alerts match "${_controller.text}".\nTry different keywords.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Result count + AI badge
          Row(
            children: [
              Text(
                '${pending.length + resolved.length} result${(pending.length + resolved.length) == 1 ? '' : 's'} for "${_controller.text}"',
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const Spacer(),
              Consumer<AIInsightsNotifier>(
                builder: (ctx, ai, _) => ai.searchResults.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: kAlertsInfo.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, size: 11, color: kAlertsInfo),
                            const SizedBox(width: 3),
                            Text(
                              'AI ranked',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: kAlertsInfo,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ──── PENDING GROUP ────
          if (pending.isNotEmpty) ...[
            _GroupHeader(label: 'Pending', count: pending.length, color: kAlertsColor),
            const SizedBox(height: 8),
            ...pending.map((alert) => PendingAlertCard(
              alert: alert,
              onTap: () => Navigator.pushNamed(context, '/alerts/detail', arguments: alert.id),
            )),
            const SizedBox(height: 16),
          ],

          // ──── RESOLVED GROUP ────
          if (resolved.isNotEmpty) ...[
            _GroupHeader(label: 'Resolved', count: resolved.length, color: kAlertsResolved),
            const SizedBox(height: 8),
            ...resolved.map((alert) => ResolvedAlertCard(
              alert: alert,
              onTap: () => Navigator.pushNamed(context, '/alerts/detail', arguments: alert.id),
            )),
          ],
        ],
      ),
    );
  }

  void _runQuery(String q) {
    _controller.text = q;
    Provider.of<AlertsProvider>(context, listen: false).setSearchQuery(q);
    setState(() => _showResults = true);
  }

  Widget _tip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Text('•', style: TextStyle(fontSize: 12, color: kAlertsInfo)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Suggestion Chip
// ──────────────────────────────────────────────

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, size: 16, color: kAlertsCritical),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
            const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Recent Search Tile
// ──────────────────────────────────────────────

class _RecentSearchTile extends StatelessWidget {
  final RecentSearch search;
  final VoidCallback? onTap;
  const _RecentSearchTile({required this.search, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            const Icon(Icons.history, size: 16, color: Color(0xFF9CA3AF)),
            const SizedBox(width: 10),
            Expanded(child: Text(search.query, style: const TextStyle(fontSize: 13))),
            Text('${search.resultCount}', style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Saved Search Tile
// ──────────────────────────────────────────────

class _SavedSearchTile extends StatelessWidget {
  final SavedSearch search;
  final VoidCallback? onTap;
  const _SavedSearchTile({required this.search, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kAlertsInfo.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.bookmark, size: 16, color: kAlertsInfo),
            const SizedBox(width: 10),
            Expanded(child: Text(search.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
            const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Group Header
// ──────────────────────────────────────────────

class _GroupHeader extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _GroupHeader({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Text('$count', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ),
      ],
    );
  }
}
