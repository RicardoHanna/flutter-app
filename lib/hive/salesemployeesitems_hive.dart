import 'package:hive/hive.dart';

part 'salesemployeesitems_hive.g.dart';

@HiveType(typeId: 33)
class SalesEmployeesItems extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String seCode;

  @HiveField(2)
  late String itemCode;

  @HiveField(3)
  late int reqFromWhsCode;

  @HiveField(4)
  late String notes;

 


  SalesEmployeesItems({
    required this.cmpCode,
    required this.seCode,
    required this.itemCode,
    required this.reqFromWhsCode,
    required this.notes,
  });


}
