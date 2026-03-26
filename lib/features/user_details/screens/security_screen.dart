/// ═══════════════════════════════════════════════════════════════════════════
/// Screen 5: Security Deep Dive
/// 4 tabs: Auth Methods, Devices & Sessions, Emergency, Advanced
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../models/user_details_models.dart';
import '../providers/user_details_provider.dart';
import '../widgets/shared_widgets.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDetailsProvider>(
      builder: (context, udp, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, size: 22),
              color: AppColors.textPrimary,
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Security',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: const Color(0xFF10B981),
              unselectedLabelColor: AppColors.textTertiary,
              indicatorColor: const Color(0xFF10B981),
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              tabAlignment: TabAlignment.start,
              tabs: const [
                Tab(text: 'Auth Methods'),
                Tab(text: 'Devices'),
                Tab(text: 'Emergency'),
                Tab(text: 'Advanced'),
              ],
            ),
          ),
          body: Column(
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: AppColors.primary.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(children: [
                      const Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(child: Text('AI: ${ai.insights.first['title'] ?? ''}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.primary),
                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                  );
                },
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _AuthMethodsTab(security: udp.security),
                    _DevicesTab(security: udp.security),
                    _EmergencyTab(identity: udp.identity),
                    _AdvancedTab(security: udp.security),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Tab 1: Auth Methods
// ═══════════════════════════════════════════════════════════════════════════

class _AuthMethodsTab extends StatelessWidget {
  final SecuritySettings security;
  const _AuthMethodsTab({required this.security});

  @override
  Widget build(BuildContext context) {
    final udp = context.read<UserDetailsProvider>();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Security Score
        SectionCard(
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: security.passwordHealthScore / 100,
                          strokeWidth: 5,
                          backgroundColor: Colors.grey.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            security.passwordHealthScore >= 80
                                ? const Color(0xFF10B981)
                                : security.passwordHealthScore >= 50
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFFEF4444),
                          ),
                        ),
                        Text(
                          '${security.passwordHealthScore}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Security Score', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        Text('Your account security is strong', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        const Text('Authentication Methods', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 10),

        // Auth method list
        ...AuthMethod.values.where((m) => m != AuthMethod.none).map((method) {
          final isPrimary = security.primaryAuth == method;
          final isSecondary = security.secondaryAuth == method;
          return _AuthMethodCard(
            method: method,
            isPrimary: isPrimary,
            isSecondary: isSecondary,
            onSetPrimary: () {
              HapticFeedback.mediumImpact();
              udp.setPrimaryAuth(method);
            },
          );
        }),

        const SizedBox(height: 16),

        // 2FA
        SectionCard(
          child: Column(
            children: [
              SettingsToggle(
                icon: Icons.security,
                label: 'Two-Factor Authentication',
                subtitle: security.twoFactorEnabled
                    ? 'Active via ${security.twoFactorType?.label ?? "authenticator"}'
                    : 'Add an extra layer of security',
                value: security.twoFactorEnabled,
                onChanged: (v) => udp.toggle2FA(v),
                activeColor: const Color(0xFF10B981),
              ),
              if (security.twoFactorEnabled) ...[
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  children: TwoFactorType.values.map((t) {
                    final selected = security.twoFactorType == t;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: ChoiceChip(
                          label: Text(t.label, style: TextStyle(fontSize: 11, color: selected ? Colors.white : AppColors.textSecondary)),
                          selected: selected,
                          onSelected: (_) {},
                          selectedColor: const Color(0xFF10B981),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AuthMethodCard extends StatelessWidget {
  final AuthMethod method;
  final bool isPrimary;
  final bool isSecondary;
  final VoidCallback onSetPrimary;

  const _AuthMethodCard({
    required this.method,
    required this.isPrimary,
    required this.isSecondary,
    required this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SectionCard(
        borderColor: isPrimary ? const Color(0xFF10B981).withOpacity(0.3) : null,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (isPrimary ? const Color(0xFF10B981) : const Color(0xFF6366F1)).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(method.icon, size: 22, color: isPrimary ? const Color(0xFF10B981) : const Color(0xFF6366F1)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  if (isPrimary)
                    const Text('Primary', style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w500))
                  else if (isSecondary)
                    const Text('Secondary', style: TextStyle(fontSize: 11, color: Color(0xFF3B82F6), fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            if (!isPrimary)
              TextButton(
                onPressed: onSetPrimary,
                child: const Text('Set Primary', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Tab 2: Devices & Sessions
// ═══════════════════════════════════════════════════════════════════════════

class _DevicesTab extends StatelessWidget {
  final SecuritySettings security;
  const _DevicesTab({required this.security});

  @override
  Widget build(BuildContext context) {
    final udp = context.read<UserDetailsProvider>();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            const Text(
              'Active Sessions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const Spacer(),
            StatusBadge(
              label: '${security.activeSessions.length} active',
              color: const Color(0xFF3B82F6),
            ),
          ],
        ),
        const SizedBox(height: 14),

        ...security.activeSessions.map((session) => _SessionCard(
              session: session,
              onRevoke: session.isCurrent ? null : () {
                HapticFeedback.mediumImpact();
                udp.revokeSession(session.id);
              },
            )),

        if (security.activeSessions.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.heavyImpact();
                udp.revokeAllOtherSessions();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All other sessions revoked')),
                );
              },
              icon: const Icon(Icons.logout, size: 16),
              label: const Text('Revoke All Other Sessions'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],

        const SizedBox(height: 20),
        const Text('Recent Security Events', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 10),

        ...security.securityLog.take(5).map((event) => _SecurityEventCard(event: event)),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  final ActiveSession session;
  final VoidCallback? onRevoke;
  const _SessionCard({required this.session, this.onRevoke});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SectionCard(
        borderColor: session.isCurrent ? const Color(0xFF10B981).withOpacity(0.3) : null,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (session.isCurrent ? const Color(0xFF10B981) : const Color(0xFF3B82F6)).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(session.deviceIcon, size: 22, color: session.isCurrent ? const Color(0xFF10B981) : const Color(0xFF3B82F6)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(session.deviceName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      if (session.isCurrent) ...[
                        const SizedBox(width: 6),
                        const StatusBadge(label: 'This device', color: Color(0xFF10B981)),
                      ],
                      if (session.isTrusted) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_user, size: 12, color: Color(0xFF3B82F6)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${session.os} • ${session.location}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
            if (onRevoke != null)
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                color: AppColors.error,
                onPressed: onRevoke,
              ),
          ],
        ),
      ),
    );
  }
}

class _SecurityEventCard extends StatelessWidget {
  final SecurityEvent event;
  const _SecurityEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: event.severity.color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.description, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                if (event.deviceName != null || event.location != null)
                  Text(
                    [event.deviceName, event.location].whereType<String>().join(' • '),
                    style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Tab 3: Emergency
// ═══════════════════════════════════════════════════════════════════════════

class _EmergencyTab extends StatelessWidget {
  final dynamic identity;
  const _EmergencyTab({required this.identity});

  @override
  Widget build(BuildContext context) {
    final contacts = (identity as dynamic).emergencyContacts as List;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Emergency Contacts',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'These contacts can be reached in case of emergency or for account recovery.',
          style: TextStyle(fontSize: 12, color: AppColors.textTertiary, height: 1.4),
        ),
        const SizedBox(height: 16),

        ...contacts.map((ec) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SectionCard(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.emergency, size: 22, color: Color(0xFFEF4444)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ec.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          Text('${ec.relationship} • ${ec.phone}', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 16),
                      color: AppColors.textTertiary,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            )),

        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Emergency Contact'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              side: const BorderSide(color: Color(0xFFEF4444)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Recovery Options
        SectionCard(
          child: CollapsibleSection(
            title: 'Account Recovery',
            icon: Icons.restore,
            iconColor: const Color(0xFFF59E0B),
            initiallyExpanded: false,
            child: Column(
              children: [
                DetailRow(
                  icon: Icons.email,
                  label: 'Recovery Email',
                  value: identity.email ?? 'Not set',
                ),
                DetailRow(
                  icon: Icons.phone,
                  label: 'Recovery Phone',
                  value: identity.phone ?? 'Not set',
                ),
                DetailRow(
                  icon: Icons.key,
                  label: 'Recovery Codes',
                  value: '8 codes remaining',
                  trailing: TextButton(
                    onPressed: () {},
                    child: const Text('View', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Tab 4: Advanced Security
// ═══════════════════════════════════════════════════════════════════════════

class _AdvancedTab extends StatelessWidget {
  final SecuritySettings security;
  const _AdvancedTab({required this.security});

  @override
  Widget build(BuildContext context) {
    final udp = context.read<UserDetailsProvider>();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SectionCard(
          child: Column(
            children: [
              SettingsToggle(
                icon: Icons.lock_clock,
                label: 'Auto-Lock',
                subtitle: 'Lock after ${security.autoLockTimeout.inMinutes} minutes of inactivity',
                value: security.autoLockEnabled,
                onChanged: (v) {
                  udp.updateSecurity(security.copyWith(autoLockEnabled: v));
                },
                activeColor: const Color(0xFF10B981),
              ),
              const Divider(height: 1),
              SettingsToggle(
                icon: Icons.dangerous,
                label: 'Dead Man\'s Switch',
                subtitle: 'Auto-wipe data if no login for extended period',
                value: security.deadManSwitchEnabled,
                onChanged: (v) {
                  udp.updateSecurity(security.copyWith(deadManSwitchEnabled: v));
                },
                activeColor: const Color(0xFFEF4444),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Login Attempts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _MetricBox(
                      label: 'Failed Attempts',
                      value: '${security.failedAttempts}',
                      color: security.failedAttempts > 0 ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricBox(
                      label: 'Max Allowed',
                      value: '${security.maxFailedAttempts}',
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Danger Zone
        SectionCard(
          borderColor: const Color(0xFFEF4444).withOpacity(0.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.warning_amber, size: 18, color: Color(0xFFEF4444)),
                  SizedBox(width: 6),
                  Text('Danger Zone', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Reset All Security Settings'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Deactivate Account'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MetricBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}
