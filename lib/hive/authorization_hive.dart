import 'package:hive/hive.dart';

part 'authorization_hive.g.dart';

@HiveType(typeId: 13)
class Authorization extends HiveObject {
  @HiveField(0)
  late int menucode;

  @HiveField(1)
  late int groupcode;


  Authorization(
    {
   required this.menucode,
   required this.groupcode,
    }
  );
  // Convert UserGroup instance to JSON format
  Map<String, dynamic> toJson() {
    return {
      'menucode': menucode,
      'groupcode': groupcode,
    };
  }
}
