import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive.dart';
import '../../../core/data/countries.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/app_toast.dart';
import '../providers/phone_auth_provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_header.dart';
import '../widgets/onboarding_loading_overlay.dart';

/// Screen 04 — Phone number entry, step 01/08.
class PhoneInputScreen extends StatefulWidget {
  final bool isLoginMode;
  const PhoneInputScreen({super.key, this.isLoginMode = false});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  late TextEditingController _phoneController;
  final FocusNode _phoneFocus = FocusNode();
  final List<Country> _countries = kCountries;
  late Country _selectedCountry;
  _ValidationState _validationState = _ValidationState.empty;
  final Debouncer _debouncer = Debouncer(milliseconds: 300);
  // Stays true after the API resolves so the overlay persists until the new
  // screen actually mounts (provider resets isLoading before navigation).
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _selectedCountry = countryByIso('GH') ?? _countries.first;
    _phoneFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
    _debouncer.cancel();
    super.dispose();
  }

  void _onPhoneChanged(String value) {
    if (value.isEmpty) {
      setState(() => _validationState = _ValidationState.empty);
      return;
    }
    setState(() => _validationState = _ValidationState.typing);
    _debouncer.run(() {
      final isValid =
          PhoneFormatter.isValid(value, _selectedCountry.iso);
      if (!mounted) return;
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

    final result = await phoneAuth.checkNumber();
    if (!mounted) return;

    if (result == NumberCheckResult.existingUser) {
      onboarding.setReturningUser(true);
      if (!widget.isLoginMode) {
        AppToast.info(
            context, 'You already have an account. Signing you in.');
      }
      setState(() => _navigating = true);
      Navigator.of(context).pushNamed(AppRoutes.welcomeBack);
    } else if (result == NumberCheckResult.newUser ||
        result == NumberCheckResult.valid) {
      if (widget.isLoginMode) {
        _showCreateAccountConsent(phoneAuth, onboarding);
        return;
      }
      final sent = await phoneAuth.sendOtp();
      if (!mounted) return;
      if (!sent) {
        AppToast.error(
            context, phoneAuth.error ?? AppStrings.networkErrorNumber);
        return;
      }
      onboarding.setPhoneData(
          _phoneController.text, _selectedCountry.dialCode);
      setState(() => _navigating = true);
      Navigator.of(context).pushNamed(
        AppRoutes.otpVerification,
        arguments: {
          'phoneNumber': _phoneController.text,
          'countryCode': _selectedCountry.dialCode,
        },
      );
    } else {
      AppToast.error(
          context, phoneAuth.error ?? AppStrings.networkErrorNumber);
    }
  }

  void _showCreateAccountConsent(
      PhoneAuthProvider phoneAuth, OnboardingProvider onboarding) {
    final phone = phoneAuth.formattedNumber;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: IveTokens.surface,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(IveTokens.rSm)),
          border: Border(top: BorderSide(color: IveTokens.hairline)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: IveTokens.hairline2,
                  borderRadius:
                      BorderRadius.circular(IveTokens.rPill),
                ),
              ),
            ),
            Text('No account found', style: IveType.title3),
            const SizedBox(height: 8),
            Text(
              'There\'s no account linked to $phone. Would you like to create one?',
              style: IveType.callout
                  .copyWith(color: IveTokens.ink2),
            ),
            const SizedBox(height: 28),
            IveButton.primary(
              label: 'Create an account',
              icon: Icons.arrow_forward,
              onPressed: () async {
                Navigator.pop(context);
                final sent = await phoneAuth.sendOtp();
                if (!mounted) return;
                if (!sent) {
                  AppToast.error(context,
                      phoneAuth.error ?? AppStrings.networkErrorNumber);
                  return;
                }
                onboarding.setPhoneData(
                    _phoneController.text, _selectedCountry.dialCode);
                Navigator.of(context).pushNamed(
                  AppRoutes.otpVerification,
                  arguments: {
                    'phoneNumber': _phoneController.text,
                    'countryCode': _selectedCountry.dialCode,
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            IveButton.secondary(
              label: 'Try a different number',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
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

  Color get _borderColor {
    switch (_validationState) {
      case _ValidationState.empty:
        return _phoneFocus.hasFocus
            ? IveTokens.accent
            : IveTokens.hairline;
      case _ValidationState.typing:
        return IveTokens.accent;
      case _ValidationState.valid:
        return IveTokens.accent;
      case _ValidationState.invalid:
        return IveTokens.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<PhoneAuthProvider>().isLoading;

    return OnboardingLoadingOverlay(
      isLoading: isLoading || _navigating,
      child: Scaffold(
        backgroundColor: IveTokens.bg,
        body: SafeArea(
          child: Responsive.constrained(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OnboardingHeader(
                  title: 'What\'s your number?',
                  subtitle:
                      'We\'ll text a verification code to confirm it\'s you.',
                  currentStep: 1,
                  totalSteps: 8,
                ),

                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Country code + phone number side by side
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.center,
                          children: [
                            // Country pill
                            GestureDetector(
                              onTap: _showCountryPicker,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 15),
                                decoration: BoxDecoration(
                                  color: IveTokens.surface,
                                  border: Border.all(
                                      color: IveTokens.hairline),
                                  borderRadius:
                                      BorderRadius.circular(
                                          IveTokens.rSm),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CountryFlag(
                                        iso: _selectedCountry.iso,
                                        size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      _selectedCountry.dialCode,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: IveTokens.ink,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 16,
                                        color: IveTokens.mute),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Phone number field
                            Expanded(
                              child: AnimatedContainer(
                                duration: IveTokens.dFast,
                                decoration: BoxDecoration(
                                  color: IveTokens.surface,
                                  border: Border.all(
                                    color: _borderColor,
                                    width:
                                        _validationState !=
                                                _ValidationState.empty
                                            ? 1.5
                                            : 1,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                          IveTokens.rSm),
                                ),
                                child: TextField(
                                  controller: _phoneController,
                                  focusNode: _phoneFocus,
                                  keyboardType:
                                      TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter
                                        .digitsOnly,
                                    LengthLimitingTextInputFormatter(
                                      PhoneFormatter.maxLength(
                                          _selectedCountry.iso),
                                    ),
                                  ],
                                  onChanged: _onPhoneChanged,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: IveTokens.ink,
                                    letterSpacing: 0.5,
                                  ),
                                  decoration:
                                      const InputDecoration(
                                    hintText: '24 555 0192',
                                    hintStyle: TextStyle(
                                        color: IveTokens.mute,
                                        fontSize: 16),
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Country · ${_selectedCountry.name} (${_selectedCountry.iso})',
                          style: const TextStyle(
                            fontSize: 12,
                            color: IveTokens.mute,
                          ),
                        ),

                        if (_validationState ==
                            _ValidationState.invalid) ...[
                          const SizedBox(height: 8),
                          const Text(
                            AppStrings.invalidNumber,
                            style: TextStyle(
                              fontSize: 12,
                              color: IveTokens.danger,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: IveButton.primary(
                    label: AppStrings.continueBtn,
                    isLoading: isLoading,
                    onPressed:
                        _validationState == _ValidationState.valid
                            ? _onContinue
                            : null,
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

enum _ValidationState { empty, typing, valid, invalid }

// ── Country picker sheet ─────────────────────────────────────────────────────

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
  State<_CountryPickerSheet> createState() =>
      _CountryPickerSheetState();
}

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
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_Row> _composeRows() {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) {
      final rows = <_Row>[];
      final popular = kPopularCountries;
      if (popular.isNotEmpty) {
        rows.add(const _HeaderRow('Popular'));
        rows.addAll(popular.map(_CountryRow.new));
      }
      rows.add(const _HeaderRow('All countries'));
      String? lastInitial;
      for (final c in widget.countries) {
        final initial =
            c.name.isEmpty ? '#' : c.name[0].toUpperCase();
        if (initial != lastInitial) {
          rows.add(_HeaderRow(initial));
          lastInitial = initial;
        }
        rows.add(_CountryRow(c));
      }
      return rows;
    }
    final qNoPlus = q.startsWith('+') ? q.substring(1) : q;
    final results = <Country>[];
    for (final c in widget.countries) {
      final name = c.name.toLowerCase();
      final iso = c.iso.toLowerCase();
      final code = c.dialCode.replaceFirst('+', '');
      if (code == qNoPlus ||
          iso == q ||
          name.startsWith(q) ||
          name.contains(q) ||
          code.startsWith(qNoPlus)) {
        results.add(c);
      }
    }
    if (results.isEmpty) return const [];
    return [
      _HeaderRow(
          '${results.length} result${results.length == 1 ? '' : 's'}'),
      ...results.map(_CountryRow.new),
    ];
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
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(10)),
          border: Border(
              top: BorderSide(color: IveTokens.hairline, width: 0.5)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: IveTokens.hairline,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(20, 8, 12, 8),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Select country',
                          style: TextStyle(
                            color: IveTokens.ink,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        color: IveTokens.ink2,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: IveTextField(
                    controller: _searchController,
                    hint: 'Search country or code',
                    prefix: const Icon(Icons.search_rounded,
                        size: 20, color: IveTokens.ink2),
                    suffix: _query.isEmpty
                        ? null
                        : IconButton(
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.cancel_rounded,
                                size: 18, color: IveTokens.mute),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                const Divider(height: 1, color: IveTokens.hairline),
                Expanded(
                  child: rows.isEmpty
                      ? const Center(
                          child: Text('No matches',
                              style: TextStyle(
                                  color: IveTokens.mute,
                                  fontSize: 15)),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding:
                              const EdgeInsets.only(bottom: 16),
                          itemCount: rows.length,
                          itemBuilder: (context, i) {
                            final row = rows[i];
                            if (row is _HeaderRow) {
                              return Container(
                                width: double.infinity,
                                color: IveTokens.surface,
                                padding: const EdgeInsets.fromLTRB(
                                    20, 14, 20, 6),
                                child: Text(
                                  row.label.toUpperCase(),
                                  style: const TextStyle(
                                    color: IveTokens.mute,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              );
                            }
                            if (row is _CountryRow) {
                              final c = row.country;
                              final sel =
                                  c.iso == widget.selectedCountry.iso;
                              return InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  widget.onSelect(c);
                                },
                                child: Container(
                                  constraints: const BoxConstraints(
                                      minHeight: 52),
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 10),
                                  color: sel
                                      ? IveTokens.accent
                                          .withValues(alpha: 0.07)
                                      : Colors.transparent,
                                  child: Row(
                                    children: [
                                      CountryFlag(
                                          iso: c.iso, size: 22),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          c.name,
                                          style: TextStyle(
                                            color: IveTokens.ink,
                                            fontSize: 16,
                                            fontWeight: sel
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        c.dialCode,
                                        style: TextStyle(
                                          color: sel
                                              ? IveTokens.accent
                                              : IveTokens.ink2,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      SizedBox(
                                        width: 20,
                                        child: sel
                                            ? const Icon(
                                                Icons.check_rounded,
                                                size: 18,
                                                color: IveTokens.accent)
                                            : const SizedBox.shrink(),
                                      ),
                                    ],
                                  ),
                                ),
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
