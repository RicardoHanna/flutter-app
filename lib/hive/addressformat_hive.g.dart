// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'addressformat_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AddressFormatAdapter extends TypeAdapter<AddressFormat> {
  @override
  final int typeId = 55;

  @override
  AddressFormat read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AddressFormat(
      cmpCode: fields[0] as String,
      addrFormatID: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AddressFormat obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.addrFormatID);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressFormatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
