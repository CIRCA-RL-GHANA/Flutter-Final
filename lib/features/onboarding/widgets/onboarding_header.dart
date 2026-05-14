import 'package:flutter/material.dart';

// OS palette — shared with splash / welcome
const Color _kBg        = Color(0xFF08080F);
const Color _kSurface   = Color(0xFF0E0E1A);
const Color _kBorder    = Color(0xFF1C1C2E);
const Color _kAccent    = Color(0xFF22BDD8);
const Color _kText      = Color(0xFFE8E8F0);
const Color _kTextDim   = Color(0xFF6B6B88);
const Color _kTextMuted = Color(0xFF3A3A52);

/// OS-aesthetic onboarding header.
///
/// Renders:
///   [←]              03 / 08
///   ──────────────[fill]─────
///   Title text
///   Optional subtitle
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
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Nav row ───────────────────────────────────────────────────
          Row(
            children: [
              // Back button — icon only, no container
              if (onBack != null)
                GestureDetector(
                  onTap: onBack,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 8, top: 4, bottom: 4),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 16,
                      color: _kTextDim,
                    ),
                  ),
                )
              else
                const SizedBox(width: 24),

              const Spacer(),

              // Step counter
              if (stepStr != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kSurface,
                    border: Border.all(color: _kBorder),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    stepStr,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _kTextDim,
                      letterSpacing: 1.2,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),

              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),

          const SizedBox(height: 16),

          // ── Thin progress bar ─────────────────────────────────────────
          if (hasStep) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: currentStep! / totalSteps!,
                backgroundColor: _kBorder,
                valueColor: const AlwaysStoppedAnimation<Color>(_kAccent),
                minHeight: 2,
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── Title ─────────────────────────────────────────────────────
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _kText,
              height: 1.25,
            ),
          ),

          // ── Subtitle ──────────────────────────────────────────────────
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 13,
                color: _kTextDim,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
