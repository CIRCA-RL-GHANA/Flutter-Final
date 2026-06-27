/// 
/// SD0: SETUP DASHBOARD HUB  Master Entry Point
/// 6-row adaptive card matrix with role-based filtering
/// Rows: Operations, Finance & Staff, Logistics, Engagement,
///        Branch Identity, Personal & History
/// 
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive.dart';
import '../../prompt/models/rbac_models.dart';
import '../../prompt/providers/context_provider.dart';
import '../models/setup_dashboard_models.dart';
import '../providers/setup_dashboard_provider.dart';
import '../../../core/routes/app_routes.dart';
import '../widgets/shared_widgets.dart';

class SetupDashboardScreen extends StatefulWidget {
  const SetupDashboardScreen({super.key});

  @override
  State<SetupDashboardScreen> createState() => _SetupDashboardScreenState();
}

class _SetupDashboardScreenState extends State<SetupDashboardScreen>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  bool _genieVisible = true;
  late final AnimationController _staggerCtrl;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    if (!WidgetsBinding.instance.accessibilityFeatures.disableAnimations) {
      _staggerCtrl.forward();
    } else {
      _staggerCtrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  /// Fade animation for card at flat index [i] out of [total] visible cards.
  Animation<double> _cardFade(int i, int total) {
    const revealMs = 200;
    const staggerMs = 60; // AppAnimations.dpStagger = 60ms
    final totalMs = ((total - 1) * staggerMs + revealMs).toDouble().clamp(revealMs.toDouble(), 2000.0);
    final start = (i * staggerMs / totalMs).clamp(0.0, 1.0);
    final end = ((i * staggerMs + revealMs) / totalMs).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _staggerCtrl,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        final role = ctxProv.currentRole;
        // Spec P1: only render permitted (fully-actionable) cards  no greyed-out locked cards
        final cards = setupProv.getCardsForRole(role).where((c) => !c.isViewOnly).toList();
        final header = setupProv.headerInfo;

        final filteredCards = _searchQuery.isEmpty
            ? cards
            : cards.where((c) =>
                c.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

        final rows = _groupCardsIntoRows(filteredCards);

        // Flat index counter for stagger  pre-count total visible cards
        final totalCards = filteredCards.length;
        var flatIndex = 0;

        return Scaffold(
          backgroundColor: IveTokens.voidColor,
          appBar: _DarkSetupAppBar(
            title: 'Setup',
            onBack: () => Navigator.pop(context),
          ),
          body: RefreshIndicator(
            color: kSetupColor,
            backgroundColor: IveTokens.raisedColor,
            onRefresh: () async => setupProv.refreshSection('hub'),
            child: CustomScrollView(
              slivers: [
                //  Header 
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      IveTokens.s4, IveTokens.s3, IveTokens.s4, 0,
                    ),
                    child: _HeaderBanner(header: header, role: role),
                  ),
                ),

                //  Genie health strip (max one per screen) 
                if (_genieVisible)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        IveTokens.s4, IveTokens.s3, IveTokens.s4, 0,
                      ),
                      child: GenieStrip(
                        message: 'Configure your modules to unlock the full Commerce OS experience.',
                        onDismiss: () => setState(() => _genieVisible = false),
                      ),
                    ),
                  ),

                //  Search 
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      IveTokens.s4, IveTokens.s4, IveTokens.s4, 0,
                    ),
                    child: _DarkSearchBar(onChanged: (q) => setState(() => _searchQuery = q)),
                  ),
                ),

                //  Card Rows 
                ...rows.entries.map((entry) {
                  final rowCards = entry.value;
                  if (rowCards.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

                  // Capture start index for this row's stagger
                  final rowStartIndex = flatIndex;
                  flatIndex += rowCards.length;

                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        IveTokens.s4, IveTokens.s4, IveTokens.s4, 0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _RowLabel(title: entry.key, icon: _rowIcon(entry.key)),
                          const SizedBox(height: IveTokens.s3),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final crossAxisCount =
                                  constraints.maxWidth > 600 ? 4 :
                                  constraints.maxWidth > 400 ? 3 : 2;
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: IveTokens.s2,
                                  mainAxisSpacing: IveTokens.s2,
                                  childAspectRatio: 0.78,
                                ),
                                itemCount: rowCards.length,
                                itemBuilder: (context, i) {
                                  final card = rowCards[i];
                                  final cardFlatIdx = rowStartIndex + i;
                                  return FadeTransition(
                                    opacity: _cardFade(cardFlatIdx, totalCards),
                                    child: _DarkModuleCard(
                                      card: card,
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        Navigator.pushNamed(context, card.route);
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                //  Empty State 
                if (filteredCards.isEmpty && _searchQuery.isNotEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(IveTokens.s10),
                      child: IveEmptyState(
                        icon: Icons.search_off,
                        title: 'No modules found',
                        message: 'Try a different search term',
                      ),
                    ),
                  ),

                //  SOS Button 
                SliverToBoxAdapter(
                  child: SetupSOSButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.liveEmergencySOS),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        );
      },
    );
  }

  Map<String, List<DashboardCard>> _groupCardsIntoRows(List<DashboardCard> cards) {
    final rowDefinitions = <String, List<String>>{
      'Operations': ['products', 'vehicles', 'tabs'],
      'Finance & Staff': ['discounts', 'staff', 'activity_log'],
      'Logistics': ['places', 'delivery_zones', 'vehicle_bands', 'branches'],
      'Engagement': ['marketing', 'social', 'connections'],
      'Branch identity': ['profile', 'outlook', 'subscription'],
      'Personal': ['interests', 'qpoints', 'my_activity'],
    };

    final result = <String, List<DashboardCard>>{};
    for (final entry in rowDefinitions.entries) {
      final rowCards = entry.value
          .map((id) {
            try { return cards.firstWhere((c) => c.id == id); } catch (_) { return null; }
          })
          .whereType<DashboardCard>()
          .toList();
      if (rowCards.isNotEmpty) result[entry.key] = rowCards;
    }
    return result;
  }

  IconData _rowIcon(String row) {
    switch (row) {
      case 'Operations': return Icons.inventory_2;
      case 'Finance & Staff': return Icons.account_balance;
      case 'Logistics': return Icons.local_shipping;
      case 'Engagement': return Icons.campaign;
      case 'Branch identity': return Icons.badge;
      case 'Personal': return Icons.person;
      default: return Icons.grid_view;
    }
  }
}

