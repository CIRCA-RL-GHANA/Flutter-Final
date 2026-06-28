library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/design/ive.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();
  String _query = '';
  String _selectedScope = 'All';

  static const _scopes = ['All', 'GO', 'Market', 'Alerts', 'qualChat', 'Community', 'e-Play'];

  static const _recents = [
    'Pay Ama',
    'Tech Stocks Fund',
    'Return #4821',
    'Kofi driver',
  ];

  static const _suggestions = [
    'Drivers available near Osu',
    'Transfer to favourite · Ama',
    'Track order #GO-2291',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() => _query = _ctrl.text));
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IveTokens.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar + Cancel
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: IveTokens.surface,
                        borderRadius: BorderRadius.circular(IveTokens.rSm),
                        border: Border.all(color: IveTokens.accent, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: Icon(Icons.search_rounded, size: 18, color: IveTokens.mute),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _ctrl,
                              focusNode: _focus,
                              style: IveType.callout.copyWith(color: IveTokens.ink),
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                hintStyle: IveType.callout.copyWith(color: IveTokens.mute),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                              ),
                            ),
                          ),
                          if (_query.isNotEmpty)
                            GestureDetector(
                              onTap: () => _ctrl.clear(),
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(Icons.cancel_rounded, size: 16, color: IveTokens.mute),
                              ),
                            ),
                          // Gold send icon
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: IveTokens.genie,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_upward_rounded, size: 14, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: IveType.callout.copyWith(color: IveTokens.accent, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Genie context banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: IveTokens.genie.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(IveTokens.rSm),
                  border: Border.all(color: IveTokens.genie.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.auto_awesome, size: 14, color: IveTokens.genie),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Genie is matching across GO · Market · LIVE · Chat in real time.',
                        style: IveType.footnote.copyWith(
                          color: IveTokens.genie,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Scope chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SCOPE',
                    style: IveType.caption.copyWith(
                      color: IveTokens.mute,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _scopes.map((s) {
                      final active = s == _selectedScope;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedScope = s);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: active ? IveTokens.accent : Colors.transparent,
                            borderRadius: BorderRadius.circular(IveTokens.rPill),
                            border: Border.all(
                              color: active ? IveTokens.accent : IveTokens.hairline2,
                            ),
                          ),
                          child: Text(
                            s,
                            style: IveType.footnote.copyWith(
                              color: active ? Colors.white : IveTokens.ink2,
                              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Scrollable results
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Recent searches
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Text(
                      'RECENT SEARCHES',
                      style: IveType.caption.copyWith(
                        color: IveTokens.mute,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ..._recents.map((r) => _SearchRow(
                    icon: Icons.history_rounded,
                    iconColor: IveTokens.mute,
                    iconBg: IveTokens.surface,
                    text: r,
                    onTap: () => _ctrl.text = r,
                  )),

                  const SizedBox(height: 20),

                  // Suggestions
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Text(
                      'SUGGESTIONS',
                      style: IveType.caption.copyWith(
                        color: IveTokens.mute,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ..._suggestions.map((s) => _SearchRow(
                    icon: Icons.auto_awesome,
                    iconColor: IveTokens.genie,
                    iconBg: IveTokens.genie.withValues(alpha: 0.15),
                    text: s,
                    onTap: () => _ctrl.text = s,
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.text,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: IveTokens.hairline, width: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(IveTokens.rSm),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: IveType.callout.copyWith(color: IveTokens.ink),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: IveTokens.mute),
          ],
        ),
      ),
    );
  }
}
