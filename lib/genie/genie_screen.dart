/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
/// GenieScreen â€“ The Universal Modal Interface
///
/// Replaces the PromptScreen as the default home of the app.
/// Layout:
///   â€¢ Top: GlobalHeader (context bar, reused from prompt module)
///   â€¢ Top floating: Pinned tile strip (optional, draggable)
///   â€¢ Center: Scrollable chat thread (ListView.builder)
///   â€¢ Offline banner: subtle yellow bar when offline
///   â€¢ Bottom: Input area (chips + text field + mic button + '+' menu)
///   â€¢ Bottom: Pinned shortcut bar (max 4 role-specific quick actions)
/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/routes/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../features/prompt/models/rbac_models.dart';
import '../features/prompt/providers/context_provider.dart';
import '../features/prompt/widgets/global_header.dart';
import 'genie_controller.dart';
import 'genie_intent.dart';
import 'genie_rbac_enforcer.dart';
import 'genie_tactile_actions.dart';
import 'widgets/genie_chat_bubble.dart';
import 'widgets/genie_full_screen_launcher.dart';
import 'widgets/genie_quick_command_bar.dart';

class GenieScreen extends StatefulWidget {
  const GenieScreen({super.key});

  @override
  State<GenieScreen> createState() => _GenieScreenState();
}

