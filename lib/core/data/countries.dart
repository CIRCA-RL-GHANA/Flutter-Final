// ─────────────────────────────────────────────────────────────
// Canonical country catalogue.
//
// One source of truth for country pickers, dial-code lookups,
// flag rendering and address forms.
//
// Coverage: every ISO 3166-1 alpha-2 entry that has an E.164
// calling code — sovereign states plus officially-listed
// dependent territories. 247 entries total, alphabetised by
// English short name.
//
// Flag emoji is derived from the ISO code (regional-indicator
// symbols) at runtime, so the source file stays plain ASCII
// and renders correctly on every platform that supports
// Unicode flag glyphs.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';

@immutable
class Country {
  /// ISO 3166-1 alpha-2 (e.g. "US", "GH").
  final String iso;

  /// English short name (e.g. "United States").
  final String name;

  /// E.164 calling code, prefixed with "+" (e.g. "+1", "+233").
  final String dialCode;

  const Country({
    required this.iso,
    required this.name,
    required this.dialCode,
  });

  /// Flag emoji computed from the ISO code using Unicode regional
  /// indicator symbols. Stable across builds, no source encoding risk.
  String get flag => flagOf(iso);

  /// Convenience: name + dial code as it reads on a tile.
  String get displayName => '$name ($dialCode)';
}

/// Builds the flag emoji for a 2-letter ISO 3166-1 alpha-2 code.
/// Returns a white-flag fallback for invalid input.
String flagOf(String iso) {
  if (iso.length != 2) return '\u{1F3F3}';
  final upper = iso.toUpperCase();
  final a = upper.codeUnitAt(0);
  final b = upper.codeUnitAt(1);
  if (a < 0x41 || a > 0x5A || b < 0x41 || b > 0x5A) return '\u{1F3F3}';
  return String.fromCharCodes(<int>[
    0x1F1E6 + (a - 0x41),
    0x1F1E6 + (b - 0x41),
  ]);
}

/// Countries pinned to the top of pickers — the markets the product
/// serves first. Order is intentional, not alphabetical.
const List<String> kPopularCountryIsos = <String>[
  'GH', 'NG', 'KE', 'ZA', 'US', 'GB', 'CA', 'IN', 'AE', 'AU',
  'DE', 'FR', 'BR', 'JP', 'MX',
];

