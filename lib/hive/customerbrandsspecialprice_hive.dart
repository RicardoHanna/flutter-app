import 'package:hive/hive.dart';

part 'customerbrandsspecialprice_hive.g.dart';

@HiveType(typeId: 41)
class CustomerBrandsSpecialPrice extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String custCode;

  @HiveField(2)
  late String brandCode;

  @HiveField(3)
  late dynamic disc;

  @HiveField(4)
  late String notes;


 
  CustomerBrandsSpecialPrice({
    required this.cmpCode,
    required this.custCode,
    required this.brandCode,
    required this.disc,
    required this.notes,

  });


}
