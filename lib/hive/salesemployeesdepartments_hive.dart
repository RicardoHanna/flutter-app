import 'package:hive/hive.dart';

part 'salesemployeesdepartments_hive.g.dart';

@HiveType(typeId: 28)
class SalesEmployeesDepartements extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String seCode;

  @HiveField(2)
  late String deptCode;

  @HiveField(3)
  late int reqFromWhsCode;

  @HiveField(4)
  late String notes;

 


  SalesEmployeesDepartements({
    required this.cmpCode,
    required this.seCode,
    required this.deptCode,
    required this.reqFromWhsCode,
    required this.notes,
  });


}
