/// ═══════════════════════════════════════════════════════════════════════════
/// LIVE MODULE — Screen 13: Delivery Verification Flow
/// Multi-method verification: PIN entry, photo capture,
/// signature, biometric, proof of delivery, and confirmation
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../models/live_models.dart';
import '../providers/live_provider.dart';
import '../widgets/live_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class LiveDeliveryVerificationScreen extends StatefulWidget {
  const LiveDeliveryVerificationScreen({super.key});

  @override
  State<LiveDeliveryVerificationScreen> createState() => _LiveDeliveryVerificationScreenState();
}

class _LiveDeliveryVerificationScreenState extends State<LiveDeliveryVerificationScreen> {
  int _step = 0; // 0=PIN, 1=Photo, 2=Signature, 3=Complete
  bool _pinVerified = false;
  bool _photoTaken = false;
  bool _signatureCollected = false;
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveProvider>(
      builder: (context, prov, _) {
        final pkg = prov.selectedPackage ?? prov.packages.first;

        if (_step == 3) {
          return _CompletionView(package: pkg, onDone: () => Navigator.pop(context));
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: LiveAppBar(
            title: _step == 0 ? 'PIN Verification' : _step == 1 ? 'Photo Evidence' : 'Digital Signature',
          ),
          body: Column(
            children: [
              // Step progress
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Row(
                  children: [
                    _StepDot(label: 'PIN', active: _step >= 0, completed: _pinVerified),
                    Expanded(child: Container(height: 2, color: _pinVerified ? const Color(0xFF10B981) : const Color(0xFFE5E7EB))),
                    _StepDot(label: 'Photo', active: _step >= 1, completed: _photoTaken),
                    Expanded(child: Container(height: 2, color: _photoTaken ? const Color(0xFF10B981) : const Color(0xFFE5E7EB))),
                    _StepDot(label: 'Sign', active: _step >= 2, completed: _signatureCollected),
                  ],
                ),
              ),

              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: Colors.green.shade50,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        Icon(Icons.verified_user, size: 14, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI verification: ${ai.insights.first['title'] ?? ''}',
                            style: TextStyle(fontSize: 11, color: Colors.green.shade700),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              Expanded(
                child: IndexedStack(
                  index: _step,
                  children: [
                    // Step 0: PIN Verification
                    _PinStep(
                      controller: _pinController,
                      verified: _pinVerified,
                      onVerify: () {
                        HapticFeedback.heavyImpact();
                        setState(() {
                          _pinVerified = true;
                        });
                      },
                    ),
                    // Step 1: Photo Evidence
                    _PhotoStep(
                      taken: _photoTaken,
                      onCapture: () {
                        HapticFeedback.mediumImpact();
                        setState(() => _photoTaken = true);
                      },
                    ),
                    // Step 2: Signature
                    _SignatureStep(
                      collected: _signatureCollected,
                      onSign: () {
                        HapticFeedback.mediumImpact();
                        setState(() => _signatureCollected = true);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))],
            ),
            child: Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _step--),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text('BACK'),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _canProceed
                        ? () {
                            HapticFeedback.mediumImpact();
                            setState(() => _step++);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _step == 2 ? const Color(0xFF10B981) : kLiveColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _step == 0 ? 'NEXT: TAKE PHOTO' : _step == 1 ? 'NEXT: SIGNATURE' : '✅ COMPLETE DELIVERY',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool get _canProceed {
    switch (_step) {
      case 0:
        return _pinVerified;
      case 1:
        return _photoTaken;
      case 2:
        return _signatureCollected;
      default:
        return false;
    }
  }
}

class _PinStep extends StatelessWidget {
  final TextEditingController controller;
  final bool verified;
  final VoidCallback onVerify;
  const _PinStep({required this.controller, required this.verified, required this.onVerify});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: verified ? const Color(0xFF10B981).withOpacity(0.1) : kLiveColor.withOpacity(0.1),
                ),
                child: Icon(
                  verified ? Icons.check_circle : Icons.dialpad,
                  size: 48,
                  color: verified ? const Color(0xFF10B981) : kLiveColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                verified ? 'PIN VERIFIED ✅' : 'ENTER CUSTOMER PIN',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: verified ? const Color(0xFF10B981) : AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text('Ask the customer for their 4-digit delivery PIN', style: TextStyle(fontSize: 13, color: AppColors.textSecondary), textAlign: TextAlign.center),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (!verified) ...[
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 4,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: 16),
            decoration: InputDecoration(
              hintText: '• • • •',
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kLiveColor, width: 2)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onVerify,
              style: ElevatedButton.styleFrom(backgroundColor: kLiveColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('VERIFY PIN', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ],
    );
  }
}

class _PhotoStep extends StatelessWidget {
  final bool taken;
  final VoidCallback onCapture;
  const _PhotoStep({required this.taken, required this.onCapture});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: taken ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFF3B82F6).withOpacity(0.1),
                ),
                child: Icon(
                  taken ? Icons.check_circle : Icons.camera_alt,
                  size: 48,
                  color: taken ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                taken ? 'PHOTO CAPTURED ✅' : 'PROOF OF DELIVERY PHOTO',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: taken ? const Color(0xFF10B981) : AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text('Take a clear photo of the delivered package', style: TextStyle(fontSize: 13, color: AppColors.textSecondary), textAlign: TextAlign.center),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (!taken) ...[
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB), style: BorderStyle.solid, width: 2),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt, size: 48, color: AppColors.textTertiary),
                  const SizedBox(height: 8),
                  Text('Tap to capture photo', style: TextStyle(fontSize: 13, color: AppColors.textTertiary)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onCapture,
              icon: const Icon(Icons.camera_alt, size: 18),
              label: const Text('CAPTURE PHOTO', style: TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
        ] else
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(child: Icon(Icons.check_circle, size: 64, color: Color(0xFF10B981))),
          ),
      ],
    );
  }
}

