/// 
/// GenieQuickCommandBar  Bottom Chip Row
///
/// Horizontally scrollable row of contextual quick-action chips.
/// Chips are RBAC-filtered and role-specific. Snaps to center on scroll.
/// Minimum 4848 dp touch target on each chip.
/// 
library;

import 'package:flutter/material.dart';
import '../../core/design/ive_tokens.dart';
import '../genie_intent.dart';
import '../genie_rbac_enforcer.dart';
import '../genie_tactile_actions.dart';
import '../../features/prompt/models/rbac_models.dart';

class GenieQuickCommandBar extends StatelessWidget {
  final UserRole role;
  final void Function(GenieIntent) onChipTap;

  const GenieQuickCommandBar({
    super.key,
    required this.role,
    required this.onChipTap,
  });

  @override
  Widget build(BuildContext context) {
    final chips = GenieRBACEnforcer.getDefaultChips(role);

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final chip = chips[index];
          return _QuickChip(
            chip: chip,
            onTap: () {
              GenieTactileActions.onTap();
              onChipTap(chip.intent);
            },
          );
        },
      ),
    );
  }
}

class _QuickChip extends StatefulWidget {
  final GenieChip chip;
  final VoidCallback onTap;

  const _QuickChip({required this.chip, required this.onTap});

  @override
  State<_QuickChip> createState() => _QuickChipState();
}

class _QuickChipState extends State<_QuickChip> {
  bool _pressed = false;

  Color get _accentColor => IveTokens.moduleColor(widget.chip.module.name);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${widget.chip.emoji} ${widget.chip.label}',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.95 : 1.0,
          duration: IveTokens.dMicro,
          child: Container(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _pressed
                  ? _accentColor.withValues(alpha: 0.15)
                  : _accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _accentColor.withValues(alpha: _pressed ? 0.5 : 0.25),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.chip.emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  widget.chip.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _accentColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
