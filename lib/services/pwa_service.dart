/// PWA Service — Platform-aware conditional export.
///
/// Uses the stub (no-op) implementation on mobile/desktop,
/// and the real dart:html implementation on web.
export 'pwa_service_stub.dart'
    if (dart.library.html) 'pwa_service_web.dart';
