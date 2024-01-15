// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customerattachments_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerAttachmentsAdapter extends TypeAdapter<CustomerAttachments> {
  @override
  final int typeId = 39;

  @override
  CustomerAttachments read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomerAttachments(
      cmpCode: fields[0] as String,
      custCode: fields[1] as String,
      attach: fields[2] as String,
      notes: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CustomerAttachments obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.custCode)
      ..writeByte(2)
      ..write(obj.attach)
      ..writeByte(3)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerAttachmentsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
