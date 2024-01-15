import 'package:hive/hive.dart';

part 'salesemployeesitemsbrands_hive.g.dart';

@HiveType(typeId: 30)
class SalesEmployeesItemsBrands extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String seCode;

  @HiveField(2)
  late String brandCode;

  @HiveField(3)
  late int reqFromWhsCode;

  @HiveField(4)
  late String notes;

 


  SalesEmployeesItemsBrands({
    required this.cmpCode,
    required this.seCode,
    required this.brandCode,
    required this.reqFromWhsCode,
    required this.notes,
  });


}
