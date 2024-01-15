// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currencies_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CurrenciesAdapter extends TypeAdapter<Currencies> {
  @override
  final int typeId = 20;

  @override
  Currencies read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Currencies(
      cmpCode: fields[0] as String,
      curCode: fields[1] as String,
      curName: fields[2] as String,
      curFName: fields[3] as String,
      notes: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Currencies obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.curCode)
      ..writeByte(2)
      ..write(obj.curName)
      ..writeByte(3)
      ..write(obj.curFName)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrenciesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
