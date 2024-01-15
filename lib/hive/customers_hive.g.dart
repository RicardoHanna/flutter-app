// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customers_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomersAdapter extends TypeAdapter<Customers> {
  @override
  final int typeId = 35;

  @override
  Customers read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Customers(
      cmpCode: fields[0] as String,
      custCode: fields[1] as String,
      custName: fields[2] as String,
      custFName: fields[3] as String,
      groupCode: fields[4] as String,
      mofNum: fields[5] as String,
      barcode: fields[6] as String,
      phone: fields[7] as String,
      mobile: fields[8] as String,
      fax: fields[9] as String,
      website: fields[10] as String,
      email: fields[11] as String,
      active: fields[12] as bool,
      printLayout: fields[13] as String,
      dfltAddressID: fields[14] as String,
      dfltContactID: fields[15] as String,
      curCode: fields[16] as String,
      cashClient: fields[17] as String,
      discType: fields[18] as String,
      vatCode: fields[19] as String,
      prListCode: fields[20] as String,
      payTermsCode: fields[21] as String,
      discount: fields[22] as double,
      creditLimit: fields[23] as double,
      balance: fields[24] as double,
      balanceDue: fields[25] as double,
      notes: fields[26] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Customers obj) {
    writer
      ..writeByte(27)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.custCode)
      ..writeByte(2)
      ..write(obj.custName)
      ..writeByte(3)
      ..write(obj.custFName)
      ..writeByte(4)
      ..write(obj.groupCode)
      ..writeByte(5)
      ..write(obj.mofNum)
      ..writeByte(6)
      ..write(obj.barcode)
      ..writeByte(7)
      ..write(obj.phone)
      ..writeByte(8)
      ..write(obj.mobile)
      ..writeByte(9)
      ..write(obj.fax)
      ..writeByte(10)
      ..write(obj.website)
      ..writeByte(11)
      ..write(obj.email)
      ..writeByte(12)
      ..write(obj.active)
      ..writeByte(13)
      ..write(obj.printLayout)
      ..writeByte(14)
      ..write(obj.dfltAddressID)
      ..writeByte(15)
      ..write(obj.dfltContactID)
      ..writeByte(16)
      ..write(obj.curCode)
      ..writeByte(17)
      ..write(obj.cashClient)
      ..writeByte(18)
      ..write(obj.discType)
      ..writeByte(19)
      ..write(obj.vatCode)
      ..writeByte(20)
      ..write(obj.prListCode)
      ..writeByte(21)
      ..write(obj.payTermsCode)
      ..writeByte(22)
      ..write(obj.discount)
      ..writeByte(23)
      ..write(obj.creditLimit)
      ..writeByte(24)
      ..write(obj.balance)
      ..writeByte(25)
      ..write(obj.balanceDue)
      ..writeByte(26)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomersAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
