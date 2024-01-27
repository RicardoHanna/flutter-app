import 'package:hive/hive.dart';

part 'vatgroups_hive.g.dart';

@HiveType(typeId: 21)
class VATGroups extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String vatCode;

  @HiveField(2)
  late String vatName;

  @HiveField(3)
  late dynamic vatRate;

  @HiveField(4)
  late String baseCurCode;

  @HiveField(5)
  late String notes;


  VATGroups({
    required this.cmpCode,
    required this.vatCode,
    required this.vatName,
    required this.vatRate,
    required this.baseCurCode,
    required this.notes
  });


}
