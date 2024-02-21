// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'companies_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompaniesAdapter extends TypeAdapter<Companies> {
  @override
  final int typeId = 17;

  @override
  Companies read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Companies(
      cmpCode: fields[0] as String,
      cmpName: fields[1] as String,
      cmpFName: fields[2] as String,
      tel: fields[3] as String,
      mobile: fields[4] as String,
      address: fields[5] as String,
      fAddress: fields[6] as String,
      prHeader: fields[7] as String,
      prFHeader: fields[8] as String,
      prFooter: fields[9] as String,
      prFFooter: fields[10] as String,
      mainCurCode: fields[11] as String,
      secCurCode: fields[12] as String,
      rateType: fields[13] as String,
      issueBatchMethod: fields[14] as String,
      systemAdminID: fields[15] as String,
      notes: fields[16] as String,
      priceDec: fields[17] as dynamic,
      amntDec: fields[18] as dynamic,
      qtyDec: fields[19] as dynamic,
      roundMethod: fields[20] as String,
      importMethod: fields[21] as String,
      time: fields[22] as TimeOfDay,
    );
  }

  @override
  void write(BinaryWriter writer, Companies obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.cmpName)
      ..writeByte(2)
      ..write(obj.cmpFName)
      ..writeByte(3)
      ..write(obj.tel)
      ..writeByte(4)
      ..write(obj.mobile)
      ..writeByte(5)
      ..write(obj.address)
      ..writeByte(6)
      ..write(obj.fAddress)
      ..writeByte(7)
      ..write(obj.prHeader)
      ..writeByte(8)
      ..write(obj.prFHeader)
      ..writeByte(9)
      ..write(obj.prFooter)
      ..writeByte(10)
      ..write(obj.prFFooter)
      ..writeByte(11)
      ..write(obj.mainCurCode)
      ..writeByte(12)
      ..write(obj.secCurCode)
      ..writeByte(13)
      ..write(obj.rateType)
      ..writeByte(14)
      ..write(obj.issueBatchMethod)
      ..writeByte(15)
      ..write(obj.systemAdminID)
      ..writeByte(16)
      ..write(obj.notes)
      ..writeByte(17)
      ..write(obj.priceDec)
      ..writeByte(18)
      ..write(obj.amntDec)
      ..writeByte(19)
      ..write(obj.qtyDec)
      ..writeByte(20)
      ..write(obj.roundMethod)
      ..writeByte(21)
      ..write(obj.importMethod)
      ..writeByte(22)
      ..write(obj.time);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompaniesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
