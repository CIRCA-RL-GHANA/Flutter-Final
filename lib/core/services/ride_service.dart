import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';
import 'ai_service.dart';

/// Service for ride operations.
/// Maps to backend RidesController.
/// Extends basic ride management with AI-powered pricing and safety features.
class RideService {
  final ApiClient _api;
  final AIService _aiService;

  RideService([ApiClient? api, AIService? aiService])
      : _api = api ?? ApiClient.instance,
        _aiService = aiService ?? AIService();

  /// Create a new ride request.
  Future<ApiResponse<Map<String, dynamic>>> createRide({
    required Map<String, dynamic> pickupLocation,
    required Map<String, dynamic> dropoffLocation,
    required String vehicleType,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.rides.create,
      data: {
        'pickupLocation': pickupLocation,
        'dropoffLocation': dropoffLocation,
        'vehicleType': vehicleType,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get a ride by ID.
  Future<ApiResponse<Map<String, dynamic>>> getRide(String id) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.rides.byId(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get rides for a specific user.
  Future<ApiResponse<List<Map<String, dynamic>>>> getUserRides({
    required String userId,
    int limit = 20,
  }) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.rides.byUser(userId),
      queryParameters: {'limit': limit},
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Assign a driver and vehicle to a ride.
  Future<ApiResponse<Map<String, dynamic>>> assignDriver({
    required String rideId,
    required String driverId,
    required String vehicleId,
  }) async {
    return _api.patch<Map<String, dynamic>>(
      ApiRoutes.rides.assignDriver(rideId),
      data: {
        'driverId': driverId,
        'vehicleId': vehicleId,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Update the status of a ride.
  Future<ApiResponse<Map<String, dynamic>>> updateRideStatus({
    required String rideId,
    required String status,
  }) async {
    return _api.patch<Map<String, dynamic>>(
      ApiRoutes.rides.updateStatus(rideId),
      data: {'status': status},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Track a ride with location update.
  Future<ApiResponse<Map<String, dynamic>>> trackRide({
    required String rideId,
    required Map<String, dynamic> location,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.rides.track(rideId),
      data: {'location': location},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Create feedback for a completed ride.
  Future<ApiResponse<Map<String, dynamic>>> createFeedback({
    required String rideId,
    required int rating,
    String? comment,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.rides.feedback,
      data: {
        'rideId': rideId,
        'rating': rating,
        if (comment != null) 'comment': comment,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// End wait time for a ride.
  Future<ApiResponse<Map<String, dynamic>>> endWaitTime(String id) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.rides.waitTimeEnd(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Complete a ride referral.
  Future<ApiResponse<Map<String, dynamic>>> completeReferral(
    String id,
  ) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.rides.completeReferral(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Resolve a ride SOS alert.
  Future<ApiResponse<Map<String, dynamic>>> resolveSOS(String id) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.rides.resolveSOS(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Verify rider PIN for a ride.
  Future<ApiResponse<Map<String, dynamic>>> verifyRiderPin({
    required String id,
    required String pin,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.rides.verifyRiderPin(id),
      data: {'pin': pin},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Verify driver PIN for a ride.
  Future<ApiResponse<Map<String, dynamic>>> verifyDriverPin({
    required String id,
    required String pin,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.rides.verifyDriverPin(id),
      data: {'pin': pin},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get tracking data for a ride.
  Future<ApiResponse<Map<String, dynamic>>> getRideTracking(String id) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.rides.tracking(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Start wait time for a ride.
  Future<ApiResponse<Map<String, dynamic>>> startWaitTime(
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.rides.waitTimeStart,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Create a ride referral.
  Future<ApiResponse<Map<String, dynamic>>> createReferral(
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.rides.referrals,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Create an SOS alert for a ride.
  Future<ApiResponse<Map<String, dynamic>>> createSOSAlert(
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.rides.sos,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get feedback for a ride.
  Future<ApiResponse<Map<String, dynamic>>> getRideFeedback(
    String id,
  ) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.rides.feedbackByRide(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // AI-ENHANCED METHODS
  // ═══════════════════════════════════════════════════════════════════════

  /// Get AI-computed dynamic pricing for a ride with surge multiplier.
  /// Returns basePrice, surgeMultiplier, finalPrice, and pricing factors.
  Future<ApiResponse<Map<String, dynamic>>> getAIDynamicPricing({
    required double baseDistance,
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
    String? rideType,
    double demandFactor = 1.0,
    double supplyFactor = 1.0,
  }) {
    return _aiService.computeRidePrice(
      baseDistance: baseDistance,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      dropoffLat: dropoffLat,
      dropoffLng: dropoffLng,
      rideType: rideType,
      demandFactor: demandFactor,
      supplyFactor: supplyFactor,
    );
  }

  /// Analyze ride feedback sentiment using AI NLP.
  /// Returns sentiment score (-1 to +1), label, and confidence.
  Future<ApiResponse<Map<String, dynamic>>> analyzeRideFeedbackSentiment(
    String feedbackText,
  ) {
    return _aiService.analyzeSentiment(feedbackText);
  }

  /// Get AI-powered ride route optimization suggestions.
  /// Summarizes route considerations based on input coordinates.
  Future<ApiResponse<Map<String, dynamic>>> getRouteOptimization({
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
  }) {
    final routeDescription =
        'Route from ($pickupLat, $pickupLng) to ($dropoffLat, $dropoffLng)';
    return _aiService.detectIntent(routeDescription);
  }
}
