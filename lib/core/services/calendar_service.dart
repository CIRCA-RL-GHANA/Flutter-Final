import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';

/// Service for calendar event management.
/// Maps to backend CalendarController.
class CalendarService {
  final ApiClient _api;

  CalendarService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  /// Create a new calendar event.
  Future<ApiResponse<Map<String, dynamic>>> createEvent({
    required String title,
    required String startTime,
    required String endTime,
    String? description,
    String? recurrence,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.calendar.create,
      data: {
        'title': title,
        'startTime': startTime,
        'endTime': endTime,
        if (description != null) 'description': description,
        if (recurrence != null) 'recurrence': recurrence,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get all calendar events.
  Future<ApiResponse<List<Map<String, dynamic>>>> getEvents() async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.calendar.list,
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get upcoming events within specified number of days.
  Future<ApiResponse<List<Map<String, dynamic>>>> getUpcomingEvents({
    int days = 7,
  }) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.calendar.upcoming,
      queryParameters: {'days': days},
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get all recurring events.
  Future<ApiResponse<List<Map<String, dynamic>>>> getRecurringEvents() async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.calendar.recurring,
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get events within a date range.
  Future<ApiResponse<List<Map<String, dynamic>>>> getEventsByDateRange({
    required String startDate,
    required String endDate,
  }) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.calendar.dateRange,
      queryParameters: {
        'startDate': startDate,
        'endDate': endDate,
      },
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get a single event by ID.
  Future<ApiResponse<Map<String, dynamic>>> getEventById(String id) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.calendar.byId(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Update an existing event.
  Future<ApiResponse<Map<String, dynamic>>> updateEvent(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _api.patch<Map<String, dynamic>>(
      ApiRoutes.calendar.byId(id),
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Delete a calendar event.
  Future<ApiResponse<Map<String, dynamic>>> deleteEvent(String id) async {
    return _api.delete<Map<String, dynamic>>(
      ApiRoutes.calendar.byId(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
