import 'package:hive/hive.dart';

part 'customerpropcategspecialprice_hive.g.dart';

@HiveType(typeId: 51)
class CustomerPropCategSpecialPrice extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String custPropCode;

  @HiveField(2)
  late String categCode;

  @HiveField(3)
  late double disc;

  @HiveField(4)
  late String notes;

  
  CustomerPropCategSpecialPrice({
    required this.cmpCode,
    required this.custPropCode,
    required this.categCode,
    required this.disc,
    required this.notes,
  });


}
