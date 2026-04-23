/// ═══════════════════════════════════════════════════════════════════════════
/// SD3.1: PROFILE — User/Entity Profile
/// Profile info, completeness, skills, social links, rating
/// RBAC: All roles (personal/entity/branch scope varies)
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../prompt/providers/context_provider.dart';
// ignore: unused_import
import '../models/setup_dashboard_models.dart';
import '../models/setup_rbac.dart';
import '../providers/setup_dashboard_provider.dart';
import '../widgets/shared_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        final profile = setupProv.userProfile;

        return SetupRbacGate(
          cardId: 'profile',
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FC),
            appBar: SetupAppBar(
              title: 'Profile',
              actions: [
                DataScopeIndicator(access: setupProv.getCardAccess('profile', ctxProv.currentRole)),
                SizedBox(width: 16),
              ],
            ),
            floatingActionButton: SetupRbacFAB(
              cardId: 'profile',
              onPressed: () {},
              label: 'Edit',
              icon: Icons.edit,
            ),
          body: CustomScrollView(
            slivers: [
              // ─── Profile Header ───────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: SetupSectionCard(
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: kSetupColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              profile.displayName.isNotEmpty ? profile.displayName[0] : '?',
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: kSetupColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          profile.displayName,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        if (profile.isVerified) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.verified, size: 16, color: kSetupColor),
                              const SizedBox(width: 4),
                              const Text(
                                'Verified Account',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kSetupColor),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          '${profile.title} · ${profile.company}',
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        // Rating + Reviews
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star, size: 18, color: AppColors.accent),
                            const SizedBox(width: 4),
                            Text(
                              '${profile.rating}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${profile.reviewCount} reviews)',
                              style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Completeness
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SetupPercentageRing(
                              percentage: profile.profileCompleteness / 100,
                              color: kSetupColor,
                              size: 48,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Profile ${profile.profileCompleteness.toStringAsFixed(0)}% complete',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── Contact Info ─────────────────────────────
              // ─── AI Insights ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Consumer<AIInsightsNotifier>(
                  builder: (context, ai, _) {
                    if (ai.insights.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: kSetupColor.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome, size: 14, color: kSetupColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'AI: ${ai.insights.first['title'] ?? ''}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kSetupColor),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SetupSectionTitle(title: 'Contact', icon: Icons.contact_mail),
                      SetupSectionCard(
                        child: Column(
                          children: [
                            SetupActionTile(
                              label: profile.email ?? 'Add email',
                              icon: Icons.email,
                              showChevron: false,
                            ),
                            SetupActionTile(
                              label: profile.phone ?? 'Add phone',
                              icon: Icons.phone,
                              showChevron: false,
                            ),
                            SetupActionTile(
                              label: '${profile.city}, ${profile.country}',
                              icon: Icons.location_on,
                              showChevron: false,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Bio ──────────────────────────────────────
              if (profile.bio != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SetupSectionTitle(title: 'About', icon: Icons.info),
                        SetupSectionCard(
                          child: Text(
                            profile.bio!,
                            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ─── Skills ───────────────────────────────────
              if (profile.skills.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SetupSectionTitle(title: 'Skills', icon: Icons.psychology),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: profile.skills.map((skill) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: kSetupColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                skill,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: kSetupColor),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

              // ─── Social Links ──────────────────────────
              if (profile.socialLinks.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SetupSectionTitle(title: 'Social Links', icon: Icons.link),
                        SetupSectionCard(
                          child: Column(
                            children: profile.socialLinks.entries.map((entry) {
                              return SetupActionTile(
                                label: entry.value,
                                icon: _socialIcon(entry.key),
                                showChevron: true,
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ─── Activity Summary ─────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SetupSectionTitle(title: 'Activity Summary', icon: Icons.insights),
                      Container(
                        padding: const EdgeInsets.all(14),
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
                        child: Row(
                          children: [
                            Expanded(
                              child: _ProfileStat(
                                label: 'Member Since',
                                value: '${profile.memberSince.year}',
                                icon: Icons.calendar_today,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _ProfileStat(
                                label: 'Connections',
                                value: '${profile.connectionCount}',
                                icon: Icons.people,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _ProfileStat(
                                label: 'Reviews',
                                value: '${profile.reviewCount}',
                                icon: Icons.rate_review,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── SOS Button (Owner / Admin / BranchManager only) ─────
              SliverToBoxAdapter(
                child: SetupSOSButton(
                  onPressed: () {},
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
        );
      },
    );
  }

  IconData _socialIcon(String key) {
    switch (key.toLowerCase()) {
      case 'facebook':
        return Icons.facebook;
      case 'instagram':
        return Icons.camera_alt;
      case 'twitter':
      case 'x':
        return Icons.tag;
      case 'linkedin':
        return Icons.work;
      case 'website':
        return Icons.language;
      default:
        return Icons.link;
    }
  }
}

// ─── Profile Stat ────────────────────────────────────────────────────────────

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ProfileStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: kSetupColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: kSetupColor),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kSetupColor)),
          Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}
