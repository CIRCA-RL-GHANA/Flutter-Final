import 'package:flutter/material.dart';
import 'ive_text.dart';
import 'ive_tokens.dart';

/// Horizontal step progress bar.
///
/// Active segment sweeps left → right over [sweepDuration] (240 ms default).
/// On checkpoint arrival the active segment pulses once (scale + opacity).
/// Labels below: active step in [IveTokens.inkColor], others in [IveTokens.muteColor].
///
/// Example:
/// ```dart
/// StepBar(
///   steps: const ['Details', 'Verify', 'Done'],
///   currentStep: 1,
/// )
/// ```
class StepBar extends StatefulWidget {
  const StepBar({
    super.key,
    required this.steps,
    required this.currentStep,
    this.sweepDuration = const Duration(milliseconds: 240),
  });

  /// Step labels shown beneath the segments.
  final List<String> steps;

  /// Zero-indexed active step.
  final int currentStep;

  /// Duration for the active segment sweep.
  final Duration sweepDuration;

  @override
  State<StepBar> createState() => _StepBarState();
}

class _StepBarState extends State<StepBar> with TickerProviderStateMixin {
  late AnimationController _sweepCtrl;
  late AnimationController _pulseCtrl;
  int _prevStep = -1;

  @override
  void initState() {
    super.initState();
    _sweepCtrl = AnimationController(
      vsync: this,
      duration: widget.sweepDuration,
      value: 1.0, // start filled
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _prevStep = widget.currentStep;
  }

  @override
  void didUpdateWidget(StepBar old) {
    super.didUpdateWidget(old);
    if (widget.currentStep != _prevStep) {
      _prevStep = widget.currentStep;
      final reduced = MediaQuery.of(context).disableAnimations;
      if (reduced) {
        _sweepCtrl.value = 1.0;
      } else {
        _sweepCtrl.forward(from: 0).then((_) {
          if (mounted) _pulseCtrl.forward(from: 0);
        });
      }
    }
  }

  @override
  void dispose() {
    _sweepCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.steps.length;
    return Column(
      children: [
        Row(
          children: List.generate(n, (i) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < n - 1 ? IveTokens.s1 : 0),
                child: _Segment(
                  isDone: i < widget.currentStep,
                  isActive: i == widget.currentStep,
                  sweepCtrl: _sweepCtrl,
                  pulseCtrl: _pulseCtrl,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: IveTokens.s2),
        Row(
          children: List.generate(n, (i) {
            final active = i == widget.currentStep;
            return Expanded(
              child: Text(
                widget.steps[i],
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: IveType.caption.copyWith(
                  color: active ? IveTokens.inkColor : IveTokens.muteColor,
                  fontWeight:
                      active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.isDone,
    required this.isActive,
    required this.sweepCtrl,
    required this.pulseCtrl,
  });

  final bool isDone;
  final bool isActive;
  final AnimationController sweepCtrl;
  final AnimationController pulseCtrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 3,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background track
          DecoratedBox(
            decoration: BoxDecoration(
              color: IveTokens.hairColor,
              borderRadius: BorderRadius.circular(IveTokens.rChip),
            ),
          ),
          // Fill
          if (isDone || isActive)
            AnimatedBuilder(
              animation: isActive ? sweepCtrl : const AlwaysStoppedAnimation(1.0),
              builder: (_, __) {
                final fill = isActive ? sweepCtrl.value : 1.0;
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: fill,
                  child: AnimatedBuilder(
                    animation: isActive ? pulseCtrl : const AlwaysStoppedAnimation(0.0),
                    builder: (_, __) {
                      final pulse = isActive
                          ? (1.0 +
                              0.4 *
                                  Curves.easeOut.transform(
                                    1 - pulseCtrl.value,
                                  ))
                          : 1.0;
                      return Transform.scale(
                        scaleY: pulse.clamp(1.0, 1.5),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: isDone
                                ? IveTokens.accentColor
                                : IveTokens.genieColor,
                            borderRadius:
                                BorderRadius.circular(IveTokens.rChip),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