class _GenieScreenState extends State<GenieScreen>
    with SingleTickerProviderStateMixin {
  late GenieController _controller;
  late TextEditingController _textCtrl;
  late ScrollController _scrollCtrl;
  late FocusNode _inputFocus;

  bool _inputExpanded = false;

  bool _controllerReady = false;

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController();
    _scrollCtrl = ScrollController();
    _inputFocus = FocusNode();
    _inputFocus.addListener(() {
      setState(() => _inputExpanded = _inputFocus.hasFocus);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = context.read<ContextProvider>();
      _controller = GenieController(contextProvider: ctx);
      _controller.addListener(_onControllerUpdate);
      setState(() => _controllerReady = true);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    setState(() {});
    // Auto-scroll to latest message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    _textCtrl.clear();
    _inputFocus.unfocus();
    _controller.handleInput(text);
  }

  void _handleChipTap(GenieIntent intent) {
    // Handle Genie-native intents that require navigation
    if (intent.module == GenieModule.genie &&
        intent.action == 'classic_dashboard') {
      Navigator.of(context).pushNamed(AppRoutes.classicDashboard);
      return;
    }
    // Modules requiring full-screen navigation
    if (intent.requiresFullScreen) {
      GenieFullScreenLauncher.launch(context, intent.module);
      return;
    }
    _controller.executeIntent(intent);
  }

  void _handleVoice() async {
    if (_controller.isListening) {
      await _controller.stopVoice();
    } else {
      await _controller.startVoice();
    }
  }

  void _handleFullScreen(GenieModule module) {
    GenieFullScreenLauncher.launch(context, module);
  }

  void _handleSOS() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.sos, color: Color(0xFFEF4444), size: 24),
            SizedBox(width: 8),
            Text('Emergency SOS'),
          ],
        ),
        content: const Text(
          'Emergency alert has been sent. '  
          'Help is on the way.\n\nStay calm and keep this screen open.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Guard: controller may not be ready on first frame
    if (!_controllerReady) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final contextProvider = context.watch<ContextProvider>();
    final role = contextProvider.currentRole;
    final pinnedShortcuts = GenieRBACEnforcer.getDefaultPinnedShortcuts(role);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            // â”€â”€â”€ Persistent Global Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            GlobalHeader(
              onContextSwitchTap: () => _controller.executeIntent(
                const GenieIntent(
                    module: GenieModule.userDetails,
                    action: 'switch_context'),
              ),
              onNotificationTap: () => _controller.executeIntent(
                const GenieIntent(
                    module: GenieModule.utility, action: 'notifications'),
              ),
              onSOSTap: _handleSOS,
            ),

            // â”€â”€â”€ Offline Banner â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            if (!_controller.isOnline) const _OfflineBanner(),

            // â”€â”€â”€ Pinned Floating Tiles â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            if (_controller.pinnedTiles.isNotEmpty)
              _PinnedTileStrip(
                tiles: _controller.pinnedTiles,
                onUnpin: (m) => _controller.unpinTile(m),
              ),

            // â”€â”€â”€ Chat Thread â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Expanded(
              child: _controller.messages.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
                      itemCount: _controller.messages.length,
                      itemBuilder: (context, index) {
                        final message = _controller.messages[index];
                        return GenieChatBubble(
                          message: message,
                          onDismiss: () {},
                          onPrimaryAction: () {},
                        );
                      },
                    ),
            ),

            // â”€â”€â”€ Typing indicator â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            if (_controller.isProcessing) const _TypingIndicator(),

            // â”€â”€â”€ Chip Row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            if (!_inputExpanded)
              Container(
                color: Colors.white,
                child: GenieQuickCommandBar(
                  role: role,
                  onChipTap: _handleChipTap,
                ),
              ),

            // â”€â”€â”€ Input Area â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _InputArea(
              controller: _textCtrl,
              focusNode: _inputFocus,
              isListening: _controller.isListening,
              isProcessing: _controller.isProcessing,
              onSend: _handleSend,
              onVoice: _handleVoice,
              onMenuTap: () =>
                  GenieFullScreenLauncher.showModuleMenu(context, role),
            ),

            // â”€â”€â”€ Pinned Shortcut Bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _PinnedShortcutBar(
              shortcuts: pinnedShortcuts,
              onShortcutTap: (intent) => _controller.executeIntent(intent),
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€â”€ Offline Banner â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.warning.withValues(alpha: 0.15),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        children: const [
          Icon(Icons.cloud_off_outlined, size: 14, color: AppColors.warning),
          SizedBox(width: 6),
          Text(
            'You\'re offline. Actions will sync when you reconnect.',
            style: TextStyle(fontSize: 11, color: AppColors.warning),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€ Pinned Tile Strip â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _PinnedTileStrip extends StatelessWidget {
  final Map<GenieModule, Map<String, dynamic>> tiles;
  final void Function(GenieModule) onUnpin;

  const _PinnedTileStrip({required this.tiles, required this.onUnpin});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: tiles.entries.map((e) {
          return GestureDetector(
            onLongPress: () => onUnpin(e.key),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: AppColors.primaryLight.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.push_pin_outlined,
                      size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    e.key.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// â”€â”€â”€ Typing Indicator â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 0, 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.accent, AppColors.primaryLight],
              ),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          FadeTransition(
            opacity: _anim,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Row(
                children: List.generate(
                  3,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.textTertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€ Input Area â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _InputArea extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isListening;
  final bool isProcessing;
  final VoidCallback onSend;
  final VoidCallback onVoice;
  final VoidCallback onMenuTap;

  const _InputArea({
    required this.controller,
    required this.focusNode,
    required this.isListening,
    required this.isProcessing,
    required this.onSend,
    required this.onVoice,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.inputBorder)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Row(
        children: [
          // '+' Module Menu Button
          Semantics(
            button: true,
            label: 'Open all modules',
            child: GestureDetector(
              onTap: onMenuTap,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: const Icon(Icons.add,
                    color: AppColors.textSecondary, size: 20),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Text Input
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: focusNode.hasFocus
                      ? AppColors.primaryLight
                      : AppColors.inputBorder,
                  width: focusNode.hasFocus ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      enabled: !isProcessing,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSend(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Ask Genie or tap a shortcutâ€¦',
                        hintStyle: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  // Send button shown only when text present
                  ValueListenableBuilder(
                    valueListenable: controller,
                    builder: (_, value, __) {
                      if ((value as TextEditingValue).text.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GestureDetector(
                          onTap: onSend,
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.send_rounded,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Mic Button
          Semantics(
            button: true,
            label: isListening ? 'Stop listening' : 'Start voice input',
            child: GestureDetector(
              onTap: onVoice,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isListening ? AppColors.error : AppColors.primary,
                  boxShadow: isListening
                      ? [
                          BoxShadow(
                            color: AppColors.error.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          )
                        ]
                      : null,
                ),
                child: Icon(
                  isListening ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€ Pinned Shortcut Bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _PinnedShortcutBar extends StatelessWidget {
  final List<GeniePinnedShortcut> shortcuts;
  final void Function(GenieIntent) onShortcutTap;

  const _PinnedShortcutBar({
    required this.shortcuts,
    required this.onShortcutTap,
  });

  @override
  Widget build(BuildContext context) {
    if (shortcuts.isEmpty) return const SizedBox.shrink();

    return Container(
      color: AppColors.backgroundDark,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: shortcuts.take(4).map((s) {
          return Expanded(
            child: Semantics(
              button: true,
              label: '${s.emoji} ${s.label}',
              child: GestureDetector(
                onTap: () {
                  GenieTactileActions.onTap();
                  onShortcutTap(s.intent);
                },
                child: Container(
                  constraints: const BoxConstraints(minHeight: 52),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(s.emoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 2),
                      Text(
                        s.label,
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.textSecondaryDark,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// â”€â”€â”€ Empty State â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'âœ¨ Say "Hey Genie" or type somethingâ€¦',
        style: TextStyle(
          color: AppColors.textTertiary,
          fontSize: 14,
        ),
      ),
    );
  }
}
