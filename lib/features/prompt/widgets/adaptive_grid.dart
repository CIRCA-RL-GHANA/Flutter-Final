/// ═══════════════════════════════════════════════════════════════════════════
/// Adaptive Grid
/// Responsive widget grid: 2 cols (mobile), 3 cols (tablet), 4 cols (desktop)
/// Supports reordering, staggered entrance, lazy loading
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/utils/responsive.dart';

class AdaptiveGrid extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final double runSpacing;

  const AdaptiveGrid({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.spacing = 12,
    this.runSpacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.value<int>(
      context,
      mobile: 2,
      tablet: 3,
      desktop: 4,
    );

    return SliverPadding(
      padding: padding,
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: spacing,
          mainAxisSpacing: runSpacing,
          childAspectRatio: _getAspectRatio(context, columns),
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => children[index],
          childCount: children.length,
        ),
      ),
    );
  }

  double _getAspectRatio(BuildContext context, int columns) {
    // Taller cards on mobile for more content, wider on desktop
    if (columns <= 2) return 0.78; // Mobile: taller cards
    if (columns == 3) return 0.85; // Tablet
    return 0.92; // Desktop
  }
}

/// Full-width widget that spans the entire grid row (for wide widgets)
class FullWidthWidget extends StatelessWidget {
  final Widget child;
  final double height;

  const FullWidthWidget({
    super.key,
    required this.child,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: SizedBox(
          height: height,
          child: child,
        ),
      ),
    );
  }
}

/// Search results overlay when user is searching
class SearchResultsOverlay extends StatelessWidget {
  final List<SearchResultTile> results;
  final bool isLoading;
  final VoidCallback onDismiss;

  const SearchResultsOverlay({
    super.key,
    required this.results,
    this.isLoading = false,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (results.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No results found',
                style: TextStyle(color: Color(0xFF9CA3AF)),
              ),
            )
          else
            ...results,
        ],
      ),
    );
  }
}

class SearchResultTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String type;
  final VoidCallback? onTap;

  const SearchResultTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.type,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                type,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
