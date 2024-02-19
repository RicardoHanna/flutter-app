// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paymentterms_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentTermsAdapter extends TypeAdapter<PaymentTerms> {
  @override
  final int typeId = 26;

  @override
  PaymentTerms read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentTerms(
      cmpCode: fields[0] as String,
      ptCode: fields[1] as String,
      ptName: fields[2] as String,
      ptFName: fields[3] as String,
      startFrom: fields[4] as String,
      nbrofDays: fields[5] as int,
      notes: fields[6] as String,
      nbrofMonths: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentTerms obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.ptCode)
      ..writeByte(2)
      ..write(obj.ptName)
      ..writeByte(3)
      ..write(obj.ptFName)
      ..writeByte(4)
      ..write(obj.startFrom)
      ..writeByte(5)
      ..write(obj.nbrofDays)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.nbrofMonths);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentTermsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
