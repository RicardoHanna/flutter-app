import 'package:hive/hive.dart';

part 'itemswhsesbatches_hive.g.dart';

@HiveType(typeId: 63)
class ItemsWhsesBatches extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String itemCode;

  @HiveField(2)
  late String whsCode;

  @HiveField(3)
  late dynamic quantity;

  @HiveField(4)
  late String batchID;

 
  ItemsWhsesBatches(
    this.cmpCode,
    this.itemCode,
    this.whsCode,
    this.quantity,
    this.batchID,

  );
}
