import 'package:hive/hive.dart';

part 'addressformat_hive.g.dart';

@HiveType(typeId: 55)
class AddressFormat extends HiveObject {
  @HiveField(0)
  late String cmpCode; 
  
  @HiveField(1)
  late String addrFormatID;
 

  AddressFormat({
   required  this.cmpCode,
   required this.addrFormatID,
  }
  );

}
