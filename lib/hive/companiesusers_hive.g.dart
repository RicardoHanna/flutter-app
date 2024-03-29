// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'companiesusers_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompaniesUsersAdapter extends TypeAdapter<CompaniesUsers> {
  @override
  final int typeId = 54;

  @override
  CompaniesUsers read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompaniesUsers(
      userCode: fields[0] as String,
      cmpCode: fields[1] as String,
      defaultcmpCode: fields[2] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, CompaniesUsers obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.userCode)
      ..writeByte(1)
      ..write(obj.cmpCode)
      ..writeByte(2)
      ..write(obj.defaultcmpCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompaniesUsersAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
