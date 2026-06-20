import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ive_text.dart';
import 'ive_tokens.dart';

/// Model for a single tab item.
class SegmentedTab {
  const SegmentedTab({required this.label, this.count});

  /// Display label. Use sentence-case.
  final String label;

  /// Optional item count. Rendered in [IveTokens.muteColor], animated only on change.
  final int? count;
}

/// Sliding-underline tab control.
///
/// Labels in sentence-case. Counts in mute. The underline slides to the
/// selected position over 200 ms using [IveTokens.emphasized] curve.
///
/// Example:
/// ```dart
/// SegmentedTabs(
///   tabs: const [
///     SegmentedTab(label: 'Active', count: 3),
///     SegmentedTab(label: 'History'),
///     SegmentedTab(label: 'Saved'),
///   ],
///   selectedIndex: _tab,
///   onChanged: (i) => setState(() => _tab = i),
/// )
/// ```
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    this.height = 44.0,
  });

  final List<SegmentedTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final tabW = constraints.maxWidth / tabs.length;
        // Indicator geometry
        final indLeft = tabW * selectedIndex + tabW * 0.12;
        final indRight = tabW * (tabs.length - 1 - selectedIndex) + tabW * 0.12;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: height,
              child: Row(
                children: List.generate(tabs.length, (i) {
                  final selected = i == selectedIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onChanged(i);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 150),
                              style: IveType.subhead.copyWith(
                                color: selected
                                    ? IveTokens.inkColor
                                    : IveTokens.muteColor,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                              child: Text(tabs[i].label),
                            ),
                            if (tabs[i].count != null) ...[
                              const SizedBox(width: 5),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  '${tabs[i].count}',
                                  key: ValueKey(tabs[i].count),
                                  style: IveType.caption.copyWith(
                                    color: IveTokens.muteColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Track + sliding indicator
            SizedBox(
              height: 2,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Full-width track
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      color: IveTokens.hairColor,
                    ),
                  ),
                  // Sliding underline
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: IveTokens.emphasized,
                    margin: EdgeInsets.only(left: indLeft, right: indRight),
                    decoration: BoxDecoration(
                      color: IveTokens.accentColor,
                      borderRadius:
                          BorderRadius.circular(IveTokens.rChip),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
