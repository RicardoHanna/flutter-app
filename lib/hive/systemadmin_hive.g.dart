// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'systemadmin_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SystemAdminAdapter extends TypeAdapter<SystemAdmin> {
  @override
  final int typeId = 16;

  @override
  SystemAdmin read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SystemAdmin(
      autoExport: fields[0] as bool,
      groupcode: fields[1] as int,
      importFromErpToMobile: fields[2] as bool,
      importFromBackendToMobile: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SystemAdmin obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.autoExport)
      ..writeByte(1)
      ..write(obj.groupcode)
      ..writeByte(2)
      ..write(obj.importFromErpToMobile)
      ..writeByte(3)
      ..write(obj.importFromBackendToMobile);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemAdminAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
