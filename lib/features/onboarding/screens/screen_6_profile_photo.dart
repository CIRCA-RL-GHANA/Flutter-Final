import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/responsive.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_header.dart';
import '../widgets/onboarding_loading_overlay.dart';

/// Screen 07 — Profile photo, step 04/08.
class ProfilePhotoScreen extends StatefulWidget {
  const ProfilePhotoScreen({super.key});

  @override
  State<ProfilePhotoScreen> createState() => _ProfilePhotoScreenState();
}

class _ProfilePhotoScreenState extends State<ProfilePhotoScreen> {
  final _picker = ImagePicker();
  File? _photo;
  bool _uploading = false;

  Future<void> _pick(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (picked == null || !mounted) return;
      setState(() => _photo = File(picked.path));
    } on PlatformException {
      // Permission denied — ignore silently
    }
  }

  Future<void> _proceed() async {
    setState(() => _uploading = true);
    context.read<OnboardingProvider>().setProfileData(photoPath: _photo?.path);
    if (!mounted) return;
    setState(() => _uploading = false);
    Navigator.of(context).pushNamed(AppRoutes.biometric);
  }

  @override
  Widget build(BuildContext context) {
    final ob = context.watch<OnboardingProvider>();
    final initials = _initials(ob.firstName, ob.lastName);

    return OnboardingLoadingOverlay(
      isLoading: _uploading,
      child: Scaffold(
        backgroundColor: IveTokens.bg,
        body: SafeArea(
          child: Responsive.constrained(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OnboardingHeader(
                  title: 'Add a profile photo',
                  subtitle: 'Optional — helps people recognise you.',
                  currentStep: 4,
                  totalSteps: 8,
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar — centered
                        Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: IveTokens.surface,
                              border: Border.all(color: IveTokens.hairline2),
                              image: _photo != null
                                  ? DecorationImage(
                                      image: FileImage(_photo!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _photo == null
                                ? Center(
                                    child: Text(
                                      initials,
                                      style: const TextStyle(
                                        fontFamily: 'SpaceGrotesk',
                                        fontSize: 32,
                                        fontWeight: FontWeight.w600,
                                        color: IveTokens.ink2,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Take a photo row
                        _ActionRow(
                          icon: Icons.camera_alt_outlined,
                          title: 'Take a photo',
                          subtitle: 'Use your camera',
                          onTap: () => _pick(ImageSource.camera),
                        ),

                        const SizedBox(height: 12),

                        // Choose from gallery row
                        _ActionRow(
                          icon: Icons.photo_library_outlined,
                          title: 'Choose from gallery',
                          subtitle: 'Pick an existing image',
                          onTap: () => _pick(ImageSource.gallery),
                        ),
                      ],
                    ),
                  ),
                ),

                // SKIP FOR NOW ghost button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: IveButton.secondary(
                    label: 'SKIP FOR NOW',
                    onPressed: _proceed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _initials(String first, String last) {
  final f = first.isNotEmpty ? first[0].toUpperCase() : '';
  final l = last.isNotEmpty ? last[0].toUpperCase() : '';
  return '$f$l'.isNotEmpty ? '$f$l' : 'KM';
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: IveTokens.surface,
          borderRadius: BorderRadius.circular(IveTokens.rSm),
          border: Border.all(color: IveTokens.hairline),
        ),
        child: Row(
          children: [
            // Icon tile
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: IveTokens.bg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: IveTokens.hairline),
              ),
              child: Icon(icon, size: 18, color: IveTokens.ink2),
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

            // Chevron
            const Text(
              '>',
              style: TextStyle(
                fontSize: 14,
                color: IveTokens.mute,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
