/// Q Points Terms of Service Screen
/// 
/// Fully compliant with the Q Points ToS (v1.0.0, effective April 27, 2026).
/// Legal requirements enforced by UI:
///  - User must scroll to the bottom of the full ToS text before accepting.
///  - Three separate confirmation checkboxes must all be checked.
///  - Version and content hash are sent to the server for legal evidence.
///  - Decline flow navigates away without granting access.

import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/qpoints_tos_provider.dart';
import '../models/qpoint_market_models.dart';

const Color kQpColor = Color(0xFF6C47FF);
const Color kQpLight = Color(0xFFF4F3FF);
const Color kDanger = Color(0xFFD32F2F);

/// Returns the platform string to send to the backend.
String _getPlatform() {
  if (kIsWeb) return 'web';
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      return 'ios';
    case TargetPlatform.android:
      return 'android';
    default:
      return 'web';
  }
}

// ignore: avoid_bool_literals_in_conditional_expressions
const bool kIsWeb = bool.fromEnvironment('dart.library.html');

class QPointsTosScreen extends StatefulWidget {
  /// Called after the user successfully accepts the ToS.
  final VoidCallback? onAccepted;

  /// Called if the user declines.
  final VoidCallback? onDeclined;

  const QPointsTosScreen({super.key, this.onAccepted, this.onDeclined});

  @override
  State<QPointsTosScreen> createState() => _QPointsTosScreenState();
}

class _QPointsTosScreenState extends State<QPointsTosScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QPointsTosProvider>().loadAll();
      _scrollController.addListener(_onScroll);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final provider = context.read<QPointsTosProvider>();
    if (!provider.hasScrolledToBottom) {
      final pos = _scrollController.position;
      if (pos.pixels >= pos.maxScrollExtent - 40) {
        provider.setScrolledToBottom();
      }
    }
  }

  Future<void> _handleAccept(QPointsTosProvider provider) async {
    final platform = _getPlatform();
    final success = await provider.acceptTos(platform);
    if (!mounted) return;
    if (success) {
      widget.onAccepted?.call();
    }
  }

  void _handleDecline(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Decline Terms?'),
        content: const Text(
          'If you decline the Q Points Terms of Service, you will not be able '
          'to use the Q Points Market, including buying, selling, or transferring '
          'Q Points. You can accept at any time by returning to this screen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kDanger),
            onPressed: () {
              Navigator.pop(context);
              widget.onDeclined?.call();
            },
            child: const Text('Decline & Exit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kQpLight,
      appBar: AppBar(
        backgroundColor: kQpColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Q Points Terms of Service',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Please read and accept to continue',
              style: TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<QPointsTosProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: kQpColor),
                  SizedBox(height: 16),
                  Text('Loading Terms of Service…',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          if (provider.tosContent == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: kDanger),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage ?? 'Failed to load Terms of Service.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: kDanger),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(backgroundColor: kQpColor),
                    onPressed: provider.loadAll,
                  ),
                ],
              ),
            );
          }

          final tos = provider.tosContent!;

          return Column(
            children: [
              // ── Version banner ───────────────────────────────────────────
              _VersionBanner(tos: tos),

              // ── Scroll-to-read instruction ───────────────────────────────
              if (!provider.hasScrolledToBottom)
                const _ScrollPromptBanner(),

              // ── ToS Body (scrollable) ────────────────────────────────────
              Expanded(
                child: _TosBody(
                  tos: tos,
                  scrollController: _scrollController,
                ),
              ),

              // ── After scroll: Checkboxes + Buttons ───────────────────────
              _ConsentFooter(
                provider: provider,
                onAccept: () => _handleAccept(provider),
                onDecline: () => _handleDecline(context),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _VersionBanner extends StatelessWidget {
  final QPointsTosContent tos;
  const _VersionBanner({required this.tos});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: kQpColor.withOpacity(0.12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.gavel, size: 16, color: kQpColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Version ${tos.version} · Effective ${tos.effectiveDate} · '
              'Governed by: Republic of Ghana law',
              style: const TextStyle(
                fontSize: 12,
                color: kQpColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScrollPromptBanner extends StatelessWidget {
  const _ScrollPromptBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFF8E1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: const Row(
        children: [
          Icon(Icons.keyboard_arrow_down, color: Color(0xFFF57F17), size: 18),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              'Scroll to the bottom to read the full Terms before accepting.',
              style: TextStyle(fontSize: 12, color: Color(0xFFF57F17)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TosBody extends StatelessWidget {
  final QPointsTosContent tos;
  final ScrollController scrollController;

  const _TosBody({required this.tos, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Row(
                children: [
                  Icon(Icons.shield_outlined, color: kQpColor, size: 28),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Q POINTS TERMS OF SERVICE',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kQpColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'PROMPT Genie Ltd. · ${tos.effectiveDate}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Divider(height: 24),

              // Full ToS text rendered as formatted sections
              _buildTosText(tos.text),

              const SizedBox(height: 24),

              // Content hash for transparency
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Document Integrity Hash (SHA-256)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tos.contentHash,
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'This hash is recorded with your acceptance to prove the '
                      'exact ToS text you reviewed.',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Risk highlight box (Section 9)
              _RiskHighlightBox(),

              const SizedBox(height: 32),

              Center(
                child: Text(
                  '↑ Scroll up to re-read any section · ↓ Continue below to accept',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTosText(String text) {
    // Render section headers and bullet points nicely
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      if (RegExp(r'^\d+\.[\d]* [A-Z]').hasMatch(line)) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(
            line,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: kQpColor,
            ),
          ),
        ));
      } else if (line.startsWith('•')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 12, top: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('•  ', style: TextStyle(color: kQpColor, fontSize: 13)),
              Expanded(
                child: Text(
                  line.substring(1).trim(),
                  style: const TextStyle(fontSize: 13, height: 1.5),
                ),
              ),
            ],
          ),
        ));
      } else if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 6));
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Text(
            line,
            style: const TextStyle(fontSize: 13, height: 1.6, color: Color(0xFF333333)),
          ),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}

class _RiskHighlightBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFF9800)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFE65100), size: 20),
              SizedBox(width: 8),
              Text(
                'KEY RISK DISCLOSURES (Section 9)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE65100),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          _RiskItem(
            icon: Icons.trending_down,
            label: 'Market Risk',
            detail:
                'The price of Q Points is determined solely by supply and demand among Users. '
                'It may be highly volatile, and you may suffer losses. '
                'Note: 1.00 Q Point is always equal to \$1.00 USD (fixed peg).',
          ),
          _RiskItem(
            icon: Icons.bug_report_outlined,
            label: 'Technical Risk',
            detail:
                'The Q Points System relies on software, networks, and third-party services. '
                'Errors, delays, or unauthorized access could result in loss of Q Points or inability to trade.',
          ),
          _RiskItem(
            icon: Icons.policy_outlined,
            label: 'Regulatory Risk',
            detail:
                'Laws and regulations regarding digital tokens vary by jurisdiction and may change. '
                'The Company may be required to modify or discontinue the Q Points System to comply with legal developments.',
          ),
          _RiskItem(
            icon: Icons.no_encryption_outlined,
            label: 'No Insurance',
            detail:
                'Q Points are not insured by any government agency or deposit insurance scheme.',
          ),
          _RiskItem(
            icon: Icons.swap_horiz,
            label: 'No Redemption Guarantee',
            detail:
                'The Company has no legal obligation to repurchase Q Points for fiat or to guarantee a market. '
                'The AI Participant maintains standing buy and sell orders at \$1.00 as an operational last-resort feature, '
                'meaning it may fill your order if no peer counterparty is available — but this is not a legal guarantee of redemption. '
                'The AI Participant may be suspended at any time without notice.',
          ),
        ],
      ),
    );
  }
}

