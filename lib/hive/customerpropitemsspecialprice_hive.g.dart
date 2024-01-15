// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customerpropitemsspecialprice_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerPropItemsSpecialPriceAdapter
    extends TypeAdapter<CustomerPropItemsSpecialPrice> {
  @override
  final int typeId = 48;

  @override
  CustomerPropItemsSpecialPrice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomerPropItemsSpecialPrice(
      cmpCode: fields[0] as String,
      custPropCode: fields[1] as String,
      itemCode: fields[2] as String,
      uom: fields[3] as String,
      basePrice: fields[4] as double,
      currency: fields[5] as double,
      auto: fields[6] as bool,
      disc: fields[7] as double,
      price: fields[8] as double,
      notes: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CustomerPropItemsSpecialPrice obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.custPropCode)
      ..writeByte(2)
      ..write(obj.itemCode)
      ..writeByte(3)
      ..write(obj.uom)
      ..writeByte(4)
      ..write(obj.basePrice)
      ..writeByte(5)
      ..write(obj.currency)
      ..writeByte(6)
      ..write(obj.auto)
      ..writeByte(7)
      ..write(obj.disc)
      ..writeByte(8)
      ..write(obj.price)
      ..writeByte(9)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerPropItemsSpecialPriceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
