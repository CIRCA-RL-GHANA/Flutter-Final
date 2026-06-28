library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/design/ive.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  String _filter = 'All';
  static const _filters = ['All', 'Payments', 'Alerts', 'Messages', 'System'];

  static const _items = [
    _NotifItem(
      dot: Color(0xFFEF4444),
      category: 'SECURITY',
      badge: 'HIGH',
      title: 'New device sign-in detected',
      meta: 'Accra · 9:32 AM',
    ),
    _NotifItem(
      dot: Color(0xFF4361EE),
      category: 'PAYMENTS',
      badge: null,
      title: 'You received 250 QP from Ama',
      meta: '2h ago',
    ),
    _NotifItem(
      dot: Color(0xFFC9A84C),
      category: 'GENIE',
      badge: null,
      title: 'Your spending is 12% under budget',
      meta: '3h ago',
    ),
    _NotifItem(
      dot: Color(0xFF4361EE),
      category: 'MARKET',
      badge: null,
      title: 'Order #GO-2291 is out for delivery',
      meta: '5h ago',
    ),
    _NotifItem(
      dot: Color(0xFF34D399),
      category: 'LIVE',
      badge: null,
      title: 'Return #4821 was approved',
      meta: 'Yesterday',
    ),
  ];

  List<_NotifItem> get _filtered {
    if (_filter == 'All') return _items;
    return _items.where((n) {
      switch (_filter) {
        case 'Payments': return n.category == 'PAYMENTS';
        case 'Alerts':   return n.category == 'SECURITY';
        case 'Messages': return n.category == 'GENIE';
        case 'System':   return n.category == 'LIVE' || n.category == 'MARKET';
        default:         return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IveTokens.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(Icons.chevron_left_rounded, size: 24, color: IveTokens.ink2),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UTILITY',
                        style: IveType.caption.copyWith(
                          color: IveTokens.mute,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text('Notifications', style: IveType.title3),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                    },
                    child: Text(
                      'Read all',
                      style: IveType.callout.copyWith(
                        color: IveTokens.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Filter chips
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final f = _filters[i];
                  final active = f == _filter;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _filter = f);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: active ? IveTokens.accent : Colors.transparent,
                        borderRadius: BorderRadius.circular(IveTokens.rPill),
                        border: Border.all(
                          color: active ? IveTokens.accent : IveTokens.hairline2,
                        ),
                      ),
                      child: Text(
                        f,
                        style: IveType.footnote.copyWith(
                          color: active ? Colors.white : IveTokens.ink2,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Notification list
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No notifications',
                        style: IveType.callout.copyWith(color: IveTokens.mute),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        thickness: 0.5,
                        color: IveTokens.hairline,
                        indent: 16,
                      ),
                      itemBuilder: (context, i) => _NotifRow(item: _filtered[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifItem {
  final Color dot;
  final String category;
  final String? badge;
  final String title;
  final String meta;
  const _NotifItem({
    required this.dot,
    required this.category,
    this.badge,
    required this.title,
    required this.meta,
  });
}

class _NotifRow extends StatelessWidget {
  const _NotifRow({required this.item});
  final _NotifItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colored dot
          Padding(
            padding: const EdgeInsets.only(top: 5, right: 12),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: item.dot, shape: BoxShape.circle),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.category,
                      style: IveType.caption.copyWith(
                        color: item.dot,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (item.badge != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          item.badge!,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFEF4444),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(item.title, style: IveType.callout),
                const SizedBox(height: 2),
                Text(item.meta, style: IveType.caption.copyWith(color: IveTokens.mute)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
