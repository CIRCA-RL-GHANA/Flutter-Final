import 'package:flutter/material.dart';
import '../core/services/enterprise_service.dart';

/// Pathway 1 — Embeddable Q-Points payment button.
///
/// Usage:
/// ```dart
/// GeniePaymentButton(
///   merchantEntityId: 'ent_123',
///   amount: 100,
///   orderReference: 'EXT-ORDER-789',
///   onSuccess: (transactionId) => print('Paid! $transactionId'),
///   onError: (err) => print('Error: $err'),
/// )
/// ```
class GeniePaymentButton extends StatefulWidget {
  const GeniePaymentButton({
    super.key,
    required this.merchantEntityId,
    required this.amount,
    required this.customerId,
    this.orderReference,
    this.metadata,
    this.onSuccess,
    this.onError,
    this.label = 'Pay with Q-Points',
    this.color,
  });

  final String merchantEntityId;
  final double amount;
  final String customerId;
  final String? orderReference;
  final Map<String, dynamic>? metadata;
  final void Function(String transactionId)? onSuccess;
  final void Function(String error)? onError;
  final String label;
  final Color? color;

  @override
  State<GeniePaymentButton> createState() => _GeniePaymentButtonState();
}

class _GeniePaymentButtonState extends State<GeniePaymentButton> {
  bool _loading = false;
  String? _result;

  Future<void> _handlePay() async {
    setState(() {
      _loading = true;
      _result = null;
    });

    try {
      final svc = EnterpriseService();
      final resp = await svc.chargeQp(
        customerId: widget.customerId,
        merchantEntityId: widget.merchantEntityId,
        amount: widget.amount,
        orderReference: widget.orderReference,
        metadata: widget.metadata,
      );
      setState(() => _result = 'Paid ${widget.amount} QP');
      widget.onSuccess?.call(resp['transactionId'] as String);
    } catch (e) {
      setState(() => _result = 'Payment failed');
      widget.onError?.call(e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: _loading ? null : _handlePay,
          icon: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.currency_exchange_rounded, size: 18),
          label: Text(widget.label),
          style: FilledButton.styleFrom(
            backgroundColor: widget.color ?? const Color(0xFF6C3CE1),
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        if (_result != null) ...[
          const SizedBox(height: 6),
          Text(
            _result!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: _result!.startsWith('Paid')
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
          ),
        ],
      ],
    );
  }
}
