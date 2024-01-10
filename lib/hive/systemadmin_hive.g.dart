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
      connDatabase: fields[1] as String,
      connServer: fields[2] as String,
      connPassword: fields[3] as String,
      connPort: fields[4] as int,
      typeDatabase: fields[5] as String,
      groupcode: fields[6] as int,
      importFromErpToMobile: fields[7] as bool,
      importFromBackendToMobile: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SystemAdmin obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.autoExport)
      ..writeByte(1)
      ..write(obj.connDatabase)
      ..writeByte(2)
      ..write(obj.connServer)
      ..writeByte(3)
      ..write(obj.connPassword)
      ..writeByte(4)
      ..write(obj.connPort)
      ..writeByte(5)
      ..write(obj.typeDatabase)
      ..writeByte(6)
      ..write(obj.groupcode)
      ..writeByte(7)
      ..write(obj.importFromErpToMobile)
      ..writeByte(8)
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
