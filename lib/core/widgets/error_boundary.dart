import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../design/ive_button.dart';
import '../design/ive_text.dart';
import '../design/ive_tokens.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final VoidCallback? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool _hasError = false;
  String _errorMessage = '';

  // Chain: we must never silently swallow the previous handler.
  FlutterExceptionHandler? _previousOnError;

  @override
  void initState() {
    super.initState();
    _previousOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      // Always forward to the outer handler (default prints to console / crashlytics).
      _previousOnError?.call(details);
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = details.exception.toString();
        });
      }
      widget.onError?.call();
    };
  }

  @override
  void dispose() {
    // Restore so the slot isn't permanently poisoned after this widget leaves.
    FlutterError.onError = _previousOnError;
    super.dispose();
  }

  void _reset() {
    setState(() {
      _hasError = false;
      _errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        backgroundColor: IveTokens.bg,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(IveTokens.s8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: IveTokens.danger.withValues(alpha: 0.12),
                      borderRadius: IveTokens.brMd,
                      border: Border.all(
                          color: IveTokens.danger.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.error_outline_rounded,
                        size: 32, color: IveTokens.danger),
                  ),
                  const SizedBox(height: IveTokens.s5),
                  Text('Something went wrong',
                      style: IveType.title3, textAlign: TextAlign.center),
                  const SizedBox(height: IveTokens.s2),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Text(
                      // Never expose raw exceptions to users in release builds.
                      kReleaseMode
                          ? 'An unexpected error occurred. Try again.'
                          : _errorMessage,
                      style: IveType.callout,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: IveTokens.s6),
                  IveButton.primary(
                    label: 'Try Again',
                    onPressed: _reset,
                    expand: false,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return widget.child;
  }
}

/// Inline API error widget  shown inside a screen when a request fails.
class ApiError extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;

  const ApiError({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(IveTokens.s8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 48, color: IveTokens.labelTertiary),
            const SizedBox(height: IveTokens.s4),
            Text(title,
                style: IveType.title3, textAlign: TextAlign.center),
            const SizedBox(height: IveTokens.s2),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(message,
                  style: IveType.callout, textAlign: TextAlign.center),
            ),
            const SizedBox(height: IveTokens.s5),
            IveButton.secondary(
              label: 'Retry',
              onPressed: onRetry,
              expand: false,
              icon: Icons.refresh_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
