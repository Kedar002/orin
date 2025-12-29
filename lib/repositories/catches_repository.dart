import '../models/catch_model.dart';
import '../services/database_service.dart';
import 'guards_repository.dart';

/// Catches Repository - CRUD operations for catches
class CatchesRepository {
  final GuardsRepository _guardsRepository = GuardsRepository();

  /// Get all catches
  List<Catch> getAll() {
    return DatabaseService.catchesBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Get catches for a specific guard
  List<Catch> getByGuardId(String guardId) {
    return getAll().where((catch_) => catch_.guardId == guardId).toList();
  }

  /// Get saved catches
  List<Catch> getSaved() {
    return getAll().where((catch_) => catch_.isSaved).toList();
  }

  /// Get catches with notes
  List<Catch> getWithNotes() {
    return getAll()
        .where((catch_) => catch_.userNote != null && catch_.userNote!.isNotEmpty)
        .toList();
  }

  /// Get catches for today
  List<Catch> getToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return getAll().where((catch_) {
      final catchDate = DateTime(
        catch_.timestamp.year,
        catch_.timestamp.month,
        catch_.timestamp.day,
      );
      return catchDate == today;
    }).toList();
  }

  /// Get catches for this week
  List<Catch> getThisWeek() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return getAll()
        .where((catch_) => catch_.timestamp.isAfter(weekAgo))
        .toList();
  }

  /// Search catches
  List<Catch> search(String query) {
    final lowerQuery = query.toLowerCase();
    return getAll().where((catch_) {
      return catch_.title.toLowerCase().contains(lowerQuery) ||
          catch_.description.toLowerCase().contains(lowerQuery) ||
          catch_.cameraName.toLowerCase().contains(lowerQuery) ||
          (catch_.userNote?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Toggle save status
  Future<void> toggleSave(String id) async {
    final catch_ = DatabaseService.catchesBox.get(id);
    if (catch_ != null) {
      final updated = catch_.copyWith(isSaved: !catch_.isSaved);
      await DatabaseService.catchesBox.put(id, updated);

      // Update guard's saved count
      if (updated.isSaved) {
        await _guardsRepository.incrementSavedCount(catch_.guardId);
      } else {
        await _guardsRepository.decrementSavedCount(catch_.guardId);
      }
    }
  }

  /// Update note
  Future<void> updateNote(String id, String? note) async {
    final catch_ = DatabaseService.catchesBox.get(id);
    if (catch_ != null) {
      final updated = catch_.copyWith(userNote: note ?? '');
      await DatabaseService.catchesBox.put(id, updated);
    }
  }

  /// Create new catch (for future AI integration)
  Future<Catch> create({
    required String guardId,
    required String cameraId,
    required String cameraName,
    required CatchType type,
    required String title,
    required String description,
    double confidence = 0.0,
  }) async {
    final catch_ = Catch(
      id: 'catch-${DateTime.now().millisecondsSinceEpoch}',
      guardId: guardId,
      cameraId: cameraId,
      cameraName: cameraName,
      timestamp: DateTime.now(),
      type: type,
      title: title,
      description: description,
      confidence: confidence,
    );

    await DatabaseService.catchesBox.put(catch_.id, catch_);
    await _guardsRepository.recordDetection(guardId);

    return catch_;
  }

  /// Delete catch
  Future<void> delete(String id) async {
    await DatabaseService.catchesBox.delete(id);
  }
}
