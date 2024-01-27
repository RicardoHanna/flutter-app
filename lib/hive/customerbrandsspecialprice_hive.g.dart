// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customerbrandsspecialprice_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerBrandsSpecialPriceAdapter
    extends TypeAdapter<CustomerBrandsSpecialPrice> {
  @override
  final int typeId = 41;

  @override
  CustomerBrandsSpecialPrice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomerBrandsSpecialPrice(
      cmpCode: fields[0] as String,
      custCode: fields[1] as String,
      brandCode: fields[2] as String,
      disc: fields[3] as dynamic,
      notes: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CustomerBrandsSpecialPrice obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.custCode)
      ..writeByte(2)
      ..write(obj.brandCode)
      ..writeByte(3)
      ..write(obj.disc)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerBrandsSpecialPriceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
