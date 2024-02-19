import 'package:hive/hive.dart';

part 'itemmanufacturers_hive.g.dart';

@HiveType(typeId: 57)
class ItemManufacturers extends HiveObject {
  @HiveField(0)
  late String cmpCode; 
  
  @HiveField(1)
  late String manufCode;

  @HiveField(2)
  late String manufName;

  @HiveField(3)
  late String manufFName;

  @HiveField(4)
  late String notes;


  ItemManufacturers({
   required  this.cmpCode,
   required this.manufCode,
   required this.manufName,
   required this.manufFName,
   required this.notes
  }
  );

}
