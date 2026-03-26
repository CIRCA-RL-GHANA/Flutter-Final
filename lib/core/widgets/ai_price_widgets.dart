import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Displays the AI-computed surge multiplier and fare breakdown for a ride.
class AISurgePriceCard extends StatelessWidget {
  final Map<String, dynamic> priceData;
  final VoidCallback? onAccept;

  const AISurgePriceCard({
    super.key,
    required this.priceData,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final surge    = (priceData['surgeMultiplier'] as num?)?.toDouble() ?? 1.0;
    final final_   = (priceData['finalPrice'] as num?)?.toDouble() ?? 0.0;
    final base     = (priceData['basePrice'] as num?)?.toDouble() ?? 0.0;
    final minutes  = (priceData['estimatedMinutes'] as num?)?.toInt() ?? 0;
    final reason   = priceData['reason'] as String? ?? '';
    final breakdown = priceData['breakdown'] as Map<String, dynamic>? ?? {};
    final isSurge  = surge > 1.25;

    return Container(
      decoration: BoxDecoration(
        gradient: isSurge
            ? LinearGradient(
                colors: [Colors.orange.shade700, Colors.red.shade700],
                begin:  Alignment.topLeft,
                end:    Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin:  Alignment.topLeft,
                end:    Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSurge ? Icons.local_fire_department : Icons.auto_awesome,
                color: Colors.white,
                size:  22,
              ),
              const SizedBox(width: 8),
              Text(
                isSurge ? 'Surge Pricing' : 'AI Smart Fare',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              const Spacer(),
              _SurgeChip(surge: surge),
            ],
          ),

          const SizedBox(height: 16),

          // Main price
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₦${final_.toStringAsFixed(0)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 34),
              ),
              const SizedBox(width: 8),
              if (isSurge)
                Text(
                  'was ₦${base.toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: Colors.white60,
                      decoration: TextDecoration.lineThrough,
                      fontSize: 14),
                ),
            ],
          ),

          const SizedBox(height: 6),
          Text(
            'Est. $minutes min · $reason',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),

          const SizedBox(height: 12),

          // Breakdown row
          _BreakdownRow(breakdown: breakdown),

          if (onAccept != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAccept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: isSurge
                      ? Colors.orange.shade700
                      : AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Accept Price',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SurgeChip extends StatelessWidget {
  final double surge;
  const _SurgeChip({required this.surge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:        Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${surge.toStringAsFixed(1)}×',
        style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final Map<String, dynamic> breakdown;
  const _BreakdownRow({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    final items = {
      'Base':     breakdown['baseFare'],
      'Distance': breakdown['distanceFare'],
      'Time':     breakdown['timeFare'],
      'Surge':    breakdown['surgeFee'],
      'Platform': breakdown['platformFee'],
    };

    return Wrap(
      spacing: 10,
      runSpacing: 4,
      children: items.entries
          .where((e) => ((e.value as num?)?.toDouble() ?? 0) > 0)
          .map((e) => Text(
                '${e.key}: ₦${(e.value as num).toStringAsFixed(0)}',
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SPENDING SUMMARY CARD
// ─────────────────────────────────────────────────────────────────────────────

/// Compact AI spending-pattern summary card for the Planner/April feature.
class AISpendingSummaryCard extends StatelessWidget {
  final Map<String, dynamic>? spendingData;
  final bool isLoading;

  const AISpendingSummaryCard({
    super.key,
    this.spendingData,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (spendingData == null) {
      return const SizedBox.shrink();
    }

    final avgDaily   = (spendingData!['avgDailySpend'] as num?)?.toDouble() ?? 0;
    final avgWeekly  = (spendingData!['avgWeeklySpend'] as num?)?.toDouble() ?? 0;
    final topCat     = spendingData!['largestCategory'] as String? ?? '—';
    final categories =
        (spendingData!['topCategories'] as List<dynamic>? ?? [])
            .take(3)
            .map((e) => e as Map<String, dynamic>)
            .toList();

    return Container(
      decoration: BoxDecoration(
        color:        Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset:     const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights_rounded,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 6),
              const Text('AI Spending Intelligence',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color:        AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('AI',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatTile(
                  label: 'Daily Avg',
                  value: '₦${avgDaily.toStringAsFixed(0)}'),
              const SizedBox(width: 16),
              _StatTile(
                  label: 'Weekly Avg',
                  value: '₦${avgWeekly.toStringAsFixed(0)}'),
              const SizedBox(width: 16),
              _StatTile(label: 'Top Category', value: topCat),
            ],
          ),
          if (categories.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('Spending Breakdown',
                style: TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            ...categories.map((c) => _CategoryBar(data: c)),
          ],
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppColors.textTertiary)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final Map<String, dynamic> data;
  const _CategoryBar({required this.data});

  @override
  Widget build(BuildContext context) {
    final category = data['category'] as String? ?? '';
    final pct      = (data['percentage'] as num?)?.toDouble() ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(category,
                  style: const TextStyle(fontSize: 11)),
              const Spacer(),
              Text('${pct.toStringAsFixed(1)}%',
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value:           pct / 100,
              minHeight:       5,
              backgroundColor: AppColors.backgroundLight,
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }
}