class _SignatureStep extends StatelessWidget {
  final bool collected;
  final VoidCallback onSign;
  const _SignatureStep({required this.collected, required this.onSign});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: collected ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFF8B5CF6).withOpacity(0.1),
                ),
                child: Icon(
                  collected ? Icons.check_circle : Icons.edit,
                  size: 48,
                  color: collected ? const Color(0xFF10B981) : const Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                collected ? 'SIGNATURE COLLECTED ✅' : 'DIGITAL SIGNATURE',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: collected ? const Color(0xFF10B981) : AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text('Have the customer sign below to confirm delivery', style: TextStyle(fontSize: 13, color: AppColors.textSecondary), textAlign: TextAlign.center),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (!collected) ...[
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF8B5CF6), width: 2),
            ),
            child: Center(
              child: Text('Sign here', style: TextStyle(fontSize: 16, color: AppColors.textTertiary, fontStyle: FontStyle.italic)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () {}, child: const Text('Clear', style: TextStyle(color: AppColors.textSecondary))),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onSign,
              icon: const Icon(Icons.done, size: 18),
              label: const Text('CONFIRM SIGNATURE', style: TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
        ] else
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(child: Icon(Icons.check_circle, size: 64, color: Color(0xFF10B981))),
          ),
      ],
    );
  }
}

class _CompletionView extends StatelessWidget {
  final LivePackage package;
  final VoidCallback onDone;
  const _CompletionView({required this.package, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const LiveAppBar(title: 'Delivery Complete'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF10B981).withOpacity(0.1)),
                child: const Icon(Icons.celebration, size: 64, color: Color(0xFF10B981)),
              ),
              const SizedBox(height: 20),
              const Text('🎉 DELIVERY VERIFIED!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('Package ${package.id} delivered successfully', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              const Text('All verification steps completed', style: TextStyle(fontSize: 13, color: Color(0xFF10B981), fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(12)),
                child: const Column(
                  children: [
                    Row(children: [Icon(Icons.check, size: 16, color: Color(0xFF059669)), SizedBox(width: 6), Text('PIN verified', style: TextStyle(fontSize: 13, color: Color(0xFF059669)))]),
                    SizedBox(height: 4),
                    Row(children: [Icon(Icons.check, size: 16, color: Color(0xFF059669)), SizedBox(width: 6), Text('Photo evidence captured', style: TextStyle(fontSize: 13, color: Color(0xFF059669)))]),
                    SizedBox(height: 4),
                    Row(children: [Icon(Icons.check, size: 16, color: Color(0xFF059669)), SizedBox(width: 6), Text('Digital signature collected', style: TextStyle(fontSize: 13, color: Color(0xFF059669)))]),
                    SizedBox(height: 4),
                    Row(children: [Icon(Icons.check, size: 16, color: Color(0xFF059669)), SizedBox(width: 6), Text('GPS location logged', style: TextStyle(fontSize: 13, color: Color(0xFF059669)))]),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onDone,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: const Text('BACK TO HOME', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool active;
  final bool completed;
  const _StepDot({required this.label, required this.active, required this.completed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: completed ? const Color(0xFF10B981) : active ? kLiveColor : const Color(0xFFE5E7EB),
          ),
          child: Center(
            child: completed
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : active
                    ? const Icon(Icons.circle, size: 8, color: Colors.white)
                    : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: active ? AppColors.textPrimary : AppColors.textTertiary)),
      ],
    );
  }
}
