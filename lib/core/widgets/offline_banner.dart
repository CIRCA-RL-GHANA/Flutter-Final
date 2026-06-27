import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A banner that slides in from the top when the device goes offline
/// and automatically disappears when connectivity is restored.
///
/// Usage:
/// ```dart
/// Column(children: [
///   const OfflineBanner(),
///   Expanded(child: ...),
/// ]);
/// ```
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner>
    with SingleTickerProviderStateMixin {
  late final StreamSubscription<List<ConnectivityResult>> _sub;
  late final AnimationController _animCtrl;
  late final Animation<Offset> _slideAnim;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));

    // Hide the banner widget only after the slide-out animation completes,
    // so it slides out smoothly rather than disappearing immediately.
    _animCtrl.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && mounted) {
        setState(() {});
      }
    });

    // Check initial state
    Connectivity().checkConnectivity().then(_handleResult);

    // Listen for changes
    _sub = Connectivity().onConnectivityChanged.listen(_handleResult);
  }

  void _handleResult(List<ConnectivityResult> results) {
    final offline = results.contains(ConnectivityResult.none);
    if (offline != _isOffline) {
      setState(() => _isOffline = offline);
      if (_isOffline) {
        _animCtrl.forward();
      } else {
        _animCtrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keep the banner in the tree until the slide-out animation is fully
    // dismissed, so the sliding-out transition is visible on reconnect.
    if (!_isOffline && _animCtrl.isDismissed) return const SizedBox.shrink();
    return SlideTransition(
      position: _slideAnim,
      child: MaterialBanner(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        backgroundColor: AppColors.error,
        leading: const Icon(Icons.cloud_off, color: Colors.white),
        content: const Text(
          'You are offline. Some features may be unavailable.',
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final result = await Connectivity().checkConnectivity();
              _handleResult(result);
            },
            child: const Text(
              'RETRY',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
