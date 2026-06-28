library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/design/ive.dart';
import '../core/routes/app_routes.dart';
import '../features/prompt/providers/context_provider.dart';
import '../features/prompt/models/rbac_models.dart';
import 'genie_controller.dart';
import 'genie_intent.dart';
import 'genie_voice.dart';
import 'widgets/genie_full_screen_launcher.dart';

class GenieScreen extends StatefulWidget {
  const GenieScreen({super.key});

  @override
  State<GenieScreen> createState() => _GenieScreenState();
}

class _GenieScreenState extends State<GenieScreen> {
  late GenieController _controller;
  late TextEditingController _textCtrl;
  late ScrollController _scrollCtrl;
  late FocusNode _inputFocus;
  bool _controllerReady = false;

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController();
    _scrollCtrl = ScrollController();
    _inputFocus = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = context.read<ContextProvider>();
      _controller = GenieController(contextProvider: ctx);
      _controller.addListener(_onUpdate);
      setState(() => _controllerReady = true);
    });
  }

  @override
  void dispose() {
    if (_controllerReady) {
      _controller.removeListener(_onUpdate);
      _controller.dispose();
    }
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _onUpdate() {
    setState(() {});
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

  void _handleChip(String label) {
    _inputFocus.unfocus();
    _controller.handleInput(label);
  }

  void _handleVoice() async {
    if (_controller.isListening) {
      await _controller.stopVoice();
      return;
    }
    await _controller.startVoice();
  }

  @override
  Widget build(BuildContext context) {
    final ctxProvider = context.watch<ContextProvider>();
    final role = ctxProvider.currentRole;
    final ctx = ctxProvider.activeContext;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: IveTokens.bg,
        body: SafeArea(
          child: _controllerReady
              ? _Body(
                  ctx: ctx,
                  role: role,
                  controller: _controller,
                  textCtrl: _textCtrl,
                  scrollCtrl: _scrollCtrl,
                  inputFocus: _inputFocus,
                  onSend: _handleSend,
                  onChip: _handleChip,
                  onVoice: _handleVoice,
                  onModules: () => GenieFullScreenLauncher.showModuleMenu(context, role),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({
    required this.ctx,
    required this.role,
    required this.controller,
    required this.textCtrl,
    required this.scrollCtrl,
    required this.inputFocus,
    required this.onSend,
    required this.onChip,
    required this.onVoice,
    required this.onModules,
  });

  final AppContextModel ctx;
  final UserRole role;
  final GenieController controller;
  final TextEditingController textCtrl;
  final ScrollController scrollCtrl;
  final FocusNode inputFocus;
  final VoidCallback onSend;
  final ValueChanged<String> onChip;
  final VoidCallback onVoice;
  final VoidCallback onModules;

  @override
  Widget build(BuildContext context) {
    final hasMessages = controller.messages.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TopBar(ctx: ctx),
        Expanded(
          child: hasMessages
              ? _ChatThread(controller: controller, scrollCtrl: scrollCtrl)
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Text(_greeting(), style: IveType.title1),
                      ),
                      // Genie input card
                      _GenieInputCard(
                        textCtrl: textCtrl,
                        inputFocus: inputFocus,
                        role: role,
                        isListening: controller.isListening,
                        isProcessing: controller.isProcessing,
                        onSend: onSend,
                        onChip: onChip,
                        onVoice: onVoice,
                      ),
                      const SizedBox(height: 28),
                      _JumpBackIn(),
                      const SizedBox(height: 28),
                      const _YourModules(),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    final time = h < 12 ? 'Good morning' : h < 17 ? 'Good afternoon' : 'Good evening';
    final first = ctx.name.split(' ').first;
    return first.isNotEmpty ? '$time, $first.' : '$time.';
  }
}

// ─── Top bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.ctx});
  final AppContextModel ctx;

  String get _dayLabel {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[DateTime.now().weekday - 1];
  }

  String get _roleLabel {
    switch (ctx.role) {
      case UserRole.owner:         return 'OWNER';
      case UserRole.administrator: return 'ADMIN';
      case UserRole.branchManager: return 'BRANCH MGR';
      case UserRole.driver:        return 'DRIVER';
      default:                     return 'MEMBER';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
      child: Row(
        children: [
          Text(
            '$_roleLabel · ACCRA · $_dayLabel',
            style: IveType.caption.copyWith(
              color: IveTokens.mute,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          // Search
          _IconBtn(
            icon: Icons.search_rounded,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.utilitySearch),
          ),
          const SizedBox(width: 4),
          // Notifications with badge
          _NotifBtn(),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 20, color: IveTokens.mute),
      ),
    );
  }
}

class _NotifBtn extends StatelessWidget {
  const _NotifBtn();

  @override
  Widget build(BuildContext context) {
    const badgeCount = 3; // TODO: wire to UtilityProvider.unreadCount
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.utilityNotifications),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(Icons.notifications_none_rounded, size: 20, color: IveTokens.mute),
            if (badgeCount > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: IveTokens.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Jump Back In ─────────────────────────────────────────────────────────────

class _JumpBackIn extends StatelessWidget {
  const _JumpBackIn();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'JUMP BACK IN',
          style: IveType.caption.copyWith(
            color: IveTokens.mute,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _JumpCard(
                label: 'GO',
                labelColor: IveTokens.accent,
                title: 'Wallet',
                subtitle: 'Balance steady',
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.goHub),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _JumpCard(
                label: 'MARKET',
                labelColor: IveTokens.success,
                title: '1 delivery',
                subtitle: 'Kofi · 4 min away',
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.marketHub),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _JumpCard extends StatelessWidget {
  const _JumpCard({
    required this.label,
    required this.labelColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final String label;
  final Color labelColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: IveTokens.surface,
          borderRadius: BorderRadius.circular(IveTokens.rContainer),
          border: Border.all(color: IveTokens.hairline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: IveType.caption.copyWith(
                color: labelColor,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(title, style: IveType.headline),
            const SizedBox(height: 2),
            Text(subtitle, style: IveType.caption.copyWith(color: IveTokens.mute)),
          ],
        ),
      ),
    );
  }
}

// ─── Your Modules ─────────────────────────────────────────────────────────────

class _YourModules extends StatelessWidget {
  const _YourModules();

  static const _modules = [
    _Module('GO',        Icons.credit_card_outlined,        AppRoutes.goHub,            false),
    _Module('MARKET',   Icons.grid_view_outlined,           AppRoutes.marketHub,        false),
    _Module('UPDATES',  Icons.diamond_outlined,             AppRoutes.updatesFeed,      false),
    _Module('APRIL',    Icons.auto_awesome,                 AppRoutes.aprilDashboard,   true),
    _Module('CHAT',     Icons.chat_bubble_outline_rounded,  AppRoutes.qualChatDashboard, false),
    _Module('SETUP',    Icons.tune,                         AppRoutes.setupDashboard,   false),
    _Module('E-PLAY',   Icons.play_arrow_outlined,          AppRoutes.eplayHub,         false),
    _Module('COMMUNITY',Icons.language_outlined,            AppRoutes.communityHub,     false),
    _Module('FINTECH',  Icons.account_balance_outlined,     AppRoutes.fintechLoans,     false),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR MODULES',
          style: IveType.caption.copyWith(
            color: IveTokens.mute,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: _modules.length,
          itemBuilder: (context, i) => _ModuleTile(module: _modules[i]),
        ),
      ],
    );
  }
}

class _Module {
  final String label;
  final IconData icon;
  final String route;
  final bool isGold;
  const _Module(this.label, this.icon, this.route, this.isGold);
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({required this.module});
  final _Module module;

  @override
  Widget build(BuildContext context) {
    final color = module.isGold ? IveTokens.genie : IveTokens.accent;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.of(context).pushNamed(module.route);
      },
      child: Container(
        decoration: BoxDecoration(
          color: IveTokens.surface,
          borderRadius: BorderRadius.circular(IveTokens.rContainer),
          border: Border.all(color: IveTokens.hairline),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(module.icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              module.label,
              style: IveType.caption.copyWith(
                fontSize: 10,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600,
                color: IveTokens.ink2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Chat thread ──────────────────────────────────────────────────────────────

class _ChatThread extends StatelessWidget {
  const _ChatThread({required this.controller, required this.scrollCtrl});
  final GenieController controller;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollCtrl,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      itemCount: controller.messages.length,
      itemBuilder: (context, i) {
        final msg = controller.messages[i];
        if (msg.text == null || msg.text!.isEmpty) return const SizedBox.shrink();
        final isUser = msg.isUser;
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            decoration: BoxDecoration(
              color: isUser ? IveTokens.genie.withValues(alpha: 0.15) : IveTokens.surface,
              borderRadius: BorderRadius.circular(IveTokens.rContainer),
              border: Border.all(
                color: isUser ? IveTokens.genie.withValues(alpha: 0.3) : IveTokens.hairline,
              ),
            ),
            child: Text(
              msg.text ?? '',
              style: IveType.callout.copyWith(
                color: isUser ? IveTokens.genie : IveTokens.ink,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Genie input card ─────────────────────────────────────────────────────────

class _GenieInputCard extends StatefulWidget {
  const _GenieInputCard({
    required this.textCtrl,
    required this.inputFocus,
    required this.role,
    required this.isListening,
    required this.isProcessing,
    required this.onSend,
    required this.onChip,
    required this.onVoice,
  });

  final TextEditingController textCtrl;
  final FocusNode inputFocus;
  final UserRole role;
  final bool isListening;
  final bool isProcessing;
  final VoidCallback onSend;
  final ValueChanged<String> onChip;
  final VoidCallback onVoice;

  @override
  State<_GenieInputCard> createState() => _GenieInputCardState();
}

class _GenieInputCardState extends State<_GenieInputCard> {
  @override
  void initState() {
    super.initState();
    widget.textCtrl.addListener(() => setState(() {}));
  }

  List<String> get _chips {
    switch (widget.role) {
      case UserRole.driver:
        return ['My earnings', 'Active trip', 'Navigate home'];
      default:
        return ["How's my spending?", 'Find a driver', 'Pay Ama', "Today's orders"];
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.textCtrl.text.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: IveTokens.surface,
        borderRadius: BorderRadius.circular(IveTokens.rContainer),
        border: Border.all(
          color: widget.inputFocus.hasFocus ? IveTokens.genie : IveTokens.hairline,
          width: widget.inputFocus.hasFocus ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Input row
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 14),
                child: Icon(Icons.auto_awesome, size: 16, color: IveTokens.genie),
              ),
              Expanded(
                child: TextField(
                  controller: widget.textCtrl,
                  focusNode: widget.inputFocus,
                  enabled: !widget.isProcessing,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => widget.onSend(),
                  style: IveType.callout.copyWith(color: IveTokens.ink),
                  decoration: InputDecoration(
                    hintText: 'Ask Genie anything...',
                    hintStyle: IveType.callout.copyWith(color: IveTokens.mute),
                    border: InputBorder.none,
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: hasText ? widget.onSend : widget.onVoice,
                  child: AnimatedContainer(
                    duration: IveTokens.dFast,
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: hasText || widget.isListening
                          ? IveTokens.genie
                          : IveTokens.genie.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasText
                          ? Icons.arrow_upward_rounded
                          : widget.isListening
                              ? Icons.stop_rounded
                              : Icons.mic_none_rounded,
                      size: 16,
                      color: hasText || widget.isListening ? IveTokens.bg : IveTokens.genie,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Quick chips
          const Divider(height: 1, color: IveTokens.hairline),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _chips.map((chip) => GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onChip(chip);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: IveTokens.bg,
                    borderRadius: BorderRadius.circular(IveTokens.rPill),
                    border: Border.all(color: IveTokens.hairline2),
                  ),
                  child: Text(
                    chip,
                    style: IveType.footnote.copyWith(color: IveTokens.ink2),
                  ),
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
