import '../models/guard_model.dart';
import '../services/database_service.dart';

/// Guards Repository - CRUD operations for guards
class GuardsRepository {
  /// Get all guards
  List<Guard> getAll() {
    return DatabaseService.guardsBox.values.toList();
  }

  /// Get guard by ID
  Guard? getById(String id) {
    return DatabaseService.guardsBox.get(id);
  }

  /// Get active guards
  List<Guard> getActive() {
    return getAll().where((guard) => guard.isActive).toList();
  }

  /// Create new guard
  Future<Guard> create({
    required String name,
    required String description,
    required GuardType type,
    required List<String> cameraIds,
    bool notifyOnDetection = true,
  }) async {
    final guard = Guard(
      id: 'guard-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      type: type,
      cameraIds: cameraIds,
      isActive: true,
      catchesThisWeek: 0,
      savedCatchesCount: 0,
      totalCatches: 0,
      notifyOnDetection: notifyOnDetection,
    );

    await DatabaseService.guardsBox.put(guard.id, guard);
    return guard;
  }

  /// Update guard
  Future<void> update(Guard guard) async {
    await DatabaseService.guardsBox.put(guard.id, guard);
  }

  /// Delete guard
  Future<void> delete(String id) async {
    await DatabaseService.guardsBox.delete(id);
  }

  /// Toggle guard active status
  Future<void> toggleActive(String id) async {
    final guard = getById(id);
    if (guard != null) {
      final updated = guard.copyWith(isActive: !guard.isActive);
      await update(updated);
    }
  }

  /// Update guard cameras
  Future<void> updateCameras(String id, List<String> cameraIds) async {
    final guard = getById(id);
    if (guard != null) {
      final updated = guard.copyWith(cameraIds: cameraIds);
      await update(updated);
    }
  }

  /// Record a new detection
  Future<void> recordDetection(String id) async {
    final guard = getById(id);
    if (guard != null) {
      final updated = guard.copyWith(
        lastDetectionAt: DateTime.now(),
        catchesThisWeek: guard.catchesThisWeek + 1,
        totalCatches: guard.totalCatches + 1,
      );
      await update(updated);
    }
  }

  /// Increment saved catches count
  Future<void> incrementSavedCount(String id) async {
    final guard = getById(id);
    if (guard != null) {
      final updated = guard.copyWith(
        savedCatchesCount: guard.savedCatchesCount + 1,
      );
      await update(updated);
    }
  }

  /// Decrement saved catches count
  Future<void> decrementSavedCount(String id) async {
    final guard = getById(id);
    if (guard != null) {
      final updated = guard.copyWith(
        savedCatchesCount: guard.savedCatchesCount - 1,
      );
      await update(updated);
    }
  }
}
