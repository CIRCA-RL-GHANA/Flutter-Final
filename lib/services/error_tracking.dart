import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';

/// Lightweight error-tracking bootstrap.
///
/// Captures Flutter framework errors and platform-level async errors.
/// In production, wire [onError] into a remote service
/// (Sentry, Crashlytics, custom endpoint, etc.).
class ErrorTracking {
  ErrorTracking._();

  /// Call once in `main()` before `runApp()`.
  static void init({
    void Function(Object error, StackTrace stack)? onError,
  }) {
    // 1. Flutter framework errors (render, layout, gesture, etc.)
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details); // default red-screen in debug
      _report(
        details.exception,
        details.stack ?? StackTrace.current,
        onError: onError,
        context: details.context?.toDescription(),
      );
    };

    // 2. Async errors not caught by Flutter (Dart VM / Isolate level)
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      _report(error, stack, onError: onError, context: 'PlatformDispatcher');
      return true; // prevent the default crash
    };
  }

  /// Run the app inside a guarded zone for extra safety.
  static void runGuarded(
    void Function() appRunner, {
    void Function(Object error, StackTrace stack)? onError,
  }) {
    runZonedGuarded(
      appRunner,
      (error, stack) {
        _report(error, stack, onError: onError, context: 'Zone');
      },
    );
  }

  // ── Internal ──────────────────────────────────────────────────────

  static void _report(
    Object error,
    StackTrace stack, {
    void Function(Object error, StackTrace stack)? onError,
    String? context,
  }) {
    // Always log in debug
    if (kDebugMode) {
      debugPrint('╔══ ERROR [$context] ══');
      debugPrint('║ $error');
      debugPrint('╚══ STACK ══');
      debugPrint('$stack');
    }

    // Forward to external service in release
    if (!kDebugMode && onError != null) {
      try {
        onError(error, stack);
      } catch (_) {
        // Swallow reporting errors to avoid infinite loops
      }
    }
  }
}
