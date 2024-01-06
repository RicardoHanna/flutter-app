// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'syncronizesubmenu_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SynchronizeSubMenuAdapter extends TypeAdapter<SynchronizeSubMenu> {
  @override
  final int typeId = 15;

  @override
  SynchronizeSubMenu read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SynchronizeSubMenu(
      syncronizecode: fields[0] as int,
      syncronizename: fields[1] as String,
      syncronizearname: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SynchronizeSubMenu obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.syncronizecode)
      ..writeByte(1)
      ..write(obj.syncronizename)
      ..writeByte(2)
      ..write(obj.syncronizearname);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SynchronizeSubMenuAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
