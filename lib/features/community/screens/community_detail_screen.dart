/// ═══════════════════════════════════════════════════════════════════════════
/// COMMUNITY MODULE — Community Detail Screen
/// Adaptive detail view; UI surface adapts to community type.
/// Theater → linked asset; Hangout → event date/location; Fair → listings, etc.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../providers/community_provider.dart';
import 'community_hub_screen.dart' show kCommunityColor, kCommunityColorDark, _archetypes;

class CommunityDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? community;
  const CommunityDetailScreen({super.key, this.community});

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> with SingleTickerProviderStateMixin {
  bool _joined = false;
  late final TabController _tabs;

  Map<String, dynamic> get _comm => widget.community ?? {};
  String get _type => _comm['type'] as String? ?? 'hub';
  String get _name => _comm['name'] as String? ?? 'Community';
  String get _members => _comm['members'] as String? ?? '0';

  Map<String, dynamic> get _arch =>
      _archetypes.firstWhere((a) => a['type'] == _type, orElse: () => _archetypes[4]);

  Color get _color => Color(_arch['color'] as int);

  @override
  void initState() {
    super.initState();
    _joined = _comm['isNew'] == true;
    _tabs = TabController(length: 2, vsync: this);
    final id = _comm['id'] as String?;
    if (id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<CommunityProvider>().loadPosts(id);
      });
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AIInsightsNotifier, CommunityProvider>(
      builder: (context, ai, community, _) {
        final communityId = _comm['id'] as String?;
        final posts = communityId != null ? (community.postsCache[communityId] ?? []) : [];
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: NestedScrollView(
            headerSliverBuilder: (ctx, innerBoxScrolled) => [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: _color,
                leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.people, color: Colors.white),
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.communityMembers, arguments: _comm),
                  ),
                  IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {}),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [_color.withOpacity(0.9), _color]),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 60),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                                child: Row(children: [
                                  Icon(_arch['icon'] as IconData, color: Colors.white, size: 14),
                                  const SizedBox(width: 5),
                                  Text(_arch['label'] as String, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                ]),
                              ),
                            ]),
                            const Spacer(),
                            Text(_name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text('$_members members', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                bottom: TabBar(
                  controller: _tabs,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  indicatorColor: Colors.white,
                  tabs: const [Tab(text: 'Feed'), Tab(text: 'About')],
                ),
              ),
            ],
            body: Column(
              children: [
                // ── Type-specific banner ─────────────────────────────
                _typeSpecificBanner(),

                // ── AI insight ────────────────────────────────────────
                if (ai.insights.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: _color.withOpacity(0.07), borderRadius: BorderRadius.circular(10), border: Border.all(color: _color.withOpacity(0.2))),
                    child: Row(children: [
                      Icon(Icons.auto_awesome, color: _color, size: 14),
                      const SizedBox(width: 8),
                      Expanded(child: Text(ai.insights.first['title'] ?? '', style: const TextStyle(fontSize: 11))),
                    ]),
                  ),

                // ── Tab views ─────────────────────────────────────────
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [_buildFeed(), _buildAbout()],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: _joined
              ? FloatingActionButton.extended(
                  backgroundColor: _color,
                  onPressed: () {},
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('New Post', style: TextStyle(color: Colors.white)),
                )
              : FloatingActionButton.extended(
                  backgroundColor: _color,
                  onPressed: () async {
                    final id = _comm['id'] as String?;
                    if (id != null) await context.read<CommunityProvider>().joinCommunity(id);
                    if (mounted) setState(() => _joined = true);
                  },
                  icon: const Icon(Icons.group_add, color: Colors.white),
                  label: const Text('Join', style: TextStyle(color: Colors.white)),
                ),
        );
      },
    );
  }

  Widget _typeSpecificBanner() {
    return switch (_type) {
      'theater' => _infoBanner(Icons.live_tv, 'Next screening: Tonight 8 PM WAT', 'Tap to sync your watch session'),
      'hangout' => _infoBanner(Icons.event, 'Next event: Sat, 24 May · Accra Hub', 'In-person & virtual attendance'),
      'fair'    => _infoBanner(Icons.storefront, 'Fair active until Dec 31', '24 listings available'),
      'journal' => _infoBanner(Icons.book, '12 shared entries this week', 'Community blog & documentation'),
      _         => const SizedBox.shrink(),
    };
  }

  Widget _infoBanner(IconData icon, String title, String sub) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _color.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: _color.withOpacity(0.2))),
      child: Row(children: [
        Icon(icon, color: _color, size: 22),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
      ]),
    );
  }

  Widget _buildFeed() {
    if (!_joined) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(_arch['icon'] as IconData, size: 60, color: _color.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('Join to see the feed', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 5,
      itemBuilder: (ctx, i) => _postCard(i),
    );
  }

  Widget _postCard(int i) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(backgroundColor: _color.withOpacity(0.2), radius: 16, child: Icon(Icons.person, size: 16, color: _color)),
            const SizedBox(width: 8),
            Text('Member ${i + 1}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const Spacer(),
            const Text('2h ago', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
          ]),
          const SizedBox(height: 8),
          Text('Post content #${i + 1} — Community discussion in progress. This is a stub.', style: const TextStyle(fontSize: 13, height: 1.5)),
          const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.favorite_border, size: 16, color: AppColors.textTertiary),
            const SizedBox(width: 4),
            const Text('12', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
            const SizedBox(width: 16),
            const Icon(Icons.comment_outlined, size: 16, color: AppColors.textTertiary),
            const SizedBox(width: 4),
            const Text('5', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
          ]),
        ]),
      ),
    );
  }

  Widget _buildAbout() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _aboutRow('Type', _arch['label'] as String),
        _aboutRow('Members', _members),
        _aboutRow('Visibility', 'Public'),
        _aboutRow('Created', 'May 2025'),
        const SizedBox(height: 16),
        if (_joined)
          OutlinedButton.icon(
            onPressed: () => setState(() => _joined = false),
            icon: const Icon(Icons.exit_to_app, color: Colors.red),
            label: const Text('Leave Community', style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 12)),
          ),
      ],
    );
  }

  Widget _aboutRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
