import 'package:hive/hive.dart';

part 'itemprop_hive.g.dart';

@HiveType(typeId: 59)
class ItemProp extends HiveObject {
  @HiveField(0)
  late String cmpCode; 
  
  @HiveField(1)
  late String itemCode;

  @HiveField(2)
  late String propCode;

  @HiveField(3)
  late String notes;

  ItemProp({
   required  this.cmpCode,
   required this.itemCode,
   required this.propCode,
   required this.notes
  }
  );

}
