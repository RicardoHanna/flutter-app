import 'package:hive/hive.dart';

part 'customercategspecialprice_hive.g.dart';

@HiveType(typeId: 43)
class CustomerCategSpecialPrice extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String custCode;

  @HiveField(2)
  late String categCode;

  @HiveField(3)
  late int disc;

  @HiveField(4)
  late String notes;


 
  CustomerCategSpecialPrice({
    required this.cmpCode,
    required this.custCode,
    required this.categCode,
    required this.disc,
    required this.notes,
  });


}
