import 'package:hive/hive.dart';

part 'salesemployees_hive.g.dart';

@HiveType(typeId: 27)
class SalesEmployees extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String seCode;

  @HiveField(2)
  late String seName;

  @HiveField(3)
  late String seFName;

  @HiveField(4)
  late String mobile;

  @HiveField(5)
  late String email;

  @HiveField(6)
  late String whsCode;

  @HiveField(7)
  late int reqFromWhsCode;

  @HiveField(8)
  late String notes;


  SalesEmployees({
    required this.cmpCode,
    required this.seCode,
    required this.seName,
    required this.seFName,
    required this.mobile,
    required this.email,
    required this.whsCode,
    required this.reqFromWhsCode,
    required this.notes
  });


}
