import 'dart:async';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

class SyncOperation {
  final String id;
  final String type; // 'CREATE_MESSAGE', 'UPDATE_PROFILE', etc.
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  bool isSynced;
  int retryCount;

  SyncOperation({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    this.isSynced = false,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'payload': payload,
    'createdAt': createdAt.toIso8601String(),
    'isSynced': isSynced,
    'retryCount': retryCount,
  };

  factory SyncOperation.fromJson(Map<String, dynamic> json) => SyncOperation(
    id: json['id'],
    type: json['type'],
    payload: json['payload'],
    createdAt: DateTime.parse(json['createdAt']),
    isSynced: json['isSynced'] ?? false,
    retryCount: json['retryCount'] ?? 0,
  );
}

enum SyncStatus { pending, syncing, success, error }

class SyncManager extends ChangeNotifier {
  late Box<Map> _syncBox;
  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  
  bool _isInitialized = false;
  Timer? _syncTimer;
  final Duration _syncInterval = const Duration(minutes: 5);
  bool _isSyncing = false;

  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      _syncBox = await Hive.openBox<Map>('sync_operations');
      _isInitialized = true;
      debugPrint('[SyncManager] Initialized');
      
      // Start periodic sync
      _startPeriodicSync();
      
      notifyListeners();
    } catch (e) {
      debugPrint('[SyncManager] Init error: $e');
    }
  }

  /// Queue an operation for sync
  Future<void> queueOperation({
    required String type,
    required Map<String, dynamic> payload,
  }) async {
    if (!_isInitialized) {
      debugPrint('[SyncManager] Not initialized');
      return;
    }

    try {
      final operation = SyncOperation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        payload: payload,
        createdAt: DateTime.now(),
      );

      await _syncBox.add(operation.toJson());
      debugPrint('[SyncManager] Queued: ${operation.type}');
      
      notifyListeners();
    } catch (e) {
      debugPrint('[SyncManager] Queue error: $e');
    }
  }

  /// Process pending operations
  Future<void> processPendingOperations({
    required Future<void> Function(SyncOperation) onSync,
  }) async {
    if (!_isInitialized || _isSyncing) return;

    _isSyncing = true;
    _syncStatusController.add(SyncStatus.syncing);

    try {
      final operations = _syncBox.values
          .map((e) => SyncOperation.fromJson(Map<String, dynamic>.from(e)))
          .where((op) => !op.isSynced && op.retryCount < 3)
          .toList();

      for (final operation in operations) {
        try {
          await onSync(operation);
          
          // Mark as synced
          operation.isSynced = true;
          operation.retryCount = 0;
          
          final index = _syncBox.values
              .toList()
              .indexWhere((e) => e['id'] == operation.id);
          
          if (index >= 0) {
            await _syncBox.putAt(index, operation.toJson());
          }

          _syncStatusController.add(SyncStatus.success);
          debugPrint('[SyncManager] Synced: ${operation.type}');
        } catch (e) {
          operation.retryCount++;
          
          final index = _syncBox.values
              .toList()
              .indexWhere((e) => e['id'] == operation.id);
          
          if (index >= 0) {
            await _syncBox.putAt(index, operation.toJson());
          }

          _syncStatusController.add(SyncStatus.error);
          debugPrint('[SyncManager] Sync error: $e');
        }
      }
    } catch (e) {
      _syncStatusController.add(SyncStatus.error);
      debugPrint('[SyncManager] Process error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Start periodic sync
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(_syncInterval, (_) {
      debugPrint('[SyncManager] Periodic sync triggered');
      notifyListeners();
    });
  }

  /// Get pending operations count
  int getPendingCount() {
    if (!_isInitialized) return 0;
    
    return _syncBox.values
        .map((e) => SyncOperation.fromJson(Map<String, dynamic>.from(e)))
        .where((op) => !op.isSynced)
        .length;
  }

  /// Clear all synced operations
  Future<void> clearSynced() async {
    if (!_isInitialized) return;

    try {
      final keysToDelete = <int>[];
      
      for (int i = 0; i < _syncBox.length; i++) {
        final op = SyncOperation.fromJson(
          Map<String, dynamic>.from(_syncBox.getAt(i)!),
        );
        
        if (op.isSynced) {
          keysToDelete.add(i);
        }
      }

      for (final key in keysToDelete.reversed) {
        await _syncBox.deleteAt(key);
      }

      debugPrint('[SyncManager] Cleared synced operations');
      notifyListeners();
    } catch (e) {
      debugPrint('[SyncManager] Clear error: $e');
    }
  }

  Stream<SyncStatus> get syncStatus => _syncStatusController.stream;

  @override
  void dispose() {
    _syncTimer?.cancel();
    _syncStatusController.close();
    super.dispose();
  }
}
