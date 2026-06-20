/// Privacy Control Center
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive.dart';
import '../models/user_details_models.dart';
import '../providers/user_details_provider.dart';
import '../widgets/shared_widgets.dart';

// Module accent: user = cyan
const Color _kModuleColor = IveTokens.moduleUser;

class PrivacyCenterScreen extends StatelessWidget {
  const PrivacyCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDetailsProvider>(
      builder: (context, udp, _) {
        final privacy = udp.privacy;
        final categories = udp.dataCategories;

        return Scaffold(
          backgroundColor: IveTokens.voidColor,
          appBar: const ModuleHeader(
            title: 'Privacy Center',
            contextColor: _kModuleColor,
          ),
          body: ListView(
            padding: const EdgeInsets.all(IveTokens.s5),
            children: [
              // ── Privacy Score (arc animates real-time) ───────────────
              _PrivacyScoreCard(score: privacy.privacyScore),

              const SizedBox(height: IveTokens.s4),

              // ── Data Map ────────────────────────────────────────────
              _DarkCard(
                child: CollapsibleSection(
                  title: 'Your Data Map',
                  icon: Icons.bubble_chart,
                  iconColor: _kModuleColor,
                  child: _DataMap(categories: categories),
                ),
              ),

              const SizedBox(height: IveTokens.s3),

              // ── Profile Visibility ──────────────────────────────────
              _DarkCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel('Profile Visibility'),
                    const SizedBox(height: IveTokens.s2 + 2),
                    ...ProfileVisibility.values.map((v) => _RadioOption<ProfileVisibility>(
                          value: v,
                          groupValue: privacy.profileVisibility,
                          label: v.label,
                          icon: v == ProfileVisibility.everyone
                              ? Icons.public
                              : v == ProfileVisibility.contactsOnly
                                  ? Icons.people
                                  : Icons.lock,
                          onChanged: (val) {
                            if (val != null) {
                              HapticFeedback.lightImpact();
                              udp.setProfileVisibility(val);
                            }
                          },
                        )),
                  ],
                ),
              ),

              const SizedBox(height: IveTokens.s3),

              // ── Data Sharing ────────────────────────────────────────
              _DarkCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel('Data Sharing Level'),
                    const SizedBox(height: IveTokens.s2 + 2),
                    ...DataSharingLevel.values.map((v) => _RadioOption<DataSharingLevel>(
                          value: v,
                          groupValue: privacy.dataSharingLevel,
                          label: v.label,
                          icon: Icons.share,
                          onChanged: (val) {
                            if (val != null) {
                              HapticFeedback.lightImpact();
                              udp.setDataSharing(val);
                            }
                          },
                        )),
                  ],
                ),
              ),

              const SizedBox(height: IveTokens.s3),

              // ── Location Tracking ───────────────────────────────────
              _DarkCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel('Location Tracking'),
                    const SizedBox(height: IveTokens.s2 + 2),
                    ...LocationTracking.values.map((v) => _RadioOption<LocationTracking>(
                          value: v,
                          groupValue: privacy.locationTracking,
                          label: v.label,
                          icon: v == LocationTracking.always
                              ? Icons.location_on
                              : v == LocationTracking.whileUsingApp
                                  ? Icons.location_searching
                                  : Icons.location_off,
                          onChanged: (val) {
                            if (val != null) {
                              HapticFeedback.lightImpact();
                              udp.setLocationTracking(val);
                            }
                          },
                        )),
                  ],
                ),
              ),

              const SizedBox(height: IveTokens.s3),

              // ── Toggles ─────────────────────────────────────────────
              _DarkCard(
                child: Column(
                  children: [
                    SettingsToggle(
                      icon: Icons.contacts,
                      label: 'Contact Sync',
                      subtitle: 'Sync phone contacts with app',
                      value: privacy.contactSyncEnabled,
                      onChanged: (v) {
                        HapticFeedback.lightImpact();
                        udp.toggleContactSync(v);
                      },
                      activeColor: _kModuleColor,
                    ),
                    const Divider(height: 1, color: IveTokens.hairColor),
                    SettingsToggle(
                      icon: Icons.analytics_outlined,
                      label: 'Usage Analytics',
                      subtitle: 'Help improve the app with anonymized data',
                      value: privacy.usageAnalyticsEnabled,
                      onChanged: (v) {
                        HapticFeedback.lightImpact();
                        udp.toggleAnalytics(v);
                      },
                      activeColor: _kModuleColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: IveTokens.s3),

              // ── Data Export ─────────────────────────────────────────
              _DarkCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.download_outlined, size: 18, color: IveTokens.accentColor),
                      SizedBox(width: IveTokens.s2),
                      _SectionLabel('Data Export'),
                    ]),
                    if (privacy.lastDataExport != null) ...[
                      const SizedBox(height: IveTokens.s1),
                      Text(
                        'Last export: ${_formatDate(privacy.lastDataExport!)}',
                        style: const TextStyle(fontSize: 12, color: IveTokens.muteColor),
                      ),
                    ],
                    const SizedBox(height: IveTokens.s2 + 2),
                    IveButton.secondary(
                      label: 'Request Data Export (GDPR)',
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        udp.requestDataExport();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Data export initiated. You\'ll receive it via email.')),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: IveTokens.s3),

              // ── Account Deletion ────────────────────────────────────
              _DarkCard(
                borderColor: IveTokens.badColor.withValues(alpha: 0.2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.delete_forever, size: 18, color: IveTokens.badColor),
                      SizedBox(width: IveTokens.s2),
                      Text('Delete Account',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: IveTokens.badColor)),
                    ]),
                    const SizedBox(height: IveTokens.s1 + 2),
                    const Text(
                      'Permanently delete your account and all associated data. This cannot be undone.',
                      style: TextStyle(fontSize: 12, color: IveTokens.muteColor, height: 1.4),
                    ),
                    const SizedBox(height: IveTokens.s2 + 2),
                    IveButton.primary(
                      label: 'Delete My Account',
                      isDestructive: true,
                      onPressed: () => _showDeleteConfirmation(context, udp),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: IveTokens.s8),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

  Future<void> _showDeleteConfirmation(BuildContext context, UserDetailsProvider udp) async {
    HapticFeedback.heavyImpact();
    await showVerifySheet(
      context,
      title: 'Delete Account',
      confirmLabel: 'Delete account',
      subtitle: 'All your data will be permanently erased across every context. This cannot be undone.',
      isDestructive: true,
      onConfirm: () async => null,
    );
  }
}

