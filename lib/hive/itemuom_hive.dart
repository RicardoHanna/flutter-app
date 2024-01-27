import 'package:hive/hive.dart';

part 'itemuom_hive.g.dart';

@HiveType(typeId: 8)
class ItemUOM extends HiveObject {
  @HiveField(0)
  late String itemCode;

  @HiveField(1)
  late String uom;

  @HiveField(2)
  late dynamic qtyperUOM;

  @HiveField(3)
  late String barCode;

  @HiveField(4)
  late String cmpCode;

  ItemUOM(
    this.itemCode,
    this.uom,
    this.qtyperUOM,
    this.barCode,
    this.cmpCode
  );
}
