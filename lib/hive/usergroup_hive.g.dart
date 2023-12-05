// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usergroup_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserGroupAdapter extends TypeAdapter<UserGroup> {
  @override
  final int typeId = 1;

  @override
  UserGroup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserGroup(
      fields[0] as int,
      fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserGroup obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.usercode)
      ..writeByte(1)
      ..write(obj.username);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
