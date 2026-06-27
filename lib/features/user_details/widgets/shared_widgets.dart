/// 
/// Shared Widgets for User Details Module
/// Reusable components: collapsible sections, edit fields, status badges, etc.
/// 
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/design/ive.dart';

//  Collapsible Section 

class CollapsibleSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final Widget child;
  final bool initiallyExpanded;

  const CollapsibleSection({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
    required this.child,
    this.initiallyExpanded = true,
  });

  @override
  State<CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<CollapsibleSection>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late AnimationController _controller;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeInOut));
    if (_expanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.selectionClick();
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _toggle,
          borderRadius: BorderRadius.circular(IveTokens.rContainer),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Row(
              children: [
                Icon(widget.icon, size: 20, color: widget.iconColor ?? IveTokens.accentColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.title,
                    style: IveType.callout.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: const Icon(Icons.expand_more, size: 20, color: IveTokens.muteColor),
                ),
              ],
            ),
          ),
        ),
        ClipRect(
          child: SizeTransition(
            sizeFactor: _heightFactor,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}

//  Detail Row 

class DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool editable;

  const DetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    this.onTap,
    this.editable = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(IveTokens.rContainer),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: IveTokens.muteColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: IveType.caption.copyWith(color: IveTokens.muteColor),
                  ),
                  const SizedBox(height: 2),
                  Text(value, style: IveType.body),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (editable && onTap != null)
              const Icon(Icons.edit, size: 14, color: IveTokens.muteColor),
          ],
        ),
      ),
    );
  }
}

//  Status Badge 

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(IveTokens.rAtom),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

//  Settings Toggle 

class SettingsToggle extends StatelessWidget {
  final String label;
  final String? subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;

  const SettingsToggle({
    super.key,
    required this.label,
    this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: value ? (activeColor ?? IveTokens.accentColor) : IveTokens.muteColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: IveType.callout.copyWith(fontWeight: FontWeight.w500)),
                if (subtitle != null)
                  Text(subtitle!, style: IveType.caption.copyWith(color: IveTokens.muteColor)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onChanged(v);
            },
            activeThumbColor: activeColor ?? IveTokens.accentColor,
          ),
        ],
      ),
    );
  }
}

//  Section Card 

class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;

  const SectionCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: IveTokens.raisedColor,
        borderRadius: BorderRadius.circular(IveTokens.rContainer),
        border: Border.all(color: borderColor ?? IveTokens.hairColor, width: 1),
      ),
      child: child,
    );
  }
}

//  Module Header (Back + Title + Actions) 

class ModuleHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Color? contextColor;

  const ModuleHeader({
    super.key,
    required this.title,
    this.actions,
    this.contextColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: IveTokens.voidColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: Row(
        children: [
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 22),
            color: IveTokens.inkColor,
            onPressed: () => Navigator.pop(context),
          ),
          if (contextColor != null)
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: contextColor,
              ),
            ),
        ],
      ),
      leadingWidth: contextColor != null ? 70 : 56,
      title: Text(title, style: IveType.title3),
      centerTitle: true,
      actions: actions,
    );
  }
}

//  Edit Field Modal 

class EditFieldModal extends StatefulWidget {
  final String title;
  final String initialValue;
  final String? hint;
  final int maxLines;
  final ValueChanged<String> onSave;

  const EditFieldModal({
    super.key,
    required this.title,
    required this.initialValue,
    this.hint,
    this.maxLines = 1,
    required this.onSave,
  });

  @override
  State<EditFieldModal> createState() => _EditFieldModalState();
}

class _EditFieldModalState extends State<EditFieldModal> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: IveTokens.muteColor.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(IveTokens.rChip),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(widget.title, style: IveType.title3),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: widget.maxLines,
            autofocus: true,
            style: IveType.body,
            cursorColor: IveTokens.accentColor,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: IveType.body.copyWith(color: IveTokens.muteColor),
              filled: true,
              fillColor: IveTokens.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(IveTokens.rContainer),
                borderSide: const BorderSide(color: IveTokens.hairColor, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(IveTokens.rContainer),
                borderSide: const BorderSide(color: IveTokens.hairColor, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(IveTokens.rContainer),
                borderSide: const BorderSide(color: IveTokens.accentColor, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          IveButton.primary(
            label: 'Save',
            onPressed: () {
              widget.onSave(_controller.text.trim());
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

//  Context Type Gradient 

Color contextTypeColor(dynamic entityType) {
  final name = entityType.toString().split('.').last;
  switch (name) {
    case 'personal': return IveTokens.accentColor;
    case 'business': return const Color(0xFF8B5CF6);
    case 'branch': return IveTokens.okColor;
    default: return IveTokens.muteColor;
  }
}

LinearGradient contextTypeGradient(dynamic entityType) {
  final c = contextTypeColor(entityType);
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [c.withValues(alpha: 0.08), c.withValues(alpha: 0.02)],
  );
}
