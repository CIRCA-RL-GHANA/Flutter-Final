/// GO Module  Shared Reusable UI Components
/// Module Color: IveTokens.moduleGo
/// Visibility: Owner + Administrator only
library;

import 'package:flutter/material.dart';
import '../../../core/design/ive.dart';
import '../models/go_models.dart';

// All GO colors use IveTokens directly — no local constants needed.

// 
// GO APP BAR
// 

class GoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool showBackButton;

  const GoAppBar({super.key, required this.title, this.actions, this.bottom, this.showBackButton = true});

  @override
  Size get preferredSize => Size.fromHeight(bottom != null ? kToolbarHeight + 48 : kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: IveTokens.surface,
      surfaceTintColor: IveTokens.surface,
      elevation: 0,
      leading: showBackButton
          ? IconButton(icon: Icon(Icons.arrow_back, color: IveTokens.ink), onPressed: () => Navigator.pop(context))
          : null,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: IveTokens.moduleGo, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(title, style: IveType.title3.copyWith(color: IveTokens.ink)),
        ],
      ),
      actions: actions,
      bottom: bottom,
    );
  }
}

// 
// SECTION CARD
// 

class GoSectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;

  const GoSectionCard({super.key, required this.child, this.padding, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: IveTokens.surface,
        borderRadius: BorderRadius.circular(IveTokens.rSm),
        border: Border.all(color: borderColor ?? IveTokens.hairline2),
      ),
      child: child,
    );
  }
}

// 
// EMPTY STATE
// 

class GoEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const GoEmptyState({super.key, required this.icon, required this.title, required this.message, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: IveTokens.hairline2),
            const SizedBox(height: 16),
            Text(title, style: IveType.headline.copyWith(color: IveTokens.ink)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: IveType.subhead.copyWith(color: IveTokens.ink2)),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              IveButton.primary(
                label: actionLabel!,
                onPressed: onAction,
                expand: false,
                compact: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// 
// CONTEXT CHIP
// 

class GoContextChip extends StatelessWidget {
  final FinancialContext context;
  final VoidCallback? onTap;

  const GoContextChip({super.key, required this.context, this.onTap});

  @override
  Widget build(BuildContext context) {
    final ctx = this.context;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: IveTokens.surfaceRaised,
          borderRadius: BorderRadius.circular(IveTokens.rSm),
          border: Border.all(color: IveTokens.moduleGo.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(ctx.typeEmoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text('${ctx.name}  ${ctx.role}', style: IveType.caption.copyWith(fontWeight: FontWeight.w600, color: IveTokens.moduleGo)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: IveTokens.moduleGo),
          ],
        ),
      ),
    );
  }
}

// 
// METRIC CARD (Small stat box)
// 

class GoMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? valueColor;
  final VoidCallback? onTap;

  const GoMetricCard({super.key, required this.label, required this.value, this.subtitle, this.icon, this.valueColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: IveTokens.surface,
          borderRadius: BorderRadius.circular(IveTokens.rSm),
          border: Border.all(color: IveTokens.hairline2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (icon != null) ...[Icon(icon!, size: 14, color: IveTokens.ink2), const SizedBox(width: 4)],
                Expanded(child: Text(label, style: IveType.caption.copyWith(color: IveTokens.ink2, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 6),
            Text(value, style: IveType.title3.copyWith(color: valueColor ?? IveTokens.ink)),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: IveType.caption.copyWith(color: IveTokens.ink2)),
            ],
          ],
        ),
      ),
    );
  }
}

// 
// GATEWAY STATUS ROW
// 

class GatewayStatusRow extends StatelessWidget {
  final PaymentGateway gateway;
  final VoidCallback? onTap;

  const GatewayStatusRow({super.key, required this.gateway, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: gateway.statusColor, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(gateway.name, style: IveType.subhead.copyWith(fontWeight: FontWeight.w600, color: IveTokens.ink)),
                  Text(gateway.statusLabel, style: IveType.caption.copyWith(color: gateway.statusColor)),
                ],
              ),
            ),
            Text('${gateway.balance.toStringAsFixed(0)} ${gateway.currency}', style: IveType.subhead.copyWith(fontWeight: FontWeight.w600, color: IveTokens.ink)),
            const SizedBox(width: 8),
            const Icon(Icons.settings, size: 16, color: IveTokens.ink2),
          ],
        ),
      ),
    );
  }
}

