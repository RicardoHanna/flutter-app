// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customergroupcategspecialprice_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerGroupCategSpecialPriceAdapter
    extends TypeAdapter<CustomerGroupCategSpecialPrice> {
  @override
  final int typeId = 47;

  @override
  CustomerGroupCategSpecialPrice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomerGroupCategSpecialPrice(
      cmpCode: fields[0] as String,
      custGroupCode: fields[1] as String,
      categCode: fields[2] as String,
      disc: fields[3] as int,
      notes: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CustomerGroupCategSpecialPrice obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.custGroupCode)
      ..writeByte(2)
      ..write(obj.categCode)
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
      other is CustomerGroupCategSpecialPriceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
