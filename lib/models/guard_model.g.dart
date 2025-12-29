// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guard_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GuardAdapter extends TypeAdapter<Guard> {
  @override
  final int typeId = 1;

  @override
  Guard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Guard(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      type: fields[3] as GuardType,
      isActive: fields[4] as bool,
      cameraIds: (fields[5] as List?)?.cast<String>(),
      createdAt: fields[6] as DateTime?,
      lastDetectionAt: fields[7] as DateTime?,
      catchesThisWeek: fields[8] as int,
      savedCatchesCount: fields[9] as int,
      sensitivity: fields[10] as double,
      totalCatches: fields[11] as int,
      notifyOnDetection: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Guard obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.isActive)
      ..writeByte(5)
      ..write(obj.cameraIds)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.lastDetectionAt)
      ..writeByte(8)
      ..write(obj.catchesThisWeek)
      ..writeByte(9)
      ..write(obj.savedCatchesCount)
      ..writeByte(10)
      ..write(obj.sensitivity)
      ..writeByte(11)
      ..write(obj.totalCatches)
      ..writeByte(12)
      ..write(obj.notifyOnDetection);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GuardTypeAdapter extends TypeAdapter<GuardType> {
  @override
  final int typeId = 0;

  @override
  GuardType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GuardType.packages;
      case 1:
        return GuardType.people;
      case 2:
        return GuardType.vehicles;
      case 3:
        return GuardType.pets;
      case 4:
        return GuardType.motion;
      case 5:
        return GuardType.custom;
      default:
        return GuardType.packages;
    }
  }

  @override
  void write(BinaryWriter writer, GuardType obj) {
    switch (obj) {
      case GuardType.packages:
        writer.writeByte(0);
        break;
      case GuardType.people:
        writer.writeByte(1);
        break;
      case GuardType.vehicles:
        writer.writeByte(2);
        break;
      case GuardType.pets:
        writer.writeByte(3);
        break;
      case GuardType.motion:
        writer.writeByte(4);
        break;
      case GuardType.custom:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuardTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
