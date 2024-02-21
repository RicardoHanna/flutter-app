import 'package:hive/hive.dart';

part 'pricelistauthorization_hive.g.dart';

@HiveType(typeId: 53)
class PriceListAuthorization extends HiveObject {
  @HiveField(0)
  late String userCode; 
  
  @HiveField(1)
  late String cmpCode;

  @HiveField(2)
  late String authoGroup;
 
  PriceListAuthorization({
   required  this.userCode,
   required this.cmpCode,
   required this.authoGroup,
  }
  );
   Map<String, dynamic> toJson() {
    return {
      'userCode': userCode,
      'cmpCode': cmpCode,
      'authoGroup':authoGroup
    };
  }
}
