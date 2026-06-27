import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ive_text.dart';
import 'ive_tokens.dart';

/// Form-aware variant of [IveTextField].
///
/// Identical styling to [IveTextField] but wraps [TextFormField] so it
/// participates in a [Form]  supports [validator] and [onSaved].
class IveTextFormField extends StatelessWidget {
  const IveTextFormField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.helper,
    this.prefix,
    this.suffix,
    this.obscure = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.maxLength,
    this.autofocus = false,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
    this.onSaved,
    this.onTap,
    this.readOnly = false,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.initialValue,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? helper;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscure;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? maxLength;
  final bool autofocus;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldSetter<String>? onSaved;
  final VoidCallback? onTap;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final FormFieldValidator<String>? validator;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: IveType.subhead),
          const SizedBox(height: IveTokens.s2),
        ],
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          focusNode: focusNode,
          obscureText: obscure,
          enabled: enabled,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: obscure ? 1 : maxLines,
          maxLength: maxLength,
          autofocus: autofocus,
          autofillHints: autofillHints,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          onSaved: onSaved,
          onTap: onTap,
          readOnly: readOnly,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          validator: validator,
          style: IveType.body,
          cursorColor: IveTokens.accent,
          cursorWidth: 1.5,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: IveType.body.copyWith(color: IveTokens.labelTertiary),
            helperText: helper,
            helperStyle: IveType.footnote,
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