// 
// QUICK ACTION BUTTON
// 

class GoQuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final String? badge;
  final VoidCallback? onTap;

  const GoQuickAction({super.key, required this.icon, required this.label, required this.subtitle, this.badge, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: IveTokens.surface,
          borderRadius: BorderRadius.circular(IveTokens.rSm),
          border: Border.all(color: IveTokens.hairline2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: IveTokens.surfaceRaised, borderRadius: BorderRadius.circular(IveTokens.rSm)),
                  child: Icon(icon, size: 18, color: IveTokens.moduleGo),
                ),
                const Spacer(),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: IveTokens.surfaceRaised, borderRadius: BorderRadius.circular(IveTokens.rSm)),
                    child: Text(badge!, style: IveType.caption.copyWith(fontWeight: FontWeight.w600, color: IveTokens.moduleGo)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(label, style: IveType.subhead.copyWith(fontWeight: FontWeight.w600, color: IveTokens.ink)),
            const SizedBox(height: 2),
            Text(subtitle, style: IveType.caption.copyWith(color: IveTokens.ink2)),
          ],
        ),
      ),
    );
  }
}

// 
// TRANSACTION ROW
// 

class GoTransactionRow extends StatelessWidget {
  final GoTransaction transaction;
  final VoidCallback? onTap;

  const GoTransactionRow({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPositive = transaction.isCredit;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: IveTokens.surface,
          borderRadius: BorderRadius.circular(IveTokens.rSm),
          border: Border.all(color: IveTokens.hairline2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: IveTokens.surfaceRaised,
                    borderRadius: BorderRadius.circular(IveTokens.rSm),
                  ),
                  child: Icon(transaction.typeIcon, size: 16, color: isPositive ? IveTokens.success : IveTokens.danger),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(transaction.typeLabel, style: IveType.subhead.copyWith(fontWeight: FontWeight.w600, color: IveTokens.ink)),
                      const SizedBox(height: 2),
                      Text('${transaction.fromEntity}  ${transaction.toEntity}', style: IveType.caption.copyWith(color: IveTokens.ink2), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${isPositive ? '+' : '-'}${transaction.amount.toStringAsFixed(0)} QP',
                      style: IveType.bodyEmphasis.copyWith(color: isPositive ? IveTokens.success : IveTokens.danger)),
                    const SizedBox(height: 2),
                    Text('${transaction.statusEmoji} ${transaction.statusLabel}', style: IveType.caption.copyWith(color: IveTokens.ink2)),
                  ],
                ),
              ],
            ),
            if (transaction.feeAmount != null) ...[
              const SizedBox(height: 6),
              Text('Fee: ${transaction.feeAmount!.toStringAsFixed(2)} QP  Net: ${transaction.netAmount?.toStringAsFixed(2) ?? '-'} QP',
                style: IveType.caption.copyWith(color: IveTokens.ink2)),
            ],
          ],
        ),
      ),
    );
  }
}

// 
// TAB CARD (Credit tab overview)
// 

class GoTabCard extends StatelessWidget {
  final GoTab tab;
  final VoidCallback? onTap;

