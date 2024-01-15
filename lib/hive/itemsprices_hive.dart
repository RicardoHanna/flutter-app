import 'package:hive/hive.dart';

part 'itemsprices_hive.g.dart';

@HiveType(typeId: 10)
class ItemsPrices extends HiveObject {
  @HiveField(0)
  late String plCode;

  @HiveField(1)
  late String itemCode;

  @HiveField(2)
  late String uom;

  @HiveField(3)
  late double basePrice;

  @HiveField(4)
  late String currency;

  @HiveField(5)
  late bool auto;

  @HiveField(6)
  late double disc;

  @HiveField(7)
  late double price;

  @HiveField(8)
  late String cmpCode;


  ItemsPrices(
    this.plCode,
    this.itemCode,
    this.uom,
    this.basePrice,
    this.currency,
    this.auto,
    this.disc,
    this.price,
    this.cmpCode
  );
}
