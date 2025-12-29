// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catch_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CatchAdapter extends TypeAdapter<Catch> {
  @override
  final int typeId = 3;

  @override
  Catch read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Catch(
      id: fields[0] as String,
      guardId: fields[1] as String,
      cameraId: fields[2] as String,
      cameraName: fields[3] as String,
      timestamp: fields[4] as DateTime,
      type: fields[5] as CatchType,
      title: fields[6] as String,
      description: fields[7] as String,
      isSaved: fields[8] as bool,
      userNote: fields[9] as String?,
      confidence: fields[10] as double,
      thumbnailUrl: fields[11] as String?,
      videoClipUrl: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Catch obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.guardId)
      ..writeByte(2)
      ..write(obj.cameraId)
      ..writeByte(3)
      ..write(obj.cameraName)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.title)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.isSaved)
      ..writeByte(9)
      ..write(obj.userNote)
      ..writeByte(10)
      ..write(obj.confidence)
      ..writeByte(11)
      ..write(obj.thumbnailUrl)
      ..writeByte(12)
      ..write(obj.videoClipUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatchAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CatchTypeAdapter extends TypeAdapter<CatchType> {
  @override
  final int typeId = 2;

  @override
  CatchType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CatchType.delivery;
      case 1:
        return CatchType.person;
      case 2:
        return CatchType.vehicle;
      case 3:
        return CatchType.pet;
      case 4:
        return CatchType.motion;
      case 5:
        return CatchType.other;
      default:
        return CatchType.delivery;
    }
  }

  @override
  void write(BinaryWriter writer, CatchType obj) {
    switch (obj) {
      case CatchType.delivery:
        writer.writeByte(0);
        break;
      case CatchType.person:
        writer.writeByte(1);
        break;
      case CatchType.vehicle:
        writer.writeByte(2);
        break;
      case CatchType.pet:
        writer.writeByte(3);
        break;
      case CatchType.motion:
        writer.writeByte(4);
        break;
      case CatchType.other:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatchTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
