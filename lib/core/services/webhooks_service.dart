import '../network/api_client.dart';
import '../network/api_response.dart';

/// Webhook subscription management.
/// Maps to POST/GET/DELETE /webhooks/subscriptions.
/// Available to ENTERPRISE_ADMIN, ENTERPRISE_OPERATOR, FINANCIAL_INSTITUTION, ADMIN.
class WebhooksService {
  final ApiClient _api;

  WebhooksService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  /// Subscribe to webhook events for an entity.
  Future<ApiResponse<Map<String, dynamic>>> subscribe({
    required String entityId,
    required String url,
    required List<String> events,
    String? secret,
  }) {
    return _api.post<Map<String, dynamic>>(
      '/webhooks/subscriptions',
      data: {
        'entityId': entityId,
        'url': url,
        'events': events,
        if (secret != null) 'secret': secret,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// List all webhook subscriptions for an entity.
  Future<ApiResponse<List<dynamic>>> listSubscriptions(String entityId) {
    return _api.get<List<dynamic>>(
      '/webhooks/subscriptions/$entityId',
      fromJson: (json) => json as List<dynamic>,
    );
  }

  /// Delete a webhook subscription.
  Future<ApiResponse<void>> deleteSubscription(
    String entityId,
    String subscriptionId,
  ) {
    return _api.delete<void>(
      '/webhooks/subscriptions/$entityId/$subscriptionId',
    );
  }
}
