/// 
/// Screen 1: USER DETAILS Master Dashboard
/// Identity section, multi-context carousel, collapsible sections, footer
/// 
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive_tokens.dart';
import '../../../core/design/ive_text.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../../onboarding/providers/phone_auth_provider.dart';
import '../../prompt/providers/context_provider.dart';
import '../models/user_details_models.dart';
import '../providers/user_details_provider.dart';
import '../widgets/shared_widgets.dart';

class UserDetailsMasterScreen extends StatelessWidget {
  const UserDetailsMasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserDetailsProvider, ContextProvider>(
      builder: (context, udp, ctxProvider, _) {
        final identity = udp.identity;
        final activeCtx = ctxProvider.activeContext;
        final allContexts = ctxProvider.availableContexts;

        return Scaffold(
          backgroundColor: IveTokens.bg,
          body: CustomScrollView(
            slivers: [
              //  App Bar 
              SliverAppBar(
                expandedHeight: 0,
                floating: true,
                snap: true,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, size: 22),
                  color: AppColors.textPrimary,
                  onPressed: () => Navigator.pop(context),
                ),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: contextTypeColor(activeCtx.entityType),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'User Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: Icon(
                      udp.editMode ? Icons.check : Icons.edit_outlined,
                      size: 20,
                    ),
                    color: udp.editMode ? AppColors.success : AppColors.textPrimary,
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      udp.toggleEditMode();
                    },
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textPrimary),
                    onSelected: (v) => _handleMenuAction(context, v, udp),
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'export', child: Text('Download My Data')),
                      const PopupMenuItem(value: 'audit', child: Text('Activity Log')),
                      const PopupMenuItem(value: 'help', child: Text('Help & Support')),
                    ],
                  ),
                ],
              ),
              //  AI Insights 
              const SliverToBoxAdapter(
              ),
              //  Identity Section 
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: _IdentitySection(identity: identity, editMode: udp.editMode),
                ),
              ),

              //  Quick Stats 
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: _QuickStats(identity: identity),
                ),
              ),

              //  Multi-Context Carousel 
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _ContextCarousel(
                    contexts: allContexts,
                    activeId: activeCtx.id,
                    onSwitch: (ctx) {
                      HapticFeedback.mediumImpact();
                      ctxProvider.switchContext(ctx);
                    },
                    onManage: () => Navigator.pushNamed(context, AppRoutes.userDetailsContexts),
                  ),
                ),
              ),

              //  Personal Information 
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: SectionCard(
                    child: CollapsibleSection(
                      title: 'Personal Information',
                      icon: Icons.person_outline,
                      iconColor: IveTokens.moduleSetup,
                      child: _PersonalInfoContent(identity: identity, editMode: udp.editMode),
                    ),
                  ),
                ),
              ),

              //  Security Center 
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: SectionCard(
                    child: CollapsibleSection(
                      title: 'Security Center',
                      icon: Icons.shield_outlined,
                      iconColor: IveTokens.success,
                      initiallyExpanded: false,
                      child: _SecurityPreview(security: udp.security),
                    ),
                  ),
                ),
              ),

              //  Preferences Hub 
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: SectionCard(
                    child: CollapsibleSection(
                      title: 'Preferences Hub',
                      icon: Icons.tune,
                      iconColor: IveTokens.moduleUpdates,
                      initiallyExpanded: false,
                      child: _PreferencesHub(
                        notifications: udp.notifications,
                        privacy: udp.privacy,
                        accessibility: udp.accessibility,
                      ),
                    ),
                  ),
                ),
              ),

              //  Context-Specific Settings 
              if (activeCtx.entityType.toString().contains('business') ||
                  activeCtx.entityType.toString().contains('branch'))
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: SectionCard(
                      borderColor: contextTypeColor(activeCtx.entityType).withValues(alpha: 0.2),
                      child: CollapsibleSection(
                        title: '${activeCtx.name} Settings',
                        icon: Icons.settings_outlined,
                        iconColor: contextTypeColor(activeCtx.entityType),
                        initiallyExpanded: false,
                        child: _ContextSpecificSettings(entityType: activeCtx.entityType),
                      ),
                    ),
                  ),
                ),

              // Sign out
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: _SignOutRow(),
                ),
              ),

              //  Bottom Spacer
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          //  Sticky Footer 
          bottomNavigationBar: _StickyFooter(
            onHelp: () {},
            onDownload: () => udp.requestDataExport(),
            onFab: () => Navigator.pushNamed(context, AppRoutes.userDetailsCreateEntity),
          ),
        );
      },
    );
  }

  void _handleMenuAction(BuildContext context, String action, UserDetailsProvider udp) {
    switch (action) {
      case 'export':
        udp.requestDataExport();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data export initiated...')),
        );
        break;
      case 'audit':
        Navigator.pushNamed(context, AppRoutes.userDetailsAuditLog);
        break;
      case 'help':
        break;
    }
  }
}

