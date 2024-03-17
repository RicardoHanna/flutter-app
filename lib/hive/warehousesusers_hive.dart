import 'package:hive/hive.dart';

part 'warehousesusers_hive.g.dart';

@HiveType(typeId: 65)
class WarehousesUsers extends HiveObject {
  @HiveField(0)
  late String userCode; 
  
  @HiveField(1)
  late String whsCode;
 
  @HiveField(2)
  late dynamic defaultwhsCode;

  WarehousesUsers({
   required  this.userCode,
   required this.whsCode,
   required this.defaultwhsCode

  }
  );

   Map<String, dynamic> toJson() {
    return {
      'userCode': userCode,
      'whsCode': whsCode,
      'defaultwhsCode': defaultwhsCode
    };
  }
}
