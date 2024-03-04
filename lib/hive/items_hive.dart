import 'package:hive/hive.dart';

part 'items_hive.g.dart';

@HiveType(typeId: 3)
class Items extends HiveObject {
  @HiveField(0)
  late String itemCode;

  @HiveField(1)
  late String itemName;

  @HiveField(2)
  late String itemPrName;

  @HiveField(3)
  late String itemFName;

  @HiveField(4)
  late String itemPrFName;

  @HiveField(5)
  late String groupCode;

  @HiveField(6)
  late String categCode;

  @HiveField(7)
  late String brandCode;

  @HiveField(8)
  late String itemType;

  @HiveField(9)
  late String barCode;

  @HiveField(10)
  late String uom;

  @HiveField(11)
  late String picture;

  @HiveField(12)
  late String remark;

  @HiveField(13)
  late String manageBy;

  @HiveField(14)
  late dynamic vatCode;

  @HiveField(15)
  late dynamic weight;

  @HiveField(16)
  late String cmpCode;

  @HiveField(17)
  late String wUOMCode;

  @HiveField(18)
  late String salesItem;

  @HiveField(19)
  late String purchItem;

  @HiveField(20)
  late String invntItem;

  @HiveField(21)
  late String depCode;

  Items(
    this.itemCode,
    this.itemName,
    this.itemPrName,
    this.itemFName,
    this.itemPrFName,
    this.groupCode,
    this.categCode,
    this.brandCode,
    this.itemType,
    this.barCode,
    this.uom,
    this.picture,
    this.remark,
    this.manageBy,
    this.vatCode,
    this.weight,
    this.cmpCode,
    this.wUOMCode,
    this.salesItem,
    this.purchItem,
    this.invntItem,
    this.depCode
  );
}
