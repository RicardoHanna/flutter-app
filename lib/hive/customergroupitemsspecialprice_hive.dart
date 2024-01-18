import 'package:hive/hive.dart';

part 'customergroupitemsspecialprice_hive.g.dart';

@HiveType(typeId: 44)
class CustomerGroupItemsSpecialPrice extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String custGroupCode;

  @HiveField(2)
  late String itemCode;

  @HiveField(3)
  late String uom;

  @HiveField(4)
  late int basePrice;

  @HiveField(5)
  late String currency;

  @HiveField(6)
  late bool auto;

  @HiveField(7)
  late int disc;

  @HiveField(8)
  late int price;

  @HiveField(9)
  late String notes;


 
  CustomerGroupItemsSpecialPrice({
    required this.cmpCode,
    required this.custGroupCode,
    required this.itemCode,
    required this.uom,
    required this.basePrice,
    required this.currency,
    required this.auto,
    required this.disc,
    required this.price,
    required this.notes,
  });


}
