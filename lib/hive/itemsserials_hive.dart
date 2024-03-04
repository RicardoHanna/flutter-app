import 'package:hive/hive.dart';

part 'itemsserials_hive.g.dart';

@HiveType(typeId: 62)
class ItemsSerials extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String itemCode;

  @HiveField(2)
  late String serialID;

  @HiveField(3)
  late int sysNumber;

  @HiveField(4)
  late String serialNumber;

  @HiveField(5)
  late String mnfSerial;

  @HiveField(6)
  late String lotNumber;

  @HiveField(7)
  late DateTime mnfDate;

  @HiveField(8)
  late DateTime expDate;

  @HiveField(9)
  late String notes;

  ItemsSerials(
    this.cmpCode,
    this.itemCode,
    this.serialID,
    this.sysNumber,
    this.serialNumber,
    this.mnfSerial,
    this.lotNumber,
    this.mnfDate,
    this.expDate,
    this.notes
  );
}
