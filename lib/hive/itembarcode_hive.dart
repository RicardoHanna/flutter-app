import 'package:hive/hive.dart';

part 'itembarcode_hive.g.dart';

@HiveType(typeId: 58)
class ItemBarcode extends HiveObject {
  @HiveField(0)
  late String cmpCode; 
  
  @HiveField(1)
  late String itemCode;

  @HiveField(2)
  late String uomCode;

  @HiveField(3)
  late String barcode;

  @HiveField(4)
  late String notes;


  ItemBarcode({
   required  this.cmpCode,
   required this.itemCode,
   required this.uomCode,
   required this.barcode,
   required this.notes
  }
  );

}