  const GoTabCard({super.key, required this.tab, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: IveTokens.surface,
          borderRadius: BorderRadius.circular(IveTokens.rSm),
          border: Border.all(color: IveTokens.hairline2),
        ),
        child: Row(
          children: [
            Container(width: 4, height: 88, decoration: BoxDecoration(color: tab.riskColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(IveTokens.rSm), bottomLeft: Radius.circular(IveTokens.rSm)))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(tab.id, style: IveType.caption.copyWith(color: IveTokens.ink2, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 6),
                        Text(' ${tab.entityName}  ${tab.entityRole}', style: IveType.caption.copyWith(color: IveTokens.mute)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: tab.statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(IveTokens.rXs)),
                          child: Text(tab.statusLabel, style: IveType.caption.copyWith(fontWeight: FontWeight.w600, color: tab.statusColor)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(tab.description, style: IveType.subhead.copyWith(fontWeight: FontWeight.w600, color: IveTokens.ink)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(IveTokens.rXs),
                            child: LinearProgressIndicator(
                              value: (tab.utilization / 100).clamp(0, 1),
                              backgroundColor: IveTokens.hairline,
                              valueColor: AlwaysStoppedAnimation(tab.utilization > 80 ? IveTokens.danger : IveTokens.moduleGo),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${tab.currentBalance.toStringAsFixed(0)}/${tab.creditLimit.toStringAsFixed(0)} QP (${tab.utilization.toStringAsFixed(0)}%)',
                          style: IveType.caption.copyWith(color: IveTokens.ink2)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(tab.isOverdue ? ' Overdue by ${(-tab.daysUntilDue)} days' : 'Due: ${tab.daysUntilDue}d',
                      style: IveType.caption.copyWith(color: tab.isOverdue ? IveTokens.danger : IveTokens.ink2, fontWeight: tab.isOverdue ? FontWeight.w600 : FontWeight.w400)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 
// REQUEST CARD
// 

class GoRequestCard extends StatelessWidget {
  final GoRequest request;
  final VoidCallback? onTap;

  const GoRequestCard({super.key, required this.request, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: IveTokens.surface,
          borderRadius: BorderRadius.circular(IveTokens.rSm),
          border: Border.all(color: IveTokens.hairline2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(request.typeIcon, size: 18, color: IveTokens.moduleGo),
                const SizedBox(width: 8),
                Expanded(child: Text(request.typeLabel, style: IveType.caption.copyWith(color: IveTokens.ink2, fontWeight: FontWeight.w500))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: request.statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(IveTokens.rXs)),
                  child: Text(request.statusLabel, style: IveType.caption.copyWith(fontWeight: FontWeight.w600, color: request.statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(request.title, style: IveType.subhead.copyWith(fontWeight: FontWeight.w600, color: IveTokens.ink)),
            const SizedBox(height: 4),
            Text('by ${request.submittedBy}  ${request.id}', style: IveType.caption.copyWith(color: IveTokens.ink2)),
          ],
        ),
      ),
    );
  }
}

// 
// FAVORITE ENTITY CARD
// 

class GoFavoriteCard extends StatelessWidget {
  final FavoriteEntity entity;
  final VoidCallback? onTap;

  const GoFavoriteCard({super.key, required this.entity, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: IveTokens.surface,
          borderRadius: BorderRadius.circular(IveTokens.rSm),
          border: Border.all(color: IveTokens.hairline2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(radius: 20, backgroundColor: IveTokens.surfaceRaised, child: Text(entity.name[0], style: IveType.bodyEmphasis.copyWith(color: IveTokens.moduleGo))),
                    if (entity.isOnline) Positioned(right: 0, bottom: 0, child: Container(width: 10, height: 10, decoration: BoxDecoration(color: IveTokens.success, shape: BoxShape.circle, border: Border.all(color: IveTokens.surface, width: 2)))),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entity.name, style: IveType.subhead.copyWith(fontWeight: FontWeight.w600, color: IveTokens.ink)),
                      Text('${entity.handle}  ${entity.role}', style: IveType.caption.copyWith(color: IveTokens.ink2)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 12, color: IveTokens.warning),
                        const SizedBox(width: 2),
                        Text(entity.rating.toStringAsFixed(1), style: IveType.caption.copyWith(fontWeight: FontWeight.w600, color: IveTokens.ink)),
                      ],
                    ),
                    Text('${entity.transactionCount} trans', style: IveType.caption.copyWith(color: IveTokens.ink2)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _MiniStat(label: 'Total', value: '${entity.totalSpent.toStringAsFixed(0)} QP'),
                const SizedBox(width: 12),
                _MiniStat(label: 'Avg', value: '${entity.avgTransaction.toStringAsFixed(0)} QP'),
                const Spacer(),
                if (entity.isMutualFavorite) Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: IveTokens.surfaceRaised, borderRadius: BorderRadius.circular(IveTokens.rXs)),
                  child: Text('Mutual ', style: IveType.caption.copyWith(fontWeight: FontWeight.w600, color: IveTokens.moduleGo)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: IveType.caption.copyWith(color: IveTokens.ink2)),
        Text(value, style: IveType.caption.copyWith(fontWeight: FontWeight.w600, color: IveTokens.ink)),
      ],
    );
  }
}

// 
// HEALTH SCORE ARC
// 

class GoHealthGauge extends StatelessWidget {
  final int score;
  final double size;

  const GoHealthGauge({super.key, required this.score, this.size = 80});

  @override
  Widget build(BuildContext context) {
    final color = score >= 70 ? IveTokens.success : score >= 50 ? IveTokens.warning : IveTokens.danger;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 6,
              backgroundColor: IveTokens.hairline,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$score', style: TextStyle(fontSize: size * 0.28, fontWeight: FontWeight.w700, color: color)),
              Text('/100', style: TextStyle(fontSize: size * 0.12, color: IveTokens.ink2)),
            ],
          ),
        ],
      ),
    );
  }
}

// 
// SECTION HEADER WITH ACTION
// 

class GoSectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const GoSectionHeader({super.key, required this.title, this.icon, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          if (icon != null) ...[Icon(icon!, size: 18, color: IveTokens.moduleGo), const SizedBox(width: 8)],
          Text(title, style: IveType.bodyEmphasis.copyWith(color: IveTokens.ink)),
          const Spacer(),
          if (actionLabel != null) GestureDetector(
            onTap: onAction,
            child: Text(actionLabel!, style: IveType.subhead.copyWith(fontWeight: FontWeight.w600, color: IveTokens.moduleGo)),
          ),
        ],
      ),
    );
  }
}

