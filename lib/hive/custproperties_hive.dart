import 'package:hive/hive.dart';

part 'custproperties_hive.g.dart';

@HiveType(typeId: 23)
class CustProperties extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String propCode;

  @HiveField(2)
  late String propName;

  @HiveField(3)
  late String propFName;

  @HiveField(4)
  late String notes;



  CustProperties({
    required this.cmpCode,
    required this.propCode,
    required this.propName,
    required this.propFName,
    required this.notes
  });


}
