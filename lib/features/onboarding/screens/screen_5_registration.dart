import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/app_toast.dart';
import '../providers/phone_auth_provider.dart';
import '../providers/registration_provider.dart';
import '../providers/onboarding_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/user_service.dart';
import '../widgets/onboarding_header.dart';
import '../widgets/onboarding_loading_overlay.dart';

enum _LookupStatus { idle, checking, available, taken }

/// Screen 06 — Registration, step 03/08.
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _userService = UserService();

  final _fullNameCtrl  = TextEditingController();
  final _usernameCtrl  = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _passwordCtrl  = TextEditingController();

  final _fullNameFocus  = FocusNode();
  final _usernameFocus  = FocusNode();
  final _emailFocus     = FocusNode();
  final _passwordFocus  = FocusNode();

  bool _obscurePassword    = true;
  bool _usernameUserEdited = false; // stops auto-sync once user touches the field
  _LookupStatus _status    = _LookupStatus.idle;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final reg = context.read<RegistrationProvider>();
    if (reg.fullName.isNotEmpty)  _fullNameCtrl.text  = reg.fullName;
    if (reg.username.isNotEmpty)  _usernameCtrl.text  = reg.username;
    if (reg.email.isNotEmpty)     _emailCtrl.text     = reg.email;
    if (reg.password.isNotEmpty)  _passwordCtrl.text  = reg.password;

    for (final n in [_fullNameFocus, _usernameFocus, _emailFocus, _passwordFocus]) {
      n.addListener(() { if (mounted) setState(() {}); });
    }

    _fullNameCtrl.addListener(_onFullNameChanged);
    _usernameCtrl.addListener(_onUsernameChanged);
    _passwordCtrl.addListener(() { if (mounted) setState(() {}); });
    _emailCtrl.addListener(() { if (mounted) setState(() {}); });
  }

  // ── Full name sync ────────────────────────────────────────────────────────

  void _onFullNameChanged() {
    final full  = _fullNameCtrl.text.trim();
    final parts = full.split(RegExp(r'\s+'));
    final reg   = context.read<RegistrationProvider>();
    reg.setFirstName(parts.isNotEmpty ? parts.first : '');
    reg.setLastName(parts.length > 1 ? parts.sublist(1).join(' ') : '');

    // Auto-fill username from full name unless user has overridden it
    if (!_usernameUserEdited) {
      final derived = full.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '');
      _usernameCtrl.value = TextEditingValue(
        text: derived,
        selection: TextSelection.collapsed(offset: derived.length),
      );
      // _onUsernameChanged fires from the controller change
    }
    if (mounted) setState(() {});
  }

  // ── Username lookup ───────────────────────────────────────────────────────

  void _onUsernameChanged() {
    final val = _usernameCtrl.text.trim();
    final reg = context.read<RegistrationProvider>();
    reg.setUsername(val);
    reg.setWireId(val.isNotEmpty ? '@$val' : '');

    if (val.length < 3) {
      _debounce?.cancel();
      if (mounted) setState(() => _status = _LookupStatus.idle);
      return;
    }

    setState(() => _status = _LookupStatus.checking);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _checkUsername(val));
  }

  Future<void> _checkUsername(String username) async {
    final res = await _userService.checkUsername(username);
    if (!mounted || _usernameCtrl.text.trim() != username) return;
    final available = res.success && (res.data?['available'] as bool? ?? false);
    setState(() => _status = available ? _LookupStatus.available : _LookupStatus.taken);
  }

  // ── Validation ────────────────────────────────────────────────────────────

  bool get _canContinue {
    final reg = context.read<RegistrationProvider>();
    return _fullNameCtrl.text.trim().length >= 2 &&
        (_status == _LookupStatus.available) &&
        _emailCtrl.text.trim().isNotEmpty &&
        reg.dateOfBirth != null &&
        reg.isPasswordValid;
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _onContinue() async {
    final reg       = context.read<RegistrationProvider>();
    final onboarding = context.read<OnboardingProvider>();

    final email = _emailCtrl.text.trim();
    if (!RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email)) {
      AppToast.error(context, 'Enter a valid email address.');
      return;
    }

    reg.setEmail(email);
    reg.setPassword(_passwordCtrl.text);

    final success = await reg.saveRegistration(
      phoneNumber: context.read<PhoneAuthProvider>().formattedNumber,
    );
    if (!mounted) return;

    if (success) {
      await AuthService().login(
        identifier: context.read<PhoneAuthProvider>().formattedNumber,
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      onboarding.setRegistrationData(
        firstName: reg.firstName,
        lastName:  reg.lastName,
        email:     email,
        dateOfBirth: reg.dateOfBirth,
      );
      Navigator.of(context).pushNamed(AppRoutes.profilePhoto);
    } else {
      AppToast.error(context, reg.error ?? 'Registration failed.');
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _fullNameCtrl.removeListener(_onFullNameChanged);
    _usernameCtrl.removeListener(_onUsernameChanged);
    _fullNameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _fullNameFocus.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<RegistrationProvider>(
      builder: (context, reg, _) => OnboardingLoadingOverlay(
        isLoading: reg.isLoading,
        child: Scaffold(
          backgroundColor: IveTokens.bg,
          body: SafeArea(
            child: Responsive.constrained(
              child: Column(
                children: [
                  OnboardingHeader(
                    title: 'Your details',
                    subtitle: 'Tell us who you are.',
                    currentStep: 3,
                    totalSteps: 8,
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // FULL NAME
                          const _FieldLabel('FULL NAME'),
                          const SizedBox(height: 6),
                          _InputBox(
                            controller: _fullNameCtrl,
                            focusNode: _fullNameFocus,
                            hint: 'Kwame Mensah',
                            nextFocus: _usernameFocus,
                            textCapitalization: TextCapitalization.words,
                            keyboardType: TextInputType.name,
                          ),

                          const SizedBox(height: 16),

                          // USERNAME
                          const _FieldLabel('USERNAME'),
                          const SizedBox(height: 6),
                          _InputBox(
                            controller: _usernameCtrl,
                            focusNode: _usernameFocus,
                            hint: 'kwamemensah',
                            nextFocus: _emailFocus,
                            keyboardType: TextInputType.text,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9_]')),
                            ],
                            onTap: () => _usernameUserEdited = true,
                            suffix: _StatusIcon(status: _status),
                            caption: _statusCaption,
                            captionColor: _statusCaptionColor,
                          ),

                          const SizedBox(height: 16),

                          // EMAIL
                          const _FieldLabel('EMAIL'),
                          const SizedBox(height: 6),
                          _InputBox(
                            controller: _emailCtrl,
                            focusNode: _emailFocus,
                            hint: 'kwame@mail.com',
                            nextFocus: _passwordFocus,
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 16),

                          // DATE OF BIRTH
                          const _FieldLabel('DATE OF BIRTH'),
                          const SizedBox(height: 6),
                          _DobField(
                            value: reg.dateOfBirth,
                            onPick: reg.setDateOfBirth,
                          ),

                          const SizedBox(height: 16),

                          // PASSWORD
                          const _FieldLabel('PASSWORD'),
                          const SizedBox(height: 6),
                          _InputBox(
                            controller: _passwordCtrl,
                            focusNode: _passwordFocus,
                            hint: '••••••••',
                            obscure: _obscurePassword,
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.done,
                            suffix: GestureDetector(
                              onTap: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                              child: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 18,
                                color: IveTokens.mute,
                              ),
                            ),
                            onChanged: reg.setPassword,
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    child: IveButton.primary(
                      label: 'CONTINUE',
                      isLoading: reg.isLoading,
                      onPressed: _canContinue ? _onContinue : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? get _statusCaption {
    switch (_status) {
      case _LookupStatus.available: return 'Available';
      case _LookupStatus.taken:     return 'Already taken';
      case _LookupStatus.checking:  return 'Checking…';
      case _LookupStatus.idle:      return null;
    }
  }

  Color get _statusCaptionColor {
    switch (_status) {
      case _LookupStatus.available: return IveTokens.success;
      case _LookupStatus.taken:     return IveTokens.danger;
      default:                      return IveTokens.mute;
    }
  }
}

// ── Status suffix icon ────────────────────────────────────────────────────────

class _StatusIcon extends StatelessWidget {
  final _LookupStatus status;
  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case _LookupStatus.checking:
        return const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: IveTokens.mute,
          ),
        );
      case _LookupStatus.available:
        return const Icon(Icons.check_circle_outline,
            size: 18, color: IveTokens.success);
      case _LookupStatus.taken:
        return const Icon(Icons.cancel_outlined,
            size: 18, color: IveTokens.danger);
      case _LookupStatus.idle:
        return const SizedBox.shrink();
    }
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: IveType.mono.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: IveTokens.mute,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final bool obscure;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final FocusNode? nextFocus;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final String? caption;
  final Color? captionColor;

  const _InputBox({
    required this.controller,
    required this.focusNode,
    required this.hint,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.none,
    this.nextFocus,
    this.suffix,
    this.onChanged,
    this.onTap,
    this.inputFormatters,
    this.caption,
    this.captionColor,
  });

  @override
  Widget build(BuildContext context) {
    final focused = focusNode.hasFocus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: IveTokens.dFast,
          decoration: BoxDecoration(
            color: IveTokens.surface,
            borderRadius: BorderRadius.circular(IveTokens.rSm),
            border: Border.all(
              color: focused ? IveTokens.accent : IveTokens.hairline,
              width: focused ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscure,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            textCapitalization: textCapitalization,
            inputFormatters: inputFormatters,
            onTap: onTap,
            onSubmitted: nextFocus != null
                ? (_) => FocusScope.of(context).requestFocus(nextFocus)
                : null,
            onChanged: onChanged,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: IveTokens.ink,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 15, color: IveTokens.mute),
              suffixIcon: suffix != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: suffix,
                    )
                  : null,
              suffixIconConstraints: const BoxConstraints(minWidth: 36),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              isCollapsed: false,
            ),
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: 5),
          Text(
            caption!,
            style: TextStyle(
              fontSize: 11,
              color: captionColor ?? IveTokens.mute,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _DobField extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime?> onPick;
  const _DobField({required this.value, required this.onPick});

  String get _display {
    if (value == null) return 'DD / MM / YYYY';
    final d = value!.day.toString().padLeft(2, '0');
    final m = value!.month.toString().padLeft(2, '0');
    return '$d / $m / ${value!.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime(now.year - 18, now.month, now.day),
          firstDate: DateTime(now.year - 120),
          lastDate: DateTime(now.year - 13, now.month, now.day),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: IveTokens.accent,
                surface: IveTokens.surface,
                onSurface: IveTokens.ink,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: IveTokens.surface,
          borderRadius: BorderRadius.circular(IveTokens.rSm),
          border: Border.all(color: IveTokens.hairline),
        ),
        child: Row(
          children: [
            Text(
              _display,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: value != null ? IveTokens.ink : IveTokens.mute,
              ),
            ),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down,
                size: 18, color: IveTokens.mute),
          ],
        ),
      ),
    );
  }
}
