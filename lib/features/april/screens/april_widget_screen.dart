/// APRIL Screen 0 — PROMPT Screen Integration (APRIL Widget)
/// Voice activation, quick actions, pending actions, plugin status

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/april_models.dart';
import '../providers/april_provider.dart';
import '../widgets/april_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class AprilWidgetScreen extends StatelessWidget {
  const AprilWidgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AprilProvider>(
      builder: (context, provider, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E5E7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kAprilColor.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(children: [
                      const Icon(Icons.auto_awesome, size: 14, color: kAprilColor),
                      const SizedBox(width: 8),
                      Expanded(child: Text('AI: ${ai.insights.first['title'] ?? ''}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kAprilColor),
                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                  );
                },
              ),
              // ──── VOICE ACTIVATION PANEL ────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(provider.userName),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1D1D1F),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            provider.voiceState == VoiceState.listening
                                ? 'Listening...'
                                : 'Tap to speak',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ),
                    AprilVoiceButton(
                      state: provider.voiceState,
                      size: 48,
                      onTap: () {
                        if (provider.voiceState == VoiceState.idle) {
                          provider.setVoiceState(VoiceState.listening);
                        } else {
                          provider.setVoiceState(VoiceState.idle);
                        }
                      },
                      onLongPress: () => provider.setVoiceState(VoiceState.listening),
                    ),
                  ],
                ),
              ),

              // ──── QUICK ACTIONS BAR ────
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _QuickActionChip(
                      icon: Icons.account_balance_wallet,
                      label: 'Review budget',
                      onTap: () => Navigator.pushNamed(context, '/april/planner'),
                    ),
                    _QuickActionChip(
                      icon: Icons.event,
                      label: 'Add event',
                      onTap: () => Navigator.pushNamed(context, '/april/calendar'),
                    ),
                    _QuickActionChip(
                      icon: Icons.card_giftcard,
                      label: 'Check wishlist',
                      onTap: () => Navigator.pushNamed(context, '/april/wishlist'),
                    ),
                    _QuickActionChip(
                      icon: Icons.description,
                      label: 'Update statement',
                      onTap: () => Navigator.pushNamed(context, '/april/statement'),
                    ),
                  ],
                ),
              ),

              const Divider(height: 20, indent: 16, endIndent: 16),

              // ──── PENDING ACTIONS ────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      'Actions pending',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1D1D1F)),
                    ),
                    const SizedBox(width: 8),
                    if (provider.pendingActionCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${provider.pendingActionCount}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/april'),
                      child: const Text(
                        'View all',
                        style: TextStyle(fontSize: 12, color: Color(0xFF007AFF), fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              if (provider.pendingActions.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'No pending actions 🎉',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                )
              else
                ...provider.pendingActions.take(3).map((action) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: PendingActionTile(action: action),
                )),

              const SizedBox(height: 12),

              // ──── PLUGIN STATUS INDICATORS ────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: provider.pluginStatuses.map((ps) {
                    return Expanded(
                      child: _MiniPluginStatus(status: ps),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _greeting(String name) {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning, $name ☀️';
    if (hour < 17) return 'Good afternoon, $name 🌤️';
    return 'Good evening, $name 🌙';
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _QuickActionChip({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E5E7)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: const Color(0xFF1D1D1F)),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(fontSize: 13, color: Color(0xFF1D1D1F)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniPluginStatus extends StatelessWidget {
  final PluginStatus status;
  const _MiniPluginStatus({required this.status});

  @override
  Widget build(BuildContext context) {
    final pluginIcons = {
      AprilPlugin.planner: Icons.account_balance_wallet,
      AprilPlugin.calendar: Icons.calendar_month,
      AprilPlugin.wishlist: Icons.card_giftcard,
      AprilPlugin.statement: Icons.description,
    };
    final syncColors = {
      SyncStatus.synced: const Color(0xFF10B981),
      SyncStatus.pending: const Color(0xFFF59E0B),
      SyncStatus.error: const Color(0xFFEF4444),
      SyncStatus.offline: const Color(0xFF6B7280),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Icon(pluginIcons[status.plugin], size: 20, color: const Color(0xFF6B7280)),
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: syncColors[status.syncStatus],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
