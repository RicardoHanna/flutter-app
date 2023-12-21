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


  ItemGroup(
    this.groupCode,
    this.groupName,
    this.groupFName,
  );
}
