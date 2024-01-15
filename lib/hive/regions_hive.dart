import 'package:hive/hive.dart';

part 'regions_hive.g.dart';

@HiveType(typeId: 24)
class Regions extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String regCode;

  @HiveField(2)
  late String regName;

  @HiveField(3)
  late String regFName;

  @HiveField(4)
  late String notes;



  Regions({
    required this.cmpCode,
    required this.regCode,
    required this.regName,
    required this.regFName,
    required this.notes
  });


}
