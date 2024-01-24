// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pricelistauthorization_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PriceListAuthorizationAdapter
    extends TypeAdapter<PriceListAuthorization> {
  @override
  final int typeId = 53;

  @override
  PriceListAuthorization read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PriceListAuthorization(
      userCode: fields[0] as String,
      cmpCode: fields[1] as String,
      authoGroup: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PriceListAuthorization obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.userCode)
      ..writeByte(1)
      ..write(obj.cmpCode)
      ..writeByte(2)
      ..write(obj.authoGroup);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriceListAuthorizationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
