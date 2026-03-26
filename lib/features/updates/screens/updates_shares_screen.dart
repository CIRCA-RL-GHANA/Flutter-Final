/// ═══════════════════════════════════════════════════════════════════════════
/// SCREEN 4 — Shares List & Actions
/// Two-pane layout: share history (who shared, platform, reach) and
/// share actions (copy link, platform icons, QR code).
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../models/updates_models.dart';
import '../providers/updates_provider.dart';
import '../widgets/updates_widgets.dart';

class UpdatesSharesScreen extends StatelessWidget {
  const UpdatesSharesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UpdatesProvider(),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdatesProvider>(
      builder: (context, prov, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: const UpdatesAppBar(title: 'Shares'),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<AIInsightsNotifier>(
                  builder: (context, ai, _) {
                    if (ai.insights.isEmpty) return const SizedBox.shrink();
                    return Container(
                      color: kUpdatesColor.withOpacity(0.07),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Row(children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kUpdatesColor),
                        const SizedBox(width: 8),
                        Expanded(child: Text('AI: ${ai.insights.first['title'] ?? ''}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kUpdatesColor),
                          maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ]),
                    );
                  },
                ),
                // Share Stats Summary
                _ShareStatsBanner(stats: prov.shareStats),

                const SizedBox(height: 14),

                // Share Actions
                UpdatesSectionCard(
                  title: 'SHARE THIS UPDATE',
                  icon: Icons.share,
                  iconColor: const Color(0xFF10B981),
                  child: Column(
                    children: [
                      _ShareAction(icon: Icons.link, label: 'Copy Link', subtitle: 'Copy shareable link to clipboard', onTap: () {
                        HapticFeedback.mediumImpact();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied!'), backgroundColor: kUpdatesColor, duration: Duration(seconds: 1)));
                      }),
                      const Divider(height: 1),
                      _ShareAction(icon: Icons.qr_code, label: 'QR Code', subtitle: 'Generate QR code for sharing', onTap: () {
                        HapticFeedback.lightImpact();
                        _showQRDialog(context);
                      }),
                      const Divider(height: 1),
                      _ShareAction(icon: Icons.mail_outline, label: 'Email', subtitle: 'Share via email', onTap: () => HapticFeedback.lightImpact()),
                      const Divider(height: 1),
                      _ShareAction(icon: Icons.sms, label: 'SMS / Message', subtitle: 'Send via text message', onTap: () => HapticFeedback.lightImpact()),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Platform Breakdown
                UpdatesSectionCard(
                  title: 'PLATFORM BREAKDOWN',
                  icon: Icons.pie_chart,
                  iconColor: kUpdatesAccent,
                  child: Column(
                    children: prov.shareStats.platformBreakdown.entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(_platformIconStr(e.key), size: 18, color: _platformColorStr(e.key)),
                          const SizedBox(width: 8),
                          Text(e.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          const Spacer(),
                          Text('${e.value}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 60,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: prov.shareStats.totalShares > 0 ? e.value / prov.shareStats.totalShares : 0,
                                backgroundColor: Colors.grey.shade100,
                                valueColor: AlwaysStoppedAnimation(_platformColorStr(e.key)),
                                minHeight: 4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),

                const SizedBox(height: 14),

                // Share History
                UpdatesSectionCard(
                  title: 'SHARE HISTORY',
                  icon: Icons.history,
                  child: prov.shares.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: Text('No shares yet', style: TextStyle(fontSize: 13, color: AppColors.textTertiary))),
                        )
                      : Column(
                          children: prov.shares.map((s) => _ShareHistoryItem(share: s)).toList(),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showQRDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('QR Code', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Center(
                child: Icon(Icons.qr_code_2, size: 120, color: AppColors.textTertiary),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Scan to view this update', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: kUpdatesColor, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─── Share Stats Banner ─────────────────────────────────────────────────────

class _ShareStatsBanner extends StatelessWidget {
  final ShareStats stats;
  const _ShareStatsBanner({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kUpdatesColor.withOpacity(0.08), kUpdatesAccent.withOpacity(0.06)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kUpdatesColor.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatColumn(value: '${stats.totalShares}', label: 'Total Shares', icon: Icons.shortcut),
          Container(width: 1, height: 40, color: kUpdatesColor.withOpacity(0.15)),
          _StatColumn(value: '${(stats.totalShares * 3.5).round()}', label: 'Est. Reach', icon: Icons.visibility),
          Container(width: 1, height: 40, color: kUpdatesColor.withOpacity(0.15)),
          _StatColumn(value: '${stats.platformBreakdown.length}', label: 'Platforms', icon: Icons.devices),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const _StatColumn({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: kUpdatesColor),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
      ],
    );
  }
}

// ─── Share Action ───────────────────────────────────────────────────────────

class _ShareAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  const _ShareAction({required this.icon, required this.label, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: kUpdatesColor.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 18, color: kUpdatesColor),
      ),
      title: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
      trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }
}

// ─── Share History Item ─────────────────────────────────────────────────────

class _ShareHistoryItem extends StatelessWidget {
  final UpdateShare share;
  const _ShareHistoryItem({required this.share});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: kUpdatesColor.withOpacity(0.12),
            child: Text(share.username.substring(0, 1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kUpdatesColor)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(share.username, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    Icon(_platformIconStr(share.platform), size: 12, color: AppColors.textTertiary),
                    const SizedBox(width: 3),
                    Text('via ${share.platform}', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                    const Text(' • ', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                    Text(_timeAgo(share.sharedAt), style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
            child: Text('${share.followerCount} reach', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF10B981))),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────────

IconData _platformIconStr(String p) => switch (p) {
      'QualChat' => Icons.group,
      'WhatsApp' => Icons.chat,
      'Twitter' => Icons.tag,
      'Email' => Icons.email,
      'SMS' => Icons.sms,
      _ => Icons.share,
    };

Color _platformColorStr(String p) => switch (p) {
      'QualChat' => kUpdatesColor,
      'WhatsApp' => const Color(0xFF25D366),
      'Twitter' => const Color(0xFF1DA1F2),
      'Email' => const Color(0xFFEA4335),
      'SMS' => const Color(0xFF34B7F1),
      _ => AppColors.textTertiary,
    };

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  return '${(diff.inDays / 7).floor()}w';
}
