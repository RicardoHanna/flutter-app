import 'package:hive/hive.dart';

part 'salesemployeescustomers_hive.g.dart';

@HiveType(typeId: 28)
class SalesEmployeesCustomers extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String seCode;

  @HiveField(2)
  late String custCode;

  @HiveField(3)
  late String notes;

 


  SalesEmployeesCustomers({
    required this.cmpCode,
    required this.seCode,
    required this.custCode,
    required this.notes,
  });


}
