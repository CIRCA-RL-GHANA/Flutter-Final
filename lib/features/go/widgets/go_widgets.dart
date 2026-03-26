/// GO Module — Shared Reusable UI Components
/// Module Color: Emerald Green (0xFF10B981)
/// Visibility: Owner + Administrator only

import 'package:flutter/material.dart';
import '../models/go_models.dart';

// ═══════════════════════════════════════════
// COLOR CONSTANTS
// ═══════════════════════════════════════════

const kGoColor = Color(0xFF10B981);
const kGoColorLight = Color(0xFFD1FAE5);
const kGoColorDark = Color(0xFF065F46);
const kGoPositive = Color(0xFF10B981);
const kGoPositiveLight = Color(0xFFD1FAE5);
const kGoNegative = Color(0xFFEF4444);
const kGoNegativeLight = Color(0xFFFEE2E2);
const kGoWarning = Color(0xFFF59E0B);
const kGoWarningLight = Color(0xFFFEF3C7);
const kGoInfo = Color(0xFF3B82F6);
const kGoInfoLight = Color(0xFFDBEAFE);
const kGoPurple = Color(0xFF7C3AED);
const kGoPurpleLight = Color(0xFFEDE9FE);

// ═══════════════════════════════════════════
// GO APP BAR
// ═══════════════════════════════════════════

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
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      leading: showBackButton
          ? IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)), onPressed: () => Navigator.pop(context))
          : null,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: kGoColor, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 18, fontWeight: FontWeight.w700)),
        ],
      ),
      actions: actions,
      bottom: bottom,
    );
  }
}

// ═══════════════════════════════════════════
// SECTION CARD
// ═══════════════════════════════════════════

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor ?? const Color(0xFFE5E7EB)),
      ),
      child: child,
    );
  }
}

// ═══════════════════════════════════════════
// EMPTY STATE
// ═══════════════════════════════════════════

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
            Icon(icon, size: 56, color: const Color(0xFFE5E7EB)),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(backgroundColor: kGoColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// CONTEXT CHIP
// ═══════════════════════════════════════════

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
          color: kGoColorLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kGoColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(ctx.typeEmoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text('${ctx.name} • ${ctx.role}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kGoColorDark)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: kGoColorDark),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// METRIC CARD (Small stat box)
// ═══════════════════════════════════════════

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (icon != null) ...[Icon(icon!, size: 14, color: const Color(0xFF9CA3AF)), const SizedBox(width: 4)],
                Expanded(child: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: valueColor ?? const Color(0xFF1A1A1A))),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// GATEWAY STATUS ROW
// ═══════════════════════════════════════════

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
                  Text(gateway.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(gateway.statusLabel, style: TextStyle(fontSize: 11, color: gateway.statusColor)),
                ],
              ),
            ),
            Text('${gateway.balance.toStringAsFixed(0)} ${gateway.currency}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            const Icon(Icons.settings, size: 16, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// QUICK ACTION BUTTON
// ═══════════════════════════════════════════

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: kGoColorLight, borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, size: 18, color: kGoColor),
                ),
                const Spacer(),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: kGoColorLight, borderRadius: BorderRadius.circular(8)),
                    child: Text(badge!, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: kGoColorDark)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// TRANSACTION ROW
