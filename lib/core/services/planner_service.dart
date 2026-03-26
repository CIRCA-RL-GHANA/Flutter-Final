import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';
import 'ai_service.dart';

/// Service for financial planner / budget tracking.
/// Maps to backend PlannerController.
/// Extends basic finance CRUD with AI-powered insights and forecasting.
class PlannerService {
  final ApiClient _api;
  final AIService _aiService;

  PlannerService([ApiClient? api, AIService? aiService])
      : _api = api ?? ApiClient.instance,
        _aiService = aiService ?? AIService();

  /// Add a new financial transaction.
  Future<ApiResponse<Map<String, dynamic>>> addTransaction({
    required String type,
    required double amount,
    required String category,
    String? description,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.planner.transactions,
      data: {
        'type': type,
        'amount': amount,
        'category': category,
        if (description != null) 'description': description,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get all financial transactions.
  Future<ApiResponse<List<Map<String, dynamic>>>> getTransactions() async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.planner.transactions,
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get transactions filtered by type (income/expense).
  Future<ApiResponse<List<Map<String, dynamic>>>> getTransactionsByType(
    String type,
  ) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.planner.byType(type),
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get transactions for a specific month and year.
  Future<ApiResponse<List<Map<String, dynamic>>>> getTransactionsByMonth({
    required int month,
    required int year,
  }) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.planner.monthly,
      queryParameters: {
        'month': month,
        'year': year,
      },
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get overall financial summary.
  Future<ApiResponse<Map<String, dynamic>>> getSummary() async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.planner.summary,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get financial summary for a specific month.
  Future<ApiResponse<Map<String, dynamic>>> getMonthlySummary({
    required int month,
    required int year,
  }) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.planner.monthlySummary,
      queryParameters: {
        'month': month,
        'year': year,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get a single transaction by ID.
  Future<ApiResponse<Map<String, dynamic>>> getTransactionById(
    String id,
  ) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.planner.transactionById(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Update an existing transaction.
  Future<ApiResponse<Map<String, dynamic>>> updateTransaction(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _api.patch<Map<String, dynamic>>(
      ApiRoutes.planner.transactionById(id),
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Delete a transaction.
  Future<ApiResponse<Map<String, dynamic>>> deleteTransaction(
    String id,
  ) async {
    return _api.delete<Map<String, dynamic>>(
      ApiRoutes.planner.transactionById(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // AI-ENHANCED METHODS
  // ═══════════════════════════════════════════════════════════════════════

  /// Get AI-generated financial insights from current transactions.
  /// Analyzes spending patterns, anomalies, and savings opportunities.
  Future<ApiResponse<List<Map<String, dynamic>>>> getAIFinancialInsights() {
    return _aiService.getPlannerInsights();
  }

  /// Get AI spending pattern analysis from transactions.
  /// Identifies categories, trends, and budget suggestions.
  Future<ApiResponse<Map<String, dynamic>>> getAISpendingPattern() {
    return _aiService.getPlannerSpending();
  }

  /// Get AI income/revenue forecast for future periods.
  /// Predicts 7-day and 30-day outlook based on historical data.
  Future<ApiResponse<Map<String, dynamic>>> getAIForecast() {
    return _aiService.getPlannerForecast();
  }

  /// Get detailed AI spending analysis from custom transaction list.
  Future<ApiResponse<Map<String, dynamic>>> analyzeSpendingPattern(
    List<Map<String, dynamic>> transactions,
  ) {
    return _aiService.getSpendingPattern(transactions);
  }

  /// Get AI revenue forecast from daily sales data.
  Future<ApiResponse<Map<String, dynamic>>> forecastRevenue(
    List<Map<String, dynamic>> dailySales,
  ) {
    return _aiService.getRevenueForecast(dailySales);
  }

  /// Extract keywords from transaction descriptions for categorization.
  Future<ApiResponse<Map<String, dynamic>>> categorizeTransaction(
    String description, {
    int topN = 5,
  }) {
    return _aiService.extractKeywords(description, topN: topN);
  }
}
