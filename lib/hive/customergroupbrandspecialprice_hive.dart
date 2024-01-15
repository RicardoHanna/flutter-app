import 'package:hive/hive.dart';

part 'customergroupbrandspecialprice_hive.g.dart';

@HiveType(typeId: 45)
class CustomerGroupBrandSpecialPrice extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String custGroupCode;

  @HiveField(2)
  late String brandCode;

  @HiveField(3)
  late double disc;

  @HiveField(4)
  late String notes;


 
  CustomerGroupBrandSpecialPrice({
    required this.cmpCode,
    required this.custGroupCode,
    required this.brandCode,
    required this.disc,
    required this.notes
  
  });


}
