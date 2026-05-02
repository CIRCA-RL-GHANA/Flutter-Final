# PROMPT Genie — Flutter PWA Deployment Guide

> **Audience:** Flutter developers joining the project.  
> **Stack:** Flutter 3.22.0 · Vercel Edge · `genieinprompt.app`  
> **Repo:** `CIRCA-RL-GHANA/Flutter-Ready` (source) ↔ `CIRCA-RL-GHANA/Root` (monorepo)

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Project Structure](#2-project-structure)
3. [Environment Configuration](#3-environment-configuration)
4. [Local Web Development](#4-local-web-development)
5. [Production Build](#5-production-build)
6. [vercel.json Explained](#6-verceljson-explained)
7. [Vercel Project Setup (One-Time)](#7-vercel-project-setup-one-time)
8. [CI/CD Pipeline](#8-cicd-pipeline)
9. [PWA Internals](#9-pwa-internals)
10. [Caching Strategy](#10-caching-strategy)
11. [Troubleshooting](#11-troubleshooting)
12. [Post-Deploy Checklist](#12-post-deploy-checklist)

---

## 1. Prerequisites

| Tool | Version | Check |
|------|---------|-------|
| Flutter SDK | 3.22.0 | `flutter --version` |
| Dart SDK | ≥ 3.2.0 | bundled with Flutter |
| Node.js | ≥ 18 | `node --version` |
| Vercel CLI | latest | `npm i -g vercel` |
| Git | any | `git --version` |

Run `flutter doctor` — all checks must pass before any build.

```bash
flutter doctor -v
```

---

## 2. Project Structure

```
thedep/                          ← Root monorepo (CIRCA-RL-GHANA/Root)
├── .github/workflows/
│   ├── deploy.yml               ← Dedicated PWA → Vercel pipeline
│   └── flutter.yml              ← Full CI/CD (Android / iOS / Web)
└── thepg/                       ← Flutter project (CIRCA-RL-GHANA/Flutter-Ready)
    ├── lib/
    │   ├── main.dart
    │   └── core/
    │       ├── constants/
    │       │   └── env_config.dart   ← Environment URLs & flags
    │       ├── network/
    │       │   └── api_client.dart   ← Dio singleton with auth interceptors
    │       └── routes/
    │           └── app_routes.dart   ← All named routes
    ├── web/
    │   ├── index.html               ← PWA shell + SEO meta tags
    │   └── manifest.json            ← PWA install manifest
    └── vercel.json                  ← Vercel build & caching config
```

---

## 3. Environment Configuration

Environment is injected at **build time** via `--dart-define`. There is no `.env` file for the Flutter project.

### How it works

`lib/core/constants/env_config.dart` reads compile-time constants:

```dart
class EnvConfig {
  static const Environment current = Environment.production;

  static String get baseUrl {
    switch (current) {
      case Environment.development:
        return 'http://10.0.2.2:3000/api/v1';     // Android emulator
      case Environment.staging:
        return 'https://staging-api.genieinprompt.app/api/v1';
      case Environment.production:
        return 'https://api.genieinprompt.app/api/v1';
    }
  }
}
```

### Passing variables at build time

```bash
# Development (local)
flutter run -d chrome \
  --dart-define=API_BASE_URL=http://localhost:3000/api/v1 \
  --dart-define=ENVIRONMENT=development

# Production build
flutter build web --release \
  --web-renderer canvaskit \
  --dart-define=API_BASE_URL=https://api.genieinprompt.app \
  --dart-define=ENVIRONMENT=production
```

Reading them in Dart:
```dart
const apiUrl = String.fromEnvironment('API_BASE_URL',
    defaultValue: 'https://api.genieinprompt.app');
```

### Vercel environment variables

| Variable | Where to set | Purpose |
|----------|-------------|---------|
| `API_BASE_URL` | Vercel → Settings → Environment Variables | Backend API URL |
| `VERCEL_TOKEN` | GitHub Secrets | CI/CD authentication |
| `VERCEL_ORG_ID` | GitHub Secrets | Vercel organisation |
| `VERCEL_PROJECT_ID` | GitHub Secrets | Vercel project |

---

## 4. Local Web Development

```bash
cd thepg

# One-time: enable web target
flutter config --enable-web

# Install dependencies
flutter pub get

# Run in Chrome (hot-reload supported)
flutter run -d chrome

# Run in Chrome with a specific port
flutter run -d chrome --web-port 8080

# Run against local backend
flutter run -d chrome \
  --dart-define=API_BASE_URL=http://localhost:3000/api/v1 \
  --dart-define=ENVIRONMENT=development
```

> **Note:** Hot reload works in `flutter run` but does **not** apply to the service worker. Changes to `web/` files require a full restart.

---

## 5. Production Build

```bash
cd thepg

# Clean previous artefacts
flutter clean
flutter pub get

# Build with CanvasKit renderer (consistent cross-browser rendering)
flutter build web \
  --release \
  --web-renderer canvaskit \
  --pwa-strategy offline-first \
  --dart-define=API_BASE_URL=https://api.genieinprompt.app \
  --dart-define=ENVIRONMENT=production \
  --source-maps
```

### Build flag reference

| Flag | Purpose |
|------|---------|
| `--release` | Minification, tree-shaking, no debug assertions |
| `--web-renderer canvaskit` | Pixel-perfect rendering via WASM; ~2 MB extra download but eliminates font/layout differences |
| `--pwa-strategy offline-first` | Service worker caches all assets on first load; app works fully offline thereafter |
| `--dart-define=KEY=VALUE` | Inlines compile-time constants — the only secure way to pass secrets into Flutter web |
| `--source-maps` | Keeps `.map` files for Sentry / DevTools stack traces in production |

### Verify artefacts

```bash
ls build/web/
# Must contain:
#   index.html
#   flutter.js
#   flutter_service_worker.js
#   manifest.json
#   main.dart.js (or canvaskit/)
#   assets/
```

---

## 6. vercel.json Explained

Location: `thepg/vercel.json`

```jsonc
{
  "version": 2,
  "framework": null,

  // Vercel runs this instead of using a framework preset
  "installCommand": "echo 'handled in buildCommand'",
  "buildCommand": "curl ... flutter_linux_3.22.0 ... && flutter build web ...",
  "outputDirectory": "build/web",

  // Client-side routing: all unknown paths serve index.html
  // This is what makes /marketplace, /fintech, etc. work on refresh
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ],

  "headers": [
    // 1. index.html — never cache; forces fresh load + SW update check
    { "source": "/index.html",        "headers": [{ "key": "Cache-Control", "value": "no-store" }] },

    // 2. Service worker — must always be fresh (browsers have a 24h max anyway)
    { "source": "/flutter_service_worker.js",
      "headers": [
        { "key": "Cache-Control",        "value": "no-cache, no-store, must-revalidate" },
        { "key": "Service-Worker-Allowed","value": "/" }
      ]
    },

    // 3. PWA manifest — no cache so installs always use the latest name/icon
    { "source": "/manifest.json",     "headers": [{ "key": "Cache-Control", "value": "no-cache, no-store, must-revalidate" }] },

    // 4. Hashed static assets — safe to cache forever (Flutter hashes filenames on each build)
    { "source": "/(.*\\.(js|css|wasm|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$)",
      "headers": [{ "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }]
    },

    // 5. All responses — security headers
    { "source": "/(.*)", "headers": [
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "X-Frame-Options",        "value": "SAMEORIGIN" },
        { "key": "X-XSS-Protection",       "value": "1; mode=block" },
        { "key": "Referrer-Policy",        "value": "strict-origin-when-cross-origin" },
        { "key": "Permissions-Policy",     "value": "camera=(), microphone=(), geolocation=(self)" }
    ]}
  ]
}
```

### Why `framework: null`?

Vercel does not have a Flutter preset. Setting `framework: null` disables all framework auto-detection and lets `buildCommand` take full control, including installing the Flutter SDK from scratch on each Vercel build container.

---

## 7. Vercel Project Setup (One-Time)

This is done once by a team admin. After this, all deploys are automated.

### Step 1 — Link the repo

1. Go to [vercel.com](https://vercel.com) → **Add New → Project**
2. Import `CIRCA-RL-GHANA/Root` (the monorepo)
3. Set **Root Directory** to `thepg`
4. Set **Framework Preset** to `Other`
5. Vercel auto-detects `vercel.json` — verify the build command and output dir match
6. Click **Deploy**

### Step 2 — Add the custom domain

1. **Settings → Domains → Add** → enter `genieinprompt.app`
2. Add the DNS records Vercel provides at your registrar:

   | Type | Name | Value |
   |------|------|-------|
   | `A` | `@` | `76.76.21.21` |
   | `CNAME` | `www` | `cname.vercel-dns.com` |

3. SSL is provisioned automatically. Propagation takes ~5 minutes.

### Step 3 — Add environment variables

**Vercel Dashboard → Settings → Environment Variables:**

| Key | Value | Environments |
|-----|-------|-------------|
| `API_BASE_URL` | `https://api.genieinprompt.app` | Production, Preview |

### Step 4 — Retrieve Vercel IDs for GitHub Actions

```bash
# In thepg/, after running `vercel link`
cat .vercel/project.json
# → { "orgId": "...", "projectId": "..." }
```

Add these to **GitHub → Settings → Secrets and variables → Actions**:

| Secret name | Value |
|-------------|-------|
| `VERCEL_TOKEN` | From vercel.com → Account → Tokens |
| `VERCEL_ORG_ID` | `orgId` from `.vercel/project.json` |
| `VERCEL_PROJECT_ID` | `projectId` from `.vercel/project.json` |

---

## 8. CI/CD Pipeline

Two workflows handle web deployment from the Root monorepo.

### `deploy.yml` — Dedicated PWA pipeline (recommended)

**Triggers:**

| Event | Effect |
|-------|--------|
| Push to `main` touching `thepg/**` | Production deploy to `genieinprompt.app` |
| Pull request to `main` touching `thepg/**` | Preview deploy; URL posted as PR comment |
| `workflow_dispatch` | Manual deploy from GitHub Actions UI |
| `repository_dispatch: flutter-deploy` | Called by `Flutter-Ready` repo after its tests pass |

**Pipeline steps:**
```
Checkout → Flutter setup → flutter pub get → flutter analyze
  → flutter build web (CanvasKit, offline-first)
  → Verify artefacts (SW + manifest present)
  → vercel --prod --yes  (or preview)
  → Smoke-test HTTP 200 (production only)
```

### `flutter.yml` — Full CI/CD (Android / iOS / Web)

Runs on push to `main`. Includes the same web deploy step plus Android AAB/APK and iOS IPA builds. Use this as the source of truth for full release builds.

### Manual deploy (no CI)

```bash
cd thepg
npm install -g vercel

# First time
vercel login
vercel link       # creates .vercel/project.json

# Deploy to production
flutter build web --release --web-renderer canvaskit \
  --dart-define=API_BASE_URL=https://api.genieinprompt.app \
  --dart-define=ENVIRONMENT=production

vercel --prod --yes
```

---

## 9. PWA Internals

### Service worker

Flutter generates `flutter_service_worker.js` automatically when `--pwa-strategy offline-first` is passed. It:

- Pre-caches all app assets on first load
- Serves from cache when offline
- Updates silently in the background when a new deploy lands (the `no-store` header on `index.html` ensures the browser always fetches the latest SW hash)

### manifest.json

Controls install behaviour. Key fields for this project:

```json
{
  "name": "PROMPT Genie",
  "short_name": "PromptGenie",
  "start_url": "/?utm_source=pwa",
  "display": "standalone",
  "background_color": "#1A1A2E",
  "theme_color": "#3F51B5"
}
```

- `display: standalone` removes the browser chrome when installed
- `start_url` with UTM parameters lets you track PWA installs in analytics
- `theme_color` sets the Android status bar colour

### Install prompt

Flutter web does not automatically show the browser install prompt. To trigger it programmatically, use the `js` package:

```dart
import 'dart:js' as js;

// Call when you want to show the install prompt
void showInstallPrompt() {
  js.context.callMethod('promptPwaInstall', []);
}
```

And in `web/index.html`, capture the event:

```html
<script>
  let deferredPrompt;
  window.addEventListener('beforeinstallprompt', (e) => {
    e.preventDefault();
    deferredPrompt = e;
  });
  window.promptPwaInstall = () => deferredPrompt?.prompt();
</script>
```

---

## 10. Caching Strategy

| Resource | Cache policy | Reason |
|----------|-------------|--------|
| `index.html` | `no-store` | Must always be fresh so SW update check runs |
| `flutter_service_worker.js` | `no-store` | Browsers enforce 24h max; we enforce zero |
| `manifest.json` | `no-store` | Install always uses latest name/icon/colour |
| `*.js`, `*.css`, `*.wasm`, images, fonts | `max-age=31536000, immutable` | Flutter hashes filenames — safe to cache permanently |
| Everything else | Vercel default | Dynamic responses |

This combination means:
- First load: full download
- Repeat load: instant (all assets from cache)
- After a new deploy: index.html fetches fresh → new SW hash detected → assets re-cached in background → user sees new version on next page load

---

## 11. Troubleshooting

### 404 on deep links (e.g. `/marketplace` after refresh)

The `rewrites` rule in `vercel.json` must be present:
```json
"rewrites": [{ "source": "/(.*)", "destination": "/index.html" }]
```
If the 404 persists, check that `vercel.json` is in the Vercel project root (i.e. `thepg/`, not the monorepo root).

### Service worker not updating (users stuck on old version)

1. `index.html` is returning a cached response — check that `Cache-Control: no-store` is set on `/index.html` in Vercel's response headers (use DevTools → Network).
2. If a specific user is stuck, have them open DevTools → Application → Service Workers → click **Unregister**, then hard-refresh.
3. In extreme cases, bump the app version in `pubspec.yaml` — Flutter regenerates the SW hash.

### Build failure: Flutter SDK not found on Vercel

The `buildCommand` in `vercel.json` downloads Flutter from the Google storage bucket. If the download URL changes (Flutter major release), update the version string:
```
flutter_linux_3.22.0-stable.tar.xz  ← update this version
```

### CanvasKit CORS errors

CanvasKit fetches WASM from `unpkg.com` by default. If your CSP blocks it, host CanvasKit locally:
```bash
flutter build web --release \
  --web-renderer canvaskit \
  --dart-define=FLUTTER_WEB_CANVASKIT_URL=/canvaskit/
```
Then copy `build/web/canvaskit/` to your Vercel output and serve it from the same origin.

### `flutter analyze` fails in CI

The pipeline runs `flutter analyze --no-fatal-infos`. Fix all errors and warnings before pushing. Run locally:
```bash
flutter analyze
dart fix --apply   # auto-fix safe issues
```

### API calls fail in the deployed PWA (CORS)

All API calls go through `ApiClient` (Dio singleton). The backend at `api.genieinprompt.app` must include `https://genieinprompt.app` in its CORS `Access-Control-Allow-Origin` header. Check the NestJS CORS config in `orionstack-backend--main`.

---

## 12. Post-Deploy Checklist

Run through this after every production deploy:

- [ ] `https://genieinprompt.app` returns HTTP 200
- [ ] Hard-refresh (`Ctrl+Shift+R`) loads the new version (check build hash in DevTools → Application → Service Workers)
- [ ] Install prompt appears on Chrome Android / Edge
- [ ] Installed app opens in standalone mode (no browser chrome)
- [ ] Offline mode: disconnect network → navigate between cached routes → no errors
- [ ] Auth flow (OTP → registration → dashboard) completes end-to-end
- [ ] Deep link test: navigate directly to `https://genieinprompt.app/marketplace` — must load the app, not a 404
- [ ] DevTools Lighthouse audit: PWA score ≥ 90, Performance ≥ 80
- [ ] Security headers present (check via [securityheaders.com](https://securityheaders.com))
