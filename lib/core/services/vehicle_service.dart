import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';

/// Service for vehicle management.
/// Maps to backend VehiclesController.
class VehicleService {
  final ApiClient _api;

  VehicleService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  /// Create a new vehicle.
  Future<ApiResponse<Map<String, dynamic>>> createVehicle(
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.vehicles.create,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get paginated list of vehicles.
  Future<ApiResponse<List<Map<String, dynamic>>>> getVehicles({
    int page = 1,
    int limit = 20,
  }) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.vehicles.list,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get a vehicle by ID.
  Future<ApiResponse<Map<String, dynamic>>> getVehicleById(String id) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.vehicles.byId(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Update an existing vehicle.
  Future<ApiResponse<Map<String, dynamic>>> updateVehicle(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _api.patch<Map<String, dynamic>>(
      ApiRoutes.vehicles.byId(id),
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Delete a vehicle by ID.
  Future<ApiResponse<Map<String, dynamic>>> deleteVehicle(String id) async {
    return _api.delete<Map<String, dynamic>>(
      ApiRoutes.vehicles.byId(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Update vehicle status.
  Future<ApiResponse<Map<String, dynamic>>> updateStatus({
    required String id,
    required String status,
  }) async {
    return _api.patch<Map<String, dynamic>>(
      ApiRoutes.vehicles.updateStatus(id),
      data: {'status': status},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get paginated list of vehicle bands.
  Future<ApiResponse<List<Map<String, dynamic>>>> getBands({
    int page = 1,
    int limit = 20,
  }) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.vehicles.bands,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get paginated list of vehicle assignments.
  Future<ApiResponse<List<Map<String, dynamic>>>> getAssignments({
    int page = 1,
    int limit = 20,
  }) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.vehicles.assignments,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Update a vehicle band.
  Future<ApiResponse<Map<String, dynamic>>> updateBand(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.vehicles.bandById(id),
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Delete a vehicle band.
  Future<ApiResponse<Map<String, dynamic>>> deleteBand(String id) async {
    return _api.delete<Map<String, dynamic>>(
      ApiRoutes.vehicles.bandById(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Add a vehicle band membership.
  Future<ApiResponse<Map<String, dynamic>>> addBandMembership(
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.vehicles.bandMemberships,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Remove a vehicle band membership.
  Future<ApiResponse<Map<String, dynamic>>> removeBandMembership(
    String id,
  ) async {
    return _api.delete<Map<String, dynamic>>(
      ApiRoutes.vehicles.bandMembershipById(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get vehicles in a specific band.
  Future<ApiResponse<List<Map<String, dynamic>>>> getVehiclesByBand(
    String bandId,
  ) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.vehicles.vehiclesByBand(bandId),
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get all bands for a vehicle.
  Future<ApiResponse<List<Map<String, dynamic>>>> getVehicleBands(
    String vehicleId,
  ) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.vehicles.vehicleBands(vehicleId),
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// End a vehicle assignment.
  Future<ApiResponse<Map<String, dynamic>>> endAssignment(String id) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.vehicles.endAssignment(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get active assignment for a driver.
  Future<ApiResponse<Map<String, dynamic>>> getDriverActiveAssignment(
    String driverId,
  ) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.vehicles.driverActiveAssignment(driverId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get active assignment for a vehicle.
  Future<ApiResponse<Map<String, dynamic>>> getVehicleActiveAssignment(
    String vehicleId,
  ) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.vehicles.vehicleActiveAssignment(vehicleId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Delete vehicle media.
  Future<ApiResponse<Map<String, dynamic>>> deleteMedia(String id) async {
    return _api.delete<Map<String, dynamic>>(
      ApiRoutes.vehicles.deleteMedia(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get pricing by ID.
  Future<ApiResponse<Map<String, dynamic>>> getPricingById(String id) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.vehicles.pricingById(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Update pricing.
  Future<ApiResponse<Map<String, dynamic>>> updatePricing(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.vehicles.pricingById(id),
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Delete pricing.
  Future<ApiResponse<Map<String, dynamic>>> deletePricing(String id) async {
    return _api.delete<Map<String, dynamic>>(
      ApiRoutes.vehicles.pricingById(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Calculate wait charge.
  Future<ApiResponse<Map<String, dynamic>>> calculateWaitCharge(
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.vehicles.calculateWaitCharge,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Create a new vehicle band.
  Future<ApiResponse<Map<String, dynamic>>> createBand(
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.vehicles.createBand,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get a vehicle band by ID.
  Future<ApiResponse<Map<String, dynamic>>> getBandById(String id) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.vehicles.bandById(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get a vehicle by plate number.
  Future<ApiResponse<Map<String, dynamic>>> getVehicleByPlateNumber(
    String plateNumber,
  ) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.vehicles.byPlate(plateNumber),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Assign a vehicle to a driver.
  Future<ApiResponse<Map<String, dynamic>>> assignVehicle(
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.vehicles.assignments,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get an assignment by ID.
  Future<ApiResponse<Map<String, dynamic>>> getAssignmentById(
    String id,
  ) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.vehicles.assignmentById(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Update an assignment.
  Future<ApiResponse<Map<String, dynamic>>> updateAssignment(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.vehicles.assignmentById(id),
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Upload vehicle media.
  Future<ApiResponse<Map<String, dynamic>>> uploadMedia(
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.vehicles.media,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get media for a vehicle.
  Future<ApiResponse<List<Map<String, dynamic>>>> getMediaForVehicle(
    String vehicleId,
  ) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.vehicles.mediaByVehicle(vehicleId),
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Create vehicle pricing.
  Future<ApiResponse<Map<String, dynamic>>> createPricing(
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.vehicles.pricing,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get all vehicle pricing.
  Future<ApiResponse<List<Map<String, dynamic>>>> getPricing() async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.vehicles.pricing,
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Remove a band membership by ID.
  Future<ApiResponse<Map<String, dynamic>>> removeMembershipById(
    String id,
  ) async {
    return _api.delete<Map<String, dynamic>>(
      ApiRoutes.vehicles.bandMembershipById(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
