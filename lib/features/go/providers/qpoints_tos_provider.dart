import 'package:flutter/foundation.dart';
import '../../../core/services/qpoint_market_service.dart';
import '../models/qpoint_market_models.dart';

/// State management for the Q Points Terms of Service flow.
/// Used by QPointsTosScreen and the market screen gate.
class QPointsTosProvider extends ChangeNotifier {
  final QPointMarketService _service;

  QPointsTosProvider([QPointMarketService? service])
      : _service = service ?? QPointMarketService();

  // ── State ─────────────────────────────────────────────────────────────────

  QPointsTosContent? tosContent;
  QPointsTosStatus? tosStatus;

  bool isLoading = false;
  bool isAccepting = false;
  String? errorMessage;

  /// Whether the user has scrolled to the bottom of the ToS text.
  bool hasScrolledToBottom = false;

  /// Three required consent checkboxes (Section 3.1 gate).
  bool readConfirmed = false;
  bool riskConfirmed = false;
  bool ageConfirmed = false;

  bool get allCheckboxesChecked =>
      readConfirmed && riskConfirmed && ageConfirmed;

  bool get canAccept =>
      hasScrolledToBottom && allCheckboxesChecked && !isAccepting;

  // ── Loaders ───────────────────────────────────────────────────────────────

  Future<void> loadTosContent() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final res = await _service.getCurrentTos();
    isLoading = false;
    if (res.isSuccess && res.data != null) {
      tosContent = res.data;
    } else {
      errorMessage = res.message ?? 'Failed to load Terms of Service.';
    }
    notifyListeners();
  }

  Future<void> loadTosStatus() async {
    final res = await _service.getTosStatus();
    if (res.isSuccess && res.data != null) {
      tosStatus = res.data;
    }
    notifyListeners();
  }

  Future<void> loadAll() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    await Future.wait([loadTosContent(), loadTosStatus()]);
    isLoading = false;
    notifyListeners();
  }

  // ── Checkbox helpers ──────────────────────────────────────────────────────

  void setReadConfirmed(bool value) {
    readConfirmed = value;
    notifyListeners();
  }

  void setRiskConfirmed(bool value) {
    riskConfirmed = value;
    notifyListeners();
  }

  void setAgeConfirmed(bool value) {
    ageConfirmed = value;
    notifyListeners();
  }

  void setScrolledToBottom() {
    if (!hasScrolledToBottom) {
      hasScrolledToBottom = true;
      notifyListeners();
    }
  }

  // ── Accept ToS ────────────────────────────────────────────────────────────

  Future<bool> acceptTos(String platform) async {
    if (tosContent == null) return false;
    isAccepting = true;
    errorMessage = null;
    notifyListeners();

    final res = await _service.acceptTos(
      tosVersion: tosContent!.version,
      readConfirmed: readConfirmed,
      riskConfirmed: riskConfirmed,
      ageConfirmed: ageConfirmed,
      platform: platform,
    );

    isAccepting = false;
    if (res.isSuccess) {
      // Refresh status so the gate screen updates
      tosStatus = QPointsTosStatus(
        accepted: true,
        version: tosContent!.version,
        effectiveDate: tosContent!.effectiveDate,
      );
      notifyListeners();
      return true;
    } else {
      errorMessage = res.message ?? 'Failed to record acceptance. Please try again.';
      notifyListeners();
      return false;
    }
  }

  bool get isAccepted => tosStatus?.accepted ?? false;
}
