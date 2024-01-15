import 'package:hive/hive.dart';

part 'customergroupgroupspecialprice_hive.g.dart';

@HiveType(typeId: 46)
class CustomerGroupGroupSpecialPrice extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String custGroupCode;

  @HiveField(2)
  late String groupCode;

  @HiveField(3)
  late double disc;

  @HiveField(4)
  late String notes;


 
  CustomerGroupGroupSpecialPrice({
    required this.cmpCode,
    required this.custGroupCode,
    required this.groupCode,
    required this.disc,
    required this.notes
  
  });


}
