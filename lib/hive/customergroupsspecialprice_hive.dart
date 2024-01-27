import 'package:hive/hive.dart';

part 'customergroupsspecialprice_hive.g.dart';

@HiveType(typeId: 42)
class CustomerGroupsSpecialPrice extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String custCode;

  @HiveField(2)
  late String groupCode;

  @HiveField(3)
  late dynamic disc;

  @HiveField(4)
  late String notes;


 
  CustomerGroupsSpecialPrice({
    required this.cmpCode,
    required this.custCode,
    required this.groupCode,
    required this.disc,
    required this.notes,
  });


}
