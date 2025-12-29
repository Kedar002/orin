import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'guard_model.g.dart';

/// Guard Type - Predefined templates for common use cases
@HiveType(typeId: 0)
enum GuardType {
  @HiveField(0)
  packages,

  @HiveField(1)
  people,

  @HiveField(2)
  vehicles,

  @HiveField(3)
  pets,

  @HiveField(4)
  motion,

  @HiveField(5)
  custom,
}

/// Extension to get human-readable names and icons for guard types
extension GuardTypeExtension on GuardType {
  String get displayName {
    switch (this) {
      case GuardType.packages:
        return 'Packages';
      case GuardType.people:
        return 'People';
      case GuardType.vehicles:
        return 'Vehicles';
      case GuardType.pets:
        return 'Pets';
      case GuardType.motion:
        return 'Motion';
      case GuardType.custom:
        return 'Custom';
    }
  }

  IconData get icon {
    switch (this) {
      case GuardType.packages:
        return Icons.inventory_2_outlined;
      case GuardType.people:
        return Icons.person_outline;
      case GuardType.vehicles:
        return Icons.directions_car_outlined;
      case GuardType.pets:
        return Icons.pets_outlined;
      case GuardType.motion:
        return Icons.motion_photos_on_outlined;
      case GuardType.custom:
        return Icons.tune_outlined;
    }
  }

  String get defaultDescription {
    switch (this) {
      case GuardType.packages:
        return 'Alert me when packages are delivered';
      case GuardType.people:
        return 'Alert me when people are detected';
      case GuardType.vehicles:
        return 'Alert me when vehicles arrive';
      case GuardType.pets:
        return 'Alert me about pet activity';
      case GuardType.motion:
        return 'Alert me about any motion';
      case GuardType.custom:
        return 'Custom detection alert';
    }
  }
}

/// Guard Model - AI assistant that monitors cameras
/// "A guard is not a feature. It's a member of your security team."
@HiveType(typeId: 1)
class Guard extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  GuardType type;

  @HiveField(4)
  bool isActive;

  @HiveField(5)
  List<String> cameraIds;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime? lastDetectionAt;

  @HiveField(8)
  int catchesThisWeek;

  @HiveField(9)
  int savedCatchesCount;

  @HiveField(10)
  double sensitivity; // 0.0 to 1.0

  @HiveField(11)
  int totalCatches;

  Guard({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.isActive = true,
    List<String>? cameraIds,
    DateTime? createdAt,
    this.lastDetectionAt,
    this.catchesThisWeek = 0,
    this.savedCatchesCount = 0,
    this.sensitivity = 0.5,
    this.totalCatches = 0,
  })  : cameraIds = cameraIds ?? [],
        createdAt = createdAt ?? DateTime.now();

  /// Get display icon for this guard
  IconData get icon => type.icon;

  /// Get success rate (% of catches user marked as important)
  int get successRate {
    if (totalCatches == 0) return 0;
    return ((savedCatchesCount / totalCatches) * 100).round();
  }

  /// Get status text
  String get statusText {
    if (!isActive) return 'PAUSED';
    if (lastDetectionAt == null) return 'MONITORING';

    final now = DateTime.now();
    final diff = now.difference(lastDetectionAt!);

    if (diff.inMinutes < 1) return 'ACTIVE';
    if (diff.inHours < 1) return 'MONITORING';
    return 'ACTIVE';
  }

  /// Get last activity text
  String? get lastActivityText {
    if (lastDetectionAt == null) return null;

    final now = DateTime.now();
    final diff = now.difference(lastDetectionAt!);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  /// Copy with method for updates
  Guard copyWith({
    String? name,
    String? description,
    GuardType? type,
    bool? isActive,
    List<String>? cameraIds,
    DateTime? lastDetectionAt,
    int? catchesThisWeek,
    int? savedCatchesCount,
    double? sensitivity,
    int? totalCatches,
  }) {
    return Guard(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      cameraIds: cameraIds ?? this.cameraIds,
      createdAt: createdAt,
      lastDetectionAt: lastDetectionAt ?? this.lastDetectionAt,
      catchesThisWeek: catchesThisWeek ?? this.catchesThisWeek,
      savedCatchesCount: savedCatchesCount ?? this.savedCatchesCount,
      sensitivity: sensitivity ?? this.sensitivity,
      totalCatches: totalCatches ?? this.totalCatches,
    );
  }
}
