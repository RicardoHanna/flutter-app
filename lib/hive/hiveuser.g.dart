// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hiveuser.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      fields[4] as String,
      fields[5] as String,
      fields[6] as String,
      fields[7] as bool,
      fields[8] as String,
      fields[9] as int,
      fields[10] as String,
      fields[11] as int,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.usercode)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.userFname)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.password)
      ..writeByte(5)
      ..write(obj.phonenumber)
      ..writeByte(6)
      ..write(obj.imeicode)
      ..writeByte(7)
      ..write(obj.active)
      ..writeByte(8)
      ..write(obj.imageLink)
      ..writeByte(9)
      ..write(obj.usergroup)
      ..writeByte(10)
      ..write(obj.languages)
      ..writeByte(11)
      ..write(obj.font);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
