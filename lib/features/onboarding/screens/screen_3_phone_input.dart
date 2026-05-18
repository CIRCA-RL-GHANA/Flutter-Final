import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/design/ive.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/data/countries.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/responsive.dart';
import '../providers/phone_auth_provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/buttons.dart';
import '../widgets/onboarding_header.dart';


// OS palette ï¿½ mirrors splash / welcome
const Color _kBg        = IveTokens.bg;
const Color _kSurface   = IveTokens.surface;
const Color _kBorder    = IveTokens.hairline;
const Color _kAccent    = IveTokens.accent;
const Color _kAccentDim = IveTokens.accentPressed;
const Color _kText      = IveTokens.label;
const Color _kTextDim   = IveTokens.labelSecondary;
const Color _kTextMuted = IveTokens.labelTertiary;
/// Screen 3: Phone Number Input (Intelligent)
/// Frictionless number entry with predictive intelligence
class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _phoneController;
  late AnimationController _waveController;
  final Debouncer _debouncer = Debouncer(milliseconds: 300);
  Timer? _emailSuggestionTimer;
  bool _showEmailSuggestion = false;

  // Canonical country catalogue — all ISO 3166-1 entries with E.164
  // calling codes. Source of truth: lib/core/data/countries.dart.
  final List<Country> _countries = kCountries;

  late Country _selectedCountry;

  // Validation states
  _ValidationState _validationState = _ValidationState.empty;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    // Default to the primary market (Ghana); user may change in picker.
    _selectedCountry =
        countryByIso('GH') ?? _countries.first;

    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Show email suggestion after 10s of inactivity
    _emailSuggestionTimer = Timer(
      const Duration(seconds: 10),
      () {
        if (mounted && _phoneController.text.isEmpty) {
          setState(() => _showEmailSuggestion = true);
        }
      },
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _waveController.dispose();
    _debouncer.cancel();
    _emailSuggestionTimer?.cancel();
    super.dispose();
  }

  void _onPhoneChanged(String value) {
    // Reset email suggestion timer
    _emailSuggestionTimer?.cancel();
    _showEmailSuggestion = false;
    _emailSuggestionTimer = Timer(
      const Duration(seconds: 10),
      () {
        if (mounted && _phoneController.text.isEmpty) {
          setState(() => _showEmailSuggestion = true);
        }
      },
    );

    if (value.isEmpty) {
      setState(() => _validationState = _ValidationState.empty);
      return;
    }

    setState(() => _validationState = _ValidationState.typing);

    _debouncer.run(() {
      final isValid = PhoneFormatter.isValid(value, _selectedCountry.iso);
      setState(() {
        _validationState =
            isValid ? _ValidationState.valid : _ValidationState.invalid;
      });
    });
  }

  Future<void> _onContinue() async {
    final phoneAuth = context.read<PhoneAuthProvider>();
    final onboarding = context.read<OnboardingProvider>();

    phoneAuth.setPhoneNumber(_phoneController.text);
    phoneAuth.setCountry(_selectedCountry.dialCode, _selectedCountry.iso);

    // Check number existence
    final result = await phoneAuth.checkNumber();

    if (!mounted) return;

    if (result == NumberCheckResult.existingUser) {
      // Existing user â†’ welcome back flow
      onboarding.setReturningUser(true);
      Navigator.of(context).pushNamed(AppRoutes.welcomeBack);
    } else if (result == NumberCheckResult.newUser ||
        result == NumberCheckResult.valid) {
      // New user â†’ send OTP
      await phoneAuth.sendOtp();
      if (!mounted) return;

      onboarding.setPhoneData(
        _phoneController.text,
        _selectedCountry.dialCode,
      );

      Navigator.of(context).pushNamed(
        AppRoutes.otpVerification,
        arguments: {
          'phoneNumber': _phoneController.text,
          'countryCode': _selectedCountry.dialCode,
        },
      );
    } else {
      // Error
      _showError(phoneAuth.error ?? AppStrings.networkErrorNumber);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: IveTokens.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: IveTokens.brMd),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CountryPickerSheet(
        countries: _countries,
        selectedCountry: _selectedCountry,
        onSelect: (country) {
          setState(() {
            _selectedCountry = country;
            _phoneController.clear();
            _validationState = _ValidationState.empty;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<PhoneAuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: IveTokens.bg,
      body: SafeArea(
        child: Responsive.constrained(
          child: Column(
            children: [
              OnboardingHeader(
                title: AppStrings.enterPhoneTitle,
                subtitle: AppStrings.enterPhoneSubtitle,
                currentStep: 1,
                totalSteps: 8,
                onBack: () => Navigator.pop(context),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Country selector
                      GestureDetector(
                        onTap: _showCountryPicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: IveTokens.surface,
                            borderRadius: IveTokens.brXs,
                            border: Border.all(color: IveTokens.hairline),
                          ),
                          child: Row(
                            children: [
                              CountryFlag(
                                iso: _selectedCountry.iso,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedCountry.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: IveTokens.label,
                                  ),
                                ),
                              ),
                              Text(
                                _selectedCountry.dialCode,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: IveTokens.labelSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: IveTokens.labelTertiary,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Phone input field
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: IveTokens.brXs,
                          border: Border.all(
                            color: _getBorderColor(),
                            width: _validationState == _ValidationState.empty
                                ? 1
                                : 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Dial code
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                              decoration: BoxDecoration(
                                color: IveTokens.surface,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(IveTokens.rXs),
                                  bottomLeft: Radius.circular(IveTokens.rXs),
                                ),
                              ),
                              child: Text(
                                _selectedCountry.dialCode,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: IveTokens.label,
                                ),
                              ),
                            ),

                            // Phone number input
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(
                                    PhoneFormatter.maxLength(
                                        _selectedCountry.iso),
                                  ),
                                ],
                                onChanged: _onPhoneChanged,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Phone number',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 18,
                                  ),
                                ),
                              ),
                            ),

                            // Validation icon
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: _buildValidationIcon(),
                            ),
                          ],
                        ),
                      ),

                      // Validation message
                      if (_validationState == _ValidationState.invalid)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 4),
                          child: Text(
                            AppStrings.invalidNumber,
                            style: const TextStyle(
                              fontSize: 12,
                              color: IveTokens.danger,
                            ),
                          ),
                        ),

                      const SizedBox(height: 32),

                      // Wave illustration area (placeholder)
                      if (Responsive.isDesktop(context))
                        Center(
                          child: AnimatedBuilder(
                            animation: _waveController,
                            builder: (context, child) {
                              return Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: _validationState ==
                                          _ValidationState.valid
                                      ? IveTokens.success.withValues(alpha: 0.1)
                                      : IveTokens.accent
                                          .withValues(alpha: 0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.phone_android,
                                  size: 80,
                                  color: _validationState ==
                                          _ValidationState.valid
                                      ? IveTokens.success.withValues(alpha: 0.5)
                                      : IveTokens.accent
                                          .withValues(alpha: 0.2),
                                ),
                              );
                            },
                          ),
                        ),

                      // Email suggestion
                      if (_showEmailSuggestion)
                        AnimatedOpacity(
                          opacity: _showEmailSuggestion ? 1.0 : 0.0,
                          duration: IveTokens.dFast,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: SecondaryButton(
                              text: AppStrings.useEmailInstead,
                              onPressed: () {
                                // Show email input modal
                                _showEmailInputModal();
                              },
                              underline: true,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Bottom action button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: PrimaryButton(
                  text: AppStrings.continueBtn,
                  icon: Icons.arrow_forward,
                  isLoading: isLoading,
                  onPressed: _validationState == _ValidationState.valid
                      ? _onContinue
                      : null,
                  margin: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBorderColor() {
    switch (_validationState) {
      case _ValidationState.empty:
        return IveTokens.hairline;
      case _ValidationState.typing:
        return IveTokens.accent;
      case _ValidationState.valid:
        return IveTokens.success;
      case _ValidationState.invalid:
        return IveTokens.danger;
    }
  }

  Widget _buildValidationIcon() {
    switch (_validationState) {
      case _ValidationState.empty:
        return const SizedBox(width: 20);
      case _ValidationState.typing:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: _kAccent,
          ),
        );
      case _ValidationState.valid:
        return const Icon(
          Icons.check_circle,
          size: 20,
          color: IveTokens.success,
        );
      case _ValidationState.invalid:
        return const Icon(
          Icons.error,
          size: 20,
          color: IveTokens.danger,
        );
    }
  }

  void _showEmailInputModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Use email instead',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _kText,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter your email address',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                text: 'Continue with Email',
                onPressed: () {
                  Navigator.pop(context);
                  // Handle email flow
                },
                margin: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

enum _ValidationState { empty, typing, valid, invalid }

// ─────────────────────────────────────────────────────────────
// Country picker sheet — global, complete (~250 entries),
// sectioned, searchable. Designed to feel inevitable: a quiet
// frame, generous touch targets, sticky letter headings, and
// a pinned "Popular" block for the markets we serve first.
// ─────────────────────────────────────────────────────────────
class _CountryPickerSheet extends StatefulWidget {
  final List<Country> countries;
  final Country selectedCountry;
  final ValueChanged<Country> onSelect;

  const _CountryPickerSheet({
    required this.countries,
    required this.selectedCountry,
    required this.onSelect,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

/// One row in the rendered list. Either a sticky section heading
/// or a selectable country tile.
sealed class _Row {
  const _Row();
}

class _HeaderRow extends _Row {
  final String label;
  const _HeaderRow(this.label);
}

class _CountryRow extends _Row {
  final Country country;
  const _CountryRow(this.country);
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocus;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocus = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  /// Compose the visible list. When the search box is empty we render
  /// a "Popular" block on top, then the entire catalogue with sticky
  /// A–Z headers. While the user is typing we collapse to a single
  /// flat result list to keep matches dense and scannable.
  List<_Row> _composeRows() {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) {
      final rows = <_Row>[];

      // Popular block
      final popular = kPopularCountries;
      if (popular.isNotEmpty) {
        rows.add(const _HeaderRow('Popular'));
        rows.addAll(popular.map(_CountryRow.new));
      }

      // Full A–Z with letter sections (countries list is pre-sorted by name).
      rows.add(const _HeaderRow('All countries'));
      String? lastInitial;
      for (final c in widget.countries) {
        final initial = c.name.isEmpty
            ? '#'
            : _firstAsciiLetter(c.name).toUpperCase();
        if (initial != lastInitial) {
          rows.add(_HeaderRow(initial));
          lastInitial = initial;
        }
        rows.add(_CountryRow(c));
      }
      return rows;
    }

    // Search mode: rank exact code/iso matches first, then name matches.
    final qNoPlus = q.startsWith('+') ? q.substring(1) : q;
    final exactCode = <Country>[];
    final startsWith = <Country>[];
    final contains = <Country>[];
    for (final c in widget.countries) {
      final name = c.name.toLowerCase();
      final iso = c.iso.toLowerCase();
      final code = c.dialCode.replaceFirst('+', '');
      if (code == qNoPlus || iso == q) {
        exactCode.add(c);
      } else if (name.startsWith(q) || code.startsWith(qNoPlus)) {
        startsWith.add(c);
      } else if (name.contains(q) || iso.contains(q)) {
        contains.add(c);
      }
    }
    final ordered = <Country>[...exactCode, ...startsWith, ...contains];
    if (ordered.isEmpty) return const <_Row>[];
    return <_Row>[
      _HeaderRow('${ordered.length} result${ordered.length == 1 ? '' : 's'}'),
      ...ordered.map(_CountryRow.new),
    ];
  }

  /// Returns the first ASCII letter in [s], or '#' if none. Used to
  /// place names beginning with diacritics under their unaccented
  /// initial (Åland → A, Côte d'Ivoire → C, Réunion → R).
  static String _firstAsciiLetter(String s) {
    const folds = <String, String>{
      'Å': 'A', 'Á': 'A', 'À': 'A', 'Â': 'A', 'Ä': 'A', 'Ã': 'A',
      'Ç': 'C', 'Č': 'C',
      'É': 'E', 'È': 'E', 'Ê': 'E', 'Ë': 'E',
      'Í': 'I', 'Ì': 'I', 'Î': 'I', 'Ï': 'I',
      'Ñ': 'N',
      'Ó': 'O', 'Ò': 'O', 'Ô': 'O', 'Ö': 'O', 'Õ': 'O', 'Ø': 'O',
      'Ś': 'S', 'Š': 'S',
      'Ú': 'U', 'Ù': 'U', 'Û': 'U', 'Ü': 'U',
      'Ý': 'Y',
      'Ž': 'Z',
    };
    for (var i = 0; i < s.length; i++) {
      final ch = s[i];
      final folded = folds[ch] ?? ch;
      final code = folded.codeUnitAt(0);
      if ((code >= 0x41 && code <= 0x5A) || (code >= 0x61 && code <= 0x7A)) {
        return folded;
      }
    }
    return '#';
  }

  @override
  Widget build(BuildContext context) {
    final rows = _composeRows();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.86,
      minChildSize: 0.5,
      maxChildSize: 0.94,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: IveTokens.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(
            top: BorderSide(color: IveTokens.hairline, width: 0.5),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Column(
              children: [
                // Grabber
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: IveTokens.hairline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Title row
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Select country',
                          style: TextStyle(
                            color: IveTokens.label,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.close_rounded),
                        color: IveTokens.labelSecondary,
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                ),

                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: IveTextField(
                    controller: _searchController,
                    hint: 'Search country, code, or +dial',
                    prefix: const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: IveTokens.labelSecondary,
                    ),
                    suffix: _query.isEmpty
                        ? null
                        : IconButton(
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(
                              Icons.cancel_rounded,
                              size: 18,
                              color: IveTokens.labelTertiary,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          ),
                    textInputAction: TextInputAction.search,
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),

                const SizedBox(height: 4),
                const Divider(height: 1, color: IveTokens.hairline),

                // Rows
                Expanded(
                  child: rows.isEmpty
                      ? const _EmptyResults()
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: rows.length,
                          itemBuilder: (context, i) {
                            final row = rows[i];
                            if (row is _HeaderRow) {
                              return _SectionHeader(label: row.label);
                            }
                            if (row is _CountryRow) {
                              final c = row.country;
                              final selected =
                                  c.iso == widget.selectedCountry.iso;
                              return _CountryTile(
                                country: c,
                                selected: selected,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  widget.onSelect(c);
                                },
                              );
                            }
                            return const SizedBox.shrink();
                          },
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

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: IveTokens.surface,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: IveTokens.labelTertiary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _CountryTile extends StatelessWidget {
  final Country country;
  final bool selected;
  final VoidCallback onTap;

  const _CountryTile({
    required this.country,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color: selected
            ? IveTokens.accent.withValues(alpha: 0.07)
            : Colors.transparent,
        child: Row(
          children: [
            CountryFlag(iso: country.iso, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                country.name,
                style: TextStyle(
                  color: IveTokens.label,
                  fontSize: 16,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: -0.1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              country.dialCode,
              style: TextStyle(
                color: selected
                    ? IveTokens.accent
                    : IveTokens.labelSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 20,
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: IveTokens.accent,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.public_off_rounded,
              size: 40,
              color: IveTokens.labelTertiary,
            ),
            SizedBox(height: 12),
            Text(
              'No country matches that search',
              style: TextStyle(
                color: IveTokens.labelSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
