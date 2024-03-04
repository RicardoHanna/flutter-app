import 'package:hive/hive.dart';

part 'itemsbatches_hive.g.dart';

@HiveType(typeId: 64)
class ItemsBatches extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String itemCode;

  @HiveField(2)
  late String batchID;

  @HiveField(3)
  late int sysNumber;

  @HiveField(4)
  late String batchNumber;

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

 
  ItemsBatches(
    this.cmpCode,
    this.itemCode,
    this.batchID,
    this.sysNumber,
    this.batchNumber,
    this.mnfSerial,
    this.lotNumber,
    this.mnfDate,
    this.expDate,
    this.notes

  );
}
