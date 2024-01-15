import 'package:hive/hive.dart';

part 'salesemployeesitemscategories_hive.g.dart';

@HiveType(typeId: 31)
class SalesEmployeesItemsCategories extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String seCode;

  @HiveField(2)
  late String categCode;

  @HiveField(3)
  late int reqFromWhsCode;

  @HiveField(4)
  late String notes;

 


  SalesEmployeesItemsCategories({
    required this.cmpCode,
    required this.seCode,
    required this.categCode,
    required this.reqFromWhsCode,
    required this.notes,
  });


}