// ── Dark card container ──────────────────────────────────────────────────────

class _DarkCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  const _DarkCard({required this.child, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(IveTokens.s4),
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: IveTokens.raisedColor,
        borderRadius: BorderRadius.circular(IveTokens.rContainer),
        border: Border.all(color: borderColor ?? IveTokens.hairColor, width: 1),
      ),
      child: child,
    );
  }
}

// ── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: IveTokens.inkColor));
  }
}

// ── Privacy Score Card — animates arc in real-time ──────────────────────────

class _PrivacyScoreCard extends StatefulWidget {
  final int score;
  const _PrivacyScoreCard({required this.score});

  @override
  State<_PrivacyScoreCard> createState() => _PrivacyScoreCardState();
}

class _PrivacyScoreCardState extends State<_PrivacyScoreCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  double _fromScore = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = Tween<double>(begin: 0, end: widget.score.toDouble())
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_PrivacyScoreCard old) {
    super.didUpdateWidget(old);
    if (old.score != widget.score) {
      _fromScore = _anim.value;
      _anim = Tween<double>(begin: _fromScore, end: widget.score.toDouble())
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _arcColor(double v) {
    if (v >= 80) return IveTokens.okColor;
    if (v >= 50) return IveTokens.warnColor;
    return IveTokens.badColor;
  }

  @override
  Widget build(BuildContext context) {
    return _DarkCard(
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          final v = _anim.value;
          final color = _arcColor(v);
          return Row(
            children: [
              SizedBox(
                width: 68,
                height: 68,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: v / 100,
                      strokeWidth: 5,
                      backgroundColor: IveTokens.hairColor,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                    Text(
                      v.round().toString(),
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: color,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: IveTokens.s4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Privacy Score',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: IveTokens.inkColor)),
                    const SizedBox(height: 2),
                    Text(
                      v >= 80 ? 'Your privacy is well protected' : 'Consider improving your privacy settings',
                      style: const TextStyle(fontSize: 12, color: IveTokens.muteColor),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Data Map Visualization ───────────────────────────────────────────────────

class _DataMap extends StatelessWidget {
  final List<DataCategory> categories;
  const _DataMap({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: IveTokens.s2),
        Wrap(
          spacing: IveTokens.s2,
          runSpacing: IveTokens.s2,
          alignment: WrapAlignment.center,
          children: categories.map((cat) => _DataBubble(category: cat)).toList(),
        ),
        const SizedBox(height: IveTokens.s4),
        ...categories.map((cat) => _DataCategoryRow(category: cat)),
      ],
    );
  }
}

class _DataBubble extends StatelessWidget {
  final DataCategory category;
  const _DataBubble({required this.category});

  @override
  Widget build(BuildContext context) {
    final size = 40 + (category.relativeSize * 14);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _showDataDetail(context, category);
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: category.color.withValues(alpha: 0.15),
          border: Border.all(color: category.color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Center(
          child: Text(
            category.name.split(' ').map((w) => w[0]).join(),
            style: TextStyle(
              fontSize: size > 70 ? 14 : 10,
              fontWeight: FontWeight.w700,
              color: category.color,
            ),
          ),
        ),
      ),
    );
  }

  void _showDataDetail(BuildContext context, DataCategory cat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(
            IveTokens.s5, IveTokens.s4, IveTokens.s5,
            IveTokens.s5 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(
          color: IveTokens.raisedColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(IveTokens.rContainer)),
          border: Border(top: BorderSide(color: IveTokens.hairColor, width: 1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(color: IveTokens.hair2Color, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: IveTokens.s4),
            Text(cat.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cat.color)),
            const SizedBox(height: IveTokens.s2),
            DetailRow(icon: Icons.info_outline, label: 'Description', value: cat.description),
            DetailRow(icon: Icons.flag, label: 'Purpose', value: cat.purpose),
            DetailRow(icon: Icons.visibility, label: 'Who can see', value: cat.visibility),
            DetailRow(icon: Icons.timer, label: 'Retention', value: cat.retention),
            const SizedBox(height: IveTokens.s5),
          ],
        ),
      ),
    );
  }
}

class _DataCategoryRow extends StatelessWidget {
  final DataCategory category;
  const _DataCategoryRow({required this.category});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: IveTokens.s2),
      child: Row(
        children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: category.color),
          ),
          const SizedBox(width: IveTokens.s2),
          Expanded(
            child: Text(category.name,
                style: const TextStyle(fontSize: 12, color: IveTokens.ink2Color)),
          ),
          Text(category.retention,
              style: const TextStyle(fontSize: 11, color: IveTokens.muteColor)),
        ],
      ),
    );
  }
}

// ── Radio Option ─────────────────────────────────────────────────────────────

class _RadioOption<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final String label;
  final IconData icon;
  final ValueChanged<T?> onChanged;

  const _RadioOption({
    required this.value,
    required this.groupValue,
    required this.label,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(IveTokens.rXs),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: IveTokens.s2),
        child: Row(
          children: [
            Icon(icon, size: 18, color: selected ? _kModuleColor : IveTokens.muteColor),
            const SizedBox(width: IveTokens.s2 + 2),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? _kModuleColor : IveTokens.inkColor,
                ),
              ),
            ),
            Radio<T>(
              value: value,
              // ignore: deprecated_member_use
              groupValue: groupValue,
              // ignore: deprecated_member_use
              onChanged: onChanged,
              activeColor: _kModuleColor,
            ),
          ],
        ),
      ),
    );
  }
}
