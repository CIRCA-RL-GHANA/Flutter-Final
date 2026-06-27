import 'package:flutter/material.dart';
import '../../../core/design/ive_tokens.dart';
import '../../../core/design/ive_text.dart';
import '../../../core/widgets/hex_mark.dart';

/// Onboarding header used by screens 04–10.
///
/// When [currentStep] is provided, renders:
///   [HexMark] COMMERCE OS                [0X / 08]
///   ─────────────────────────────────────────── (accent progress)
///   Title
///   Subtitle (optional)
///
/// Otherwise renders:
///   [← back]
///   Title
///   Subtitle (optional)
class OnboardingHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;
  final int? currentStep;
  final int? totalSteps;

  const OnboardingHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
    this.currentStep,
    this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final hasStep = currentStep != null && totalSteps != null;
    final stepStr = hasStep
        ? '${currentStep.toString().padLeft(2, '0')} / ${totalSteps.toString().padLeft(2, '0')}'
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nav row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (hasStep) ...[
                const HexMark(size: 22),
                const SizedBox(width: 8),
                Text(
                  'COMMERCE OS',
                  style: IveType.mono.copyWith(
                    fontSize: 10,
                    color: IveTokens.ink,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ] else if (onBack != null)
                GestureDetector(
                  onTap: onBack,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 8, top: 4, bottom: 4),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 16,
                      color: IveTokens.ink2,
                    ),
                  ),
                ),

              const Spacer(),

              if (stepStr != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: IveTokens.surface,
                    border: Border.all(color: IveTokens.hairline),
                    borderRadius: BorderRadius.circular(IveTokens.rXs),
                  ),
                  child: Text(
                    stepStr,
                    style: IveType.mono.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: IveTokens.ink2,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),

          const SizedBox(height: 12),

          // Progress line
          if (hasStep) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(IveTokens.rPill),
              child: LinearProgressIndicator(
                value: currentStep! / totalSteps!,
                backgroundColor: IveTokens.hairline,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(IveTokens.accent),
                minHeight: 2,
              ),
            ),
            const SizedBox(height: 20),
          ] else
            const SizedBox(height: 4),

          // Title
          Text(
            title,
            style: IveType.display.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: IveTokens.ink,
              height: 1.2,
              letterSpacing: -0.3,
            ),
          ),

          // Subtitle
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 13,
                color: IveTokens.ink2,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
