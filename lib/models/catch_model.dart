import 'package:hive/hive.dart';

part 'catch_model.g.dart';

/// Catch Type - What was detected
@HiveType(typeId: 2)
enum CatchType {
  @HiveField(0)
  delivery,

  @HiveField(1)
  person,

  @HiveField(2)
  vehicle,

  @HiveField(3)
  pet,

  @HiveField(4)
  motion,

  @HiveField(5)
  other,
}

extension CatchTypeExtension on CatchType {
  String get displayName {
    switch (this) {
      case CatchType.delivery:
        return 'Delivery';
      case CatchType.person:
        return 'Person';
      case CatchType.vehicle:
        return 'Vehicle';
      case CatchType.pet:
        return 'Pet';
      case CatchType.motion:
        return 'Motion';
      case CatchType.other:
        return 'Other';
    }
  }
}

/// Catch Model - An event detected by a guard
/// "I want to remember this catch"
@HiveType(typeId: 3)
class Catch extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String guardId;

  @HiveField(2)
  String cameraId;

  @HiveField(3)
  String cameraName;

  @HiveField(4)
  DateTime timestamp;

  @HiveField(5)
  CatchType type;

  @HiveField(6)
  String title;

  @HiveField(7)
  String description;

  @HiveField(8)
  bool isSaved; // User starred this

  @HiveField(9)
  String? userNote; // User's annotation

  @HiveField(10)
  double confidence; // AI confidence 0.0 to 1.0

  @HiveField(11)
  String? thumbnailUrl; // Screenshot from video

  @HiveField(12)
  String? videoClipUrl; // 10-second clip

  Catch({
    required this.id,
    required this.guardId,
    required this.cameraId,
    required this.cameraName,
    required this.timestamp,
    required this.type,
    required this.title,
    required this.description,
    this.isSaved = false,
    this.userNote,
    this.confidence = 0.0,
    this.thumbnailUrl,
    this.videoClipUrl,
  });

  /// Get formatted time
  String get formattedTime {
    final hour = timestamp.hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  /// Get relative time (for display)
  String get relativeTime {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${diff.inDays ~/ 7}w ago';
  }

  /// Get date group (Today, Yesterday, This Week, Earlier)
  String get dateGroup {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final catchDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (catchDate == today) return 'Today';
    if (catchDate == yesterday) return 'Yesterday';
    if (now.difference(timestamp).inDays < 7) return 'This Week';
    return 'Earlier';
  }

  /// Copy with method for updates
  Catch copyWith({
    bool? isSaved,
    String? userNote,
  }) {
    return Catch(
      id: id,
      guardId: guardId,
      cameraId: cameraId,
      cameraName: cameraName,
      timestamp: timestamp,
      type: type,
      title: title,
      description: description,
      isSaved: isSaved ?? this.isSaved,
      userNote: userNote,
      confidence: confidence,
      thumbnailUrl: thumbnailUrl,
      videoClipUrl: videoClipUrl,
    );
  }
}
