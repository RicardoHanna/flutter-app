import 'package:hive/hive.dart';

part 'customeritemsspecialprice_hive.g.dart';

@HiveType(typeId: 40)
class CustomerItemsSpecialPrice extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String custCode;

  @HiveField(2)
  late String itemCode;

  @HiveField(3)
  late String uom;

  @HiveField(4)
  late dynamic basePrice;

  @HiveField(5)
  late String currency;

  @HiveField(6)
  late bool auto;

  @HiveField(7)
  late dynamic disc;

  @HiveField(8)
  late dynamic price;

  @HiveField(9)
  late String notes;

 
  CustomerItemsSpecialPrice({
    required this.cmpCode,
    required this.custCode,
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
