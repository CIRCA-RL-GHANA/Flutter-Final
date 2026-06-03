import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ive_text.dart';
import 'ive_tokens.dart';

/// Quiet, focused text field. Hairline border by default, accent on focus.
/// No drop-shadow, no rounded "pill" — a precise rectangle with a 10px radius.
class IveTextField extends StatelessWidget {
  const IveTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.helper,
    this.errorText,
    this.prefix,
    this.suffix,
    this.obscure = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.autofocus = false,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? helper;
  final String? errorText;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscure;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool autofocus;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: IveType.subhead),
          const SizedBox(height: IveTokens.s2),
        ],
        TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscure,
          enabled: enabled,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: obscure ? 1 : maxLines,
          minLines: minLines,
          maxLength: maxLength,
          autofocus: autofocus,
          autofillHints: autofillHints,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          onTap: onTap,
          readOnly: readOnly,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          style: IveType.body,
          cursorColor: IveTokens.accent,
          cursorWidth: 1.5,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: IveType.body.copyWith(color: IveTokens.labelTertiary),
            helperText: helper,
            helperStyle: IveType.footnote,
            errorText: errorText,
            errorStyle:
                IveType.footnote.copyWith(color: IveTokens.danger),
            prefixIcon: prefix,
            suffixIcon: suffix,
            filled: true,
            fillColor: IveTokens.surface,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: IveTokens.s4, vertical: IveTokens.s4),
            border: const OutlineInputBorder(
              borderRadius: IveTokens.brSm,
              borderSide: IveTokens.hairlineSide,
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: IveTokens.brSm,
              borderSide: IveTokens.hairlineSide,
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: IveTokens.brSm,
              borderSide: BorderSide(color: IveTokens.accent, width: 1.5),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: IveTokens.brSm,
              borderSide: BorderSide(color: IveTokens.danger, width: 1),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: IveTokens.brSm,
              borderSide: BorderSide(color: IveTokens.danger, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: IveTokens.brSm,
              borderSide: BorderSide(
                  color: IveTokens.hairline.withValues(alpha: 0.4)),
            ),
            counterText: '',
          ),
        ),
      ],
    );
  }
}
