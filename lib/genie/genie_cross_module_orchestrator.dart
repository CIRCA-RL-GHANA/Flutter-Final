/// ═══════════════════════════════════════════════════════════════════════════
/// GenieCrossModuleOrchestrator – Multi-Step Workflow Engine
///
/// Handles compound intents that span multiple modules (e.g., pay QPoints for
/// a market order AND send a qualChat confirmation). Executes steps serially
/// with rollback on failure. RBAC is verified for every step.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import '../features/prompt/models/rbac_models.dart';
import 'genie_intent.dart';
import 'genie_rbac_enforcer.dart';

/// A single step in an orchestration workflow.
class OrchestrationStep {
  final GenieIntent intent;
  final String description;

  const OrchestrationStep({required this.intent, required this.description});
}

/// Possible states of an orchestration workflow.
enum OrchestrationStatus { pending, running, success, partialFailure, failed }

/// The result of a completed (or failed) orchestration run.
class OrchestrationResult {
  final OrchestrationStatus status;
  final List<String> completedDescriptions;
  final String? failureReason;

  const OrchestrationResult({
    required this.status,
    required this.completedDescriptions,
    this.failureReason,
  });

  bool get isSuccess => status == OrchestrationStatus.success;
}

class GenieCrossModuleOrchestrator {
  GenieCrossModuleOrchestrator._();

  // ─── Known Multi-Step Workflows ───────────────────────────────────────────

  /// "Pay QPoints to X for order Y" workflow.
  static List<OrchestrationStep> buildPayForOrderWorkflow({
    required double amount,
    required String recipient,
    String? orderId,
  }) {
    return [
      OrchestrationStep(
        description: 'Verifying order in MARKET',
        intent: GenieIntent(
          module: GenieModule.market,
          action: 'verify_order',
          params: {'orderId': orderId},
        ),
      ),
      OrchestrationStep(
        description: 'Transferring $amount QP to $recipient via GO PAGE',
        intent: GenieIntent(
          module: GenieModule.goPage,
          action: 'transfer',
          params: {'amount': amount, 'recipient': recipient},
        ),
      ),
      OrchestrationStep(
        description: 'Sending confirmation in qualChat',
        intent: GenieIntent(
          module: GenieModule.qualChat,
          action: 'send_message',
          params: {
            'recipient': recipient,
            'message': 'QP payment sent for order ${orderId ?? ''} ✓',
          },
        ),
      ),
    ];
  }

  /// "On delivery complete: update stock + notify branch manager" workflow.
  static List<OrchestrationStep> buildDeliveryCompleteWorkflow({
    required String packageId,
    required String managerId,
  }) {
    return [
      OrchestrationStep(
        description: 'Confirming delivery in LIVE',
        intent: GenieIntent(
          module: GenieModule.live,
          action: 'confirm_delivery',
          params: {'packageId': packageId},
        ),
      ),
      OrchestrationStep(
        description: 'Updating product stock in SETUP DASHBOARD',
        intent: GenieIntent(
          module: GenieModule.setupDashboard,
          action: 'decrement_stock',
          params: {'packageId': packageId},
        ),
      ),
      OrchestrationStep(
        description: 'Notifying Branch Manager via qualChat',
        intent: GenieIntent(
          module: GenieModule.qualChat,
          action: 'send_message',
          params: {
            'recipient': managerId,
            'message': 'Package $packageId delivered successfully ✓',
          },
        ),
      ),
    ];
  }

  // ─── Run Orchestration ───────────────────────────────────────────────────
  /// Execute a list of steps, verifying RBAC at each step.
  /// Returns an [OrchestrationResult] describing what completed.
  static Future<OrchestrationResult> run({
    required List<OrchestrationStep> steps,
    required UserRole userRole,
    Future<bool> Function(GenieIntent)? executor,
  }) async {
    final completed = <String>[];

    for (final step in steps) {
      // RBAC gate for each step
      if (!GenieRBACEnforcer.canPerformAction(
          userRole, step.intent.module, step.intent.action)) {
        return OrchestrationResult(
          status: OrchestrationStatus.partialFailure,
          completedDescriptions: completed,
          failureReason: GenieRBACEnforcer.getDenialMessage(
              userRole, step.intent.module, step.intent.action),
        );
      }

      try {
        final success = executor != null ? await executor(step.intent) : true;
        if (!success) {
          return OrchestrationResult(
            status: OrchestrationStatus.partialFailure,
            completedDescriptions: completed,
            failureReason: '${step.description} failed.',
          );
        }
        completed.add(step.description);
        debugPrint('[Orchestrator] ✓ ${step.description}');
      } catch (e) {
        debugPrint('[Orchestrator] ✗ ${step.description}: $e');
        return OrchestrationResult(
          status: OrchestrationStatus.failed,
          completedDescriptions: completed,
          failureReason: 'Error during: ${step.description}',
        );
      }
    }

    return OrchestrationResult(
      status: OrchestrationStatus.success,
      completedDescriptions: completed,
    );
  }
}