// 
// Identity Section
// 

class _IdentitySection extends StatelessWidget {
  final UserIdentity identity;
  final bool editMode;

  const _IdentitySection({required this.identity, required this.editMode});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Avatar + Verification Badge
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.userDetailsAvatarEditor),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Status ring
                Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: identity.verificationLevel.color,
                      width: 3,
                    ),
                  ),
                ),
                // Avatar
                CircleAvatar(
                  radius: 48,
                  backgroundColor: IveTokens.moduleSetup.withValues(alpha: 0.1),
                  child: identity.avatarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            identity.avatarUrl!,
                            fit: BoxFit.cover,
                            width: 96,
                            height: 96,
                            semanticLabel: 'User avatar',
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const SizedBox(
                                width: 96,
                                height: 96,
                                child: Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stack) => Text(
                              identity.displayName.isNotEmpty
                                  ? identity.displayName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: IveTokens.moduleSetup,
                              ),
                            ),
                          ),
                        )
                      : Text(
                          identity.displayName.isNotEmpty
                              ? identity.displayName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: IveTokens.moduleSetup,
                          ),
                        ),
                ),
                // Edit overlay
                if (editMode)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: IveTokens.moduleSetup,
                      ),
                      child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                    ),
                  ),
                // Verification badge
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: identity.verificationLevel.color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      identity.verificationLevel.icon,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Name
          Text(
            identity.displayName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            identity.handle,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),

          if (identity.bio != null && identity.bio!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              identity.bio!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 12),

          // Verification badge
          StatusBadge(
            label: identity.verificationLevel.label,
            color: identity.verificationLevel.color,
            icon: identity.verificationLevel.icon,
          ),
        ],
      ),
    );
  }
}

// 
// Quick Stats
// 

class _QuickStats extends StatelessWidget {
  final UserIdentity identity;
  const _QuickStats({required this.identity});

