// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'salesemployeesitemscategories_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SalesEmployeesItemsCategoriesAdapter
    extends TypeAdapter<SalesEmployeesItemsCategories> {
  @override
  final int typeId = 31;

  @override
  SalesEmployeesItemsCategories read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SalesEmployeesItemsCategories(
      cmpCode: fields[0] as String,
      seCode: fields[1] as String,
      categCode: fields[2] as String,
      reqFromWhsCode: fields[3] as int,
      notes: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SalesEmployeesItemsCategories obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.seCode)
      ..writeByte(2)
      ..write(obj.categCode)
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
      other is SalesEmployeesItemsCategoriesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
