/// ═══════════════════════════════════════════════════════════════════════════
/// Module Widget Card
/// The universal wrapper for all 10 module widgets on the PROMPT screen.
/// Handles 6 states, gestures, accessibility, view-only overlay, shimmer.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../models/rbac_models.dart';
import '../providers/prompt_provider.dart';

class ModuleWidgetCard extends StatefulWidget {
  final PromptModule module;
  final ModuleWidgetState state;
  final bool isViewOnly;
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onRetry;
  final int staggerIndex;

  const ModuleWidgetCard({
    super.key,
    required this.module,
    required this.child,
    this.state = ModuleWidgetState.normal,
    this.isViewOnly = false,
    this.onTap,
    this.onLongPress,
    this.onRetry,
    this.staggerIndex = 0,
  });

  @override
  State<ModuleWidgetCard> createState() => _ModuleWidgetCardState();
}

class _ModuleWidgetCardState extends State<ModuleWidgetCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );

    // Staggered entrance: 50ms delay per widget index
    Future.delayed(Duration(milliseconds: 50 * widget.staggerIndex), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = ModuleInfo.forModule(widget.module);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Semantics(
          label: '${info.name} widget. ${info.description}. '
              '${widget.isViewOnly ? "View only." : "Tap to open."}',
          button: !widget.isViewOnly,
          child: GestureDetector(
            onTapDown: widget.isViewOnly
                ? null
                : (_) => setState(() => _scale = 0.97),
            onTapUp: widget.isViewOnly
                ? null
                : (_) {
                    setState(() => _scale = 1.0);
                    HapticFeedback.lightImpact();
                    widget.onTap?.call();
                  },
            onTapCancel: () => setState(() => _scale = 1.0),
            onLongPress: widget.isViewOnly
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    widget.onLongPress?.call();
                  },
            child: AnimatedScale(
              scale: _scale,
              duration: const Duration(milliseconds: 100),
              child: _buildCardContent(info),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(ModuleInfo info) {
    switch (widget.state) {
      case ModuleWidgetState.loading:
        return _LoadingCard(info: info);
      case ModuleWidgetState.error:
        return _ErrorCard(info: info, onRetry: widget.onRetry);
      case ModuleWidgetState.empty:
        return _EmptyCard(info: info, onTap: widget.onTap);
      case ModuleWidgetState.disabled:
        return _DisabledCard(info: info);
      default:
        return _NormalCard(
          info: info,
          isViewOnly: widget.isViewOnly ||
              widget.state == ModuleWidgetState.viewOnly,
          child: widget.child,
        );
    }
  }
}

// ─── Normal Card ──────────────────────────────────────────────────────────────

class _NormalCard extends StatelessWidget {
  final ModuleInfo info;
  final bool isViewOnly;
  final Widget child;

  const _NormalCard({
    required this.info,
    required this.isViewOnly,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isViewOnly ? 0.4 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: info.color.withOpacity(0.12), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              child,
              if (isViewOnly)
                Positioned.fill(
                  child: AbsorbPointer(
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Loading (Shimmer) Card ──────────────────────────────────────────────────

class _LoadingCard extends StatefulWidget {
  final ModuleInfo info;
  const _LoadingCard({required this.info});

  @override
  State<_LoadingCard> createState() => _LoadingCardState();
}

class _LoadingCardState extends State<_LoadingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _shimmerBox(120, 14),
              const SizedBox(height: 12),
              _shimmerBox(double.infinity, 40),
              const SizedBox(height: 8),
              _shimmerBox(180, 12),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _shimmerBox(double.infinity, 32)),
                  const SizedBox(width: 8),
                  Expanded(child: _shimmerBox(double.infinity, 32)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _shimmerBox(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment(-1.0 + 2.0 * _shimmerController.value, 0),
          end: Alignment(-1.0 + 2.0 * _shimmerController.value + 1, 0),
          colors: const [
            AppColors.shimmerBase,
            AppColors.shimmerHighlight,
            AppColors.shimmerBase,
          ],
        ),
      ),
    );
  }
}

// ─── Error Card ─────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  final ModuleInfo info;
  final VoidCallback? onRetry;

  const _ErrorCard({required this.info, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 32),
          const SizedBox(height: 8),
          Text(
            info.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Something went wrong',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Empty Card ─────────────────────────────────────────────────────────────

class _EmptyCard extends StatelessWidget {
  final ModuleInfo info;
  final VoidCallback? onTap;

  const _EmptyCard({required this.info, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(info.icon, color: info.color.withOpacity(0.4), size: 36),
          const SizedBox(height: 8),
          Text(
            info.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No data yet',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onTap,
            child: Text(
              'Get Started',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: info.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Disabled Card ──────────────────────────────────────────────────────────

class _DisabledCard extends StatelessWidget {
  final ModuleInfo info;
  const _DisabledCard({required this.info});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Upgrade required',
      child: Opacity(
        opacity: 0.35,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(info.icon, color: AppColors.textTertiary, size: 32),
              const SizedBox(height: 8),
              Text(
                info.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Upgrade required',
                style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
