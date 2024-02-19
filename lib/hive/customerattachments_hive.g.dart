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
      attachType: fields[3] as String,
      notes: fields[4] as String,
      lineID: fields[5] as String,
      attachPath: fields[6] as String,
      attachFile: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CustomerAttachments obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.custCode)
      ..writeByte(2)
      ..write(obj.attach)
      ..writeByte(3)
      ..write(obj.attachType)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.lineID)
      ..writeByte(6)
      ..write(obj.attachPath)
      ..writeByte(7)
      ..write(obj.attachFile);
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
