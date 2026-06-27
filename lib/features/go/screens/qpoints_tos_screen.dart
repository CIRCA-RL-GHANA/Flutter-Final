/// Q Points Terms of Service Screen
///
/// Fully compliant with the Q Points ToS (v1.0.0, effective April 27, 2026).
/// Legal requirements enforced by UI:
///  - User must scroll to the bottom of the full ToS text before accepting.
///  - Three separate confirmation checkboxes must all be checked.
///  - Version and content hash are sent to the server for legal evidence.
///  - Decline flow navigates away without granting access.
library;

import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive.dart';
import '../providers/qpoints_tos_provider.dart';
import '../models/qpoint_market_models.dart';

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
  double _scrollProgress = 0.0;

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
    final pos = _scrollController.position;
    if (pos.maxScrollExtent > 0) {
      final progress = (pos.pixels / pos.maxScrollExtent).clamp(0.0, 1.0);
      if ((progress - _scrollProgress).abs() > 0.005) {
        setState(() => _scrollProgress = progress);
      }
    }
    final provider = context.read<QPointsTosProvider>();
    if (!provider.hasScrolledToBottom && pos.pixels >= pos.maxScrollExtent - 40) {
      provider.setScrolledToBottom();
    }
  }

  Future<void> _handleAccept(QPointsTosProvider provider) async {
    final platform = _getPlatform();
    final success = await provider.acceptTos(platform);
    if (!mounted) return;
    if (success) widget.onAccepted?.call();
  }

  void _handleDecline(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: IveTokens.surfaceRaised,
        title: Text('Decline terms?',
            style: IveType.title3.copyWith(color: IveTokens.ink)),
        content: Text(
          'Declining removes access to the Q Points Market  buying, selling, '
          'and transfers. Accept any time by returning to this screen.',
          style: IveType.body.copyWith(color: IveTokens.ink2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: IveTokens.ink2)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDeclined?.call();
            },
            child: Text('Decline',
                style: TextStyle(color: IveTokens.danger)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IveTokens.bg,
      appBar: AppBar(
        backgroundColor: IveTokens.surface,
        foregroundColor: IveTokens.ink,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Q Points Terms of Service',
                style: IveType.headline.copyWith(color: IveTokens.ink)),
            Text('Read and accept to continue',
                style: IveType.footnote.copyWith(color: IveTokens.mute)),
          ],
        ),
      ),
      body: Consumer<QPointsTosProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: IveTokens.accent),
                  const SizedBox(height: IveTokens.s4),
                  Text('Loading terms',
                      style: IveType.body.copyWith(color: IveTokens.mute)),
                ],
              ),
            );
          }

          if (provider.tosContent == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(IveTokens.s6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: IveTokens.danger),
                    const SizedBox(height: IveTokens.s4),
                    Text(
                      provider.errorMessage ?? 'Failed to load Terms of Service.',
                      textAlign: TextAlign.center,
                      style: IveType.body.copyWith(color: IveTokens.danger),
                    ),
                    const SizedBox(height: IveTokens.s4),
                    IveButton.primary(
                      label: 'Retry',
                      onPressed: provider.loadAll,
                      icon: Icons.refresh,
                    ),
                  ],
                ),
              ),
            );
          }

          final tos = provider.tosContent!;

          return Column(
            children: [
              //  Scroll progress hairline (spec P1) 
              AnimatedContainer(
                duration: const Duration(milliseconds: 80),
                height: 2,
                child: LinearProgressIndicator(
                  value: _scrollProgress,
                  backgroundColor: IveTokens.hairline,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _scrollProgress >= 1.0 ? IveTokens.success : IveTokens.accent,
                  ),
                  minHeight: 2,
                ),
              ),

              //  Version banner 
              _VersionBanner(tos: tos),

              //  Scroll prompt 
              if (!provider.hasScrolledToBottom) const _ScrollPromptBanner(),

              //  ToS body 
              Expanded(
                child: _TosBody(
                  tos: tos,
                  scrollController: _scrollController,
                ),
              ),

              //  Consent footer 
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

// 
// Sub-widgets
// 

class _VersionBanner extends StatelessWidget {
  final QPointsTosContent tos;
  const _VersionBanner({required this.tos});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: IveTokens.accentSoft,
      padding: const EdgeInsets.symmetric(
          horizontal: IveTokens.s4, vertical: IveTokens.s2 + 2),
      child: Row(
        children: [
          const Icon(Icons.gavel, size: 16, color: IveTokens.accent),
          const SizedBox(width: IveTokens.s2),
          Expanded(
            child: Text(
              'Version ${tos.version}  Effective ${tos.effectiveDate}  '
              'Governed by: Republic of Ghana law',
              style: IveType.footnote.copyWith(color: IveTokens.accent),
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
      color: IveTokens.warning.withValues(alpha: 0.10),
      padding: const EdgeInsets.symmetric(
          horizontal: IveTokens.s4, vertical: IveTokens.s2),
      child: Row(
        children: [
          const Icon(Icons.keyboard_arrow_down,
              color: IveTokens.warning, size: 18),
          const SizedBox(width: IveTokens.s1 + 2),
          Expanded(
            child: Text(
              'Scroll to the bottom to read the full terms before accepting.',
              style: IveType.footnote.copyWith(color: IveTokens.warning),
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
      color: IveTokens.surface,
      child: Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(IveTokens.s5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.shield_outlined,
                      color: IveTokens.accent, size: 28),
                  const SizedBox(width: IveTokens.s3),
                  Expanded(
                    child: Text(
                      'Q POINTS TERMS OF SERVICE',
                      style: IveType.title3.copyWith(color: IveTokens.accent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: IveTokens.s1 + 2),
              Text(
                'genie help Ltd.  ${tos.effectiveDate}',
                style: IveType.footnote.copyWith(color: IveTokens.mute),
              ),
              Divider(height: IveTokens.s6, color: IveTokens.hairline),

              // Full ToS text
              _buildTosText(tos.text),

              const SizedBox(height: IveTokens.s6),

              // Content hash
              Container(
                padding: const EdgeInsets.all(IveTokens.s3),
                decoration: BoxDecoration(
                  color: IveTokens.surfaceRaised,
                  borderRadius: IveTokens.brSm,
                  border: Border.all(color: IveTokens.hairline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Document integrity hash (SHA-256)',
                      style: IveType.caption.copyWith(
                        color: IveTokens.mute,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: IveTokens.s1),
                    Text(
                      tos.contentHash,
                      style: IveType.mono.copyWith(
                          color: IveTokens.mute, fontSize: 10),
                    ),
                    const SizedBox(height: IveTokens.s1),
                    Text(
                      'Recorded with your acceptance to prove the exact terms you reviewed.',
                      style: IveType.caption.copyWith(color: IveTokens.faint),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: IveTokens.s4),
              _RiskHighlightBox(),

              const SizedBox(height: IveTokens.s8),
              Center(
                child: Text(
                  ' Scroll up to re-read   Continue below to accept',
                  style: IveType.footnote.copyWith(
                      color: IveTokens.faint,
                      fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: IveTokens.s2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTosText(String text) {
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      if (RegExp(r'^\d+\.[\d]* [A-Z]').hasMatch(line)) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(
            line,
            style: IveType.callout.copyWith(
              fontWeight: FontWeight.bold,
              color: IveTokens.accent,
            ),
          ),
        ));
      } else if (line.startsWith('')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 12, top: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('  ',
                  style: IveType.subhead.copyWith(color: IveTokens.accent)),
              Expanded(
                child: Text(
                  line.substring(1).trim(),
                  style: IveType.subhead.copyWith(
                      color: IveTokens.ink2, height: 1.5),
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
            style: IveType.subhead.copyWith(
                color: IveTokens.ink2, height: 1.6),
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
      padding: const EdgeInsets.all(IveTokens.s4),
      decoration: BoxDecoration(
        color: IveTokens.warning.withValues(alpha: 0.08),
        borderRadius: IveTokens.brSm,
        border: Border.all(color: IveTokens.warning.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: IveTokens.warning, size: 20),
              const SizedBox(width: IveTokens.s2),
              Text(
                'KEY RISK DISCLOSURES (Section 9)',
                style: IveType.callout.copyWith(
                  fontWeight: FontWeight.bold,
                  color: IveTokens.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: IveTokens.s3),
          const _RiskItem(
            icon: Icons.trending_down,
            label: 'Market Risk',
            detail:
                'The price of Q Points is determined solely by supply and demand among users. '
                'It may be highly volatile, and you may suffer losses. '
                'Note: 1.00 Q Point is always equal to \$1.00 USD (fixed peg).',
          ),
          const _RiskItem(
            icon: Icons.bug_report_outlined,
            label: 'Technical Risk',
            detail:
                'The Q Points system relies on software, networks, and third-party services. '
                'Errors, delays, or unauthorized access could result in loss of Q Points or inability to trade.',
          ),
          const _RiskItem(
            icon: Icons.policy_outlined,
            label: 'Regulatory Risk',
            detail:
                'Laws and regulations regarding digital tokens vary by jurisdiction and may change. '
                'The company may need to modify or discontinue the Q Points system to comply with legal developments.',
          ),
          const _RiskItem(
            icon: Icons.no_encryption_outlined,
            label: 'No Insurance',
            detail:
                'Q Points are not insured by any government agency or deposit insurance scheme.',
          ),
          const _RiskItem(
            icon: Icons.swap_horiz,
            label: 'No Redemption Guarantee',
            detail:
                'The company has no legal obligation to repurchase Q Points for fiat or to guarantee a market. '
                'The AI participant maintains standing orders at \$1.00 as an operational last-resort feature only  not a legal guarantee. '
                'The AI participant may be suspended at any time without notice.',
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
  const _RiskItem(
      {required this.icon, required this.label, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: IveTokens.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: IveTokens.warning),
          const SizedBox(width: IveTokens.s2),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: IveType.callout.copyWith(
                      fontWeight: FontWeight.bold,
                      color: IveTokens.ink,
                    ),
                  ),
                  TextSpan(
                    text: detail,
                    style: IveType.callout.copyWith(
                        color: IveTokens.ink2, height: 1.4),
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
      decoration: const BoxDecoration(
        color: IveTokens.surface,
        border: Border(top: BorderSide(color: IveTokens.hairline)),
      ),
      padding: const EdgeInsets.fromLTRB(
          IveTokens.s4, IveTokens.s3, IveTokens.s4, IveTokens.s5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scroll gate indicator
          if (!provider.hasScrolledToBottom)
            Padding(
              padding: const EdgeInsets.only(bottom: IveTokens.s3),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 14, color: IveTokens.warning),
                  const SizedBox(width: IveTokens.s1 + 2),
                  Expanded(
                    child: Text(
                      'Scroll to the bottom to unlock acceptance.',
                      style:
                          IveType.footnote.copyWith(color: IveTokens.warning),
                    ),
                  ),
                ],
              ),
            ),

          _ConsentCheckbox(
            value: provider.readConfirmed,
            enabled: provider.hasScrolledToBottom,
            onChanged: provider.setReadConfirmed,
            label: 'I have read and understood the full Q Points Terms of Service.',
          ),
          _ConsentCheckbox(
            value: provider.riskConfirmed,
            enabled: provider.hasScrolledToBottom,
            onChanged: provider.setRiskConfirmed,
            label: 'I acknowledge all Risk Disclosures in Section 9, including market, '
                'technical, regulatory, and insurance risks.',
          ),
          _ConsentCheckbox(
            value: provider.ageConfirmed,
            enabled: provider.hasScrolledToBottom,
            onChanged: provider.setAgeConfirmed,
            label: 'I am at least 18 years of age (or the age of majority in my jurisdiction) '
                'as required by Section 3.1.',
          ),

          if (provider.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: IveTokens.s2),
              child: Text(
                provider.errorMessage!,
                style: IveType.footnote.copyWith(color: IveTokens.danger),
              ),
            ),

          const SizedBox(height: IveTokens.s3),

          Text(
            'By tapping "Accept", you agree to be legally bound by these terms under '
            'the laws of the Republic of Ghana. Disputes are settled by arbitration '
            'at the Ghana Arbitration Centre, Accra. Contact: legal@genieinprompt.app',
            style:
                IveType.caption.copyWith(color: IveTokens.mute, height: 1.4),
          ),
          const SizedBox(height: IveTokens.s3),

          // Primary: accept
          SizedBox(
            width: double.infinity,
            child: provider.isAccepting
                ? const Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: IveTokens.accent, strokeWidth: 2),
                    ),
                  )
                : IveButton.primary(
                    label: 'Accept & continue',
                    onPressed: provider.canAccept ? onAccept : null,
                  ),
          ),

          const SizedBox(height: IveTokens.s2),

          // Secondary: decline
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onDecline,
              child: Text('Decline',
                  style: IveType.body.copyWith(color: IveTokens.mute)),
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
      padding: const EdgeInsets.symmetric(vertical: IveTokens.s1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            // ignore: deprecated_member_use
            child: Checkbox(
              value: value,
              activeColor: IveTokens.accent,
              checkColor: IveTokens.bg,
              side: BorderSide(
                color: enabled ? IveTokens.hairline2 : IveTokens.faint,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(IveTokens.rXs)),
              onChanged: enabled ? (v) => onChanged(v ?? false) : null,
            ),
          ),
          const SizedBox(width: IveTokens.s2),
          Expanded(
            child: GestureDetector(
              onTap: enabled ? () => onChanged(!value) : null,
              child: Text(
                label,
                style: IveType.footnote.copyWith(
                  height: 1.4,
                  color: enabled ? IveTokens.ink2 : IveTokens.faint,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