class _RiskItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String detail;
  const _RiskItem({required this.icon, required this.label, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFE65100)),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                      fontSize: 12,
                    ),
                  ),
                  TextSpan(
                    text: detail,
                    style: const TextStyle(color: Color(0xFF555555), fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsentFooter extends StatelessWidget {
  final QPointsTosProvider provider;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _ConsentFooter({
    required this.provider,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scroll gate indicator
          if (!provider.hasScrolledToBottom)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: Colors.orange.shade700),
                  const SizedBox(width: 6),
                  const Text(
                    'Scroll to the bottom of the Terms to unlock acceptance.',
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ],
              ),
            ),

          // Checkbox 1: Read confirmed
          _ConsentCheckbox(
            value: provider.readConfirmed,
            enabled: provider.hasScrolledToBottom,
            onChanged: provider.setReadConfirmed,
            label: 'I have read and understood the full Q Points Terms of Service.',
          ),

          // Checkbox 2: Risk acknowledgement (Section 9)
          _ConsentCheckbox(
            value: provider.riskConfirmed,
            enabled: provider.hasScrolledToBottom,
            onChanged: provider.setRiskConfirmed,
            label: 'I acknowledge and accept all Risk Disclosures in Section 9, '
                'including market, technical, regulatory, and insurance risks.',
          ),

          // Checkbox 3: Age confirmation (Section 3.1)
          _ConsentCheckbox(
            value: provider.ageConfirmed,
            enabled: provider.hasScrolledToBottom,
            onChanged: provider.setAgeConfirmed,
            label: 'I confirm I am at least 18 years of age (or the age of majority '
                'in my jurisdiction) as required by Section 3.1.',
          ),

          if (provider.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: kDanger, fontSize: 12),
              ),
            ),

          const SizedBox(height: 12),

          // Legal note
          Text(
            'By tapping "Accept & Continue", you agree to be legally bound by '
            'these Terms under the laws of the Republic of Ghana, without regard '
            'to conflict of law principles. Disputes shall be finally settled by '
            'arbitration in accordance with the Arbitration Rules of the Ghana '
            'Arbitration Centre, Accra, Ghana. '
            'Contact: legal@genieinprompt.app',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.4),
          ),
          const SizedBox(height: 12),

          // Accept button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    provider.canAccept ? kQpColor : Colors.grey.shade300,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: provider.canAccept ? 2 : 0,
              ),
              onPressed: provider.canAccept ? onAccept : null,
              child: provider.isAccepting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Accept & Continue',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
            ),
          ),

          const SizedBox(height: 8),

          // Decline button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onDecline,
              child: Text(
                'Decline',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsentCheckbox extends StatelessWidget {
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final String label;

  const _ConsentCheckbox({
    required this.value,
    required this.enabled,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              activeColor: kQpColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              onChanged: enabled ? (v) => onChanged(v ?? false) : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: enabled ? () => onChanged(!value) : null,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.4,
                  color: enabled ? const Color(0xFF333333) : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
