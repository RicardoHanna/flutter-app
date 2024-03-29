// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'salesemployees_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SalesEmployeesAdapter extends TypeAdapter<SalesEmployees> {
  @override
  final int typeId = 27;

  @override
  SalesEmployees read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SalesEmployees(
      cmpCode: fields[0] as String,
      seCode: fields[1] as String,
      seName: fields[2] as String,
      seFName: fields[3] as String,
      mobile: fields[4] as String,
      email: fields[5] as String,
      whsCode: fields[6] as String,
      reqFromWhsCode: fields[7] as dynamic,
      notes: fields[8] as String,
      cashSalesCustCode: fields[9] as String,
      allowUpdDisc: fields[10] as bool,
      maxDiscPerc: fields[11] as dynamic,
      allowFreeItm: fields[12] as bool,
      allowFreeInv: fields[13] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SalesEmployees obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.seCode)
      ..writeByte(2)
      ..write(obj.seName)
      ..writeByte(3)
      ..write(obj.seFName)
      ..writeByte(4)
      ..write(obj.mobile)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.whsCode)
      ..writeByte(7)
      ..write(obj.reqFromWhsCode)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.cashSalesCustCode)
      ..writeByte(10)
      ..write(obj.allowUpdDisc)
      ..writeByte(11)
      ..write(obj.maxDiscPerc)
      ..writeByte(12)
      ..write(obj.allowFreeItm)
      ..writeByte(13)
      ..write(obj.allowFreeInv);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalesEmployeesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
