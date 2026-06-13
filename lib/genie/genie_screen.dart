/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
/// GenieScreen – The Universal Modal Interface
///
/// Replaces the PromptScreen as the default home of the app.
/// Layout:
///   • Top: GlobalHeader (context bar, reused from prompt module)
///   • Top floating: Pinned tile strip (optional, draggable)
///   • Center: Scrollable chat thread (ListView.builder)
///   • Offline banner: subtle yellow bar when offline
///   • Bottom: Input area (chips + text field + mic button + '+' menu)
///   • Bottom: Pinned shortcut bar (max 4 role-specific quick actions)
/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/design/ive_text.dart';
import '../core/design/ive_tokens.dart';
import '../core/routes/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../features/prompt/providers/context_provider.dart';
import '../features/prompt/widgets/global_header.dart';
import 'genie_controller.dart';
import 'genie_intent.dart';
import 'genie_rbac_enforcer.dart';
import 'genie_tactile_actions.dart';
import 'genie_voice.dart';
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
  static const String _sosMessage =
      'Emergency alert has been sent. '
      'Help is on the way.\n\nStay calm and keep this screen open.';
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
          duration: IveTokens.dFast,
          curve: IveTokens.standard,
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
    // RBAC pre-check: every navigation path (classic-dashboard, full-screen
    // launch, or controller-routed intent) must honor the role's access
    // matrix. executeIntent() also re-validates, giving us defense-in-depth.
    final role = context.read<ContextProvider>().currentRole;
    if (!GenieRBACEnforcer.canPerformAction(
        role, intent.module, intent.action)) {
      // Defer to controller — it posts a polite, role-aware denial bubble
      // (full denial path lives in GenieController.executeIntent).
      _controller.executeIntent(intent);
      return;
    }

    // Handle Genie-native intents that require navigation
    if (intent.module == GenieModule.genie &&
        intent.action == 'classic_dashboard') {
      Navigator.of(context).pushNamed(AppRoutes.classicDashboard);
      return;
    }
    // Modules requiring full-screen navigation
    if (intent.requiresFullScreen) {
      GenieFullScreenLauncher.launchForRole(context, intent.module, role);
      return;
    }
    _controller.executeIntent(intent);
  }

  void _handleVoice() async {
    if (_controller.isListening) {
      await _controller.stopVoice();
      return;
    }
    await _controller.startVoice();
    // If the platform reports unavailable (no Web Speech API, mic permission
    // denied, or native STT not wired) tell the user instead of silently
    // sitting on the mic icon.
    if (!mounted) return;
    if (_controller.voiceStatus == GenieVoiceStatus.unavailable) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          content: Text(
            'Voice input is unavailable on this device. '
            'Check microphone permission or use the text field.',
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  // ignore: unused_element
  void _handleFullScreen(GenieModule module) {
    final role = context.read<ContextProvider>().currentRole;
    GenieFullScreenLauncher.launchForRole(context, module, role);
  }

  void _handleSOS() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: IveTokens.brLg),
        title: const Row(
          children: [
            Icon(Icons.sos, color: IveTokens.danger, size: 24),
            SizedBox(width: 8),
            Text('Emergency SOS'),
          ],
        ),
        content: const Text(
          _sosMessage,
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
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            // ─── Persistent Global Header ────────────────────────────────
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

            // ─── Offline Banner ──────────────────────────────────────────
            if (!_controller.isOnline) const _OfflineBanner(),

            // ─── Pinned Floating Tiles ───────────────────────────────────
            if (_controller.pinnedTiles.isNotEmpty)
              _PinnedTileStrip(
                tiles: _controller.pinnedTiles,
                onUnpin: (m) => _controller.unpinTile(m),
              ),

            // ─── Chat Thread ─────────────────────────────────────────────
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
                          // Swipe-left to dismiss: removes the bubble from the thread.
                          onDismiss: () => _controller.removeMessage(message.id),
                          // Swipe-right primary action: re-execute the card's module
                          // intent so the user gets a fresh response or navigates.
                          onPrimaryAction: () {
                            final module = message.cardData['module'] as String?;
                            final action = message.cardData['action'] as String?;
                            if (module != null && action != null) {
                              try {
                                final mod = GenieModule.values
                                    .firstWhere((m) => m.name == module);
                                _controller.executeIntent(
                                  GenieIntent(module: mod, action: action),
                                );
                              } catch (_) {
                                // Unknown module string — silently ignore.
                              }
                            }
                          },
                        );
                      },
                    ),
            ),

            // ─── Typing indicator ─────────────────────────────────────────
            if (_controller.isProcessing) const _TypingIndicator(),

            // ─── Chip Row ────────────────────────────────────────────────
            if (!_inputExpanded)
              Container(
                color: IveTokens.bg,
                child: GenieQuickCommandBar(
                  role: role,
                  onChipTap: _handleChipTap,
                ),
              ),

            // ─── Input Area ───────────────────────────────────────────────
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

            // ─── Pinned Shortcut Bar ─────────────────────────────────────
            _PinnedShortcutBar(
              shortcuts: pinnedShortcuts,
              onShortcutTap: _handleChipTap,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Offline Banner ───────────────────────────────────────────────────────────
class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: IveTokens.warning.withValues(alpha: 0.12),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: IveTokens.s4),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_outlined,
              size: 14, color: IveTokens.warning),
          const SizedBox(width: IveTokens.s2),
          Expanded(
            child: Text(
              'You\'re offline. Actions will sync when you reconnect.',
              style: IveType.caption.copyWith(color: IveTokens.warning),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pinned Tile Strip ────────────────────────────────────────────────────────
class _PinnedTileStrip extends StatelessWidget {
  final Map<GenieModule, Map<String, dynamic>> tiles;
  final void Function(GenieModule) onUnpin;

  const _PinnedTileStrip({required this.tiles, required this.onUnpin});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: IveTokens.bg,
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
                color: IveTokens.accent.withValues(alpha: 0.08),
                borderRadius: IveTokens.brSm,
                border: Border.all(
                    color: IveTokens.accent.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.push_pin_outlined,
                      size: 12, color: IveTokens.labelSecondary),
                  const SizedBox(width: IveTokens.s1),
                  Text(
                    e.key.name.toUpperCase(),
                    style: IveType.caption.copyWith(
                      color: IveTokens.accent,
                      fontWeight: FontWeight.w600,
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

// ─── Typing Indicator ─────────────────────────────────────────────────────────
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  // Three independent controllers offset in phase to create a wave.
  late final List<AnimationController> _dots;
  static const _dotCount = 3;
  static const _phaseOffset = 160; // ms between each dot's peak

  @override
  void initState() {
    super.initState();
    _dots = List.generate(_dotCount, (i) {
      final c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 480),
      );
      // Stagger starts so each dot is already mid-cycle when the first frame
      // renders — this prevents them all bouncing in lock-step.
      Future.delayed(Duration(milliseconds: i * _phaseOffset), () {
        if (mounted) c.repeat(reverse: true);
      });
      return c;
    });
  }

  @override
  void dispose() {
    for (final c in _dots) {
      c.dispose();
    }
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
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [IveTokens.accent, IveTokens.accentPressed],
              ),
            ),
            child: const Icon(Icons.auto_awesome,
                color: Colors.white, size: 14),
          ),
          const SizedBox(width: IveTokens.s2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: IveTokens.surface,
              borderRadius: IveTokens.brLg,
              border: IveTokens.cardBorder,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_dotCount, (i) {
                return AnimatedBuilder(
                  animation: _dots[i],
                  builder: (_, __) => Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 2),
                    child: Transform.translate(
                      // Bounce up by 4px at peak.
                      offset: Offset(0, -4 * _dots[i].value),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Color.lerp(
                            IveTokens.labelTertiary,
                            IveTokens.accent,
                            _dots[i].value,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Input Area ───────────────────────────────────────────────────────────────
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
      decoration: const BoxDecoration(
        color: IveTokens.surface,
        border: Border(top: BorderSide(color: IveTokens.hairline)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -2),
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
                        hintText: 'Ask Genie or tap a shortcut…',
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
                      if ((value).text.isEmpty) {
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

// ─── Pinned Shortcut Bar ──────────────────────────────────────────────────────
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
                        style: IveType.caption
                            .copyWith(color: IveTokens.labelSecondary),
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

// ─── Empty State ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Say "Hey Genie" or type something…',
        style: IveType.callout,
      ),
    );
  }
}
