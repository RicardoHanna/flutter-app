import 'package:hive/hive.dart';

part 'warehouses_hive.g.dart';

@HiveType(typeId: 25)
class Warehouses extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String whsCode;

  @HiveField(2)
  late String whsName;

  @HiveField(3)
  late String whsFName;

  @HiveField(4)
  late String notes;

  @HiveField(5)
  late bool binActivate;



  Warehouses({
    required this.cmpCode,
    required this.whsCode,
    required this.whsName,
    required this.whsFName,
    required this.notes,
    required this.binActivate
  });


}
