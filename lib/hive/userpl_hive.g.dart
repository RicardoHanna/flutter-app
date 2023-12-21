// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'userpl_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserPLAdapter extends TypeAdapter<UserPL> {
  @override
  final int typeId = 11;

  @override
  UserPL read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPL(
      fields[0] as String,
      fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserPL obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.userCode)
      ..writeByte(1)
      ..write(obj.plSecGroup);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPLAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
