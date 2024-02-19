// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pricelist_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PriceListAdapter extends TypeAdapter<PriceList> {
  @override
  final int typeId = 9;

  @override
  PriceList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PriceList(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as dynamic,
      fields[4] as double,
      fields[5] as bool,
      fields[6] as String,
      fields[7] as String,
      fields[8] as String,
      fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PriceList obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.plCode)
      ..writeByte(1)
      ..write(obj.plName)
      ..writeByte(2)
      ..write(obj.currency)
      ..writeByte(3)
      ..write(obj.basePL)
      ..writeByte(4)
      ..write(obj.factor)
      ..writeByte(5)
      ..write(obj.incVAT)
      ..writeByte(6)
      ..write(obj.cmpCode)
      ..writeByte(7)
      ..write(obj.authoGroup)
      ..writeByte(8)
      ..write(obj.plFName)
      ..writeByte(9)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriceListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
