// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customerpropgroupspecialprice_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerPropGroupSpecialPriceAdapter
    extends TypeAdapter<CustomerPropGroupSpecialPrice> {
  @override
  final int typeId = 50;

  @override
  CustomerPropGroupSpecialPrice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomerPropGroupSpecialPrice(
      cmpCode: fields[0] as String,
      custGroupCode: fields[1] as String,
      propCode: fields[2] as String,
      disc: fields[3] as String,
      notes: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, CustomerPropGroupSpecialPrice obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.custGroupCode)
      ..writeByte(2)
      ..write(obj.propCode)
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
      other is CustomerPropGroupSpecialPriceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