//  Dark App Bar 

class _DarkSetupAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBack;

  const _DarkSetupAppBar({required this.title, required this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) => AppBar(
    backgroundColor: IveTokens.voidColor,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: IveTokens.inkColor, size: 22),
      onPressed: onBack,
    ),
    title: Text(title, style: IveType.headline),
  );
}

//  Header Banner 

class _HeaderBanner extends StatelessWidget {
  final DashboardHeaderInfo header;
  final UserRole role;

  const _HeaderBanner({required this.header, required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(IveTokens.s4),
      decoration: BoxDecoration(
        color: IveTokens.raisedColor,
        borderRadius: BorderRadius.circular(IveTokens.rContainer),
        border: Border.all(color: IveTokens.hairColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: kSetupColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(IveTokens.rAtom),
            ),
            child: Center(
              child: Text(
                header.userName.isNotEmpty ? header.userName[0] : '?',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: kSetupColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: IveTokens.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome, ${header.userName}', style: IveType.callout),
                const SizedBox(height: 2),
                Text(
                  '${header.roleName}  ${header.branchName}',
                  style: IveType.caption.copyWith(color: IveTokens.muteColor),
                ),
              ],
            ),
          ),
          _SyncBadge(state: header.syncState),
        ],
      ),
    );
  }
}

//  Sync Badge 

class _SyncBadge extends StatelessWidget {
  final SyncState state;
  const _SyncBadge({required this.state});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    final IconData icon;
    switch (state) {
      case SyncState.synced:
        color = IveTokens.okColor; label = 'Synced'; icon = Icons.cloud_done;
        break;
      case SyncState.syncing:
        color = kSetupColor; label = 'Syncing'; icon = Icons.sync;
        break;
      case SyncState.offline:
        color = IveTokens.badColor; label = 'Offline'; icon = Icons.cloud_off;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: IveTokens.s2, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(IveTokens.rAtom),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}

//  Dark Search Bar 

class _DarkSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _DarkSearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    height: 44,
    decoration: BoxDecoration(
      color: IveTokens.surfaceColor,
      borderRadius: BorderRadius.circular(IveTokens.rAtom),
      border: Border.all(color: IveTokens.hairColor, width: 1),
    ),
    child: Row(
      children: [
        const SizedBox(width: IveTokens.s4),
        const Icon(Icons.search, size: 18, color: IveTokens.muteColor),
        const SizedBox(width: IveTokens.s3),
        Expanded(
          child: TextField(
            style: const TextStyle(fontSize: 14, color: IveTokens.inkColor),
            cursorColor: IveTokens.accentColor,
            decoration: const InputDecoration(
              hintText: 'Search modules',
              hintStyle: TextStyle(fontSize: 14, color: IveTokens.muteColor),
              border: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: IveTokens.s4),
      ],
    ),
  );
}

//  Row Label 

class _RowLabel extends StatelessWidget {
  final String title;
  final IconData icon;
  const _RowLabel({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 14, color: IveTokens.muteColor),
    const SizedBox(width: IveTokens.s2),
    Text(title.toUpperCase(), style: IveType.caption.copyWith(
      color: IveTokens.muteColor,
      letterSpacing: 0.6,
      fontWeight: FontWeight.w700,
    )),
  ]);
}

//  Dark Module Card 

class _DarkModuleCard extends StatelessWidget {
  final DashboardCard card;
  final VoidCallback? onTap;
  const _DarkModuleCard({required this.card, this.onTap});

  @override
  Widget build(BuildContext context) {
    final accentColor = card.highlightColor ?? kSetupColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(IveTokens.s3),
        decoration: BoxDecoration(
          color: IveTokens.raisedColor,
          borderRadius: BorderRadius.circular(IveTokens.rContainer),
          border: Border.all(
            color: card.hasAlerts
                ? IveTokens.badColor.withValues(alpha: 0.5)
                : IveTokens.hairColor,
            width: card.hasAlerts ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon row
            Row(children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(IveTokens.rAtom),
                ),
                child: Icon(card.icon, size: 18, color: accentColor),
              ),
              const Spacer(),
              if (card.hasAlerts)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: IveTokens.badColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(IveTokens.rAtom),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.warning_amber, size: 10, color: IveTokens.badColor),
                    const SizedBox(width: 2),
                    Text('${card.alertCount}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: IveTokens.badColor)),
                  ]),
                ),
            ]),
            const Spacer(),
            // Title
            Text(card.title, style: IveType.callout, maxLines: 2, overflow: TextOverflow.ellipsis),
            if (card.subtitle != null) ...[
              const SizedBox(height: 2),
              Text(card.subtitle!, style: IveType.caption.copyWith(color: IveTokens.muteColor), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ],
        ),
      ),
    );
  }
}
