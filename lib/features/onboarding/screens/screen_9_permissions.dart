import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/responsive.dart';
import '../providers/permission_provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_header.dart';

/// Screen 10 — Permissions, step 07/08.
class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _camera        = true;
  bool _location      = true;
  bool _notifications = true;
  bool _contacts      = false;

  Future<void> _onAllow() async {
    final perms = context.read<PermissionProvider>();

    if (_camera)        await perms.requestPermission(AppPermission.camera);
    if (_location)      await perms.requestPermission(AppPermission.locationPrecise);
    if (_notifications) await perms.requestPermission(AppPermission.notifications);
    if (_contacts)      await perms.requestPermission(AppPermission.contacts);

    if (!mounted) return;
    context.read<OnboardingProvider>().completePermissions();
    Navigator.of(context).pushReplacementNamed(AppRoutes.success);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IveTokens.bg,
      body: SafeArea(
        child: Responsive.constrained(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OnboardingHeader(
                title: 'Permissions',
                subtitle: 'Grant access so the OS can serve you fully.',
                currentStep: 7,
                totalSteps: 8,
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _PermRow(
                        icon: Icons.camera_alt_outlined,
                        title: 'Camera',
                        subtitle: 'Scan codes, capture proof',
                        value: _camera,
                        onChanged: (v) => setState(() => _camera = v),
                      ),
                      _Divider(),
                      _PermRow(
                        icon: Icons.place_outlined,
                        title: 'Location',
                        subtitle: 'Delivery & ride tracking',
                        value: _location,
                        onChanged: (v) => setState(() => _location = v),
                      ),
                      _Divider(),
                      _PermRow(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        subtitle: 'Alerts & order updates',
                        value: _notifications,
                        onChanged: (v) => setState(() => _notifications = v),
                      ),
                      _Divider(),
                      _PermRow(
                        icon: Icons.import_contacts_outlined,
                        title: 'Contacts',
                        subtitle: 'Find people to pay',
                        value: _contacts,
                        onChanged: (v) => setState(() => _contacts = v),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: IveButton.primary(
                  label: 'ALLOW & CONTINUE',
                  onPressed: _onAllow,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: IveTokens.hairline);
}

class _PermRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PermRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Icon tile
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: IveTokens.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: IveTokens.hairline),
            ),
            child: Icon(
              icon,
              size: 20,
              color: value ? IveTokens.accent : IveTokens.mute,
            ),
          ),

          const SizedBox(width: 14),

          // Labels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: IveTokens.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: IveTokens.mute,
                  ),
                ),
              ],
            ),
          ),

          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: IveTokens.accent,
            activeTrackColor: IveTokens.accent.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
