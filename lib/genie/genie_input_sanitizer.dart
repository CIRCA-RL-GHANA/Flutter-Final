/// ═══════════════════════════════════════════════════════════════════════════
/// GenieInputSanitizer
///
/// Recommendation 5 — Input Sanitization at the Edge:
///   • Rejects or normalises code injection attempts (SQL, JS, shell)
///   • Strips adversarial homoglyph substitutions (e.g. Ⓐ → a)
///   • Caps emoji density to prevent flood attacks
///   • Caps raw input length to prevent model token-exhaustion
///   • Returns a SanitizationResult: cleaned text + flagged categories
///
/// All sanitization runs synchronously on the client before any intent
/// resolution or server call. The same logic should be mirrored on the
/// backend AI guard (see ai-input-sanitizer.guard.ts).
/// ═══════════════════════════════════════════════════════════════════════════

/// Categories of input that were sanitized or rejected.
enum SanitizationFlag {
  tooLong,
  injectionAttempt,
  emojiFl,            // emoji flood
  adversarialHomoglyph,
  controlCharacter,
  clean,
}

class SanitizationResult {
  final String cleanedText;
  final List<SanitizationFlag> flags;
  final bool rejected;

  const SanitizationResult({
    required this.cleanedText,
    required this.flags,
    required this.rejected,
  });

  bool get isClean => flags.length == 1 && flags.first == SanitizationFlag.clean;
}

class GenieInputSanitizer {
  GenieInputSanitizer._();

  // ─── Constants ────────────────────────────────────────────────────────────
  static const int _maxLength = 512;
  static const int _maxEmojiDensityPercent = 40; // >40% emoji chars → flood

  // Injection patterns: SQL, JS, shell meta-chars, prompt injection markers
  static final List<RegExp> _injectionPatterns = [
    RegExp(r"('|--|;|\/\*|\*\/|xp_|exec\s+|UNION\s+SELECT)", caseSensitive: false),
    RegExp(r'<script[\s\S]*?>[\s\S]*?<\/script>', caseSensitive: false),
    RegExp(r'javascript\s*:', caseSensitive: false),
    RegExp(r'(on\w+\s*=)', caseSensitive: false),   // onload= etc.
    RegExp(r'(\bignore\b.*\bprevious\b.*\binstruction)', caseSensitive: false),
    RegExp(r'(\bforget\b.*\bsystem\b.*\bprompt\b)', caseSensitive: false),
    RegExp(r'\$\{.*?\}'),     // template literal injection
    RegExp(r'`[^`]*`'),       // backtick command substitution
  ];

  // Common homoglyph substitution map (adversarial phoneme avoidance)
  static final Map<RegExp, String> _homoglyphMap = {
    RegExp(r'[Ａ-Ｚａ-ｚ０-９]'): _normaliseFullWidth, // fullwidth ASCII
    RegExp(r'[ₐₑₒₓₔ]'): 'a',
    RegExp(r'[①②③④⑤⑥⑦⑧⑨⑩]'): _normaliseCircledDigit,
  };

  // Control / non-printable characters
  static final RegExp _controlChars = RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]');

  // Simple emoji range detector
  static final RegExp _emojiRange = RegExp(
    r'[\u{1F300}-\u{1FAFF}]|[\u{2600}-\u{27FF}]|[\u{FE00}-\u{FEFF}]',
    unicode: true,
  );

  // ─── Public API ───────────────────────────────────────────────────────────

  static SanitizationResult sanitize(String raw) {
    final flags = <SanitizationFlag>[];
    String text = raw;

    // 1. Length guard
    if (text.length > _maxLength) {
      text = text.substring(0, _maxLength);
      flags.add(SanitizationFlag.tooLong);
    }

    // 2. Strip control characters
    if (_controlChars.hasMatch(text)) {
      text = text.replaceAll(_controlChars, '');
      flags.add(SanitizationFlag.controlCharacter);
    }

    // 3. Homoglyph normalisation
    for (final entry in _homoglyphMap.entries) {
      if (entry.key.hasMatch(text)) {
        text = text.replaceAllMapped(entry.key, (m) {
          // Use static transformer for each pattern
          if (entry.key.pattern.contains('Ａ')) {
            return _normaliseFullWidth(m[0]!);
          }
          if (entry.key.pattern.contains('①')) {
            return _normaliseCircledDigit(m[0]!);
          }
          return entry.value;
        });
        flags.add(SanitizationFlag.adversarialHomoglyph);
      }
    }

    // 4. Injection detection — reject outright
    for (final pattern in _injectionPatterns) {
      if (pattern.hasMatch(text)) {
        return SanitizationResult(
          cleanedText: '',
          flags: [SanitizationFlag.injectionAttempt],
          rejected: true,
        );
      }
    }

    // 5. Emoji flood check
    final emojiCount = _emojiRange.allMatches(text).length;
    if (text.isNotEmpty &&
        (emojiCount / text.length * 100) > _maxEmojiDensityPercent) {
      // Strip excess emojis — keep first 3
      int kept = 0;
      text = text.replaceAllMapped(_emojiRange, (m) {
        if (kept < 3) {
          kept++;
          return m[0]!;
        }
        return '';
      });
      flags.add(SanitizationFlag.emojiFl);
    }

    // 6. Final trim
    text = text.trim();

    if (flags.isEmpty) flags.add(SanitizationFlag.clean);
    return SanitizationResult(
        cleanedText: text, flags: flags, rejected: false);
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// Normalise Unicode full-width characters to ASCII equivalents.
  static String _normaliseFullWidth(String char) {
    final code = char.codeUnitAt(0);
    if (code >= 0xFF01 && code <= 0xFF5E) {
      return String.fromCharCode(code - 0xFEE0);
    }
    return char;
  }

  /// Normalise circled digit characters (①→1, ②→2 …).
  static String _normaliseCircledDigit(String char) {
    const circled = '①②③④⑤⑥⑦⑧⑨⑩';
    final idx = circled.indexOf(char);
    return idx >= 0 ? '${idx + 1}' : char;
  }
}
