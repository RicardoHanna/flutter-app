// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'countries_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CountriesAdapter extends TypeAdapter<Countries> {
  @override
  final int typeId = 56;

  @override
  Countries read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Countries(
      cmpCode: fields[0] as String,
      countryCode: fields[1] as String,
      countryName: fields[2] as String,
      countryFName: fields[3] as String,
      addrFormatID: fields[4] as String,
      notes: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Countries obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.countryCode)
      ..writeByte(2)
      ..write(obj.countryName)
      ..writeByte(3)
      ..write(obj.countryFName)
      ..writeByte(4)
      ..write(obj.addrFormatID)
      ..writeByte(5)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountriesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
