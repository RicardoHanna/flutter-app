import 'package:hive/hive.dart';

part 'customergroupcategspecialprice_hive.g.dart';

@HiveType(typeId: 47)
class CustomerGroupCategSpecialPrice extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String custGroupCode;

  @HiveField(2)
  late String categCode;

  @HiveField(3)
  late dynamic disc;

  @HiveField(4)
  late String notes;


 
  CustomerGroupCategSpecialPrice({
    required this.cmpCode,
    required this.custGroupCode,
    required this.categCode,
    required this.disc,
    required this.notes
  
  });


}
