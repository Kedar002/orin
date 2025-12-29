import 'package:hive_flutter/hive_flutter.dart';
import '../models/guard_model.dart';
import '../models/catch_model.dart';

/// Database Service - Initialize and manage Hive boxes
class DatabaseService {
  static const String _guardsBox = 'guards';
  static const String _catchesBox = 'catches';

  /// Initialize Hive database
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(GuardTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(GuardAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(CatchTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(CatchAdapter());
    }

    // Open boxes
    await Hive.openBox<Guard>(_guardsBox);
    await Hive.openBox<Catch>(_catchesBox);

    // Seed initial data if empty
    await _seedInitialData();
  }

  /// Get guards box
  static Box<Guard> get guardsBox => Hive.box<Guard>(_guardsBox);

  /// Get catches box
  static Box<Catch> get catchesBox => Hive.box<Catch>(_catchesBox);

  /// Seed initial data for demo
  static Future<void> _seedInitialData() async {
    final guardsBox = Hive.box<Guard>(_guardsBox);
    final catchesBox = Hive.box<Catch>(_catchesBox);

    // Only seed if empty
    if (guardsBox.isEmpty) {
      // Create sample guards
      final guard1 = Guard(
        id: 'guard-1',
        name: 'Package Watch',
        description: 'Alert me when packages are delivered',
        type: GuardType.packages,
        cameraIds: ['CAM-003'],
        isActive: true,
        catchesThisWeek: 3,
        savedCatchesCount: 2,
        totalCatches: 3,
        lastDetectionAt: DateTime.now().subtract(const Duration(minutes: 2)),
      );

      final guard2 = Guard(
        id: 'guard-2',
        name: 'Pool Safety',
        description: 'Monitor pool area for safety',
        type: GuardType.motion,
        cameraIds: ['CAM-002'],
        isActive: true,
        catchesThisWeek: 0,
        savedCatchesCount: 0,
        totalCatches: 0,
        lastDetectionAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      final guard3 = Guard(
        id: 'guard-3',
        name: 'Night Watch',
        description: 'Active during night hours only',
        type: GuardType.people,
        cameraIds: ['CAM-001'],
        isActive: false,
        catchesThisWeek: 12,
        savedCatchesCount: 10,
        totalCatches: 12,
        lastDetectionAt: DateTime.now().subtract(const Duration(hours: 12)),
      );

      await guardsBox.put(guard1.id, guard1);
      await guardsBox.put(guard2.id, guard2);
      await guardsBox.put(guard3.id, guard3);
    }

    // Seed catches
    if (catchesBox.isEmpty) {
      final now = DateTime.now();

      final catches = [
        Catch(
          id: 'catch-1',
          guardId: 'guard-1',
          cameraId: 'CAM-003',
          cameraName: 'Front Door',
          timestamp: now.subtract(const Duration(minutes: 2)),
          type: CatchType.delivery,
          title: 'Package delivered',
          description: 'Amazon package detected at front door',
          isSaved: true,
          userNote: 'Amazon - new camera',
          confidence: 0.95,
        ),
        Catch(
          id: 'catch-2',
          guardId: 'guard-1',
          cameraId: 'CAM-003',
          cameraName: 'Front Door',
          timestamp: now.subtract(const Duration(hours: 4)),
          type: CatchType.person,
          title: 'Person detected',
          description: 'Unknown person approaching entrance',
          isSaved: true,
          userNote: 'USPS mail carrier - Mark',
          confidence: 0.88,
        ),
        Catch(
          id: 'catch-3',
          guardId: 'guard-1',
          cameraId: 'CAM-003',
          cameraName: 'Front Door',
          timestamp: now.subtract(const Duration(hours: 6)),
          type: CatchType.motion,
          title: 'Motion detected',
          description: 'Vehicle motion detected in driveway',
          isSaved: false,
          confidence: 0.72,
        ),
        Catch(
          id: 'catch-4',
          guardId: 'guard-1',
          cameraId: 'CAM-003',
          cameraName: 'Front Door',
          timestamp: now.subtract(const Duration(days: 1, hours: 6)),
          type: CatchType.delivery,
          title: 'Package picked up',
          description: 'Package removed from front door area',
          isSaved: false,
          confidence: 0.81,
        ),
        Catch(
          id: 'catch-5',
          guardId: 'guard-1',
          cameraId: 'CAM-003',
          cameraName: 'Front Door',
          timestamp: now.subtract(const Duration(days: 1, hours: 9)),
          type: CatchType.person,
          title: 'Person detected',
          description: 'Delivery person detected',
          isSaved: false,
          confidence: 0.91,
        ),
        Catch(
          id: 'catch-6',
          guardId: 'guard-1',
          cameraId: 'CAM-003',
          cameraName: 'Front Door',
          timestamp: now.subtract(const Duration(days: 1, hours: 14)),
          type: CatchType.motion,
          title: 'Motion detected',
          description: 'Morning activity detected',
          isSaved: false,
          confidence: 0.65,
        ),
      ];

      for (var catch_ in catches) {
        await catchesBox.put(catch_.id, catch_);
      }
    }
  }

  /// Clear all data (for testing)
  static Future<void> clearAll() async {
    await guardsBox.clear();
    await catchesBox.clear();
  }
}
