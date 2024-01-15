// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'salesemployeescustomers_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SalesEmployeesCustomersAdapter
    extends TypeAdapter<SalesEmployeesCustomers> {
  @override
  final int typeId = 28;

  @override
  SalesEmployeesCustomers read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SalesEmployeesCustomers(
      cmpCode: fields[0] as String,
      seCode: fields[1] as String,
      custCode: fields[2] as String,
      notes: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SalesEmployeesCustomers obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.seCode)
      ..writeByte(2)
      ..write(obj.custCode)
      ..writeByte(3)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalesEmployeesCustomersAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