// 
// STEP INDICATOR (For wizard flows)
// 

class GoStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> labels;

  const GoStepIndicator({super.key, required this.currentStep, required this.totalSteps, required this.labels});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(totalSteps * 2 - 1, (index) {
          if (index.isOdd) {
            return Expanded(child: Container(height: 2, color: index ~/ 2 < currentStep ? IveTokens.moduleGo : IveTokens.hairline2));
          }
          final step = index ~/ 2;
          final isActive = step <= currentStep;
          return Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isActive ? IveTokens.moduleGo : IveTokens.surfaceRaised,
              shape: BoxShape.circle,
              border: Border.all(color: isActive ? IveTokens.moduleGo : IveTokens.hairline2, width: 2),
            ),
            child: Center(
              child: step < currentStep
                  ? const Icon(Icons.check, size: 14, color: IveTokens.bg)
                  : Text('${step + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isActive ? IveTokens.bg : IveTokens.ink2)),
            ),
          );
        }),
      ),
    );
  }
}

// 
// AUDIT ENTRY ROW
// 

class GoAuditRow extends StatelessWidget {
  final AuditEntry entry;

  const GoAuditRow({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(color: entry.severityColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.action, style: IveType.subhead.copyWith(fontWeight: FontWeight.w500, color: IveTokens.ink)),
                const SizedBox(height: 2),
                Text('${entry.actor}${entry.ipAddress != null ? '  ${entry.ipAddress}' : ''}',
                  style: IveType.caption.copyWith(color: IveTokens.ink2)),
              ],
            ),
          ),
          Text(_formatTimeAgo(entry.timestamp), style: IveType.caption.copyWith(color: IveTokens.ink2)),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// 
// MINI DONUT CHART (Reusable)
// 

class GoDonutChart extends StatelessWidget {
  final List<double> values;
  final List<Color> colors;
  final double size;
  final Widget? center;

  const GoDonutChart({super.key, required this.values, required this.colors, this.size = 80, this.center});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(values: values, colors: colors),
        child: center,
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  _DonutPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold(0.0, (a, b) => a + b);
    if (total == 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const strokeWidth = 10.0;
    double startAngle = -1.5708; // -pi/2

    for (int i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * 6.2832; // 2*pi
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect.deflate(strokeWidth / 2), startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
