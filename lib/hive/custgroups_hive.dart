import 'package:hive/hive.dart';

part 'custgroups_hive.g.dart';

@HiveType(typeId: 22)
class CustGroups extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String grpCode;

  @HiveField(2)
  late String grpName;

  @HiveField(3)
  late String grpFName;

  @HiveField(4)
  late String notes;



  CustGroups({
    required this.cmpCode,
    required this.grpCode,
    required this.grpName,
    required this.grpFName,
    required this.notes
  });


}
