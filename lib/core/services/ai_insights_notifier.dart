import 'package:flutter/foundation.dart';
import 'ai_service.dart';

/// ChangeNotifier that drives AI insights state across the app.
/// Consumed by Riverpod providers or Provider widgets.
class AIInsightsNotifier extends ChangeNotifier {
  final AIService _aiService;

  AIInsightsNotifier([AIService? service]) : _aiService = service ?? AIService();

  // ── Planner financial insights ────────────────────────────────────────
  List<Map<String, dynamic>> _insights       = [];
  Map<String, dynamic>?      _spendingPattern;
  Map<String, dynamic>?      _forecast;

  // ── Recommendations ───────────────────────────────────────────────────
  List<Map<String, dynamic>> _recommendations = [];

  // ── Smart search ──────────────────────────────────────────────────────
  List<Map<String, dynamic>> _searchResults  = [];
  String                     _lastQuery      = '';

  // ── State flags ───────────────────────────────────────────────────────
  bool    _loadingInsights = false;
  bool    _loadingSearch   = false;
  String? _error;

  List<Map<String, dynamic>> get insights        => _insights;
  Map<String, dynamic>?      get spendingPattern => _spendingPattern;
  Map<String, dynamic>?      get forecast        => _forecast;
  List<Map<String, dynamic>> get recommendations => _recommendations;
  List<Map<String, dynamic>> get searchResults   => _searchResults;
  String                     get lastQuery       => _lastQuery;
  bool                       get loadingInsights => _loadingInsights;
  bool                       get loadingSearch   => _loadingSearch;
  String?                    get error           => _error;

  // ─────────────────────────────────────────────────────────────────────────
  // FINANCIAL INSIGHTS
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> loadPlannerInsights() async {
    _loadingInsights = true;
    _error = null;
    notifyListeners();

    try {
      final resp = await _aiService.getPlannerInsights();
      if (resp.isSuccess && resp.data != null) {
        _insights = resp.data!;
      }
    } catch (e, st) {
      _error = e.toString();
      debugPrint('[AIInsights] loadPlannerInsights failed: $e\n$st');
    } finally {
      _loadingInsights = false;
      notifyListeners();
    }
  }

  Future<void> loadSpendingPattern() async {
    try {
      final resp = await _aiService.getPlannerSpending();
      if (resp.isSuccess) _spendingPattern = resp.data;
    } catch (e, st) {
      debugPrint('[AIInsights] loadSpendingPattern failed: $e\n$st');
    }
    notifyListeners();
  }

  Future<void> loadForecast() async {
    try {
      final resp = await _aiService.getPlannerForecast();
      if (resp.isSuccess) _forecast = resp.data;
    } catch (e, st) {
      debugPrint('[AIInsights] loadForecast failed: $e\n$st');
    }
    notifyListeners();
  }

  Future<void> loadAll() async {
    await Future.wait([
      loadPlannerInsights(),
      loadSpendingPattern(),
      loadForecast(),
    ]);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // RECOMMENDATIONS
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> loadRecommendations() async {
    try {
      final resp = await _aiService.getRecommendations();
      if (resp.isSuccess && resp.data != null) {
        _recommendations = resp.data!;
        notifyListeners();
      }
    } catch (e, st) {
      debugPrint('[AIInsights] loadRecommendations failed: $e\n$st');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SMART SEARCH
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> smartSearch({
    required String query,
    required List<Map<String, String>> documents,
    int topN = 10,
  }) async {
    if (query.trim().isEmpty) return;
    _lastQuery     = query;
    _loadingSearch = true;
    _error         = null;
    notifyListeners();

    try {
      final resp = await _aiService.semanticSearch(
        query:     query,
        documents: documents,
        topN:      topN,
      );
      _searchResults = resp.isSuccess ? (resp.data ?? []) : [];
    } catch (e, st) {
      _error = e.toString();
      debugPrint('[AIInsights] smartSearch failed: $e\n$st');
    } finally {
      _loadingSearch = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    _lastQuery     = '';
    notifyListeners();
  }
}
