import 'package:hive/hive.dart';

part 'customerpropbrandspecialprice_hive.g.dart';

@HiveType(typeId: 49)
class CustomerPropBrandSpecialPrice extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String custPropCode;

  @HiveField(2)
  late String brandCode;

  @HiveField(3)
  late double disc;

  @HiveField(4)
  late String notes;

  
  CustomerPropBrandSpecialPrice({
    required this.cmpCode,
    required this.custPropCode,
    required this.brandCode,
    required this.disc,
    required this.notes,
  });


}
