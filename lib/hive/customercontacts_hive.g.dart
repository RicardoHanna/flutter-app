// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customercontacts_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerContactsAdapter extends TypeAdapter<CustomerContacts> {
  @override
  final int typeId = 37;

  @override
  CustomerContacts read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomerContacts(
      cmpCode: fields[0] as String,
      custCode: fields[1] as String,
      contactID: fields[2] as String,
      contactName: fields[3] as String,
      contactFName: fields[4] as String,
      phone: fields[5] as String,
      mobile: fields[6] as String,
      email: fields[7] as String,
      position: fields[8] as String,
      notes: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CustomerContacts obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.custCode)
      ..writeByte(2)
      ..write(obj.contactID)
      ..writeByte(3)
      ..write(obj.contactName)
      ..writeByte(4)
      ..write(obj.contactFName)
      ..writeByte(5)
      ..write(obj.phone)
      ..writeByte(6)
      ..write(obj.mobile)
      ..writeByte(7)
      ..write(obj.email)
      ..writeByte(8)
      ..write(obj.position)
      ..writeByte(9)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerContactsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
