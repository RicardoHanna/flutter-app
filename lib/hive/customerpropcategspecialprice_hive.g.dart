// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customerpropcategspecialprice_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerPropCategSpecialPriceAdapter
    extends TypeAdapter<CustomerPropCategSpecialPrice> {
  @override
  final int typeId = 51;

  @override
  CustomerPropCategSpecialPrice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomerPropCategSpecialPrice(
      cmpCode: fields[0] as String,
      custPropCode: fields[1] as String,
      categCode: fields[2] as String,
      disc: fields[3] as double,
      notes: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CustomerPropCategSpecialPrice obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.custPropCode)
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
      other is CustomerPropCategSpecialPriceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
