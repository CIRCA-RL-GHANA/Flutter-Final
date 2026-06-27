import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/app_toast.dart';
import '../providers/phone_auth_provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_header.dart';
import '../widgets/onboarding_loading_overlay.dart';

/// Screen 05 — OTP verification, step 02/08.
class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String countryCode;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.countryCode,
  });

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  Timer? _timer;
  int _remainingSeconds = 299;
  bool _canResend = false;
  bool _isVerifying = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnim = Tween(begin: 0.0, end: 8.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeCtrl);

    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _focusNodes[0].requestFocus());
  }

  void _startTimer() {
    _remainingSeconds = 299;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 269) _canResend = true;
        if (_remainingSeconds <= 0) t.cancel();
      });
      context.read<PhoneAuthProvider>().updateTimer(_remainingSeconds);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeCtrl.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _formattedTime {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _onDigitEntered(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == 6) _verifyOtp(otp);
  }

  void _distributePaste(String digits) {
    final code = digits.replaceAll(RegExp(r'[^0-9]'), '');
    final len = code.length.clamp(0, 6);
    for (int i = 0; i < 6; i++) {
      _controllers[i].text = i < len ? code[i] : '';
    }
    _focusNodes[(len - 1).clamp(0, 5)].requestFocus();
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == 6) _verifyOtp(otp);
  }

  void _onKeyPressed(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyOtp(String otp) async {
    setState(() => _isVerifying = true);
    HapticFeedback.mediumImpact();

    final auth = context.read<PhoneAuthProvider>();
    final success = await auth.verifyOtp(otp);

    if (!mounted) return;

    if (success) {
      setState(() {
        _isSuccess = true;
        _isVerifying = false;
      });
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      context.read<OnboardingProvider>().completeOtp();
      final isReturning =
          context.read<OnboardingProvider>().isReturningUser;
      if (isReturning) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.welcomeBack, (r) => false);
      } else {
        Navigator.of(context)
            .pushReplacementNamed(AppRoutes.registration);
      }
    } else {
      setState(() => _isVerifying = false);
      _shakeCtrl.forward().then((_) => _shakeCtrl.reset());
      HapticFeedback.heavyImpact();
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
    }
  }

  Future<void> _resendOtp() async {
    final auth = context.read<PhoneAuthProvider>();
    final success = await auth.resendOtp();
    if (!mounted) return;
    if (success) {
      _startTimer();
      AppToast.success(context, 'New code sent.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<PhoneAuthProvider>();

    return OnboardingLoadingOverlay(
      isLoading: _isVerifying,
      child: Scaffold(
        backgroundColor: IveTokens.bg,
        body: SafeArea(
          child: Responsive.constrained(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OnboardingHeader(
                  title: 'Enter the code',
                  subtitle:
                      'Sent to ${widget.countryCode} ${widget.phoneNumber}',
                  currentStep: 2,
                  totalSteps: 8,
                ),

                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 6 OTP boxes
                        AnimatedBuilder(
                          animation: _shakeAnim,
                          builder: (context, child) =>
                              Transform.translate(
                            offset: Offset(
                              _shakeAnim.value *
                                  (_shakeCtrl.isAnimating
                                      ? (_shakeCtrl.value * 10).toInt() %
                                                  2 ==
                                              0
                                          ? 1.0
                                          : -1.0
                                      : 0.0),
                              0,
                            ),
                            child: child,
                          ),
                          child: Row(
                            children: List.generate(6, (i) {
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      right: i < 5 ? 8 : 0),
                                  child: _OtpBox(
                                    controller: _controllers[i],
                                    focusNode: _focusNodes[i],
                                    isSuccess: _isSuccess,
                                    onChanged: (v) =>
                                        _onDigitEntered(i, v),
                                    onKey: (e) =>
                                        _onKeyPressed(i, e),
                                    onPaste: _distributePaste,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),

                        if (auth.error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            auth.error!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: IveTokens.danger,
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Resend row
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _canResend
                                  ? 'Code expired'
                                  : 'Resend in $_formattedTime',
                              style: const TextStyle(
                                fontSize: 13,
                                color: IveTokens.mute,
                              ),
                            ),
                            GestureDetector(
                              onTap: _canResend &&
                                      auth.resendAttemptsRemaining >
                                          0
                                  ? _resendOtp
                                  : null,
                              child: Text(
                                'Resend code',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _canResend &&
                                          auth.resendAttemptsRemaining >
                                              0
                                      ? IveTokens.accent
                                      : IveTokens.mute,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // VERIFY button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: IveButton.primary(
                    label: 'VERIFY',
                    isLoading: _isVerifying,
                    onPressed: _isSuccess
                        ? null
                        : () {
                            final otp = _controllers
                                .map((c) => c.text)
                                .join();
                            if (otp.length == 6) _verifyOtp(otp);
                          },
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

// ── Paste-aware formatter ─────────────────────────────────────────────────────

class _PasteAwareFormatter extends TextInputFormatter {
  final void Function(String digits) onPaste;
  _PasteAwareFormatter(this.onPaste);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 1) {
      // Distribute paste asynchronously so we're not modifying state
      // from within a formatter call.
      Future.microtask(() => onPaste(digits));
      return oldValue;
    }
    final single = digits.isEmpty ? '' : digits[0];
    return newValue.copyWith(
      text: single,
      selection: TextSelection.collapsed(offset: single.length),
    );
  }
}

// ── Single OTP digit box ──────────────────────────────────────────────────────

class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSuccess;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKey;
  final void Function(String digits) onPaste;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.isSuccess,
    required this.onChanged,
    required this.onKey,
    required this.onPaste,
  });

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _fillCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _fillCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _fillCtrl, curve: Curves.easeOut),
    );
    widget.controller.addListener(_onCtrlChanged);
    widget.focusNode.addListener(_onFocusChanged);
  }

  void _onCtrlChanged() {
    if (!mounted) return;
    setState(() {});
    if (widget.controller.text.isNotEmpty) {
      _fillCtrl.forward().then((_) {
        if (mounted) _fillCtrl.reverse();
      });
    }
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onCtrlChanged);
    widget.focusNode.removeListener(_onFocusChanged);
    _fillCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filled = widget.controller.text.isNotEmpty;
    final focused = widget.focusNode.hasFocus;

    Color borderCol;
    if (widget.isSuccess) {
      borderCol = IveTokens.success;
    } else if (focused) {
      borderCol = IveTokens.accent;
    } else if (filled) {
      borderCol = IveTokens.hairline2;
    } else {
      borderCol = IveTokens.hairline;
    }

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: widget.onKey,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: AnimatedContainer(
          duration: IveTokens.dFast,
          height: 56,
          decoration: BoxDecoration(
            color: widget.isSuccess
                ? IveTokens.success.withValues(alpha: 0.08)
                : IveTokens.surface,
            borderRadius:
                BorderRadius.circular(IveTokens.rSm),
            border: Border.all(
              color: borderCol,
              width: (focused || widget.isSuccess) ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            onChanged: widget.onChanged,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color:
                  widget.isSuccess ? IveTokens.success : IveTokens.ink,
            ),
            inputFormatters: [
              _PasteAwareFormatter(widget.onPaste),
            ],
            textAlignVertical: TextAlignVertical.center,
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
              isCollapsed: true,
            ),
          ),
        ),
      ),
    );
  }
}
