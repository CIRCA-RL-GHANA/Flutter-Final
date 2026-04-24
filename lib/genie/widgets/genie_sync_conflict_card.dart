/// ═══════════════════════════════════════════════════════════════════════════
/// GenieSyncConflictCard
///
/// Renders a side-by-side comparison of the local vs server version of a
/// conflicting resource. The user can accept one version with a single tap.
/// Haptic bracket-style feedback confirms selection.
///
/// Recommendation 2 — Sync-Conflict UI.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../genie_offline_cache.dart';
import '../genie_tactile_actions.dart';

class GenieSyncConflictCard extends StatelessWidget {
  final SyncConflict conflict;
  final VoidCallback? onDismiss;

  const GenieSyncConflictCard({
    super.key,
    required this.conflict,
    this.onDismiss,
  });

  Future<void> _resolve(BuildContext context, bool acceptLocal) async {
    await GenieTactileActions.trigger(
      acceptLocal
          ? GenieTactileEvent.mediumImpact
          : GenieTactileEvent.lightTick,
    );
    await GenieOfflineCache.resolveConflict(conflict.resourceId, acceptLocal);
    onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.errorContainer.withOpacity(0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.error.withOpacity(0.35)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.sync_problem_rounded, color: cs.error, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sync conflict — ${conflict.resourceType}',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: cs.error,
                      fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Side-by-side version comparison
          Row(
            children: [
              Expanded(
                child: _VersionCard(
                  label: 'Your offline version',
                  timestamp: conflict.localTimestamp,
                  data: conflict.localVersion,
                  accentColor: const Color(0xFF3F51B5),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _VersionCard(
                  label: 'Server version',
                  timestamp: conflict.serverTimestamp,
                  data: conflict.serverVersion,
                  accentColor: const Color(0xFF00897B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Action row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _resolve(context, true),
                  icon: const Icon(Icons.phone_android_rounded, size: 15),
                  label: const Text('Keep mine'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _resolve(context, false),
                  icon: const Icon(Icons.cloud_done_rounded, size: 15),
                  label: const Text('Use server'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VersionCard extends StatelessWidget {
  final String label;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  final Color accentColor;

  const _VersionCard({
    required this.label,
    required this.timestamp,
    required this.data,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentColor.withOpacity(0.28)),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: accentColor)),
          const SizedBox(height: 4),
          Text(
            _timeLabel(timestamp),
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          // Show key fields from the version map
          ...data.entries.take(3).map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '${e.key}: ${e.value}',
                  style: const TextStyle(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )),
        ],
      ),
    );
  }

  String _timeLabel(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
