import 'package:hive/hive.dart';

part 'itemswhses_hive.g.dart';

@HiveType(typeId: 60)
class ItemsWhses extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String itemCode;

  @HiveField(2)
  late String whsCode;

  @HiveField(3)
  late dynamic qty;


  ItemsWhses(
    this.cmpCode,
    this.itemCode,
    this.whsCode,
    this.qty,
  );
}
