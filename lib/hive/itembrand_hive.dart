import 'package:hive/hive.dart';

part 'itembrand_hive.g.dart';

@HiveType(typeId: 6)
class ItemBrand extends HiveObject {
  @HiveField(0)
  late String brandCode;

  @HiveField(1)
  late String brandName;

  @HiveField(2)
  late String brandFName;


  ItemBrand(
    this.brandCode,
    this.brandName,
    this.brandFName,
  );
}
