// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customeraddresses_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerAddressesAdapter extends TypeAdapter<CustomerAddresses> {
  @override
  final int typeId = 36;

  @override
  CustomerAddresses read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomerAddresses(
      cmpCode: fields[0] as String,
      custCode: fields[1] as String,
      addressID: fields[2] as String,
      address: fields[3] as String,
      fAddress: fields[4] as String,
      regCode: fields[5] as String,
      gpslat: fields[6] as String,
      gpslong: fields[7] as String,
      notes: fields[8] as String,
      addressType: fields[9] as String,
      countryCode: fields[10] as String,
      city: fields[11] as String,
      block: fields[12] as String,
      street: fields[13] as String,
      zipCode: fields[14] as String,
      building: fields[15] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CustomerAddresses obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.custCode)
      ..writeByte(2)
      ..write(obj.addressID)
      ..writeByte(3)
      ..write(obj.address)
      ..writeByte(4)
      ..write(obj.fAddress)
      ..writeByte(5)
      ..write(obj.regCode)
      ..writeByte(6)
      ..write(obj.gpslat)
      ..writeByte(7)
      ..write(obj.gpslong)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.addressType)
      ..writeByte(10)
      ..write(obj.countryCode)
      ..writeByte(11)
      ..write(obj.city)
      ..writeByte(12)
      ..write(obj.block)
      ..writeByte(13)
      ..write(obj.street)
      ..writeByte(14)
      ..write(obj.zipCode)
      ..writeByte(15)
      ..write(obj.building);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerAddressesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
