import 'package:hive/hive.dart';

part 'departements_hive.g.dart';

@HiveType(typeId: 18)
class Departements extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String depCode;

  @HiveField(2)
  late String depName;

  @HiveField(3)
  late String depFName;

  @HiveField(4)
  late String notes;


  Departements({
    required this.cmpCode,
    required this.depCode,
    required this.depName,
    required this.depFName,
    required this.notes
  });


}
