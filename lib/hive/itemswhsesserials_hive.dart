import 'package:hive/hive.dart';

part 'itemswhsesserials_hive.g.dart';

@HiveType(typeId: 61)
class ItemsWhsesSerials extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String itemCode;

  @HiveField(2)
  late String whsCode;

  @HiveField(3)
  late dynamic quantity;

  @HiveField(4)
  late String serialID;


  ItemsWhsesSerials(
    this.cmpCode,
    this.itemCode,
    this.whsCode,
    this.quantity,
    this.serialID,
  );
}
