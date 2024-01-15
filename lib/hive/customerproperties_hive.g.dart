// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customerproperties_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerPropertiesAdapter extends TypeAdapter<CustomerProperties> {
  @override
  final int typeId = 38;

  @override
  CustomerProperties read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomerProperties(
      cmpCode: fields[0] as String,
      custCode: fields[1] as String,
      propCode: fields[2] as String,
      notes: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CustomerProperties obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.custCode)
      ..writeByte(2)
      ..write(obj.propCode)
      ..writeByte(3)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerPropertiesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
