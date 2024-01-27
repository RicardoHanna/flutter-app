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
  late String brand;

  @HiveField(14)
  late String manageBy;

  @HiveField(15)
  late dynamic vatRate;

  @HiveField(16)
  late bool active;

  @HiveField(17)
  late dynamic weight;

  @HiveField(18)
  late String charect1;

  @HiveField(19)
  late String charact2;

  @HiveField(20)
  late String cmpCode;

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
    this.brand,
    this.manageBy,
    this.vatRate,
    this.active,
    this.weight,
    this.charect1,
    this.charact2,
    this.cmpCode
  );
}
