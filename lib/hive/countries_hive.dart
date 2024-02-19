import 'package:hive/hive.dart';

part 'countries_hive.g.dart';

@HiveType(typeId: 56)
class Countries extends HiveObject {
  @HiveField(0)
  late String cmpCode; 
  
  @HiveField(1)
  late String countryCode;

  @HiveField(2)
  late String countryName;

  @HiveField(3)
  late String countryFName;

  @HiveField(4)
  late String addrFormatID;

  @HiveField(5)
  late String notes;


  Countries({
   required  this.cmpCode,
   required this.countryCode,
   required this.countryName,
   required this.countryFName,
   required this.addrFormatID,
   required this.notes
  }
  );

}
