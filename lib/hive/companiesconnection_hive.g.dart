// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'companiesconnection_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompaniesConnectionAdapter extends TypeAdapter<CompaniesConnection> {
  @override
  final int typeId = 52;

  @override
  CompaniesConnection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompaniesConnection(
      connectionID: fields[0] as String,
      connDatabase: fields[1] as String,
      connServer: fields[2] as String,
      connUser: fields[3] as String,
      connPassword: fields[4] as String,
      connPort: fields[5] as int,
      typeDatabase: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CompaniesConnection obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.connectionID)
      ..writeByte(1)
      ..write(obj.connDatabase)
      ..writeByte(2)
      ..write(obj.connServer)
      ..writeByte(3)
      ..write(obj.connUser)
      ..writeByte(4)
      ..write(obj.connPassword)
      ..writeByte(5)
      ..write(obj.connPort)
      ..writeByte(6)
      ..write(obj.typeDatabase);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompaniesConnectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
