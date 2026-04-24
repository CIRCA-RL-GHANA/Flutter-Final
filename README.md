# Frontend — thepg

Flutter 3.2+ cross-platform application for the PROMPT Genie platform. Targets Android, iOS, and Web (PWA).

## Overview

| Property | Value |
|---|---|
| Framework | Flutter 3.2+ |
| Language | Dart (SDK ≥3.2.0 <4.0.0) |
| State management | Provider (ChangeNotifier) + Riverpod |
| Local storage | Hive + SharedPreferences |
| HTTP client | Dio |
| App name | PROMPT Genie |
| Version | 1.0.0+1 |
| Production API | `https://api.genieinprompt.app/api/v1` |

## Directory Structure

```
thepg/
├── lib/
│   ├── main.dart                     ← App entry point, providers, routes, theme
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_routes.dart       ← All API paths (mirrors shared/constants/routes.ts)
│   │   │   ├── app_config.dart       ← Build-time config flags
│   │   │   ├── app_strings.dart      ← UI string constants
│   │   │   ├── app_dimensions.dart   ← Spacing / sizing constants
│   │   │   ├── app_animations.dart   ← Animation duration constants
│   │   │   ├── env_config.dart       ← Environment URLs (prod/staging/dev)
│   │   │   └── error_codes.dart      ← Error code constants
│   │   ├── network/
│   │   │   ├── api_client.dart       ← Dio singleton, auth interceptor, token refresh
│   │   │   ├── api_response.dart     ← Generic ApiResponse<T> wrapper
│   │   │   └── network.dart          ← Connectivity checks
│   │   ├── providers/
│   │   │   ├── app_providers.dart    ← All MultiProvider registrations
│   │   │   └── service_providers.dart
│   │   ├── routes/
│   │   │   └── app_routes.dart       ← Named route definitions
│   │   ├── services/                 ← One service class per backend module
│   │   ├── theme/
│   │   │   ├── app_colors.dart       ← Color palette
│   │   │   └── app_theme.dart        ← ThemeData (light + dark)
│   │   └── utils/
│   │       ├── helpers.dart
│   │       └── responsive.dart
│   ├── features/
│   │   ├── onboarding/               ← 14-screen registration flow
│   │   ├── prompt/                   ← AI assistant hub (main dashboard)
│   │   ├── user_details/             ← Profile, security, privacy (9 screens)
│   │   ├── setup_dashboard/          ← Business setup wizard (34 screens)
│   │   ├── go/                       ← Financial wallet (24 screens)
│   │   ├── market/                   ← E-commerce (17 screens)
│   │   ├── live/                     ← Fulfilment & driver ops (23 screens)
│   │   ├── updates/                  ← Social feed (13 screens)
│   │   ├── qualchat/                 ← Messaging (16 screens)
│   │   ├── april/                    ← Finance calendar (7 screens)
│   │   ├── alerts/                   ← Notification feeds (12 screens)
│   │   └── utility/                  ← Settings, help, privacy (9 screens)
│   ├── models/local/                 ← Local-only Hive models
│   ├── services/                     ← Cross-feature services (error tracking, PWA)
│   └── widgets/
│       └── offline_banner.dart       ← Network offline indicator
├── android/                          ← Android native project
├── ios/                              ← iOS native project
├── web/                              ← Web/PWA shell
├── assets/
│   ├── animations/                   ← Lottie JSON files
│   ├── icons/                        ← PWA icon set + app icons
│   └── images/                       ← Static images
├── pubspec.yaml
├── analysis_options.yaml
└── build-all.sh                      ← Script to build all targets in sequence
```

## Local Development

### Prerequisites