/// Full alphabetised catalogue. Do not reorder — UI groups assume
/// this list is sorted by `name` ascending.
const List<Country> kCountries = <Country>[
  Country(iso: 'AF', name: 'Afghanistan', dialCode: '+93'),
  Country(iso: 'AX', name: 'Åland Islands', dialCode: '+358'),
  Country(iso: 'AL', name: 'Albania', dialCode: '+355'),
  Country(iso: 'DZ', name: 'Algeria', dialCode: '+213'),
  Country(iso: 'AS', name: 'American Samoa', dialCode: '+1684'),
  Country(iso: 'AD', name: 'Andorra', dialCode: '+376'),
  Country(iso: 'AO', name: 'Angola', dialCode: '+244'),
  Country(iso: 'AI', name: 'Anguilla', dialCode: '+1264'),
  Country(iso: 'AQ', name: 'Antarctica', dialCode: '+672'),
  Country(iso: 'AG', name: 'Antigua and Barbuda', dialCode: '+1268'),
  Country(iso: 'AR', name: 'Argentina', dialCode: '+54'),
  Country(iso: 'AM', name: 'Armenia', dialCode: '+374'),
  Country(iso: 'AW', name: 'Aruba', dialCode: '+297'),
  Country(iso: 'AU', name: 'Australia', dialCode: '+61'),
  Country(iso: 'AT', name: 'Austria', dialCode: '+43'),
  Country(iso: 'AZ', name: 'Azerbaijan', dialCode: '+994'),
  Country(iso: 'BS', name: 'Bahamas', dialCode: '+1242'),
  Country(iso: 'BH', name: 'Bahrain', dialCode: '+973'),
  Country(iso: 'BD', name: 'Bangladesh', dialCode: '+880'),
  Country(iso: 'BB', name: 'Barbados', dialCode: '+1246'),
  Country(iso: 'BY', name: 'Belarus', dialCode: '+375'),
  Country(iso: 'BE', name: 'Belgium', dialCode: '+32'),
  Country(iso: 'BZ', name: 'Belize', dialCode: '+501'),
  Country(iso: 'BJ', name: 'Benin', dialCode: '+229'),
  Country(iso: 'BM', name: 'Bermuda', dialCode: '+1441'),
  Country(iso: 'BT', name: 'Bhutan', dialCode: '+975'),
  Country(iso: 'BO', name: 'Bolivia', dialCode: '+591'),
  Country(iso: 'BQ', name: 'Bonaire, Sint Eustatius and Saba', dialCode: '+599'),
  Country(iso: 'BA', name: 'Bosnia and Herzegovina', dialCode: '+387'),
  Country(iso: 'BW', name: 'Botswana', dialCode: '+267'),
  Country(iso: 'BV', name: 'Bouvet Island', dialCode: '+47'),
  Country(iso: 'BR', name: 'Brazil', dialCode: '+55'),
  Country(iso: 'IO', name: 'British Indian Ocean Territory', dialCode: '+246'),
  Country(iso: 'VG', name: 'British Virgin Islands', dialCode: '+1284'),
  Country(iso: 'BN', name: 'Brunei', dialCode: '+673'),
  Country(iso: 'BG', name: 'Bulgaria', dialCode: '+359'),
  Country(iso: 'BF', name: 'Burkina Faso', dialCode: '+226'),
  Country(iso: 'BI', name: 'Burundi', dialCode: '+257'),
  Country(iso: 'CV', name: 'Cabo Verde', dialCode: '+238'),
  Country(iso: 'KH', name: 'Cambodia', dialCode: '+855'),
  Country(iso: 'CM', name: 'Cameroon', dialCode: '+237'),
  Country(iso: 'CA', name: 'Canada', dialCode: '+1'),
  Country(iso: 'KY', name: 'Cayman Islands', dialCode: '+1345'),
  Country(iso: 'CF', name: 'Central African Republic', dialCode: '+236'),
  Country(iso: 'TD', name: 'Chad', dialCode: '+235'),
  Country(iso: 'CL', name: 'Chile', dialCode: '+56'),
  Country(iso: 'CN', name: 'China', dialCode: '+86'),
  Country(iso: 'CX', name: 'Christmas Island', dialCode: '+61'),
  Country(iso: 'CC', name: 'Cocos (Keeling) Islands', dialCode: '+61'),
  Country(iso: 'CO', name: 'Colombia', dialCode: '+57'),
  Country(iso: 'KM', name: 'Comoros', dialCode: '+269'),
  Country(iso: 'CG', name: 'Congo', dialCode: '+242'),
  Country(iso: 'CD', name: 'Congo (DRC)', dialCode: '+243'),
  Country(iso: 'CK', name: 'Cook Islands', dialCode: '+682'),
  Country(iso: 'CR', name: 'Costa Rica', dialCode: '+506'),
  Country(iso: 'CI', name: "Côte d'Ivoire", dialCode: '+225'),
  Country(iso: 'HR', name: 'Croatia', dialCode: '+385'),
  Country(iso: 'CU', name: 'Cuba', dialCode: '+53'),
  Country(iso: 'CW', name: 'Curaçao', dialCode: '+599'),
  Country(iso: 'CY', name: 'Cyprus', dialCode: '+357'),
  Country(iso: 'CZ', name: 'Czechia', dialCode: '+420'),
  Country(iso: 'DK', name: 'Denmark', dialCode: '+45'),
  Country(iso: 'DJ', name: 'Djibouti', dialCode: '+253'),
  Country(iso: 'DM', name: 'Dominica', dialCode: '+1767'),
  Country(iso: 'DO', name: 'Dominican Republic', dialCode: '+1809'),
  Country(iso: 'EC', name: 'Ecuador', dialCode: '+593'),
  Country(iso: 'EG', name: 'Egypt', dialCode: '+20'),
  Country(iso: 'SV', name: 'El Salvador', dialCode: '+503'),
  Country(iso: 'GQ', name: 'Equatorial Guinea', dialCode: '+240'),
  Country(iso: 'ER', name: 'Eritrea', dialCode: '+291'),
  Country(iso: 'EE', name: 'Estonia', dialCode: '+372'),
  Country(iso: 'SZ', name: 'Eswatini', dialCode: '+268'),
  Country(iso: 'ET', name: 'Ethiopia', dialCode: '+251'),
  Country(iso: 'FK', name: 'Falkland Islands', dialCode: '+500'),
  Country(iso: 'FO', name: 'Faroe Islands', dialCode: '+298'),
  Country(iso: 'FJ', name: 'Fiji', dialCode: '+679'),
  Country(iso: 'FI', name: 'Finland', dialCode: '+358'),
  Country(iso: 'FR', name: 'France', dialCode: '+33'),
  Country(iso: 'GF', name: 'French Guiana', dialCode: '+594'),
  Country(iso: 'PF', name: 'French Polynesia', dialCode: '+689'),
  Country(iso: 'TF', name: 'French Southern Territories', dialCode: '+262'),
  Country(iso: 'GA', name: 'Gabon', dialCode: '+241'),
  Country(iso: 'GM', name: 'Gambia', dialCode: '+220'),
  Country(iso: 'GE', name: 'Georgia', dialCode: '+995'),
  Country(iso: 'DE', name: 'Germany', dialCode: '+49'),
  Country(iso: 'GH', name: 'Ghana', dialCode: '+233'),
  Country(iso: 'GI', name: 'Gibraltar', dialCode: '+350'),
  Country(iso: 'GR', name: 'Greece', dialCode: '+30'),
  Country(iso: 'GL', name: 'Greenland', dialCode: '+299'),
  Country(iso: 'GD', name: 'Grenada', dialCode: '+1473'),
  Country(iso: 'GP', name: 'Guadeloupe', dialCode: '+590'),
  Country(iso: 'GU', name: 'Guam', dialCode: '+1671'),
  Country(iso: 'GT', name: 'Guatemala', dialCode: '+502'),
  Country(iso: 'GG', name: 'Guernsey', dialCode: '+44'),
  Country(iso: 'GN', name: 'Guinea', dialCode: '+224'),
  Country(iso: 'GW', name: 'Guinea-Bissau', dialCode: '+245'),
  Country(iso: 'GY', name: 'Guyana', dialCode: '+592'),
  Country(iso: 'HT', name: 'Haiti', dialCode: '+509'),
  Country(iso: 'HM', name: 'Heard Island and McDonald Islands', dialCode: '+672'),
  Country(iso: 'HN', name: 'Honduras', dialCode: '+504'),
  Country(iso: 'HK', name: 'Hong Kong', dialCode: '+852'),
  Country(iso: 'HU', name: 'Hungary', dialCode: '+36'),
  Country(iso: 'IS', name: 'Iceland', dialCode: '+354'),
  Country(iso: 'IN', name: 'India', dialCode: '+91'),
  Country(iso: 'ID', name: 'Indonesia', dialCode: '+62'),
  Country(iso: 'IR', name: 'Iran', dialCode: '+98'),
  Country(iso: 'IQ', name: 'Iraq', dialCode: '+964'),
  Country(iso: 'IE', name: 'Ireland', dialCode: '+353'),
  Country(iso: 'IM', name: 'Isle of Man', dialCode: '+44'),
  Country(iso: 'IL', name: 'Israel', dialCode: '+972'),
  Country(iso: 'IT', name: 'Italy', dialCode: '+39'),
  Country(iso: 'JM', name: 'Jamaica', dialCode: '+1876'),
  Country(iso: 'JP', name: 'Japan', dialCode: '+81'),
  Country(iso: 'JE', name: 'Jersey', dialCode: '+44'),
  Country(iso: 'JO', name: 'Jordan', dialCode: '+962'),
  Country(iso: 'KZ', name: 'Kazakhstan', dialCode: '+7'),
  Country(iso: 'KE', name: 'Kenya', dialCode: '+254'),
  Country(iso: 'KI', name: 'Kiribati', dialCode: '+686'),
  Country(iso: 'XK', name: 'Kosovo', dialCode: '+383'),
  Country(iso: 'KW', name: 'Kuwait', dialCode: '+965'),
  Country(iso: 'KG', name: 'Kyrgyzstan', dialCode: '+996'),
  Country(iso: 'LA', name: 'Laos', dialCode: '+856'),
  Country(iso: 'LV', name: 'Latvia', dialCode: '+371'),
  Country(iso: 'LB', name: 'Lebanon', dialCode: '+961'),
  Country(iso: 'LS', name: 'Lesotho', dialCode: '+266'),
  Country(iso: 'LR', name: 'Liberia', dialCode: '+231'),
  Country(iso: 'LY', name: 'Libya', dialCode: '+218'),
  Country(iso: 'LI', name: 'Liechtenstein', dialCode: '+423'),
  Country(iso: 'LT', name: 'Lithuania', dialCode: '+370'),
  Country(iso: 'LU', name: 'Luxembourg', dialCode: '+352'),
  Country(iso: 'MO', name: 'Macao', dialCode: '+853'),
  Country(iso: 'MG', name: 'Madagascar', dialCode: '+261'),
  Country(iso: 'MW', name: 'Malawi', dialCode: '+265'),
  Country(iso: 'MY', name: 'Malaysia', dialCode: '+60'),
  Country(iso: 'MV', name: 'Maldives', dialCode: '+960'),
  Country(iso: 'ML', name: 'Mali', dialCode: '+223'),
  Country(iso: 'MT', name: 'Malta', dialCode: '+356'),
  Country(iso: 'MH', name: 'Marshall Islands', dialCode: '+692'),
  Country(iso: 'MQ', name: 'Martinique', dialCode: '+596'),
  Country(iso: 'MR', name: 'Mauritania', dialCode: '+222'),
  Country(iso: 'MU', name: 'Mauritius', dialCode: '+230'),
  Country(iso: 'YT', name: 'Mayotte', dialCode: '+262'),
  Country(iso: 'MX', name: 'Mexico', dialCode: '+52'),
  Country(iso: 'FM', name: 'Micronesia', dialCode: '+691'),
  Country(iso: 'MD', name: 'Moldova', dialCode: '+373'),
  Country(iso: 'MC', name: 'Monaco', dialCode: '+377'),
  Country(iso: 'MN', name: 'Mongolia', dialCode: '+976'),
  Country(iso: 'ME', name: 'Montenegro', dialCode: '+382'),
  Country(iso: 'MS', name: 'Montserrat', dialCode: '+1664'),
  Country(iso: 'MA', name: 'Morocco', dialCode: '+212'),
  Country(iso: 'MZ', name: 'Mozambique', dialCode: '+258'),
  Country(iso: 'MM', name: 'Myanmar', dialCode: '+95'),
  Country(iso: 'NA', name: 'Namibia', dialCode: '+264'),
  Country(iso: 'NR', name: 'Nauru', dialCode: '+674'),
  Country(iso: 'NP', name: 'Nepal', dialCode: '+977'),
  Country(iso: 'NL', name: 'Netherlands', dialCode: '+31'),
  Country(iso: 'NC', name: 'New Caledonia', dialCode: '+687'),
  Country(iso: 'NZ', name: 'New Zealand', dialCode: '+64'),
  Country(iso: 'NI', name: 'Nicaragua', dialCode: '+505'),
  Country(iso: 'NE', name: 'Niger', dialCode: '+227'),
  Country(iso: 'NG', name: 'Nigeria', dialCode: '+234'),
  Country(iso: 'NU', name: 'Niue', dialCode: '+683'),
  Country(iso: 'NF', name: 'Norfolk Island', dialCode: '+672'),
  Country(iso: 'KP', name: 'North Korea', dialCode: '+850'),
  Country(iso: 'MK', name: 'North Macedonia', dialCode: '+389'),
  Country(iso: 'MP', name: 'Northern Mariana Islands', dialCode: '+1670'),
  Country(iso: 'NO', name: 'Norway', dialCode: '+47'),
  Country(iso: 'OM', name: 'Oman', dialCode: '+968'),
  Country(iso: 'PK', name: 'Pakistan', dialCode: '+92'),
  Country(iso: 'PW', name: 'Palau', dialCode: '+680'),
  Country(iso: 'PS', name: 'Palestine', dialCode: '+970'),
  Country(iso: 'PA', name: 'Panama', dialCode: '+507'),
  Country(iso: 'PG', name: 'Papua New Guinea', dialCode: '+675'),
  Country(iso: 'PY', name: 'Paraguay', dialCode: '+595'),
  Country(iso: 'PE', name: 'Peru', dialCode: '+51'),
  Country(iso: 'PH', name: 'Philippines', dialCode: '+63'),
  Country(iso: 'PN', name: 'Pitcairn', dialCode: '+64'),
  Country(iso: 'PL', name: 'Poland', dialCode: '+48'),
  Country(iso: 'PT', name: 'Portugal', dialCode: '+351'),
  Country(iso: 'PR', name: 'Puerto Rico', dialCode: '+1787'),
  Country(iso: 'QA', name: 'Qatar', dialCode: '+974'),
  Country(iso: 'RE', name: 'Réunion', dialCode: '+262'),
  Country(iso: 'RO', name: 'Romania', dialCode: '+40'),
  Country(iso: 'RU', name: 'Russia', dialCode: '+7'),
  Country(iso: 'RW', name: 'Rwanda', dialCode: '+250'),
  Country(iso: 'BL', name: 'Saint Barthélemy', dialCode: '+590'),
  Country(iso: 'SH', name: 'Saint Helena', dialCode: '+290'),
  Country(iso: 'KN', name: 'Saint Kitts and Nevis', dialCode: '+1869'),
  Country(iso: 'LC', name: 'Saint Lucia', dialCode: '+1758'),
  Country(iso: 'MF', name: 'Saint Martin', dialCode: '+590'),
  Country(iso: 'PM', name: 'Saint Pierre and Miquelon', dialCode: '+508'),
  Country(iso: 'VC', name: 'Saint Vincent and the Grenadines', dialCode: '+1784'),
  Country(iso: 'WS', name: 'Samoa', dialCode: '+685'),
  Country(iso: 'SM', name: 'San Marino', dialCode: '+378'),
  Country(iso: 'ST', name: 'São Tomé and Príncipe', dialCode: '+239'),
  Country(iso: 'SA', name: 'Saudi Arabia', dialCode: '+966'),
  Country(iso: 'SN', name: 'Senegal', dialCode: '+221'),
  Country(iso: 'RS', name: 'Serbia', dialCode: '+381'),
  Country(iso: 'SC', name: 'Seychelles', dialCode: '+248'),
  Country(iso: 'SL', name: 'Sierra Leone', dialCode: '+232'),
  Country(iso: 'SG', name: 'Singapore', dialCode: '+65'),
  Country(iso: 'SX', name: 'Sint Maarten', dialCode: '+1721'),
  Country(iso: 'SK', name: 'Slovakia', dialCode: '+421'),
  Country(iso: 'SI', name: 'Slovenia', dialCode: '+386'),
  Country(iso: 'SB', name: 'Solomon Islands', dialCode: '+677'),
  Country(iso: 'SO', name: 'Somalia', dialCode: '+252'),
  Country(iso: 'ZA', name: 'South Africa', dialCode: '+27'),
  Country(iso: 'GS', name: 'South Georgia and the South Sandwich Islands', dialCode: '+500'),
  Country(iso: 'KR', name: 'South Korea', dialCode: '+82'),
  Country(iso: 'SS', name: 'South Sudan', dialCode: '+211'),
  Country(iso: 'ES', name: 'Spain', dialCode: '+34'),
  Country(iso: 'LK', name: 'Sri Lanka', dialCode: '+94'),
  Country(iso: 'SD', name: 'Sudan', dialCode: '+249'),
  Country(iso: 'SR', name: 'Suriname', dialCode: '+597'),
  Country(iso: 'SJ', name: 'Svalbard and Jan Mayen', dialCode: '+47'),
  Country(iso: 'SE', name: 'Sweden', dialCode: '+46'),
  Country(iso: 'CH', name: 'Switzerland', dialCode: '+41'),
  Country(iso: 'SY', name: 'Syria', dialCode: '+963'),
  Country(iso: 'TW', name: 'Taiwan', dialCode: '+886'),
  Country(iso: 'TJ', name: 'Tajikistan', dialCode: '+992'),
  Country(iso: 'TZ', name: 'Tanzania', dialCode: '+255'),
  Country(iso: 'TH', name: 'Thailand', dialCode: '+66'),
  Country(iso: 'TL', name: 'Timor-Leste', dialCode: '+670'),
  Country(iso: 'TG', name: 'Togo', dialCode: '+228'),
  Country(iso: 'TK', name: 'Tokelau', dialCode: '+690'),
  Country(iso: 'TO', name: 'Tonga', dialCode: '+676'),
  Country(iso: 'TT', name: 'Trinidad and Tobago', dialCode: '+1868'),
  Country(iso: 'TN', name: 'Tunisia', dialCode: '+216'),
  Country(iso: 'TR', name: 'Türkiye', dialCode: '+90'),
  Country(iso: 'TM', name: 'Turkmenistan', dialCode: '+993'),
  Country(iso: 'TC', name: 'Turks and Caicos Islands', dialCode: '+1649'),
  Country(iso: 'TV', name: 'Tuvalu', dialCode: '+688'),
  Country(iso: 'UG', name: 'Uganda', dialCode: '+256'),
  Country(iso: 'UA', name: 'Ukraine', dialCode: '+380'),
  Country(iso: 'AE', name: 'United Arab Emirates', dialCode: '+971'),
  Country(iso: 'GB', name: 'United Kingdom', dialCode: '+44'),
  Country(iso: 'US', name: 'United States', dialCode: '+1'),
  Country(iso: 'UY', name: 'Uruguay', dialCode: '+598'),
  Country(iso: 'VI', name: 'U.S. Virgin Islands', dialCode: '+1340'),
  Country(iso: 'UZ', name: 'Uzbekistan', dialCode: '+998'),
  Country(iso: 'VU', name: 'Vanuatu', dialCode: '+678'),
  Country(iso: 'VA', name: 'Vatican City', dialCode: '+379'),
  Country(iso: 'VE', name: 'Venezuela', dialCode: '+58'),
  Country(iso: 'VN', name: 'Vietnam', dialCode: '+84'),
  Country(iso: 'WF', name: 'Wallis and Futuna', dialCode: '+681'),
  Country(iso: 'EH', name: 'Western Sahara', dialCode: '+212'),
  Country(iso: 'YE', name: 'Yemen', dialCode: '+967'),
  Country(iso: 'ZM', name: 'Zambia', dialCode: '+260'),
  Country(iso: 'ZW', name: 'Zimbabwe', dialCode: '+263'),
];

/// Resolve a country by ISO-2 code (case-insensitive). Returns null
/// if not found.
Country? countryByIso(String iso) {
  if (iso.length != 2) return null;
  final upper = iso.toUpperCase();
  for (final c in kCountries) {
    if (c.iso == upper) return c;
  }
  return null;
}

/// Popular countries materialised in the order declared by
/// [kPopularCountryIsos]. Silently skips any ISO not in the catalogue.
List<Country> get kPopularCountries {
  final out = <Country>[];
  for (final iso in kPopularCountryIsos) {
    final c = countryByIso(iso);
    if (c != null) out.add(c);
  }
  return out;
}
