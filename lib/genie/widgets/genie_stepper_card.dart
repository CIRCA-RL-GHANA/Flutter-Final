/// ═══════════════════════════════════════════════════════════════════════════
/// GenieStepperCard
///
/// Inline stepper card that displays real-time orchestration progress.
/// Subscribes to [GenieOutbox.progressStream] and highlights the current step.
/// Provides a Cancel button that triggers rollback via [onCancel].
///
/// Recommendation 4 — User-Visible Progress with rollback.
/// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/material.dart';

import '../genie_outbox.dart';

class GenieStepperCard extends StatefulWidget {
  final OutboxOrchestration orchestration;
  final VoidCallback? onCancel;
  final VoidCallback? onCompleted;

  const GenieStepperCard({
    super.key,
    required this.orchestration,
    this.onCancel,
    this.onCompleted,
  });

  @override
  State<GenieStepperCard> createState() => _GenieStepperCardState();
}

class _GenieStepperCardState extends State<GenieStepperCard> {
  late OutboxOrchestration _orch;
  StreamSubscription<OutboxProgressEvent>? _sub;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _orch = widget.orchestration;
    _sub = GenieOutbox.progressStream.listen(_onProgress);
  }

  void _onProgress(OutboxProgressEvent event) {
    if (event.orchestrationId != _orch.id) return;
    if (!mounted) return;
    setState(() {
      _statusMessage = event.message;
      // Refresh orchestration steps from the event payload
      if (event.stepIndex < _orch.steps.length) {
        _orch.steps[event.stepIndex].status = event.stepStatus;
      }
      _orch.currentStepIndex = event.stepIndex;
      _orch.status = event.overallStatus;
    });

    if (_orch.isComplete) {
      widget.onCompleted?.call();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isComplete = _orch.isComplete;
    final failed = _orch.status == OutboxOrchestrationStatus.failed ||
        _orch.status == OutboxOrchestrationStatus.rolledBack ||
        _orch.status == OutboxOrchestrationStatus.partialFailure;
    final success = _orch.status == OutboxOrchestrationStatus.completed;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _cardColor(success, failed).withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: _cardColor(success, failed).withOpacity(0.35)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(_headerIcon(success, failed),
                  color: _cardColor(success, failed), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _orch.description,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _cardColor(success, failed),
                    fontSize: 13,
                  ),
                ),
              ),
              if (!isComplete)
                TextButton.icon(
                  onPressed: widget.onCancel,
                  icon: const Icon(Icons.close_rounded, size: 15),
                  label: const Text('Cancel'),
                  style: TextButton.styleFrom(
                    foregroundColor: cs.error,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Step list
          ..._orch.steps.asMap().entries.map((e) {
            final i = e.key;
            final step = e.value;
            final isCurrent = i == _orch.currentStepIndex && !isComplete;
            return _StepRow(
              step: step,
              isCurrent: isCurrent,
              stepNumber: i + 1,
            );
          }),

          // Status / compensation message
          if (_statusMessage != null) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: _cardColor(success, failed).withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _statusMessage!,
                style: TextStyle(
                  fontSize: 12,
                  color: _cardColor(success, failed),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _cardColor(bool success, bool failed) {
    if (success) return const Color(0xFF4CAF50);
    if (failed) return const Color(0xFFF44336);
    return const Color(0xFF3F51B5);
  }

  IconData _headerIcon(bool success, bool failed) {
    if (success) return Icons.check_circle_rounded;
    if (failed) return Icons.error_rounded;
    return Icons.pending_actions_rounded;
  }
}

class _StepRow extends StatelessWidget {
  final OutboxStep step;
  final bool isCurrent;
  final int stepNumber;

  const _StepRow({
    required this.step,
    required this.isCurrent,
    required this.stepNumber,
  });

  @override
  Widget build(BuildContext context) {
    final color = _stepColor();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Step indicator circle
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCurrent ? color : color.withOpacity(0.18),
              border: Border.all(color: color.withOpacity(0.6)),
            ),
            child: Center(
              child: _stepIcon(),
            ),
          ),
          const SizedBox(width: 10),
          // Description
          Expanded(
            child: Text(
              step.description,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight:
                    isCurrent ? FontWeight.w600 : FontWeight.normal,
                color: isCurrent ? color : Colors.black87,
              ),
            ),
          ),
          if (isCurrent)
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: color),
            ),
        ],
      ),
    );
  }

  Color _stepColor() {
    switch (step.status) {
      case OutboxStepStatus.completed:
        return const Color(0xFF4CAF50);
      case OutboxStepStatus.failed:
        return const Color(0xFFF44336);
      case OutboxStepStatus.compensated:
        return const Color(0xFFFF9800);
      case OutboxStepStatus.running:
        return const Color(0xFF3F51B5);
      case OutboxStepStatus.pending:
        return Colors.black38;
    }
  }

  Widget _stepIcon() {
    switch (step.status) {
      case OutboxStepStatus.completed:
        return const Icon(Icons.check_rounded, size: 13, color: Colors.white);
      case OutboxStepStatus.failed:
        return const Icon(Icons.close_rounded, size: 13, color: Colors.white);
      case OutboxStepStatus.compensated:
        return const Icon(Icons.undo_rounded, size: 13, color: Colors.white);
      case OutboxStepStatus.running:
        return const Icon(Icons.arrow_forward_rounded,
            size: 13, color: Colors.white);
      case OutboxStepStatus.pending:
        return Text(
          '$stepNumber',
          style: const TextStyle(fontSize: 10, color: Colors.black54),
        );
    }
  }
}
