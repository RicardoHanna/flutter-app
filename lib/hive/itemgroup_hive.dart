import 'package:hive/hive.dart';

part 'itemgroup_hive.g.dart';

@HiveType(typeId: 4)
class ItemGroup extends HiveObject {
  @HiveField(0)
  late String groupCode;

  @HiveField(1)
  late String groupName;

  @HiveField(2)
  late String groupFName;

  @HiveField(3)
  late String cmpCode;


  ItemGroup(
    this.groupCode,
    this.groupName,
    this.groupFName,
    this.cmpCode
  );
}
