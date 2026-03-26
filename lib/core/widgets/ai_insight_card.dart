import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Displays a single AI insight card with type-based icon and colour coding.
class AIInsightCard extends StatelessWidget {
  final Map<String, dynamic> insight;
  final VoidCallback? onTap;

  const AIInsightCard({
    super.key,
    required this.insight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final type       = insight['type'] as String? ?? 'recommendation';
    final title      = insight['title'] as String? ?? '';
    final body       = insight['body'] as String? ?? '';
    final impact     = insight['impact'] as String? ?? 'neutral';
    final confidence = ((insight['confidence'] as num?)?.toDouble() ?? 0.0) * 100;

    final config = _typeConfig(type, impact);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color:        Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border:       Border(left: BorderSide(color: config.accent, width: 4)),
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset:     const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width:  40,
                height: 40,
                decoration: BoxDecoration(
                  color:        config.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(config.icon, color: config.accent, size: 20),
              ),
              const SizedBox(width: 12),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(body,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _ImpactChip(impact: impact, color: config.accent),
                        const Spacer(),
                        Text(
                          '${confidence.toStringAsFixed(0)}% confidence',
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _InsightStyleConfig _typeConfig(String type, String impact) {
    final impactColor = impact == 'positive'
        ? Colors.green.shade600
        : impact == 'negative'
            ? Colors.red.shade600
            : Colors.orange.shade600;

    switch (type) {
      case 'alert':
        return _InsightStyleConfig(
            icon:   Icons.warning_amber_rounded,
            accent: impactColor);
      case 'anomaly':
        return _InsightStyleConfig(
            icon:   Icons.bar_chart_outlined,
            accent: Colors.deepPurple.shade400);
      case 'forecast':
        return _InsightStyleConfig(
            icon:   Icons.trending_up_rounded,
            accent: Colors.blue.shade600);
      case 'recommendation':
        return _InsightStyleConfig(
            icon:   Icons.lightbulb_outline_rounded,
            accent: Colors.amber.shade700);
      case 'trend':
      default:
        return _InsightStyleConfig(
            icon:   Icons.insights_rounded,
            accent: AppColors.primary);
    }
  }
}

class _InsightStyleConfig {
  final IconData icon;
  final Color    accent;
  const _InsightStyleConfig({required this.icon, required this.accent});
}

class _ImpactChip extends StatelessWidget {
  final String impact;
  final Color  color;
  const _ImpactChip({required this.impact, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        impact,
        style: TextStyle(
            fontSize:   10,
            color:      color,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INSIGHTS LIST (scrollable)
// ─────────────────────────────────────────────────────────────────────────────

/// Displays a horizontal or vertical list of AI insight cards.
class AIInsightsList extends StatelessWidget {
  final List<Map<String, dynamic>> insights;
  final bool horizontal;
  final bool isLoading;
  final String emptyMessage;

  const AIInsightsList({
    super.key,
    required this.insights,
    this.horizontal     = false,
    this.isLoading      = false,
    this.emptyMessage   = 'No AI insights available',
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (insights.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insights_outlined,
                size: 36, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(emptyMessage,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          ],
        ),
      );
    }

    if (horizontal) {
      return SizedBox(
        height: 120,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding:         const EdgeInsets.symmetric(horizontal: 16),
          itemCount:       insights.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) => SizedBox(
            width: 240,
            child: AIInsightCard(insight: insights[i]),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics:    const NeverScrollableScrollPhysics(),
      itemCount:  insights.length,
      itemBuilder: (_, i) => AIInsightCard(insight: insights[i]),
    );
  }
}
