/// ─────────────────────────────────────────────────────────────────────────────
/// LIVE MODULE — Screen 13: Delivery Verification Flow
/// Multi-method verification: PIN entry, photo capture,
/// signature, biometric, proof of delivery, and confirmation
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive.dart';
import '../models/live_models.dart';
import '../providers/live_provider.dart';
import '../widgets/live_widgets.dart';

class LiveDeliveryVerificationScreen extends StatefulWidget {
  const LiveDeliveryVerificationScreen({super.key});

  @override
  State<LiveDeliveryVerificationScreen> createState() => _LiveDeliveryVerificationScreenState();
}

class _LiveDeliveryVerificationScreenState extends State<LiveDeliveryVerificationScreen> {
  int _step = 0; // 0=PIN, 1=Photo, 2=Signature
  bool _pinVerified = false;
  bool _photoTaken = false;
  bool _signatureCollected = false;
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  bool get _canProceed {
    switch (_step) {
      case 0: return _pinVerified;
      case 1: return _photoTaken;
      case 2: return _signatureCollected;
      default: return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveProvider>(
      builder: (context, prov, _) {
        final pkg = prov.selectedPackage ?? prov.packages.first;

        if (_step == 3) {
          return _CompletionView(package: pkg, onDone: () => Navigator.pop(context));
        }

        const stepLabels = ['PIN', 'Photo', 'Signature'];

        return Scaffold(
          backgroundColor: IveTokens.voidColor,
          appBar: LiveAppBar(
            title: stepLabels[_step],
          ),
          body: Column(
            children: [
              // StepBar replacing custom dots (spec P1 — gold checkpoint pulse)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  IveTokens.s4, IveTokens.s3, IveTokens.s4, 0,
                ),
                child: StepBar(
                  steps: stepLabels,
                  currentStep: _step,
                ),
              ),

              Expanded(
                child: IndexedStack(
                  index: _step,
                  children: [
                    _PinStep(
                      controller: _pinController,
                      verified: _pinVerified,
                      onVerify: () {
                        HapticFeedback.heavyImpact();
                        setState(() => _pinVerified = true);
                      },
                    ),
                    _PhotoStep(
                      taken: _photoTaken,
                      onCapture: () {
                        HapticFeedback.mediumImpact();
                        setState(() => _photoTaken = true);
                      },
                    ),
                    _SignatureStep(
                      collected: _signatureCollected,
                      onSign: () {
                        HapticFeedback.mediumImpact();
                        setState(() => _signatureCollected = true);
                      },
                      onClear: () => setState(() => _signatureCollected = false),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: EdgeInsets.fromLTRB(
              IveTokens.s4,
              IveTokens.s3,
              IveTokens.s4,
              IveTokens.s4 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: const BoxDecoration(
              color: IveTokens.surfaceColor,
              border: Border(top: BorderSide(color: IveTokens.hairColor, width: 1)),
            ),
            child: Row(
              children: [
                if (_step > 0) ...[
                  Expanded(
                    child: IveButton.secondary(
                      label: 'Back',
                      onPressed: () => setState(() => _step--),
                    ),
                  ),
                  const SizedBox(width: IveTokens.s3),
                ],
                Expanded(
                  flex: 2,
                  child: _canProceed
                      ? IveButton.primary(
                          label: _step == 2 ? 'Complete delivery' : 'Next',
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            setState(() => _step++);
                          },
                        )
                      : IveButton.primary(
                          label: _step == 2 ? 'Complete delivery' : 'Next',
                          onPressed: null,
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── PIN Step ─────────────────────────────────────────────────────────────────

class _PinStep extends StatelessWidget {
  final TextEditingController controller;
  final bool verified;
  final VoidCallback onVerify;
  const _PinStep({required this.controller, required this.verified, required this.onVerify});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(IveTokens.s4),
      children: [
        const SizedBox(height: IveTokens.s5),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(IveTokens.s4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (verified ? IveTokens.okColor : kLiveColor).withValues(alpha: 0.12),
                ),
                child: Icon(
                  verified ? Icons.check_circle_rounded : Icons.dialpad_rounded,
                  size: 48,
                  color: verified ? IveTokens.okColor : kLiveColor,
                ),
              ),
              const SizedBox(height: IveTokens.s4),
              Text(
                verified ? 'PIN verified' : 'Enter delivery PIN',
                style: IveType.title3.copyWith(
                  color: verified ? IveTokens.okColor : IveTokens.inkColor,
                ),
              ),
              const SizedBox(height: IveTokens.s1),
              Text(
                'Ask the customer for their 4-digit delivery PIN',
                style: IveType.callout.copyWith(color: IveTokens.muteColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: IveTokens.s6),
        if (!verified) ...[
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 4,
            // PIN in large mono (spec P1)
            style: GoogleFonts.ibmPlexMono(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: 16,
              color: IveTokens.inkColor,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
            cursorColor: kLiveColor,
            decoration: InputDecoration(
              hintText: '· · · ·',
              hintStyle: GoogleFonts.ibmPlexMono(
                fontSize: 24,
                color: IveTokens.faintColor,
                letterSpacing: 16,
              ),
              counterText: '',
              filled: true,
              fillColor: IveTokens.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(IveTokens.rContainer),
                borderSide: const BorderSide(color: IveTokens.hairColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(IveTokens.rContainer),
                borderSide: const BorderSide(color: IveTokens.hairColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(IveTokens.rContainer),
                borderSide: const BorderSide(color: kLiveColor, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: IveTokens.s4),
          IveButton.primary(label: 'Verify PIN', onPressed: onVerify),
        ],
      ],
    );
  }
}

// ─── Photo Step ───────────────────────────────────────────────────────────────

class _PhotoStep extends StatelessWidget {
  final bool taken;
  final VoidCallback onCapture;
  const _PhotoStep({required this.taken, required this.onCapture});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(IveTokens.s4),
      children: [
        const SizedBox(height: IveTokens.s5),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(IveTokens.s4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (taken ? IveTokens.okColor : IveTokens.accentColor).withValues(alpha: 0.12),
                ),
                child: Icon(
                  taken ? Icons.check_circle_rounded : Icons.camera_alt_rounded,
                  size: 48,
                  color: taken ? IveTokens.okColor : IveTokens.accentColor,
                ),
              ),
              const SizedBox(height: IveTokens.s4),
              Text(
                taken ? 'Photo captured' : 'Proof of delivery',
                style: IveType.title3.copyWith(
                  color: taken ? IveTokens.okColor : IveTokens.inkColor,
                ),
              ),
              const SizedBox(height: IveTokens.s1),
              Text(
                'Take a clear photo of the delivered package',
                style: IveType.callout.copyWith(color: IveTokens.muteColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: IveTokens.s6),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: taken
                ? IveTokens.okColor.withValues(alpha: 0.10)
                : IveTokens.surfaceColor,
            borderRadius: BorderRadius.circular(IveTokens.rContainer),
            border: Border.all(
              color: taken ? IveTokens.okColor.withValues(alpha: 0.4) : IveTokens.hairColor,
            ),
          ),
          child: Center(
            child: taken
                ? const Icon(Icons.check_circle_rounded, size: 56, color: IveTokens.okColor)
                : Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.camera_alt_rounded, size: 40, color: IveTokens.muteColor),
                    const SizedBox(height: IveTokens.s2),
                    Text('Capture', style: IveType.caption.copyWith(color: IveTokens.muteColor)),
                  ]),
          ),
        ),
        if (!taken) ...[
          const SizedBox(height: IveTokens.s4),
          IveButton.primary(label: 'Capture photo', onPressed: onCapture),
        ],
      ],
    );
  }
}

// ─── Signature Step ───────────────────────────────────────────────────────────

class _SignatureStep extends StatelessWidget {
  final bool collected;
  final VoidCallback onSign;
  final VoidCallback? onClear;
  const _SignatureStep({required this.collected, required this.onSign, this.onClear});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(IveTokens.s4),
      children: [
        const SizedBox(height: IveTokens.s5),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(IveTokens.s4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (collected ? IveTokens.okColor : IveTokens.warnColor).withValues(alpha: 0.12),
                ),
                child: Icon(
                  collected ? Icons.check_circle_rounded : Icons.draw_rounded,
                  size: 48,
                  color: collected ? IveTokens.okColor : IveTokens.warnColor,
                ),
              ),
              const SizedBox(height: IveTokens.s4),
              Text(
                collected ? 'Signature collected' : 'Digital signature',
                style: IveType.title3.copyWith(
                  color: collected ? IveTokens.okColor : IveTokens.inkColor,
                ),
              ),
              const SizedBox(height: IveTokens.s1),
              Text(
                'Have the customer sign below to confirm delivery',
                style: IveType.callout.copyWith(color: IveTokens.muteColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: IveTokens.s6),
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: collected
                ? IveTokens.okColor.withValues(alpha: 0.10)
                : IveTokens.surfaceColor,
            borderRadius: BorderRadius.circular(IveTokens.rContainer),
            border: Border.all(
              color: collected
                  ? IveTokens.okColor.withValues(alpha: 0.4)
                  : IveTokens.warnColor.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Center(
            child: collected
                ? const Icon(Icons.check_circle_rounded, size: 56, color: IveTokens.okColor)
                : Text(
                    'Sign here',
                    style: IveType.callout.copyWith(
                      color: IveTokens.faintColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
          ),
        ),
        if (!collected) ...[
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onClear,
              child: Text('Clear', style: IveType.callout.copyWith(color: IveTokens.muteColor)),
            ),
          ),
          IveButton.primary(label: 'Confirm signature', onPressed: onSign),
        ],
      ],
    );
  }
}

// ─── Completion View ──────────────────────────────────────────────────────────

class _CompletionView extends StatelessWidget {
  final LivePackage package;
  final VoidCallback onDone;
  const _CompletionView({required this.package, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IveTokens.voidColor,
      appBar: const LiveAppBar(title: 'Delivery complete'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(IveTokens.s6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(IveTokens.s6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: IveTokens.okColor.withValues(alpha: 0.12),
                ),
                child: const Icon(Icons.check_circle_rounded, size: 64, color: IveTokens.okColor),
              ),
              const SizedBox(height: IveTokens.s5),
              Text('Delivery verified', style: IveType.title1),
              const SizedBox(height: IveTokens.s2),
              Text(
                'Package ${package.id} delivered successfully',
                style: IveType.callout.copyWith(color: IveTokens.ink2Color),
              ),
              const SizedBox(height: IveTokens.s5),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(IveTokens.s4),
                decoration: BoxDecoration(
                  color: IveTokens.raisedColor,
                  borderRadius: BorderRadius.circular(IveTokens.rContainer),
                  border: Border.all(color: IveTokens.hairColor),
                ),
                child: const Column(
                  children: [
                    _CheckRow('PIN verified'),
                    SizedBox(height: IveTokens.s2),
                    _CheckRow('Photo evidence captured'),
                    SizedBox(height: IveTokens.s2),
                    _CheckRow('Signature collected'),
                    SizedBox(height: IveTokens.s2),
                    _CheckRow('GPS location logged'),
                  ],
                ),
              ),
              const SizedBox(height: IveTokens.s6),
              IveButton.primary(label: 'Back to home', onPressed: onDone),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String label;
  const _CheckRow(this.label);

  @override
  Widget build(BuildContext context) => Row(children: [
    const Icon(Icons.check_circle_rounded, size: 16, color: IveTokens.okColor),
    const SizedBox(width: IveTokens.s2),
    Text(label, style: IveType.callout),
  ]);
}
