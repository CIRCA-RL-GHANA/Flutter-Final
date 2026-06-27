/// 
/// Screen 5: Security Deep Dive
/// 4 tabs: Auth Methods, Devices & Sessions, Emergency, Advanced
/// 
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive.dart';
import '../../../core/network/api_client.dart';
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
          backgroundColor: IveTokens.voidColor,
          appBar: AppBar(
            backgroundColor: IveTokens.voidColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, size: 22),
              color: IveTokens.inkColor,
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('Security', style: IveType.title3),
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: IveTokens.accentColor,
              unselectedLabelColor: IveTokens.muteColor,
              indicatorColor: IveTokens.accentColor,
              indicatorWeight: 2,
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

// 
// Tab 1: Auth Methods
// 

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
                          backgroundColor: IveTokens.hairColor,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            security.passwordHealthScore >= 80
                                ? IveTokens.okColor
                                : security.passwordHealthScore >= 50
                                    ? IveTokens.warnColor
                                    : IveTokens.badColor,
                          ),
                        ),
                        Text(
                          '${security.passwordHealthScore}',
                          style: IveType.callout.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Security score', style: IveType.callout.copyWith(fontWeight: FontWeight.w600)),
                        Text('Your account security is strong', style: IveType.caption.copyWith(color: IveTokens.muteColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        Text('Authentication methods', style: IveType.callout.copyWith(color: IveTokens.ink2Color, fontWeight: FontWeight.w600)),
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
                label: 'Two-factor authentication',
                subtitle: security.twoFactorEnabled
                    ? 'Active via ${security.twoFactorType?.label ?? "authenticator"}'
                    : 'Add an extra layer of security',
                value: security.twoFactorEnabled,
                onChanged: (v) => udp.toggle2FA(v),
                activeColor: IveTokens.okColor,
              ),
              if (security.twoFactorEnabled) ...[
                const Divider(height: 1, color: IveTokens.hairColor),
                const SizedBox(height: 8),
                Row(
                  children: TwoFactorType.values.map((t) {
                    final selected = security.twoFactorType == t;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: ChoiceChip(
                          label: Text(t.label, style: TextStyle(fontSize: 11, color: selected ? IveTokens.inkColor : IveTokens.muteColor)),
                          selected: selected,
                          onSelected: (_) {
                            HapticFeedback.selectionClick();
                            udp.updateSecurity(security.copyWith(twoFactorType: t));
                          },
                          selectedColor: IveTokens.accentColor,
                          backgroundColor: IveTokens.surfaceColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(IveTokens.rAtom)),
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
        borderColor: isPrimary ? IveTokens.okColor.withValues(alpha: 0.35) : null,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (isPrimary ? IveTokens.okColor : IveTokens.accentColor).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(IveTokens.rContainer),
              ),
              child: Icon(method.icon, size: 22, color: isPrimary ? IveTokens.okColor : IveTokens.accentColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.label, style: IveType.callout.copyWith(fontWeight: FontWeight.w600)),
                  if (isPrimary)
                    Text('Primary', style: IveType.caption.copyWith(color: IveTokens.okColor, fontWeight: FontWeight.w500))
                  else if (isSecondary)
                    Text('Secondary', style: IveType.caption.copyWith(color: IveTokens.infoColor, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            if (!isPrimary)
              TextButton(
                onPressed: onSetPrimary,
                child: Text('Set primary', style: IveType.caption.copyWith(color: IveTokens.accentColor, fontWeight: FontWeight.w600)),
              ),
          ],
        ),
      ),
    );
  }
}

// 
// Tab 2: Devices & Sessions
// 

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
            Text('Active sessions', style: IveType.headline),
            const Spacer(),
            StatusBadge(
              label: '${security.activeSessions.length} active',
              color: IveTokens.infoColor,
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Sessions list with one-tap revoke via VerifySheet (spec P1)
        ...security.activeSessions.map((session) => _SessionCard(
              session: session,
              onRevoke: session.isCurrent
                  ? null
                  : () async {
                      final confirmed = await showVerifySheet(
                        context,
                        title: 'End session',
                        confirmLabel: 'End session',
                        subtitle: '${session.deviceName} will be signed out immediately.',
                        isDestructive: true,
                        onConfirm: () async {
                          udp.revokeSession(session.id);
                          return null;
                        },
                      );
                      if (confirmed) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${session.deviceName} signed out')),
                          );
                        }
                      }
                    },
            )),

        if (security.activeSessions.length > 1) ...[
          const SizedBox(height: 12),
          IveButton.primary(
            label: 'End all other sessions',
            isDestructive: true,
            onPressed: () async {
              final confirmed = await showVerifySheet(
                context,
                title: 'End all other sessions',
                confirmLabel: 'End all sessions',
                subtitle: 'All sessions except this device will be signed out.',
                isDestructive: true,
                onConfirm: () async {
                  HapticFeedback.heavyImpact();
                  udp.revokeAllOtherSessions();
                  return null;
                },
              );
              if (confirmed && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All other sessions revoked')),
                );
              }
            },
          ),
        ],

        const SizedBox(height: 20),
        Text('Recent security events', style: IveType.callout.copyWith(color: IveTokens.ink2Color, fontWeight: FontWeight.w600)),
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
        borderColor: session.isCurrent ? IveTokens.okColor.withValues(alpha: 0.3) : null,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (session.isCurrent ? IveTokens.okColor : IveTokens.infoColor).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(IveTokens.rContainer),
              ),
              child: Icon(session.deviceIcon, size: 22, color: session.isCurrent ? IveTokens.okColor : IveTokens.infoColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(session.deviceName, style: IveType.callout.copyWith(fontWeight: FontWeight.w600)),
                      if (session.isCurrent) ...[
                        const SizedBox(width: 6),
                        const StatusBadge(label: 'This device', color: IveTokens.okColor),
                      ],
                      if (session.isTrusted) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_user, size: 12, color: IveTokens.infoColor),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${session.os}  ${session.location}',
                    style: IveType.caption.copyWith(color: IveTokens.muteColor),
                  ),
                ],
              ),
            ),
            if (onRevoke != null)
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                color: IveTokens.badColor,
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
                Text(event.description, style: IveType.callout),
                if (event.deviceName != null || event.location != null)
                  Text(
                    [event.deviceName, event.location].whereType<String>().join('  '),
                    style: IveType.caption.copyWith(color: IveTokens.muteColor),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 
// Tab 3: Emergency
// 

class _EmergencyTab extends StatelessWidget {
  final dynamic identity;
  const _EmergencyTab({required this.identity});

  @override
  Widget build(BuildContext context) {
    final contacts = (identity as dynamic).emergencyContacts as List;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Emergency contacts', style: IveType.headline),
        const SizedBox(height: 4),
        Text(
          'These contacts can be reached in case of emergency or for account recovery.',
          style: IveType.caption.copyWith(color: IveTokens.muteColor, height: 1.4),
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
                        color: IveTokens.badColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(IveTokens.rContainer),
                      ),
                      child: const Icon(Icons.emergency, size: 22, color: IveTokens.badColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ec.name, style: IveType.callout.copyWith(fontWeight: FontWeight.w600)),
                          Text('${ec.relationship}  ${ec.phone}', style: IveType.caption.copyWith(color: IveTokens.muteColor)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 16),
                      color: IveTokens.muteColor,
                      onPressed: () {
                        final nameCtrl = TextEditingController(text: ec.name);
                        final phoneCtrl = TextEditingController(text: ec.phone);
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: IveTokens.raisedColor,
                            title: Text('Edit emergency contact', style: IveType.title3),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  controller: nameCtrl,
                                  style: IveType.body,
                                  decoration: const InputDecoration(labelText: 'Name'),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: phoneCtrl,
                                  style: IveType.body,
                                  decoration: const InputDecoration(labelText: 'Phone'),
                                  keyboardType: TextInputType.phone,
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text('Cancel', style: IveType.callout.copyWith(color: IveTokens.muteColor)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Contact updated')),
                                  );
                                },
                                child: Text('Update', style: IveType.callout.copyWith(color: IveTokens.accentColor, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            )),

        const SizedBox(height: 8),
        IveButton.secondary(
          label: 'Add emergency contact',
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add emergency contact')),
          ),
        ),

        const SizedBox(height: 24),

        // Recovery Options
        SectionCard(
          child: CollapsibleSection(
            title: 'Account recovery',
            icon: Icons.restore,
            iconColor: IveTokens.warnColor,
            initiallyExpanded: false,
            child: Column(
              children: [
                DetailRow(
                  icon: Icons.email,
                  label: 'Recovery email',
                  value: identity.email ?? 'Not set',
                ),
                DetailRow(
                  icon: Icons.phone,
                  label: 'Recovery phone',
                  value: identity.phone ?? 'Not set',
                ),
                DetailRow(
                  icon: Icons.key,
                  label: 'Recovery codes',
                  value: '8 codes remaining',
                  trailing: TextButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Recovery codes')),
                    ),
                    child: Text('View', style: IveType.caption.copyWith(color: IveTokens.accentColor)),
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

// 
// Tab 4: Advanced Security
// 

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
                label: 'Auto-lock',
                subtitle: 'Lock after ${security.autoLockTimeout.inMinutes} minutes of inactivity',
                value: security.autoLockEnabled,
                onChanged: (v) {
                  udp.updateSecurity(security.copyWith(autoLockEnabled: v));
                },
                activeColor: IveTokens.okColor,
              ),
              const Divider(height: 1, color: IveTokens.hairColor),
              SettingsToggle(
                icon: Icons.dangerous,
                label: "Dead man's switch",
                subtitle: 'Auto-wipe data if no login for extended period',
                value: security.deadManSwitchEnabled,
                onChanged: (v) {
                  udp.updateSecurity(security.copyWith(deadManSwitchEnabled: v));
                },
                activeColor: IveTokens.badColor,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Login attempts', style: IveType.callout.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _MetricBox(
                      label: 'Failed attempts',
                      value: '${security.failedAttempts}',
                      color: security.failedAttempts > 0 ? IveTokens.warnColor : IveTokens.okColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricBox(
                      label: 'Max allowed',
                      value: '${security.maxFailedAttempts}',
                      color: IveTokens.infoColor,
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
          borderColor: IveTokens.badColor.withValues(alpha: 0.25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber, size: 18, color: IveTokens.badColor),
                  const SizedBox(width: 6),
                  Text('Danger zone', style: IveType.callout.copyWith(fontWeight: FontWeight.w600, color: IveTokens.badColor)),
                ],
              ),
              const SizedBox(height: 12),
              IveButton.primary(
                label: 'Reset all security settings',
                isDestructive: true,
                onPressed: () async {
                  final confirmed = await showVerifySheet(
                    context,
                    title: 'Reset security settings',
                    confirmLabel: 'Reset settings',
                    subtitle: 'All security settings will be reset. This cannot be undone.',
                    isDestructive: true,
                    onConfirm: () async {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Resetting security settings...')),
                        );
                        Navigator.pop(context);
                      }
                      return null;
                    },
                  );
                  if (!confirmed) return;
                },
              ),
              const SizedBox(height: 8),
              IveButton.primary(
                label: 'Deactivate account',
                isDestructive: true,
                onPressed: () async {
                  final confirmed = await showVerifySheet(
                    context,
                    title: 'Deactivate account',
                    confirmLabel: 'Deactivate account',
                    subtitle: 'You can reactivate within 30 days by logging in.',
                    isDestructive: true,
                    onConfirm: () async {
                      await ApiClient.instance.clearTokens();
                      return null;
                    },
                  );
                  if (confirmed && context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/pre-loading',
                      (route) => false,
                    );
                  }
                },
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
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label, style: IveType.caption.copyWith(color: IveTokens.muteColor)),
        ],
      ),
    );
  }
}
