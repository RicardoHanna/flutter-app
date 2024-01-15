// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'userssalesemployees_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSalesEmployeesAdapter extends TypeAdapter<UserSalesEmployees> {
  @override
  final int typeId = 34;

  @override
  UserSalesEmployees read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSalesEmployees(
      cmpCode: fields[0] as String,
      userCode: fields[1] as int,
      seCode: fields[2] as String,
      notes: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserSalesEmployees obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.userCode)
      ..writeByte(2)
      ..write(obj.seCode)
      ..writeByte(3)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSalesEmployeesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
