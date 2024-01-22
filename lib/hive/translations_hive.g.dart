// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translations_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TranslationsAdapter extends TypeAdapter<Translations> {
  @override
  final int typeId = 2;

  @override
  Translations read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Translations(
      groupcode: fields[0] as int,
      translations: (fields[1] as Map).cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Translations obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.groupcode)
      ..writeByte(1)
      ..write(obj.translations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslationsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
