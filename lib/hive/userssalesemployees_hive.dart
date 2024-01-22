import 'package:hive/hive.dart';

part 'userssalesemployees_hive.g.dart';

@HiveType(typeId: 34)
class UserSalesEmployees extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String userCode;

  @HiveField(2)
  late String seCode;

  @HiveField(3)
  late String notes;

 
  UserSalesEmployees({
    required this.cmpCode,
    required this.userCode,
    required this.seCode,
    required this.notes,
  });


}
