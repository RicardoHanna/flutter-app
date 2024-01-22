import 'package:hive/hive.dart';

part 'usergroup_hive.g.dart'; // Add this line

@HiveType(typeId: 1)
class UserGroup extends HiveObject {
  @HiveField(0)
  late int groupcode;

  @HiveField(1)
  late String groupname;

  UserGroup({
required this.groupcode,
    required this.groupname,
  }
    
  );
}
