import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';

/// Service for all Financial Institution (FI) operations:
/// Loans, Deposits, Insurance, Credit Data.
///
/// All methods map directly to the backend FI extension controllers
/// under /api/v1/loans, /api/v1/deposits, /api/v1/insurance,
/// and /api/v1/credit-data.
class FintechService {
  final ApiClient _api;

  FintechService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  // ─── Loans ──────────────────────────────────────────────────────────────

  /// Apply for a loan from a specific FI entity.
  Future<ApiResponse<Map<String, dynamic>>> applyForLoan({
    required String fiEntityId,
    required double amountQp,
    required String purpose,
    int termDays = 30,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.loans.apply,
      data: {
        'fiEntityId': fiEntityId,
        'amountQp': amountQp,
        'purpose': purpose,
        'termDays': termDays,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get loan applications for the current user.
  Future<ApiResponse<List<Map<String, dynamic>>>> getLoanApplications() async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.loans.applications,
      fromJson: (json) =>
          (json as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  /// Get competing loan offers from all verified FIs.
  Future<ApiResponse<List<Map<String, dynamic>>>> getLoanOffers({
    required double amountQp,
    required String purpose,
  }) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.loans.offers,
      queryParameters: {'amount': amountQp, 'purpose': purpose},
      fromJson: (json) =>
          (json as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  /// Manually repay an active loan.
  Future<ApiResponse<Map<String, dynamic>>> repayLoan({
    required String applicationId,
    required double amountQp,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.loans.repay(applicationId),
      data: {'amountQp': amountQp},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ─── Deposits ───────────────────────────────────────────────────────────

  /// Lock Q-Points as a term deposit with a verified FI.
  Future<ApiResponse<Map<String, dynamic>>> createDeposit({
    required String fiEntityId,
    required double amountQp,
    required int termDays,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.deposits.create,
      data: {
        'fiEntityId': fiEntityId,
        'amountQp': amountQp,
        'termDays': termDays,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get all deposits for the current user.
  Future<ApiResponse<List<Map<String, dynamic>>>> getDeposits() async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.deposits.list,
      fromJson: (json) =>
          (json as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  // ─── Insurance ──────────────────────────────────────────────────────────

  /// Purchase an insurance policy.
  Future<ApiResponse<Map<String, dynamic>>> purchasePolicy({
    required String fiEntityId,
    required String policyType,
    required double coverageQp,
    required double premiumQp,
    required int durationDays,
    Map<String, dynamic>? metadata,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.insurance.purchasePolicy,
      data: {
        'fiEntityId': fiEntityId,
        'policyType': policyType,
        'coverageQp': coverageQp,
        'premiumQp': premiumQp,
        'durationDays': durationDays,
        if (metadata != null) 'metadata': metadata,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get all insurance policies for the current user.
  Future<ApiResponse<List<Map<String, dynamic>>>> getPolicies() async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.insurance.policies,
      fromJson: (json) =>
          (json as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  /// File an insurance claim.
  Future<ApiResponse<Map<String, dynamic>>> fileClaim({
    required String policyId,
    required double amountClaimedQp,
    required String description,
    List<Map<String, dynamic>>? attachments,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.insurance.fileClaim,
      data: {
        'policyId': policyId,
        'amountClaimedQp': amountClaimedQp,
        'description': description,
        if (attachments != null) 'attachments': attachments,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get all insurance claims for the current user.
  Future<ApiResponse<List<Map<String, dynamic>>>> getClaims() async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.insurance.claims,
      fromJson: (json) =>
          (json as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  // ─── Credit Data ─────────────────────────────────────────────────────────

  /// Request a credit score for a subject user (FI only, requires consent).
  Future<ApiResponse<Map<String, dynamic>>> requestCreditScore({
    required String subjectUserId,
    required String consentId,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.creditData.score,
      data: {
        'subjectUserId': subjectUserId,
        'consentId': consentId,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Subscribe to a credit data plan tier.
  Future<ApiResponse<Map<String, dynamic>>> subscribeToCreditData({
    required String planTier,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.creditData.subscribe,
      data: {'planTier': planTier},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
