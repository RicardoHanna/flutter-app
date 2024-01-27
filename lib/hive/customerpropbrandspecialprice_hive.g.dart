// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customerpropbrandspecialprice_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerPropBrandSpecialPriceAdapter
    extends TypeAdapter<CustomerPropBrandSpecialPrice> {
  @override
  final int typeId = 49;

  @override
  CustomerPropBrandSpecialPrice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomerPropBrandSpecialPrice(
      cmpCode: fields[0] as String,
      custPropCode: fields[1] as String,
      brandCode: fields[2] as String,
      disc: fields[3] as dynamic,
      notes: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CustomerPropBrandSpecialPrice obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.custPropCode)
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
      other is CustomerPropBrandSpecialPriceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
