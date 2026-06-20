import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/design/ive.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive.dart';
import '../providers/phone_auth_provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_header.dart';


// OS palette — mirrors splash / welcome
// ignore: unused_element
const Color _kTextDim   = IveTokens.labelSecondary;
/// Screen 4: OTP Verification (Secure)
/// Maximum security with minimum friction
class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String countryCode;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.countryCode,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  Timer? _timer;
  int _remainingSeconds = 299; // 4:59
  bool _canResend = false;
  bool _isVerifying = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _shakeAnimation = Tween(begin: 0.0, end: 8.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    _startTimer();

    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startTimer() {
    _remainingSeconds = 299;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _canResend = true;
          timer.cancel();
        }
        // Allow first resend after 30 seconds
        if (_remainingSeconds <= 269) {
          // 299 - 30
          _canResend = true;
        }
      });
      context.read<PhoneAuthProvider>().updateTimer(_remainingSeconds);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _onDigitEntered(int index, String value) {
    if (value.length == 1 && index < 5) {
      // Auto-advance
      _focusNodes[index + 1].requestFocus();
    }

    // Check if all 6 digits are entered â†’ auto-submit
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length == 6) {
      _verifyOtp(otp);
    }
  }

  void _onKeyPressed(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _otpControllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  // ignore: unused_element
  void _handlePaste(String? value) {
    if (value == null || value.length < 6) return;
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 6) return; // reject if not exactly 6 digits
    for (int i = 0; i < 6 && i < digits.length; i++) {
      _otpControllers[i].text = digits[i];
    }
    if (digits.length >= 6) {
      _verifyOtp(digits.substring(0, 6));
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

      // Wait for success animation
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      context.read<OnboardingProvider>().completeOtp();
      Navigator.of(context).pushReplacementNamed(AppRoutes.registration);
    } else {
      setState(() => _isVerifying = false);
      _shakeController.forward().then((_) => _shakeController.reset());
      HapticFeedback.heavyImpact();

      // Clear fields
      for (var c in _otpControllers) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.newCodeSent),
          backgroundColor: IveTokens.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: IveTokens.brMd),
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<PhoneAuthProvider>();

    return Scaffold(
      backgroundColor: IveTokens.bg,
      body: SafeArea(
        child: Responsive.constrained(
          child: Column(
            children: [
              OnboardingHeader(
                title: AppStrings.verifyNumber,
                currentStep: 2,
                totalSteps: 8,
                onBack: () => Navigator.pop(context),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Phone number display with edit
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: const BoxDecoration(
                            color: IveTokens.surface,
                            borderRadius: IveTokens.brMd,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${widget.countryCode} ${widget.phoneNumber}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: IveTokens.label,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.edit,
                                size: 16,
                                color: IveTokens.accent,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      const Text(
                        AppStrings.enterOtpCode,
                        style: TextStyle(
                          fontSize: 14,
                          color: IveTokens.labelSecondary,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // OTP Input Matrix
                      AnimatedBuilder(
                        animation: _shakeAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                              _shakeAnimation.value *
                                  (_shakeController.isAnimating
                                      ? ((_shakeController.value * 10).toInt() %
                                                  2 ==
                                              0
                                          ? 1
                                          : -1)
                                      : 0),
                              0,
                            ),
                            child: child,
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (index) {
                            return Container(
                              width: 50,
                              height: 56,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: _OtpDigitField(
                                controller: _otpControllers[index],
                                focusNode: _focusNodes[index],
                                isSuccess: _isSuccess,
                                onChanged: (value) =>
                                    _onDigitEntered(index, value),
                                onKey: (event) =>
                                    _onKeyPressed(index, event),
                              ),
                            );
                          }),
                        ),
                      ),

                      // Error message
                      if (auth.error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          auth.error!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: IveTokens.danger,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Timer / Resend
                      if (_isSuccess)
                        const _SuccessIndicator()
                      else if (_isVerifying)
                        // Content-shaped skeleton replaces spinner (Move 06)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            children: [
                              IveSkeleton(
                                width: double.infinity,
                                height: 3,
                                radius: BorderRadius.circular(IveTokens.rChip),
                              ),
                              const SizedBox(height: IveTokens.s2),
                              IveSkeleton(
                                width: 120,
                                height: 12,
                                radius: BorderRadius.circular(IveTokens.rAtom),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        // Timer display
                        if (!_canResend)
                          Column(
                            children: [
                              // Circular timer
                              SizedBox(
                                width: 60,
                                height: 60,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      value: _remainingSeconds / 299,
                                      strokeWidth: 3,
                                      backgroundColor: IveTokens.surface,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                        IveTokens.accent,
                                      ),
                                    ),
                                    Text(
                                      _formattedTime,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: IveTokens.label,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${AppStrings.resendCode} $_formattedTime',
                                style: const TextStyle(
                                  fontSize: 13,
                                color: IveTokens.labelTertiary,
                                ),
                              ),
                            ],
                          ),

                        if (_canResend)
                          TextButton(
                            onPressed:
                                auth.resendAttemptsRemaining > 0
                                    ? _resendOtp
                                    : null,
                            child: Text(
                              _remainingSeconds <= 0
                                  ? AppStrings.codeExpired
                                  : 'Resend Code',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: auth.resendAttemptsRemaining > 0
                                    ? IveTokens.accent
                                    : IveTokens.labelTertiary,
                              ),
                            ),
                          ),

                        const SizedBox(height: 32),

                        // Alternative methods
                        const Text(
                          'Didn\'t receive a code?',
                          style: TextStyle(
                            fontSize: 14,
                            color: IveTokens.labelSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _AlternativeMethodButton(
                          icon: Icons.phone,
                          label: AppStrings.getCodeViaCall,
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sending code via call...'))),
                        ),
                        const SizedBox(height: 8),
                        _AlternativeMethodButton(
                          icon: Icons.chat_bubble_outline,
                          label: AppStrings.receiveOnWhatsApp,
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sending code via WhatsApp...'))),
                        ),
                        const SizedBox(height: 8),
                        _AlternativeMethodButton(
                          icon: Icons.email_outlined,
                          label: AppStrings.sendToEmail,
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sending code to email...'))),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpDigitField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSuccess;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKey;

  const _OtpDigitField({
    required this.controller,
    required this.focusNode,
    required this.isSuccess,
    required this.onChanged,
    required this.onKey,
  });

  @override
  State<_OtpDigitField> createState() => _OtpDigitFieldState();
}

class _OtpDigitFieldState extends State<_OtpDigitField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fillCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _fillCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _fillCtrl, curve: Curves.easeOut),
    );
    widget.controller.addListener(_onControllerChanged);
    widget.focusNode.addListener(_onFocusChanged);
  }

  void _onControllerChanged() {
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
    widget.controller.removeListener(_onControllerChanged);
    widget.focusNode.removeListener(_onFocusChanged);
    _fillCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filled = widget.controller.text.isNotEmpty;
    final focused = widget.focusNode.hasFocus;

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: widget.onKey,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: AnimatedContainer(
          duration: IveTokens.dFast,
          decoration: BoxDecoration(
            color: widget.isSuccess
                ? IveTokens.okColor.withValues(alpha: 0.10)
                : filled
                    ? IveTokens.accentSoftBlue
                    : IveTokens.surfaceColor,
            borderRadius: BorderRadius.circular(IveTokens.rContainer),
            border: Border.all(
              color: widget.isSuccess
                  ? IveTokens.okColor
                  : (filled || focused)
                      ? IveTokens.accentColor
                      : IveTokens.hairColor,
              width: (widget.isSuccess || filled || focused) ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            onChanged: widget.onChanged,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color:
                  widget.isSuccess ? IveTokens.okColor : IveTokens.inkColor,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessIndicator extends StatelessWidget {
  const _SuccessIndicator();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, value, child) => Transform.scale(
            scale: value,
            child: child,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: IveTokens.okColor,
            size: 56,
          ),
        ),
        const SizedBox(height: IveTokens.s3),
        Text(
          'Verified',
          style: IveType.title3.copyWith(color: IveTokens.okColor),
        ),
      ],
    );
  }
}

class _AlternativeMethodButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AlternativeMethodButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: IveTokens.brMd,
          border: Border.all(color: IveTokens.hairline),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: IveTokens.labelSecondary),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: IveTokens.labelSecondary,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: IveTokens.labelTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
