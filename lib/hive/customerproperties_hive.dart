import 'package:hive/hive.dart';

part 'customerproperties_hive.g.dart';

@HiveType(typeId: 38)
class CustomerProperties extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String custCode;

  @HiveField(2)
  late String propCode;

  @HiveField(3)
  late String notes;

 
  CustomerProperties({
    required this.cmpCode,
    required this.custCode,
    required this.propCode,
    required this.notes,
  });


}