- Flutter SDK 3.2+ ([install guide](https://docs.flutter.dev/get-started/install))
- Android Studio or Xcode (depending on target platform)
- A running backend (see [orionstack-backend--main/README.md](../orionstack-backend--main/README.md))

### 1. Install dependencies

```bash
cd thepg
flutter pub get
```

### 2. Configure the environment

The active environment is set in `lib/core/constants/env_config.dart`:

```dart
// Change this to match your target environment
static const Environment _environment = Environment.production;
```

| Environment | Base URL |
|---|---|
| `production` | `https://api.genieinprompt.app/api/v1` |
| `staging` | `https://staging-api.genieinprompt.app/api/v1` |
| `development` | `http://10.0.2.2:3000/api/v1` (Android emulator) |

For local development against `localhost`, set `_environment = Environment.development`.

### 3. Run the app

```bash
flutter run                        # Default connected device
flutter run -d chrome              # Web
flutter run -d emulator-5554       # Android emulator
flutter run -d "iPhone 15 Pro"     # iOS simulator
```

## Building for Release

### Android APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (Play Store)

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

Configure signing in `android/keystore.properties` (copy from `android/keystore.properties.example`):

```
storePassword=<keystore-password>
keyPassword=<key-password>
keyAlias=<key-alias>
storeFile=../keystore/release.jks
```

### iOS

```bash
flutter build ios --release
```

Open `ios/Runner.xcworkspace` in Xcode to archive and submit to App Store Connect. Export options are pre-configured in `ios/ExportOptions.plist`.

### Web / PWA

```bash
flutter build web --release --base-href /
# Output: build/web/
```

The `build/web/` directory is mounted into Nginx by `docker-compose.prod.yml` and served at `https://genieinprompt.app/`.

### Build All Targets

```bash
bash build-all.sh
```

## State Management

The app uses **Provider** (ChangeNotifier). All providers are registered in `lib/core/providers/app_providers.dart` via `MultiProvider` wrapping the root `MaterialApp`.

| Provider | Feature |
|---|---|
| `OnboardingProvider` | Registration flow state |
| `DeviceCheckProvider` | Device fingerprint / compatibility |
| `PhoneAuthProvider` | Phone number auth state |
| `RegistrationProvider` | Multi-step registration form |
| `ProfileProvider` | User profile state |
| `BiometricProvider` | Biometric auth state |
| `RoleProvider` | User role selection |
| `PermissionProvider` | OS permission requests |
| `ContextProvider` | App-level context flags |
| `PromptProvider` | AI assistant state |
| `UserDetailsProvider` | User details management |
| `UtilityProvider` | Settings / utility state |
| `SetupDashboardProvider` | Business setup wizard state |
| `GoProvider` | GO financial wallet state |
| `MarketProvider` | Market / e-commerce state |
| `LiveProvider` | Fulfilment / driver state |
| `UpdatesProvider` | Social feed state |
| `QualChatProvider` | Chat state |
| `AprilProvider` | Finance calendar state |
| `AlertsProvider` | Alerts / notifications state |
| `AIAssistantService` | AI assistant service (Riverpod) |
| `AIInsightsNotifier` | AI insights state (Riverpod) |

## Services Layer

Every backend module has a corresponding service in `lib/core/services/`. Each service uses the `ApiClient` Dio singleton and returns typed `ApiResponse<T>` objects.

| Service | Backend Module |
|---|---|
| `AuthService` | `/auth` |
| `UserService` | `/users` |
| `ProfileService` | `/profiles` |
| `EntityService` | `/entities` |
| `QPointsService` | `/qpoints` |
| `ProductService` | `/products` |
| `OrderService` | `/orders` |
| `VehicleService` | `/vehicles` |
| `RideService` | `/rides` |
| `SocialService` | `/social` |
| `CalendarService` | `/calendar` |
| `PlannerService` | `/planner` |
| `StatementService` | `/statement` |
| `WishlistService` | `/wishlist` |
| `InterestService` | `/interests` |
| `PlaceService` | `/places` |
| `SubscriptionService` | `/subscriptions` |
| `AIService` | `/ai` |
| `AIAssistantService` | AI chat (in-app) |
| `EntityProfileService` | `/entity-profiles` |
| `FavoriteDriverService` | `/favorite-drivers` |
| `MarketProfileService` | `/market-profiles` |
| `WebSocketService` | Socket.io chat |
| `LocalStorageService` | Hive / SharedPreferences |

## API Client

`lib/core/network/api_client.dart` is a Dio singleton initialized in `main.dart`.

- Base URL set from `EnvConfig.baseUrl`
- 30 second connect + receive timeout
- `Content-Type: application/json`
- Interceptor: attaches `Authorization: Bearer <token>` from SharedPreferences on every request
- On `401 Unauthorized`: attempts a token refresh, retries the original request once, then routes to the login screen

## Routing

Named routes are defined in `lib/core/routes/app_routes.dart`. The initial route is `preLoading`. Navigation uses `Navigator.pushNamed`.

Key routes:
```
/                → preLoading (screen_0)
/splash          → splash (screen_1)
/welcome         → welcome (screen_2)
/phone           → phone input (screen_3)
/otp             → OTP verification (screen_4)
/register        → registration form (screen_5)
/photo           → profile photo (screen_6)
/biometric       → biometric setup (screen_7)
/role            → role selection (screen_8)
/permissions     → permissions (screen_9)
/success         → onboarding success (screen_10)
/tutorial        → tutorial (screen_11)
/prompt          → main AI dashboard
/go              → GO wallet hub
/market          → Market hub
/live            → Live operations hub
/updates         → Updates feed
/qualchat        → QualChat hub
/april           → April calendar
/setup           → Setup dashboard
/settings        → User settings
```

## Theme

Defined in `lib/core/theme/`:

**Brand colours:**
- Background dark: `#0F0F23`
- Primary: `#1A237E` → `#3F51B5` (deep navy / indigo)
- Accent / CTA: `#FFD700` → `#FFA000` (gold)
- Success: `#10B981` | Error: `#EF4444` | Warning: `#F59E0B` | Info: `#3B82F6`

**Role colours:**
- Buyer: purple | Shop owner: green | Delivery: amber | Driver: blue | Individual: indigo | Business: cyan

**Typography:** Poppins (Regular, Medium 500, SemiBold 600, Bold 700)

Text scale is clamped to [0.8, 2.0] for accessibility.
Screen orientation is locked to portrait only.

## PWA Configuration

The web build targets full PWA compliance:
- Service worker configured in `web/`
- Full icon set in `assets/icons/` (72px through 512px, maskable variants)
- `manifest.json` with `display: standalone`, theme colour `#0F0F23`
- Served by Nginx with `try_files` SPA fallback and 1-year static asset caching

## Testing

```bash
flutter test                       # Unit + widget tests
flutter test integration_test/     # Integration tests (requires device/emulator)
```

Test files live in `test/`.

## Linting

```bash
flutter analyze
```

Analysis rules are defined in `analysis_options.yaml`.

## Key Dependencies

| Package | Purpose |
|---|---|
| `provider` | ChangeNotifier state management |
| `flutter_riverpod` | Riverpod for AI and insights state |
| `hive` / `hive_flutter` | Local offline database |
| `shared_preferences` | Auth token persistence |
| `dio` | HTTP client with interceptors |
| `connectivity_plus` | Network status monitoring |
| `local_auth` | Biometric authentication |
| `permission_handler` | OS permission management |
| `pinput` | OTP / PIN input widget |
| `lottie` | Lottie animation playback |
| `shimmer` | Loading skeleton effect |
| `google_fonts` / `Poppins` | Typography |
| `cached_network_image` | Image caching |
| `image_picker` / `image_cropper` | Photo upload |
| `geolocator` | GPS location |
| `country_code_picker` | International phone input |
| `device_info_plus` | Device fingerprinting |
| `intl` | Date/number formatting |
| `animate_do` / `flutter_animate` | UI animations |
| `confetti` | Celebration animations |
