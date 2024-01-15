// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'salesemployeesitemsbrands_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SalesEmployeesItemsBrandsAdapter
    extends TypeAdapter<SalesEmployeesItemsBrands> {
  @override
  final int typeId = 30;

  @override
  SalesEmployeesItemsBrands read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SalesEmployeesItemsBrands(
      cmpCode: fields[0] as String,
      seCode: fields[1] as String,
      brandCode: fields[2] as String,
      reqFromWhsCode: fields[3] as int,
      notes: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SalesEmployeesItemsBrands obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.seCode)
      ..writeByte(2)
      ..write(obj.brandCode)
      ..writeByte(3)
      ..write(obj.reqFromWhsCode)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalesEmployeesItemsBrandsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
