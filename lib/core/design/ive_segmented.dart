import 'package:flutter/material.dart';
import 'ive_text.dart';
import 'ive_tokens.dart';

/// Two-or-more segment control. The selection slides with [IveTokens.emphasized].
class IveSegmented<T> extends StatelessWidget {
  const IveSegmented({
    super.key,
    required this.value,
    required this.onChanged,
    required this.segments,
  });

  final T value;
  final ValueChanged<T> onChanged;
  final List<IveSegment<T>> segments;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: IveTokens.surface,
        borderRadius: IveTokens.brSm,
        border: IveTokens.cardBorder,
      ),
      child: Row(
        children: [
          for (final s in segments)
            Expanded(
              child: _Segment<T>(
                segment: s,
                selected: s.value == value,
                onTap: () => onChanged(s.value),
              ),
            ),
        ],
      ),
    );
  }
}

class IveSegment<T> {
  const IveSegment({required this.value, required this.label, this.icon});
  final T value;
  final String label;
  final IconData? icon;
}

class _Segment<T> extends StatelessWidget {
  const _Segment({required this.segment, required this.selected, required this.onTap});
  final IveSegment<T> segment;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: IveTokens.dFast,
        curve: IveTokens.emphasized,
        height: 32,
        decoration: BoxDecoration(
          color: selected ? IveTokens.surfaceRaised : Colors.transparent,
          borderRadius: BorderRadius.circular(IveTokens.rXs + 2),
          border: selected
              ? Border.all(color: IveTokens.hairline, width: 1)
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (segment.icon != null) ...[
              Icon(segment.icon,
                  size: 14,
                  color:
                      selected ? IveTokens.label : IveTokens.labelSecondary),
              const SizedBox(width: 6),
            ],
            Text(
              segment.label,
              style: IveType.subhead.copyWith(
                color: selected ? IveTokens.label : IveTokens.labelSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
