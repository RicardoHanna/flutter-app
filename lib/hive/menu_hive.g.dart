// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MenuAdapter extends TypeAdapter<Menu> {
  @override
  final int typeId = 12;

  @override
  Menu read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Menu(
      menucode: fields[0] as int,
      menuname: fields[1] as String,
      menuarname: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Menu obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.menucode)
      ..writeByte(1)
      ..write(obj.menuname)
      ..writeByte(3)
      ..write(obj.menuarname);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
