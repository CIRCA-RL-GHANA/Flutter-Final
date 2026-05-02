import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';

/// Service for all Genie for Enterprise operations:
/// Enterprise onboarding, API keys, multi-channel sync, fulfillment routing,
/// and agentic concierge sessions.
///
/// Methods map directly to the enterprise extension controllers under
/// /api/v1/enterprise, /api/v1/multi-channel, /api/v1/fulfillment,
/// and /api/v1/concierge.
class EnterpriseService {
  final ApiClient _api;

  EnterpriseService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  // ─── Enterprise Profiles ──────────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> registerEnterprise({
    required String legalName,
    required String enterpriseType,
    String? taxId,
    String? licenceDocumentUrl,
    String? webhookUrl,
    List<int> enabledPathways = const [],
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.enterprise.register,
      data: {
        'legalName': legalName,
        'enterpriseType': enterpriseType,
        if (taxId != null) 'taxId': taxId,
        if (licenceDocumentUrl != null) 'licenceDocumentUrl': licenceDocumentUrl,
        if (webhookUrl != null) 'webhookUrl': webhookUrl,
        'enabledPathways': enabledPathways,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> listProfiles() async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.enterprise.profiles,
      fromJson: (json) =>
          (json as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getProfile(String entityId) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.enterprise.profile(entityId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateSettings(
    String entityId, {
    String? webhookUrl,
    Map<String, dynamic>? settings,
    List<int>? enabledPathways,
  }) async {
    return _api.patch<Map<String, dynamic>>(
      ApiRoutes.enterprise.settings(entityId),
      data: {
        if (webhookUrl != null) 'webhookUrl': webhookUrl,
        if (settings != null) 'settings': settings,
        if (enabledPathways != null) 'enabledPathways': enabledPathways,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ─── API Keys ─────────────────────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> createApiKey(
    String entityId, {
    required String label,
    required List<String> permissions,
    DateTime? expiresAt,
    List<String> ipWhitelist = const [],
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.enterprise.apiKeys(entityId),
      data: {
        'label': label,
        'permissions': permissions,
        if (expiresAt != null) 'expiresAt': expiresAt.toIso8601String(),
        'ipWhitelist': ipWhitelist,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> listApiKeys(String entityId) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.enterprise.apiKeys(entityId),
      fromJson: (json) =>
          (json as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  Future<ApiResponse<void>> revokeApiKey(String entityId, String keyId) async {
    return _api.delete<void>(
      ApiRoutes.enterprise.revokeKey(entityId, keyId),
      fromJson: (_) {},
    );
  }

  // ─── Multi-Channel ────────────────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> registerChannel({
    required String entityId,
    required String channelType,
    required String channelName,
    Map<String, dynamic>? credentials,
    String? webhookUrl,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.multiChannel.channels,
      data: {
        'entityId': entityId,
        'channelType': channelType,
        'channelName': channelName,
        if (credentials != null) 'credentials': credentials,
        if (webhookUrl != null) 'webhookUrl': webhookUrl,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> listChannels(String entityId) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.multiChannel.listChannels(entityId),
      fromJson: (json) =>
          (json as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> syncChannel(
    String channelId, {
    bool fullResync = false,
  }) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.multiChannel.syncChannel(channelId),
      data: {'fullResync': fullResync},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ─── Fulfillment ──────────────────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> createRoutingRule({
    required String entityId,
    required String primaryProvider,
    String? regionCode,
    String? channelType,
    List<String> fallbackProviders = const [],
    int priority = 100,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.fulfillment.rules,
      data: {
        'entityId': entityId,
        'primaryProvider': primaryProvider,
        if (regionCode != null) 'regionCode': regionCode,
        if (channelType != null) 'channelType': channelType,
        'fallbackProviders': fallbackProviders,
        'priority': priority,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> listFulfillmentTasks(String entityId) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.fulfillment.listTasks(entityId),
      fromJson: (json) =>
          (json as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> dispatchFulfillment({
    required String entityId,
    String? orderId,
    String? overrideProvider,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.fulfillment.tasks,
      data: {
        'entityId': entityId,
        if (orderId != null) 'orderId': orderId,
        if (overrideProvider != null) 'overrideProvider': overrideProvider,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ─── Agentic Concierge ────────────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> createConciergeSession({
    required String entityId,
    required String endUserId,
    String? topic,
    Map<String, dynamic>? context,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.concierge.sessions,
      data: {
        'entityId': entityId,
        'endUserId': endUserId,
        if (topic != null) 'topic': topic,
        if (context != null) 'context': context,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> sendConciergeMessage(
    String sessionId,
    String message, {
    Map<String, dynamic>? context,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.concierge.sendMessage(sessionId),
      data: {
        'message': message,
        if (context != null) 'context': context,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getConciergeHistory(String sessionId) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.concierge.history(sessionId),
      fromJson: (json) =>
          (json as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> closeConciergeSession(String sessionId) async {
    return _api.delete<Map<String, dynamic>>(
      ApiRoutes.concierge.closeSession(sessionId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ─── Pathway 1: QP Charge ─────────────────────────────────────────────────

  Future<Map<String, dynamic>> chargeQp({
    required String customerId,
    required String merchantEntityId,
    required double amount,
    String? orderReference,
    Map<String, dynamic>? metadata,
  }) async {
    final resp = await _api.post<Map<String, dynamic>>(
      '/api/v1/payments/qp/charge',
      body: {
        'customerId': customerId,
        'merchantEntityId': merchantEntityId,
        'amount': amount,
        if (orderReference != null) 'orderReference': orderReference,
        if (metadata != null) 'metadata': metadata,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (resp.data == null) throw Exception(resp.message ?? 'QP charge failed');
    return resp.data!;
  }

  // ─── Pathway 5: Facilitator Institutions ─────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> getInstitutionBalance(String entityId) async {
    return _api.get<Map<String, dynamic>>(
      '/api/v1/facilitator/institutions/$entityId/balance',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> issueQp({
    required String entityId,
    required double amount,
    String? reason,
  }) async {
    return _api.post<Map<String, dynamic>>(
      '/api/v1/facilitator/institutions/issue',
      body: {'entityId': entityId, 'amount': amount, if (reason != null) 'reason': reason},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> initiateSettlement({
    required String fromEntityId,
    required String toEntityId,
    required double amount,
    String? reference,
  }) async {
    return _api.post<Map<String, dynamic>>(
      '/api/v1/qpoints/settlement/initiate',
      body: {
        'fromEntityId': fromEntityId,
        'toEntityId': toEntityId,
        'amount': amount,
        if (reference != null) 'reference': reference,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ─── Webhooks ─────────────────────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> subscribeWebhook({
    required String entityId,
    required String url,
    required List<String> events,
  }) async {
    return _api.post<Map<String, dynamic>>(
      '/api/v1/webhooks/subscriptions',
      body: {'entityId': entityId, 'url': url, 'events': events},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> listWebhookSubscriptions(
      String entityId) async {
    return _api.get<List<Map<String, dynamic>>>(
      '/api/v1/webhooks/subscriptions/$entityId',
      fromJson: (json) =>
          (json as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }
}

