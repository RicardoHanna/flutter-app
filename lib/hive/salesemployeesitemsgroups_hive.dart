import 'package:hive/hive.dart';

part 'salesemployeesitemsgroups_hive.g.dart';

@HiveType(typeId: 32)
class SalesEmployeesItemsGroups extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String seCode;

  @HiveField(2)
  late String groupCode;

  @HiveField(3)
  late dynamic reqFromWhsCode;

  @HiveField(4)
  late String notes;

 


  SalesEmployeesItemsGroups({
    required this.cmpCode,
    required this.seCode,
    required this.groupCode,
    required this.reqFromWhsCode,
    required this.notes,
  });


}