  @override
  Widget build(BuildContext context) {
    final daysSinceJoined = DateTime.now().difference(identity.joinedDate).inDays;
    final memberDuration = daysSinceJoined > 365
        ? '${(daysSinceJoined / 365).floor()} yr'
        : '${(daysSinceJoined / 30).floor()} mo';

    return Row(
      children: [
        _StatChip(
          label: 'Profile',
          value: '${(identity.profileCompleteness * 100).toInt()}%',
          color: IveTokens.moduleSetup,
          icon: Icons.person,
        ),
        const SizedBox(width: 8),
        _StatChip(
          label: 'Member',
          value: memberDuration,
          color: IveTokens.success,
          icon: Icons.calendar_today,
        ),
        const SizedBox(width: 8),
        _StatChip(
          label: 'Contacts',
          value: '${identity.emergencyContacts.length}',
          color: IveTokens.moduleUpdates,
          icon: Icons.people,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatChip({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
                  Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 
// Multi-Context Carousel
// 

class _ContextCarousel extends StatelessWidget {
  final List<dynamic> contexts;
  final String activeId;
  final ValueChanged<dynamic> onSwitch;
  final VoidCallback onManage;

  const _ContextCarousel({
    required this.contexts,
    required this.activeId,
    required this.onSwitch,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Icon(Icons.swap_horiz, size: 16, color: AppColors.textTertiary),
              const SizedBox(width: 6),
              const Text(
                'Your Contexts',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onManage,
                child: const Text(
                  'Manage',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: IveTokens.moduleSetup),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: contexts.length + 1,
            itemBuilder: (ctx, i) {
              if (i == contexts.length) {
                return _AddContextCard(onTap: onManage);
              }
              final c = contexts[i];
              final isActive = c.id == activeId;
              return _ContextCard(
                context: c,
                isActive: isActive,
                onTap: () => onSwitch(c),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ContextCard extends StatelessWidget {
  final dynamic context;
  final bool isActive;
  final VoidCallback onTap;
  const _ContextCard({required this.context, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context2) {
    final color = contextTypeColor(context.entityType);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? color : Colors.grey.withValues(alpha: 0.15),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Text(
                context.name.isNotEmpty ? context.name[0].toUpperCase() : '?',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? color : AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddContextCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AddContextCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2), style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: IveTokens.moduleSetup.withValues(alpha: 0.08),
              ),
              child: const Icon(Icons.add, size: 18, color: IveTokens.moduleSetup),
            ),
            const SizedBox(height: 4),
            const Text(
              'Add',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: IveTokens.moduleSetup),
            ),
          ],
        ),
      ),
    );
  }
}

// 
// Personal Information
// 

class _PersonalInfoContent extends StatelessWidget {
  final UserIdentity identity;
  final bool editMode;
  const _PersonalInfoContent({required this.identity, required this.editMode});

  void _edit(BuildContext context, String field, String title, String current, ValueChanged<String> onSave) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
      builder: (_) => EditFieldModal(title: title, initialValue: current, onSave: onSave),
    );
  }

  @override
  Widget build(BuildContext context) {
    final udp = context.read<UserDetailsProvider>();
    return Column(
      children: [
        DetailRow(
          icon: Icons.badge_outlined,
          label: 'Legal Name',
          value: identity.legalName,
        ),
        DetailRow(
          icon: Icons.alternate_email,
          label: 'Display Name',
          value: identity.displayName,
          editable: editMode,
          onTap: editMode
              ? () => _edit(context, 'displayName', 'Edit Display Name', identity.displayName,
                  (v) => udp.updateField(displayName: v))
              : null,
        ),
        DetailRow(
          icon: Icons.email_outlined,
          label: 'Email',
          value: identity.email ?? 'Not set',
          trailing: identity.emailVerified
              ? const Icon(Icons.verified, size: 14, color: IveTokens.success)
              : null,
          editable: editMode,
          onTap: editMode
              ? () => _edit(context, 'email', 'Edit Email', identity.email ?? '',
                  (v) => udp.updateField(email: v))
              : null,
        ),
        DetailRow(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: identity.phone ?? 'Not set',
          trailing: identity.phoneVerified
              ? const Icon(Icons.verified, size: 14, color: IveTokens.success)
              : null,
        ),
        DetailRow(
          icon: Icons.location_on_outlined,
          label: 'Address',
          value: identity.address ?? 'Not set',
          editable: editMode,
          onTap: editMode
              ? () => _edit(context, 'address', 'Edit Address', identity.address ?? '',
                  (v) => udp.updateField(address: v))
              : null,
        ),
        DetailRow(
          icon: Icons.cake_outlined,
          label: 'Date of Birth',
          value: identity.dateOfBirth != null
              ? '${identity.dateOfBirth!.day}/${identity.dateOfBirth!.month}/${identity.dateOfBirth!.year}'
              : 'Not set',
        ),
        DetailRow(
          icon: Icons.wc_outlined,
          label: 'Gender',
          value: identity.gender.label,
        ),
        DetailRow(
          icon: Icons.language,
          label: 'Language',
          value: identity.primaryLanguage,
        ),
      ],
    );
  }
}

// 
// Security Preview
// 

class _SecurityPreview extends StatelessWidget {
  final SecuritySettings security;
  const _SecurityPreview({required this.security});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Auth method summary
        _SecurityRow(
          label: 'Primary Auth',
          value: security.primaryAuth.label,
          icon: security.primaryAuth.icon,
          color: IveTokens.success,
        ),
        _SecurityRow(
          label: '2FA Status',
          value: security.twoFactorEnabled ? 'Enabled' : 'Disabled',
          icon: Icons.security,
          color: security.twoFactorEnabled ? IveTokens.success : IveTokens.warning,
        ),
        _SecurityRow(
          label: 'Active Sessions',
          value: '${security.activeSessions.length} devices',
          icon: Icons.devices,
          color: IveTokens.moduleMarket,
        ),
        _SecurityRow(
          label: 'Password Health',
          value: '${security.passwordHealthScore}%',
          icon: Icons.health_and_safety,
          color: security.passwordHealthScore >= 80 ? IveTokens.success : IveTokens.warning,
        ),

        const SizedBox(height: 12),

        // Full security button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.userDetailsSecurity),
            icon: const Icon(Icons.shield, size: 16),
            label: const Text('Full Security Settings'),
            style: OutlinedButton.styleFrom(
              foregroundColor: IveTokens.success,
              side: const BorderSide(color: IveTokens.success, width: 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ],
    );
  }
}

class _SecurityRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _SecurityRow({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

// 
// Preferences Hub
// 

class _PreferencesHub extends StatelessWidget {
  final NotificationSettings notifications;
  final PrivacySettings privacy;
  final AccessibilitySettings accessibility;
  const _PreferencesHub({required this.notifications, required this.privacy, required this.accessibility});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PrefTile(
          icon: Icons.notifications_outlined,
          label: 'Notifications',
          subtitle: notifications.activeMode.label,
          color: IveTokens.warning,
          onTap: () => Navigator.pushNamed(context, AppRoutes.userDetailsNotifications),
        ),
        _PrefTile(
          icon: Icons.privacy_tip_outlined,
          label: 'Privacy',
          subtitle: 'Score: ${privacy.privacyScore}%',
          color: IveTokens.moduleUpdates,
          onTap: () => Navigator.pushNamed(context, AppRoutes.userDetailsPrivacy),
        ),
        _PrefTile(
          icon: Icons.accessibility_new,
          label: 'Accessibility',
          subtitle: accessibility.activePresetName ?? 'Default',
          color: IveTokens.accent,
          onTap: () => Navigator.pushNamed(context, AppRoutes.userDetailsAccessibility),
        ),
      ],
    );
  }
}

class _PrefTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _PrefTile({required this.icon, required this.label, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

// 
// Context-Specific Settings
// 

class _ContextSpecificSettings extends StatelessWidget {
  final dynamic entityType;
  const _ContextSpecificSettings({required this.entityType});

  @override
  Widget build(BuildContext context) {
    final isBusiness = entityType.toString().contains('business');
    return Column(
      children: [
        if (isBusiness) ...[
          const DetailRow(icon: Icons.schedule, label: 'Business Hours', value: '9:00 AM - 5:00 PM'),
          const DetailRow(icon: Icons.badge, label: 'Registration', value: 'GH-BRN-123456'),
          const DetailRow(icon: Icons.factory, label: 'Industry', value: 'Retail & Commerce'),
          const DetailRow(icon: Icons.people_outline, label: 'Employees', value: '10-50'),
        ] else ...[
          const DetailRow(icon: Icons.access_time, label: 'Shift Pattern', value: 'Morning Shift'),
          const DetailRow(icon: Icons.map_outlined, label: 'Coverage Radius', value: '10 km'),
          const DetailRow(icon: Icons.account_tree_outlined, label: 'Parent Entity', value: 'Wizdom Shop'),
        ],
      ],
    );
  }
}

// 
// Sticky Footer
// 

class _StickyFooter extends StatelessWidget {
  final VoidCallback onHelp;
  final VoidCallback onDownload;
  final VoidCallback onFab;
  const _StickyFooter({required this.onHelp, required this.onDownload, required this.onFab});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 12,
        top: 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          _FooterButton(icon: Icons.help_outline, label: 'Help', onTap: onHelp),
          const SizedBox(width: 12),
          _FooterButton(icon: Icons.download, label: 'Data', onTap: onDownload),
          const Spacer(),
          FloatingActionButton(
            heroTag: 'user_details_fab',
            mini: true,
            backgroundColor: IveTokens.moduleSetup,
            onPressed: onFab,
            child: const Icon(Icons.add, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}

class _FooterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _FooterButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textTertiary),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _SignOutRow extends StatefulWidget {
  @override
  State<_SignOutRow> createState() => _SignOutRowState();
}

class _SignOutRowState extends State<_SignOutRow> {
  bool _loading = false;

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: IveTokens.surfaceRaised,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(IveTokens.rSm)),
        ),
        title: Text('Sign out', style: IveType.title3),
        content: Text(
          'You will need to sign in again to access your account.',
          style: IveType.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: IveType.callout),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Sign out',
                style: IveType.callout.copyWith(color: IveTokens.danger)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _loading = true);
    HapticFeedback.mediumImpact();

    await AuthService().logout();

    if (!mounted) return;
    context.read<ContextProvider>().clear();
    context.read<OnboardingProvider>().reset();
    context.read<PhoneAuthProvider>().reset();
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.welcome,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: IveTokens.surface,
      borderRadius: BorderRadius.circular(IveTokens.rSm),
      child: InkWell(
        onTap: _loading ? null : _signOut,
        borderRadius: BorderRadius.circular(IveTokens.rSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.logout, size: 18, color: IveTokens.danger),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sign out',
                  style: IveType.body.copyWith(color: IveTokens.danger),
                ),
              ),
              if (_loading)
                const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: IveTokens.danger,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
