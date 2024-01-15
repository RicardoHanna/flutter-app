import 'package:hive/hive.dart';

part 'customerpropgroupspecialprice_hive.g.dart';

@HiveType(typeId: 50)
class CustomerPropGroupSpecialPrice extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String custGroupCode;

  @HiveField(2)
  late String propCode;

  @HiveField(3)
  late String disc;

  @HiveField(4)
  late double notes;

  
  CustomerPropGroupSpecialPrice({
    required this.cmpCode,
    required this.custGroupCode,
    required this.propCode,
    required this.disc,
    required this.notes,
  });


}
