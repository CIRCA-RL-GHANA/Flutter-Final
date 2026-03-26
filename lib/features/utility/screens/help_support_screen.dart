/// ═══════════════════════════════════════════════════════════════════════════
/// U4: HELP & SUPPORT Screen
/// FAQ articles, support tickets, contact options, search help
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../models/utility_models.dart';
import '../providers/utility_provider.dart';
import '../widgets/shared_widgets.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UtilityProvider>(
      builder: (context, prov, _) {
        final articles = prov.helpArticles;
        final tickets = prov.supportTickets;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FC),
          appBar: const UtilityAppBar(title: 'Help & Support'),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kUtilityColor.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kUtilityColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI: ${ai.insights.first['title'] ?? ''}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kUtilityColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // ─── Search Help ───────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: prov.setHelpSearch,
                  decoration: const InputDecoration(
                    hintText: 'Search help articles...',
                    hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 15),
                    prefixIcon: Icon(Icons.search, color: AppColors.textTertiary),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ─── Contact Options ──────────────────────────
              const UtilitySectionTitle(
                title: 'Contact Us',
                icon: Icons.headset_mic,
                iconColor: Color(0xFF3B82F6),
              ),
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: UtilityProvider.contactOptions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final option = UtilityProvider.contactOptions[i];
                    return _ContactCard(option: option);
                  },
                ),
              ),

              const SizedBox(height: 16),

              // ─── Category Chips ───────────────────────────
              const UtilitySectionTitle(
                title: 'Help Articles',
                icon: Icons.article,
                iconColor: Color(0xFF10B981),
              ),
              SizedBox(
                height: 32,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _HelpCategoryChip(
                      label: 'All',
                      isSelected: prov.helpCategoryFilter == null,
                      onTap: () => prov.setHelpCategory(null),
                    ),
                    ...HelpCategory.values.map((c) => Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: _HelpCategoryChip(
                        label: _categoryLabel(c),
                        isSelected: prov.helpCategoryFilter == c,
                        onTap: () => prov.setHelpCategory(c),
                      ),
                    )),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ─── Articles List ────────────────────────────
              if (articles.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: UtilityEmptyState(
                    icon: Icons.article_outlined,
                    title: 'No Articles Found',
                    subtitle: 'Try a different search or category.',
                  ),
                )
              else
                ...articles.map((article) => _ArticleCard(article: article)),

              // ─── Support Tickets ──────────────────────────
              if (tickets.isNotEmpty) ...[
                const SizedBox(height: 16),
                const UtilitySectionTitle(
                  title: 'Your Tickets',
                  icon: Icons.confirmation_number,
                  iconColor: Color(0xFFF59E0B),
                ),
                ...tickets.map((ticket) => _TicketCard(ticket: ticket)),
              ],
            ],
          ),
        );
      },
    );
  }

  String _categoryLabel(HelpCategory c) {
    switch (c) {
      case HelpCategory.gettingStarted: return 'Getting Started';
      case HelpCategory.account: return 'Account';
      case HelpCategory.payments: return 'Payments';
      case HelpCategory.orders: return 'Orders';
      case HelpCategory.security: return 'Security';
      case HelpCategory.troubleshooting: return 'Troubleshooting';
      case HelpCategory.contact: return 'Contact';
    }
  }
}

// ─── Contact Card ────────────────────────────────────────────────────────────

class _ContactCard extends StatelessWidget {
  final ContactOption option;
  const _ContactCard({required this.option});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(option.icon, size: 22, color: option.color),
            const Spacer(),
            Text(
              option.label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            Text(
              option.subtitle,
              style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Category Chip ───────────────────────────────────────────────────────────

class _HelpCategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _HelpCategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : AppColors.inputBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Article Card ────────────────────────────────────────────────────────────

class _ArticleCard extends StatefulWidget {
  final HelpArticle article;
  const _ArticleCard({required this.article});

  @override
  State<_ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<_ArticleCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _expanded = !_expanded);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: widget.article.isPinned
                ? Border.all(color: const Color(0xFF10B981).withOpacity(0.2))
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(widget.article.icon, size: 20, color: const Color(0xFF10B981)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.article.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (widget.article.isPinned)
                    const Icon(Icons.push_pin, size: 14, color: Color(0xFF10B981)),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more, size: 20, color: AppColors.textTertiary),
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 10),
                Text(
                  widget.article.content,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.visibility, size: 12, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.article.viewCount} views',
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                    const Spacer(),
                    ...widget.article.tags.take(3).map((t) => Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(t, style: const TextStyle(fontSize: 9, color: AppColors.textTertiary)),
                      ),
                    )),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Ticket Card ─────────────────────────────────────────────────────────────

class _TicketCard extends StatelessWidget {
  final SupportTicket ticket;
  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: UtilitySectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ticket.subject,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ),
                UtilityStatusIndicator(
                  label: _statusLabel(ticket.status),
                  color: _statusColor(ticket.status),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '#${ticket.id} · ${ticket.messages.length} message${ticket.messages.length != 1 ? 's' : ''}',
              style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
            ),
            if (ticket.assignedAgent != null) ...[
              const SizedBox(height: 4),
              Text(
                'Assigned: ${ticket.assignedAgent}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _statusLabel(TicketStatus s) {
    switch (s) {
      case TicketStatus.open: return 'Open';
      case TicketStatus.inProgress: return 'In Progress';
      case TicketStatus.waitingOnUser: return 'Waiting';
      case TicketStatus.resolved: return 'Resolved';
      case TicketStatus.closed: return 'Closed';
    }
  }

  Color _statusColor(TicketStatus s) {
    switch (s) {
      case TicketStatus.open: return const Color(0xFF3B82F6);
      case TicketStatus.inProgress: return const Color(0xFFF59E0B);
      case TicketStatus.waitingOnUser: return const Color(0xFF8B5CF6);
      case TicketStatus.resolved: return const Color(0xFF10B981);
      case TicketStatus.closed: return const Color(0xFF64748B);
    }
  }
}
