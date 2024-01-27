// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customergroupgroupspecialprice_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerGroupGroupSpecialPriceAdapter
    extends TypeAdapter<CustomerGroupGroupSpecialPrice> {
  @override
  final int typeId = 46;

  @override
  CustomerGroupGroupSpecialPrice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomerGroupGroupSpecialPrice(
      cmpCode: fields[0] as String,
      custGroupCode: fields[1] as String,
      groupCode: fields[2] as String,
      disc: fields[3] as dynamic,
      notes: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CustomerGroupGroupSpecialPrice obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.custGroupCode)
      ..writeByte(2)
      ..write(obj.groupCode)
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
      other is CustomerGroupGroupSpecialPriceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