// ═══════════════════════════════════════════

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isPositive ? kGoPositiveLight : kGoNegativeLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(transaction.typeIcon, size: 16, color: isPositive ? kGoPositive : kGoNegative),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(transaction.typeLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text('${transaction.fromEntity} → ${transaction.toEntity}', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${isPositive ? '+' : '-'}${transaction.amount.toStringAsFixed(0)} QP',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isPositive ? kGoPositive : kGoNegative)),
                    const SizedBox(height: 2),
                    Text('${transaction.statusEmoji} ${transaction.statusLabel}', style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                  ],
                ),
              ],
            ),
            if (transaction.feeAmount != null) ...[
              const SizedBox(height: 6),
              Text('Fee: ${transaction.feeAmount!.toStringAsFixed(2)} QP • Net: ${transaction.netAmount?.toStringAsFixed(2) ?? '-'} QP',
                style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// TAB CARD (Credit tab overview)
// ═══════════════════════════════════════════

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(width: 4, height: 88, decoration: BoxDecoration(color: tab.riskColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(tab.id, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500)),
                        const SizedBox(width: 6),
                        Text('• ${tab.entityName} • ${tab.entityRole}', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: tab.statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                          child: Text(tab.statusLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: tab.statusColor)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(tab.description, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (tab.utilization / 100).clamp(0, 1),
                              backgroundColor: const Color(0xFFF3F4F6),
                              valueColor: AlwaysStoppedAnimation(tab.utilization > 80 ? kGoNegative : kGoColor),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${tab.currentBalance.toStringAsFixed(0)}/${tab.creditLimit.toStringAsFixed(0)} QP (${tab.utilization.toStringAsFixed(0)}%)',
                          style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(tab.isOverdue ? '⚠️ Overdue by ${(-tab.daysUntilDue)} days' : 'Due: ${tab.daysUntilDue}d',
                      style: TextStyle(fontSize: 11, color: tab.isOverdue ? kGoNegative : const Color(0xFF9CA3AF), fontWeight: tab.isOverdue ? FontWeight.w600 : FontWeight.w400)),
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

// ═══════════════════════════════════════════
// REQUEST CARD
// ═══════════════════════════════════════════

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(request.typeIcon, size: 18, color: kGoColor),
                const SizedBox(width: 8),
                Expanded(child: Text(request.typeLabel, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: request.statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                  child: Text(request.statusLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: request.statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(request.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('by ${request.submittedBy} • ${request.id}', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// FAVORITE ENTITY CARD
// ═══════════════════════════════════════════

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(radius: 20, backgroundColor: kGoColorLight, child: Text(entity.name[0], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kGoColorDark))),
                    if (entity.isOnline) Positioned(right: 0, bottom: 0, child: Container(width: 10, height: 10, decoration: BoxDecoration(color: kGoPositive, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entity.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      Text('${entity.handle} • ${entity.role}', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 2),
                        Text(entity.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Text('${entity.transactionCount} trans', style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
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
                  decoration: BoxDecoration(color: kGoColorLight, borderRadius: BorderRadius.circular(6)),
                  child: const Text('Mutual ❤️', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: kGoColorDark)),
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
        Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF9CA3AF))),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ═══════════════════════════════════════════
// HEALTH SCORE ARC
// ═══════════════════════════════════════════

class GoHealthGauge extends StatelessWidget {
  final int score;
  final double size;

  const GoHealthGauge({super.key, required this.score, this.size = 80});

  @override
  Widget build(BuildContext context) {
    final color = score >= 70 ? kGoPositive : score >= 50 ? kGoWarning : kGoNegative;
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
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$score', style: TextStyle(fontSize: size * 0.28, fontWeight: FontWeight.w700, color: color)),
              Text('/100', style: TextStyle(fontSize: size * 0.12, color: const Color(0xFF9CA3AF))),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// SECTION HEADER WITH ACTION
// ═══════════════════════════════════════════

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
          if (icon != null) ...[Icon(icon!, size: 18, color: kGoColor), const SizedBox(width: 8)],
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
          const Spacer(),
          if (actionLabel != null) GestureDetector(
            onTap: onAction,
            child: Text(actionLabel!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kGoColor)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// STEP INDICATOR (For wizard flows)
// ═══════════════════════════════════════════

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
            return Expanded(child: Container(height: 2, color: index ~/ 2 < currentStep ? kGoColor : const Color(0xFFE5E7EB)));
          }
          final step = index ~/ 2;
          final isActive = step <= currentStep;
          return Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isActive ? kGoColor : const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
              border: Border.all(color: isActive ? kGoColor : const Color(0xFFE5E7EB), width: 2),
            ),
            child: Center(
              child: step < currentStep
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : Text('${step + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isActive ? Colors.white : const Color(0xFF9CA3AF))),
            ),
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// AUDIT ENTRY ROW
// ═══════════════════════════════════════════

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
                Text(entry.action, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text('${entry.actor}${entry.ipAddress != null ? ' • ${entry.ipAddress}' : ''}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
              ],
            ),
          ),
          Text(_formatTimeAgo(entry.timestamp), style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
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

// ═══════════════════════════════════════════
// MINI DONUT CHART (Reusable)
// ═══════════════════════════════════════════

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
