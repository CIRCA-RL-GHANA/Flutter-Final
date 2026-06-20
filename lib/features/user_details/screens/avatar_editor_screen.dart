/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
/// Screen 4: Avatar & Branding Editor
/// Photo, Branding colors/logo, Consistency across contexts
/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../prompt/providers/context_provider.dart';
import '../providers/user_details_provider.dart';
import '../widgets/shared_widgets.dart';

class AvatarEditorScreen extends StatefulWidget {
  const AvatarEditorScreen({super.key});

  @override
  State<AvatarEditorScreen> createState() => _AvatarEditorScreenState();
}

class _AvatarEditorScreenState extends State<AvatarEditorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserDetailsProvider, ContextProvider>(
      builder: (context, udp, ctxProvider, _) {
        final identity = udp.identity;

        return Scaffold(
          backgroundColor: const Color(0xFF08080F),
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
              'Avatar & Branding',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF6366F1),
              unselectedLabelColor: AppColors.textTertiary,
              indicatorColor: const Color(0xFF6366F1),
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Photo'),
                Tab(text: 'Branding'),
                Tab(text: 'Consistency'),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _PhotoTab(identity: identity),
                    _BrandingTab(),
                    _ConsistencyTab(contexts: ctxProvider.availableContexts),
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

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// Tab 1: Photo
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class _PhotoTab extends StatefulWidget {
  final dynamic identity;
  const _PhotoTab({required this.identity});

  @override
  State<_PhotoTab> createState() => _PhotoTabState();
}

class _PhotoTabState extends State<_PhotoTab> {
  String? _selectedImagePath;

  Future<void> _pickImage(ImageSource source) async {
    HapticFeedback.selectionClick();
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source);
    if (file != null && mounted) {
      setState(() => _selectedImagePath = file.path);
      // Update the provider with the selected image path
      if (mounted) {
        context.read<UserDetailsProvider>().updateField();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final identity = widget.identity;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Current Avatar Preview
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                  border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.2), width: 3),
                ),
                child: CircleAvatar(
                  radius: 72,
                  backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  child: _selectedImagePath != null
                      ? null
                      : Text(
                          identity.displayName.isNotEmpty ? identity.displayName[0].toUpperCase() : 'U',
                          style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                        ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF6366F1),
                  ),
                  child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Action buttons
        _PhotoAction(
          icon: Icons.photo_camera,
          label: 'Take Photo',
          subtitle: 'Use camera to capture a new photo',
          color: const Color(0xFF6366F1),
          onTap: () => _pickImage(ImageSource.camera),
        ),
        _PhotoAction(
          icon: Icons.photo_library,
          label: 'Choose from Gallery',
          subtitle: 'Select from your device photos',
          color: const Color(0xFF8B5CF6),
          onTap: () => _pickImage(ImageSource.gallery),
        ),
        _PhotoAction(
          icon: Icons.emoji_emotions_outlined,
          label: 'Create Avatar',
          subtitle: 'Design a custom avatar illustration',
          color: const Color(0xFFF59E0B),
          onTap: () {
            HapticFeedback.selectionClick();
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Create Avatar'),
                content: const Text('Avatar creator coming soon'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
        ),
        _PhotoAction(
          icon: Icons.delete_outline,
          label: 'Remove Photo',
          subtitle: 'Revert to initials avatar',
          color: AppColors.error,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedImagePath = null);
          },
        ),

        const SizedBox(height: 20),

        // Guidelines
        const SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Photo Guidelines', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              SizedBox(height: 8),
              _Guideline('Clear face shot, centered'),
              _Guideline('Minimum 200x200 pixels'),
              _Guideline('Max file size: 5MB'),
              _Guideline('Supported: JPG, PNG, WEBP'),
            ],
          ),
        ),
      ],
    );
  }
}

class _PhotoAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _PhotoAction({required this.icon, required this.label, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SectionCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: color),
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
        ),
      ),
    );
  }
}

class _Guideline extends StatelessWidget {
  final String text;
  const _Guideline(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF10B981)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// Tab 2: Branding
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class _BrandingTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final brandColors = [
      AppColors.roleIndividual,
      AppColors.roleBusiness,
      AppColors.success,
      AppColors.roleTransport,
      AppColors.secondary,
      AppColors.accent,
      AppColors.error,
      AppColors.info,
      AppColors.roleShop,
      AppColors.roleDelivery,
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Brand Colors',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Choose colors that represent this context. These appear on your profile card and shared materials.',
          style: TextStyle(fontSize: 12, color: AppColors.textTertiary, height: 1.4),
        ),
        const SizedBox(height: 16),

        // Color Palette
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Primary Color', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: brandColors.map((c) => _ColorDot(color: c, selected: c == brandColors[0])).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Accent Color', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: brandColors.map((c) => _ColorDot(color: c, selected: c == brandColors[4])).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Logo / Header
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Context Logo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.15), style: BorderStyle.solid),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 28, color: Color(0xFF6366F1)),
                    SizedBox(height: 6),
                    Text('Upload Logo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6366F1))),
                    Text('PNG or SVG, max 2MB', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Preview
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Preview', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [brandColors[0], brandColors[0].withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Builder(
                builder: (context) {
                  final udp = Provider.of<UserDetailsProvider>(context, listen: false);
                  final shopName = udp.entityName.isNotEmpty ? udp.entityName : 'My Shop';
                  final initial = shopName.isNotEmpty ? shopName[0].toUpperCase() : 'S';
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white24,
                        child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(shopName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          const Text('Business Entity', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ],
                  );
                },
              ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool selected;
  const _ColorDot({required this.color, required this.selected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: selected ? Border.all(color: Colors.white, width: 3) : null,
        ),
        child: selected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// Tab 3: Consistency (cross-context avatar sync)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class _ConsistencyTab extends StatefulWidget {
  final List<dynamic> contexts;
  const _ConsistencyTab({required this.contexts});

  @override
  State<_ConsistencyTab> createState() => _ConsistencyTabState();
}

class _ConsistencyTabState extends State<_ConsistencyTab> {
  bool _syncAcrossContexts = true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Cross-Context Consistency',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Decide whether to use the same avatar and branding across all your contexts, or customize each one.',
          style: TextStyle(fontSize: 12, color: AppColors.textTertiary, height: 1.4),
        ),
        const SizedBox(height: 20),

        // Sync option
        SectionCard(
          child: SettingsToggle(
            icon: Icons.sync,
            label: 'Sync Avatar Across Contexts',
            subtitle: 'Use the same photo everywhere',
            value: _syncAcrossContexts,
            onChanged: (v) => setState(() => _syncAcrossContexts = v),
            activeColor: const Color(0xFF6366F1),
          ),
        ),

        const SizedBox(height: 8),
        const Text(
          'Per-Context Preview',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 10),

        // Context avatar list
        ...widget.contexts.map((ctx) {
          final color = contextTypeColor(ctx.entityType);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SectionCard(
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: color.withValues(alpha: 0.2)),
                    ),
                    child: Center(
                      child: Text(
                        ctx.name.isNotEmpty ? ctx.name[0].toUpperCase() : '?',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ctx.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        Text(
                          ctx.entityType.toString().split('.').last,
                          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Synced',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
